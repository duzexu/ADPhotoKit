//
//  ADVideoClip.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/6.
//

import Foundation
import AVFoundation

class ADVideoClip: ADVideoEditTool {
    
    var image: UIImage {
        return Bundle.image(name: "icons_video_clip", module: .videoEdit) ?? UIImage()
    }
    
    var isSelected: Bool = false
        
    var toolConfigView: ADToolConfigable?
    var toolInteractView: ADToolInteractable?
    
    let asset: AVAsset
    var videoPlayer: ADVideoPlayable?
    let minValue: CGFloat?
    let maxValue: CGFloat?
        
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        let clip = ADVideoClipController(asset: asset, videoPlayer: videoPlayer, min: minValue, max: maxValue)
        clip.modalPresentationStyle = .custom
        clip.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
        ctx?.present(clip, animated: true, completion: nil)
        return false
    }
    
    var identifier: String {
        return "ADVideoClip"
    }
    
    func encode() -> Any? {
        return nil
    }
    
    func decode(from: Any) {
         
    }
    
    init(asset: AVAsset, min: CGFloat? = nil, max: CGFloat? = nil) {
        self.asset = asset
        self.minValue = min
        self.maxValue = max
    }
    
    func setVideoPlayer<T: ADVideoPlayable>(_ player: ADWeakRef<T>) {
        videoPlayer = player.value
    }
    
}
