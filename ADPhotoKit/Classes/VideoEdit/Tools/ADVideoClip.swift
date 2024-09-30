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
    weak var clipVC: ADVideoClipController?
    
    let asset: AVAsset
    var videoPlayer: ADVideoPlayable?
    let minValue: CGFloat?
    let maxValue: CGFloat?
    
    var beginClip: (()->Void)?
    var endClip: (()->Void)?
    
    var clipRange: CMTimeRange?
        
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        let clip = ADVideoClipController(asset: asset, videoPlayer: videoPlayer, min: minValue, max: maxValue, clipRange: clipRange)
        clip.modalPresentationStyle = .overCurrentContext
        ctx?.present(clip, animated: false, completion: nil)
        clip.clipCancel = { [weak self] in
            self?.videoPlayer?.clipRange = self?.clipRange
            self?.endClip?()
        }
        clip.clipRangeConfirm = { [weak self] in
            self?.clipRange = self?.videoPlayer?.clipRange
            self?.endClip?()
        }
        clip.clipRangeChange = { [weak self] range in
            self?.videoPlayer?.clipRange = range
        }
        clip.seekReview = { [weak self] time in
            self?.videoPlayer?.seek(to: time, pause: true)
        }
        clipVC = clip
        beginClip?()
        return false
    }
    
    var identifier: String {
        return "ADVideoClip"
    }
    
    func encode() -> Any? {
        return ["clipRange":clipRange]
    }
    
    func decode(from: Any) {
        if let json = from as? Dictionary<String,Any> {
            videoPlayer?.clipRange = json["clipInfo"] as? CMTimeRange
        }
    }
    
    init(asset: AVAsset, min: CGFloat? = nil, max: CGFloat? = nil) {
        self.asset = asset
        self.minValue = min
        self.maxValue = max
    }
    
    func setVideoPlayer<T: ADVideoPlayable>(_ player: ADWeakRef<T>) {
        videoPlayer = player.value
        videoPlayer?.addProgressObserver { [weak self] progress in
            self?.clipVC?.updateProgress(progress)
        }
    }
}
