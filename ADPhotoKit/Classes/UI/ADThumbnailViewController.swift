//
//  ADThumbnailViewController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import UIKit
import PhotosUI

struct ADThumbnailParams {
    var maxCount: Int?
    
    var minImageCount: Int?
    var maxImageCount: Int?
    
    var minVideoCount: Int?
    var maxVideoCount: Int?
    
    var minVideoTime: Int?
    var maxVideoTime: Int?
}

class ADThumbnailViewController: UIViewController {
    
    let model: ADPhotoKitPickerInternal
    let albumList: ADAlbumModel
    
    var collectionView: UICollectionView!
    var dataSource: ADAssetListDataSource!
    
    var toolBarView: ADThumbnailToolBarable!
    
    init(model: ADPhotoKitPickerInternal, albumList: ADAlbumModel) {
        self.model = model
        self.albumList = albumList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cleanTimer()
    }
    
    /// 滑动选择
    private var panGesture: UIPanGestureRecognizer?
    private var selectionInfo: SlideSelectionInfo?
    private var selectionRange: SlideSelectionRange?
    
    private enum AutoScrollDirection {
        case none
        case top
        case bottom
    }
    private var autoScrollTimer: CADisplayLink?
    private var lastPanUpdateTime = CACurrentMediaTime()
    private var autoScrollInfo: (direction: AutoScrollDirection, speed: CGFloat) = (.none, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if model.assetOpts.contains(.slideSelect) {
            if (model.params.maxCount ?? Int.max) > 1 {
                panGesture = UIPanGestureRecognizer(target: self, action: #selector(slideSelectAction(_:)))
                view.addGestureRecognizer(panGesture!)
            }
        }
        
        reloadAssets()
    }
    
    func reloadAssets() {
        if dataSource.list.isEmpty {
            let hud = ADProgressHUD()
            hud.show()
            dataSource.reloadData() {
                hud.hide()
            }
        }else{
            dataSource.reloadData()
        }
    }

}

extension ADThumbnailViewController {
    
    func setupUI() {
        automaticallyAdjustsScrollViewInsets = true
        edgesForExtendedLayout = .all
        view.backgroundColor = UIColor(hex: 0x323232)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .always
        }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        collectionView.regisiter(cell: ADThumbnailListCell.self)
        collectionView.regisiter(cell: ADCameraCell.self)
        collectionView.regisiter(cell: ADAddPhotoCell.self)
        
        toolBarView = ADThumbnailToolBarView(model: model)
        toolBarView.selectCount = model.assets.count
        view.addSubview(toolBarView)
        toolBarView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(toolBarView.height+tabBarOffset)
        }
        toolBarView.previewActionBlock = { [weak self] in
            guard let strong = self else { return }
            let browser = ADAssetModelBrowserController(dataSource: strong.dataSource, index: 0)
            strong.navigationController?.pushViewController(browser, animated: true)
        }
        
        dataSource = ADAssetListDataSource(reloadable: collectionView, album: albumList, select: model.assets, albumOpts: model.albumOpts, assetOpts: model.assetOpts)
        dataSource.selectAssetChanged = { [weak self] count in
            self?.toolBarView.selectCount = count
        }
        
    }
    
}

extension ADThumbnailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ADPhotoKitConfiguration.default.thumbnailLayout.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ADPhotoKitConfiguration.default.thumbnailLayout.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 0, bottom: 3+toolBarView.height, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ADAssetModel.thumbnailSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.list.count+dataSource.appendCellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if dataSource.enableCameraCell {
            if indexPath.row == dataSource.cameraCellIndex {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADCameraCell.reuseIdentifier, for: indexPath) as! ADCameraCell
                if model.assetOpts.contains(.captureOnTakeAsset) {
                    cell.startCapture()
                }
                return cell
            }
        }
        
        if #available(iOS 14, *) {
            if dataSource.enableAddAssetCell {
                if indexPath.row == dataSource.addAssetCellIndex {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADAddPhotoCell.reuseIdentifier, for: indexPath) as! ADAddPhotoCell
                    return cell
                }
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADThumbnailListCell.reuseIdentifier, for: indexPath) as! ADThumbnailListCell
        
        let modify = model.albumOpts.contains(.ascending) ? indexPath : IndexPath(row: indexPath.row-dataSource.appendCellCount, section: indexPath.section)
        let model = dataSource.list[modify.row]
        cell.configure(with: model, indexPath: modify)
        cell.selectAction = { [weak self] cell, sel in
            guard let strong = self else {
                return
            }
            if sel { //取消选择
                self?.dataSource.selectAssetAt(index: cell.indexPath.row)
            }else{
                self?.dataSource.deselectAssetAt(index: cell.indexPath.row)
            }
            
            /// 单独刷新这个cell 防止选择动画停止
            cell.configure(with: strong.dataSource.list[cell.indexPath.row], indexPath: nil)
            
            var indexs = strong.collectionView.indexPathsForVisibleItems
            indexs.removeAll {$0 == cell.indexPath}
            self?.collectionView.reloadItems(at: indexs)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let c = cell as? ADThumbnailListCell else {
            return
        }
        let index = model.albumOpts.contains(.ascending) ? indexPath.row : indexPath.row-dataSource.appendCellCount
        let item = dataSource.list[index]
        if !c.selectStatus.isSelect {
            c.selectStatus = .select(index: nil)
            item.selectStatus = .select(index: nil)
            let selected = dataSource.selects.count
            let max = model.params.maxCount ?? Int.max
            if selected < max {
                let itemIsImage = item.type.isImage
                if model.assetOpts.contains(.mixSelect) {
                    let videoCount = dataSource.selects.filter { $0.asset.mediaType == .video }.count
                    let maxVideoCount = model.params.maxVideoCount ?? Int.max
                    let maxImageCount = model.params.maxImageCount ?? Int.max
                    if videoCount >= maxVideoCount, !itemIsImage {
                        c.selectStatus = .deselect
                        item.selectStatus = .deselect
                    }else if (dataSource.selects.count - videoCount) >= maxImageCount, itemIsImage {
                        c.selectStatus = .deselect
                        item.selectStatus = .deselect
                    }
                }else{
                    if item.type.isImage != model.selectMediaImage {
                        c.selectStatus = .deselect
                        item.selectStatus = .deselect
                    }else{
                        let videoCount = dataSource.selects.filter { $0.asset.mediaType == .video }.count
                        let maxVideoCount = model.params.maxVideoCount ?? Int.max
                        let maxImageCount = model.params.maxImageCount ?? Int.max
                        if videoCount >= maxVideoCount, !itemIsImage {
                            c.selectStatus = .deselect
                            item.selectStatus = .deselect
                        }else if (dataSource.selects.count - videoCount) >= maxImageCount, itemIsImage {
                            c.selectStatus = .deselect
                            item.selectStatus = .deselect
                        }
                    }
                }
            }else{
                c.selectStatus = .deselect
                item.selectStatus = .deselect
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if cell is ADCameraCell {
            presentCameraController()
        }else if cell is ADAddPhotoCell {
            if #available(iOS 14, *) {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            }
        }else if let c = cell as? ADThumbnailListCell {
            if !model.assetOpts.contains(.allowPreview) {
                c.cellSelectAction()
            }else if c.selectStatus.isEnable {
                let modify = model.albumOpts.contains(.ascending) ? indexPath : IndexPath(row: indexPath.row-dataSource.appendCellCount, section: indexPath.section)
                let browser = ADAssetModelBrowserController(dataSource: dataSource, index: modify.row)
                navigationController?.pushViewController(browser, animated: true)
            }
        }
    }
}

/// 滑动手势
private extension ADThumbnailViewController {
    
    typealias SlideSelectionInfo = (begin: Int, select: Bool, indexs: [Int])
    typealias SlideSelectionRange = (s: Int, e: Int, len: Int, index: Int)
    
    @objc
    func slideSelectAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else {
            return
        }
        let cell = collectionView.cellForItem(at: indexPath) as? ADThumbnailListCell
        if pan.state == .began {
            if cell != nil {
                slideRangeDidChange(indexPath: indexPath, cell: cell!)
            }
        }else if pan.state == .changed {
            autoScrollWhenSlideSelect(pan)
            if cell != nil {
                slideRangeDidChange(indexPath: indexPath, cell: cell!)
            }
        }else{
            cleanTimer()
            selectionInfo = nil
            selectionRange = nil
        }
    }
    
    func slideRangeDidChange(indexPath: IndexPath, cell: ADThumbnailListCell) {
        let index = model.albumOpts.contains(.ascending) ? indexPath.row : indexPath.row-dataSource.appendCellCount
        let model = dataSource.list[index]
        //已经有第一个
        if let info = selectionInfo, let range = selectionRange {
            if range.index != index {
                let current: SlideSelectionRange = (min(index, info.begin),max(index, info.begin),max(index, info.begin)-min(index, info.begin),index)
                var shrankRange: (Int,Int)?
                var expandRange: (Int,Int)?
                if range.s == current.s || range.e == current.e { //同方向
                    let minIndex = range.s == current.s ? min(range.e, current.e) : min(range.s, current.s)
                    let maxIndex = range.s == current.s ? max(range.e, current.e) : max(range.s, current.s)
                    let shink = range.len > current.len
                    if shink { //缩短
                        shrankRange = (minIndex,maxIndex)
                    }else{ //扩大
                        expandRange = (minIndex,maxIndex)
                    }
                }else{
                    shrankRange = (range.s,range.e)
                    expandRange = (current.s,current.e)
                }
                if let range = shrankRange {
                    for i in range.0...range.1 {
                        let item = dataSource.list[i]
                        if i != info.begin {
                            if info.select && item.selectStatus.isSelect {
                                dataSource.deselectAssetAt(index: i)
                            }
                            if !info.select && info.indexs.contains(i) {
                                dataSource.selectAssetAt(index: i)
                            }
                        }
                    }
                }
                if let range = expandRange {
                    for i in range.0...range.1 {
                        let item = dataSource.list[i]
                        if i != info.begin {
                            if info.select && !item.selectStatus.isSelect && item.selectStatus.isEnable {
                                dataSource.selectAssetAt(index: i)
                            }
                            if !info.select && item.selectStatus.isSelect {
                                dataSource.deselectAssetAt(index: i)
                            }
                        }
                    }
                }
                selectionRange = current
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                }
            }
        }else{
            if model.selectStatus.isEnable {
                let indexs = dataSource.selects.compactMap { $0.index }
                selectionInfo = (index,!model.selectStatus.isSelect,indexs)
                selectionRange = (index,index,0,index)
                if model.selectStatus.isSelect { //取消选择
                    dataSource.deselectAssetAt(index: index)
                }else{
                    dataSource.selectAssetAt(index: index)
                }
                cell.configure(with: model)
            }
        }
    }
    
    func autoScrollWhenSlideSelect(_ pan: UIPanGestureRecognizer) {
        guard model.assetOpts.contains(.autoScroll) else {
            return
        }
        
        if let max = model.params.maxCount {
            guard model.assets.count < max else {
                cleanTimer()
                return
            }
        }
        
        let top = navigationController!.navigationBar.frame.height + 30
        let bottom = view.frame.height - toolBarView.height - 30
        
        let point = pan.location(in: self.view)
        
        var diff: CGFloat = 0
        var direction: AutoScrollDirection = .none
        if point.y < top {
            diff = top - point.y
            direction = .top
        } else if point.y > bottom {
            diff = point.y - bottom
            direction = .bottom
        } else {
            cleanTimer()
            return
        }
                
        let speed = min(diff, 60) / 60 * ADPhotoKitConfiguration.default.autoScrollMaxSpeed
        
        autoScrollInfo = (direction, speed)
        
        if autoScrollTimer == nil {
            autoScrollTimer = CADisplayLink(target: ADWeakProxy(target: self), selector: #selector(autoScrollAction))
            autoScrollTimer?.add(to: RunLoop.current, forMode: .common)
        }
    }
    
    func cleanTimer() {
        autoScrollTimer?.remove(from: RunLoop.current, forMode: .common)
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    @objc
    func autoScrollAction() {
        guard autoScrollInfo.direction != .none else { return }
        if CACurrentMediaTime() - lastPanUpdateTime > 0.2 {
            // Finger may be not moved in slide selection mode
            slideSelectAction(panGesture!)
        }
        let duration = CGFloat(autoScrollTimer?.duration ?? 1 / 60)
        let distance = autoScrollInfo.speed * duration
        let offset = collectionView.contentOffset
        let inset = collectionView.contentInset
        if autoScrollInfo.direction == .top, offset.y + inset.top > distance {
            collectionView.contentOffset = CGPoint(x: 0, y: offset.y - distance)
        } else if autoScrollInfo.direction == .bottom, offset.y + collectionView.bounds.height + distance - inset.bottom < collectionView.contentSize.height {
            collectionView.contentOffset = CGPoint(x: 0, y: offset.y + distance)
        }
    }
    
}

/// 相机
extension ADThumbnailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentCameraController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.videoQuality = .typeHigh
            picker.sourceType = .camera
            picker.cameraFlashMode = .off
            var mediaTypes = [String]()
            if model.assetOpts.contains(.allowTakePhotoAsset) {
                mediaTypes.append("public.image")
            }
            if model.assetOpts.contains(.allowTakeVideoAsset) {
                mediaTypes.append("public.movie")
            }
            picker.mediaTypes = mediaTypes
            if let max = model.params.maxVideoTime {
                picker.videoMaximumDuration = TimeInterval(max)
            }
            showDetailViewController(picker, sender: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                let hud = ADProgressHUD()
                hud.show()
                ADPhotoManager.saveImageToAlbum(image: image) { (suc, _) in
                    if suc {
                        self.dataSource.reloadData()
                    } else {
                        
                    }
                    hud.hide()
                }
            }
            if let url = info[.mediaURL] as? URL {
                let hud = ADProgressHUD()
                hud.show()
                ADPhotoManager.saveVideoToAlbum(url: url) { (suc, _) in
                    if suc {
                        self.dataSource.reloadData()
                    } else {
                        
                    }
                    hud.hide()
                }
            }
        }
    }
    
}

extension ADThumbnailViewController: ADAssetBrowserTransitionContextTo {
    func transitionRect(identifier: String, convertTo: UIView) -> CGRect? {
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            if !model.albumOpts.contains(.ascending) {
                guard indexPath.row >= dataSource.appendCellCount else {
                    continue
                }
            }
            let modify = model.albumOpts.contains(.ascending) ? indexPath : IndexPath(row: indexPath.row-dataSource.appendCellCount, section: indexPath.section)
            if dataSource.list[modify.row].asset.localIdentifier == identifier {
                if let cell = collectionView.cellForItem(at: indexPath) {
                    return collectionView.convert(cell.frame, to: convertTo)
                }
            }
        }
        return nil
    }
}
