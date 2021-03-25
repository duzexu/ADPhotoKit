//
//  ADThumbnailViewController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import UIKit

struct ADThumbnailParams {
    var minImageCount: Int?
    var maxImageCount: Int?
    
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
    
    private var panGesture: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if model.assetOpts.contains(.slideSelect) {
            if (model.params.maxImageCount ?? Int.max) > 1 {
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
    
    static var beginIndexPath: IndexPath?
    static var lastIndexPath: IndexPath?
    static var slideShouldSelect: Bool?
    static var selectIndexs: [Int]?
    
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
            ADThumbnailViewController.beginIndexPath = nil
            ADThumbnailViewController.lastIndexPath = nil
            ADThumbnailViewController.slideShouldSelect = nil
        }
    }
    
    func slideRangeDidChange(indexPath: IndexPath, cell: ADThumbnailListCell) {
        let index = indexPath.row
        let model = dataSource.list[index]
        //已经有第一个
        if let select = ADThumbnailViewController.slideShouldSelect {
            let last = ADThumbnailViewController.lastIndexPath!.row
            let begin = ADThumbnailViewController.beginIndexPath!.row
            if last != index {
                if begin < indexPath.row  { //向下选择
                    if last < index {
                        for i in last...index {
                            if select { //判断是否能添加
                                if !model.selectStatus.isSelect {
                                    dataSource.selectAssetAt(index: i)
                                }
                            }else{
                                if model.selectStatus.isSelect {
                                    dataSource.deselectAssetAt(index: i)
                                }
                            }
                        }
                    }else{
                        for i in index...last {
                            if select { //判断是否能添加
                                if model.selectStatus.isSelect {
                                    dataSource.deselectAssetAt(index: i)
                                }
                            }else{ //之前选择的有
                                if ADThumbnailViewController.selectIndexs!.contains(i) {
                                    dataSource.selectAssetAt(index: i)
                                }
                            }
                        }
                    }
                }else if begin > indexPath.row { //向上选择
                    for i in (last...indexPath.row).reversed() {
                        if select { //判断是否能添加
                            if !model.selectStatus.isSelect {
                                dataSource.selectAssetAt(index: i)
                            }
                        }else{
                            if model.selectStatus.isSelect {
                                dataSource.deselectAssetAt(index: i)
                            }
                        }
                    }
                }
                ADThumbnailViewController.lastIndexPath = indexPath
            }
        }else{
            ADThumbnailViewController.selectIndexs = dataSource.selects.compactMap { $0.index }
            ADThumbnailViewController.slideShouldSelect = !model.selectStatus.isSelect
            ADThumbnailViewController.beginIndexPath = indexPath
            ADThumbnailViewController.lastIndexPath = indexPath
            if model.selectStatus.isSelect { //取消选择
                dataSource.deselectAssetAt(index: index)
            }else{
                dataSource.selectAssetAt(index: index)
            }
        }
    }
    
}
