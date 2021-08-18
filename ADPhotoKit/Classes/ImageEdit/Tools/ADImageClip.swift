//
//  ADImageClip.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

struct ADClipInfo {
    let image: UIImage
    let clipRect: CGRect?
    let rotation: CGFloat?
    
    let clipImage: UIImage
    let clipFrom: CGRect
}

protocol ADImageClipSource {
    func clipInfo() -> ADClipInfo
    
    func clipRectDidConfirmed(_ rect: CGRect?)
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
        let clip = ADImageClipController(cilpInfo: source.clipInfo())
        clip.clipRectConfirmBlock = { [weak self] rect in
            self?.source.clipRectDidConfirmed(rect)
        }
        clip.modalPresentationStyle = .overCurrentContext
        ctx?.present(clip, animated: false, completion: nil)
        return false
    }
    
    func process() -> UIImage? {
        return nil
    }
    
    let source: ADImageClipSource
    
    init(source: ADImageClipSource) {
        self.source = source
    }
    
}
