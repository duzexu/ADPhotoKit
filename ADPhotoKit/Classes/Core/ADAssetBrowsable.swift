//
//  ADAssetBrowsable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/2.
//

import Foundation
import UIKit
import Photos
import Kingfisher

/// Represents an asset source for browser.
public protocol ADAssetBrowsable {
    var browseAsset: ADAsset { get }
    
    #if Module_ImageEdit
    var imageEditInfo: ADImageEditInfo? { set get }
    #endif
    #if Module_VideoEdit
    var videoEditInfo: ADVideoEditInfo? { set get }
    #endif
}

/// Image asset support browser.
public enum ADImageSource {
    /// The target should be got from network remotely.
    case network(URL)
    /// The target should be got from system album.
    case album(PHAsset)
    /// The target should be provided in `UIImage` format, and a identifier should provide.
    case local(UIImage, String)
    
    // Returns an identifier which persistently identifies the source.
    public var identifier: String {
        switch self {
        case let .network(url):
            return url.absoluteString
        case let .album(asset):
            return asset.localIdentifier
        case let .local(_, identify):
            return identify
        }
    }
    
    /// Return the file size of asset. Size return in kb.
    public var assetSize: CGFloat? {
        switch self {
        case .network(_):
            return nil
        case let .album(asset):
            return asset.assetSize
        case let .local(image, _):
            return CGFloat((image.pngData()?.count ?? 0)) / 1024
        }
    }
}

/// Video asset support browser.
public enum ADVideoSource {
    /// The target should be got from network remotely.
    case network(URL)
    /// The target should be got from system album.
    case album(PHAsset)
    /// The target should be provided with local video path.
    case local(URL)
    
    // Returns an identifier which persistently identifies the source.
    public var identifier: String {
        switch self {
        case let .network(url):
            return url.absoluteString
        case let .album(asset):
            return asset.localIdentifier
        case let .local(url):
            return url.absoluteString
        }
    }
}

/// Asset support browser.
public enum ADAsset: Equatable {
    
    /// Image asset source. The associated `ADImageSource` value defines source type.
    case image(ADImageSource)
    /// Video asset source. The associated `ADVideoSource` value defines source type.
    case video(ADVideoSource)
    
    // Returns an identifier which persistently identifies the asset.
    public var identifier: String {
        switch self {
        case let .image(source):
            return source.identifier
        case let .video(source):
            return source.identifier
        }
    }
    
    // Returns if asset is image.
    public var isImage: Bool {
        switch self {
        case .image(_):
            return true
        case .video(_):
            return false
        }
    }
    
    /// Return the file size of asset. Size return in kb.
    public var assetSize: CGFloat? {
        switch self {
        case let .image(source):
            return source.assetSize
        case .video(_):
            return nil
        }
    }
    
    public static func == (lhs: ADAsset, rhs: ADAsset) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension ADAssetModel: ADAssetBrowsable {
    
    /// ADAssetModel conforms to `ADAssetBrowsable` in ADPhotoKit.
    public var browseAsset: ADAsset {
        if type.isImage  {
            return .image(.album(asset))
        }else{
            return .video(.album(asset))
        }
    }
}

struct ADAssetBrowsableRuntimeKey {
    static let ImageEditInfo : UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "ImageEditInfo:".hashValue)
    static let VideoEditInfo : UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "VideoEditInfo:".hashValue)
}

/// PHAsset conforms to `ADAssetBrowsable` in ADPhotoKit.
extension PHAsset: ADAssetBrowsable {
    
    public var browseAsset: ADAsset {
        switch self.mediaType {
        case .video:
            return .video(.album(self))
        case .image:
            return .image(.album(self))
        default:
            return .image(.album(self))
        }
    }
    
    #if Module_ImageEdit
    public var imageEditInfo: ADImageEditInfo? {
        set {
            objc_setAssociatedObject(self, ADAssetBrowsableRuntimeKey.ImageEditInfo, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, ADAssetBrowsableRuntimeKey.ImageEditInfo) as? ADImageEditInfo
        }
    }
    #endif
    #if Module_VideoEdit
    public var videoEditInfo: ADVideoEditInfo? {
        set {
            objc_setAssociatedObject(self, ADAssetBrowsableRuntimeKey.VideoEditInfo, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, ADAssetBrowsableRuntimeKey.VideoEditInfo) as? ADVideoEditInfo
        }
    }
    #endif
    
}

/// UIImage conforms to `ADAssetBrowsable` in ADPhotoKit. It use random uuid string as identifier.
extension UIImage: ADAssetBrowsable {
    
    public var browseAsset: ADAsset {
        return .image(.local(self, UUID().uuidString))
    }
    
    #if Module_ImageEdit
    public var imageEditInfo: ADImageEditInfo? {
        set {
            objc_setAssociatedObject(self, ADAssetBrowsableRuntimeKey.ImageEditInfo, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, ADAssetBrowsableRuntimeKey.ImageEditInfo) as? ADImageEditInfo
        }
    }
    #endif
    #if Module_VideoEdit
    public var videoEditInfo: ADVideoEditInfo? {
        set {
            
        }
        get {
            return nil
        }
    }
    #endif
}
