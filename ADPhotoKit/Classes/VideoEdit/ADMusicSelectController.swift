//
//  ADMusicSelectController.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/9.
//

import UIKit
import AVFoundation
import Kingfisher

public struct ADMusicLyric {
    public let text: String
    public let offset: CGFloat
    
    public init(text: String, offset: CGFloat) {
        self.text = text
        self.offset = offset
    }
}

public struct ADMusicItem {
    public let id: String
    public let asset: AVAsset
    public let cover: Kingfisher.Source?
    public let name: String
    public let singer: String
    public let lyric: [ADMusicLyric]?
    
    public init(id: String, asset: AVAsset, cover: Kingfisher.Source?, name: String, singer: String, lyric: [ADMusicLyric]? = nil) {
        self.id = id
        self.asset = asset
        self.cover = cover
        self.name = name
        self.singer = singer
        self.lyric = lyric
    }
}

public class ADVideoSound {
    public var lyricOn: Bool = false
    public var ostOn: Bool = true
    public var bgm: ADMusicItem? = nil
    public var bgmLoop: Bool = true
    
    public static let `default` = ADVideoSound()
}

public typealias ADVideoMusicDataSource = ((_ keyword: String?, _ completion: (([ADMusicItem]) -> Void)) -> Void)

class ADMusicSelectController: UIViewController, ADVideoMusicSelectConfigurable {
    
    var soundDidChange: ((ADVideoSound) -> Void)?
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)?
    
    let dataSource: ADVideoMusicDataSource
    let sound: ADVideoSound
    let bottomHeight = 556+safeAreaInsets.bottom
    
    private var bgmSelectView: ADVideoBGMSelectView!
    private var bottomView: UIView!
    
    required init(dataSource: @escaping ADVideoMusicDataSource, sound: ADVideoSound?) {
        self.dataSource = dataSource
        self.sound = sound ?? .default
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        singleTap.delegate = self
        view.addGestureRecognizer(singleTap)
        
        searchWith(keyword: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let path = UIBezierPath(roundedRect: bottomView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8))
        bottomView.layer.mask = nil
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        bottomView.layer.mask = maskLayer
    }

}

private extension ADMusicSelectController {
    func setupUI() {
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(bottomHeight)
        }
        bgmSelectView = ADVideoBGMSelectView(sound: sound, change: { [weak self] in
            self?.soundConfigChange()
        })
        bottomView.addSubview(bgmSelectView)
        bgmSelectView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-safeAreaInsets.bottom)
            make.top.equalToSuperview().offset(28)
        }
        let dragBar = ADPageSheetDragBar(threshold: 300)
        dragBar.dragDidEnded = { [weak self] valid in
            self?.dragDidEnd(valid: valid)
        }
        dragBar.offsetDidChange = { [weak self] offset in
            self?.playableRectUpdate?(self!.bottomHeight-offset, 0, false)
            self?.bottomView.transform = CGAffineTransform(translationX: 0, y: offset)
        }
        bottomView.addSubview(dragBar)
        dragBar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(28)
        }
    }
    
    func searchWith(keyword: String?) {
        let block: (([ADMusicItem]) -> Void) = { [weak self] items in
            self?.bgmSelectView.reload(items: items)
        }
        dataSource(keyword, block)
    }
    
    func soundConfigChange() {
        soundDidChange?(sound)
        if sound.lyricOn, let music = sound.bgm {
            if let content = ADStickerInteractView.shared.contentWithId(ADLyricsStickerContentView.LyricsStickerId) as? ADLyricsStickerContentView {
                if music.id != content.music.id {
                    content.updateMusic(music)
                }
            }else{
                let content = ADLyricsStickerContentView(music: music)
                content.soundDidChange = soundDidChange
                content.playableRectUpdate = playableRectUpdate
                ADStickerInteractView.shared.addContent(content)
            }
        }else{
            ADStickerInteractView.shared.removeContent(ADLyricsStickerContentView.LyricsStickerId)
        }
    }
}

extension ADMusicSelectController {
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        playableRectUpdate?(0, 0, true)
        dismiss(animated: true, completion: nil)
    }
    
    func dragDidEnd(valid: Bool) {
        if valid {
            playableRectUpdate?(0, 0, true)
            UIView.animate(withDuration: 0.3) {
                self.bottomView.alpha = 0
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.bottomHeight)
            } completion: { _ in
                self.dismiss(animated: false, completion: nil)
            }
        }else{
            playableRectUpdate?(self.bottomHeight, 0, true)
            UIView.animate(withDuration: 0.3) {
                self.bottomView.transform = .identity
            }
        }
    }
}

extension ADMusicSelectController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: view)
        return !bottomView.frame.contains(point)
    }
}
