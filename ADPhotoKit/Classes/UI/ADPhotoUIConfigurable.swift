//
//  ADPhotoUIConfigurable.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import Photos

public typealias ADNavBarable = (UIView & ADNavBarConfigurable)
public protocol ADNavBarConfigurable {
    
    var height: CGFloat { get }
    
    var title: String? { set get }
    
    var leftActionBlock: ((UIButton)->Void)? { set get }
    
    var rightActionBlock: ((UIButton)->Void)? { set get }
            
}

public typealias ADAlbumListNavBarable = (UIView & ADAlbumListNavBarConfigurable)
public protocol ADAlbumListNavBarConfigurable {
    
    var height: CGFloat { get }
    
    var title: String? { set get }
        
    var rightActionBlock: ((UIButton)->Void)? { set get }
    
}

public typealias ADAlbumListCellable = (UITableViewCell & ADAlbumListCellConfigurable)
public protocol ADAlbumListCellConfigurable {
    
    var albumModel: ADAlbumModel! { set get }
    
    var style: ADPickerStyle! { set get }
    
    func configure(with model: ADAlbumModel)
    
}

public typealias ADThumbnailNavBarable = (UIView & ADThumbnailNavBarConfigurable)
public protocol ADThumbnailNavBarConfigurable {
    
    var height: CGFloat { get }
    
    var title: String? { set get }
    
    var leftActionBlock: ((UIButton)->Void)? { set get }
    
    var rightActionBlock: ((UIButton)->Void)? { set get }
    
    var reloadAlbumBlock: ((ADAlbumModel)->Void)? { set get }
    
    init(style: ADPickerStyle)
    
}

public typealias ADThumbnailToolBarable = (UIView & ADThumbnailToolBarConfigurable)
public protocol ADThumbnailToolBarConfigurable {
    
    var height: CGFloat { get }
    
    var isOriginal: Bool { set get }
    
    var selectCount: Int { set get }
    
    var browserActionBlock: (()->Void)? { set get }
    
    var doneActionBlock: (()->Void)? { set get }
    
}

public enum ADThumbnailSelectStatus {
    /// 可选 如果有index是已选择
    case select(index: Int?)
    /// 不可选
    case deselect

    public var isSelect: Bool {
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
    
    public var isEnable: Bool {
        switch self {
        case .select:
            return true
        case .deselect:
            return false
        }
    }
}

public typealias ADThumbnailCellable = (UICollectionViewCell & ADThumbnailCellConfigurable)
public protocol ADThumbnailCellConfigurable {
    
    var selectStatus: ADThumbnailSelectStatus { set get }
        
    var assetModel: ADAssetModel! { set get }
    
    var indexPath: IndexPath! { set get }

    var selectAction: ((ADThumbnailCellable,Bool)->Void)? { set get }
    
    func configure(with model: ADAssetModel, indexPath: IndexPath?)
    
    func cellSelectAction()
    
}

public typealias ADBrowserCellable = (UICollectionViewCell & ADBrowserCellConfigurable)
public protocol ADBrowserCellConfigurable {
    
    var singleTapBlock: (() -> Void)? { set get }
    
    func cellWillDisplay()
    
    func cellDidEndDisplay()
    
    ///transation
    func transationBegin() -> (UIView,CGRect)
    
    func transationCancel(view: UIView)
    
}

public typealias ADImageBrowserCellable = (UICollectionViewCell & ADImageBrowserCellConfigurable)
public protocol ADImageBrowserCellConfigurable: ADBrowserCellConfigurable {
    func configure(with source: ADImageSource, indexPath: IndexPath?)
}

public typealias ADVideoBrowserCellable = (UICollectionViewCell & ADVideoBrowserCellConfigurable)
public protocol ADVideoBrowserCellConfigurable: ADBrowserCellConfigurable {
    func configure(with source: ADVideoSource, indexPath: IndexPath?)
}

public typealias ADBrowserNavBarable = (UIView & ADBrowserNavBarConfigurable)
public protocol ADBrowserNavBarConfigurable {
    
    var height: CGFloat { get }
    
    var title: String? { set get }
    
    var leftActionBlock: ((UIButton)->Void)? { set get }
    
    var rightActionBlock: ((UIButton)->Void)? { set get }
    
    init(dataSource: ADAssetBrowserDataSource)
        
}

public typealias ADBrowserToolBarable = (UIView & ADBrowserToolBarConfigurable)
public protocol ADBrowserToolBarConfigurable {
    
    var height: CGFloat { get }
    
    var modifyHeight: CGFloat { get }
    
    var isOriginal: Bool { set get }
    
    var editActionBlock: (()->Void)? { set get }
    
    var doneActionBlock: (()->Void)? { set get }
        
}

public typealias ADProgressableable = (UIView & ADProgressConfigurable)
public protocol ADProgressConfigurable {
    
    var progress: CGFloat { set get }
    
}

public typealias ADProgressHUDable = (UIView & ADProgressHUDConfigurable)
public protocol ADProgressHUDConfigurable {
    
    var timeoutBlock: (() -> Void)? { set get }
        
    func show(timeout: TimeInterval)
    
    func hide()
    
}

public protocol ADAlertConfigurable {
    
    static func alert(on: UIViewController, title: String?, message: String?, completion: ((Int)->Void)?)
        
}

class ADPhotoUIConfigurable {
    
    static func albumListNavBar() -> ADAlbumListNavBarable {
        return ADPhotoKitConfiguration.default.customAlbumListNavBarBlock?() ?? ADAlbumListNavBarView()
    }
    
    static func albumListCell(tableView: UITableView, indexPath: IndexPath) -> ADAlbumListCellable {
        if ADPhotoKitConfiguration.default.customAlbumListCellBlock != nil {
            assert(ADPhotoKitConfiguration.default.customAlbumListCellRegistor != nil, "you must set 'customAlbumListCellRegistor' and regist your custom cell")
        }
        return ADPhotoKitConfiguration.default.customAlbumListCellBlock?(tableView, indexPath) ?? tableView.dequeueReusableCell(withIdentifier: ADAlbumListCell.reuseIdentifier, for: indexPath) as! ADAlbumListCellable
    }
    
    static func thumbnailNavBar(style: ADPickerStyle) -> ADThumbnailNavBarable {
        return ADPhotoKitConfiguration.default.customThumbnailNavBarBlock?(style) ?? ADThumbnailNavBarView(style: style)
    }
    
    static func thumbnailToolBar() -> ADThumbnailToolBarable {
        return ADPhotoKitConfiguration.default.customThumbnailToolBarBlock?(ADPhotoKitUI.config) ?? ADThumbnailToolBarView(config: ADPhotoKitUI.config)
    }
    
    static func thumbnailCell(collectionView: UICollectionView, indexPath: IndexPath) -> ADThumbnailCellable {
        if ADPhotoKitConfiguration.default.customThumbnailCellBlock != nil {
            assert(ADPhotoKitConfiguration.default.customThumbnailCellRegistor != nil, "you must set 'customThumbnailCellRegistor' and regist your custom cell")
        }
        return ADPhotoKitConfiguration.default.customThumbnailCellBlock?(collectionView, indexPath) ?? collectionView.dequeueReusableCell(withReuseIdentifier: ADThumbnailListCell.reuseIdentifier, for: indexPath) as! ADThumbnailCellable
    }
    
    static func browserNavBar(dataSource: ADAssetBrowserDataSource) -> ADBrowserNavBarable {
        return ADPhotoKitConfiguration.default.customBrowserNavBarBlock?(dataSource) ?? ADBrowserNavBarView(dataSource: dataSource)
    }
    
    static func browserToolBar(dataSource: ADAssetBrowserDataSource) -> ADBrowserToolBarable {
        return ADPhotoKitConfiguration.default.customBrowserToolBarBlock?(dataSource) ?? ADBrowserToolBarView(dataSource: dataSource)
    }
    
    static func browserCell(collectionView: UICollectionView, indexPath: IndexPath, reuseIdentifier: String) -> ADBrowserCellable {
        if ADPhotoKitConfiguration.default.customBrowserCellBlock != nil {
            assert(ADPhotoKitConfiguration.default.customBrowserCellRegistor != nil, "you must set 'customBrowserCellRegistor' and regist your custom cell")
        }
        return ADPhotoKitConfiguration.default.customBrowserCellBlock?(collectionView, indexPath) ?? collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ADBrowserCellable
    }
    
    static func progressHUD() -> ADProgressHUDable {
        return ADPhotoKitConfiguration.default.customProgressHUDBlock?() ?? ADProgressHUD()
    }
    
    static func progress() -> ADProgressableable {
        return ADPhotoKitConfiguration.default.customProgressBlock?() ?? ADProgressView()
    }
    
}
