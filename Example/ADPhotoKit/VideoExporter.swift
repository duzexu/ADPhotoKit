//
//  VideoExporter.swift
//  ADPhotoKit_Example
//
//  Created by du on 2024/11/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import ADPhotoKit
import AVFoundation
import CoreImage

#if Module_VideoEdit
class VideoExporter: ADVideoExporter {
    
    private var exportSession: AVAssetExportSession?
    private var filterIndex: Int = -1
    
    override init(asset: AVAsset, editInfo: ADVideoEditInfo) {
        super.init(asset: asset, editInfo: editInfo)
        setupSession()
    }
    
    override func parseToolJosn() {
        super.parseToolJosn()
        guard let json = editInfo.toolsJson else {
            return
        }
        for item in json {
            if item.key == "com.adphoto.demo.videofilter" {
                if let json = item.value as? Dictionary<String,Any> {
                    filterIndex = json["index"] as? Int ?? -1
                }
            }
        }
    }

    override func export(to path: String, completionHandler handler: @escaping (URL?, Error?) -> Void) {
        if exportSession == nil {
            handler(nil, ADError.exportSessionCreateFailed)
            return
        }
        startDisplayLink()
        let exportURL = URL(fileURLWithPath: path)
        if exportURL.pathExtension.lowercased() == "mp4" {
            exportSession?.outputFileType = .mp4
        }else if exportURL.pathExtension.lowercased() == "mov" {
            exportSession?.outputFileType = .mov
        }else if exportURL.pathExtension.lowercased() == "m4v" {
            exportSession?.outputFileType = .m4v
        }else{
            exportSession?.outputFileType = .mp4
        }
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
    
    override func cancelExport() {
        if exportSession?.status == .exporting {
            exportSession?.cancelExport()
        }
    }
    
    private func setupSession() {
        let composition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition.init(propertiesOf: composition)

        let timeRange = clipRange ?? CMTimeRange(start: .zero, duration: asset.duration)
        
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        if let video = asset.tracks(withMediaType: .video).first {
            try? videoTrack.insertTimeRange(timeRange, of: video, at: .zero)
            var instructions: [AVMutableVideoCompositionInstruction] = []
            VideoFilterCompositor.transform = video.preferredTransform
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            layerInstruction.setTransform(video.preferredTransform, at: .zero)
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: .zero, duration: timeRange.duration)
            instruction.layerInstructions = [layerInstruction]
            instructions.append(instruction)
            videoComposition.instructions = instructions
        }
        
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        if let audio = asset.tracks(withMediaType: .audio).first {
            try? audioTrack.insertTimeRange(timeRange, of: audio, at: .zero)
        }
        
        let bgmTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        if let bgmAsset = videoSound.bgm?.asset {
            if let bgm = bgmAsset.tracks(withMediaType: .audio).first {
                if !videoSound.bgmLoop {
                    let bgmRange = CMTimeRange(start: .zero, duration: min(timeRange.duration, bgmAsset.duration))
                    try? bgmTrack.insertTimeRange(bgmRange, of: bgm, at: .zero)
                }else{
                    var duration = min(timeRange.duration, bgmAsset.duration)
                    var total = timeRange.duration
                    var start: CMTime = .zero
                    while total.seconds > 0 {
                        try? bgmTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: bgm, at: start)
                        start = CMTimeAdd(start, duration)
                        total = timeRange.duration - start
                        duration = min(total, duration)
                    }
                }
            }
        }
        
        let audioMix = AVMutableAudioMix()
        let audioParameters = AVMutableAudioMixInputParameters(track: audioTrack)
        audioParameters.setVolume(videoSound.ostOn ? 1 : 0, at: .zero)
        let bgmParameters = AVMutableAudioMixInputParameters(track: bgmTrack)
        bgmParameters.setVolume(1, at: .zero)
        audioMix.inputParameters = [audioParameters, bgmParameters]
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: videoSize)
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        videoLayer.transform = CATransform3DMakeScale(1, -1, 1)
        parentLayer.sublayerTransform = CATransform3DMakeScale(1, -1, 1)
        parentLayer.addSublayer(videoLayer)
        for item in stkrs {
            let layer = CALayer()
            layer.frame = CGRect(origin: .zero, size: item.image.size)
            layer.contents = item.image.cgImage
            let scale = videoSize.width/UIScreen.main.bounds.width
            layer.position = CGPoint(x: item.normalizeCenter.x*videoSize.width, y: item.normalizeCenter.y*videoSize.height)
            layer.transform = CATransform3DMakeAffineTransform(item.transform.scaledBy(x: scale, y: scale).scaledBy(x: 1, y: -1))
            parentLayer.addSublayer(layer)
        }
        for changable in changables {
            parentLayer.addSublayer(changable)
        }
        let tool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        videoComposition.animationTool = tool
        videoComposition.frameDuration = CMTime(value: 1, timescale: frameRate)
        videoComposition.renderSize = videoSize
        if filterIndex != -1 {
            VideoFilterCompositor.filter = CIFilter(name: VideoFilter.allCases[filterIndex].filterName)
            videoComposition.customVideoCompositorClass = VideoFilterCompositor.self
        }
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.audioMix = audioMix
        exportSession?.videoComposition = videoComposition
        self.exportSession = exportSession
        if exportSession == nil {
            print("AVAssetExportSession create failed!")
        }
    }
}

class VideoFilterCompositor: NSObject, AVVideoCompositing {

    var sourcePixelBufferAttributes: [String : Any]? = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    var requiredPixelBufferAttributesForRenderContext: [String : Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        renderContext = newRenderContext
    }

    func cancelAllPendingVideoCompositionRequests() {
    }
    
    static var filter: CIFilter?
    static var transform: CGAffineTransform = .identity
    
    private var renderContext: AVVideoCompositionRenderContext?
    private let context = CIContext()
    
    func startRequest(_ asyncVideoCompositionRequest: AVAsynchronousVideoCompositionRequest) {
        guard let track = asyncVideoCompositionRequest.sourceTrackIDs.first?.int32Value, let frame = asyncVideoCompositionRequest.sourceFrame(byTrackID: track) else {
            asyncVideoCompositionRequest.finish(with: NSError(domain: "VideoFilterCompositor", code: 0, userInfo: nil))
            return
        }
        let source = CIImage(cvPixelBuffer: frame)
        if let filter = VideoFilterCompositor.filter {
            filter.setValue(source, forKey: kCIInputImageKey)
            if let outputImage = filter.outputImage?.transformed(by: VideoFilterCompositor.transform.inverted()), let outBuffer = renderContext?.newPixelBuffer() {
                if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                    let finalImage = CIImage(cgImage: cgImage)
                    context.render(finalImage, to: outBuffer)
                }
                asyncVideoCompositionRequest.finish(withComposedVideoFrame: outBuffer)
            } else {
                asyncVideoCompositionRequest.finish(with: NSError(domain: "VideoFilterCompositor", code: 0, userInfo: nil))
            }
        }else{
            asyncVideoCompositionRequest.finish(with: NSError(domain: "VideoFilterCompositor", code: 0, userInfo: nil))
        }
    }

}
#endif
