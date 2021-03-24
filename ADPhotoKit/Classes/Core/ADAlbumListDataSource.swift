//
//  ADAlbumListDataSource.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import Foundation
import Photos

public class ADAlbumListDataSource: NSObject {
    
    public weak var reloadable: ADDataSourceReloadable?
    public let options: ADAlbumSelectOptions
    public var list: [ADAlbumModel] = []
    
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
