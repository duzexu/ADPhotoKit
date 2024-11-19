//
//  ADVideoExporter.swift
//  ADPhotoKit
//
//  Created by du on 2024/11/6.
//

import Foundation
import AVFoundation

/// Base video exporter.
open class ADVideoExporter {
    
    /// Export video frame rate.
    open var frameRate: Int32 {
        return 30;
    }
    
    /// Video asset to export.
    public let asset: AVAsset
    
    /// Video edit info.
    public let editInfo: ADVideoEditInfo
    
    /// Video render size.
    public let videoSize: CGSize
    
    /// Video clip range parse from editInfo.
    public var clipRange: CMTimeRange?
    /// Video bgm info parse from editInfo.
    public var videoSound: ADVideoSound = ADVideoSound()
    /// Video sticker info parse from editInfo.
    public var stkrs: [ADImageStickerInfo] = []
    /// Video changable info parse from editInfo.
    public var changables: [ADContentChangable] = []
            
    private var isDisplayLinkInitialized: Bool = false
    private lazy var displayLink: CADisplayLink = {
        isDisplayLinkInitialized = true
        let displayLink = CADisplayLink(target: TargetProxy(target: self), selector: #selector(TargetProxy.onScreenUpdate))
        displayLink.preferredFramesPerSecond = Int(frameRate)
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
        displayLink.isPaused = true
        return displayLink
    }()
    
    private class TargetProxy {
        private weak var target: ADVideoExporter?
        
        init(target: ADVideoExporter) {
            self.target = target
        }
        
        @objc func onScreenUpdate() {
            target?.onScreenUpdate()
        }
    }
    
    /// Create video exporter.
    /// - Parameters:
    ///   - asset: Asset to export.
    ///   - editInfo: Edit info to asset.
    public init(asset: AVAsset, editInfo: ADVideoEditInfo) {
        self.asset = asset
        self.editInfo = editInfo
        self.videoSize = asset.naturalSize
        
        parseToolJosn()
    }
    
    deinit {
        if isDisplayLinkInitialized {
            displayLink.invalidate()
        }
        cancelExport()
    }
    
    /// Begin to export video. Subclass should override to export video.
    /// - Parameters:
    ///   - path: Path to save export video.
    ///   - handler: Called when the export is complete.
    open func export(to path: String, completionHandler handler: @escaping (URL?, Error?) -> Void) {
        
    }
    
    /// Cancel export. Subclass should override to cancel export.
    open func cancelExport() {
        
    }
    
    /// Start display link.
    /// - Note: When display link is started, ``onScreenUpdate()`` will be called every frame.
    public func startDisplayLink() {
        displayLink.isPaused = false
    }
    
    /// Stop display link.
    public func stopDisplayLink() {
        displayLink.isPaused = true
    }
    
    /// Parse edit info. Subclass can override and do some operation.
    open func parseToolJosn() {
        guard let json = editInfo.toolsJson else {
            return
        }
        var lyricInfo: ADLyricsStickerInfo?
        for item in json {
            if item.key.hasPrefix("ADVideoSticker") {
                if let json = item.value as? Dictionary<String,Any> {
                    if let array = json["stkrs"] as? [ADImageStickerInfo] {
                        stkrs.append(contentsOf: array)
                    }
                }
            }
            if item.key == "ADVideoClip" {
                if let json = item.value as? Dictionary<String,Any> {
                    clipRange = json["clipRange"] as? CMTimeRange
                }
            }
            if item.key == "ADVideoBGM" {
                if let json = item.value as? Dictionary<String,Any> {
                    videoSound = json["videoSound"] as? ADVideoSound ?? ADVideoSound()
                    lyricInfo = json["stk"] as? ADLyricsStickerInfo
                }
            }
        }
        if videoSound.lyricOn {
            let timeRange = clipRange ?? CMTimeRange(start: .zero, duration: asset.duration)
            let lyric = ADLyricsChangableView(music: videoSound.bgm!, length: timeRange.duration.seconds)
            if let lyricInfo = lyricInfo {
                let scale = videoSize.width/screenWidth
                lyric.position = CGPoint(x: lyricInfo.normalizeCenter.x*videoSize.width, y: lyricInfo.normalizeCenter.y*videoSize.height)
                lyric.transform = CATransform3DMakeAffineTransform(lyricInfo.transform.scaledBy(x: scale, y: scale)) 
            }
            changables.append(lyric)
        }
    }
    
    /// Called every frame to update changable content. Subclass can override and do some operation.
    open func onScreenUpdate() {
        for changable in changables {
            changable.onUpdateContent()
        }
    }
}
