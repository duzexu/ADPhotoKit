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
    
    static func exporter(from asset: AVAsset, editInfo: ADVideoEditInfo) -> ADVideoExporter
    
}

public extension ADVideoPlayable {
    static func exporter(from asset: AVAsset, editInfo: ADVideoEditInfo) -> ADVideoExporter {
        return ADDefaultVideoExporter(asset: asset, editInfo: editInfo)
    }
}

public protocol ADContentChangable where Self: CALayer {
    
    func onUpdateContent()
    
}

public protocol ADVideoEditConfigurable where Self: UIViewController {
    
    var videoDidEdit: ((ADVideoEditInfo) -> Void)? { set get }
    
    var cancelEdit: (() -> Void)? { set get }
    
    init(config: ADPhotoKitConfig, asset: AVAsset, editInfo: ADVideoEditInfo?)
    
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

public protocol ADVideoExporterable {
    init(asset: AVAsset, editInfo: ADVideoEditInfo)
    
    func export(to path: String, completionHandler handler: @escaping (URL?, Error?) -> Void)
    
    func cancelExport()
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
