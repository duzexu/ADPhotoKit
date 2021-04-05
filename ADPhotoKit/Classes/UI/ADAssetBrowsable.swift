//
//  ADAssetBrowsable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/2.
//

import Foundation
import Kingfisher
import Photos

protocol ADAssetBrowsable {
    var browseAsset: ADAsset { get }
}

enum ADImageSource {
    case network(URL)
    case album(PHAsset)
    case local(UIImage)
}

enum ADVideoSource {
    case network(URL)
    case album(PHAsset)
    case local(URL)
}

enum ADAsset {
    case image(ADImageSource)
    case video(ADVideoSource)
}

extension ADAssetModel: ADAssetBrowsable {
    var browseAsset: ADAsset {
        if type.isImage  {
            return .image(.album(asset))
        }else{
            return .video(.album(asset))
        }
    }
}

extension PHAsset: ADAssetBrowsable {
    var browseAsset: ADAsset {
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
    var browseAsset: ADAsset {
        return .image(.local(self))
    }
}
