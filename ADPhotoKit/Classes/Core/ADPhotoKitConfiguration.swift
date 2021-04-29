//
//  ADPhotoKitConfiguration.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import Foundation

public class ADPhotoKitConfiguration {
    
    public static var `default` = ADPhotoKitConfiguration()
    
    /// Set framework language, if set nil, framework will use system language. Default is nil.
    public var locale: Locale? {
        didSet {
            Bundle.resetLocaleBundle()
        }
    }
    
    /// You can custom display text for diffent language on yourself.
    public var customLocaleValue: [Locale:[ADLocale.LocaleKey: String]]?
    
    /// Custom album orders, if type not contain, it will not display. Default is ordered by `ADAlbumType.allCases` 's order.
    public var customAlbumOrders: [ADAlbumType]?
    
    #if Module_UI
    
    /// 自定义图片
    public var customUIBundle: Bundle?
    
    /// Set status bar style, Default is .lightContent.
    public var statusBarStyle: UIStatusBarStyle?
    
    /// album
    public var customAlbumListControllerBlock: ((ADAlbumListController) -> Void)?
    
    public var customAlbumListNavBarBlock: (() -> ADAlbumListNavBarable)?
    
    public var customAlbumListCellRegistor: ((UITableView)->Void)?
    public var customAlbumListCellBlock: ((UITableView, IndexPath)->ADAlbumListCellable)?
    
    /// thumbnail
    public var customThumbnailControllerBlock: ((ADThumbnailViewController)->Void)?
    
    public var customThumbnailNavBarBlock: ((ADPickerStyle) -> ADThumbnailNavBarable)?
    
    public var customThumbnailToolBarBlock: ((ADPhotoKitConfig) -> ADThumbnailToolBarable)?
    
    public var customThumbnailCellRegistor: ((UICollectionView)->Void)?
    public var customThumbnailCellBlock: ((UICollectionView, IndexPath)->ADThumbnailCellable)?
    
    /// browser
    public var customBrowserControllerBlock: ((ADAssetBrowserController)->Void)?
    
    public var customBrowserNavBarBlock: ((ADAssetBrowserDataSource) -> ADBrowserNavBarable)?
    
    public var customBrowserToolBarBlock: ((ADAssetBrowserDataSource) -> ADBrowserToolBarable)?
    
    public var customBrowserCellRegistor: ((UICollectionView)->Void)?
    public var customBrowserCellBlock: ((UICollectionView, IndexPath)->ADBrowserCellable)?
    
    /// hud
    public var customProgressHUDBlock: (() -> ADProgressHUDable)?
    
    /// progress
    public var customProgressBlock: (() -> ADProgressableable)?
         
    /// The max speed (pt/s) of auto scroll. Defaults to 600.
    public var autoScrollMaxSpeed: CGFloat = 600
    
    public struct ThumbnailControllerLayout {
        public var itemSpacing: CGFloat = 2
        public var lineSpacing: CGFloat = 2
        public var columnCount: Int = 4
    }
    
    /// thumbnail layout
    public var thumbnailLayout = ThumbnailControllerLayout()
    
    /// browser layout
    public var browseItemSpacing: CGFloat = 40
    
    /// fetch image timeout
    public var fetchTimeout: TimeInterval = 20
    
    #endif

}
