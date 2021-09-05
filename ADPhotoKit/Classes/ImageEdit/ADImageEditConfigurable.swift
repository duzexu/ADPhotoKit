//
//  ADImageEditConfigurable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

public protocol ImageProcessor: AnyObject {
    
    func process() -> UIImage?
    
}

public protocol ADImageEditTool: AnyObject {
    
    var image: UIImage { get }
    var selectImage: UIImage? { get }
    var isSelected: Bool { set get }
    
    var contentStatus: ((Bool) -> Void)? { set get }
    
    var toolConfigView: (UIView & ADToolConfigable)? { set get }
    var toolInteractView: (UIView & ADToolInteractable)? { set get }
    
    func toolDidSelect(ctx: UIViewController?) -> Bool
        
}

public extension ADImageEditTool {
    var selectImage: UIImage? { return nil }
}

public protocol ADToolConfigable {
    func singleTap(with point: CGPoint) -> Bool
}

extension ADToolConfigable {
    public func singleTap(with point: CGPoint) -> Bool {
        return false
    }
}

public enum ADInteractZIndex: Int {
    case Top = 100
    case Mid = 50
    case Bottom = 0
}

public enum ADInteractPolicy {
    case simult //同时相应
    case single
    case none
}

public enum ADInteractType {
    case pan(loc: CGPoint, trans: CGPoint)
    case pinch(scale: CGFloat, point: CGPoint)
    case rotate(angle: CGFloat, point: CGPoint)
}

public typealias ADClipingInfo = (screen: CGRect, clip: CGRect, rotate: ADRotation, scale: CGFloat)

public protocol ADToolInteractable {
    
    var zIndex: Int { get }
    
    var policy: ADInteractPolicy { get }
    
    var interactClipBounds: Bool { get }
    
    var clipingScreenInfo: ADClipingInfo? { set get }
        
    func shouldInteract(_ gesture: UIGestureRecognizer, point: CGPoint) -> Bool
    
    func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) -> TimeInterval?
    
    func willBeginRenderImage()
    
    func didEndRenderImage()
}

extension ADToolInteractable {
    public func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) -> Bool { return true }
    
    public func willBeginRenderImage() { }
    
    public func didEndRenderImage() { }
}

public typealias ADImageStickerSelectable = (UIViewController & ADImageStickerSelectConfigurable)
public protocol ADImageStickerSelectConfigurable: AnyObject {
    
    var imageDidSelect: ((UIImage) -> Void)? { get set }
    
}

public typealias ADTextStickerColor = (textColor: UIColor, bgColor: UIColor)

public struct ADTextSticker {
    public enum Style {
        case normal
        case border
    }
    
    public var color: ADTextStickerColor
    public var style: Style = .normal
    public var text: String?
}

public typealias ADTextStickerEditable = (UIViewController & ADTextStickerEditConfigurable)
public protocol ADTextStickerEditConfigurable: AnyObject {
    
    var textDidEdit: ((UIImage, ADTextSticker) -> Void)? { get set }
    
}

public class ADImageEditConfigurable {
    
    static func imageStickerSelectVC() -> ADImageStickerSelectable {
        return ADPhotoKitConfiguration.default.customImageStickerSelectVC ?? ADImageStickerSelectController(dataSource: ADPhotoKitConfiguration.default.imageStickerDataSource!)
    }
    
    static func textStickerEditVC(sticker: ADTextSticker?) -> ADTextStickerEditable {
        return ADPhotoKitConfiguration.default.customTextStickerEditVCBlock?(sticker) ?? ADTextStickerEditController(sticker: sticker)
    }
    
}
