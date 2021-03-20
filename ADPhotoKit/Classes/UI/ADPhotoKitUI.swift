//
//  ADPhotoKitUI.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import Photos

public enum ADPhotoSelectParams {
    /// 图片选择数量 最小 最大
    case imageCount(min: Int?, max: Int?)
    /// 视频数量 最小 最大
    case videoCount(min: Int?, max:Int?)
    /// 视频时长 最小 最大
    case videoTime(min: Int?, max: Int?)
}

class ADPhotoKitInternal {
    let options: ADAlbumSelectOptions
    let params: [ADPhotoSelectParams]
    let selected: ADPhotoKitUI.AssetSelectHandler
    let canceled: ADPhotoKitUI.AssetCancelHandler?
    let error: ADPhotoKitUI.AssetRequestError?
    
    init(options: ADAlbumSelectOptions,
         params: [ADPhotoSelectParams],
         selected: @escaping ADPhotoKitUI.AssetSelectHandler,
         canceled: ADPhotoKitUI.AssetCancelHandler? = nil,
         error: ADPhotoKitUI.AssetRequestError? = nil) {
        self.options = options
        self.params = params
        self.selected = selected
        self.canceled = canceled
        self.error = error
    }
}

public class ADPhotoKitUI {
    
    public typealias Asset = (asset: PHAsset, image: UIImage)
    public typealias AssetSelectHandler = (([Asset],Bool) -> Void)
    public typealias AssetRequestError = ((PHAsset,Error) -> Void)
    public typealias AssetCancelHandler = (() -> Void)
    
    public class func imagePicker(present on: UIViewController,
                                    assets:  [PHAsset] = [],
                                    options: ADAlbumSelectOptions = .default,
                                    params: [ADPhotoSelectParams] = [],
                                    selected: @escaping AssetSelectHandler,
                                    canceled: AssetCancelHandler? = nil,
                                    error: AssetRequestError? = nil) {
        let `internal` = ADPhotoKitInternal(options: options, params: params, selected: selected, canceled: canceled, error: error)
        ADPhotoManager.cameraRollAlbum(options: options) { (model) in
            let album = ADAlbumListController(options: options)
            let nav = ADPhotoNavController(rootViewController: album, model: `internal`)
            let thumbnail = ADThumbnailViewController(options: options, albumList: model)
            nav.pushViewController(thumbnail, animated: false)
            on.present(nav, animated: true, completion: nil)
        }
    }
    
}
