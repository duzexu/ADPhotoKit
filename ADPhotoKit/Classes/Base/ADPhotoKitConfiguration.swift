//
//  ADPhotoKitConfiguration.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import Foundation
import UIKit
import AVFoundation

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
    
    #if Module_Core
    
    /// Custom album orders, if type not contain, it will not display. Default is ordered by `ADAlbumType.allCases` 's order.
    public var customAlbumOrders: [ADAlbumType]?
    
    #endif
    
    #if Module_UI
    
    /// Custom alert. Default to use alert in framework.
    public var customAlert: ADAlertConfigurable.Type?
    
    /// Bolck to generate `ProgressHUD`. Default to use hud in framework.
    public var customProgressHUDBlock: (() -> ADProgressHUDConfigurable)?
    
    /// Bolck to generate `ProgressView`. Default to use view in framework.
    public var customProgressBlock: (() -> ADProgressConfigurable)?
    
    /// You can custom `core` image Bundle by this property or simple replace image in `ADPhotoKitCoreUI.bundle`. Default is `ADPhotoKitCoreUI.bundle`.
    public var customCoreUIBundle: Bundle?
    
    /// Set status bar style, Default is .lightContent.
    public var statusBarStyle: UIStatusBarStyle?
    
    /// Timeout for request assets from select assets. Defaults is 20.
    public var fetchTimeout: TimeInterval = 20
    
    /* ================= album ================= */
    
    /// Block to config `ADAlbumListController`.
    public var customAlbumListControllerBlock: ((ADAlbumListController) -> Void)?
    
    /// Bolck to generate `AlbumListNavBar`. Default to use `ADAlbumListNavBarView`.
    public var customAlbumListNavBarBlock: (() -> ADAlbumListNavBarConfigurable)?
    
    /// Bolck to regist cells used in albumlist controller.
    public var customAlbumListCellRegistor: ((UITableView) -> Void)?
    /// Bolck to return custom album list cell.
    /// - Note: If use your custom cells, you must regist cells first by set `customAlbumListCellRegistor` block.
    public var customAlbumListCellBlock: ((UITableView, IndexPath) -> ADAlbumListCellConfigurable)?
        
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
    /// The parameter `ADPhotoKitConfig` is the config pass through.
    public var customThumbnailNavBarBlock: ((ADPickerStyle,ADPhotoKitConfig) -> ADThumbnailNavBarConfigurable)?
    
    /// Bolck to generate `ThumbnailToolBar`. Default to use `ADThumbnailToolBarView`.
    /// The parameter `ADPhotoKitConfig` is the config pass through.
    public var customThumbnailToolBarBlock: ((ADAssetListDataSource,ADPhotoKitConfig) -> ADThumbnailToolBarConfigurable)?
    
    /// Bolck to regist cells used in thumbnail controller.
    public var customThumbnailCellRegistor: ((UICollectionView) -> Void)?
    /// Bolck to return custom thumbnail collection cell.
    /// - Note: If use your custom cells, you must regist cells first by set `customThumbnailCellRegistor` block.
    public var customThumbnailCellBlock: ((UICollectionView, IndexPath) -> ADThumbnailCellConfigurable)?
    
    /// Config to control asset capture.
    public struct AssetCaptureConfig {
        /// Default device position.
        public var cameraPosition: ADDevicePosition = .back
        /// Whether to show flash switch button.
        public var flashSwitch: Bool = true
        /// Whether to show camera switch button.
        public var cameraSwitch: Bool = true
        /// Indicates whether the video flowing through the connection should be mirrored about its vertical axis.
        public var videoMirrored = true
        /// Capture video resolution.
        public var sessionPreset: ADCapturePreset = .hd1280x720
        // Camera focus mode. Defaults to continuousAutoFocus
        public var focusMode: ADFocusMode = .continuousAutoFocus
        /// Camera exposure mode. Defaults to continuousAutoExposure
        public var exposureMode: ADExposureMode = .continuousAutoExposure
    }
    
    /// Control asset capture controller.
    public var captureConfig = AssetCaptureConfig()
    
    /// Custom asset capture controller.
    public var customAssetCaptureVCBlock: ((ADPhotoKitConfig) -> ADAssetCaptureConfigurable)?
    
    /* =============== browser =============== */
        
    /// Space between browser controller item.
    public var browseItemSpacing: CGFloat = 40
    
    /// Block to config `ADAssetBrowserController`.
    public var customBrowserControllerBlock: ((ADAssetBrowserController) -> Void)?
    
    /// Bolck to generate `BrowserNavBar`. Default to use `ADBrowserNavBarView`.
    /// The parameter `ADAssetBrowserDataSource` is the datasource of browser controller.
    /// The parameter `ADPhotoKitConfig` is the config pass through.
    public var customBrowserNavBarBlock: ((ADAssetBrowserDataSource,ADPhotoKitConfig) -> ADBrowserNavBarConfigurable)?
    
    /// Bolck to generate `BrowserToolBar`. Default to use `ADBrowserToolBarView`.
    /// The parameter `ADAssetBrowserDataSource` is the datasource of browser controller.
    /// The parameter `ADPhotoKitConfig` is the config pass through.
    public var customBrowserToolBarBlock: ((ADAssetBrowserDataSource,ADPhotoKitConfig) -> ADBrowserToolBarConfigurable)?
    
    /// Bolck to regist cells used in browser controller.
    public var customBrowserCellRegistor: ((UICollectionView) -> Void)?
    /// Bolck to return custom browser collection cell.
    /// The parameter `ADAsset` is the asset to browser.
    /// - Note: If use your custom cells, you must regist cells first by set `customBrowserCellRegistor` block.
    public var customBrowserCellBlock: ((UICollectionView, IndexPath, ADAsset) -> ADBrowserCellConfigurable)?
        
    #endif
    
    #if Module_ImageEdit || Module_VideoEdit
    
    /* =============== image sticker =============== */
    
    /// System image picker data source.
    public var imageStickerDataSource: ADImageStickerDataSource?
    
    /// Custom image sticker select controller.
    public var customImageStickerSelectVC: ADImageStickerSelectConfigurable?
    
    /* =============== text sticker =============== */
    
    /// Custom text sticker edit controller.
    public var customTextStickerEditVCBlock: ((ADTextSticker?) -> ADTextStickerEditConfigurable)?
    
    /// System text sticker selectable colors.
    public var textStickerColors: [ADTextStickerColor] = [(.white,.black,UIColor(hex: 0x8E8C90)!),(.black,.white,UIColor(hex: 0x8E8C90)!),(UIColor(hex: 0xF14F4F)!,.white,UIColor(hex: 0x8B3031)!),(UIColor(hex: 0xF3AA4E)!,.white,UIColor(hex: 0x7C4F20)!),(UIColor(hex: 0xFFC300)!,.white,UIColor(hex: 0x8C6E02)!),(UIColor(hex: 0x90D200)!,.white,UIColor(hex: 0x567603)!),(UIColor(hex: 0x10C060)!,.white,UIColor(hex: 0x056C39)!),(UIColor(hex: 0x1EB7F3)!,.white,UIColor(hex: 0x06628E)!),(UIColor(hex: 0x1384ED)!,.white,UIColor(hex: 0x0A4C84)!),(UIColor(hex: 0x8B69EA)!,.white,UIColor(hex: 0x3A3A85)!),(UIColor(hex: 0x7F7F7F)!,.white,UIColor(hex: 0x4C494C)!)]
    
    /// System text sticker tool default color index.
    public var textStickerDefaultColorIndex: Int = 0
    
    /// System text sticker tool default font size.
    public var textStickerDefaultFontSize: CGFloat = 32
    
    /// System text sticker tool default stroke width.
    public var textStickerDefaultStrokeWidth: Int = 6
    
    #endif
    
    #if Module_ImageEdit
    
    /// You can custom `image edit` image Bundle by this property or simple replace image in `ADPhotoKitImageEdit.bundle`. Default is `ADPhotoKitImageEdit.bundle`.
    public var customImageEditBundle: Bundle?
    
    /// System image edit tools. Default is ordered by `ADImageEditTools.all` 's order. You can remove some tools or reorder as you wish.
    /// - Note: If contain `.imageStkr`, you must set `imageStickerDataSource` or `customImageStickerSelectVC`.
    public var systemImageEditTools: ADImageEditTools = .all
    
    /// User custom image edit tools. Custom tools is default add after system tools.
    /// - Parameter image: Original image.
    public var customImageEditToolsBlock: ((UIImage) -> [ADImageEditTool])?
    
    /// Custom image edit edit controller.
    public var customImageEditVCBlock: ((UIImage,ADImageEditInfo?) -> ADImageEditConfigurable)?
    
    /* =============== draw =============== */
    
    /// System line draw tool selectable colors.
    public var lineDrawColors: [UIColor] = [.white, .black, UIColor(hex: 0xF14F4F)!, UIColor(hex: 0xF3AA4E)!, UIColor(hex: 0xFFC300)!, UIColor(hex: 0x90D200)!, UIColor(hex: 0x10C060)!, UIColor(hex: 0x1EB7F3)!, UIColor(hex: 0x1384ED)!, UIColor(hex: 0x8B69EA)!, UIColor(hex: 0x7F7F7F)!]
    
    /// System line draw tool default color index.
    public var lineDrawDefaultColorIndex: Int = 2
    
    /// System line draw tool default line width.
    public var lineDrawWidth: CGFloat = 5
    
    /// System mosaic draw tool default line width.
    public var mosaicDrawWidth: CGFloat = 25
    
    /// Erase default highlight outline width.
    public var eraseOutlineWidth: CGFloat = 8
    
    /* =============== clip =============== */
    
    /// Custom image clip controller.
    public var customImageClipVCBlock: ((ADImageClipInfo) -> ADImageClipConfigurable)?
    
    #endif
    
    #if Module_VideoEdit
    
    /// You can custom `video edit` image Bundle by this property or simple replace image in `ADPhotoKitImageEdit.bundle`. Default is `ADPhotoKitVideoEdit.bundle`.
    public var customVideoEditBundle: Bundle?
    
    /// System video edit tools. Default is ordered by `ADVideoEditTools.all` 's order. You can remove some tools or reorder as you wish.
    /// - Note: If contain `.imageStkr`, you must set `imageStickerDataSource` or `customImageStickerSelectVC`.
    /// - Note: If contain `.bgMusic`, you must set `videoMusicDataSource` or `customVideoMusicSelectVC`.
    public var systemVideoEditTools: ADVideoEditTools = .all
    
    public var customVideoPlayableBlock: ((AVAsset) -> ADVideoPlayable)?
    
    /// User custom video edit tools. Custom tools is default add after system tools.
    public var customVideoEditToolsBlock: (() -> [ADVideoEditTool])?
    
    public var customVideoEditVCBlock: ((AVAsset, ADVideoEditInfo?, ADVideoEditOptions) -> ADVideoEditConfigurable)?
    
    /* =============== bgm =============== */
    
    public var videoMusicDataSource: ADVideoMusicDataSource?
    
    public var customVideoMusicSelectVCBlock: ((ADVideoSound?) -> ADVideoMusicSelectConfigurable)?
    
    /* =============== clip =============== */
    
    /// Custom video clip controller.
    public var customVideoClipVCBlock: ((ADVideoClipInfo) -> ADVideoClipConfigurable)?
    
    #endif

}
