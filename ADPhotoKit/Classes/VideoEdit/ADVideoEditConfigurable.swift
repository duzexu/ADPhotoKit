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
    
    /// Call when you want to change play preview rect.
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)! { set get }
    
    /// View to preview edit video.
    /// - Note: This property is initialized and set by the system. Classes that implement this protocol should declare this property as weak.
    var videoPlayable: ADVideoPlayable? { set get }
    
}

/// View to preview edit video. It can be previewed in real time when editing parameters are modified.
public protocol ADVideoPlayable where Self: UIView {
    
    /// Video clip range.
    var clipRange: CMTimeRange? { set get }
    
    /// Video bgm and ost setting.
    var videoSound: ADVideoSound { set get }
    
    /// Create with video asset.
    /// - Parameter asset: Vieo asset.
    init(asset: AVAsset)
    
    /// Pause play.
    /// - Parameter seekToZero: Whether to reset to the beginning.
    func pause(seekToZero: Bool)
    
    /// Resume if pause.
    func play()
    
    /// Seek to time.
    /// - Parameters:
    ///   - to: Time to seek.
    ///   - pause: Whether to pause after seeking.
    func seek(to: CMTime, pause: Bool)
    
    /// Add play progress observer.
    /// - Parameter observer: Called when progress changed.
    func addProgressObserver(_ observer: @escaping (_ progress: CGFloat, _ time: CMTime) -> Void)
    
    /// Return the video exporter.
    /// - Parameters:
    ///   - asset: Vieo asset.
    ///   - editInfo: Edited info.
    /// - Returns: Video exporter.
    static func exporter(from asset: AVAsset, editInfo: ADVideoEditInfo) -> ADVideoExporter
    
}

public extension ADVideoPlayable {
    static func exporter(from asset: AVAsset, editInfo: ADVideoEditInfo) -> ADVideoExporter {
        return ADDefaultVideoExporter(asset: asset, editInfo: editInfo)
    }
}

/// Layer with changeable content.
public protocol ADContentChangable where Self: CALayer {
    
    /// Call to update content.
    func onUpdateContent()
    
}

/// Use to define video edit controller.
public protocol ADVideoEditConfigurable where Self: UIViewController {
    
    /// Called when finish video edit.
    var videoDidEdit: ((ADVideoEditInfo) -> Void)? { set get }
    
    /// Called when cancel video edit.
    var cancelEdit: (() -> Void)? { set get }
    
    /// Create video edit controller.
    /// - Parameters:
    ///   - config: The config pass through.
    ///   - asset: Asset to edit.
    ///   - editInfo: Edited info.
    init(config: ADPhotoKitConfig, asset: AVAsset, editInfo: ADVideoEditInfo?)
    
    /// Update video playable preview rect.
    /// - Parameters:
    ///   - bottom: Preview bottom distance to bottom of screen.
    ///   - top: Preview top distance to top of screen.
    ///   - animated: If change with animation.
    func updatePlayableRect(bottom: CGFloat, top: CGFloat, animated: Bool)
    
}

/// Use to define Image clip controller.
public protocol ADVideoClipConfigurable where Self: UIViewController {
    
    /// Called when clip cancel.
    var clipCancel: (() -> Void)? { get set }
    
    /// Called when clip range changed.
    var clipRangeChange: ((CMTimeRange) -> Void)? { get set }
    
    /// Called when clip finished.
    var clipRangeConfirm: (() -> Void)? { get set }
    
    /// Called when seek preview.
    var seekReview: ((CMTime) -> Void)? { get set }
    
    /// Create with clip info.
    /// - Parameter clipInfo: Video clip info.
    init(clipInfo: ADVideoClipInfo)
    
    /// Call to update play progress.
    /// - Parameter progress: Play progress.
    func updateProgress(_ progress: CGFloat)
    
}

/// Use to define music select controller.
public protocol ADVideoMusicSelectConfigurable where Self: UIViewController {
    
    /// Called when sound config is changed.
    var soundDidChange: ((ADVideoSound) -> Void)? { get set }
    
    /// Call when you want to change play preview rect.
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)? { get set }
    
}

class ADVideoEditConfigure {
    
    static func videoPlayable(asset: AVAsset) -> ADVideoPlayable {
        let type = ADPhotoKitConfiguration.default.customVideoPlayable ?? ADVideoPlayerView.self
        return type.init(asset: asset)
    }
    
    static func videoEditVC(config: ADPhotoKitConfig, asset: AVAsset, editInfo: ADVideoEditInfo?) -> ADVideoEditConfigurable {
        return ADPhotoKitConfiguration.default.customVideoEditVCBlock?(config, asset, editInfo) ?? ADVideoEditController(config: config, asset: asset, editInfo: editInfo)
    }
    
    static func videoClipVC(clipInfo: ADVideoClipInfo) -> ADVideoClipConfigurable {
        return ADPhotoKitConfiguration.default.customVideoClipVCBlock?(clipInfo) ?? ADVideoClipController(clipInfo: clipInfo)
    }
    
    static func videoMusicSelectVC(sound: ADVideoSound?) -> ADVideoMusicSelectConfigurable {
        return ADPhotoKitConfiguration.default.customVideoMusicSelectVCBlock?(sound) ?? ADMusicSelectController(dataSource: ADPhotoKitConfiguration.default.videoMusicDataSource!, sound: sound)
    }
    
}
