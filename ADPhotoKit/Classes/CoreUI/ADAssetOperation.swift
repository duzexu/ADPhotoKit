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
    
    struct ImageOptConfig {
        let isOriginal: Bool
        let selectAsGif: Bool
    }
    
    struct VideoOptConfig {
    }
    
    let model: ADSelectAssetModel
    let imageConfig: ImageOptConfig?
    let videoConfig: VideoOptConfig?
    let progress: ADPhotoManager.ADAssetProgressHandler?
    let completion: ((ADPhotoKitUI.Asset) -> Void)
    
    private var requestID: PHImageRequestID?
    
    private var _isFinished: Bool = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    
    private var _isExecuting: Bool = false {
        willSet { willChangeValue(forKey: "isExecuting") }
        didSet { didChangeValue(forKey: "isExecuting") }
    }
    
    init(model: ADSelectAssetModel,
         imageConfig: ImageOptConfig? = nil,
         videoConfig: VideoOptConfig? = nil,
         progress: ADPhotoManager.ADAssetProgressHandler? = nil,
         completion: @escaping ((ADPhotoKitUI.Asset) -> Void)) {
        self.model = model
        self.imageConfig = imageConfig
        self.videoConfig = videoConfig
        self.progress = progress
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
            
        }else{
            if model.asset.isGif && imageConfig?.selectAsGif == true {
                requestID = ADPhotoManager.fetch(for: model.asset, type: .originImageData, progress: progress, completion: { [weak self] (data, info, _) in
                    guard let strong = self else { return }
                    if let d = data as? Data {
                        self?.completion((strong.model.asset,strong.model.result(with: KingfisherWrapper.image(data: d, options: .init())),nil))
                    }else{
                        let error = info?[PHImageErrorKey] as? NSError
                        self?.completion((strong.model.asset,strong.model.result(with: nil),error))
                    }
                    self?.done()
                })
            }else{
                let size: CGSize? = imageConfig?.isOriginal == true ? nil : model.asset.browserSize
                requestID = ADPhotoManager.fetch(for: model.asset, type: .image(size: size, synchronous: true), progress: progress, completion: { [weak self] (image, info, _) in
                    guard let strong = self else { return }
                    let error = info?[PHImageErrorKey] as? NSError
                    self?.completion((strong.model.asset,strong.model.result(with: image as? UIImage),error))
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
