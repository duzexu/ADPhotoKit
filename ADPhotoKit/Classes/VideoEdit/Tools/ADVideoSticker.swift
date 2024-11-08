//
//  ADImageSticker.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/6.
//

import Foundation

class ADVideoSticker: ADVideoEditTool {
    
    var image: UIImage {
        switch style {
        case .text:
            return Bundle.image(name: "icons_filled_text", module: .videoEdit) ?? UIImage()
        case .image:
            return Bundle.image(name: "icons_filled_sticker", module: .videoEdit) ?? UIImage()
        }
    }
    
    var isSelected: Bool = false
    
    var isEdited: Bool {
        let stkrs = stkrs.compactMap { $0.value }
        return stkrs.count > 0
    }
        
    var toolConfigView: ADToolConfigable?
    var toolInteractView: ADToolInteractable?
    weak var videoPlayable: ADVideoPlayable?
    
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)!
    
    private var stkrs: [ADWeakRef<ADStickerContentView>] = []
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        switch style {
        case .text:
            let sticker = ADEditConfigure.textStickerEditVC(sticker: nil)
            sticker.textDidEdit = { [weak self] image, sticker in
                let content = ADTextStickerContentView(image: image, sticker: sticker)
                self?.addContentView(.view(content))
            }
            sticker.modalPresentationStyle = .custom
            sticker.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
            ctx?.present(sticker, animated: true, completion: nil)
        case .image:
            let sticker = ADEditConfigure.imageStickerSelectVC()
            sticker.imageDidSelect = { [weak self] image in
                let content = ADImageStickerContentView(image: image)
                self?.addContentView(.view(content))
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
        let actionDataDidChange: (ADStickerActionData) -> Void = { _ in
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
            return "ADVideoSticker-Text"
        case .image:
            return "ADVideoSticker-Image"
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
            if let stkrs = json["stkrs"] as? [ADImageStickerInfo] {
                for item in stkrs {
                    addContentView(.info(item))
                }
            }
        }
    }
    
    enum ContentSource {
        case info(ADImageStickerInfo)
        case view(ADStickerContentView)
    }
    
    func addContentView(_ source: ContentSource) {
        let view = (toolInteractView as? ADStickerInteractView)
        switch source {
        case let .info(info):
            if let content = view?.addContentWithInfo(info) {
                stkrs.append(ADWeakRef(value: content))
            }
        case let .view(content):
            stkrs.append(ADWeakRef(value: content))
            view?.addContent(content)
        }
    }
    
}
