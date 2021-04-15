//
//  ADPhotoUIConfigurable.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import Photos

public protocol ADAlbumListConfigurable {
    
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

public typealias ADNavBarable = (UIView & ADNavBarConfigurable)
public protocol ADNavBarConfigurable {
    
    var height: CGFloat { get }
    
    var title: String? { set get }
    
    var leftActionBlock: ((UIButton)->Void)? { set get }
    
    var rightActionBlock: ((UIButton)->Void)? { set get }
            
}

public protocol ADToolBarConfigurable {
    
    var height: CGFloat { get }
        
    var leftActionBlock: ((UIButton)->Void)? { set get }
    
    var rightActionBlock: ((UIButton)->Void)? { set get }
            
}

public typealias ADThumbnailListable = (UICollectionViewCell & ADThumbnailListConfigurable)
public protocol ADThumbnailListConfigurable {
    
    var selectStatus: ADThumbnailSelectStatus { set get }
        
    var assetModel: ADAssetModel! { set get }
    
    var indexPath: IndexPath! { set get }

    var selectAction: ((ADThumbnailListable,Bool)->Void)? { set get }
    
    func configure(with model: ADAssetModel, indexPath: IndexPath?)
    
    func cellSelectAction()
    
}

public typealias ADThumbnailToolBarable = (UIView & ADThumbnailToolBarConfigurable)
public protocol ADThumbnailToolBarConfigurable {
    
    var height: CGFloat { get }
    
    var isOriginal: Bool { set get }
    
    var selectCount: Int { set get }
    
    var browserActionBlock: (()->Void)? { set get }
    
    var doneActionBlock: (()->Void)? { set get }
    
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

public typealias ADBrowserToolBarable = (UIView & ADBrowserToolBarConfigurable)
public protocol ADBrowserToolBarConfigurable {
    
    var height: CGFloat { get }
    
    var isOriginal: Bool { set get }
    
    var editActionBlock: (()->Void)? { set get }
    
    var doneActionBlock: (()->Void)? { set get }
        
}
