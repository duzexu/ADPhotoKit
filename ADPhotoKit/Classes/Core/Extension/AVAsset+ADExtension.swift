//
//  AVAsset+ADExtension.swift
//  ADPhotoKit
//
//  Created by du on 2024/11/14.
//

import Foundation
import AVFoundation

extension AVAsset {
    
    var naturalSize: CGSize {
        if let videoTrack = tracks(withMediaType: .video).first {
            var size = videoTrack.naturalSize
            if AVAsset.isPortraitTrack(videoTrack) {
                swap(&size.width, &size.height)
            }
            return size
        }
        return .zero
    }
    
    static func isPortraitTrack(_ track: AVAssetTrack) -> Bool {
        let transform = track.preferredTransform
        let tfA = transform.a
        let tfB = transform.b
        let tfC = transform.c
        let tfD = transform.d
        
        if (tfA == 0 && tfB == 1 && tfC == -1 && tfD == 0) ||
            (tfA == 0 && tfB == 1 && tfC == 1 && tfD == 0) ||
            (tfA == 0 && tfB == -1 && tfC == 1 && tfD == 0) {
            return true
        } else {
            return false
        }
    }
}
