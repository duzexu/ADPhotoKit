//
//  ADAssetBrowserDataSource.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/12.
//

import UIKit

class ADAssetBrowserDataSource: NSObject {

    public weak var listView: UICollectionView?
    public weak var selectView: UICollectionView?
    
    public let options: ADAssetBrowserOptions
    
    public let list: [ADAssetBrowsable]
    public var selects: [ADAssetBrowsable] = []
    
    public var index: Int = 0
    public var selectIndexs: [Int] = []
    
    public var current: ADAssetBrowsable {
        return list[index]
    }
    
    public init(options: ADAssetBrowserOptions,
                list: [ADAssetBrowsable],
                index: Int = 0,
                selects: [Int] = []) {
        self.options = options
        self.list = list
        self.index = index
        self.selectIndexs = selects
        self.selects = selectIndexs.map { list[$0] }
        super.init()
    }
    
    func didIndexChange(_ idx: Int) {
        index = idx
        if let index = selects.firstIndex(where: { $0.browseAsset == current.browseAsset }) {
            selectView?.performBatchUpdates { [weak self] in
                self?.selectView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
            } completion: { [weak self] (_) in
                guard let strong = self?.selectView else { return }
                strong.reloadItems(at: strong.indexPathsForVisibleItems)
            }
        }else{
            selectView?.reloadItems(at: selectView!.indexPathsForVisibleItems)
        }
    }
    
    func didSelectIndexChange(_ idx: Int) {
        didIndexChange(selectIndexs[idx])
        listView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
    }
}

private extension ADAssetBrowserDataSource {
    
}
