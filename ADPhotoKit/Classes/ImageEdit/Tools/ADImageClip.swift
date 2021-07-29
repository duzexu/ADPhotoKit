//
//  ADImageClip.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

class ADImageClip: ImageEditTool {
    
    var image: UIImage {
        return Bundle.image(name: "clip", module: .imageEdit) ?? UIImage()
    }
    
    var isSelected: Bool = false
    
    var contentStatus: ((Bool) -> Void)?
    
    var toolConfigView: (UIView & ToolConfigable)?
    var toolInteractView: (UIView & ToolInteractable)?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        let clip = ADImageClipController()
        clip.modalPresentationStyle = .overCurrentContext
        ctx?.present(clip, animated: true, completion: nil)
        return false
    }
    
    func process() -> UIImage? {
        return nil
    }
    
}
