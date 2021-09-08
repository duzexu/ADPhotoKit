//
//  ADAssetListDataSource.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import UIKit
import Photos

/// The data source of asset model controller. It get assets you request and reload the associate reloadable view when assets changed.
public class ADAssetListDataSource: NSObject {
    
    /// The associate reloadable view conform to `ADDataSourceReloadable`.
    public weak var reloadable: ADDataSourceReloadable?
    
    /// Options to set the album type and order.
    public let albumOpts: ADAlbumSelectOptions
    
    /// Options to control the asset select condition and ui.
    public let assetOpts: ADAssetSelectOptions
    
    /// The album select to get assets.
    public let album: ADAlbumModel
    
    /// Assets array request from album.
    public var list: [ADAssetModel] = []
    
    /// Assets you select.
    public var selects: [ADSelectAssetModel] = []
    
    /// The cell count except assets.
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
    
    /// Indicate whether show camera cell in CameraRoll. if `true`, camera roll page will show camera cell.
    public var enableCameraCell: Bool {
        return album.isCameraRoll && (assetOpts.contains(.allowTakePhotoAsset) || assetOpts.contains(.allowTakeVideoAsset))
    }
    
    /// The index for camera cell.
    public var cameraCellIndex: Int {
        if albumOpts.contains(.ascending) {
            if appendCellCount >= 2 {
                return list.count + appendCellCount - 2
            }else{
                return list.count + appendCellCount - 1
            }
        }else{
            return 0
        }
    }
    
    /// Indicate whether show add asset in CameraRoll when user choose limited Photo mode. if `true`, camera roll page will show add asset cell.
    @available(iOS 14, *)
    public var enableAddAssetCell: Bool {
        return album.isCameraRoll && PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited && assetOpts.contains(.allowAddAsset)
    }
    
    /// The index for add seest cell.
    public var addAssetCellIndex: Int {
        if albumOpts.contains(.ascending) {
            return list.count + appendCellCount - 1
        }else{
            return 1
        }
    }
    
    /// Called when select asset or deselect asset.
    public var selectAssetChanged: ((Int)->Void)?
    
    /// Create data source with associate reloadable view, album model, select assets and options.
    /// - Parameters:
    ///   - reloadable: Associate reloadable view.
    ///   - album: Album to get assets.
    ///   - selects: Selected assets.
    ///   - albumOpts: Options to limit album type and order. It is `ADAlbumSelectOptions.default` by default.
    ///   - assetOpts: Options to control the asset select condition and ui. It is `ADAssetSelectOptions.default` by default.
    public init(reloadable: ADDataSourceReloadable,
                album: ADAlbumModel,
                selects: [PHAsset],
                albumOpts: ADAlbumSelectOptions,
                assetOpts: ADAssetSelectOptions) {
        self.reloadable = reloadable
        self.album = album
        self.albumOpts = albumOpts
        self.assetOpts = assetOpts
        self.selects = selects.map { ADSelectAssetModel(asset: $0) }
        super.init()
        if #available(iOS 14.0, *), PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    /// Create data source with associate reloadable view, album model, select assets and options.
    /// - Parameters:
    ///   - reloadable: Associate reloadable view.
    ///   - album: Album to get assets.
    ///   - selects: Selected asset models.
    ///   - albumOpts: Options to limit album type and order. It is `ADAlbumSelectOptions.default` by default.
    ///   - assetOpts: Options to control the asset select condition and ui. It is `ADAssetSelectOptions.default` by default.
    public init(reloadable: ADDataSourceReloadable,
                album: ADAlbumModel,
                selects: [ADSelectAssetModel],
                albumOpts: ADAlbumSelectOptions,
                assetOpts: ADAssetSelectOptions) {
        self.reloadable = reloadable
        self.album = album
        self.albumOpts = albumOpts
        self.assetOpts = assetOpts
        self.selects = selects
        super.init()
        if #available(iOS 14.0, *), PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    /// Reload the associate view with fetch assets.
    /// - Parameter completion: Called when the reload finished.
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
    
    /// Return modify indexPath when camera cell or add asset cell is enable.
    /// - Parameter indexPath: Orginal indexPath.
    /// - Returns: Modify indexPath.
    public func modifyIndexPath(_ indexPath: IndexPath) -> IndexPath {
        return albumOpts.contains(.ascending) ? indexPath : IndexPath(row: indexPath.row-appendCellCount, section: indexPath.section)
    }
    
    /// Select the asset.
    /// - Parameter index: Index whitch asset is select.
    public func selectAssetAt(index: Int) {
        if index < list.count {
            let item = list[index]
            if selects.firstIndex(where: { (model) -> Bool in
                return model.identifier == item.identifier
            }) == nil {
                let selected = ADSelectAssetModel(asset: item.asset)
                selected.index = index
                #if Module_ImageEdit
                selected.imageEditInfo = item.imageEditInfo
                #endif
                selects.append(selected)
                item.selectStatus = .select(index: selects.count)
            }
            #if Module_UI
            if selects.count == 1 {
                if let model = selects.randomElement() {
                    ADPhotoKitUI.config.selectMediaImage = ADAssetModel(asset: model.asset).type.isImage
                }
            }
            #endif
            selectAssetChanged?(selects.count)
        }
    }
    
    /// Deselect the asset.
    /// - Parameter index: Index whitch asset is deselect.
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
            #if Module_UI
            if selects.count == 0 {
                ADPhotoKitUI.config.selectMediaImage = nil
            }
            #endif
            selectAssetChanged?(selects.count)
        }
    }
    
    /// Reload asset `selectStatus` with select indexs. Use this method when return from browser controller.
    /// - Parameters:
    ///   - indexs: Select asset indexs.
    ///   - current: Current browser index.
    public func reloadSelectAssetIndexs(_ indexs: [Int], current: Int) {
        selects.removeAll()
        for (idx,item) in list.enumerated() {
            if let index = indexs.firstIndex(of: idx) {
                let model = ADSelectAssetModel(asset: item.asset)
                item.selectStatus = .select(index: index+1)
                model.index = idx
                #if Module_ImageEdit
                model.imageEditInfo = item.imageEditInfo
                #endif
                selects.append(model)
            }else{
                item.selectStatus = .select(index: nil)
            }
        }
        #if Module_UI
        if selects.count == 1 {
            if let model = selects.randomElement() {
                ADPhotoKitUI.config.selectMediaImage = ADAssetModel(asset: model.asset).type.isImage
            }
        }
        if selects.count == 0 {
            ADPhotoKitUI.config.selectMediaImage = nil
        }
        #endif
        selectAssetChanged?(selects.count)
        if let view = reloadable as? UICollectionView {
            view.reloadItems(at: view.indexPathsForVisibleItems)
        }
    }
    
    #if Module_ImageEdit
    /// Reload asset `imageEditInfo` when edit ended.
    /// - Parameters:
    ///   - info: Info contains image edit data.
    ///   - index: Index whitch asset is update.
    func reloadImageEditInfo(_ info: ADImageEditInfo, at index: Int) {
        if index < list.count {
            let item = list[index]
            item.imageEditInfo = info
        }
    }
    #endif
    
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
