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
    
    var isEdited: Bool {
        return videoSound.lyricOn || !videoSound.ostOn || videoSound.bgm != nil || !videoSound.bgmLoop
    }
        
    var toolConfigView: ADToolConfigable?
    var toolInteractView: ADToolInteractable?
    
    weak var videoPlayable: ADVideoPlayable?
    
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)!
    var soundDidChange: ((ADVideoSound) -> Void)!
    
    var videoSound: ADVideoSound = ADVideoSound()
     
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        let bgm = ADVideoEditConfigure.videoMusicSelectVC(sound: videoSound)
        bgm.soundDidChange = soundDidChange
        bgm.playableRectUpdate = playableRectUpdate
        bgm.modalPresentationStyle = .custom
        bgm.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
        ctx?.present(bgm, animated: true, completion: nil)
        return false
    }
    
    var identifier: String {
        return "ADVideoBGM"
    }
    
    func encode() -> Any? {
        if let content = ADStickerInteractView.shared.contentWithId(ADLyricsStickerContentView.LyricsStickerId) as? ADLyricsStickerContentView {
            return ["videoSound":videoSound,"stk":content.stickerInfo]
        }else{
            return ["videoSound":videoSound]
        }
    }
    
    func decode(from: Any) {
        if let json = from as? Dictionary<String,Any> {
            videoSound = json["videoSound"] as? ADVideoSound ?? ADVideoSound()
            if let info = json["stk"] as? ADLyricsStickerInfo {
                ADStickerInteractView.shared.addContentWithInfo(info)
            }
        }
        videoPlayable?.videoSound = videoSound
    }
    
    init() {
        soundDidChange = { [weak self] sound in
            self?.soundConfigChange(sound: sound)
        }
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
    
    func soundConfigChange(sound: ADVideoSound) {
        videoSound = sound
        videoPlayable?.videoSound = sound
        if sound.lyricOn, let music = sound.bgm {
            if let content = ADStickerInteractView.shared.contentWithId(ADLyricsStickerContentView.LyricsStickerId) as? ADLyricsStickerContentView {
                if music.id != content.music.id {
                    content.updateMusic(music)
                }
            }else{
                let content = ADLyricsStickerContentView(music: music)
                content.soundDidChange = soundDidChange
                content.playableRectUpdate = playableRectUpdate
                ADStickerInteractView.shared.addContent(content)
            }
        }else{
            ADStickerInteractView.shared.removeContent(ADLyricsStickerContentView.LyricsStickerId)
        }
    }
}
