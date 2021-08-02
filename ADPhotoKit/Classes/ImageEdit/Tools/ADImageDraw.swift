//
//  ADDraw.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

class ADImageDraw: ImageEditTool {
    
    var image: UIImage
    var selectImage: UIImage?
    
    var isSelected: Bool = false {
        didSet {
            contentStatus?(isSelected)
        }
    }
    
    var contentStatus: ((Bool) -> Void)?
    
    var toolConfigView: (UIView & ToolConfigable)?
    var toolInteractView: (UIView & ToolInteractable)?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
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
        return nil
    }
    
    let style: Style
    
    init(style: Style) {
        self.style = style
        switch style {
        case let .line(colors,index):
            let colorSelect = ADDrawColorsView(colors: colors, select: index)
            toolInteractView = ADDrawInteractView(style: .line({
                return colorSelect.selectColor
            }))
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
