//
//  ADUndoManager.swift
//  ADPhotoKit
//
//  Created by du on 2024/8/24.
//

import Foundation

protocol ADUndoManagerDelegate: AnyObject {
    
    func update(canUndo: Bool, canRedo: Bool)
    
}

class ADUndoManager: ADUndoManageable {
    
    public static let shared = ADUndoManager()
    
    weak var delegate: ADUndoManagerDelegate? {
        didSet {
            update()
        }
    }
    
    private(set) var undoActions: [any ADEditAction] = []
    private(set) var redoActions: [any ADEditAction] = []
    
    private var toolInfos: [String:ADWeakRef<AnyObject>] = [:]
    
    func regist(tool: ADImageEditTool) {
        toolInfos[tool.identifier] = ADWeakRef(value: tool)
    }
    
    public func push(action: any ADEditAction) {
        undoActions.append(action)
        redoActions = undoActions
        update()
    }
    
    func clear() {
        undoActions.removeAll()
        redoActions.removeAll()
        update()
        toolInfos.removeAll()
    }
    
    func undo() {
        guard let action = undoActions.popLast() else { return }
        if let tool = toolInfos[action.identifier]?.value as? ADImageEditTool {
            tool.undo(action: action)
        }
        update()
    }
    
    func redo() {
        guard undoActions.count < redoActions.count else { return }
        let action = redoActions[undoActions.count]
        undoActions.append(action)
        if let tool = toolInfos[action.identifier]?.value as? ADImageEditTool {
            tool.redo(action: action)
        }
        update()
    }
    
    func update() {
        delegate?.update(canUndo: undoActions.count != 0, canRedo: redoActions.count != undoActions.count)
    }
    
}
