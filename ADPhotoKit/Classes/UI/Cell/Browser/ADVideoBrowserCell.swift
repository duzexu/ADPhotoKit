//
//  ADVideoBrowserCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/5.
//

import UIKit
import Photos
import AVFoundation

class ADVideoBrowserCell: ADBrowserBaseCell, ADVideoBrowserCellConfigurable {
        
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer!
    
    var playBtn: UIButton!
    
    var progressView: ADProgressableable!
    
    var imageView: UIImageView!
    var errorLabel: UILabel!
    
    private var identifier: String?
    
    private var requestID: PHImageRequestID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configure(with source: ADVideoSource) {
        if identifier != source.identifier {
            identifier = source.identifier
            configureCell(source: source)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    override func cellDidEndDisplay() {
        pause()
    }
    
    internal class VideoTransView: UIView {
        
        var playerLayer: CALayer
        
        init(playerLayer: CALayer) {
            self.playerLayer = playerLayer
            super.init(frame: playerLayer.frame)
            layer.addSublayer(playerLayer)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer.frame = bounds
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    override func transationBegin() -> (UIView, CGRect) {
        let frame = playerLayer.frame
        let view = VideoTransView(playerLayer: playerLayer)
        return (view,frame)
    }
    
    override func transationCancel(view: UIView) {
        let trans = view as! VideoTransView
        layer.insertSublayer(trans.playerLayer, at: 0)
    }
}

private extension ADVideoBrowserCell {
    func setupUI() {
        imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playerLayer = AVPlayerLayer()
        playerLayer.contentsGravity = .resizeAspect
        layer.insertSublayer(playerLayer, at: 0)
        
        let attStr = NSMutableAttributedString()
        let attach = NSTextAttachment()
        attach.image = Bundle.uiBundle?.image(name: "videoLoadFailed")
        attach.bounds = CGRect(x: 0, y: -10, width: 30, height: 30)
        attStr.append(NSAttributedString(attachment: attach))
        let errorText = NSAttributedString(string: ADLocale.LocaleKey.iCloudVideoLoadFaild.localeTextValue, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        attStr.append(errorText)
        errorLabel = UILabel()
        errorLabel.attributedText = attStr
        contentView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(60)
        }
        
        progressView = ADPhotoUIConfigurable.progress()
        progressView.isHidden = true
        contentView.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        playBtn = UIButton(type: .custom)
        playBtn.setImage(Bundle.uiBundle?.image(name: "playVideo"), for: .normal)
        playBtn.setImage(UIImage(), for: .selected)
        playBtn.addTarget(self, action: #selector(playBtnAction(sender:)), for: .touchUpInside)
        contentView.addSubview(playBtn)
        playBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    func configureCell(source: ADVideoSource) {
        imageView.image = nil
        imageView.isHidden = false
        errorLabel.isHidden = true
        playBtn.isHidden = true
        playerLayer.player = nil
        player = nil
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        switch source {
        case let .network(url):
            imageView.isHidden = true
            configWithPlayItem(AVPlayerItem(url: url))
        case let .album(asset):
            imageView.setAsset(asset, size: asset.browserSize, placeholder: nil, completionHandler:  { [weak self] (img) in
                self?.progressView.isHidden = true
                self?.loadVideoData(asset: asset)
            })
        case let .local(url):
            imageView.isHidden = true
            configWithPlayItem(AVPlayerItem(url: url))
        }
    }
    
    func loadVideoData(asset: PHAsset) {
        requestID = ADPhotoManager.fetch(for: asset, type: .video, progress: { [weak self] (progress, _, _, _) in
            self?.progressView.progress = CGFloat(progress)
            if progress >= 1 {
                self?.progressView.isHidden = true
            }else{
                self?.progressView.isHidden = false
            }
        },completion: { [weak self] (item, info, _) in
            self?.progressView.isHidden = true
            if let play = item as? AVPlayerItem {
                self?.configWithPlayItem(play)
            }else{
                let error = info?[PHImageErrorKey] as? NSError
                if error?.iCloudFetchError == true {
                    self?.errorLabel.isHidden = false
                }
            }
        })
    }
    
    func configWithPlayItem(_ item: AVPlayerItem) {
        playBtn.isHidden = false
        player = AVPlayer(playerItem: item)
        playerLayer.player = player
        
        NotificationCenter.default.addObserver(self, selector: #selector(playDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    func pause(seekToZero: Bool = false) {
        playBtn.isSelected = false
        if let status = player?.timeControlStatus, status == .playing {
            singleTapBlock?()
        }
        player?.pause()
        if seekToZero {
            player?.seek(to: .zero)
        }
    }
}

// action
private extension ADVideoBrowserCell {
    @objc func playBtnAction(sender: UIButton) {
        guard let play = player else {
            return
        }
        if play.rate == 0 {
            let current = play.currentItem?.currentTime()
            let duration = play.currentItem?.duration
            if current?.value == duration?.value {
                play.currentItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
            }
            imageView.isHidden = true
            play.play()
            playBtn.isSelected = true
            singleTapBlock?()
        }else{
            pause()
        }
    }
    
    @objc func appWillResignActive() {
        if let play = player, play.rate != 0 {
            pause()
        }
    }
    
    @objc func playDidFinish() {
        pause(seekToZero: true)
    }
}

extension NSError {
    
    var iCloudFetchError: Bool {
        if self.domain == "CKErrorDomain" || self.domain == "CloudPhotoLibraryErrorDomain" {
            return true
        }
        return false
    }
    
}
