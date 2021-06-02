//
//  ADAlbumListDataSource.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import Foundation
import UIKit
import Photos

/// The data source of album controller. It get albums you request and reload the associate reloadable view when album changed.
public class ADAlbumListDataSource: NSObject {
        
    /// The associate reloadable view conform to `ADDataSourceReloadable`.
    public weak var reloadable: ADDataSourceReloadable?
    
    /// Options to set the album type and order.
    public let options: ADAlbumSelectOptions
    
    /// Albums array request from `PHAssetCollection`.
    public var list: [ADAlbumModel] = []
    
    /// Create data source with associate reloadable view and options.
    /// - Parameters:
    ///   - reloadable: Associate reloadable view.
    ///   - options: Options to limit album type and order. It is `ADAlbumSelectOptions.default` by default.
    public init(reloadable: ADDataSourceReloadable, options: ADAlbumSelectOptions = .default) {
        self.reloadable = reloadable
        self.options = options
        super.init()
        if #available(iOS 14.0, *), PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    /// Reload the associate view with fetch albums.
    /// - Parameter completion: Called when the reload finished.
    public func reloadData(completion: (() -> Void)? = nil) {
        DispatchQueue.global().async { [weak self] in
            guard let strong = self else { return }
            ADPhotoManager.allPhotoAlbumList(options: strong.options) { [weak self] (list) in
                self?.list.removeAll()
                self?.list.append(contentsOf: list)
                DispatchQueue.main.async {
                    self?.reloadable?.reloadData()
                    completion?()
                }
            }
        }
    }
    
}

extension ADAlbumListDataSource: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        reloadData()
    }
    
}
