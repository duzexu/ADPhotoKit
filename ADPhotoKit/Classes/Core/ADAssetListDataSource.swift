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
    public let options: ADAlbumSelectOptions
    public let album: ADAlbumModel
    
    public var list: [ADAssetModel] = []
    public var selects: [ADSelectAssetModel] = []
    
    public init(reloadable: ADDataSourceReloadable,
                album: ADAlbumModel,
                select: [PHAsset],
                options: ADAlbumSelectOptions = .default) {
        self.reloadable = reloadable
        self.album = album
        self.options = options
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
            let models = ADPhotoManager.fetchAssets(in: strong.album.result, options: strong.options)
            strong.list.removeAll()
            strong.list.append(contentsOf: models)
            for (idx,item) in strong.selects.enumerated() {
                if let index = strong.list.firstIndex(where: { (model) -> Bool in
                    return model.identifier == item.identifier
                }) {
                    item.index = index
                    strong.list[index].selectStatus = .select(index: idx)
                }
            }
            DispatchQueue.main.async {
                self?.reloadable?.reloadData()
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
            }
        }
    }
    
}

extension ADAssetListDataSource: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        reloadData()
    }
    
}
