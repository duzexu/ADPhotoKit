//
//  ADImageEditConfigurable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation
import UIKit

/// Edit action user perform.
public protocol ADEditAction {
    
    associatedtype Action
    
    /// Identifier of the action. It will be used to identify the action when
    /// undo and redo action. 
    ///
    /// - Note: You must use the identifier that corresponds to the tool. This way, the corresponding action can be dispatch to the correct tool
    var identifier: String { get }
    
    /// Data carried by action.
    var data: Action { set get }
}

/// Manager to undo or redo edit operation.
public protocol ADUndoManageable {
    
    /// Push new action to manager.
    /// - Parameter action: Edit action.
    func push(action: any ADEditAction)

}

/// Use to undo or redo edit operation.
public protocol ADEditToolUndoable {
    
    /// Tool's undo manager.
    var undoManager: ADUndoManageable { get }
    
    /// Called when undo action performed.
    /// - Parameter action: Edit action.
    func undo(action: any ADEditAction)
    
    /// Called when redo action performed.
    /// - Parameter action: Edit action.
    func redo(action: any ADEditAction)
        
}

extension ADEditToolUndoable {
     public var undoManager: ADUndoManageable { return ADUndoManager.shared }
}

/// An `ADImageEditTool` would be used to edit image.
public protocol ADImageEditTool: ADEditTool, ADEditToolUndoable {
    
    /// Block to lock or unlock edit content view. When lock, content view will scroll disabled.
    var contentLockStatus: ((Bool) -> Void)? { set get }
        
}

/// `ImageEditTool` can confirm this protocol to add ability to modify the original image.
public protocol ADSourceImageEditable {
    var modifySourceImage: ((UIImage) -> Void)? { get set }
}

/// `ImageEditTool` can confirm this protocol to add ability to do something when the original image is modify.
public protocol ADSourceImageModify {
    func sourceImageDidModify(_ image: UIImage)
}

/// Use to define image edit controller.
public protocol ADImageEditConfigurable where Self: UIViewController {
    
    /// Called when finish image edit.
    var imageDidEdit: ((ADImageEditInfo) -> Void)? { set get }
    
    /// Called when cancel image edit.
    var cancelEdit: (() -> Void)? { set get }
    
    /// Create image edit controller.
    /// - Parameters:
    ///   - image: Image to edit.
    ///   - editInfo: Edited info.
    init(image: UIImage, editInfo: ADImageEditInfo?)
    
}

/// Use to define Image clip controller.
public protocol ADImageClipConfigurable where Self: UIViewController {
    
    /// Called when clip finished.
    /// - Parameters:
    ///   - rect: Normalized clip rect. Return `nil` means no clip.
    ///   - rotation: Image rotation.
    var clipInfoConfirm: ((CGRect?, ADRotation) -> Void)? { get set }
    
    /// Create with clip info.
    /// - Parameter clipInfo: Image clip info.
    init(clipInfo: ADClipInfo)
    
}

class ADImageEditConfigure {
    
    static func imageEditVC(image: UIImage, editInfo: ADImageEditInfo?) -> ADImageEditConfigurable {
        return ADPhotoKitConfiguration.default.customImageEditVCBlock?(image, editInfo) ?? ADImageEditController(image: image, editInfo: editInfo)
    }
    
    static func imageClipVC(clipInfo: ADClipInfo) -> ADImageClipConfigurable {
        return ADPhotoKitConfiguration.default.customImageClipVCBlock?(clipInfo) ?? ADImageClipController(clipInfo: clipInfo)
    }
    
}
