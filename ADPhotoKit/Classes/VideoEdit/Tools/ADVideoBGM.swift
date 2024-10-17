//
//  ADVideoBGM.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/9.
//

import Foundation

class ADVideoBGM: ADVideoEditTool {
        
    var image: UIImage {
        return videoSound.bgm == nil ? Bundle.image(name: "icons_filled_bgm", module: .videoEdit) ?? UIImage() : Bundle.image(name: "icons_filled_bgm_on", module: .videoEdit) ?? UIImage()
    }
    
    var isSelected: Bool = false
        
    var toolConfigView: ADToolConfigable?
    var toolInteractView: ADToolInteractable?
    
    weak var videoPlayable: ADVideoPlayable?
    
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)!
    
    var videoSound: ADVideoSound = .default
     
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        let bgm = ADVideoEditConfigure.videoMusicSelectVC(sound: videoSound)
        bgm.soundDidChange = { [weak self] sound in
            self?.videoSound = sound
            self?.videoPlayable?.videoSound = sound
        }
        bgm.playableRectUpdate = playableRectUpdate
        bgm.modalPresentationStyle = .custom
        bgm.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
        ctx?.present(bgm, animated: true, completion: nil)
        playableRectUpdate(bgm.bottomHeight, 0, true)
        return false
    }
    
    var identifier: String {
        return "ADVideoBGM"
    }
    
    func encode() -> Any? {
        return ["videoSound":videoSound]
    }
    
    func decode(from: Any) {
        if let json = from as? Dictionary<String,Any> {
            videoSound = json["videoSound"] as? ADVideoSound ?? .default
        }
    }
    
    init() {
        toolInteractView = ADStickerInteractView.shared
        let actionDataDidChange: (ADStickerActionData) -> Void = { [weak self] action in
            switch action {
            case let .update(old: _, new: new):
                if new == nil {
                    self?.videoSound.lyricOn = false
                }
            default:
                break
            }
        }
        ADStickerInteractView.shared.registHandle(ADStickerInteractHandle(actionDataDidChange: actionDataDidChange, contentViewWithInfo: { info in
            return ADLyricsStickerContentView(info: info)
        }), for: ADLyricsStickerInfo.self)
    }
}
