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
    
    public init(reloadable: ADDataSourceReloadable,
                album: ADAlbumModel,
                options: ADAlbumSelectOptions = .default) {
        self.reloadable = reloadable
        self.album = album
        self.options = options
        super.init()
        if #available(iOS 14.0, *), PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    public func reloadData() {
        DispatchQueue.global().async { [weak self] in
            guard let strong = self else { return }
            let models = ADPhotoManager.fetchAssets(in: strong.album.result, options: strong.options)
            strong.list.removeAll()
            strong.list.append(contentsOf: models)
            DispatchQueue.main.async {
                self?.reloadable?.reloadData()
            }
        }
    }
    
}

extension ADAssetListDataSource: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        reloadData()
    }
    
}
