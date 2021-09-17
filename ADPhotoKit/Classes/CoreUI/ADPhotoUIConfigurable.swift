//
//  ADPhotoUIConfigurable.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import UIKit
import Photos

/// Albumlist controller's navigation bar.
public typealias ADAlbumListNavBarable = (UIView & ADAlbumListNavBarConfigurable)
/// Use to define albumlist controller's navigation bar.
public protocol ADAlbumListNavBarConfigurable {
    
    /// Navigation bar height.
    var height: CGFloat { get }
    /// Navigation bar title.
    var title: String? { set get }
    /// Called when tap navigation bar's right button.
    var rightActionBlock: ((UIButton)->Void)? { set get }
    
}

/// Albumlist controller's tableView cell.
public typealias ADAlbumListCellable = (UITableViewCell & ADAlbumListCellConfigurable)
/// Use to define albumlist controller's tableView cell.
public protocol ADAlbumListCellConfigurable {
    
    /// Album model to config cell interface.
    var albumModel: ADAlbumModel! { set get }
    /// Album display style.
    var style: ADPickerStyle! { set get }
    /// Config cell with album model.
    /// - Parameter model: Album info.
    func configure(with model: ADAlbumModel)
    
}

/// Thumbnail controller's navigation bar.
public typealias ADThumbnailNavBarable = (UIView & ADThumbnailNavBarConfigurable)
/// Use to define thumbnail controller's navigation bar.
public protocol ADThumbnailNavBarConfigurable {
    
    /// Navigation bar height.
    var height: CGFloat { get }
    /// Navigation bar title.
    var title: String? { set get }
    /// Called when navigation bar's left button click.
    var leftActionBlock: (()->Void)? { set get }
    /// Called when tap navigation bar's right button.
    var rightActionBlock: ((UIButton)->Void)? { set get }
    /// Called when select album model changed.
    var reloadAlbumBlock: ((ADAlbumModel)->Void)? { set get }
    /// Create with the style of bar.
    init(style: ADPickerStyle)
    
}

/// Thumbnail controller's tool bar.
public typealias ADThumbnailToolBarable = (UIView & ADThumbnailToolBarConfigurable)
/// Use to define thumbnail controller's tool bar.
public protocol ADThumbnailToolBarConfigurable {
    
    /// Tool bar height.
    var height: CGFloat { get }
    /// If select orginal asset.
    var isOriginal: Bool { set get }
    /// Asset select count.
    var selectCount: Int { set get }
    /// Called when browser button click.
    var browserActionBlock: (()->Void)? { set get }
    /// Called when done button click.
    var doneActionBlock: (()->Void)? { set get }
    
}

/// Thumbnail controller's collection view cell.
public typealias ADThumbnailCellable = (UICollectionViewCell & ADThumbnailCellConfigurable)
/// Use to define thumbnail controller's collection view cell.
public protocol ADThumbnailCellConfigurable {
    
    /// Thumbnail cell select status.
    var selectStatus: ADThumbnailSelectStatus { set get }
    /// Asset model to config cell interface.
    var assetModel: ADAssetModel! { set get }
    /// Cell indexPath in collection view.
    var indexPath: IndexPath! { set get }
    /// Called when cell select or deselect. The parameter `Bool` represent asset is selet or not.
    var selectAction: ((ADThumbnailCellable,Bool)->Void)? { set get }
    /// Config cell with asset model.
    /// - Parameter model: Asset info.
    func configure(with model: ADAssetModel)
    /// Select or deselect cell.
    func cellSelectAction()
    
}

/// Browser controller's collection view cell.
/// - Note: Don't use this protocol directly. User `ADImageBrowserCellable` or `ADVideoBrowserCellable` instead.
public typealias ADBrowserCellable = (UICollectionViewCell & ADBrowserCellConfigurable)
/// Use to define browser controller's collection view cell.
public protocol ADBrowserCellConfigurable {
    
    /// Called when tap cell.
    var singleTapBlock: (() -> Void)? { set get }
    
    /// Call when cell will display.
    func cellWillDisplay()
    /// Call when cell did end display.
    func cellDidEndDisplay()
    
    /// Call when begin pull down in browser controller.
    func transationBegin() -> (UIView,CGRect)
    /// Call when cancel pull down in browser controller.
    func transationCancel(view: UIView)
    
}

/// Browser controller's image collection view cell.
public typealias ADImageBrowserCellable = (UICollectionViewCell & ADImageBrowserCellConfigurable)
/// Use to define browser controller's image collection view cell.
public protocol ADImageBrowserCellConfigurable: ADBrowserCellConfigurable {
    
    /// Config cell with image browser source.
    /// - Parameter source: Image browser info.
    func configure(with source: ADImageSource)
    
}

/// Browser controller's video collection view cell.
public typealias ADVideoBrowserCellable = (UICollectionViewCell & ADVideoBrowserCellConfigurable)
/// Use to define browser controller's video collection view cell.
public protocol ADVideoBrowserCellConfigurable: ADBrowserCellConfigurable {
    
    /// Config cell with video browser source.
    /// - Parameter source: Video browser info.
    func configure(with source: ADVideoSource)
    
}

/// Browser controller's navigation bar.
public typealias ADBrowserNavBarable = (UIView & ADBrowserNavBarConfigurable)
/// Use to define browser controller's navigation bar.
public protocol ADBrowserNavBarConfigurable {
    
    /// Navigation bar height.
    var height: CGFloat { get }
    /// Navigation bar title.
    var title: String? { set get }
    /// Called when navigation bar's left button click.
    var leftActionBlock: (()->Void)? { set get }
    /// Called when navigation bar's select button click. The parameter `Bool` represent asset is selet or not.
    var selectActionBlock: ((Bool)->Bool)? { set get }
    /// Create with browser controller's datasource.
    /// - Parameter dataSource: Browser controller datasource.
    init(dataSource: ADAssetBrowserDataSource)
        
}

/// Browser controller's tool bar.
public typealias ADBrowserToolBarable = (UIView & ADBrowserToolBarConfigurable)
/// Use to define browser controller's tool bar.
public protocol ADBrowserToolBarConfigurable {
    
    /// Tool bar height.
    var height: CGFloat { get }
    /// Bar height when select assets changed.
    var modifyHeight: CGFloat { get }
    /// If select orginal asset.
    var isOriginal: Bool { set get }
    /// Called when edit button click.
    var editActionBlock: (()->Void)? { set get }
    /// Called when done button click.
    var doneActionBlock: (()->Void)? { set get }
    /// Create with browser controller's datasource.
    /// - Parameter dataSource: Browser controller datasource.
    init(dataSource: ADAssetBrowserDataSource)
        
}

/// View use to show download or loading progress.
public typealias ADProgressableable = (UIView & ADProgressConfigurable)
/// Used to indicator a time-consuming operation's progress.
public protocol ADProgressConfigurable {
    
    /// Task progress.
    var progress: CGFloat { set get }
    
}

/// View showed when load albums and assets or request images from assets.
public typealias ADProgressHUDable = (UIView & ADProgressHUDConfigurable)
/// Used to indicator a time-consuming operation is in progress.
public protocol ADProgressHUDConfigurable {
    
    /// Called when task timeout.
    var timeoutBlock: (() -> Void)? { set get }
    
    /// Show ProgressHUD.
    /// - Parameter timeout: The duration before the task is timeout. If set 0, view will not hide automatic.
    func show(timeout: TimeInterval)
    
    /// Dismiss ProgressHUD.
    func hide()
    
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
    
    static func browserCell(collectionView: UICollectionView, indexPath: IndexPath, asset: ADAsset) -> ADBrowserCellable {
        if ADPhotoKitConfiguration.default.customBrowserCellBlock != nil {
            assert(ADPhotoKitConfiguration.default.customBrowserCellRegistor != nil, "you must set 'customBrowserCellRegistor' and regist your custom cell")
        }
        return ADPhotoKitConfiguration.default.customBrowserCellBlock?(collectionView, indexPath, asset) ?? collectionView.dequeueReusableCell(withReuseIdentifier: asset.reuseIdentifier, for: indexPath) as! ADBrowserCellable
    }
    
    static func progressHUD() -> ADProgressHUDable {
        return ADPhotoKitConfiguration.default.customProgressHUDBlock?() ?? ADProgressHUD()
    }
    
    static func progress() -> ADProgressableable {
        return ADPhotoKitConfiguration.default.customProgressBlock?() ?? ADProgressView()
    }
    
    static func alert() -> ADAlertConfigurable.Type {
        return ADPhotoKitConfiguration.default.customAlert ?? ADAlert.self
    }
    
}
