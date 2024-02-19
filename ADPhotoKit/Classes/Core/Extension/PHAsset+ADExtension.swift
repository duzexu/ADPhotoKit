//
//  PHAsset+ADExtension.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/15.
//

import Photos

extension PHAsset {
    
    // An indicator of whether the asset is in cloud.
    public var isInCloud: Bool {
        guard let resource = PHAssetResource.assetResources(for: self).first else {
            return false
        }
        return !(resource.value(forKey: "locallyAvailable") as? Bool ?? true)
    }
    
    // An indicator of the asset‘s aspect ratio.
    public var whRatio: CGFloat {
        return CGFloat(pixelWidth) / CGFloat(pixelHeight)
    }
    
    // An indicator of whether the asset is gif.
    public var isGif: Bool {
        switch mediaType {
        case .image:
            if (value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
                return true
            }
        default:
            break
        }
        return false
    }
    
    // An indicator of whether the asset is livephoto.
    @available(iOS 9.1, *)
    public var isLivePhoto: Bool {
        switch mediaType {
        case .image:
            if mediaSubtypes == .photoLive || mediaSubtypes.rawValue == 10 {
                return true
            }
        default:
            break
        }
        return false
    }
    
}
