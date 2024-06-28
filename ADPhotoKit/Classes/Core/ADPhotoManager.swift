//
//  ADPhotoManager.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import UIKit
import Photos

/// Main manager class of ADPhotoKit Core. It provide a set of convenience methods to fetch asset from system album.
/// You can use this class to fetch or save asset.
public class ADPhotoManager {
    
    /// Fetch all album.
    /// - Parameters:
    ///   - options: Options to set the album type and order. It is `ADAlbumSelectOptions.default` by default.
    ///   - completion: Called after finish fetching.
    public class func allPhotoAlbumList(options: ADAlbumSelectOptions = .default, completion: (([ADAlbumModel]) -> Void)) {
        let allowImage = options.contains(.allowImage)
        let allowVideo = options.contains(.allowVideo)
        
        if !allowImage && !allowVideo {
            fatalError("you must add at least one of 'allowImage' or 'allowVideo' to the options.")
        }
        
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
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// Fetch all album.
    /// - Parameter options: Options to set the album type and order. It is `ADAlbumSelectOptions.default` by default.
    /// - Returns: albums.
    @available(iOS 13.0, *)
    public class func allPhotoAlbumList(options: ADAlbumSelectOptions = .default) async -> [ADAlbumModel] {
        let albumList = await withCheckedContinuation { continuation in
            allPhotoAlbumList(options: options) { list in
                continuation.resume(returning: list)
            }
        }
        return albumList
    }
    #endif
    
    /// Fetch cameraRoll album.
    /// - Parameters:
    ///   - options: Options to set the album type and order. It is `ADAlbumSelectOptions.default` by default.
    ///   - completion: Called after finish fetching.
    public class func cameraRollAlbum(options: ADAlbumSelectOptions = .default, completion: @escaping ( (ADAlbumModel) -> Void )) {
        let allowImage = options.contains(.allowImage)
        let allowVideo = options.contains(.allowVideo)
        
        if !allowImage && !allowVideo {
            fatalError("you must add at least one of 'allowImage' or 'allowVideo' to the options.")
        }
        
        let option = PHFetchOptions()
        if !allowImage {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !allowVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        smartAlbums.enumerateObjects { (collection, _, stop) in
            if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                let result = PHAsset.fetchAssets(in: collection, options: option)
                let albumModel = ADAlbumModel(result: result, collection: collection, option: option)
                completion(albumModel)
                stop.pointee = true
            }
        }
    }
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// Fetch cameraRoll album.
    /// - Parameter options: Options to set the album type and order. It is `ADAlbumSelectOptions.default` by default.
    /// - Returns: cameraRoll album.
    @available(iOS 13.0, *)
    public class func cameraRollAlbum(options: ADAlbumSelectOptions = .default) async -> ADAlbumModel {
        let allowImage = options.contains(.allowImage)
        let allowVideo = options.contains(.allowVideo)
        
        if !allowImage && !allowVideo {
            fatalError("you must add 'allowImage' or 'allowVideo' to options.")
        }
        
        let option = PHFetchOptions()
        if !allowImage {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !allowVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        return await withCheckedContinuation { continuation in
            smartAlbums.enumerateObjects { (collection, _, stop) in
                if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    let result = PHAsset.fetchAssets(in: collection, options: option)
                    let albumModel = ADAlbumModel(result: result, collection: collection, option: option)
                    stop.pointee = true
                    continuation.resume(returning: albumModel)
                }
            }
        }
    }
    #endif
    
    /// Fetch assets in album.
    /// - Parameters:
    ///   - result: Fetch result associate with album.
    ///   - options: Options to set the album type and order. It is `ADAlbumSelectOptions.default` by default.
    ///   - limitCount: Max count to fetch.
    /// - Returns: Assets in album.
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
    
    /// Type of fetch result.
    public enum AssetResultType {
        /// Fetch result by `UIImage`.
        /// - Parameter size: Size of the image fetch, If nil, will fetch original image.
        /// - Parameter resizeMode: Image resize mode.
        /// - Parameter synchronous: If `true`, return only a single result, blocking until available (or failure).
        case image(size: CGSize?, resizeMode: PHImageRequestOptionsResizeMode = .fast, synchronous: Bool = false)
        /// Fetch result by original `Data`.
        case originImageData
        /// Fetch result by `PHLivePhoto`.
        case livePhoto
        /// Fetch result by `AVPlayerItem`.
        case video
        /// Fetch result by `AVAsset`.
        case assert
        /// Fetch result by filePath.
        case filePath
    }
    
    /// Provide caller a way to be told how much progress has been made prior to delivering the data when it comes from iCloud.
    public typealias ADAssetProgressHandler = (Double, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void
    /// A block that is called after fetch complete.
    public typealias ADAssetCompletionHandler = (Any?, [AnyHashable: Any]?, Bool) -> Void
    /// A block that is called after fetch image complete.
    public typealias ADImageCompletionHandler = (UIImage?, [AnyHashable: Any]?, Bool) -> Void
    /// A block that is called after fetch data complete.
    public typealias ADDataCompletionHandler = (Data?, [AnyHashable: Any]?, Bool) -> Void
    /// A block that is called after fetch livePhoto complete.
    public typealias ADLivePhotoCompletionHandler = (PHLivePhoto?, [AnyHashable: Any]?, Bool) -> Void
    /// A block that is called after fetch playItem complete.
    public typealias ADPlayItemCompletionHandler = (AVPlayerItem?, [AnyHashable: Any]?, Bool) -> Void
    /// A block that is called after fetch AVAsset complete.
    public typealias ADAVAssertCompletionHandler = (AVAsset?, [AnyHashable: Any]?, Bool) -> Void
    /// A block that is called after fetch file path complete.
    public typealias ADFilePathCompletionHandler = (String?, [AnyHashable: Any]?, Bool) -> Void
    
    /// Fetch assset's data by type.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - type: Type of fetch result.
    ///   - progress: Progress of fetching request.
    ///   - completion: Called after fetch result.
    /// - Returns: A numeric identifier for the request. If you need to cancel the request before it completes, pass this identifier to the cancelImageRequest: method.
    @discardableResult
    public class func fetch(for asset: PHAsset, type: AssetResultType, progress: ADAssetProgressHandler? = nil, completion: @escaping ADAssetCompletionHandler) -> PHImageRequestID? {
        switch type {
        case let .image(size, resizeMode, synchronous):
            return fetchImage(for: asset, size: size, resizeMode: resizeMode, synchronous: synchronous, progress: progress, completion: completion)
        case .originImageData:
            return fetchOriginImageData(for: asset, progress: progress, completion: completion)
        case .livePhoto:
            return fetchLivePhoto(for: asset, progress: progress, completion: completion)
        case .video:
            return fetchVideo(for: asset, progress: progress, completion: completion)
        case .assert:
            return fetchAVAsset(for: asset, progress: progress, completion: completion)
        case .filePath:
            fetchFilePath(for: asset, completion: completion)
            return nil
        }
    }
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// Fetch assset's data by type.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - type: Type of fetch result.
    ///   - progress: Progress of fetching request.
    /// - Returns: fetch result.
    @available(iOS 13.0.0, *)
    public class func fetch<T>(for asset: PHAsset, type: AssetResultType, progress: ADAssetProgressHandler? = nil) async throws  -> T? {
        switch type {
        case let .image(size, resizeMode, _):
            return try await fetchImage(for: asset, size: size, resizeMode: resizeMode, progress: progress) as? T
        case .originImageData:
            return try await fetchOriginImageData(for: asset, progress: progress) as? T
        case .livePhoto:
            return try await fetchLivePhoto(for: asset, progress: progress) as? T
        case .video:
            return try await fetchVideo(for: asset, progress: progress) as? T
        case .assert:
            return try await fetchAVAsset(for: asset, progress: progress) as? T
        case .filePath:
            return try await fetchFilePath(for: asset) as? T
        }
    }
    #endif
        
    /// Fetch image for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - size: Size of the image fetch, If nil, will fetch original image.
    ///   - resizeMode: Image resize mode.
    ///   - synchronous: Return only a single result, blocking until available (or failure).
    ///   - progress: Progress of fetching request. Only called when the data is not available locally and is retrieved from iCloud.
    ///   - completion: Called after fetch result.
    /// - Returns: A numeric identifier for the request. If you need to cancel the request before it completes, pass this identifier to the cancelImageRequest: method.
    @discardableResult
    public class func fetchImage(for asset: PHAsset, size: CGSize? = nil, resizeMode: PHImageRequestOptionsResizeMode = .fast, synchronous: Bool = false, progress: PHAssetImageProgressHandler? = nil, completion: @escaping ADImageCompletionHandler) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode
        option.isNetworkAccessAllowed = true
        option.isSynchronous = synchronous
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
            }else{
                completion(nil, info, false)
            }
        }
    }

    #if swift(>=5.5) && canImport(_Concurrency)
    /// Fetch image for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - size: Size of the image fetch, If nil, will fetch original image.
    ///   - resizeMode: Image resize mode.
    ///   - progress: Progress of fetching request. Only called when the data is not available locally and is retrieved from iCloud.
    /// - Returns: image asset.
    @available(iOS 13.0, *)
    public class func fetchImage(for asset: PHAsset, size: CGSize? = nil, resizeMode: PHImageRequestOptionsResizeMode = .fast, progress: PHAssetImageProgressHandler? = nil) async throws -> UIImage? {
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
        
        let targetSize = size ?? PHImageManagerMaximumSize
        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: option) { (image, info) in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                }else{
                    continuation.resume(returning: image)
                }
           }
        }
    }
    #endif
    
    /// Fetch origin data for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - progress: Progress of fetching request.Only called when the data is not available locally and is retrieved from iCloud.
    ///   - completion: Called after fetch result.
    /// - Returns: A numeric identifier for the request. If you need to cancel the request before it completes, pass this identifier to the cancelImageRequest: method.
    @discardableResult
    public class func fetchOriginImageData(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil, completion: @escaping ADDataCompletionHandler) -> PHImageRequestID {
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
        
        let completionHandle: (Data?, [AnyHashable: Any]?) -> Void = { (data, info) in
            let cancel = info?[PHImageCancelledKey] as? Bool ?? false
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if !cancel, let data = data {
                completion(data, info, isDegraded)
            }else{
                completion(nil, info, false)
            }
        }
        
        if #available(iOS 13.0, *) {
            return PHImageManager.default().requestImageDataAndOrientation(for: asset, options: option) { data, _, _, info in
                completionHandle(data, info)
            }
        } else {
            return PHImageManager.default().requestImageData(for: asset, options: option) { data, _, _, info in
                completionHandle(data, info)
            }
        }
    }
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// Fetch origin data for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - progress: Progress of fetching request.Only called when the data is not available locally and is retrieved from iCloud.
    /// - Returns: data asset.
    @available(iOS 13.0, *)
    public class func fetchOriginImageData(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil) async throws -> Data? {
        let option = PHImageRequestOptions()
        if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
            option.version = .original
        }
        option.isNetworkAccessAllowed = true
        option.resizeMode = .fast
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: option) { (data, _, _, info) in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                }else{
                    continuation.resume(returning: data)
                }
            }
        }
    }
    #endif
    
    /// Fetch livePhoto for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - progress: Progress of fetching request.Only called when the data is not available locally and is retrieved from iCloud.
    ///   - completion: Called after fetch result.
    /// - Returns: A numeric identifier for the request. If you need to cancel the request before it completes, pass this identifier to the cancelImageRequest: method.
    @discardableResult
    public class func fetchLivePhoto(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil, completion: @escaping ADLivePhotoCompletionHandler) -> PHImageRequestID {
        let option = PHLivePhotoRequestOptions()
        option.version = .current
        option.deliveryMode = .opportunistic
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
        
        return PHImageManager.default().requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option) { (livePhoto, info) in
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            completion(livePhoto, info, isDegraded)
        }
    }
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// Fetch livePhoto for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - progress: Progress of fetching request.Only called when the data is not available locally and is retrieved from iCloud.
    /// - Returns: livePhoto asset.
    @available(iOS 13.0.0, *)
    public class func fetchLivePhoto(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil) async throws -> PHLivePhoto? {
        let option = PHLivePhotoRequestOptions()
        option.version = .current
        option.deliveryMode = .highQualityFormat
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option) { (livePhoto, info) in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                }else{
                    continuation.resume(returning: livePhoto)
                }
            }
        }
    }
    #endif
    
    /// Fetch video for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - progress: Progress of fetching request.Only called when the data is not available locally and is retrieved from iCloud.
    ///   - completion: Called after fetch result.
    /// - Returns: A numeric identifier for the request. If you need to cancel the request before it completes, pass this identifier to the cancelImageRequest: method.
    @discardableResult
    public class func fetchVideo(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil, completion: @escaping ADPlayItemCompletionHandler) -> PHImageRequestID {
        let option = PHVideoRequestOptions()
        option.version = .current
        option.deliveryMode = .automatic
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
                
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
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// Fetch video for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - progress: Progress of fetching request.Only called when the data is not available locally and is retrieved from iCloud.
    /// - Returns: AVPlayerItem asset.
    @available(iOS 13.0.0, *)
    public class func fetchVideo(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil) async throws -> AVPlayerItem? {
        let option = PHVideoRequestOptions()
        option.version = .current
        option.deliveryMode = .automatic
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
                
        if asset.isInCloud {
            return try await withCheckedThrowingContinuation { continuation in
                PHImageManager.default().requestExportSession(forVideo: asset, options: option, exportPreset: AVAssetExportPresetHighestQuality, resultHandler: { (session, info) in
                    // iOS11 and earlier, callback is not on the main thread.
                    DispatchQueue.main.async {
                        if let error = info?[PHImageErrorKey] as? Error {
                            continuation.resume(throwing: error)
                        }else{
                            if let avAsset = session?.asset {
                                let item = AVPlayerItem(asset: avAsset)
                                continuation.resume(returning: item)
                            }else{
                                continuation.resume(returning: nil)
                            }
                        }
                    }
                })
            }
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                PHImageManager.default().requestPlayerItem(forVideo: asset, options: option) { (item, info) in
                    // iOS11 and earlier, callback is not on the main thread.
                    DispatchQueue.main.async {
                        if let error = info?[PHImageErrorKey] as? Error {
                            continuation.resume(throwing: error)
                        }else{
                            continuation.resume(returning: item)
                        }
                    }
                }
            }
        }
    }
    #endif
    
    /// Fetch AVAsset for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - progress: Progress of fetching request.Only called when the data is not available locally and is retrieved from iCloud.
    ///   - completion: Called after fetch result.
    /// - Returns: A numeric identifier for the request. If you need to cancel the request before it completes, pass this identifier to the cancelImageRequest: method.
    @discardableResult
    public class func fetchAVAsset(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil, completion: @escaping ADAVAssertCompletionHandler) -> PHImageRequestID {
        let option = PHVideoRequestOptions()
        option.version = .current
        option.deliveryMode = .automatic
        option.isNetworkAccessAllowed = true
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
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// Fetch video for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - progress: Progress of fetching request.Only called when the data is not available locally and is retrieved from iCloud.
    /// - Returns: AVAsset asset.
    @available(iOS 13.0.0, *)
    public class func fetchAVAsset(for asset: PHAsset, progress: PHAssetImageProgressHandler? = nil) async throws -> AVAsset? {
        let option = PHVideoRequestOptions()
        option.version = .current
        option.deliveryMode = .automatic
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(pro, error, stop, info)
            }
        }
                
        if asset.isInCloud {
            return try await withCheckedThrowingContinuation { continuation in
                PHImageManager.default().requestExportSession(forVideo: asset, options: option, exportPreset: AVAssetExportPresetHighestQuality, resultHandler: { (session, info) in
                    // iOS11 and earlier, callback is not on the main thread.
                    DispatchQueue.main.async {
                        if let error = info?[PHImageErrorKey] as? Error {
                            continuation.resume(throwing: error)
                        }else{
                            continuation.resume(returning: session?.asset)
                        }
                    }
                })
            }
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                PHImageManager.default().requestAVAsset(forVideo: asset, options: option) { (avAsset, _, info) in
                    DispatchQueue.main.async {
                        if let error = info?[PHImageErrorKey] as? Error {
                            continuation.resume(throwing: error)
                        }else{
                            continuation.resume(returning: avAsset)
                        }
                    }
                }
            }
        }
    }
    #endif
    
    /// Fetch file path for asset.
    /// - Parameters:
    ///   - asset: Asset to fetch result.
    ///   - completion: Called after fetch result.
    public class func fetchFilePath(for asset: PHAsset, completion: @escaping ADFilePathCompletionHandler) {
        asset.requestContentEditingInput(with: nil) { (input, info) in
            DispatchQueue.main.async {
                var path = input?.fullSizeImageURL?.absoluteString
                if path == nil, let dir = asset.value(forKey: "directory") as? String, let name = asset.value(forKey: "filename") as? String {
                    path = String(format: "file:///var/mobile/Media/%@/%@", dir, name)
                }
                completion(path,info,true)
            }
        }
    }
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// Fetch file path for asset.
    /// - Parameter asset: Asset to fetch result.
    /// - Returns: file path.
    @available(iOS 13.0.0, *)
    public class func fetchFilePath(for asset: PHAsset) async throws -> String? {
        return try await withCheckedThrowingContinuation { continuation in
            asset.requestContentEditingInput(with: nil) { (input, info) in
                DispatchQueue.main.async {
                    if let error = info[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                    }else{
                        var path = input?.fullSizeImageURL?.absoluteString
                        if path == nil, let dir = asset.value(forKey: "directory") as? String, let name = asset.value(forKey: "filename") as? String {
                            path = String(format: "file:///var/mobile/Media/%@/%@", dir, name)
                        }
                        continuation.resume(returning: path)
                    }
                }
            }
        }
    }
    #endif
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
    /// - Parameters:
    ///   - image: Image to save.
    ///   - completion: Called after image saved.
    public class func saveImageToAlbum(image: UIImage, completion: ( (Bool, PHAsset?) -> Void )? ) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .denied || status == .restricted {
            completion?(false, nil)
            return
        }
        
        var placeholderAsset: PHObjectPlaceholder? = nil
        let completionHandler: ((Bool, Error?) -> Void) = { suc, _ in
            if suc {
                let asset = self.getAsset(from: placeholderAsset?.localIdentifier)
                DispatchQueue.main.async {
                    completion?(suc, asset)
                }
            } else {
                DispatchQueue.main.async {
                    completion?(false, nil)
                }
            }
        }
        
        if image.hasAlphaChannel(), let data = image.pngData() {
            PHPhotoLibrary.shared().performChanges({
                let newAssetRequest = PHAssetCreationRequest.forAsset()
                newAssetRequest.addResource(with: .photo, data: data, options: nil)
                placeholderAsset = newAssetRequest.placeholderForCreatedAsset
            }, completionHandler: completionHandler)
        }else{
            PHPhotoLibrary.shared().performChanges({
                let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                placeholderAsset = newAssetRequest.placeholderForCreatedAsset
            }, completionHandler: completionHandler)
        }
    }
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// Save image to album.
    /// - Parameters:
    ///   - image: Image to save.
    @available(iOS 13.0.0, *)
    public class func saveImageToAlbum(image: UIImage) async throws -> PHAsset? {
        var placeholderAsset: PHObjectPlaceholder? = nil
        if image.hasAlphaChannel(), let data = image.pngData() {
            try await PHPhotoLibrary.shared().performChanges{
                let newAssetRequest = PHAssetCreationRequest.forAsset()
                newAssetRequest.addResource(with: .photo, data: data, options: nil)
                placeholderAsset = newAssetRequest.placeholderForCreatedAsset
            }
        }else{
            try await PHPhotoLibrary.shared().performChanges {
                let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                placeholderAsset = newAssetRequest.placeholderForCreatedAsset
            }
        }
        return self.getAsset(from: placeholderAsset?.localIdentifier)
    }
    #endif
    
    /// Save video to album.
    /// - Parameters:
    ///   - url: Video asset's path.
    ///   - completion: Called after video saved.
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
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// Save image to album.
    /// - Parameters:
    ///   - image: Image to save.
    @available(iOS 13.0.0, *)
    public class func saveVideoToAlbum(url: URL) async throws -> PHAsset? {
        var placeholderAsset: PHObjectPlaceholder? = nil
        try await PHPhotoLibrary.shared().performChanges {
            let newAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            placeholderAsset = newAssetRequest?.placeholderForCreatedAsset
        }
        return self.getAsset(from: placeholderAsset?.localIdentifier)
    }
    #endif
    
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
    
    /// Check authority access to system album.
    /// - Returns: If have authority.
    public class func photoAuthority() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    /// Check authority access to camera.
    /// - Returns: If have authority.
    public class func cameraAuthority() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
            return false
        }
        return true
    }
    
    /// Check authority access to microphone.
    /// - Returns: If have authority.
    public class func microphoneAuthority() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .restricted || status == .denied {
            return false
        }
        return true
    }
}
