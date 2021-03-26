//
//  ADPhotoManager.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import UIKit
import Photos

public struct ADAlbumSelectOptions: OptionSet {
    public let rawValue: Int
    
    public static let ascending = ADAlbumSelectOptions(rawValue: 1 << 0)
    public static let allowImage = ADAlbumSelectOptions(rawValue: 1 << 1)
    public static let allowVideo = ADAlbumSelectOptions(rawValue: 1 << 2)
    
    public static let `default`: ADAlbumSelectOptions = [.ascending, .allowImage, .allowVideo]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct ADAssetSelectOptions: OptionSet {
    public let rawValue: Int
    
    /// Whether photos and videos can be selected together.
    static let mixSelect = ADAssetSelectOptions(rawValue: 1 << 0)
    /// Allow select Gif, it only controls whether it is displayed in Gif form.
    static let selectAsGif = ADAssetSelectOptions(rawValue: 1 << 1)
    /// Allow select LivePhoto, it only controls whether it is displayed in LivePhoto form.
    static let selectAsLivePhoto = ADAssetSelectOptions(rawValue: 1 << 2)
    /// If true, you can slide select photos in album.
    static let slideSelect = ADAssetSelectOptions(rawValue: 1 << 3)
    /// Allow select full image.
    static let selectOriginal = ADAssetSelectOptions(rawValue: 1 << 4)
    /// Allow access to the preview large image interface.
    static let previewPhotos = ADAssetSelectOptions(rawValue: 1 << 5)
    /// Allow take photos in the album.
    static let allowTakeAsset = ADAssetSelectOptions(rawValue: 1 << 6)
    /// If user choose limited Photo mode, a button with '+' will be added. It will call PHPhotoLibrary.shared().presentLimitedLibraryPicker(from:) to add photo.
    @available(iOS 14, *)
    static let allowAddAsset = ADAssetSelectOptions(rawValue: 1 << 7)
        
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let `default`: ADAssetSelectOptions = [.mixSelect,.selectOriginal,.previewPhotos,.slideSelect,.selectAsLivePhoto]
}

public class ADPhotoManager {

    /// 获取所有的相册列表
    public class func allPhotoAlbumList(options: ADAlbumSelectOptions = .default, completion: (([ADAlbumModel]) -> Void)) {
        let allowImage = options.contains(.allowImage)
        let allowVideo = options.contains(.allowVideo)
        
        let option = PHFetchOptions()
        if !allowImage {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !allowVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil) as! PHFetchResult<PHCollection>
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil) as! PHFetchResult<PHCollection>
        let streamAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumMyPhotoStream, options: nil) as! PHFetchResult<PHCollection>
        let syncedAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumSyncedAlbum, options: nil) as! PHFetchResult<PHCollection>
        let sharedAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: nil) as! PHFetchResult<PHCollection>
        let arr = [smartAlbums, albums, streamAlbums, syncedAlbums, sharedAlbums]
        
        var albumList: [ADAlbumModel] = []
        arr.forEach { (album) in
            album.enumerateObjects { (collection, _, _) in
                guard let collection = collection as? PHAssetCollection else { return }
                if collection.assetCollectionSubtype == .smartAlbumAllHidden {
                    return
                }
                if collection.assetCollectionSubtype == .smartAlbumRecentlyAdded {
                    return
                }
                if #available(iOS 11.0, *), collection.assetCollectionSubtype.rawValue > PHAssetCollectionSubtype.smartAlbumLongExposures.rawValue {
                    return
                }
                let result = PHAsset.fetchAssets(in: collection, options: option)
                if result.count == 0 {
                    return
                }
                
                let albumModel = ADAlbumModel(result: result, collection: collection, option: option)
                albumList.append(albumModel)
            }
        }
        
        completion(albumListByOrder(albumList))
    }
    
    /// 获取最近项目相册
    public class func cameraRollAlbum(options: ADAlbumSelectOptions = .default, completion: @escaping ( (ADAlbumModel) -> Void )) {
        let allowImage = options.contains(.allowImage)
        let allowVideo = options.contains(.allowVideo)
        
        let option = PHFetchOptions()
        if !allowImage {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !allowVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        smartAlbums.enumerateObjects { (collection, _, stop) in
            if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                let result = PHAsset.fetchAssets(in: collection, options: option)
                let albumModel = ADAlbumModel(result: result, collection: collection, option: option)
                completion(albumModel)
                stop.pointee = true
            }
        }
    }
    
    /// 获取相册中的资源信息
    public class func fetchAssets(in result: PHFetchResult<PHAsset>, options: ADAlbumSelectOptions = .default, limitCount: Int = .max) -> [ADAssetModel] {
        let ascending = options.contains(.ascending)
        let allowImage = options.contains(.allowImage)
        let allowVideo = options.contains(.allowVideo)
        
        var models: [ADAssetModel] = []
        let option: NSEnumerationOptions = ascending ? .init(rawValue: 0) : .reverse
        var count = 1
        
        result.enumerateObjects(options: option) { (asset, index, stop) in
            let m = ADAssetModel(asset: asset)
            
            if m.type == .image, !allowImage {
                return
            }
            if m.type == .video(), !allowVideo {
                return
            }
            if count == limitCount {
                stop.pointee = true
            }
            
            models.append(m)
            count += 1
        }
        
        return models
    }
    
    public enum AssetResultType {
        /// size为nil 获取原图
        case image(size: CGSize?, resizeMode: PHImageRequestOptionsResizeMode = .fast)
        case originImageData
        
        case livePhoto
        
        case video
        
        case assert
        
        case filePath
    }
    
    public typealias ADAssetProgressHandler = (Double, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void
    public typealias ADAssetCompletionHandler = (Any, [AnyHashable: Any]?, Bool) -> Void
    public typealias ADImageCompletionHandler = (UIImage?, [AnyHashable: Any]?, Bool) -> Void
    public typealias ADDataCompletionHandler = (Data?, [AnyHashable: Any]?, Bool) -> Void
    public typealias ADLivePhotoCompletionHandler = (PHLivePhoto?, [AnyHashable: Any]?, Bool) -> Void
    public typealias ADPlayItemCompletionHandler = (AVPlayerItem?, [AnyHashable: Any]?, Bool) -> Void
    public typealias ADAVAssertCompletionHandler = (AVAsset?, [AnyHashable: Any]?, Bool) -> Void
    public typealias ADFilePathCompletionHandler = (String?, [AnyHashable: Any]?, Bool) -> Void
    
    /// 获取资源文件
    @discardableResult
    class func fetch(for asset: PHAsset, type: AssetResultType, progress: ADAssetProgressHandler?, completion: @escaping ADAssetCompletionHandler) -> PHImageRequestID? {
        switch type {
        case let .image(size, resizeMode):
            return fetchImage(for: asset, size: size, resizeMode: resizeMode, progress: progress, completion: completion)
        case .originImageData:
            return fetchOriginImageData(for: asset, progress: progress, completion: completion)
        case .livePhoto:
            return fetchLivePhoto(for: asset, progress: progress, completion: completion)
        case .video:
            return fetchVideo(for: asset, progress: progress, completion: completion)
        case .assert:
            return fetchAVAsset(forVideo: asset, progress: progress, completion: completion)
        case .filePath:
            fetchFilePath(asset: asset, completion: completion)
            return nil
        }
    }
        
    /// Fetch image for asset.
    @discardableResult
    class func fetchImage(for asset: PHAsset, size: CGSize? = nil, resizeMode: PHImageRequestOptionsResizeMode = .fast, progress: PHAssetImageProgressHandler? = nil, completion: @escaping ADImageCompletionHandler) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
        
        let targetSize = size ?? PHImageManagerMaximumSize
        return PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: option) { (image, info) in
            var downloadFinished = false
            if let info = info {
                downloadFinished = !(info[PHImageCancelledKey] as? Bool ?? false) && (info[PHImageErrorKey] == nil)
            }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if downloadFinished {
                completion(image, info, isDegraded)
            }
        }
    }
    
    @discardableResult
    class func fetchOriginImageData(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil, completion: @escaping ADDataCompletionHandler) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
            option.version = .original
        }
        option.isNetworkAccessAllowed = true
        option.resizeMode = .fast
        option.deliveryMode = .highQualityFormat
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
        
        return PHImageManager.default().requestImageData(for: asset, options: option) { (data, _, _, info) in
            let cancel = info?[PHImageCancelledKey] as? Bool ?? false
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if !cancel, let data = data {
                completion(data, info, isDegraded)
            }
        }
    }
    
    @discardableResult
    class func fetchLivePhoto(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil, completion: @escaping ADLivePhotoCompletionHandler) -> PHImageRequestID {
        let option = PHLivePhotoRequestOptions()
        option.version = .current
        option.deliveryMode = .opportunistic
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
        
        return PHImageManager.default().requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (livePhoto, info) in
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            completion(livePhoto, info, isDegraded)
        }
    }
    
    @discardableResult
    class func fetchVideo(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil, completion: @escaping ADPlayItemCompletionHandler) -> PHImageRequestID {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
        
        // https://github.com/longitachi/ZLPhotoBrowser/issues/369#issuecomment-728679135
        
        if asset.isInCloud {
            return PHImageManager.default().requestExportSession(forVideo: asset, options: option, exportPreset: AVAssetExportPresetHighestQuality, resultHandler: { (session, info) in
                // iOS11 and earlier, callback is not on the main thread.
                DispatchQueue.main.async {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
                    if let avAsset = session?.asset {
                        let item = AVPlayerItem(asset: avAsset)
                        completion(item, info, isDegraded)
                    }
                }
            })
        } else {
            return PHImageManager.default().requestPlayerItem(forVideo: asset, options: option) { (item, info) in
                // iOS11 and earlier, callback is not on the main thread.
                DispatchQueue.main.async {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
                    completion(item, info, isDegraded)
                }
            }
        }
    }
    
    @discardableResult
    class func fetchAVAsset(forVideo asset: PHAsset, progress: PHAssetImageProgressHandler? = nil, completion: @escaping ADAVAssertCompletionHandler) -> PHImageRequestID {
        let option = PHVideoRequestOptions()
        option.version = .original
        option.deliveryMode = .automatic
        option.isNetworkAccessAllowed =  true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
        
        if asset.isInCloud {
            return PHImageManager.default().requestExportSession(forVideo: asset, options: option, exportPreset: AVAssetExportPresetHighestQuality) { (session, info) in
                // iOS11 and earlier, callback is not on the main thread.
                DispatchQueue.main.async {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
                    completion(session?.asset, info, isDegraded)
                }
            }
        } else {
            return PHImageManager.default().requestAVAsset(forVideo: asset, options: option) { (avAsset, _, info) in
                DispatchQueue.main.async {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
                    completion(avAsset, info, isDegraded)
                }
            }
        }
    }
    
    class func fetchFilePath(asset: PHAsset, completion: @escaping ADFilePathCompletionHandler) {
        asset.requestContentEditingInput(with: nil) { (input, info) in
            var path = input?.fullSizeImageURL?.absoluteString
            if path == nil, let dir = asset.value(forKey: "directory") as? String, let name = asset.value(forKey: "filename") as? String {
                path = String(format: "file:///var/mobile/Media/%@/%@", dir, name)
            }
            completion(path,info,true)
        }
    }
}

/// Private
extension ADPhotoManager {
    
    class func albumListByOrder(_ input: [ADAlbumModel]) -> [ADAlbumModel] {
        let custom = input.filter { $0.type == .custom }
        let old = input.filter { $0.type != .custom }.reduce(into: [ADAlbumType: ADAlbumModel]()) { $0[$1.type] = $1 }
        var new: [ADAlbumModel] = []
        let orders = ADPhotoKitConfiguration.default.customAlbumOrders ?? ADAlbumType.allCases
        for item in orders {
            if item == .custom {
                new.append(contentsOf: custom)
            }else{
                if let value = old[item] {
                    new.append(value)
                }
            }
        }
        return new
    }
    
}

/// save
extension ADPhotoManager {
    
    /// Save image to album.
    public class func saveImageToAlbum(image: UIImage, completion: ( (Bool, PHAsset?) -> Void )? ) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .denied || status == .restricted {
            completion?(false, nil)
            return
        }
        
        var placeholderAsset: PHObjectPlaceholder? = nil
        PHPhotoLibrary.shared().performChanges {
            let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset
        } completionHandler: { (suc, error) in
            DispatchQueue.main.async {
                if suc {
                    let asset = self.getAsset(from: placeholderAsset?.localIdentifier)
                    completion?(suc, asset)
                } else {
                    completion?(false, nil)
                }
            }
        }
    }
    
    /// Save video to album.
    public class func saveVideoToAlbum(url: URL, completion: ( (Bool, PHAsset?) -> Void )? ) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .denied || status == .restricted {
            completion?(false, nil)
            return
        }
        
        var placeholderAsset: PHObjectPlaceholder? = nil
        PHPhotoLibrary.shared().performChanges {
            let newAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            placeholderAsset = newAssetRequest?.placeholderForCreatedAsset
        } completionHandler: { (suc, error) in
            DispatchQueue.main.async {
                if suc {
                    let asset = self.getAsset(from: placeholderAsset?.localIdentifier)
                    completion?(suc, asset)
                } else {
                    completion?(false, nil)
                }
            }
        }
    }
    
    private class func getAsset(from localIdentifier: String?) -> PHAsset? {
        guard let id = localIdentifier else {
            return nil
        }
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        if result.count > 0{
            return result[0]
        }
        return nil
    }
}

/// Authority related.
extension ADPhotoManager {
    
    public class func photoAuthority() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
}
