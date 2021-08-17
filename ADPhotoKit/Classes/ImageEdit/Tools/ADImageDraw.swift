//
//  ADDraw.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

class ADImageDraw: ADImageEditTool {
    
    var image: UIImage
    var selectImage: UIImage?
    
    var isSelected: Bool = false {
        didSet {
            contentStatus?(isSelected)
        }
    }
    
    var contentStatus: ((Bool) -> Void)?
    
    var toolConfigView: (UIView & ADToolConfigable)?
    var toolInteractView: (UIView & ADToolInteractable)?
    
    func toolDidSelect(ctx: ADImageProcessorable?) -> Bool {
        switch style {
        case .line:
            break
        case .mosaic:
            break
        }
        return true
    }
    
    enum Style {
        case line([UIColor],Int)
        case mosaic(UIImage)
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
        switch style {
        case let .line(colors,index):
            let colorSelect = ADDrawColorsView(colors: colors, select: index)
            let interact = ADDrawInteractView(style: .line({ [weak colorSelect] in
                return colorSelect?.selectColor ?? .clear
            }))
            colorSelect.revokeAction = { [weak interact] in
                interact?.revoke()
            }
            interact.lineCountChange = { [weak colorSelect] count in
                colorSelect?.lineCount = count
            }
            toolInteractView = interact
            toolConfigView = colorSelect
            image = Bundle.image(name: "drawLine", module: .imageEdit) ?? UIImage()
            selectImage = Bundle.image(name: "drawLine_selected", module: .imageEdit)
        case let .mosaic(img):
            toolInteractView = ADDrawInteractView(style: .mosaic(img))
            image = Bundle.image(name: "mosaic", module: .imageEdit) ?? UIImage()
            selectImage = Bundle.image(name: "mosaic_selected", module: .imageEdit)
        }
        toolInteractView?.isOpaque = false
    }
    
}
