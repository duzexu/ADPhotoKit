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
    public var selectIndexs: [Int] = []

    @objc
    public dynamic var index: Int = 0
    
    public var current: ADAssetBrowsable {
        return list[index]
    }
    
    @objc
    public dynamic var isSelected: Bool = false
    
    public var selectAssetChanged: ((Int)->Void)?
        
    public init(options: ADAssetBrowserOptions,
                list: [ADAssetBrowsable],
                index: Int = 0,
                selects: [Int] = []) {
        self.options = options
        self.list = list
        self.index = index
        self.selectIndexs = selects
        self.selects = selectIndexs.map { list[$0] }
        self.isSelected = selects.contains(index)
        selectAssetChanged?(selects.count)
        super.init()
    }
    
    func didIndexChange(_ idx: Int) {
        index = idx
        isSelected = selectIndexs.contains(index)
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
    
    func appendSelect(_ idx: Int) {
        selectIndexs.append(idx)
        selects.append(list[idx])
        isSelected = selectIndexs.contains(index)
        let ip = IndexPath(row: selects.count-1, section: 0)
        selectView?.insertItems(at: [ip])
        selectView?.scrollToItem(at: ip, at: .centeredHorizontally, animated: true)
        selectAssetChanged?(selects.count)
    }
    
    func deleteSelect(_ idx: Int) {
        if let i = selectIndexs.firstIndex(where: { $0 == idx }) {
            selectIndexs.remove(at: i)
            selects.remove(at: i)
            isSelected = selectIndexs.contains(index)
            selectView?.deleteItems(at: [IndexPath(row: i, section: 0)])
            selectAssetChanged?(selects.count)
        }
    }
    
    func moveSelect(from fIdx: Int, to tIdx: Int) {
        selectView?.performBatchUpdates({
            let select = self.selectIndexs[fIdx]
            self.selectIndexs.remove(at: fIdx)
            self.selectIndexs.insert(select, at: tIdx)
            let selectModel = self.selects[fIdx]
            self.selects.remove(at: fIdx)
            self.selects.insert(selectModel, at: tIdx)
            
            self.selectView?.deleteItems(at: [IndexPath(row: fIdx, section: 0)])
            self.selectView?.insertItems(at: [IndexPath(row: tIdx, section: 0)])
        }, completion: nil)
    }
}

private extension ADAssetBrowserDataSource {
    
}
