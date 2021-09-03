//
//  ADImageClip.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

struct ADClipInfo {
    let image: UIImage
    var clipRect: CGRect?
    var rotation: ADRotation
    
    let clipImage: UIImage
    let clipFrom: CGRect
    
    var isOrigin: Bool {
        return clipRect == nil && rotation == .idle
    }
}

protocol ADImageClipSource {
    func clipInfo() -> ADClipInfo
    
    func clipInfoDidConfirmed(_ clipRect: CGRect?, rotation: ADRotation)
}

class ADImageClip: ADImageEditTool {
    
    var image: UIImage {
        return Bundle.image(name: "clip", module: .imageEdit) ?? UIImage()
    }
    
    var isSelected: Bool = false
    
    var contentStatus: ((Bool) -> Void)?
    
    var toolConfigView: (UIView & ADToolConfigable)?
    var toolInteractView: (UIView & ADToolInteractable)?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        let clip = ADImageClipController(clipInfo: source.clipInfo())
        clip.clipInfoConfirmBlock = { [weak self] clipRect,rotation in
            self?.source.clipInfoDidConfirmed(clipRect, rotation: rotation)
        }
        clip.modalPresentationStyle = .overCurrentContext
        ctx?.present(clip, animated: false, completion: nil)
        return false
    }
    
    let source: ADImageClipSource
    
    init(source: ADImageClipSource) {
        self.source = source
    }
    
}
