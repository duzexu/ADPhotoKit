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

public protocol ImageEditTool: ImageProcessor {
    
    var image: UIImage { get }
    var selectImage: UIImage? { get }
    var isSelected: Bool { set get }
    
    var contentStatus: ((Bool) -> Void)? { set get }
    
    var toolConfigView: (UIView & ToolConfigable)? { set get }
    var toolInteractView: (UIView & ToolInteractable)? { set get }
    
    func toolDidSelect(ctx: UIViewController?) -> Bool
        
}

public extension ImageEditTool {
    var selectImage: UIImage? { return nil }
}

public protocol ToolConfigable {
    func singleTap(with point: CGPoint) -> Bool
}

extension ToolConfigable {
    public func singleTap(with point: CGPoint) -> Bool {
        return false
    }
}

public enum InteractZIndex: Int {
    case Top = 100
    case Mid = 50
    case Bottom = 0
}

public enum InteractPolicy {
    case simult //同时相应
    case single
    case none
}

public enum InteractType {
    case pan(loc: CGPoint, trans: CGPoint)
    case pinch(CGFloat)
    case rotate(CGFloat)
}

public protocol ToolInteractable {
    
    var zIndex: Int { get }
    
    var interactPolicy: InteractPolicy { get }
    
    var isInteracting: Bool { set get }
    
    func shouldInteract(_ gesture: UIGestureRecognizer, point: CGPoint) -> Bool
        
    func interact(with type: InteractType, scale: CGFloat, state: UIGestureRecognizer.State)
}

extension ToolInteractable {
    public func interact(with type: InteractType, scale: CGFloat, state: UIGestureRecognizer.State) { }
}

public typealias ADImageStickerSelectable = (UIViewController & ADImageStickerSelectConfigurable)
public protocol ADImageStickerSelectConfigurable: AnyObject {
    
    var imageDidSelect: ((UIImage) -> Void)? { get set }
    
}

class ADImageEditConfigurable {
    
    static func imageStickerSelectVC() -> ADImageStickerSelectable {
        return ADPhotoKitConfiguration.default.customImageStickerSelectVC ?? ADImageStickerSelectController()
    }
    
}
