//
//  ADPhotoKitUI.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import Photos

public enum ADPickerStyle {
    case normal
    case embed
}

public struct ADAssetSelectOptions: OptionSet {
    public let rawValue: Int
    
    /// Whether photos and videos can be selected together.
    static let mixSelect = ADAssetSelectOptions(rawValue: 1 << 0)
    /// Allow select Gif, it only controls whether it is displayed in Gif form.
    static let selectAsGif = ADAssetSelectOptions(rawValue: 1 << 1)
    /// Allow select LivePhoto, it only controls whether it is displayed in LivePhoto form.
    static let selectAsLivePhoto = ADAssetSelectOptions(rawValue: 1 << 2)
    /// You can slide select photos in album.
    static let slideSelect = ADAssetSelectOptions(rawValue: 1 << 3)
    /// Will auto scroll to top or bottom when your finger at the top or bottom.
    static let autoScroll = ADAssetSelectOptions(rawValue: 1 << 4)
    /// Allow take photo asset in the album.
    static let allowTakePhotoAsset = ADAssetSelectOptions(rawValue: 1 << 5)
    /// Allow take video asset in the album.
    static let allowTakeVideoAsset = ADAssetSelectOptions(rawValue: 1 << 6)
    /// Show the image captured by the camera is displayed on the camera button inside the album.
    static let captureOnTakeAsset = ADAssetSelectOptions(rawValue: 1 << 7)
    /// If user choose limited Photo mode, a button with '+' will be added. It will call PHPhotoLibrary.shared().presentLimitedLibraryPicker(from:) to add photo.
    @available(iOS 14, *)
    static let allowAddAsset = ADAssetSelectOptions(rawValue: 1 << 8)
    /// iOS14 limited Photo mode, will show collection footer view in ZLThumbnailViewController.
    /// Will go to system setting if clicked.
    @available(iOS 14, *)
    static let allowAuthTips = ADAssetSelectOptions(rawValue: 1 << 9)
    /// Allow access to the preview large image interface (That is, whether to allow access to the large image interface after clicking the thumbnail image).
    static let allowPreview = ADAssetSelectOptions(rawValue: 1 << 10)
    /// Allow toolbar in thumbnail controller
    static let thumbnailToolBar = ADAssetSelectOptions(rawValue: 1 << 11)
    /// Allow select full image.
    static let selectOriginal = ADAssetSelectOptions(rawValue: 1 << 12)
        
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let `default`: ADAssetSelectOptions = [.mixSelect,.selectOriginal,.slideSelect,.autoScroll,.selectAsLivePhoto,allowTakePhotoAsset,.thumbnailToolBar,.allowPreview]
    
    @available(iOS 14, *)
    public static let defaultiOS14: ADAssetSelectOptions = [.mixSelect,.selectOriginal,.slideSelect,.autoScroll,.selectAsLivePhoto,allowTakePhotoAsset,.allowAddAsset,.thumbnailToolBar,.allowAuthTips,.allowPreview]
}

public struct ADAssetBrowserOptions: OptionSet {
    public let rawValue: Int
    
    public static let selectOriginal = ADAssetBrowserOptions(rawValue: 1 << 0)
    public static let selectBrowser = ADAssetBrowserOptions(rawValue: 1 << 1)
    public static let selectIndex = ADAssetBrowserOptions(rawValue: 1 << 2)
    public static let fetchImage = ADAssetBrowserOptions(rawValue: 1 << 3)
    
    public static let `default`: ADAssetBrowserOptions = [.selectOriginal, .selectBrowser, .selectIndex, .fetchImage]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public enum ADPhotoSelectParams: Hashable {
    /// 最多选择数量
    case maxCount(max: Int?)
    /// 图片选择数量 最小 最大
    case imageCount(min: Int?, max:Int?)
    /// 视频数量 最小 最大
    case videoCount(min: Int?, max:Int?)
    /// 视频时长 最小 最大
    case videoTime(min: Int?, max: Int?)
    
    public func hash(into hasher: inout Hasher) {
        var value: Int = 0
        switch self {
        case .maxCount:
            value = 0
        case .imageCount:
            value = 1
        case .videoCount:
            value = 2
        case .videoTime:
            value = 3
        }
        hasher.combine(value)
    }
}

public class ADPhotoKitUI {
    
    public typealias Asset = (asset: PHAsset, image: UIImage?, error: Error?)
    /// return asset and is original image
    public typealias AssetSelectHandler = (([Asset],Bool) -> Void)
    public typealias AssetableSelectHandler = (([ADAssetBrowsable]) -> Void)
    public typealias AssetCancelHandler = (() -> Void)
    
    public class func imagePicker(present on: UIViewController,
                                    style: ADPickerStyle = .normal,
                                    assets: [PHAsset] = [],
                                    albumOpts: ADAlbumSelectOptions = .default,
                                    assetOpts: ADAssetSelectOptions = .default,
                                    browserOpts: ADAssetBrowserOptions = .default,
                                    params: Set<ADPhotoSelectParams> = [],
                                    selected: @escaping AssetSelectHandler,
                                    canceled: AssetCancelHandler? = nil) {
        let configuration = ADPhotoKitConfig(albumOpts: albumOpts, assetOpts: assetOpts, browserOpts: browserOpts, params: params, pickerSelect: selected, browserSelect: nil, canceled: canceled)
        if let asset = assets.randomElement() {
            configuration.selectMediaImage = ADAssetModel(asset: asset).type.isImage
        }
        if albumOpts.contains(.allowImage) {
            configuration.selectMediaImage = true
        }
        config = configuration
        if style == .normal {
            ADPhotoManager.cameraRollAlbum(options: albumOpts) { (model) in
                let album = ADAlbumListController(config: configuration)
                let nav = ADPhotoNavController(rootViewController: album)
                let thumbnail = ADThumbnailViewController(config: configuration, album: model, style: style, selects: assets)
                nav.modalPresentationStyle = .fullScreen
                nav.pushViewController(thumbnail, animated: false)
                on.present(nav, animated: true, completion: nil)
            }
        }else{
            ADPhotoManager.cameraRollAlbum(options: albumOpts) { (model) in
                let thumbnail = ADThumbnailViewController(config: configuration, album: model, style: style, selects: assets)
                let nav = ADPhotoNavController(rootViewController: thumbnail)
                nav.modalPresentationStyle = .fullScreen
                on.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    public class func assetBrowser(present on: UIViewController,
                                    assets:  [ADAssetBrowsable],
                                    index: Int? = nil,
                                    selects: [Int] = [],
                                    options: ADAssetBrowserOptions = .default,
                                    selected: @escaping AssetableSelectHandler,
                                    canceled: AssetCancelHandler? = nil) {
        let configuration = ADPhotoKitConfig(browserOpts: options, pickerSelect: nil, browserSelect: selected, canceled: canceled)
        config = configuration
        let browser = ADAssetBrowserController(model: configuration, assets: assets, index: index, selects: selects)
        let nav = ADPhotoNavController(rootViewController: browser)
        nav.modalPresentationStyle = .fullScreen
        on.present(nav, animated: true, completion: nil)
    }
    
    static var config: ADPhotoKitConfig!
}

extension ADPhotoKitUI {
    
    static func springAnimation() -> CAKeyframeAnimation {
        let animate = CAKeyframeAnimation(keyPath: "transform")
        animate.duration = 0.4
        animate.isRemovedOnCompletion = true
        animate.fillMode = .forwards
        
        animate.values = [CATransform3DMakeScale(0.7, 0.7, 1),
                          CATransform3DMakeScale(1.2, 1.2, 1),
                          CATransform3DMakeScale(0.8, 0.8, 1),
                          CATransform3DMakeScale(1, 1, 1)]
        return animate
    }
    
}

public class ADPhotoKitConfig {

    public let albumOpts: ADAlbumSelectOptions
    public let assetOpts: ADAssetSelectOptions
    public let browserOpts: ADAssetBrowserOptions
    public let params: ADThumbnailParams
    
    let pickerSelect: ADPhotoKitUI.AssetSelectHandler?
    let browserSelect: ADPhotoKitUI.AssetableSelectHandler?
    let canceled: ADPhotoKitUI.AssetCancelHandler?
    
    var selectMediaImage: Bool = false
    
    public var isOriginal: Bool = false
    
    let fetchImageQueue: OperationQueue = OperationQueue()
    
    init(albumOpts: ADAlbumSelectOptions = .default,
         assetOpts: ADAssetSelectOptions = .default,
         browserOpts: ADAssetBrowserOptions,
         params: Set<ADPhotoSelectParams> = [],
         pickerSelect: ADPhotoKitUI.AssetSelectHandler?,
         browserSelect: ADPhotoKitUI.AssetableSelectHandler?,
         canceled: ADPhotoKitUI.AssetCancelHandler?) {
        self.albumOpts = albumOpts
        self.assetOpts = assetOpts
        self.browserOpts = browserOpts
        self.pickerSelect = pickerSelect
        self.browserSelect = browserSelect
        self.canceled = canceled
        
        var value = ADThumbnailParams()
        for item in params {
            switch item {
            case let .maxCount(max):
                value.maxCount = max
            case let .imageCount(min, max):
                value.minImageCount = min
                value.maxImageCount = max
            case let .videoCount(min, max):
                value.minVideoCount = min
                value.maxVideoCount = max
            case let .videoTime(min, max):
                value.minVideoTime = min
                value.maxVideoTime = max
            }
        }
        self.params = value
        
        fetchImageQueue.maxConcurrentOperationCount = 3
    }
}

extension ADAssetListDataSource {
    
    func fetchSelectImages(original: Bool, asGif: Bool, completion: @escaping (()->Void)) {
        var hud = ADPhotoUIConfigurable.progressHUD()
        
        var timeout: Bool = false
        hud.timeoutBlock = {
            timeout = true
            ADPhotoKitUI.config.fetchImageQueue.cancelAllOperations()
        }
        
        hud.show(timeout: ADPhotoKitConfiguration.default.fetchTimeout)
        
        var result: [ADPhotoKitUI.Asset?] = Array(repeating: nil, count: selects.count)
        var operations: [Operation] = []
        for (i,item) in selects.enumerated() {
            let op = ADAssetOperation(model: item.asset, isOriginal: original, selectAsGif: asGif, progress: nil) { (asset) in
                result[i] = asset
            }
            operations.append(op)
        }
        
        DispatchQueue.main.async {
            ADPhotoKitUI.config.fetchImageQueue.addOperations(operations, waitUntilFinished: true)
            hud.hide()
            if !timeout {
                ADPhotoKitUI.config.pickerSelect?(result.compactMap { $0 }, original)
                completion()
            }
        }
    }
    
}
