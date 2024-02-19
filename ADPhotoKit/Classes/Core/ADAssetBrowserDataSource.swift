//
//  ADAssetBrowserDataSource.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/12.
//

import UIKit

/// The data source of browser controller. It reload the associate reloadable view when selet or deselect asset, browser index change, select order change.
public class ADAssetBrowserDataSource: NSObject {
    
    /// Associate browser view.
    public weak var listView: UICollectionView?
    /// Associate select preview view.
    public weak var selectView: UICollectionView?
    
    /// Options to control the asset browser condition and ui.
    public let options: ADAssetBrowserOptions
    
    /// Assets to browser.
    public var list: [ADAssetBrowsable]
    /// Select assets.
    public var selects: [ADAssetBrowsable] = []
    /// Select asset's index.
    public var selectIndexs: [Int?] = []
    
    /// Current browser asset. Will be `nil` if select asset is not in `list`.
    public var current: ADAssetBrowsable? {
        if index < 0 {
            return nil
        }
        if index >= list.count {
            return nil
        }
        return list[index]
    }

    /// Current browser asset index in `list`.
    @objc
    public dynamic var index: Int = 0
        
    /// Current browser asset is select or not.
    @objc
    public dynamic var isSelected: Bool = false
    
    /// Current browser asset index in `selects`.
    @objc
    public dynamic var selectIndex: Int = -1
    
    /// Total select browser asset count.
    @objc
    public dynamic var selectCount: Int = 0
    
    /// Called when selet or deselect asset.
    public var selectAssetChanged: ((Int)->Void)?
    
    /// Called whether selet asset is in `list` or not.
    public var selectAssetExistOrNot: ((Bool) -> Void)?
    
    /// Create data source with browser data, options and select info.
    /// - Parameters:
    ///   - options: Options to control browser controller. It is `ADAssetBrowserOptions.default` by default.
    ///   - list: Asset array to browser.
    ///   - selects: Assets have been selected.
    ///   - index: Default asset index in `list`. If `nil`, it will be set first select asset index in `list` or set 0 when select count is 0.
    public init(options: ADAssetBrowserOptions,
                list: [ADAssetBrowsable],
                selects: [ADAssetBrowsable],
                index: Int?) {
        self.options = options
        self.list = list
        self.selectIndexs = []
        self.selects = selects
        var _index: Int? = index
        for item in selects {
            if let idx = list.firstIndex(where: { (model) -> Bool in
                return model.browseAsset.identifier == item.browseAsset.identifier
            }) {
                if _index == nil {
                    _index = idx
                }
                selectIndexs.append(idx)
            }else{
                selectIndexs.append(nil)
            }
        }
        self.index = _index ?? 0
        self.isSelected = selectIndexs.contains(self.index)
        if isSelected {
            self.selectIndex = selectIndexs.firstIndex(of: self.index)!
        }
        selectCount = selects.count
        selectAssetChanged?(selects.count)
        super.init()
    }
    
    /// Change current browser index.
    /// - Parameter idx: Asset index in `list` to browser.
    public func didIndexChange(_ idx: Int?) {
        if idx != nil {
            index = idx!
            isSelected = selectIndexs.contains(index)
            if let index = selects.firstIndex(where: { $0.browseAsset == current!.browseAsset }) {
                selectIndex = index
                selectView?.performBatchUpdates { [weak self] in
                    self?.selectView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
                } completion: { [weak self] (_) in
                    guard let strong = self?.selectView else { return }
                    strong.reloadItems(at: strong.indexPathsForVisibleItems)
                }
            }else{
                selectIndex = -1
                selectView?.reloadItems(at: selectView!.indexPathsForVisibleItems)
            }
        }else{
            isSelected = false
            selectIndex = -1
            selectView?.reloadItems(at: selectView!.indexPathsForVisibleItems)
        }
    }
    
    /// Change select browser index.
    /// - Parameter idx: Asset index in `selects` to browser.
    public func didSelectIndexChange(_ idx: Int) {
        if idx < selectIndexs.count {
            if let index = selectIndexs[idx] {
                selectAssetExistOrNot?(true)
                didIndexChange(index)
                listView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
            }else{
                selectAssetExistOrNot?(false)
                didIndexChange(nil)
            }
        }else{
            selectAssetExistOrNot?(false)
            didIndexChange(nil)
        }
    }
    
    /// Select the asset.
    /// - Parameter idx: Index whitch asset is select.
    public func appendSelect(_ idx: Int) {
        selectIndexs.append(idx)
        selects.append(list[idx])
        isSelected = selectIndexs.contains(index)
        let ip = IndexPath(row: selects.count-1, section: 0)
        selectIndex = selects.count-1
        selectView?.insertItems(at: [ip])
        selectView?.scrollToItem(at: ip, at: .centeredHorizontally, animated: true)
        selectCount = selects.count
        selectAssetChanged?(selects.count)
    }
    
    /// Deselect the asset.
    /// - Parameter index: Index whitch asset is deselect.
    public func deleteSelect(_ idx: Int) {
        if let i = selectIndexs.firstIndex(where: { $0 == idx }) {
            selectIndex = -1
            selectIndexs.remove(at: i)
            selects.remove(at: i)
            isSelected = selectIndexs.contains(index)
            selectView?.deleteItems(at: [IndexPath(row: i, section: 0)])
            selectCount = selects.count
            selectAssetChanged?(selects.count)
        }
    }
    
    /// Change select assets order.
    /// - Parameters:
    ///   - fIdx: Index move from.
    ///   - tIdx: Index move to.
    ///   - reload: Indicator reload `selectView` or not.
    public func moveSelect(from fIdx: Int, to tIdx: Int, reload: Bool = false) {
        selectIndex = tIdx
        if reload {
            selectView?.performBatchUpdates({
                let select = self.selectIndexs[fIdx]
                self.selectIndexs.remove(at: fIdx)
                self.selectIndexs.insert(select, at: tIdx)
                let selectModel = self.selects[fIdx]
                self.selects.remove(at: fIdx)
                self.selects.insert(selectModel, at: tIdx)
                
                self.selectView?.moveItem(at: IndexPath(row: fIdx, section: 0), to: IndexPath(row: tIdx, section: 0))
            }, completion: { (_) in
                if let collectionView = self.selectView {
                    collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
                }
            })
        }else{
            let select = self.selectIndexs[fIdx]
            self.selectIndexs.remove(at: fIdx)
            self.selectIndexs.insert(select, at: tIdx)
            let selectModel = self.selects[fIdx]
            self.selects.remove(at: fIdx)
            self.selects.insert(selectModel, at: tIdx)
        }
    }
}
