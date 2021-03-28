//
//  ADThumbnailViewController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import UIKit

struct ADThumbnailParams {
    var maxCount: Int?
    
    var minVideoCount: Int?
    var maxVideoCount: Int?
    
    var minVideoTime: Int?
    var maxVideoTime: Int?
}

class ADThumbnailViewController: UIViewController {
    
    let model: ADPhotoKitInternal
    let albumList: ADAlbumModel
    
    var collectionView: UICollectionView!
    var dataSource: ADAssetListDataSource!
    
    var toolBarView: ADThumbnailToolBarable!
    
    init(model: ADPhotoKitInternal, albumList: ADAlbumModel) {
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
        
        dataSource = ADAssetListDataSource(reloadable: collectionView, album: albumList, select: model.assets, options: model.albumOpts)
        
        toolBarView = ADThumbnailToolBarView()
        view.addSubview(toolBarView)
        toolBarView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(ADThumbnailToolBarView.height)
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
        return UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columnCount: CGFloat = CGFloat(ADPhotoKitConfiguration.default.thumbnailLayout.columnCount)
        let totalW = collectionView.bounds.width - (columnCount - 1) * ADPhotoKitConfiguration.default.thumbnailLayout.itemSpacing
        let singleW = totalW / columnCount
        return CGSize(width: singleW, height: singleW)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADThumbnailListCell.reuseIdentifier, for: indexPath) as! ADThumbnailListCell
        
        let model = dataSource.list[indexPath.row]
        cell.configure(with: model, indexPath: indexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
        let index = indexPath.row
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
                var indexPaths: [IndexPath] = []
                if let range = shrankRange {
                    for i in range.0...range.1 {
                        let item = dataSource.list[i]
                        if i != info.begin {
                            if info.select && item.selectStatus.isSelect {
                                indexPaths.append(IndexPath(row: i, section: 0))
                                dataSource.deselectAssetAt(index: i)
                            }
                            if !info.select && info.indexs.contains(i) {
                                indexPaths.append(IndexPath(row: i, section: 0))
                                dataSource.selectAssetAt(index: i)
                            }
                        }
                    }
                }
                if let range = expandRange {
                    for i in range.0...range.1 {
                        let item = dataSource.list[i]
                        if i != info.begin {
                            if info.select && !item.selectStatus.isSelect {
                                indexPaths.append(IndexPath(row: i, section: 0))
                                dataSource.selectAssetAt(index: i)
                            }
                            if !info.select && item.selectStatus.isSelect {
                                indexPaths.append(IndexPath(row: i, section: 0))
                                dataSource.deselectAssetAt(index: i)
                            }
                        }
                    }
                }
                selectionRange = current
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: indexPaths)
                }
            }
        }else{
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
        let bottom = view.frame.height - ADThumbnailToolBarView.height - 30
        
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
