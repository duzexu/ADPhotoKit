//
//  ADPhotoModel.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import UIKit
import Photos

/// Album type.
public enum ADAlbumType: CaseIterable {
    /// Recent (最近项目)
    case cameraRoll
    /// Favorites (个人收藏)
    case favorites
    /// Videos (视频)
    case videos
    /// Selfie (自拍)
    case selfPortraits
    /// LivePhoto (实况照片)
    case livePhotos
    /// Portrait (人像)
    case depthEffect
    /// Panoramic (全景)
    case panoramas
    /// Time-lapse (延时摄影)
    case timelapses
    /// Slow motion (慢动作)
    case slomoVideos
    /// Screenshot (截屏)
    case screenshots
    /// Continuous shooting (连拍快照)
    case bursts
    /// Gif (动图)
    case animated
    /// User created (用户或APP建立)
    case custom
    
    var localeKey: ADLocale.LocaleKey? {
        switch self {
        case .cameraRoll:
            return .cameraRoll
        case .favorites:
            return .favorites
        case .videos:
            return .videos
        case .selfPortraits:
            return .selfPortraits
        case .livePhotos:
            return .livePhotos
        case .depthEffect:
            return .depthEffect
        case .panoramas:
            return .panoramas
        case .slomoVideos:
            return .slomoVideos
        case .timelapses:
            return .timelapses
        case .screenshots:
            return .screenshots
        case .bursts:
            return .bursts
        case .animated:
            return .animated
        case .custom:
            return nil
        }
    }
}

/// Model contain album info.
public class ADAlbumModel: Equatable {
    
    /// Album title.
    public let title: String
    
    /// Album type.
    public let type: ADAlbumType
    
    /// Assets count contain in album.
    public var count: Int {
        return result.count
    }
    
    /// Property use to get asset in album.
    public var result: PHFetchResult<PHAsset>
    
    /// Property description the album.
    public let collection: PHAssetCollection
    
    /// Options that fetch album list.
    public let option: PHFetchOptions
    
    /// Indicate album is `Recent` album.
    public let isCameraRoll: Bool
    
    /// Lastest asset in album.
    public var lastestAsset: PHAsset? {
        return result.lastObject
    }
    
    /// Create album info model.
    /// - Parameters:
    ///   - result: Property use to get asset in album.
    ///   - collection: Property description the album.
    ///   - option: Options that fetch album list.
    public init(result: PHFetchResult<PHAsset>, collection: PHAssetCollection, option: PHFetchOptions) {
        let info = ADAlbumModel.collectionInfo(collection)
        self.title = info.0
        self.type = info.1
        self.isCameraRoll = info.1 == .cameraRoll
        self.result = result
        self.collection = collection
        self.option = option
    }
    
    /// Conversion collection info.
    private class func collectionInfo(_ collection: PHAssetCollection) -> (String,ADAlbumType) {
        if collection.assetCollectionType == .album {
            // Albums created by user.
            var title: String? = nil
            if let _ = ADPhotoKitConfiguration.default.locale {
                switch collection.assetCollectionSubtype {
                case .albumMyPhotoStream:
                    title = ADLocale.LocaleKey.myPhotoStream.localeTextValue
                default:
                    title = collection.localizedTitle
                }
            } else {
                title = collection.localizedTitle
            }
            return (title ?? ADLocale.LocaleKey.noTitleAlbumListPlaceholder.localeTextValue,.custom)
        }
        
        var title: String? = nil
        var type: ADAlbumType? = nil
        switch collection.assetCollectionSubtype {
        case .smartAlbumUserLibrary:
            type = .cameraRoll
        case .smartAlbumPanoramas:
            type = .panoramas
        case .smartAlbumVideos:
            type = .videos
        case .smartAlbumFavorites:
            type = .favorites
        case .smartAlbumTimelapses:
            type = .timelapses
        case .smartAlbumRecentlyAdded:
            //type = .recentlyAdded
            break
        case .smartAlbumBursts:
            type = .bursts
        case .smartAlbumSlomoVideos:
            type = .slomoVideos
        case .smartAlbumSelfPortraits:
            type = .selfPortraits
        case .smartAlbumScreenshots:
            type = .screenshots
        case .smartAlbumDepthEffect:
            type = .depthEffect
        case .smartAlbumLivePhotos:
            type = .livePhotos
        case .smartAlbumAnimated:
            type = .animated
        default:
            break
        }
        if let _ = ADPhotoKitConfiguration.default.locale {
            title = type?.localeKey?.localeTextValue ?? collection.localizedTitle
        } else {
            title = collection.localizedTitle
        }
        
        return (title ?? ADLocale.LocaleKey.noTitleAlbumListPlaceholder.localeTextValue,type ?? .custom)
    }
    
    public static func == (lhs: ADAlbumModel, rhs: ADAlbumModel) -> Bool {
        return lhs.collection.localIdentifier == rhs.collection.localIdentifier
    }
    
}

extension ADAlbumModel: CustomStringConvertible {
    public var description: String {
        return "title-\(title) count-\(count)"
    }
}

/// Model contain asset info.
public class ADAssetModel: Equatable {
    
    /// Type of asset.
    public enum MediaType: Equatable {
        case unknown
        case image
        case gif
        case livePhoto
        case video(duration: Int = 0, format: String = "")
        
        /// Asset is image.
        public var isImage: Bool {
            return value < 4
        }
        
        /// If asset is video, return video duration, else return 0.
        public var duration: Int {
            switch self {
            case let .video(duration,_):
                return duration
            default:
                return 0
            }
        }
        
        private var value: Int {
            switch self {
            case .unknown:
                return 0
            case .image:
                return 1
            case .gif:
                return 2
            case .livePhoto:
                return 3
            case .video:
                return 4
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.value == rhs.value
        }
    }
    
    /// An identifier which persistently identifies the object on a given device.
    public let identifier: String
    
    /// Asset associte with model.
    public let asset: PHAsset
    
    #if Module_ImageEdit
    /// The image edit info. If not 'nil', indicate asset have been edited.
    public var imageEditInfo: ADImageEditInfo?
    #endif
    
    /// Media type of asset.
    public var type: MediaType = .unknown
    
    /// Asset's select status.
    public var selectStatus: ADThumbnailSelectStatus = .select(index: nil)
    
    /// Create asset info model.
    /// - Parameter asset: Asset to bind.
    public init(asset: PHAsset) {
        self.identifier = asset.localIdentifier
        self.asset = asset
        self.type = transformAssetType(for: asset)
    }
    
    private func transformAssetType(for asset: PHAsset) -> MediaType {
        switch asset.mediaType {
        case .video:
            let dur = Int(round(asset.duration))
            let time = transformDuration(dur)
            return .video(duration: dur, format: time)
        case .image:
            if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
                return .gif
            }
            if #available(iOS 9.1, *) {
                if asset.mediaSubtypes == .photoLive || asset.mediaSubtypes.rawValue == 10 {
                    return .livePhoto
                }
            }
            return .image
        default:
            return .unknown
        }
    }
    
    private func transformDuration(_ dur: Int) -> String {
        switch dur {
        case 0..<60:
            return String(format: "00:%02d", dur)
        case 60..<3600:
            let m = dur / 60
            let s = dur % 60
            return String(format: "%02d:%02d", m, s)
        case 3600...:
            let h = dur / 3600
            let m = (dur % 3600) / 60
            let s = dur % 60
            return String(format: "%02d:%02d:%02d", h, m, s)
        default:
            return ""
        }
    }
    
    public static func == (lhs: ADAssetModel, rhs: ADAssetModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}

/// Warp of select asset.
public class ADSelectAssetModel: Equatable {
    
    /// PHAsset's identifier.
    public let identifier: String
    
    /// Asset warp by model.
    public let asset: PHAsset
    
    /// Index of asset in select array.
    public var index: Int?
    
    /// Image edited by user.
    public var editImage: UIImage?
    
    /// Create warp model with asset.
    /// - Parameter asset: Asset to warp.
    public init(asset: PHAsset) {
        self.identifier = asset.localIdentifier
        self.asset = asset
    }
    
    public static func == (lhs: ADSelectAssetModel, rhs: ADSelectAssetModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
