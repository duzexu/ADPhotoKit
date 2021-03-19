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
    public let config: ADPhotoSelectConfig
    public var list: [ADAlbumListModel] = []
    
    public init(reloadable: ADDataSourceReloadable, config: ADPhotoSelectConfig = .init()) {
        self.reloadable = reloadable
        self.config = config
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    public func reloadData() {
        DispatchQueue.global().async { [weak self] in
            guard let strong = self else { return }
            ADPhotoManager.allPhotoAlbumList(ascending: strong.config.ascending, allowSelectImage: strong.config.allowImage, allowSelectVideo: strong.config.allowVideo) { [weak self] (list) in
                self?.list.removeAll()
                self?.list.append(contentsOf: list)
                DispatchQueue.main.async {
                    self?.reloadable?.reloadData()
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
