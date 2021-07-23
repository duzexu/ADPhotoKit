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
    
    let model: PHAsset
    let isOriginal: Bool
    let selectAsGif: Bool
    
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
    
    init(model: PHAsset,
         isOriginal: Bool = false,
         selectAsGif: Bool = true,
         progress: ADPhotoManager.ADAssetProgressHandler? = nil,
         completion: @escaping ((ADPhotoKitUI.Asset) -> Void)) {
        self.model = model
        self.isOriginal = isOriginal
        self.selectAsGif = selectAsGif
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
        
        if model.isGif && selectAsGif {
            requestID = ADPhotoManager.fetch(for: model, type: .originImageData, progress: progress, completion: { [weak self] (data, info, _) in
                guard let strong = self else { return }
                if let d = data as? Data {
                    self?.completion((strong.model,KingfisherWrapper.image(data: d, options: .init()),nil))
                }else{
                    let error = info?[PHImageErrorKey] as? NSError
                    self?.completion((strong.model,nil,error))
                }
                self?.done()
            })
        }else{
            let size: CGSize? = isOriginal ? nil : model.browserSize
            requestID = ADPhotoManager.fetch(for: model, type: .image(size: size, synchronous: true), progress: progress, completion: { [weak self] (image, info, _) in
                guard let strong = self else { return }
                let error = info?[PHImageErrorKey] as? NSError
                self?.completion((strong.model,image as? UIImage,error))
                self?.done()
            })
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
