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

public protocol ToolInteractable {
    
    var zIndex: Int { get }
    
    func move(to point: CGPoint, scale: CGFloat, state: UIPanGestureRecognizer.State)
}

extension ToolInteractable {
    public func move(to point: CGPoint, scale: CGFloat, state: UIPanGestureRecognizer.State) { }
}
