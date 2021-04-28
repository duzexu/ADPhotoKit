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
    
    /// 自定义图片
    public var customUIBundle: Bundle?
    
    /// 状态栏样式
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
