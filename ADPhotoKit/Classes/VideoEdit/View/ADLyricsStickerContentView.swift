//
//  ADLyricStickerContentView.swift
//  ADPhotoKit
//
//  Created by du on 2024/10/16.
//

import UIKit
import CoreMedia
import Kingfisher

class ADLyricsStickerInfo: ADStickerInfo {
    
    let music: ADMusicItem
    
    init(id: String, transform: CGAffineTransform, scale: CGFloat, center: CGPoint, music: ADMusicItem) {
        self.music = music
        super.init(id: id, transform: transform, scale: scale, center: center)
    }
}

class ADLyricsStickerContentView: ADVideoStickerContentView {
    
    static let LyricsStickerId = String(describing: ADLyricsStickerContentView.self)

    var music: ADMusicItem
    var sound: ADVideoSound?
    
    override var stickerInfo: ADLyricsStickerInfo {
        return ADLyricsStickerInfo(id: stickerID, transform: transform, scale: scale, center: center, music: music)
    }
    
    init(music: ADMusicItem) {
        self.music = music
        super.init(size: CGSize(width: screenWidth-64, height: 137), id: ADLyricsStickerContentView.LyricsStickerId)
        setupUI()
    }
    
    init(info: ADLyricsStickerInfo) {
        music = info.music
        super.init(info: info)
        setupUI()
    }
    
    func update(info: ADLyricsStickerInfo) {
        super.update(info: info)
        music = info.music
    }
    
    func updateMusic(_ new: ADMusicItem) {
        music = new
        if music.lyric == nil {
            lyricView.text = "此音乐暂无歌词"
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func doubleTapAction(ctx: UIViewController?) {
        let vc = ADVideoEditConfigure.videoMusicSelectVC(sound: sound)
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
        ctx?.present(vc, animated: true, completion: nil)
    }
    
    override func playerTimeUpdate(_ time: CMTime) {
        guard let lyrics = music.lyric else {
            return
        }
        var index = -1
        let offset = time.seconds.truncatingRemainder(dividingBy: music.asset.duration.seconds)
        for item in lyrics.enumerated() {
            if item.element.offset <= offset {
                index = item.offset
            }else{
                break
            }
        }
        lyricIndex = index
    }
    
    override func pinch(by scale: CGFloat) {
        
    }
    
    override func rotate(by angle: CGFloat) {
        
    }
    
    private var lyricView: UITextView!
    private lazy var attributes = {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 6
        let attributes: [NSAttributedString.Key : Any] = [.font:UIFont.systemFont(ofSize: 32, weight: .bold),.foregroundColor:UIColor.white.withAlphaComponent(0.8),.shadow: shadow]
        return attributes
    }()
    private var lyricIndex: Int = -1 {
        didSet {
            if lyricIndex >= 0 {
                if lyricIndex != oldValue {
                    if let lyrics = music.lyric {
                        lyricView.attributedText = NSAttributedString(string: lyrics[lyricIndex].text, attributes: attributes)
                    }
                }
            }else{
                lyricView.text = ""
            }
        }
    }
    
    func setupUI() {
        let icon = UIImageView(frame: CGRect(x: 6, y: 4, width: 13, height: 9))
        let path = Bundle.videoEditBundle?.bundlePath.appending("/live_lyric.gif") ?? ""
        icon.kf.setImage(with: .provider(LocalFileImageDataProvider(fileURL: URL(fileURLWithPath: path))))
        addSubview(icon)
        lyricView = UITextView(frame: CGRect(x: 0, y: 17, width: screenWidth-64, height: 120))
        lyricView.backgroundColor = .clear
        lyricView.textContainerInset = .zero
        lyricView.isUserInteractionEnabled = false
        addSubview(lyricView)
        if music.lyric == nil {
            lyricView.attributedText = NSAttributedString(string: "此音乐暂无歌词", attributes: attributes)
        }
    }

}
