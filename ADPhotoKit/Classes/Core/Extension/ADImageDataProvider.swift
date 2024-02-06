//
//  ADImageDataProvider.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/5.
//

import Foundation
import UIKit
import Kingfisher
import Photos
#if canImport(MobileCoreServices)
import MobileCoreServices
#else
import CoreServices
#endif

/// PHAsset image loading error.
enum ADImageDataProviderError: Error {
    case fetchError
    case userCancelled
    case invalidImage
}

/// Kingfisher's ImageDataProvider to load image from `PHAsset`.
public class PHAssetImageDataProvider: ImageDataProvider {
    
    public var cacheKey: String {
        if let s = size {
            return "com.adphotokit.phasset_" + asset.localIdentifier + "_\(s.width)*\(s.height)"
        }
        return "com.adphotokit.phasset_" + asset.localIdentifier
    }
    
    let asset: PHAsset
    let size: CGSize?
    let progress: ((String,Double)->Void)?
    
    private var requestID: PHImageRequestID?
    
    /// Creates an image data provider by supplying the target local file URL.
    /// - Parameters:
    ///   - asset: PHAsset from photo library.
    ///   - size: Image thumbnail size, `nil` if fetch origin image data.
    ///   - progress: Image loading progress.
    public init(asset: PHAsset, size: CGSize? = nil, progress: ((String,Double)->Void)? = nil) {
        self.asset = asset
        self.size = size
        self.progress = progress
    }
    
    deinit {
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
        }
    }
    
    public func data(handler: @escaping (Result<Data, Error>) -> Void) {
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        if let s = size {
            requestID = ADPhotoManager.fetch(for: asset, type: .image(size: s, synchronous: true), progress: { [weak self] (pro, _, _, _) in
                guard let strong = self else { return }
                self?.progress?(strong.asset.localIdentifier,pro)
            }, completion: { (image, info, _) in
                if let img = image as? UIImage {
                    handler(.success(img.pngData()!))
                }else{
                    let error: Error = ((info?[PHImageErrorKey]) as? Error) ?? ADImageDataProviderError.fetchError
                    handler(.failure(error))
                }
            })
        }else{
            requestID = ADPhotoManager.fetch(for: asset, type: .originImageData, progress: { [weak self] (pro, _, _, _) in
                guard let strong = self else { return }
                self?.progress?(strong.asset.localIdentifier,pro)
            }, completion: { (data, info, _) in
                if let d = data as? Data {
                    handler(.success(d))
                }else{
                    let error: Error = ((info?[PHImageErrorKey]) as? Error) ?? ADImageDataProviderError.fetchError
                    handler(.failure(error))
                }
            })
        }
    }
    
}

/// Kingfisher's ImageDataProvider to load image from `ADAsset`.
public class ADAssetImageDataProvider: ImageDataProvider {
    public var cacheKey: String {
        var key = "com.adphotokit.phasset_" + asset.identifier
        if let s = size {
            key = key + "_\(s.width)*\(s.height)"
        }
        key = key + "_\(time.seconds)"
        return key
    }
    
    let asset: ADAsset
    let size: CGSize?
    let time: CMTime!
    let progress: ((String,Double)->Void)?
    
    private var requestID: PHImageRequestID?
    private var task: DownloadTask?
    
    /// Creates an image data provider by supplying the target local file URL.
    /// - Parameters:
    ///   - asset: PHAsset from photo library.
    ///   - size: Image thumbnail size, `nil` if fetch origin image data.
    ///   - progress: Image loading progress.
    ///   - time: Time used to generate image for video asset.
    public init(asset: ADAsset, size: CGSize? = nil, time: CMTime = .zero, progress: ((String,Double)->Void)? = nil) {
        self.asset = asset
        self.size = size
        self.time = time
        self.progress = progress
    }
    
    deinit {
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        if let t = task {
            t.cancel()
        }
    }
    
    public func data(handler: @escaping (Result<Data, Error>) -> Void) {
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        if let t = task {
            t.cancel()
        }
        switch asset {
        case let .image(source):
            switch source {
            case let .network(url):
                task = KingfisherManager.shared.downloader.downloadImage(with: url) { [weak self] receivedSize, totalSize in
                    guard let strong = self else { return }
                    self?.progress?(strong.asset.identifier,Double(receivedSize)/Double(totalSize))
                } completionHandler: { result in
                    switch result {
                    case let .success(r):
                        handler(.success(r.originalData))
                    case let .failure(e):
                        handler(.failure(e))
                    }
                }
            case let .album(asset):
                if let s = size {
                    requestID = ADPhotoManager.fetch(for: asset, type: .image(size: s, synchronous: true), progress: { [weak self] (pro, _, _, _) in
                        guard let strong = self else { return }
                        self?.progress?(strong.asset.identifier,pro)
                    }, completion: { (image, info, _) in
                        if let img = image as? UIImage, let data = img.pngData() {
                            handler(.success(data))
                        }else{
                            let error: Error = ((info?[PHImageErrorKey]) as? Error) ?? ADImageDataProviderError.fetchError
                            handler(.failure(error))
                        }
                    })
                }else{
                    requestID = ADPhotoManager.fetch(for: asset, type: .originImageData, progress: { [weak self] (pro, _, _, _) in
                        guard let strong = self else { return }
                        self?.progress?(strong.asset.identifier,pro)
                    }, completion: { (data, info, _) in
                        if let d = data as? Data {
                            handler(.success(d))
                        }else{
                            let error: Error = ((info?[PHImageErrorKey]) as? Error) ?? ADImageDataProviderError.fetchError
                            handler(.failure(error))
                        }
                    })
                }
            case let .local(image, _):
                if let data = image.pngData() {
                    handler(.success(data))
                }else{
                    handler(.failure(ADImageDataProviderError.invalidImage))
                }
            }
        case let .video(source):
            switch source {
            case let .network(url):
                let assert = AVURLAsset(url: url)
                let generator = AVAssetImageGenerator(asset: assert)
                generator.appliesPreferredTrackTransform = true
                generator.apertureMode = .encodedPixels
                generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) {
                    (requestedTime, image, imageTime, result, error) in
                    if let error = error {
                        handler(.failure(error))
                        return
                    }

                    if result == .cancelled {
                        handler(.failure(ADImageDataProviderError.userCancelled))
                        return
                    }

                    guard let cgImage = image, let data = cgImage.jpegData else {
                        handler(.failure(ADImageDataProviderError.invalidImage))
                        return
                    }

                    handler(.success(data))
                }
            case let .album(asset):
                requestID = ADPhotoManager.fetch(for: asset, type: .assert) { [weak self] (pro, _, _, _) in
                    guard let strong = self else { return }
                    self?.progress?(strong.asset.identifier,pro)
                } completion: { [weak self] (asset, info, _) in
                    guard let strong = self else { return }
                    if let av = asset as? AVAsset {
                        let generator = AVAssetImageGenerator(asset: av)
                        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: strong.time)]) {
                            (requestedTime, image, imageTime, result, error) in
                            if let error = error {
                                handler(.failure(error))
                                return
                            }

                            if result == .cancelled {
                                handler(.failure(ADImageDataProviderError.userCancelled))
                                return
                            }

                            guard let cgImage = image, let data = cgImage.jpegData else {
                                handler(.failure(ADImageDataProviderError.invalidImage))
                                return
                            }

                            handler(.success(data))
                        }
                    }else{
                        handler(.failure(ADImageDataProviderError.fetchError))
                    }
                }
            case let .local(url):
                let assert = AVURLAsset(url: url)
                let generator = AVAssetImageGenerator(asset: assert)
                generator.appliesPreferredTrackTransform = true
                generator.apertureMode = .encodedPixels
                generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) {
                    (requestedTime, image, imageTime, result, error) in
                    if let error = error {
                        handler(.failure(error))
                        return
                    }

                    if result == .cancelled {
                        handler(.failure(ADImageDataProviderError.userCancelled))
                        return
                    }

                    guard let cgImage = image, let data = cgImage.jpegData else {
                        handler(.failure(ADImageDataProviderError.invalidImage))
                        return
                    }

                    handler(.success(data))
                }
            }
        }
    }
    
}

extension CGImage {
    var jpegData: Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(mutableData, kUTTypeJPEG, 1, nil)
        else {
            return nil
        }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}
