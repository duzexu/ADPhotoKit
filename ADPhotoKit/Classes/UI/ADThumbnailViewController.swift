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
    
    init(model: ADPhotoKitInternal, albumList: ADAlbumModel) {
        self.model = model
        self.albumList = albumList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 滑动选择
    private var panGesture: UIPanGestureRecognizer?
    private var selectionInfo: SlideSelectionInfo?
    private var selectionRange: SlideSelectionRange?
    
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
    }
    
}

extension ADThumbnailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columnCount: CGFloat = 4
        let totalW = collectionView.bounds.width - (columnCount - 1) * 2
        let singleW = totalW / columnCount
        return CGSize(width: singleW, height: singleW)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADThumbnailListCell.reuseIdentifier, for: indexPath) as! ADThumbnailListCell
        
        let model = dataSource.list[indexPath.row]
        cell.configure(with: model)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

/// 滑动手势
extension ADThumbnailViewController {
    
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
            if cell != nil {
                slideRangeDidChange(indexPath: indexPath, cell: cell!)
            }
        }else{
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
                            if info.select && !item.selectStatus.isSelect {
                                dataSource.selectAssetAt(index: i)
                            }
                            if !info.select && item.selectStatus.isSelect {
                                dataSource.deselectAssetAt(index: i)
                            }
                        }
                    }
                }
                selectionRange = current
                collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
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
    
}
