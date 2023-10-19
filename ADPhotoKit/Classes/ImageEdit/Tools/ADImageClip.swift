//
//  ADImageClip.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation
import UIKit

struct ADClipSource {
    let image: UIImage
    let clipImage: UIImage
    let clipFrom: CGRect
}

protocol ADImageClipSource: AnyObject {
    func clipSource() -> ADClipSource
    
    func clipInfoDidConfirmed(_ clipRect: CGRect?, rotation: ADRotation)
}

class ADImageClip: ADImageEditTool {
    
    var image: UIImage {
        return Bundle.image(name: "icons_filled_clip", module: .imageEdit) ?? UIImage()
    }
    
    var isSelected: Bool = false
    
    var contentLockStatus: ((Bool) -> Void)?
    
    var toolConfigView: (UIView & ADToolConfigable)?
    var toolInteractView: (UIView & ADToolInteractable)?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        if let sourceInfo = source?.clipSource() {
            let info = ADClipInfo(image: sourceInfo.image, clipRect: clipRect, rotation: rotation, clipImage: sourceInfo.clipImage, clipFrom: sourceInfo.clipFrom)
            let clip = ADImageEditConfigurable.imageClipVC(clipInfo: info)
            clip.clipInfoConfirmBlock = { [weak self] clipRect,rotation in
                self?.clipRect = clipRect
                self?.rotation = rotation
                self?.source?.clipInfoDidConfirmed(clipRect, rotation: rotation)
            }
            clip.modalPresentationStyle = .overCurrentContext
            ctx?.present(clip, animated: false, completion: nil)
        }
        return false
    }
    
    weak var source: ADImageClipSource?
    
    var clipRect: CGRect? = nil
    var rotation: ADRotation = .idle
    
    var isOrigin: Bool {
        return clipRect == nil && rotation == .idle
    }
    
    init(source: ADImageClipSource) {
        self.source = source
    }
    
    var identifier: String {
        return "ADImageClip"
    }
    
    func encode() -> Any? {
        if !isOrigin {
            if clipRect == nil {
                return ["rotation":rotation]
            }else{
                return ["clipRect":clipRect!,"rotation":rotation]
            }
        }
        return nil
    }
    
    func decode(from: Any) {
        if let json = from as? Dictionary<String,Any> {
            clipRect = json["clipRect"] as? CGRect
            rotation = json["rotation"] as? ADRotation ?? .idle
        }
        source?.clipInfoDidConfirmed(clipRect, rotation: rotation)
    }
    
}
