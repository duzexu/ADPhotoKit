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
            image = Bundle.image(name: "icons_filled_pencil3", module: .imageEdit) ?? UIImage()
            selectImage = Bundle.image(name: "icons_filled_pencil3_on", module: .imageEdit)
        case let .mosaic(img):
            toolInteractView = ADDrawInteractView(style: .mosaic(img))
            image = Bundle.image(name: "icons_filled_mosaic", module: .imageEdit) ?? UIImage()
            selectImage = Bundle.image(name: "icons_filled_mosaic_on", module: .imageEdit)
        }
        toolInteractView?.isOpaque = false
    }
    
    var identifier: String {
        switch style {
        case .line:
            return "ADImageDraw-Line"
        case .mosaic:
            return "ADImageDraw-Mosaic"
        }
    }
    
    func encode() -> Any? {
        if let interact = toolInteractView as? ADDrawInteractView {
            if interact.paths.count > 0 {
                return ["paths":interact.paths]
            }
        }
        return nil
    }
    
    func decode(from: Any) {
        if let json = from as? Dictionary<String,Any> {
            if let paths = json["paths"] as? [DrawPath] {
                (toolInteractView as? ADDrawInteractView)?.paths = paths
            }
        }
        switch style {
        case .line:
            (toolConfigView as? ADDrawColorsView)?.lineCount = 0
        case .mosaic:
            break
        }
    }
    
}
