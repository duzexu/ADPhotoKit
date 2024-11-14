//
//  ADVideoExporter.swift
//  ADPhotoKit
//
//  Created by du on 2024/11/6.
//

import Foundation
import AVFoundation

open class ADVideoExporter {
    open var frameRate: Int32 {
        return 30;
    }
    
    public let asset: AVAsset
    public let editInfo: ADVideoEditInfo
    
    public let videoSize: CGSize
    
    public var clipRange: CMTimeRange?
    public var videoSound: ADVideoSound = ADVideoSound()
    public var stkrs: [ADImageStickerInfo] = []
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
    
    public init(asset: AVAsset, editInfo: ADVideoEditInfo) {
        self.asset = asset
        self.editInfo = editInfo
        self.videoSize = ADVideoUitls.getNaturalSize(asset: asset)
        
        parseToolJosn()
    }
    
    deinit {
        if isDisplayLinkInitialized {
            displayLink.invalidate()
        }
        cancelExport()
    }
    
    open func export(to path: String, completionHandler handler: @escaping (URL?, Error?) -> Void) {
        
        
    }
    
    open func cancelExport() {
        
    }
    
    public func startUpdateContent() {
        displayLink.isPaused = false
    }
    
    public func stopUpdateContent() {
        displayLink.isPaused = true
    }
    
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
    
    private func onScreenUpdate() {
        for changable in changables {
            changable.onUpdateContent()
        }
    }
}
