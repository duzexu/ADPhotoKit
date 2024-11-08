//
//  ADLyricsChangableView.swift
//  ADPhotoKit
//
//  Created by du on 2024/11/6.
//

import UIKit
import AVFoundation
import CoreServices

class ADLyricsChangableView: UIView, ADContentChangable {
    
    let music: ADMusicItem
    let duration: CGFloat
    
    init(music: ADMusicItem, duration: CGFloat) {
        self.music = music
        self.duration = duration
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: screenWidth-64, height: 137)))
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var attributes = {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        shadow.shadowBlurRadius = 4
        let attributes: [NSAttributedString.Key : Any] = [.font:UIFont.systemFont(ofSize: 32, weight: .bold),.foregroundColor:UIColor.white.withAlphaComponent(0.8),.shadow: shadow]
        return attributes
    }()
    private var animatedView: UIImageView!
    private var images: [UIImage] = []
    private var index: Int = 0
    
    func setupUI() {
        let path = Bundle.videoEditBundle?.bundlePath.appending("/live_lyric.gif") ?? ""
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        let info: [String: Any] = [
            kCGImageSourceShouldCache as String: true,
            kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF
        ]
        if let data = data, let imageSource = CGImageSourceCreateWithData(data as CFData, info as CFDictionary) {
            let frameCount = CGImageSourceGetCount(imageSource)
            for i in 0 ..< frameCount {
                if let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, info as CFDictionary) {
                    let image = UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: .up)
                    images.append(image)
                }
            }
        }
        animatedView = UIImageView(frame: CGRect(x: 6, y: 4, width: 13, height: 9))
        animatedView.image = images.first
        addSubview(animatedView)
        switch music.extra {
        case let .text(content):
            let lyricView = UILabel(frame: CGRect(x: 0, y: 17, width: screenWidth-64, height: 120))
            lyricView.backgroundColor = .clear
            lyricView.isUserInteractionEnabled = false
            lyricView.attributedText = NSAttributedString(string: content, attributes: attributes)
            addSubview(lyricView)
        case let .lyric(items):
            var lastLayer: CALayer?
            for item in items {
                if item.offset >= duration {
                    break
                }
                let lyricLayer = CATextLayer()
                lyricLayer.contentsScale = UIScreen.main.scale
                lyricLayer.string = NSAttributedString(string: item.text, attributes: attributes)
                lyricLayer.alignmentMode = .left
                lyricLayer.frame = CGRect(x: 0, y: 17, width: screenWidth-64, height: 120)
                lyricLayer.opacity = 0
                let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
                fadeInAnimation.fromValue = 0.0
                fadeInAnimation.toValue = 1.0
                fadeInAnimation.duration = 0.1
                fadeInAnimation.beginTime = AVCoreAnimationBeginTimeAtZero + item.offset
                fadeInAnimation.fillMode = .forwards
                fadeInAnimation.isRemovedOnCompletion = false
                lyricLayer.add(fadeInAnimation, forKey: "fadeIn")
                lyricLayer.transform = CATransform3DMakeScale(1, -1, 1)
                layer.addSublayer(lyricLayer)
                if let last = lastLayer {
                    let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
                    fadeOutAnimation.fromValue = 1.0
                    fadeOutAnimation.toValue = 0.0
                    fadeOutAnimation.duration = 0.1
                    fadeOutAnimation.beginTime = AVCoreAnimationBeginTimeAtZero + item.offset-0.1
                    fadeOutAnimation.fillMode = .forwards
                    fadeOutAnimation.isRemovedOnCompletion = false
                    last.add(fadeOutAnimation, forKey: "fadeOut")
                }
                lastLayer = lyricLayer
            }
        case .none:
            break
        }
    }
    
    func changeWithProgress(_ progress: CGFloat) {
        if index >= images.count {
            index = 0
        }
        animatedView.image = images[index]
        index += 1
    }

}
