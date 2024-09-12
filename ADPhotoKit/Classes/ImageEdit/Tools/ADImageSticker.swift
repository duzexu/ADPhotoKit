//
//  ADImageSticker.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation
import UIKit

class ADStickerAction: ADEditAction {
    var data: ADStickerActionData
    let identifier: String
    
    init(data: ADStickerActionData, identifier: String) {
        self.data = data
        self.identifier = identifier
    }
}

class ADImageSticker: ADImageEditTool {
    
    var image: UIImage {
        switch style {
        case .text:
            return Bundle.image(name: "icons_filled_text", module: .imageEdit) ?? UIImage()
        case .image:
            return Bundle.image(name: "icons_filled_sticker", module: .imageEdit) ?? UIImage()
        }
    }
    
    var isSelected: Bool = false
    
    var contentLockStatus: ((Bool) -> Void)?
    
    var toolConfigView: ADToolConfigable?
    var toolInteractView: ADToolInteractable?
    
    private var stkrs: [ADWeakRef<ADStickerContentView>] = []
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        switch style {
        case .text:
            let sticker = ADEditConfigure.textStickerEditVC(sticker: nil)
            sticker.textDidEdit = { [weak self] image, sticker in
                let content = ADTextStickerContentView(image: image, sticker: sticker)
                self?.stkrs.append(ADWeakRef(value: content))
                (self?.toolInteractView as? ADStickerInteractView)?.addContent(content)
                self?.undoManager.push(action: ADStickerAction(data: .update(old: nil, new: content.stickerInfo), identifier: self!.identifier))
            }
            sticker.modalPresentationStyle = .custom
            sticker.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
            ctx?.present(sticker, animated: true, completion: nil)
        case .image:
            let sticker = ADEditConfigure.imageStickerSelectVC()
            sticker.imageDidSelect = { [weak self] image in
                let content = ADImageStickerContentView(image: image)
                self?.stkrs.append(ADWeakRef(value: content))
                (self?.toolInteractView as? ADStickerInteractView)?.addContent(content)
                self?.undoManager.push(action: ADStickerAction(data: .update(old: nil, new: content.stickerInfo), identifier: self!.identifier))
            }
            sticker.modalPresentationStyle = .custom
            sticker.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
            ctx?.present(sticker, animated: true, completion: nil)
        }
        return false
    }
    
    enum Style {
        case text
        case image
    }
    
    let style: Style
    
    init(style: Style) {
        self.style = style
        toolInteractView = ADStickerInteractView.shared
        let actionDataDidChange: (ADStickerActionData) -> Void = { [weak self] action in
            self?.undoManager.push(action: ADStickerAction(data: action, identifier: self!.identifier))
        }
        switch style {
        case .text:
            ADStickerInteractView.shared.registHandle(ADStickerInteractHandle(actionDataDidChange: actionDataDidChange, contentViewWithInfo: { info in
                return ADTextStickerContentView(info: info)
            }), for: ADTextStickerInfo.self)
        case .image:
            ADStickerInteractView.shared.registHandle(ADStickerInteractHandle(actionDataDidChange: actionDataDidChange, contentViewWithInfo: { info in
                return ADImageStickerContentView(info: info)
            }), for: ADImageStickerInfo.self)
        }
    }
    
    var identifier: String {
        switch style {
        case .text:
            return "ADImageSticker-Text"
        case .image:
            return "ADImageSticker-Image"
        }
    }
    
    func encode() -> Any? {
        let stkrs: [ADStickerInfo] = stkrs.compactMap { $0.value }.map { obj in
            return obj.stickerInfo
        }
        return ["stkrs":stkrs]
    }
    
    func decode(from: Any) {
        if let json = from as? Dictionary<String,Any> {
            if let stkrs = json["stkrs"] as? [ADStickerInfo] {
                for item in stkrs {
                    if let content = (toolInteractView as? ADStickerInteractView)?.addContentWithInfo(item) {
                        self.stkrs.append(ADWeakRef(value: content))
                    }
                }
            }
        }
    }
    
    func undo(action: any ADEditAction) {
        if let action = action as? ADStickerAction {
            if let content = (toolInteractView as? ADStickerInteractView)?.undo(action: action.data) {
                stkrs.append(ADWeakRef(value: content))
            }
        }
    }
    
    func redo(action: any ADEditAction) {
        if let action = action as? ADStickerAction {
            if let content = (toolInteractView as? ADStickerInteractView)?.redo(action: action.data) {
                stkrs.append(ADWeakRef(value: content))
            }
        }
    }
    
}
