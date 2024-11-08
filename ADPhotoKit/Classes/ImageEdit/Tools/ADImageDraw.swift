//
//  ADDraw.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation
import UIKit

enum DrawActionData {
    case draw(DrawPath)
    case erase([DrawPath])
}

class ADDrawAction: ADEditAction {
    var data: DrawActionData
    let identifier: String
    
    init(data: DrawActionData, identifier: String) {
        self.data = data
        self.identifier = identifier
    }
}

class ADImageDraw: ADImageEditTool {
    
    var image: UIImage
    var selectImage: UIImage?
    
    var isSelected: Bool = false {
        didSet {
            contentLockStatus?(isSelected)
        }
    }
    
    var isEdited: Bool {
        if let interact = toolInteractView as? ADDrawInteractView {
            return interact.paths.count > 0
        }
        return false
    }
    
    var contentLockStatus: ((Bool) -> Void)?
    
    var toolConfigView: ADToolConfigable?
    var toolInteractView: ADToolInteractable?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
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
            let colorSelect = ADLineDrawView(colors: colors, select: index)
            let interact = ADDrawInteractView(style: .line({ [weak colorSelect] in
                return colorSelect?.selectColor ?? .clear
            }))
            colorSelect.eraseAction = { [weak interact] sel in
                interact?.erase = sel
            }
            toolInteractView = interact
            toolConfigView = colorSelect
            image = Bundle.image(name: "icons_filled_pencil3", module: .imageEdit) ?? UIImage()
            selectImage = Bundle.image(name: "icons_filled_pencil3_on", module: .imageEdit)
            interact.actionsDidChange = { [weak self] data in
                self?.undoManager.push(action: ADDrawAction(data: data, identifier: self!.identifier))
            }
        case let .mosaic(img):
            let config = ADMosaicDrawView()
            let interact = ADDrawInteractView(style: .mosaic(img))
            config.eraseAction = { [weak interact] sel in
                interact?.erase = sel
            }
            toolInteractView = interact
            toolConfigView = config
            image = Bundle.image(name: "icons_filled_mosaic", module: .imageEdit) ?? UIImage()
            selectImage = Bundle.image(name: "icons_filled_mosaic_on", module: .imageEdit)
            interact.actionsDidChange = { [weak self] data in
                self?.undoManager.push(action: ADDrawAction(data: data, identifier: self!.identifier))
            }
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
    }
    
    func undo(action: any ADEditAction) {
        if let action = action as? ADDrawAction {
            (toolInteractView as? ADDrawInteractView)?.undo(action: action.data)
        }
    }
    
    func redo(action: any ADEditAction) {
        if let action = action as? ADDrawAction {
            (toolInteractView as? ADDrawInteractView)?.redo(action: action.data)
        }
    }
    
}

extension ADImageDraw: ADSourceImageModify {
    func sourceImageDidModify(_ image: UIImage) {
        switch style {
        case .line(_, _):
            break
        case .mosaic(_):
            (toolInteractView as? ADDrawInteractView)?.sourceImageDidModify(image)
        }
    }
}
