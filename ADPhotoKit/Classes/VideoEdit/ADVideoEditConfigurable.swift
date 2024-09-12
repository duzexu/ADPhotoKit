//
//  ADImageEditConfigurable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation
import UIKit
import AVFoundation

/// An `ADVideoEditTool` would be used to edit video.
public protocol ADVideoEditTool: ADEditTool {
        
    func setVideoPlayer<T: ADVideoPlayable>(_ player: ADWeakRef<T>)
    
}

public protocol ADVideoPlayable where Self: UIView {
    
    init(asset: AVAsset)
    
    func seek(to: CMTime, pause: Bool)
    
    func addProgressObserver(_ observer: @escaping (CGFloat) -> Void)
    
    func addOrUpdateSticker(_ stk: ADVideoStcker)
    
    func removeSticker(_ id: String)
    
    func setClipRange(_ range: CMTimeRange?)
    
    func setVideoSound(_ sound: ADVideoSound)
    
    func exportVideo(completionHandler handler: @escaping () -> Void)
    
}

public protocol ADVideoEditConfigurable where Self: UIViewController {
    
    var videoDidEdit: ((ADVideoEditInfo) -> Void)? { set get }
    
    var cancelEdit: (() -> Void)? { set get }
    
}

class ADVideoEditConfigure {
    
    static func videoEditVC(asset: AVAsset, editInfo: ADVideoEditInfo?, options: ADVideoEditOptions) -> ADVideoEditConfigurable {
        return ADPhotoKitConfiguration.default.customVideoEditVCBlock?(asset, editInfo, options) ?? ADVideoEditController(asset: asset, editInfo: editInfo, options: options)
    }
    
}
