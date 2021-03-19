//
//  PHAsset+ADExtension.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/15.
//

import Photos

extension PHAsset {
    
    var isInCloud: Bool {
        guard let resource = PHAssetResource.assetResources(for: self).first else {
            return false
        }
        return !(resource.value(forKey: "locallyAvailable") as? Bool ?? true)
    }
    
}
