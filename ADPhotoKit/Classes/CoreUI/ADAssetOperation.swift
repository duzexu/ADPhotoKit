//
//  ADAssetOperation.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/15.
//

import UIKit
import Photos
import Kingfisher

class ADAssetOperation: Operation {
    
    struct OptConfig {
        let isOriginal: Bool
        let selectAsGif: Bool
        let saveEditVideo: Bool
    }
    
    let model: ADSelectAssetModel
    let config: OptConfig
    let completion: ((ADPhotoKitUI.Asset) -> Void)
    
    private var requestID: PHImageRequestID?
    private var exporter: ADVideoExporter?
    
    private var _isFinished: Bool = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    
    private var _isExecuting: Bool = false {
        willSet { willChangeValue(forKey: "isExecuting") }
        didSet { didChangeValue(forKey: "isExecuting") }
    }
    
    init(model: ADSelectAssetModel,
         config: OptConfig,
         completion: @escaping ((ADPhotoKitUI.Asset) -> Void)) {
        self.model = model
        self.config = config
        self.completion = completion
        super.init()
    }
    
    override func start() {
        if isCancelled {
            done()
            return
        }
        
        _isExecuting = true
        
        if model.asset.mediaType == .video {
            #if Module_VideoEdit
            if model.videoEditInfo != nil && model.videoEditInfo!.editUrl == nil {
                let type = ADPhotoKitConfiguration.default.customVideoPlayable ?? ADVideoPlayerView.self
                let exporter = type.exporter(from: model.videoEditInfo!.originAsset, editInfo: model.videoEditInfo!)
                let path = NSTemporaryDirectory().appending("\(UUID().uuidString).mp4")
                exporter.export(to: path) { [weak self] url, error in
                    guard let strong = self else { return }
                    if let url = url {
                        strong.model.videoEditInfo!.editUrl = url
                        if strong.config.saveEditVideo {
                            ADPhotoManager.saveVideoToAlbum(url: url, completion: nil)
                        }
                    }
                    self?.completion((strong.model.asset,strong.model.result(asset: strong.model.videoEditInfo!.originAsset),nil))
                    self?.done()
                }
                self.exporter = exporter
                return
            }
            #endif
            requestID = ADPhotoManager.fetch(for: model.asset, type: .assert, progress: nil, completion: { [weak self] (data, info, _) in
                guard let strong = self else { return }
                let error = info?[PHImageErrorKey] as? NSError
                self?.completion((strong.model.asset,strong.model.result(asset: data as? AVAsset),error))
                self?.done()
            })
        }else{
            if model.asset.isGif && config.selectAsGif {
                requestID = ADPhotoManager.fetch(for: model.asset, type: .originImageData, progress: nil, completion: { [weak self] (data, info, _) in
                    guard let strong = self else { return }
                    if let d = data as? Data {
                        self?.completion((strong.model.asset,strong.model.result(image: KingfisherWrapper.image(data: d, options: .init())),nil))
                    }else{
                        let error = info?[PHImageErrorKey] as? NSError
                        self?.completion((strong.model.asset,strong.model.result(image: nil),error))
                    }
                    self?.done()
                })
            }else{
                #if Module_ImageEdit
                if !config.isOriginal && model.imageEditInfo?.originImg != nil {
                    completion((model.asset,model.result(image: model.imageEditInfo?.originImg),nil))
                    done()
                    return
                }
                #endif
                let size: CGSize? = config.isOriginal ? nil : model.asset.browserSize
                requestID = ADPhotoManager.fetch(for: model.asset, type: .image(size: size, synchronous: true), progress: nil, completion: { [weak self] (image, info, _) in
                    guard let strong = self else { return }
                    let error = info?[PHImageErrorKey] as? NSError
                    self?.completion((strong.model.asset,strong.model.result(image: image as? UIImage),error))
                    self?.done()
                })
            }
        }
    }
    
    private func done() {
        guard !isFinished else {
            return
        }
        if isExecuting {
            _isExecuting = false
        }
        if !isFinished {
            _isFinished = true
        }
    }
    
    override func cancel() {
        guard !isFinished else {
            return
        }
        super.cancel()
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        if isExecuting {
            _isExecuting = false
        }
        if !isFinished {
            _isFinished = true
        }
    }
    
    override var isFinished: Bool {
        return _isFinished
    }
    
    override var isExecuting: Bool {
        return _isExecuting
    }
    
    override var isConcurrent: Bool {
        return true
    }
    
    override var isAsynchronous: Bool {
        return true
    }
}
