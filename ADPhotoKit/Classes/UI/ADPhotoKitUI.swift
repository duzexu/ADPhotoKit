//
//  ADPhotoKitUI.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import Photos

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
    
    public typealias Asset = (asset: PHAsset, image: UIImage)
    public typealias AssetSelectHandler = (([Asset],Bool) -> Void)
    public typealias AssetRequestError = ((PHAsset,Error) -> Void)
    public typealias AssetCancelHandler = (() -> Void)
    
    public class func imagePicker(present on: UIViewController,
                                    assets:  [PHAsset] = [],
                                    albumOpts: ADAlbumSelectOptions = .default,
                                    assetOpts: ADAssetSelectOptions = .default,
                                    params: Set<ADPhotoSelectParams> = [],
                                    selected: @escaping AssetSelectHandler,
                                    canceled: AssetCancelHandler? = nil,
                                    error: AssetRequestError? = nil) {
        let `internal` = ADPhotoKitPickerInternal(assets: assets, albumOpts: albumOpts, assetOpts: assetOpts, params: params, selected: selected, canceled: canceled, error: error)
        internalPickerModel = `internal`
        ADPhotoManager.cameraRollAlbum(options: albumOpts) { (model) in
            let album = ADAlbumListController(model: `internal`)
            let nav = ADPhotoNavController(rootViewController: album)
            let thumbnail = ADThumbnailViewController(model: `internal`, albumList: model)
            nav.modalPresentationStyle = .fullScreen
            nav.pushViewController(thumbnail, animated: false)
            on.present(nav, animated: true, completion: nil)
        }
    }
    
    public class func assetBrowser(present on: UIViewController,
                                    assets:  [ADAssetBrowsable],
                                    index: Int = 0,
                                    selects: [Int] = [],
                                    options: ADAssetBrowserOptions = .default,
                                    selected: @escaping AssetSelectHandler,
                                    canceled: AssetCancelHandler? = nil) {
        internalBrowserModel = ADPhotoKitBrowserInternal(assets: assets, options: options, selected: selected, canceled: canceled)
        let browser = ADAssetBrowserController(assets: assets, index: index, selects: selects)
        let nav = ADPhotoNavController(rootViewController: browser)
        nav.modalPresentationStyle = .fullScreen
        on.present(nav, animated: true, completion: nil)
    }
    
    static var internalPickerModel: ADPhotoKitPickerInternal?
    static var internalBrowserModel: ADPhotoKitBrowserInternal?
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

class ADPhotoKitPickerInternal {
    var assets: [PHAsset]
    let albumOpts: ADAlbumSelectOptions
    let assetOpts: ADAssetSelectOptions
    let params: ADThumbnailParams
    let selected: ADPhotoKitUI.AssetSelectHandler
    let canceled: ADPhotoKitUI.AssetCancelHandler?
    let error: ADPhotoKitUI.AssetRequestError?
        
    init(assets: [PHAsset],
         albumOpts: ADAlbumSelectOptions,
         assetOpts: ADAssetSelectOptions,
         params: Set<ADPhotoSelectParams>,
         selected: @escaping ADPhotoKitUI.AssetSelectHandler,
         canceled: ADPhotoKitUI.AssetCancelHandler?,
         error: ADPhotoKitUI.AssetRequestError?) {
        self.assets = assets
        self.albumOpts = albumOpts
        self.assetOpts = assetOpts
        self.selected = selected
        self.canceled = canceled
        self.error = error
        
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
    }
}

extension ADPhotoKitPickerInternal {
    
    var selectMediaImage: Bool {
        if let asset = assets.randomElement() {
            return ADAssetModel(asset: asset).type.isImage
        }
        if albumOpts.contains(.allowImage) {
            return true
        }
        return false
    }
    
}

class ADPhotoKitBrowserInternal {
    
    var assets: [ADAssetBrowsable]
    let options: ADAssetBrowserOptions
    let selected: ADPhotoKitUI.AssetSelectHandler
    let canceled: ADPhotoKitUI.AssetCancelHandler?

    init(assets: [ADAssetBrowsable],
         options: ADAssetBrowserOptions,
         selected: @escaping ADPhotoKitUI.AssetSelectHandler,
         canceled: ADPhotoKitUI.AssetCancelHandler?) {
        self.assets = assets
        self.options = options
        self.selected = selected
        self.canceled = canceled
    }
}
