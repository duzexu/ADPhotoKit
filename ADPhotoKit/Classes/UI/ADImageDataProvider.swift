//
//  ADImageDataProvider.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/5.
//

import Foundation
import Kingfisher
import Photos

enum ADImageDataProviderError: Error {
    case fetchError
}

class PHAssetImageDataProvider: ImageDataProvider {
    
    var cacheKey: String {
        if let s = size {
            return "com.adphotokit.phasset_" + asset.localIdentifier + "_\(s.width)*\(s.height)"
        }
        return "com.adphotokit.phasset_" + asset.localIdentifier
    }
    
    let asset: PHAsset
    let size: CGSize?
    let progress: ((String,Double)->Void)?
    
    private var requestID: PHImageRequestID?
    
    init(asset: PHAsset, size: CGSize? = nil, progress: ((String,Double)->Void)? = nil) {
        self.asset = asset
        self.size = size
        self.progress = progress
    }
    
    deinit {
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
        }
    }
    
    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        if let s = size {
            requestID = ADPhotoManager.fetch(for: asset, type: .image(size: s, synchronous: true), progress: { [weak self] (pro, _, _, _) in
                guard let strong = self else { return }
                print(pro)
                self?.progress?(strong.asset.localIdentifier,pro)
            }, completion: { (image, info, _) in
                if let img = image as? UIImage {
                    handler(.success(img.pngData()!))
                }else{
                    let error: Error = ((info?[PHImageErrorKey]) as? Error) ?? ADImageDataProviderError.fetchError
                    handler(.failure(error))
                }
            })
        }else{
            requestID = ADPhotoManager.fetch(for: asset, type: .originImageData, progress: { [weak self] (pro, _, _, _) in
                guard let strong = self else { return }
                self?.progress?(strong.asset.localIdentifier,pro)
            }, completion: { (data, info, _) in
                if let d = data as? Data {
                    handler(.success(d))
                }else{
                    let error: Error = ((info?[PHImageErrorKey]) as? Error) ?? ADImageDataProviderError.fetchError
                    handler(.failure(error))
                }
            })
        }
    }
    
}
