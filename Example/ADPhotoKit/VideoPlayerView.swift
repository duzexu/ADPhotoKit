//
//  VideoPlayerView.swift
//  ADPhotoKit_Example
//
//  Created by du on 2024/11/19.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit
import AVFoundation

#if Module_VideoEdit
class VideoPlayerView: UIView, ADVideoPlayable {
    
    class Observer {
        var target: ((CGFloat, CMTime)->Void)
        
        init(target: @escaping (CGFloat, CMTime) -> Void) {
            self.target = target
        }
    }
    
    class TargetProxy {
        private weak var target: VideoPlayerView?
        
        init(target: VideoPlayerView) {
            self.target = target
        }
        
        @objc func onScreenUpdate() {
            target?.onRenderFrame()
        }
    }
    
    let asset: AVAsset
    var clipRange: CMTimeRange? {
        didSet {
            resetEdit()
        }
    }
    var videoSound: ADVideoSound = ADVideoSound() {
        didSet {
            if videoSound.bgm?.id != lastBgm && videoSound.bgm != nil {
                resetEdit()
            }else{
                updateEdit()
            }
        }
    }
    
    var filterIndex: Int = -1 {
        didSet {
            if filterIndex >= 0 {
                filter = CIFilter(name: VideoFilter.allCases[filterIndex].filterName)
                if displayLink == nil {
                    let _displayLink = CADisplayLink(target: TargetProxy(target: self), selector: #selector(TargetProxy.onScreenUpdate))
                    _displayLink.add(to: .main, forMode: .default)
                    displayLink = _displayLink
                }
            }else{
                filter = nil
                displayLink?.invalidate()
                displayLink = nil
            }
        }
    }
    
    static func exporter(from asset: AVAsset, editInfo: ADVideoEditInfo) -> ADVideoExporter {
        return VideoExporter(asset: asset, editInfo: editInfo)
    }
    
    private var composition: AVMutableComposition!
    private var playerItem: AVPlayerItem!
    private var lastBgm: String?
    
    private var progressObservers: [Observer] = []
    
    private var player: AVPlayer!
    private var videoPlayerLayer: AVPlayerLayer!
    
    private var videoOutput: AVPlayerItemVideoOutput!
    private var displayLink: CADisplayLink?
    private var ciContext: CIContext = CIContext()
    private var filter: CIFilter?
    private var renderImageView: UIImageView!
    private var videoTransform: CGAffineTransform = .identity

    required init(asset: AVAsset) {
        self.asset = asset
        videoPlayerLayer = AVPlayerLayer()
        super.init(frame: .zero)
        player = AVPlayer()
        videoPlayerLayer.contentsGravity = .resizeAspect
        layer.insertSublayer(videoPlayerLayer, at: 0)
        videoPlayerLayer.player = player
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: DispatchQueue.main) { [weak self] time in
            self?.playerTimeUpdate(time)
        }
        renderImageView = UIImageView()
        renderImageView.contentMode = .scaleAspectFit
        addSubview(renderImageView)
        renderImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        resetEdit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        displayLink?.invalidate()
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
    
    func play() {
        player.play()
    }
    
    func seek(to: CMTime, pause: Bool) {
        player?.pause()
        player?.seek(to: to)
        if !pause {
            player.play()
        }
    }
    
    func addProgressObserver(_ observer: @escaping (_ progress: CGFloat, _ time: CMTime) -> Void) {
        progressObservers.append(Observer(target: observer))
    }
    
}

extension VideoPlayerView {
    
    func resetEdit() {
        composition = AVMutableComposition()
        
        let timeRange = clipRange ?? CMTimeRange(start: .zero, duration: asset.duration)
        
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        if let video = asset.tracks(withMediaType: .video).first {
            videoTrack?.preferredTransform = video.preferredTransform
            try? videoTrack?.insertTimeRange(timeRange, of: video, at: .zero)
            videoTransform = video.preferredTransform
        }
        
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        if let audio = asset.tracks(withMediaType: .audio).first {
            try? audioTrack?.insertTimeRange(timeRange, of: audio, at: .zero)
        }
        
        let bgmTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        if let bgmAsset = videoSound.bgm?.asset {
            lastBgm = videoSound.bgm?.id
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
        
        playerItem = AVPlayerItem(asset: composition)
        let outputSettings: [String: Any] = [
                    (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                ]
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: outputSettings)
        playerItem.add(videoOutput)
        let audioMix = AVMutableAudioMix()
        let audioParameters = AVMutableAudioMixInputParameters(track: audioTrack!)
        audioParameters.setVolume(videoSound.ostOn ? 1 : 0, at: .zero)
        let bgmParameters = AVMutableAudioMixInputParameters(track: bgmTrack!)
        bgmParameters.setVolume(1, at: .zero)
        audioMix.inputParameters = [audioParameters, bgmParameters]
        playerItem.audioMix = audioMix
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func updateEdit() {
        let audioTracks = composition.tracks(withMediaType: .audio)
        var audioMixInputParameters: [AVMutableAudioMixInputParameters] = []
        for track in audioTracks {
            if track.trackID == 2 {
                let inputParameters = AVMutableAudioMixInputParameters(track: track)
                inputParameters.setVolume(videoSound.ostOn ? 1 : 0, at: .zero)
                audioMixInputParameters.append(inputParameters)
            }
            if track.trackID == 3 {
                let inputParameters = AVMutableAudioMixInputParameters(track: track)
                inputParameters.setVolume(videoSound.bgm != nil ? 1 : 0, at: .zero)
                audioMixInputParameters.append(inputParameters)
            }
        }
        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = audioMixInputParameters
        playerItem.audioMix = audioMix
    }
}

extension VideoPlayerView {
    @objc func playDidFinish() {
        pause(seekToZero: true)
    }
    
    func playerTimeUpdate(_ time: CMTime) {
        let duration = clipRange?.duration.seconds ?? asset.duration.seconds
        let progress = time.seconds / duration
        for item in progressObservers {
            item.target(progress, time)
        }
    }
    
    func onRenderFrame() {
        guard let filter = filter else {
            renderImageView.image = nil
            return
        }
        
        guard let time = player.currentItem?.currentTime() else { return }

        guard videoOutput.hasNewPixelBuffer(forItemTime: time), let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else {
            return
        }

        let inputImage = CIImage(cvPixelBuffer: pixelBuffer).transformed(by: videoTransform.inverted())
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else { return }
        
        if let cgImage = ciContext.createCGImage(outputImage, from: inputImage.extent) {
            DispatchQueue.main.async {
                self.renderImageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
}
#endif
