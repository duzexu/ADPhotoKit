//
//  ADImageSticker.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

class ADImageSticker: ADImageEditTool {
    
    var image: UIImage {
        switch style {
        case .text(_):
            return Bundle.image(name: "textSticker", module: .imageEdit) ?? UIImage()
        case .image(_):
            return Bundle.image(name: "imageSticker", module: .imageEdit) ?? UIImage()
        }
    }
    
    var isSelected: Bool = false
    
    var contentStatus: ((Bool) -> Void)?
    
    var toolConfigView: (UIView & ADToolConfigable)?
    var toolInteractView: (UIView & ADToolInteractable)?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        switch style {
        case .text(_):
            let sticker = ADImageEditConfigurable.textStickerEditVC()
            sticker.textDidEdit = { text, color in
                
            }
            sticker.modalPresentationStyle = .custom
            sticker.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
            ctx?.present(sticker, animated: true, completion: nil)
        case .image(_):
            let sticker = ADImageEditConfigurable.imageStickerSelectVC()
            sticker.imageDidSelect = { image in
                let content = ADImageStickerContentView(image: image)
                ADStickerInteractView.share.addContent(content)
            }
            sticker.modalPresentationStyle = .custom
            sticker.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
            ctx?.present(sticker, animated: true, completion: nil)
        }
        return false
    }
    
    enum Style {
        case text([UIColor])
        case image([UIImage])
    }
    
    func process() -> UIImage? {
        guard let interactView = toolInteractView else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(interactView.bounds.size, false, UIScreen.main.scale)
        if let ctx = UIGraphicsGetCurrentContext() {
            interactView.layer.render(in: ctx)
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    let style: Style
    
    init(style: Style) {
        self.style = style
        toolInteractView = ADStickerInteractView.share
    }
    
}
