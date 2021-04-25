//
//  ADPhotoKitConfiguration.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import Foundation

public class ADPhotoKitConfiguration {
    
    public static var `default` = ADPhotoKitConfiguration()
    
    /// 指定语言
    public var locale: Locale? {
        didSet {
            Bundle.resetLocaleBundle()
        }
    }
    
    /// 自定义语言文案
    public var customLocaleValue: [Locale:[ADLocale.LocaleKey: String]]?
    
    /// 自定义相簿顺序 默认 ADAlbumType.allCases 顺序
    public var customAlbumOrders: [ADAlbumType]?
    
    #if Module_UI
    
    /// 自定义ui
    public var customUIBundle: Bundle?
    
    public var statusBarStyle: UIStatusBarStyle?
    
    /// album
    public var customAlbumListControllerBlock: ((ADAlbumListController)->Void)?
    
    public var customAlbumListNavBar: ADAlbumListNavBarable?
    
    public var customAlbumListCellRegistor: ((UITableView)->Void)?
    public var customAlbumListCellBlock: ((UITableView, IndexPath)->ADAlbumListCellable)?
    
    /// thumbnail
    public var customThumbnailControllerBlock: ((ADThumbnailViewController)->Void)?
    
    public var customThumbnailNavBar: ADThumbnailNavBarable?
    
    public var customThumbnailToolBar: ADThumbnailToolBarable?
    
    public var customThumbnailCellRegistor: ((UICollectionView)->Void)?
    public var customThumbnailCellBlock: ((UICollectionView, IndexPath)->ADThumbnailCellable)?
    
    /// browser
    public var customBrowserControllerBlock: ((ADAssetBrowserController)->Void)?
    
    public var customBrowserNavBar: ADBrowserNavBarable?
    
    public var customBrowserToolBar: ADBrowserToolBarable?
    
    public var customBrowserCellRegistor: ((UICollectionView)->Void)?
    public var customBrowserCellBlock: ((UICollectionView, IndexPath)->ADBrowserCellable)?
    
    /// hud
    public var customProgressHUD: ADProgressHUDable?
    
    /// progress
    public var customProgress: ADProgressableable?
         
    /// The max speed (pt/s) of auto scroll. Defaults to 600.
    public var autoScrollMaxSpeed: CGFloat = 600
    
    public struct ThumbnailControllerLayout {
        public var itemSpacing: CGFloat = 2
        public var lineSpacing: CGFloat = 2
        public var columnCount: Int = 4
    }
    
    public var thumbnailLayout = ThumbnailControllerLayout()
    
    public var browseItemSpacing: CGFloat = 40
    
    public var fetchTimeout: TimeInterval = 20
    
    #endif

}
