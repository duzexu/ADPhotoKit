//
//  ADImageSticker.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

class ADImageSticker: ImageEditTool {
    
    var image: UIImage {
        switch style {
        case .text(_):
            return Bundle.image(name: "textSticker", module: .imageEdit) ?? UIImage()
        case .image(_):
            return Bundle.image(name: "imageSticker", module: .imageEdit) ?? UIImage()
        }
    }
    
    var isSelected: Bool = false
    
    var toolConfigView: UIView?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        switch style {
        case .text(_):
            let sticker = ADTextStickerEditController()
            sticker.modalPresentationStyle = .overCurrentContext
            ctx?.present(sticker, animated: true, completion: nil)
        case .image(_):
            let sticker = ADImageStickerSelectController()
            sticker.modalPresentationStyle = .overCurrentContext
            ctx?.present(sticker, animated: true, completion: nil)
        }
        return false
    }
    
    enum Style {
        case text([UIColor])
        case image([UIImage])
    }
    
    func process() -> UIImage? {
        return nil
    }
    
    let style: Style
    
    init(style: Style) {
        self.style = style
    }
    
}
