//
//  ADVideoPlayerView.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/7.
//

import UIKit
import AVFoundation

public struct ADVideoStcker {
    /// Identifier of content view.
    public let id: String
    /// Transform of content view.
    public let transform: CGAffineTransform
    /// Normalize sticker center.
    public let center: CGPoint
    /// Stciker image.
    public let image: UIImage
}

public struct ADVideoSound {
    public let originalSound: Bool
    public let bgmAsset: AVAsset?
    public let bgmLoop: Bool
    
    public static let `default` = ADVideoSound(originalSound: true, bgmAsset: nil, bgmLoop: true)
}

class Observer {
    var target: ((CGFloat)->Void)
    
    init(target: @escaping (CGFloat) -> Void) {
        self.target = target
    }
}

class ADVideoPlayerView: UIView, ADVideoPlayable {
    
    let asset: AVAsset
    var clipRange: CMTimeRange? {
        didSet {
            updateEdit()
        }
    }
    var videoSound: ADVideoSound = .default {
        didSet {
            updateEdit()
        }
    }
    
    private var stkrs: [ADVideoStcker] = []
    private var composition: AVMutableComposition!
    private var playerItem: AVPlayerItem!
    
    private var progressObservers: [Observer] = []
    
    private var videoSize: CGSize = .zero
    private var player: AVPlayer!
    private var videoPlayerLayer: AVPlayerLayer!

    required init(asset: AVAsset) {
        self.asset = asset
        videoPlayerLayer = AVPlayerLayer()
        super.init(frame: .zero)
        videoSize = ADVideoUitls.getNaturalSize(asset: asset)
        player = AVPlayer()
        videoPlayerLayer.contentsGravity = .resizeAspect
        layer.insertSublayer(videoPlayerLayer, at: 0)
        videoPlayerLayer.player = player
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: DispatchQueue.main) { [weak self] time in
            self?.playTimeChange(time)
        }
        updateEdit()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayerLayer.frame = bounds
    }
    
    func pause(seekToZero: Bool = false) {
        player?.pause()
        if seekToZero {
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    func seek(to: CMTime, pause: Bool) {
        if clipRange != nil && !clipRange!.containsTime(to) {
            setClipRange(nil)
        }
        player?.pause()
        player?.seek(to: to)
        if !pause {
            player.play()
        }
    }
    
    func addProgressObserver(_ observer: @escaping (CGFloat) -> Void) {
        progressObservers.append(Observer(target: observer))
    }
    
    func addOrUpdateSticker(_ stk: ADVideoStcker) {
        if let idx = stkrs.firstIndex(where: { $0.id == stk.id }) {
            stkrs[idx] = stk
        }else{
            stkrs.append(stk)
        }
    }
    
    func removeSticker(_ id: String) {
        stkrs.removeAll { $0.id == id }
    }
    
    func setClipRange(_ range: CMTimeRange?) {
        
    }
    
    func setVideoSound(_ sound: ADVideoSound) {
        videoSound = sound
        updateEdit()
    }
    
    func exportVideo(completionHandler handler: @escaping () -> Void) {
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: videoSize)
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        parentLayer.addSublayer(videoLayer)
        for item in stkrs {
            let layer = CALayer()
            layer.frame = CGRect(origin: .zero, size: item.image.size)
            layer.contents = item.image.cgImage
            layer.transform = CATransform3DMakeAffineTransform(item.transform)
            layer.position = CGPoint(x: videoSize.width*item.center.x, y: videoSize.height*item.center.y)
            parentLayer.addSublayer(layer)
        }
        let videoComposition = playerItem.videoComposition as? AVMutableVideoComposition
        let tool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        videoComposition?.animationTool = tool
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("output.mp4")
        exportSession?.audioMix = playerItem.audioMix
        exportSession?.videoComposition = videoComposition
        exportSession?.outputURL = exportURL
        exportSession?.outputFileType = .mp4

        exportSession?.exportAsynchronously {
            // 导出完成的处理
            print("导出完成\(exportURL)")
        }
    }
    
}

extension ADVideoPlayerView {
    
    func updateEdit() {
        composition = AVMutableComposition()
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
        
        var audioTrack: AVMutableCompositionTrack?
        if videoSound.originalSound {
            audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            if let audio = asset.tracks(withMediaType: .audio).first {
                try? audioTrack?.insertTimeRange(timeRange, of: audio, at: .zero)
            }
        }
        
        var bgmTrack: AVMutableCompositionTrack?
        if let bgmAsset = videoSound.bgmAsset {
            bgmTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            if let bgm = bgmAsset.tracks(withMediaType: .audio).first {
                if !videoSound.bgmLoop {
                    let bgmRange = CMTimeRange(start: .zero, duration: min(timeRange.duration, bgmAsset.duration))
                    try? bgmTrack?.insertTimeRange(bgmRange, of: bgm, at: .zero)
                }else{
                    var duration = min(timeRange.duration, bgmAsset.duration)
                    var start: CMTime = .zero
                    while duration.seconds > 0 {
                        try? bgmTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: bgm, at: start)
                        start = CMTimeAdd(start, duration)
                        duration = timeRange.duration - start
                    }
                }
            }
        }
        
        let playerItem = AVPlayerItem(asset: composition)
        playerItem.videoComposition = videoComposition;
        if audioTrack != nil && bgmTrack != nil {
            let audioMix = AVMutableAudioMix()
            let audioParameters = AVMutableAudioMixInputParameters(track: audioTrack!)
            audioParameters.setVolume(1, at: .zero)
            let bgmParameters = AVMutableAudioMixInputParameters(track: bgmTrack!)
            bgmParameters.setVolume(1, at: .zero)
            audioMix.inputParameters = [audioParameters, bgmParameters]
            playerItem.audioMix = audioMix;
        }
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func playTimeChange(_ time: CMTime) {
        let duration = clipRange?.duration.seconds ?? asset.duration.seconds
        let progress = time.seconds / duration
        for item in progressObservers {
            item.target(progress)
        }
    }
}

extension ADVideoPlayerView {
    @objc func appWillResignActive() {
        if let play = player, play.rate != 0 {
            pause()
        }
    }
    
    @objc func playDidFinish() {
        pause(seekToZero: true)
    }
}
