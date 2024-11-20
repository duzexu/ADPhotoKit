//
//  ADMusicSelectController.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/9.
//

import UIKit
import AVFoundation
import Kingfisher

/// Single line lyrics info.
public struct ADLyricItem {
    /// Lyric text.
    public let text: String
    /// Start time.
    public let offset: CGFloat
    /// Create lyric item.
    public init(text: String, offset: CGFloat) {
        self.text = text
        self.offset = offset
    }
}

/// Music info.
public struct ADMusicItem: Equatable {
    
    /// Music extended info.
    public enum Extra {
        case none
        /// Music lyric.
        case lyric([ADLyricItem])
        /// Text info.
        case text(String)
    }
    
    /// Music id.
    public let id: String
    /// Music asset.
    public let asset: AVAsset
    /// Music cover.
    public let cover: Kingfisher.Source?
    /// Music name.
    public let name: String
    /// Music singer.
    public let singer: String
    /// Music extended info.
    public let extra: Extra
    
    /// Create music item.
    public init(id: String, asset: AVAsset, cover: Kingfisher.Source?, name: String, singer: String, extra: Extra = .none) {
        self.id = id
        self.asset = asset
        self.cover = cover
        self.name = name
        self.singer = singer
        self.extra = extra
    }
    
    public static func == (lhs: ADMusicItem, rhs: ADMusicItem) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Video bgm setting.
public class ADVideoSound {
    
    /// Whether to show lyrics.
    public var lyricOn: Bool = false
    /// Whether to include the original sound of the video
    public var ostOn: Bool = true
    /// Video bgm, `nil` means no bgm included.
    public var bgm: ADMusicItem? = nil
    /// Whether bgm loop play.
    public var bgmLoop: Bool = true
    
    /// Create video sound.
    public init(lyricOn: Bool = false, ostOn: Bool = true, bgm: ADMusicItem? = nil, bgmLoop: Bool = true) {
        self.lyricOn = lyricOn
        self.ostOn = ostOn
        self.bgm = bgm
        self.bgmLoop = bgmLoop
    }
}

/// Music select datasource.
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
        self.sound = sound ?? ADVideoSound()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playableRectUpdate?(bottomHeight, 0, true)

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
        bgmSelectView.searchMusic = { [weak self] keyword in
            self?.searchWith(keyword: keyword)
        }
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
