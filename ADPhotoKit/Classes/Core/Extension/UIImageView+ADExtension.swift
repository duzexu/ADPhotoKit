//
//  UIImageView+ADExtension.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/7.
//

import Foundation
import UIKit
import Kingfisher
import Photos

struct UIImageViewRuntimeKey {
    static let RequestID : UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "RequestID:".hashValue)
    static let Identifier : UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "Identifier:".hashValue)
}

extension UIImageView {
    
    var assetReqID: PHImageRequestID? {
        set {
            objc_setAssociatedObject(self, UIImageViewRuntimeKey.RequestID, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, UIImageViewRuntimeKey.RequestID) as? PHImageRequestID
        }
    }
    
    var assetIdentifier: String? {
        set {
            objc_setAssociatedObject(self, UIImageViewRuntimeKey.Identifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, UIImageViewRuntimeKey.Identifier) as? String
        }
    }
    
    /// Sets an image to imageView with `PHAsset`.
    /// - Parameters:
    ///   - asset: Asset to fetch image.
    ///   - size: Size of fetch image.
    ///   - placeholder: A placeholder to show while retrieving the image from asset.
    ///   - progress: Progress of fetching request.
    ///   - completionHandler: Called after fetch result.
    public func setAsset(_ asset: PHAsset,
                  size: CGSize? = nil,
                  placeholder: UIImage? = nil,
                  progress: ((Double) -> Void)? = nil,
                  completionHandler: ((UIImage?) -> Void)? = nil) {
        if let id = assetReqID {
            PHImageManager.default().cancelImageRequest(id)
        }
        assetIdentifier = asset.localIdentifier
        image = placeholder ?? nil
        if let s = size {
            assetReqID = ADPhotoManager.fetch(for: asset, type: .image(size: s), progress: { [weak self] (pro, _, _, _) in
                guard let strong = self else { return }
                if strong.assetIdentifier == asset.localIdentifier {
                    progress?(pro)
                }
            }, completion: { [weak self] (image, info, _) in
                guard let strong = self else { return }
                if strong.assetIdentifier == asset.localIdentifier {
                    self?.image = image as? UIImage
                    completionHandler?(image as? UIImage)
                }
            })
        }else{
            assetReqID = ADPhotoManager.fetch(for: asset, type: .originImageData, progress: { [weak self] (pro, _, _, _) in
                guard let strong = self else { return }
                if strong.assetIdentifier == asset.localIdentifier {
                    progress?(pro)
                }
            }, completion: { [weak self] (data, info, _) in
                guard let strong = self else { return }
                if strong.assetIdentifier == asset.localIdentifier {
                    if let d = data as? Data {
                        self?.image = UIImage(data: d)
                        completionHandler?(UIImage(data: d))
                    }else{
                        completionHandler?(nil)
                    }
                }
            })
        }
    }
    
    /// Sets an image to imageView with video url.
    /// - Parameter url: Video url.
    public func setVideoUrlAsset(_ url: URL, time: CMTime = .zero) {
        let assert = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: assert)
        generator.appliesPreferredTrackTransform = true
        generator.apertureMode = .encodedPixels
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { [weak self] (requestedTime, image, imageTime, result, error) in
            if let cgImage = image {
                self?.image = UIImage(cgImage: cgImage)
            }
        }
    }
    
}
