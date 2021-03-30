//
//  ADPhotoUIConfigurable.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import Photos

public protocol ADAlbumListConfigurable {
    
    var identifier: String? { set get }
    
    var requestID: PHImageRequestID? { set get }
    
    var albumModel: ADAlbumModel! { set get }
    
    func configure(with model: ADAlbumModel)
    
}

public enum ADThumbnailSelectStatus {
    /// 可选 如果有index是已选择
    case select(index: Int?)
    /// 不可选
    case deselect

    var isSelect: Bool {
        switch self {
        case let .select(index):
            if let _ = index {
                return true
            }else{
                return false
            }
        case .deselect:
            return false
        }
    }
    
    var isEnable: Bool {
        switch self {
        case .select:
            return true
        case .deselect:
            return false
        }
    }
}

public typealias ADThumbnailListable = (UICollectionViewCell & ADThumbnailListConfigurable)
public protocol ADThumbnailListConfigurable {
    
    var identifier: String? { set get }
    
    var smallRequestID: PHImageRequestID? { set get }
    
    var bigRequestID: PHImageRequestID? { set get }
    
    var selectStatus: ADThumbnailSelectStatus { set get }
    
    var progressView: ADProgressableable! { set get }
    
    var assetModel: ADAssetModel! { set get }
    
    var indexPath: IndexPath! { set get }

    var selectAction: ((ADThumbnailListable,Bool)->Void)? { set get }
    
    func configure(with model: ADAssetModel, indexPath: IndexPath?)
    
    func cellSelectAction()
    
}

public typealias ADThumbnailToolBarable = (UIView & ADThumbnailToolBarConfigurable)
public protocol ADThumbnailToolBarConfigurable {
    
    var height: CGFloat { get }
    
}

public typealias ADProgressableable = (UIView & ADProgressConfigurable)
public protocol ADProgressConfigurable {
    
    var progress: CGFloat { set get }
    
}

public typealias ADProgressHUDable = (UIView & ADProgressHUDConfigurable)
public protocol ADProgressHUDConfigurable {
        
    func show(timeout: TimeInterval)
    
    func hide()
    
}
