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
    let minValue: CGFloat?
    let maxValue: CGFloat?
    
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)!
    
    weak var videoPlayable: ADVideoPlayable? {
        didSet {
            videoPlayable?.addProgressObserver { [weak self] progress, _ in
                self?.clipVC?.updateProgress(progress)
            }
        }
    }
    var clipRange: CMTimeRange?
        
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        let clip = ADVideoEditConfigure.videoClipVC(clipInfo: ADVideoClipInfo(asset: asset, normalizeMinTime: minValue, normalizeMaxTime: maxValue, clipRange: clipRange))
        clip.modalPresentationStyle = .overCurrentContext
        ctx?.present(clip, animated: false, completion: nil)
        clip.clipCancel = { [weak self] in
            self?.videoPlayable?.clipRange = self?.clipRange
            self?.playableRectUpdate(0, 0, true)
        }
        clip.clipRangeConfirm = { [weak self] in
            self?.clipRange = self?.videoPlayable?.clipRange
            self?.playableRectUpdate(0, 0, true)
        }
        clip.clipRangeChange = { [weak self] range in
            self?.videoPlayable?.clipRange = range
        }
        clip.seekReview = { [weak self] time in
            self?.videoPlayable?.seek(to: time, pause: true)
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
            videoPlayable?.clipRange = json["clipInfo"] as? CMTimeRange
        }
    }
    
    init(asset: AVAsset, min: CGFloat? = nil, max: CGFloat? = nil) {
        self.asset = asset
        self.minValue = min
        self.maxValue = max
    }
    
}
