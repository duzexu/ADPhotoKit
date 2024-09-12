//
//  ADVideoBGM.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/9.
//

import Foundation

class ADVideoBGM: ADVideoEditTool {
    
    var image: UIImage {
        return Bundle.image(name: "icons_video_clip", module: .videoEdit) ?? UIImage()
    }
    
    var isSelected: Bool = false
        
    var toolConfigView: ADToolConfigable?
    var toolInteractView: ADToolInteractable?
     
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        let bgm = ADMusicSelectController()
        bgm.modalPresentationStyle = .custom
        bgm.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
        ctx?.present(bgm, animated: true, completion: nil)
        return false
    }
    
    var identifier: String {
        return "ADVideoBGM"
    }
    
    func encode() -> Any? {
        return nil
    }
    
    func decode(from: Any) {
        
    }
    
    func setVideoPlayer<T: ADVideoPlayable>(_ player: ADWeakRef<T>) {
        
    }
    
}
