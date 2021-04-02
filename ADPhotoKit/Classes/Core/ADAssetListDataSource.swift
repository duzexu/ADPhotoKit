//
//  ADAssetListDataSource.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import Photos

public class ADAssetListDataSource: NSObject {
    
    public weak var reloadable: ADDataSourceReloadable?
    public let albumOpts: ADAlbumSelectOptions
    public let assetOpts: ADAssetSelectOptions
    public let album: ADAlbumModel
    
    public var list: [ADAssetModel] = []
    public var selects: [ADSelectAssetModel] = []
    
    public var appendCellCount: Int {
        var count: Int = 0
        if enableCameraCell {
            count += 1
        }
        if #available(iOS 14, *) {
            if enableAddAssetCell {
                count += 1
            }
        }
        return count
    }
    
    /// 显示拍照按钮
    public var enableCameraCell: Bool {
        return album.isCameraRoll && (assetOpts.contains(.allowTakePhotoAsset) || assetOpts.contains(.allowTakeVideoAsset))
    }
    
    public var cameraCellIndex: Int {
        if albumOpts.contains(.ascending) {
            return list.count + appendCellCount - 2
        }else{
            return 0
        }
    }
    
    /// 显示添加按钮
    @available(iOS 14, *)
    public var enableAddAssetCell: Bool {
        return album.isCameraRoll && PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited && assetOpts.contains(.allowAddAsset)
    }
    
    public var addAssetCellIndex: Int {
        if albumOpts.contains(.ascending) {
            return list.count + appendCellCount - 1
        }else{
            return 1
        }
    }
    
    public var selectAssetChanged: ((Int)->Void)?
    
    public init(reloadable: ADDataSourceReloadable,
                album: ADAlbumModel,
                select: [PHAsset],
                albumOpts: ADAlbumSelectOptions,
                assetOpts: ADAssetSelectOptions) {
        self.reloadable = reloadable
        self.album = album
        self.albumOpts = albumOpts
        self.assetOpts = assetOpts
        self.selects = select.map { ADSelectAssetModel(asset: $0) }
        super.init()
        if #available(iOS 14.0, *), PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    public func reloadData(completion: (() -> Void)? = nil) {
        DispatchQueue.global().async { [weak self] in
            guard let strong = self else { return }
            let models = ADPhotoManager.fetchAssets(in: strong.album.result, options: strong.albumOpts)
            strong.list.removeAll()
            strong.list.append(contentsOf: models)
            for (idx,item) in strong.selects.enumerated() {
                if let index = strong.list.firstIndex(where: { (model) -> Bool in
                    return model.identifier == item.identifier
                }) {
                    item.index = index
                    strong.list[index].selectStatus = .select(index: idx+1)
                }
            }
            DispatchQueue.main.async {
                self?.reloadable?.reloadData()
                self?.scrollToBottom()
                completion?()
            }
        }
    }
    
    public func selectAssetAt(index: Int) {
        if index < list.count {
            let item = list[index]
            if selects.firstIndex(where: { (model) -> Bool in
                return model.identifier == item.identifier
            }) == nil {
                let selected = ADSelectAssetModel(asset: item.asset)
                selected.index = index
                selects.append(selected)
                item.selectStatus = .select(index: selects.count)
            }
            selectAssetChanged?(selects.count)
        }
    }
    
    public func deselectAssetAt(index: Int) {
        if index < list.count {
            let item = list[index]
            if selects.firstIndex(where: { (model) -> Bool in
                return model.identifier == item.identifier
            }) != nil {
                item.selectStatus = .select(index: nil)
                selects.removeAll() { $0.identifier == item.identifier }
                for (idx,model) in selects.enumerated() {
                    if let index = model.index {
                        let m = list[index]
                        m.selectStatus = .select(index: idx+1)
                    }
                }
            }
            selectAssetChanged?(selects.count)
        }
    }
    
    private func scrollToBottom() {
        guard albumOpts.contains(.ascending), list.count > 0 else {
            return
        }
        if let view = reloadable as? UICollectionView {
            view.scrollToItem(at: IndexPath(row: list.count-1, section: 0), at: .centeredVertically, animated: false)
        }
    }
    
}

extension ADAssetListDataSource: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: album.result) else {
            return
        }
        DispatchQueue.main.async {
            self.album.result = changes.fetchResultAfterChanges
            for sm in self.selects {
                let isDelete = changeInstance.changeDetails(for: sm.asset)?.objectWasDeleted ?? false
                if isDelete {
                    self.selects.removeAll { $0 == sm }
                }
            }
            self.selectAssetChanged?(self.selects.count)
            self.reloadData()
        }
    }
    
}
