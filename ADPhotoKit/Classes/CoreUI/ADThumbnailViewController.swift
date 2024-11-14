//
//  ADThumbnailViewController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import UIKit
import PhotosUI

/// Controller to display assets in album.
public class ADThumbnailViewController: UIViewController {
    
    let config: ADPhotoKitConfig
    var album: ADAlbumModel
    let style: ADPickerStyle
    let selects: [ADSelectAssetModel]
    
    /// View to display asset.
    public var collectionView: UICollectionView!
    /// The data source of album assets.
    public var dataSource: ADAssetListDataSource!
    /// Return back to `albumListController` when ADPickerStyle is `normal`
    public var selectAlbumBlock: (([ADSelectAssetModel]) -> Void)?
    
    var toolBarView: ADThumbnailToolBarConfigurable!
    
    init(config: ADPhotoKitConfig, album: ADAlbumModel, style: ADPickerStyle = .normal, selects: [ADSelectAssetModel] = []) {
        self.config = config
        self.album = album
        self.style = style
        self.selects = selects
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cleanTimer()
    }
    
    /// 滑动选择
    private var panGesture: UIPanGestureRecognizer?
    private var selectionBegin: Bool = false
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        ADPhotoKitConfiguration.default.customThumbnailControllerBlock?(self)
        
        if config.assetOpts.contains(.slideSelect) {
            if (config.params.maxCount ?? UInt.max) > 1 {
                panGesture = UIPanGestureRecognizer(target: self, action: #selector(slideSelectAction(_:)))
                view.addGestureRecognizer(panGesture!)
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolBarView.isOriginal = config.isOriginal
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        config.isOriginal = toolBarView.isOriginal
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return ADPhotoKitConfiguration.default.statusBarStyle ?? .lightContent
    }
    
    func reloadAssets() {
        if dataSource.list.isEmpty {
            let hud = ADProgress.progressHUD()
            hud.show(timeout: 0)
            dataSource.reloadData() {
                hud.hide()
            }
        }else{
            dataSource.reloadData()
        }
    }
    
    func reloadAlbum(_ album: ADAlbumModel, initial: Bool) {
        if initial {
            dataSource = ADAssetListDataSource(reloadable: collectionView, album: album, selects: selects, albumOpts: config.albumOpts, assetOpts: config.assetOpts)
        }else{
            dataSource = ADAssetListDataSource(reloadable: collectionView, album: album, selects: selects, albumOpts: config.albumOpts, assetOpts: config.assetOpts)
        }
        dataSource.selectAssetChanged = { [weak self] count in
            #if Module_UI
            if count == 1 {
                if let model = self?.dataSource.selects.randomElement() {
                    self?.config.selectMediaImage = ADAssetModel(asset: model.asset).type.isImage
                }
            }
            if count == 0 {
                self?.config.selectMediaImage = nil
            }
            #endif
            self?.toolBarView.selectCount = count
        }

        reloadAssets()
    }

}

extension ADThumbnailViewController {
    
    func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor(hex: 0x323232)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: ADCollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        collectionView.regisiter(cell: ADThumbnailListCell.self)
        collectionView.regisiter(cell: ADCameraCell.self)
        collectionView.regisiter(cell: ADAddPhotoCell.self)
        
        reloadAlbum(album, initial: true)
        
        ADPhotoKitConfiguration.default.customThumbnailCellRegistor?(collectionView)
        
        toolBarView = ADPhotoUIConfigurable.thumbnailToolBar(dataSource: dataSource, config: config)
        toolBarView.selectCount = selects.count
        view.addSubview(toolBarView)
        toolBarView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(toolBarView.height)
        }
        toolBarView.browserActionBlock = { [weak self] in
            guard let strong = self else { return }
            let browser = ADAssetModelBrowserController(config: strong.config, dataSource: strong.dataSource)
            strong.navigationController?.pushViewController(browser, animated: true)
        }
        toolBarView.doneActionBlock = { [weak self] in
            self?.doneBtnAction()
        }
        
        let navBarView = ADPhotoUIConfigurable.thumbnailNavBar(style: style, config: config)
        navBarView.title = album.title
        navBarView.leftActionBlock = { [weak self] in
            if let _ = self?.navigationController?.popViewController(animated: true) {
                if let strong = self {
                    self?.selectAlbumBlock?(strong.dataSource.selects)
                }
            }else{
                self?.config.canceled?()
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        navBarView.rightActionBlock = { [weak self] btn in
            self?.config.canceled?()
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
        view.addSubview(navBarView)
        navBarView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navBarView.height)
        }
        navBarView.reloadAlbumBlock = { [weak self] model in
            self?.reloadAlbum(model, initial: false)
        }
        
        collectionView.contentInset = UIEdgeInsets(top: navBarView.height, left: 0, bottom: toolBarView.height, right: 0)
    }
    
    func doneBtnAction() {
        if config.browserOpts.contains(.fetchResult) {
            let opt = ADAssetOperation.OptConfig(isOriginal: toolBarView.isOriginal, selectAsGif: config.assetOpts.contains(.selectAsGif), saveEditVideo: config.browserOpts.contains(.saveVideoAfterEdit))
            dataSource.fetchSelectResults(config: opt, inQueue: config.fetchImageQueue) { [weak self] selected in
                self?.config.pickerSelect?(selected, self!.toolBarView.isOriginal)
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }else{
            let selected = dataSource.selects.map { ADPhotoKitUI.Asset($0.asset,$0.result(image: nil),nil) }
            config.pickerSelect?(selected, toolBarView.isOriginal)
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func canSelectWithIndex(_ index: Int) -> Bool {
        let selected = dataSource.selects.count
        let max = config.params.maxCount ?? UInt.max
        let item = dataSource.list[index]
        let itemIsImage = item.type.isImage

        func canSelect() -> Bool? {
            let videoCount = dataSource.selects.filter { $0.asset.mediaType != .image }.count
            let maxVideoCount = config.params.maxVideoCount ?? UInt.max
            let maxImageCount = config.params.maxImageCount ?? UInt.max
            if videoCount >= maxVideoCount, !itemIsImage {
                return false
            }else if (dataSource.selects.count - videoCount) >= maxImageCount, itemIsImage {
                return false
            }
            return nil
        }
        
        if selected < max {
            if config.assetOpts.contains(.mixSelect) {
                if let value = canSelect() {
                    return value
                }
            }else{
                if let selectMediaImage = config.selectMediaImage, item.browseAsset.isImage != selectMediaImage {
                    return false
                }else{
                    if let value = canSelect() {
                        return value
                    }
                }
            }
            if !itemIsImage {
                switch item.type {
                case let .video(duration, _):
                    if let maxTime = config.params.maxVideoTime {
                        if duration > maxTime {
                            return false
                        }
                    }
                    if let minTime = config.params.minVideoTime {
                        if duration < minTime {
                            return false
                        }
                    }
                default:
                    break
                }
            }
        }else{
            return false
        }
        return true
    }
    
    func directEdit(index: Int) -> Bool {
        if config.assetOpts.contains(.editAfterSelectThumbnail) && config.params.maxCount == 1 {
            let model = dataSource.list[index]
            if config.browserOpts.contains(.allowEditImage) && model.type.isImage {
                #if Module_ImageEdit
                editImage(index: index)
                return true
                #endif
            }
            if config.browserOpts.contains(.allowEditVideo) && !model.type.isImage {
                #if Module_VideoEdit
                editVideo(index: index)
                return true
                #endif
            }
        }
        return false
    }
    
    #if Module_ImageEdit
    func editImage(index: Int) {
        let model = dataSource.list[index]
        if let img = model.imageEditInfo?.originImg {
            let vc = ADImageEditConfigure.imageEditVC(image: img, editInfo: model.imageEditInfo)
            vc.imageDidEdit = { [weak self] editInfo in
                self?.didImageEditInfoUpdate(editInfo, at: index)
            }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false, completion: nil)
        }else{
            var requestId: PHImageRequestID?
            let hud = ADProgress.progressHUD()
            hud.timeoutBlock = {
                ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.timeout.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                if let requestId = requestId {
                    PHImageManager.default().cancelImageRequest(requestId)
                }
            }
            hud.show(timeout: ADPhotoKitConfiguration.default.fetchTimeout)
            let maxSize = CGSize(width: screenHeight*UIScreen.main.scale, height: screenHeight*UIScreen.main.scale)
            requestId = ADPhotoManager.fetchImage(for: model.asset, size: maxSize, synchronous: true) { [weak self] img, _, _ in
                if let img = img {
                    let vc = ADImageEditConfigure.imageEditVC(image: img, editInfo: model.imageEditInfo)
                    vc.imageDidEdit = { [weak self] editInfo in
                        self?.didImageEditInfoUpdate(editInfo, at: index)
                    }
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: false, completion: nil)
                }else{
                    print("fetch image error")
                }
                hud.hide()
            }
        }
    }
    
    func didImageEditInfoUpdate(_ info: ADImageEditInfo, at: Int) {
        dataSource.reloadImageEditInfo(info, at: at)
        if config.browserOpts.contains(.saveImageAfterEdit), let img = info.editImg {
            ADPhotoManager.saveImageToAlbum(image: img, completion: nil)
        }
        if canSelectWithIndex(at) {
            dataSource.selectAssetAt(index: at)
            collectionView.reloadData()
            doneBtnAction()
        }
    }
    #endif

    #if Module_VideoEdit
    func editVideo(index: Int) {
        let model = dataSource.list[index]
        if let asset = model.videoEditInfo?.originAsset {
            let vc = ADVideoEditConfigure.videoEditVC(config: config, asset: asset, editInfo: nil)
            vc.videoDidEdit = { [weak self] editInfo in
                self?.didVideoEditInfoUpdate(editInfo, at: index)
            }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false, completion: nil)
        }else{
            var requestId: PHImageRequestID?
            let hud = ADProgress.progressHUD()
            hud.timeoutBlock = {
                ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.timeout.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                if let requestId = requestId {
                    PHImageManager.default().cancelImageRequest(requestId)
                }
            }
            hud.show(timeout: ADPhotoKitConfiguration.default.fetchTimeout)
            requestId = ADPhotoManager.fetchAVAsset(for: model.asset, completion: { [weak self] asset, _, _ in
                hud.hide()
                guard let strong = self else { return }
                if let asset = asset {
                    let vc = ADVideoEditConfigure.videoEditVC(config: strong.config, asset: asset, editInfo: nil)
                    vc.videoDidEdit = { [weak self] editInfo in
                        self?.didVideoEditInfoUpdate(editInfo, at: index)
                    }
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: false, completion: nil)
                }else{
                    print("fetch video error")
                }
            })
        }
    }
    
    func didVideoEditInfoUpdate(_ info: ADVideoEditInfo, at: Int) {
        dataSource.reloadVideoEditInfo(info, at: at)
        if config.browserOpts.contains(.saveVideoAfterEdit), let url = info.editUrl {
            ADPhotoManager.saveVideoToAlbum(url: url, completion: nil)
        }
        if canSelectWithIndex(at) {
            dataSource.selectAssetAt(index: at)
            collectionView.reloadData()
            doneBtnAction()
        }
    }
    #endif
    
}

extension ADThumbnailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ADPhotoKitConfiguration.default.thumbnailLayout.itemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ADPhotoKitConfiguration.default.thumbnailLayout.lineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ADAssetModel.thumbnailSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.list.count+dataSource.appendCellCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if dataSource.enableCameraCell {
            if indexPath.row == dataSource.cameraCellIndex {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADCameraCell.reuseIdentifier, for: indexPath) as! ADCameraCell
                if config.assetOpts.contains(.captureOnTakeAsset) {
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
        
        let cell = ADPhotoUIConfigurable.thumbnailCell(collectionView: collectionView, indexPath: indexPath)
        
        let modify = dataSource.modifyIndexPath(indexPath)
        let model = dataSource.list[modify.row]
        cell.indexPath = indexPath
        cell.configure(with: model, config: config)
        cell.selectAction = { [weak self] cell, sel in
            guard let strong = self else {
                return
            }
            
            let index = strong.config.albumOpts.contains(.ascending) ? cell.indexPath.row : indexPath.row-strong.dataSource.appendCellCount
            
            if sel { //取消选择
                if !strong.directEdit(index: index) {
                    self?.dataSource.selectAssetAt(index: index)
                }
            }else{
                self?.dataSource.deselectAssetAt(index: index)
            }
            
            /// 单独刷新这个cell 防止选择动画停止
            cell.configure(with: strong.dataSource.list[index], config: strong.config)
            
            var indexs = strong.collectionView.indexPathsForVisibleItems
            indexs.removeAll {$0 == cell.indexPath}
            self?.collectionView.reloadItems(at: indexs)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let c = cell as? ADThumbnailCellConfigurable else {
            return
        }
        let index = dataSource.modifyIndexPath(indexPath).row
        let item = dataSource.list[index]
        if !c.selectStatus.isSelect {
            c.selectStatus = .select(index: nil)
            item.selectStatus = .select(index: nil)
            let selected = dataSource.selects.count
            let max = config.params.maxCount ?? UInt.max
            if selected < max {
                let itemIsImage = item.type.isImage
                if config.assetOpts.contains(.mixSelect) {
                    let videoCount = dataSource.selects.filter { $0.asset.mediaType == .video }.count
                    let maxVideoCount = config.params.maxVideoCount ?? UInt.max
                    let maxImageCount = config.params.maxImageCount ?? UInt.max
                    if videoCount >= maxVideoCount, !itemIsImage {
                        c.selectStatus = .deselect
                        item.selectStatus = .deselect
                    }else if (dataSource.selects.count - videoCount) >= maxImageCount, itemIsImage {
                        c.selectStatus = .deselect
                        item.selectStatus = .deselect
                    }
                }else{
                    if let selectMediaImage = config.selectMediaImage, item.type.isImage != selectMediaImage {
                        c.selectStatus = .deselect
                        item.selectStatus = .deselect
                    }else{
                        let videoCount = dataSource.selects.filter { $0.asset.mediaType == .video }.count
                        let maxVideoCount = config.params.maxVideoCount ?? UInt.max
                        let maxImageCount = config.params.maxImageCount ?? UInt.max
                        if videoCount >= maxVideoCount, !itemIsImage {
                            c.selectStatus = .deselect
                            item.selectStatus = .deselect
                        }else if (dataSource.selects.count - videoCount) >= maxImageCount, itemIsImage {
                            c.selectStatus = .deselect
                            item.selectStatus = .deselect
                        }
                    }
                }
                if !itemIsImage {
                    #if !Module_VideoEdit
                    if let max = config.params.maxVideoTime {
                        if item.type.duration > max {
                            c.selectStatus = .deselect
                            item.selectStatus = .deselect
                        }
                    }
                    if let min = config.params.minVideoTime {
                        if item.type.duration < min {
                            c.selectStatus = .deselect
                            item.selectStatus = .deselect
                        }
                    }
                    if let max = config.params.maxVideoSize, let size = item.assetSize {
                        if size > max {
                            c.selectStatus = .deselect
                            item.selectStatus = .deselect
                        }
                    }
                    if let min = config.params.minVideoSize, let size = item.assetSize {
                        if size < min {
                            c.selectStatus = .deselect
                            item.selectStatus = .deselect
                        }
                    }
                    #endif
                }
            }else{
                c.selectStatus = .deselect
                item.selectStatus = .deselect
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if cell is ADCameraCell {
            presentCameraController()
        }else if cell is ADAddPhotoCell {
            if #available(iOS 14, *) {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            }
        }else if let c = cell as? ADThumbnailCellConfigurable {
            let modify = dataSource.modifyIndexPath(indexPath)
            if directEdit(index: modify.row) {
                return
            }
            if !config.assetOpts.contains(.allowBrowser) {
                c.cellSelectAction()
            }else if c.selectStatus.isEnable {
                let browser = ADAssetModelBrowserController(config: config, dataSource: dataSource, index: modify.row)
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
        let cell = collectionView.cellForItem(at: indexPath) as? ADThumbnailCellConfigurable
        if pan.state == .began {
            if cell != nil {
                let index = dataSource.modifyIndexPath(indexPath).row
                if !directEdit(index: index) {
                    selectionBegin = true
                    slideRangeDidChange(indexPath: indexPath, cell: cell!)
                }
            }
        }else if pan.state == .changed {
            if selectionBegin {
                autoScrollWhenSlideSelect(pan)
                if cell != nil {
                    slideRangeDidChange(indexPath: indexPath, cell: cell!)
                }
            }
        }else{
            cleanTimer()
            selectionInfo = nil
            selectionRange = nil
            selectionBegin = false
        }
    }
    
    func slideRangeDidChange(indexPath: IndexPath, cell: ADThumbnailCellConfigurable) {
        let index = dataSource.modifyIndexPath(indexPath).row
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
                                if canSelectWithIndex(i) {
                                    dataSource.selectAssetAt(index: i)
                                }else{
                                    break
                                }
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
                cell.configure(with: model, config: config)
            }
        }
    }
    
    func autoScrollWhenSlideSelect(_ pan: UIPanGestureRecognizer) {
        guard config.assetOpts.contains(.autoScroll) else {
            return
        }
        
        if let max = config.params.maxCount {
            guard dataSource.selects.count < max else {
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
        if !config.assetOpts.contains(.allowTakePhotoAsset) && !config.assetOpts.contains(.allowTakeVideoAsset) {
            return
        }
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.cameraUnavailable.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
            return
        }
        if config.assetOpts.contains(.systemCapture) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.videoQuality = .typeHigh
            picker.sourceType = .camera
            picker.cameraDevice = ADPhotoKitConfiguration.default.captureConfig.cameraPosition.cameraDevice
            if ADPhotoKitConfiguration.default.captureConfig.flashSwitch {
                picker.cameraFlashMode = .auto
            }else{
                picker.cameraFlashMode = .off
            }
            var mediaTypes = [String]()
            if config.assetOpts.contains(.allowTakePhotoAsset) {
                mediaTypes.append("public.image")
            }
            if config.assetOpts.contains(.allowTakeVideoAsset) {
                mediaTypes.append("public.movie")
            }
            picker.mediaTypes = mediaTypes
            picker.videoMaximumDuration = TimeInterval(config.params.maxRecordTime)
            showDetailViewController(picker, sender: nil)
        }else{
            let capture = ADPhotoUIConfigurable.assetCaptureController(config: config)
            capture.modalPresentationStyle = .fullScreen
            capture.assetCapture = { [weak self] image, url in
                self?.save(image: image, url: url)
            }
            showDetailViewController(capture, sender: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            let image = info[.originalImage] as? UIImage
            let url = info[.mediaURL] as? URL
            self.save(image: image, url: url)
        }
    }
    
    func save(image: UIImage?, url: URL?, timeCheck: Bool = false) {
        if let image = image {
            let hud = ADProgress.progressHUD()
            hud.show(timeout: 0)
            ADPhotoManager.saveImageToAlbum(image: image) { (asset, _) in
                if let asset = asset {
                    let index = self.dataSource.appendCaptureAsset(asset)
                    self.dataSource.selectAssetAt(index: index)
                } else {
                    ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.saveImageError.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                }
                hud.hide()
            }
        }
        if let url = url {
            if timeCheck {
                let asset = AVAsset(url: url)
                if Int(asset.duration.seconds) < config.params.minRecordTime {
                    ADAlert.alert().alert(on: self, title: nil, message: String(format: ADLocale.LocaleKey.minRecordTimeTips.localeTextValue, config.params.minRecordTime), actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                    return
                }
            }
            let hud = ADProgress.progressHUD()
            hud.show(timeout: 0)
            ADPhotoManager.saveVideoToAlbum(url: url) { (asset, _) in
                if let asset = asset {
                    let index = self.dataSource.appendCaptureAsset(asset)
                    self.dataSource.selectAssetAt(index: index)
                } else {
                    ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.saveVideoError.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                }
                hud.hide()
            }
        }
    }
    
}

extension ADThumbnailViewController: ADAssetBrowserTransitionContextTo {
    func transitionRect(identifier: String, convertTo: UIView) -> CGRect? {
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            if !config.albumOpts.contains(.ascending) {
                guard indexPath.row >= dataSource.appendCellCount else {
                    continue
                }
            }
            let modify = dataSource.modifyIndexPath(indexPath)
            if dataSource.list[modify.row].asset.localIdentifier == identifier {
                if let cell = collectionView.cellForItem(at: indexPath) {
                    return collectionView.convert(cell.frame, to: convertTo)
                }
            }
        }
        return nil
    }
}
