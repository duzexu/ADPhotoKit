//
//  ADPhotoKitConfiguration.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import Foundation
import UIKit

/// Class to modify ADPhotoKit's configuration.
public class ADPhotoKitConfiguration {
    
    /// Represents a shared configuration used across ADPhotoKit.
    /// Use this instance for modify configuration.
    public static var `default` = ADPhotoKitConfiguration()
    
    /// Set framework language, if set nil, framework will use system language. Default is nil.
    public var locale: Locale? {
        didSet {
            Bundle.resetLocaleBundle()
        }
    }
    
    /// You can custom display text for diffent language on yourself. Default is nil.
    public var customLocaleValue: [Locale:[ADLocale.LocaleKey: String]]?
    
    /// Custom album orders, if type not contain, it will not display. Default is ordered by `ADAlbumType.allCases` 's order.
    public var customAlbumOrders: [ADAlbumType]?
    
    /// Custom alert. Default to use alert in framework.
    public var customAlert: ADAlertConfigurable.Type?
    
    #if Module_UI
    
    /// You can custom `core` image Bundle by this property or simple replace image in `ADPhotoKitCoreUI.bundle`. Default is `ADPhotoKitCoreUI.bundle`.
    public var customCoreUIBundle: Bundle?
    
    /// Set status bar style, Default is .lightContent.
    public var statusBarStyle: UIStatusBarStyle?
    
    /// Bolck to generate `ProgressHUD`. Default to use hud in framework.
    public var customProgressHUDBlock: (() -> ADProgressHUDable)?
    
    /// Bolck to generate `ProgressView`. Default to use view in framework.
    public var customProgressBlock: (() -> ADProgressableable)?

    /// Timeout for request images from select assets. Defaults is 20.
    public var fetchTimeout: TimeInterval = 20
    
    /* ================= album ================= */
    
    /// Block to config `ADAlbumListController`.
    public var customAlbumListControllerBlock: ((ADAlbumListController) -> Void)?
    
    /// Bolck to generate `AlbumListNavBar`. Default to use `ADAlbumListNavBarView`.
    public var customAlbumListNavBarBlock: (() -> ADAlbumListNavBarable)?
    
    /// Bolck to regist cells used in albumlist controller.
    public var customAlbumListCellRegistor: ((UITableView) -> Void)?
    /// Bolck to return custom album list cell.
    /// - Note: If use your custom cells, you must regist cells first by set `customAlbumListCellRegistor` block.
    public var customAlbumListCellBlock: ((UITableView, IndexPath) -> ADAlbumListCellable)?
        
    /* =============== thumbnail =============== */
    
    /// The max speed (pt/s) of auto scroll. Defaults to 600.
    public var autoScrollMaxSpeed: CGFloat = 600
    
    /// Layout to control thumbnail controller collection appearance.
    public struct ThumbnailControllerLayout {
        /// Space between item. Default is 2.
        public var itemSpacing: CGFloat = 2
        /// Space between line. Default is 2.
        public var lineSpacing: CGFloat = 2
        /// Item count per line. Default is 4. Max is 5.
        public var columnCount: Int = 4
    }
    
    /// Control thumbnail controller collection appearance.
    public var thumbnailLayout = ThumbnailControllerLayout()
    
    /// Block to config `ADThumbnailViewController`.
    public var customThumbnailControllerBlock: ((ADThumbnailViewController) -> Void)?
    
    /// Bolck to generate `ThumbnailNavBar`. Default to use `ADThumbnailNavBarView`.
    /// The parameter `ADPickerStyle` is the style of bar.
    public var customThumbnailNavBarBlock: ((ADPickerStyle) -> ADThumbnailNavBarable)?
    
    /// Bolck to generate `ThumbnailToolBar`. Default to use `ADThumbnailToolBarView`.
    /// The parameter `ADPhotoKitConfig` is the config pass through.
    public var customThumbnailToolBarBlock: ((ADPhotoKitConfig) -> ADThumbnailToolBarable)?
    
    /// Bolck to regist cells used in thumbnail controller.
    public var customThumbnailCellRegistor: ((UICollectionView) -> Void)?
    /// Bolck to return custom thumbnail collection cell.
    /// - Note: If use your custom cells, you must regist cells first by set `customThumbnailCellRegistor` block.
    public var customThumbnailCellBlock: ((UICollectionView, IndexPath) -> ADThumbnailCellable)?
    
    /* =============== browser =============== */
        
    /// Space between browser controller item.
    public var browseItemSpacing: CGFloat = 40
    
    /// Block to config `ADAssetBrowserController`.
    public var customBrowserControllerBlock: ((ADAssetBrowserController) -> Void)?
    
    /// Bolck to generate `BrowserNavBar`. Default to use `ADBrowserNavBarView`.
    /// The parameter `ADAssetBrowserDataSource` is the datasource of browser controller.
    public var customBrowserNavBarBlock: ((ADAssetBrowserDataSource) -> ADBrowserNavBarable)?
    
    /// Bolck to generate `BrowserToolBar`. Default to use `ADBrowserToolBarView`.
    /// The parameter `ADAssetBrowserDataSource` is the datasource of browser controller.
    public var customBrowserToolBarBlock: ((ADAssetBrowserDataSource) -> ADBrowserToolBarable)?
    
    /// Bolck to regist cells used in browser controller.
    public var customBrowserCellRegistor: ((UICollectionView) -> Void)?
    /// Bolck to return custom browser collection cell.
    /// The parameter `ADAsset` is the asset to browser.
    /// - Note: If use your custom cells, you must regist cells first by set `customBrowserCellRegistor` block.
    public var customBrowserCellBlock: ((UICollectionView, IndexPath, ADAsset) -> ADBrowserCellable)?
        
    #endif
    
    #if Module_ImageEdit
    
    /// You can custom `image edit` image Bundle by this property or simple replace image in `ADPhotoKitImageEdit.bundle`. Default is `ADPhotoKitImageEdit.bundle`.
    public var customImageEditBundle: Bundle?
    
    public var systemImageEditTool: ADImageEditTool = .all
    
    public var customImageEditTools: [ImageEditTool]?
    
    public var lineDrawColors: [UIColor] = [.white, .black, UIColor(hex: 0xF14F4F)!, UIColor(hex: 0xF3AA4E)!, UIColor(hex: 0x50A938)!, UIColor(hex: 0x1EB7F3)!, UIColor(hex: 0x8B69EA)!]
    
    public var lineDrawDefaultColorIndex: Int = 2
    
    public var lineDrawWidth: CGFloat = 5
    
    public var mosaicDrawWidth: CGFloat = 25
    
    public var customImageStickerSelectVC: ADImageStickerSelectable?
    
    #endif

}
