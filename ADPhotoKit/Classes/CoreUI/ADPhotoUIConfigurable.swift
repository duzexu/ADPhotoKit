//
//  ADPhotoUIConfigurable.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import UIKit
import Photos

/// Use to define albumlist controller's navigation bar.
public protocol ADAlbumListNavBarConfigurable where Self: UIView {
    
    /// Navigation bar height.
    var height: CGFloat { get }
    /// Navigation bar title.
    var title: String? { set get }
    /// Called when tap navigation bar's right button.
    var rightActionBlock: ((UIButton)->Void)? { set get }
    
}

/// Use to define albumlist controller's tableView cell.
public protocol ADAlbumListCellConfigurable where Self: UITableViewCell {
    
    /// Album model to config cell interface.
    var albumModel: ADAlbumModel! { set get }
    /// Album display style.
    var style: ADPickerStyle! { set get }
    /// Config cell with album model.
    /// - Parameter model: Album info.
    func configure(with model: ADAlbumModel)
    
}

/// Use to define thumbnail controller's navigation bar.
public protocol ADThumbnailNavBarConfigurable where Self: UIView {
    
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

/// Use to define thumbnail controller's tool bar.
public protocol ADThumbnailToolBarConfigurable where Self: UIView {
    
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

/// Use to define thumbnail controller's collection view cell.
public protocol ADThumbnailCellConfigurable where Self: UICollectionViewCell {
    
    /// Thumbnail cell select status.
    var selectStatus: ADAssetModel.SelectStatus { set get }
    /// Asset model to config cell interface.
    var assetModel: ADAssetModel! { set get }
    /// Cell indexPath in collection view.
    var indexPath: IndexPath! { set get }
    /// Called when cell select or deselect. The parameter `Bool` represent asset is selet or not.
    var selectAction: ((ADThumbnailCellConfigurable,Bool)->Void)? { set get }
    /// Config cell with asset model.
    /// - Parameter model: Asset info.
    func configure(with model: ADAssetModel)
    /// Select or deselect cell.
    func cellSelectAction()
    
}

/// Use to define browser controller's collection view cell.
/// - Note: Don't use this protocol directly. User `ADImageBrowserCellable` or `ADVideoBrowserCellable` instead.
public protocol ADBrowserCellConfigurable where Self: UICollectionViewCell {
    
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

/// Use to define browser controller's image collection view cell.
public protocol ADImageBrowserCellConfigurable: ADBrowserCellConfigurable {
    
    /// Config cell with image browser source.
    /// - Parameter source: Image browser info.
    func configure(with source: ADImageSource)
    
}

/// Use to define browser controller's video collection view cell.
public protocol ADVideoBrowserCellConfigurable: ADBrowserCellConfigurable {
    
    /// Config cell with video browser source.
    /// - Parameter source: Video browser info.
    func configure(with source: ADVideoSource)
    
}

/// Use to define browser controller's navigation bar.
public protocol ADBrowserNavBarConfigurable where Self: UIView {
    
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

/// Use to define browser controller's tool bar.
public protocol ADBrowserToolBarConfigurable where Self: UIView {
    
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

class ADPhotoUIConfigurable {
    
    static func albumListNavBar() -> ADAlbumListNavBarConfigurable {
        return ADPhotoKitConfiguration.default.customAlbumListNavBarBlock?() ?? ADAlbumListNavBarView()
    }
    
    static func albumListCell(tableView: UITableView, indexPath: IndexPath) -> ADAlbumListCellConfigurable {
        if ADPhotoKitConfiguration.default.customAlbumListCellBlock != nil {
            assert(ADPhotoKitConfiguration.default.customAlbumListCellRegistor != nil, "you must set 'customAlbumListCellRegistor' and regist your custom cell")
        }
        return ADPhotoKitConfiguration.default.customAlbumListCellBlock?(tableView, indexPath) ?? tableView.dequeueReusableCell(withIdentifier: ADAlbumListCell.reuseIdentifier, for: indexPath) as! ADAlbumListCellConfigurable
    }
    
    static func thumbnailNavBar(style: ADPickerStyle) -> ADThumbnailNavBarConfigurable {
        return ADPhotoKitConfiguration.default.customThumbnailNavBarBlock?(style) ?? ADThumbnailNavBarView(style: style)
    }
    
    static func thumbnailToolBar() -> ADThumbnailToolBarConfigurable {
        return ADPhotoKitConfiguration.default.customThumbnailToolBarBlock?(ADPhotoKitUI.config) ?? ADThumbnailToolBarView(config: ADPhotoKitUI.config)
    }
    
    static func thumbnailCell(collectionView: UICollectionView, indexPath: IndexPath) -> ADThumbnailCellConfigurable {
        if ADPhotoKitConfiguration.default.customThumbnailCellBlock != nil {
            assert(ADPhotoKitConfiguration.default.customThumbnailCellRegistor != nil, "you must set 'customThumbnailCellRegistor' and regist your custom cell")
        }
        return ADPhotoKitConfiguration.default.customThumbnailCellBlock?(collectionView, indexPath) ?? collectionView.dequeueReusableCell(withReuseIdentifier: ADThumbnailListCell.reuseIdentifier, for: indexPath) as! ADThumbnailCellConfigurable
    }
    
    static func browserNavBar(dataSource: ADAssetBrowserDataSource) -> ADBrowserNavBarConfigurable {
        return ADPhotoKitConfiguration.default.customBrowserNavBarBlock?(dataSource) ?? ADBrowserNavBarView(dataSource: dataSource)
    }
    
    static func browserToolBar(dataSource: ADAssetBrowserDataSource) -> ADBrowserToolBarConfigurable {
        return ADPhotoKitConfiguration.default.customBrowserToolBarBlock?(dataSource) ?? ADBrowserToolBarView(dataSource: dataSource)
    }
    
    static func browserCell(collectionView: UICollectionView, indexPath: IndexPath, asset: ADAsset) -> ADBrowserCellConfigurable {
        if ADPhotoKitConfiguration.default.customBrowserCellBlock != nil {
            assert(ADPhotoKitConfiguration.default.customBrowserCellRegistor != nil, "you must set 'customBrowserCellRegistor' and regist your custom cell")
        }
        return ADPhotoKitConfiguration.default.customBrowserCellBlock?(collectionView, indexPath, asset) ?? collectionView.dequeueReusableCell(withReuseIdentifier: asset.reuseIdentifier, for: indexPath) as! ADBrowserCellConfigurable
    }
    
}
