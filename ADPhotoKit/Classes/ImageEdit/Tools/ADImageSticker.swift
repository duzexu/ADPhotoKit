//
//  ADImageSticker.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

struct ADStickerInfo {
    let image: UIImage
    let transform: CGAffineTransform
    let outerScale: CGFloat
    let center: CGPoint
    let sticker: ADTextSticker?
}

class ADImageSticker: ADImageEditTool {
    
    var image: UIImage {
        switch style {
        case .text:
            return Bundle.image(name: "icons_filled_text2", module: .imageEdit) ?? UIImage()
        case .image:
            return Bundle.image(name: "icons_filled_sticker", module: .imageEdit) ?? UIImage()
        }
    }
    
    var isSelected: Bool = false
    
    var contentStatus: ((Bool) -> Void)?
    
    var toolConfigView: (UIView & ADToolConfigable)?
    var toolInteractView: (UIView & ADToolInteractable)?
    
    private var textStkrs: [ADWeakProxy] = []
    private var imageStkrs: [ADWeakProxy] = []
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        switch style {
        case .text:
            let sticker = ADImageEditConfigurable.textStickerEditVC(sticker: nil)
            sticker.textDidEdit = { [weak self] image, sticker in
                let content = ADTextStickerContentView(image: image, sticker: sticker)
                self?.textStkrs.append(ADWeakProxy(target: content))
                ADStickerInteractView.share.addContent(content)
            }
            sticker.modalPresentationStyle = .custom
            sticker.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
            ctx?.present(sticker, animated: true, completion: nil)
        case .image:
            let sticker = ADImageEditConfigurable.imageStickerSelectVC()
            sticker.imageDidSelect = { [weak self] image in
                let content = ADImageStickerContentView(image: image)
                self?.imageStkrs.append(ADWeakProxy(target: content))
                ADStickerInteractView.share.addContent(content)
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
        toolInteractView = ADStickerInteractView.share
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
        switch style {
        case .text:
            let stkrs: [ADStickerInfo] = textStkrs.compactMap { $0.target }.map { obj in
                let content = (obj as! ADTextStickerContentView)
                return ADStickerInfo(image: content.image, transform: content.transform, outerScale: content.outerScale, center: content.center, sticker: content.sticker)
            }
            return ["stkrs":stkrs]
        case .image:
            let stkrs: [ADStickerInfo] = imageStkrs.compactMap { $0.target }.map { obj in
                let content = obj as! ADImageStickerContentView
                return ADStickerInfo(image: content.image, transform: content.transform, outerScale: content.outerScale, center: content.center, sticker: nil)
            }
            return ["stkrs":stkrs]
        }
    }
    
    func decode(from: Any) {
        if let json = from as? Dictionary<String,Any> {
            if let stkrs = json["stkrs"] as? [ADStickerInfo] {
                switch style {
                case .text:
                    for item in stkrs {
                        let content = ADTextStickerContentView(image: item.image, sticker: item.sticker!)
                        content.transform = item.transform
                        content.center = item.center
                        content.outerScale = item.outerScale
                        textStkrs.append(ADWeakProxy(target: content))
                        ADStickerInteractView.share.appendContent(content)
                    }
                case .image:
                    for item in stkrs {
                        let content = ADImageStickerContentView(image: item.image)
                        content.transform = item.transform
                        content.center = item.center
                        content.outerScale = item.outerScale
                        imageStkrs.append(ADWeakProxy(target: content))
                        ADStickerInteractView.share.appendContent(content)
                    }
                }
            }
        }
    }
    
}
