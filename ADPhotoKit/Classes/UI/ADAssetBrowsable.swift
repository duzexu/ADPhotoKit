//
//  ADAssetBrowsable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/2.
//

import Foundation
import UIKit
import Kingfisher
import Photos

/// Represents an asset source for browser.
public protocol ADAssetBrowsable {
    var browseAsset: ADAsset { get }
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

extension PHAsset: ADAssetBrowsable {
    
    /// PHAsset conforms to `ADAssetBrowsable` in ADPhotoKit.
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
}

extension UIImage: ADAssetBrowsable {
    
    /// UIImage conforms to `ADAssetBrowsable` in ADPhotoKit. It use random uuid string as identifier.
    public var browseAsset: ADAsset {
        return .image(.local(self, UUID().uuidString))
    }
}
