//
//  ADVideoPlayerView.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/7.
//

import UIKit
import AVFoundation

class Observer {
    var target: ((CGFloat, CMTime)->Void)
    
    init(target: @escaping (CGFloat, CMTime) -> Void) {
        self.target = target
    }
}

class ADVideoPlayerView: UIView, ADVideoPlayable {
    
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
    
    private var composition: AVMutableComposition!
    private var playerItem: AVPlayerItem!
    private var lastBgm: String?
    
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
            self?.playerTimeUpdate(time)
        }
        resetEdit()
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

extension ADVideoPlayerView {
    
    func resetEdit() {
        composition = AVMutableComposition()

        let timeRange = clipRange ?? CMTimeRange(start: .zero, duration: asset.duration)
        
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        if let video = asset.tracks(withMediaType: .video).first {
            videoTrack?.preferredTransform = video.preferredTransform
            try? videoTrack?.insertTimeRange(timeRange, of: video, at: .zero)
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
    
    func playerTimeUpdate(_ time: CMTime) {
        let duration = clipRange?.duration.seconds ?? asset.duration.seconds
        let progress = time.seconds / duration
        for item in progressObservers {
            item.target(progress, time)
        }
    }
}

extension ADVideoPlayerView {
    @objc func playDidFinish() {
        pause(seekToZero: true)
    }
}
