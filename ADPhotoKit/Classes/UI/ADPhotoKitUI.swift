//
//  ADPhotoKitUI.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import Photos

public enum ADPhotoSelectParams: Hashable {
    /// 图片选择数量 最小 最大
    case maxCount(max: Int?)
    /// 视频数量 最小 最大
    case videoCount(min: Int?, max:Int?)
    /// 视频时长 最小 最大
    case videoTime(min: Int?, max: Int?)
    
    public func hash(into hasher: inout Hasher) {
        var value: Int = 0
        switch self {
        case .maxCount:
            value = 0
        case .videoCount:
            value = 1
        case .videoTime:
            value = 2
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
        let `internal` = ADPhotoKitInternal(assets: assets, albumOpts: albumOpts, assetOpts: assetOpts, params: params, selected: selected, canceled: canceled, error: error)
        internalModel = `internal`
        ADPhotoManager.cameraRollAlbum(options: albumOpts) { (model) in
            let album = ADAlbumListController(model: `internal`)
            let nav = ADPhotoNavController(rootViewController: album, model: `internal`)
            let thumbnail = ADThumbnailViewController(model: `internal`, albumList: model)
            nav.pushViewController(thumbnail, animated: false)
            on.present(nav, animated: true, completion: nil)
        }
    }
    
    static var internalModel: ADPhotoKitInternal?
}

class ADPhotoKitInternal {
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
         canceled: ADPhotoKitUI.AssetCancelHandler? = nil,
         error: ADPhotoKitUI.AssetRequestError? = nil) {
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

extension ADPhotoKitInternal {
    
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
