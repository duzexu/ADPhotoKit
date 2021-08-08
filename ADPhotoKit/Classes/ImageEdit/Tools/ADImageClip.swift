//
//  ADImageClip.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

class ADImageClip: ADImageEditTool {
    
    var image: UIImage {
        return Bundle.image(name: "clip", module: .imageEdit) ?? UIImage()
    }
    
    var isSelected: Bool = false
    
    var contentStatus: ((Bool) -> Void)?
    
    var toolConfigView: (UIView & ADToolConfigable)?
    var toolInteractView: (UIView & ADToolInteractable)?
    
    func toolDidSelect(ctx: ADImageProcessorable?) -> Bool {
        if let image = ctx?.process() {
            let clip = ADImageClipController(editInfo: ADEditInfo(image: image, editImage: image, clipRect: image, rotation: 0), editFromRect: .zero)
            clip.modalPresentationStyle = .overCurrentContext
            ctx?.present(clip, animated: true, completion: nil)
        }
        return false
    }
    
    func process() -> UIImage? {
        return nil
    }
    
}
