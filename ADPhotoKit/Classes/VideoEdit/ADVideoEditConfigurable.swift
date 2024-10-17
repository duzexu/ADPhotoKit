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
    
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)! { set get }
    
    var videoPlayable: ADVideoPlayable? { set get }
    
}

public protocol ADVideoPlayable where Self: UIView {
    
    var clipRange: CMTimeRange? { set get }
    
    var videoSound: ADVideoSound { set get }
    
    init(asset: AVAsset)
    
    func pause(seekToZero: Bool)
    
    func play()
    
    func seek(to: CMTime, pause: Bool)
    
    func addProgressObserver(_ observer: @escaping (_ progress: CGFloat, _ time: CMTime) -> Void)
    
    func addOrUpdateSticker(_ stk: ADVideoStcker)
    
    func removeSticker(_ id: String)
    
    func exportVideo(completionHandler handler: @escaping () -> Void)
    
}

public protocol ADVideoEditConfigurable where Self: UIViewController {
    
    var videoDidEdit: ((ADVideoEditInfo) -> Void)? { set get }
    
    var cancelEdit: (() -> Void)? { set get }
    
}

/// Use to define Image clip controller.
public protocol ADVideoClipConfigurable where Self: UIViewController {
    
    /// Called when clip cancel.
    var clipCancel: (() -> Void)? { get set }
    
    var clipRangeChange: ((CMTimeRange) -> Void)? { get set }
    var clipRangeConfirm: (() -> Void)? { get set }
    var seekReview: ((CMTime) -> Void)? { get set }
    
    /// Create with clip info.
    /// - Parameter clipInfo: Video clip info.
    init(clipInfo: ADVideoClipInfo)
    
    func updateProgress(_ progress: CGFloat)
    
}

public protocol ADVideoMusicSelectConfigurable where Self: UIViewController {
    
    var bottomHeight: CGFloat { get }
    
    /// Called when sound config is changed.
    var soundDidChange: ((ADVideoSound) -> Void)? { get set }
    
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)? { get set }
    
}

class ADVideoEditConfigure {
    
    static func videoPlayable(asset: AVAsset) -> ADVideoPlayable {
        return ADPhotoKitConfiguration.default.customVideoPlayableBlock?(asset) ?? ADVideoPlayerView(asset: asset)
    }
    
    static func videoEditVC(asset: AVAsset, editInfo: ADVideoEditInfo?, options: ADVideoEditOptions) -> ADVideoEditConfigurable {
        return ADPhotoKitConfiguration.default.customVideoEditVCBlock?(asset, editInfo, options) ?? ADVideoEditController(asset: asset, editInfo: editInfo, options: options)
    }
    
    static func videoClipVC(clipInfo: ADVideoClipInfo) -> ADVideoClipConfigurable {
        return ADPhotoKitConfiguration.default.customVideoClipVCBlock?(clipInfo) ?? ADVideoClipController(clipInfo: clipInfo)
    }
    
    static func videoMusicSelectVC(sound: ADVideoSound?) -> ADVideoMusicSelectConfigurable {
        return ADPhotoKitConfiguration.default.customVideoMusicSelectVCBlock?(sound) ?? ADMusicSelectController(dataSource: ADPhotoKitConfiguration.default.videoMusicDataSource!, sound: sound)
    }
    
}
