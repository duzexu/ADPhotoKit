//
//  ADVideoStickerContentView.swift
//  ADPhotoKit
//
//  Created by du on 2024/10/16.
//

import UIKit
import CoreMedia

class ADVideoStickerContentView: ADStickerContentView {

    open func playerTimeUpdate(_ time: CMTime) {
        
    }

}

extension ADStickerInteractView {
    func updatePlayerTime(_ time: CMTime) {
        for sub in container.subviews {
            if let sub = sub as? ADVideoStickerContentView {
                sub.playerTimeUpdate(time)
            }
        }
    }
}
