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
    
    var isSelected: Bool = false
    
    var toolConfigView: UIView?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        switch style {
        case .line(_):
            break
        case .mosaic:
            break
        }
        return true
    }
    
    enum Style {
        case line([UIColor])
        case mosaic
    }
    
    func process() -> UIImage? {
        return nil
    }
    
    let style: Style
    
    init(style: Style) {
        self.style = style
        switch style {
        case .line(_):
            toolConfigView = UIView()
            image = Bundle.image(name: "drawLine", module: .imageEdit) ?? UIImage()
            selectImage = Bundle.image(name: "drawLine_selected", module: .imageEdit)
        case .mosaic:
            image = Bundle.image(name: "mosaic", module: .imageEdit) ?? UIImage()
            selectImage = Bundle.image(name: "mosaic_selected", module: .imageEdit)
        }
    }
    
}
