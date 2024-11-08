//
//  ADVideoExporter.swift
//  ADPhotoKit
//
//  Created by du on 2024/11/6.
//

import Foundation
import AVFoundation

class ADVideoExporter {
    let frameRate: Int32 = 30
    
    let asset: AVAsset
    let editInfo: ADVideoEditInfo
    
    private let videoSize: CGSize
    
    private var clipRange: CMTimeRange?
    private var videoSound: ADVideoSound = ADVideoSound()
    private var stkrs: [ADImageStickerInfo] = []
    private var changables: [ADContentChangable] = []
        
    private var exportSession: AVAssetExportSession?
    
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
            target?.updateExportProgress()
        }
    }
    
    init(asset: AVAsset, editInfo: ADVideoEditInfo) {
        self.asset = asset
        self.editInfo = editInfo
        self.videoSize = ADVideoUitls.getNaturalSize(asset: asset)
        
        parseToolJosn()
        setupSession()
    }
    
    deinit {
        if isDisplayLinkInitialized {
            displayLink.invalidate()
        }
        cancelExport()
    }
    
    func export(to path: String, completionHandler handler: @escaping (URL?, Error?) -> Void) {
        displayLink.isPaused = false
        let exportURL = URL(fileURLWithPath: path)
        exportSession?.outputURL = exportURL
        exportSession?.exportAsynchronously { [weak self] in
            guard let strong = self else { return }
            if strong.exportSession?.status == .completed {
                handler(exportURL, nil)
            }else{
                handler(nil, strong.exportSession?.error)
            }
        }
    }
    
    
    func cancelExport() {
        if exportSession?.status == .exporting {
            exportSession?.cancelExport()
        }
    }
    
    private func parseToolJosn() {
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
            let lyric = ADLyricsChangableView(music: videoSound.bgm!, duration: timeRange.duration.seconds)
            if let lyricInfo = lyricInfo {
                let scale = videoSize.width/screenWidth
                lyric.center = CGPoint(x: lyricInfo.normalizeCenter.x*videoSize.width, y: lyricInfo.normalizeCenter.y*videoSize.height)
                lyric.transform = lyricInfo.transform.scaledBy(x: scale, y: scale)
            }
            changables.append(lyric)
        }
    }
    
    private func setupSession() {
        let composition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition.init(propertiesOf: composition)

        let timeRange = clipRange ?? CMTimeRange(start: .zero, duration: asset.duration)
        
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        if let video = asset.tracks(withMediaType: .video).first {
            try? videoTrack?.insertTimeRange(timeRange, of: video, at: .zero)
            videoComposition.frameDuration = video.minFrameDuration
            videoComposition.renderSize = videoSize
            var instructions: [AVMutableVideoCompositionInstruction] = []
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: video)
            layerInstruction.setTransform(video.preferredTransform, at: .zero)
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: .zero, duration: timeRange.duration)
            instruction.layerInstructions = [layerInstruction]
            instructions.append(instruction)
            videoComposition.instructions = instructions
        }
        
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        if let audio = asset.tracks(withMediaType: .audio).first {
            try? audioTrack?.insertTimeRange(timeRange, of: audio, at: .zero)
        }
        
        let bgmTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        if let bgmAsset = videoSound.bgm?.asset {
            if let bgm = bgmAsset.tracks(withMediaType: .audio).first {
                if !videoSound.bgmLoop {
                    let bgmRange = CMTimeRange(start: .zero, duration: min(timeRange.duration, bgmAsset.duration))
                    try? bgmTrack?.insertTimeRange(bgmRange, of: bgm, at: .zero)
                }else{
                    var duration = min(timeRange.duration, bgmAsset.duration)
                    var total = timeRange.duration
                    var start: CMTime = .zero
                    while total.seconds > 0 {
                        try? bgmTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: bgm, at: start)
                        start = CMTimeAdd(start, duration)
                        total = timeRange.duration - start
                        duration = min(total, duration)
                    }
                }
            }
        }
        
        let audioMix = AVMutableAudioMix()
        let audioParameters = AVMutableAudioMixInputParameters(track: audioTrack!)
        audioParameters.setVolume(videoSound.ostOn ? 1 : 0, at: .zero)
        let bgmParameters = AVMutableAudioMixInputParameters(track: bgmTrack!)
        bgmParameters.setVolume(1, at: .zero)
        audioMix.inputParameters = [audioParameters, bgmParameters]
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: videoSize)
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        parentLayer.sublayerTransform = CATransform3DMakeScale(1, -1, 1)
        parentLayer.addSublayer(videoLayer)
        for item in stkrs {
            let layer = CALayer()
            layer.frame = CGRect(origin: .zero, size: item.image.size)
            layer.contents = item.image.cgImage
            let scale = videoSize.width/screenWidth
            layer.position = CGPoint(x: item.normalizeCenter.x*videoSize.width, y: item.normalizeCenter.y*videoSize.height)
            layer.transform = CATransform3DMakeAffineTransform(item.transform.scaledBy(x: scale, y: scale).scaledBy(x: 1, y: -1))
            parentLayer.addSublayer(layer)
        }
        for changable in changables {
            parentLayer.addSublayer(changable.layer)
        }
        let tool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        videoComposition.animationTool = tool
        videoComposition.frameDuration = CMTime(value: 1, timescale: frameRate)
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.audioMix = audioMix
        exportSession?.videoComposition = videoComposition
        exportSession?.outputFileType = .mp4
        self.exportSession = exportSession
        if exportSession == nil {
            print("AVAssetExportSession create failed!")
        }
    }
    
    private func updateExportProgress() {
        let value = exportSession?.progress ?? 0
        for changable in changables {
            changable.changeWithProgress(CGFloat(value))
        }
    }
}
