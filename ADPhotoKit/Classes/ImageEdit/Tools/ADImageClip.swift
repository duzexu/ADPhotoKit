//
//  ADImageClip.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation
import UIKit

struct ADClipSource {
    let image: UIImage
    let clipImage: UIImage
    let clipFrom: CGRect
}

protocol ADImageClipSource: AnyObject {
    func clipSource() -> ADClipSource
    
    func clipInfoDidConfirmed(_ clipRect: CGRect?, rotation: ADRotation)
}

enum ClipActionData {
    case update(old: ClipInfo, new: ClipInfo)
}

struct ClipInfo {
    var clipRect: CGRect? = nil
    var rotation: ADRotation = .idle
}

class ADClipAction: ADEditAction {
    var data: ClipActionData
    let identifier: String
    
    init(data: ClipActionData, identifier: String) {
        self.data = data
        self.identifier = identifier
    }
}

class ADImageClip: ADImageEditTool {
    
    var image: UIImage {
        return Bundle.image(name: "icons_filled_clip", module: .imageEdit) ?? UIImage()
    }
    
    var isSelected: Bool = false
    
    var contentLockStatus: ((Bool) -> Void)?
    
    var toolConfigView: ADToolConfigable?
    var toolInteractView: ADToolInteractable?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        if let sourceInfo = source?.clipSource() {
            let info = ADClipInfo(image: sourceInfo.image, clipRect: clipInfo.clipRect, rotation: clipInfo.rotation, clipImage: sourceInfo.clipImage, clipFrom: sourceInfo.clipFrom)
            let clip = ADImageEditConfigure.imageClipVC(clipInfo: info)
            clip.clipInfoConfirmBlock = { [weak self] clipRect,rotation in
                let new = ClipInfo(clipRect: clipRect, rotation: rotation)
                self?.source?.clipInfoDidConfirmed(clipRect, rotation: rotation)
                self?.undoManager.push(action: ADClipAction(data: .update(old: self!.clipInfo, new: new), identifier: self!.identifier))
                self?.clipInfo = new
            }
            clip.modalPresentationStyle = .overCurrentContext
            ctx?.present(clip, animated: false, completion: nil)
        }
        return false
    }
    
    weak var source: ADImageClipSource?
    
    var clipInfo = ClipInfo()
    
    var isOrigin: Bool {
        return clipInfo.clipRect == nil && clipInfo.rotation == .idle
    }
    
    init(source: ADImageClipSource) {
        self.source = source
    }
    
    var identifier: String {
        return "ADImageClip"
    }
    
    func encode() -> Any? {
        if !isOrigin {
            if clipInfo.clipRect == nil {
                return ["rotation":clipInfo.rotation]
            }else{
                return ["clipRect":clipInfo.clipRect!,"rotation":clipInfo.rotation]
            }
        }
        return nil
    }
    
    func decode(from: Any) {
        if let json = from as? Dictionary<String,Any> {
            clipInfo.clipRect = json["clipRect"] as? CGRect
            clipInfo.rotation = json["rotation"] as? ADRotation ?? .idle
        }
        source?.clipInfoDidConfirmed(clipInfo.clipRect, rotation: clipInfo.rotation)
    }
    
    func undo(action: any ADEditAction) {
        if let action = action as? ADClipAction {
            switch action.data {
            case .update(let old, _):
                source?.clipInfoDidConfirmed(old.clipRect, rotation: old.rotation)
                clipInfo = old
            }
        }
    }
    
    func redo(action: any ADEditAction) {
        if let action = action as? ADClipAction {
            switch action.data {
            case .update(_, let new):
                source?.clipInfoDidConfirmed(new.clipRect, rotation: new.rotation)
                clipInfo = new
            }
        }
    }
    
}
