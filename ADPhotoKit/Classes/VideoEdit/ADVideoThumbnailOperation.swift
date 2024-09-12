//
//  ADVideoThumbnilOperation.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/10.
//

import Foundation
import AVFoundation

class ADVideoThumbnailOperation: Operation {
    
    private let generator: AVAssetImageGenerator
    private let time: CMTime
    private let completion: (UIImage?) -> Void
    
    init(generator: AVAssetImageGenerator, time: CMTime, completion: @escaping ((UIImage?) -> Void)) {
        self.generator = generator
        self.time = time
        self.completion = completion
        super.init()
    }
    
    override func start() {
        if isCancelled {
            done()
            return
        }
        _isExecuting = true
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { [weak self] _, cgImage, _, result, error in
            if result == .succeeded, let cg = cgImage {
                let image = UIImage(cgImage: cg)
                DispatchQueue.main.async {
                    self?.completion(image)
                    self?.done()
                }
            }else{
                self?.completion(nil)
                self?.done()
            }
        }
    }
    
    private var _isFinished: Bool = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    
    private var _isExecuting: Bool = false {
        willSet { willChangeValue(forKey: "isExecuting") }
        didSet { didChangeValue(forKey: "isExecuting") }
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
