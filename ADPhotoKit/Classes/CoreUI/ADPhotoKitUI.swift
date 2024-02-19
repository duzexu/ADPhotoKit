//
//  ADPhotoKitUI.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation
import UIKit
import Photos
import SwiftUI

/// Style to display picker.
public enum ADPickerStyle {
    /// The display relationship between the album list and the thumbnail interface is push.
    case normal
    /// The album list is embedded in the navigation of the thumbnail interface, click the drop-down display.
    case embed
}

/// Asset fetch result.
public struct ADAssetResult {
    /// Image fetch with asset. It's `nil` if `browserOpts` not contain `.fetchImage` or error occur when fetching.
    public var image: UIImage?
    
    #if Module_ImageEdit
    /// Image edited info. It can be `nil` if image is not edit.
    public var imageEditInfo: ADImageEditInfo?
    #endif
}

/// Parsing the input `Set<ADPhotoSelectParams>` to `ADConstraintParams` and pass through the internal methods.
public struct ADConstraintParams {
    
    /// Limit the max count you can select. Set `nil` means no limit. Default is no limit.
    public fileprivate(set) var maxCount: Int?
    
    /// Limit the min image count you can select. Set `nil` means no limit. Default is no limit.
    public fileprivate(set) var minImageCount: Int?
    /// Limit the max image count you can select. Set `nil` means no limit. Default is no limit.
    public fileprivate(set) var maxImageCount: Int?
    
    /// Limit the min video count you can select. Set `nil` means no limit. Default is no limit.
    public fileprivate(set) var minVideoCount: Int?
    /// Limit the max video count you can select. Set `nil` means no limit. Default is no limit.
    public fileprivate(set) var maxVideoCount: Int?
    
    /// Limit the min video time you can select. Set `nil` means no limit. Default is no limit.
    public fileprivate(set) var minVideoTime: Int?
    /// Limit the max video time you can select. Set `nil` means no limit. Default is no limit.
    public fileprivate(set) var maxVideoTime: Int?
    
    /// Limit the min video time you can record. Set `nil` means no limit. Default is no limit.
    public fileprivate(set) var minRecordTime: Int?
    /// Limit the max video time you can record. Set `nil` means no limit. Default is no limit.
    public fileprivate(set) var maxRecordTime: Int?
}

extension ADSelectAssetModel {
    func result(with image: UIImage?) -> ADAssetResult? {
        #if Module_ImageEdit
        return ADAssetResult(image: image, imageEditInfo: imageEditInfo)
        #else
        if let img = image {
            return ADAssetResult(image: img)
        }else{
            return nil
        }
        #endif
    }
}

/// Main class of ADPhotoKit UI. It provide methods to show asset picker or asset browser.
public class ADPhotoKitUI {
    
    /// Wrap of select asset.
    /// - Parameters:
    ///     - asset: Asset select from system.
    ///     - result: Result fetch with asset. It's `nil` if not contain `ImageEdit` subspec and `browserOpts` not contain `.fetchImage`.
    ///     - error: Error info when fetch error. It's not `nil` when error occur when fetching.
    /// - Note: If `browserOpts` not contain `.fetchImage`, fetch will not perform and asset will return immediately, `result.image` and `error` will be `nil`.
    public typealias Asset = (asset: PHAsset, result: ADAssetResult?, error: Error?)
    /// Return select assets and if original or not.
    public typealias AssetSelectHandler = (([Asset],Bool) -> Void)
    /// Return browsable asset array.
    public typealias BrowsableSelectHandler = (([ADAssetBrowsable]) -> Void)
    /// Cancel select.
    public typealias AssetCancelHandler = (() -> Void)
    
    /// Show picker with select assets.
    /// - Parameters:
    ///   - on: The controller to show picker.
    ///   - style: Style to display picker.
    ///   - modelsSel: Asset models have been selected.
    ///   - albumOpts: Options to limit album type and order. It is `ADAlbumSelectOptions.default` by default.
    ///   - assetOpts: Options to control the asset select condition and ui. It is `ADAssetSelectOptions.default` by default.
    ///   - browserOpts: Options to control browser controller. It is `ADAssetBrowserOptions.default` by default.
    ///   - params: Params to control the asset select condition.
    ///   - selected: Called after selection finish.
    ///   - canceled: Called when cancel select.
    public class func imagePicker(present on: UIViewController,
                                    style: ADPickerStyle = .normal,
                                    modelsSel: [ADSelectAssetModel] = [],
                                    albumOpts: ADAlbumSelectOptions = .default,
                                    assetOpts: ADAssetSelectOptions = .default,
                                    browserOpts: ADAssetBrowserOptions = .default,
                                    params: Set<ADPhotoSelectParams> = [],
                                    selected: @escaping AssetSelectHandler,
                                    canceled: AssetCancelHandler? = nil) {
        let configuration = ADPhotoKitConfig(albumOpts: albumOpts, assetOpts: assetOpts, browserOpts: browserOpts, params: params, pickerSelect: selected, browserSelect: nil, canceled: canceled)
        if let asset = modelsSel.randomElement() {
            configuration.selectMediaImage = ADAssetModel(asset: asset.asset).type.isImage
        }
        if style == .normal {
            ADPhotoManager.cameraRollAlbum(options: albumOpts) { (model) in
                let album = ADAlbumListController(config: configuration, selects: modelsSel)
                let nav = ADPhotoNavController(rootViewController: album)
                album.pushThumbnail(with: model, style: style, animated: false)
                nav.modalPresentationStyle = .fullScreen
                on.present(nav, animated: true, completion: nil)
            }
        }else{
            ADPhotoManager.cameraRollAlbum(options: albumOpts) { (model) in
                let thumbnail = ADThumbnailViewController(config: configuration, album: model, style: style, selects: modelsSel)
                let nav = ADPhotoNavController(rootViewController: thumbnail)
                nav.modalPresentationStyle = .fullScreen
                on.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    /// Show controller to browser and select assets.
    /// - Parameters:
    ///   - on: The controller to show browser.
    ///   - assets: Assets to browser.
    ///   - selects: Assets heave been selected.
    ///   - index: Current browser asset index.
    ///   - options: Options to control browser controller. It is `ADAssetBrowserOptions.default` by default.
    ///   - selected: Called after selection finish.
    ///   - canceled: Called when cancel select.
    public class func assetBrowser(present on: UIViewController,
                                    assets:  [ADAssetBrowsable],
                                    selects: [ADAssetBrowsable] = [],
                                    index: Int? = nil,
                                    options: ADAssetBrowserOptions = .default,
                                    selected: @escaping BrowsableSelectHandler,
                                    canceled: AssetCancelHandler? = nil) {
        if assets.count == 0 {
            fatalError("assets count must>0")
        }
        let configuration = ADPhotoKitConfig(browserOpts: options, pickerSelect: nil, browserSelect: selected, canceled: canceled)
        let browser = ADAssetBrowserController(config: configuration, assets: assets, selects: selects, index: index)
        let nav = ADPhotoNavController(rootViewController: browser)
        nav.modalPresentationStyle = .fullScreen
        on.present(nav, animated: true, completion: nil)
    }
    
}

@available(iOS 13.0, *)
extension View {
    
    /// Show picker with select assets.
    /// - Parameters:
    ///   - isPresented: Present when changes to true.
    ///   - style: Style to display picker.
    ///   - modelsSel: Asset models have been selected.
    ///   - albumOpts: Options to limit album type and order. It is `ADAlbumSelectOptions.default` by default.
    ///   - assetOpts: Options to control the asset select condition and ui. It is `ADAssetSelectOptions.default` by default.
    ///   - browserOpts: Options to control browser controller. It is `ADAssetBrowserOptions.default` by default.
    ///   - params: Params to control the asset select condition.
    ///   - selected: Called after selection finish.
    ///   - canceled: Called when cancel select.
    public func imagePicker(isPresented: Binding<Bool>,
                            style: ADPickerStyle = .normal,
                            modelsSel: [ADSelectAssetModel] = [],
                            albumOpts: ADAlbumSelectOptions = .default,
                            assetOpts: ADAssetSelectOptions = .default,
                            browserOpts: ADAssetBrowserOptions = .default,
                            params: Set<ADPhotoSelectParams> = [],
                            selected: @escaping ADPhotoKitUI.AssetSelectHandler,
                            canceled: ADPhotoKitUI.AssetCancelHandler? = nil) -> some View {
        let configuration = ADPhotoKitConfig(albumOpts: albumOpts, assetOpts: assetOpts, browserOpts: browserOpts, params: params, pickerSelect: selected, browserSelect: nil, canceled: canceled)
        if let asset = modelsSel.randomElement() {
            configuration.selectMediaImage = ADAssetModel(asset: asset.asset).type.isImage
        }
        if #available(iOS 14.0, *) {
            return fullScreenCover(isPresented: isPresented) {
                
            } content: {
                ADAlbumListSwiftUIView(style: style, configuration: configuration, models: modelsSel)
            }
        } else {
            return sheet(isPresented: isPresented, onDismiss: {
                
            }, content: {
                ADAlbumListSwiftUIView(style: style, configuration: configuration, models: modelsSel)
            })
        }
    }
    
    /// Show controller to browser and select assets.
    /// - Parameters:
    ///   - isPresented: Present when changes to true.
    ///   - assets: Assets to browser.
    ///   - selects: Assets heave been selected.
    ///   - index: Current browser asset index.
    ///   - options: Options to control browser controller. It is `ADAssetBrowserOptions.default` by default.
    ///   - selected: Called after selection finish.
    ///   - canceled: Called when cancel select.
    public func assetBrowser(isPresented: Binding<Bool>,
                             assets:  [ADAssetBrowsable],
                             selects: [ADAssetBrowsable] = [],
                             index: Int? = nil,
                             options: ADAssetBrowserOptions = .default,
                             selected: @escaping ADPhotoKitUI.BrowsableSelectHandler,
                             canceled: ADPhotoKitUI.AssetCancelHandler? = nil) -> some View {
        let configuration = ADPhotoKitConfig(browserOpts: options, pickerSelect: nil, browserSelect: selected, canceled: canceled)
        if #available(iOS 14.0, *) {
            return fullScreenCover(isPresented: isPresented) {
                
            } content: {
                ADAssetBrowserSwiftUIView(configuration: configuration, assets: assets, selects: selects, index: index)
            }
        } else {
            return sheet(isPresented: isPresented, onDismiss: {
                
            }, content: {
                ADAssetBrowserSwiftUIView(configuration: configuration, assets: assets, selects: selects, index: index)
            })
        }
    }
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

/// Parsing the input config to `ADPhotoKitConfig` and pass through the internal methods.
public class ADPhotoKitConfig {

    public let albumOpts: ADAlbumSelectOptions
    public let assetOpts: ADAssetSelectOptions
    public let browserOpts: ADAssetBrowserOptions
    public let params: ADConstraintParams
    
    let pickerSelect: ADPhotoKitUI.AssetSelectHandler?
    let browserSelect: ADPhotoKitUI.BrowsableSelectHandler?
    let canceled: ADPhotoKitUI.AssetCancelHandler?
    
    var selectMediaImage: Bool?
    
    var isOriginal: Bool = false
    
    let fetchImageQueue: OperationQueue = OperationQueue()
    
    init(albumOpts: ADAlbumSelectOptions = .default,
         assetOpts: ADAssetSelectOptions = .default,
         browserOpts: ADAssetBrowserOptions,
         params: Set<ADPhotoSelectParams> = [],
         pickerSelect: ADPhotoKitUI.AssetSelectHandler?,
         browserSelect: ADPhotoKitUI.BrowsableSelectHandler?,
         canceled: ADPhotoKitUI.AssetCancelHandler?) {
        self.albumOpts = albumOpts
        self.assetOpts = assetOpts
        self.browserOpts = browserOpts
        self.pickerSelect = pickerSelect
        self.browserSelect = browserSelect
        self.canceled = canceled
        
        var value = ADConstraintParams()
        for item in params {
            switch item {
            case let .maxCount(max):
                value.maxCount = max
            case let .imageCount(min, max):
                value.minImageCount = min
                value.maxImageCount = max
                if let l = min, let r = max {
                    assert(l <= r, "min count must less than or equal max")
                }
            case let .videoCount(min, max):
                value.minVideoCount = min
                value.maxVideoCount = max
                if let l = min, let r = max {
                    assert(l <= r, "min count must less than or equal max")
                }
            case let .videoTime(min, max):
                value.minVideoTime = min
                value.maxVideoTime = max
                if let l = min, let r = max {
                    assert(l <= r, "min time must less than or equal max")
                }
            case let .recordTime(min, max):
                value.minRecordTime = min
                value.maxRecordTime = max
                if let l = min, let r = max {
                    assert(l <= r, "min time must less than or equal max")
                }
            }
        }
        self.params = value
        
        fetchImageQueue.maxConcurrentOperationCount = 3
    }
}

extension ADAssetListDataSource {
    
    func fetchSelectImages(original: Bool, asGif: Bool, inQueue: OperationQueue, completion: @escaping (([ADPhotoKitUI.Asset])->Void)) {
        let hud = ADProgress.progressHUD()
        
        var timeout: Bool = false
        hud.timeoutBlock = {
            timeout = true
            inQueue.cancelAllOperations()
        }
        
        hud.show(timeout: ADPhotoKitConfiguration.default.fetchTimeout)
        
        var result: [ADPhotoKitUI.Asset?] = Array(repeating: nil, count: selects.count)
        var operations: [Operation] = []
        for (i,item) in selects.enumerated() {
            let op = ADAssetOperation(model: item, isOriginal: original, selectAsGif: asGif, progress: nil) { (asset) in
                result[i] = asset
            }
            operations.append(op)
        }
        
        DispatchQueue.main.async {
            inQueue.addOperations(operations, waitUntilFinished: true)
            hud.hide()
            if !timeout {
                completion(result.compactMap { $0 })
            }else{
                completion([])
            }
        }
    }
    
}
