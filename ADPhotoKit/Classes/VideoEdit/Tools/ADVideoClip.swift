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
    weak var clipVC: ADVideoClipConfigurable?
    
    let asset: AVAsset
    var videoPlayer: ADVideoPlayable?
    let minValue: CGFloat?
    let maxValue: CGFloat?
    
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)!
    
    var clipRange: CMTimeRange?
        
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        let clip = ADVideoEditConfigure.videoClipVC(clipInfo: ADVideoClipInfo(asset: asset, normalizeMinTime: minValue, normalizeMaxTime: maxValue, clipRange: clipRange))
        clip.modalPresentationStyle = .overCurrentContext
        ctx?.present(clip, animated: false, completion: nil)
        clip.clipCancel = { [weak self] in
            self?.videoPlayer?.clipRange = self?.clipRange
            self?.playableRectUpdate(0, 0, true)
        }
        clip.clipRangeConfirm = { [weak self] in
            self?.clipRange = self?.videoPlayer?.clipRange
            self?.playableRectUpdate(0, 0, true)
        }
        clip.clipRangeChange = { [weak self] range in
            self?.videoPlayer?.clipRange = range
        }
        clip.seekReview = { [weak self] time in
            self?.videoPlayer?.seek(to: time, pause: true)
        }
        clipVC = clip
        playableRectUpdate(128 + safeAreaInsets.bottom + 24, safeAreaInsets.top + 24, true)
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
        videoPlayer?.addProgressObserver { [weak self] progress, _ in
            self?.clipVC?.updateProgress(progress)
        }
    }
}
