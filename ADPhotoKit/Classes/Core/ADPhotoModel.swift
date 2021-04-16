//
//  ADPhotoModel.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import UIKit
import Photos

public enum ADAlbumType: CaseIterable {
    case cameraRoll //最近项目
    case favorites //个人收藏
    case videos //视频
    case selfPortraits //自拍
    case livePhotos //实况照片
    case depthEffect //人像
    case panoramas //全景
    case timelapses //延时摄影
    case slomoVideos //慢动作
    case screenshots //截屏
    case bursts //连拍快照
    case animated //动图
    case custom //用户或APP建立
    
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

public class ADAlbumModel {
    
    public let title: String
    
    public let type: ADAlbumType
    
    public var count: Int {
        return result.count
    }
    
    public var result: PHFetchResult<PHAsset>
    
    public let collection: PHAssetCollection
    
    public let option: PHFetchOptions
    
    /// 是否是最近项目
    public let isCameraRoll: Bool
    
    public var lastestAsset: PHAsset? {
        return result.lastObject
    }
        
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
}

extension ADAlbumModel: CustomStringConvertible {
    public var description: String {
        return "title-\(title) count-\(count)"
    }
}

public class ADAssetModel: Equatable {
    
    public enum MediaType: Equatable {
        case unknown
        case image
        case gif
        case livePhoto
        case video(duration: Int = 0, format: String = "")
        
        var isImage: Bool {
            return value < 4
        }
        
        var duration: Int {
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
    
    public let identifier: String
    
    public let asset: PHAsset
    
    public var type: MediaType = .unknown
            
    public var selectStatus: ADThumbnailSelectStatus = .select(index: nil)
    
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

public class ADSelectAssetModel: Equatable {
    
    public let identifier: String
    
    public let asset: PHAsset
    
    public var index: Int?
    
    public init(asset: PHAsset) {
        self.identifier = asset.localIdentifier
        self.asset = asset
    }
    
    public static func == (lhs: ADSelectAssetModel, rhs: ADSelectAssetModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
