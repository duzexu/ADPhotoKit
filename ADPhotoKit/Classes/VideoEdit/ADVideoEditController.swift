//
//  ADVideoEditController.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/6.
//

import UIKit
import AVFoundation

/// System defalut video edit tools.
public struct ADVideoEditTools: OptionSet {
    public let rawValue: Int
    
    /// Tool used to add image sticker to video.
    public static let imageStkr = ADVideoEditTools(rawValue: 1 << 0)
    /// Tool used to add text sticker to video.
    public static let textStkr = ADVideoEditTools(rawValue: 1 << 1)
    /// Tool used to add backgroud music.
    public static let bgMusic = ADVideoEditTools(rawValue: 1 << 2)
    /// Tool used to clip video.
    public static let clip = ADVideoEditTools(rawValue: 1 << 3)
    /// Contains all tools.
    public static let all: ADVideoEditTools = [.imageStkr, .textStkr, .bgMusic, .clip]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct ADVideoEditInfo {
    
    /// Tools saved data. `Key` is tool's `identifier`.
    public var toolsJson: Dictionary<String,Any>?
    
    /// Edit result asset.
    public var editAsset: AVAsset?
    
}

public typealias ADVideoEditOptions = [ADVideoEditOptionsItem]

public enum ADVideoEditOptionsItem {
    case minTime(CGFloat)
    case maxTime(CGFloat)
}

class ADVideoEditController: UIViewController, ADVideoEditConfigurable {
    
    var videoDidEdit: ((ADVideoEditInfo) -> Void)?
    
    var cancelEdit: (() -> Void)?
    
    let asset: AVAsset
    var editInfo: ADVideoEditInfo
    let options: ADVideoEditOptions
    let videoSize: CGSize
    
    private var videoPlayerView: ADVideoPlayerView!
    
    private var contentView: ADVideoEditContentView!
    private var controlsView: ADVideoEditControlsView!
    
    private var isControlShow: Bool = true {
        didSet {
            if isControlShow != oldValue {
                if isControlShow {
                    UIView.animate(withDuration: 0.25) {
                        self.controlsView.alpha = 1
                    }
                }else{
                    UIView.animate(withDuration: 0.25) {
                        self.controlsView.alpha = 0
                    }
                }
            }
        }
    }
    
    required init(asset: AVAsset, editInfo: ADVideoEditInfo?, options: ADVideoEditOptions = []) {
        self.asset = asset
        self.editInfo = editInfo ?? ADVideoEditInfo()
        self.options = options
        self.videoSize = ADVideoUitls.getNaturalSize(asset: asset)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        definesPresentationContext = true
        
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        ADStickerInteractView.shared.ctx = self
        setupUI()
    }
    
    deinit {
        ADStickerInteractView.shared.clear()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension ADVideoEditController {
    
    func setupUI() {
        var min: CGFloat? = nil
        var max: CGFloat? = nil
        for item in options {
            switch item {
            case let .minTime(v):
                min = v
            case let .maxTime(v):
                max = v
            }
        }
        
        videoPlayerView = ADVideoPlayerView(asset: asset)
        videoPlayerView.addProgressObserver { _, time in
            ADStickerInteractView.shared.updatePlayerTime(time)
        }
        
        var tools: [ADVideoEditTool] = []
        let tool = ADPhotoKitConfiguration.default.systemVideoEditTools
        if tool.contains(.imageStkr) {
            if ADPhotoKitConfiguration.default.customImageStickerSelectVC == nil && ADPhotoKitConfiguration.default.imageStickerDataSource == nil {
                fatalError("`imageStickerDataSource` must not be `nil`")
            }
            tools.append(ADVideoSticker(style: .image))
        }
        if tool.contains(.textStkr) {
            tools.append(ADVideoSticker(style: .text))
        }
        if tool.contains(.bgMusic) {
            if ADPhotoKitConfiguration.default.customVideoMusicSelectVCBlock == nil && ADPhotoKitConfiguration.default.videoMusicDataSource == nil {
                fatalError("`videoMusicDataSource` must not be `nil`")
            }
            tools.append(ADVideoBGM())
        }
        if tool.contains(.clip) {
            if min != nil {
                min = min!/asset.duration.seconds
            }
            if max != nil {
                max = max!/asset.duration.seconds
            }
            let clip = ADVideoClip(asset: asset, min: min, max: max)
            tools.append(clip)
        }
        if let custom = ADPhotoKitConfiguration.default.customVideoEditToolsBlock?() {
            tools.append(contentsOf: custom)
        }
        
        for tool in tools {
            tool.playableRectUpdate = { [weak self] bottom, top, animated in
                self?.updatePlayableRect(bottom: bottom, top: top, animated: animated)
            }
            tool.setVideoPlayer(ADWeakRef(value: videoPlayerView))
        }
        
        contentView = ADVideoEditContentView(asset: asset, videoPlayer: videoPlayerView, tools: tools)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        controlsView = ADVideoEditControlsView(vc: self, tools: tools)
        controlsView.confirmActionBlock = { [weak self] in
            self?.confirmAction()
        }
        controlsView.cancelActionBlock = { [weak self] in
            self?.cancelEdit?()
        }
        view.addSubview(controlsView)
        controlsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if let json = editInfo.toolsJson {
            for tool in tools {
                if let data = json[tool.identifier] {
                    tool.decode(from: data)
                }
            }
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        singleTap.delegate = self
        view.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)

        let panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        panGes.delegate = self
        view.addGestureRecognizer(panGes)

        singleTap.require(toFail: panGes)
        
        let pinchGes = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        pinchGes.delegate = self
        view.addGestureRecognizer(pinchGes)
        
        let rotationGes = UIRotationGestureRecognizer(target: self, action: #selector(rotateAction(_:)))
        rotationGes.delegate = self
        view.addGestureRecognizer(rotationGes)
    }
    
}

extension ADVideoEditController {
    
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: view)
        if contentView.gestureShouldBegin(tap, point: point) {
            return
        }
        isControlShow = !isControlShow
    }
    
    @objc func doubleTapAction(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: view)
        _ = contentView.gestureShouldBegin(tap, point: point)
    }
    
    @objc func panAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        let trans = pan.translation(in: view)
        contentView.interact(with: .pan(loc: point, trans: trans), state: pan.state)
        pan.setTranslation(.zero, in: view)
        switch pan.state {
        case .began:
            isControlShow = false
        case .changed:
            break
        case .ended, .cancelled, .failed:
            isControlShow = true
        default:
            break
        }
    }
    
    @objc func pinchAction(_ pinch: UIPinchGestureRecognizer) {
        let point = pinch.location(in: view)
        contentView.interact(with: .pinch(scale: pinch.scale, point: point), state: pinch.state)
        pinch.scale = 1
        switch pinch.state {
        case .began:
            isControlShow = false
        case .changed:
            break
        case .ended, .cancelled, .failed:
            isControlShow = true
        default:
            break
        }
    }
    
    @objc func rotateAction(_ rotate: UIRotationGestureRecognizer) {
        let point = rotate.location(in: view)
        contentView.interact(with: .rotate(angle: rotate.rotation, point: point), state: rotate.state)
        rotate.rotation = 0
        switch rotate.state {
        case .began:
            isControlShow = false
        case .changed:
            break
        case .ended, .cancelled, .failed:
            isControlShow = true
        default:
            break
        }
    }
    
    func confirmAction() {
//        var json = Dictionary<String,Any>()
//        for tool in controlsView.tools {
//            json[tool.identifier] = tool.encode()
//        }
//        editInfo.toolsJson = json
//        if let editImage = contentView.editImage() {
//            let ori = clipInfo.rotation.imageOrientation
//            let edit = UIImage(cgImage: editImage.cgImage!, scale: editImage.scale, orientation: ori)
//            if clipInfo.clipRect == nil {
//                editInfo.editImg = edit
//            }else{
//                let rotation = clipInfo.rotation
//                let imageSize = rotation.imageSize(editImage.size)
//                let clipRect = imageSize|->clipInfo.clipRect!
//                UIGraphicsBeginImageContextWithOptions(clipRect.size, true, 1)
//                edit.draw(at: CGPoint(x: -clipRect.origin.x, y: -clipRect.origin.y))
//                let result = UIGraphicsGetImageFromCurrentImageContext()
//                UIGraphicsEndImageContext()
//                editInfo.editImg = result
//            }
//        }
//        imageDidEdit?(editInfo)
//        navigationController?.popViewController(animated: false)
    }
    
    func updatePlayableRect(bottom: CGFloat, top: CGFloat, animated: Bool) {
        if bottom == 0 && top == 0 {
            controlsView.alpha = 1
            if animated {
                UIView.animate(withDuration: 0.3) {
                    self.contentView.transform = .identity
                }
            }else{
                self.contentView.transform = .identity
            }
        }else{
            controlsView.alpha = 0
            let videoHWRatio = videoSize.height / videoSize.width
            let viewHWRatio = view.frame.height / view.frame.width
            var size: CGSize = .zero
            if videoHWRatio < viewHWRatio {
                size.width = view.frame.width
                size.height = view.frame.width * videoHWRatio
            } else {
                size.width = view.frame.height / videoHWRatio
                size.height = view.frame.height
            }
            let scale = size.height <= (view.frame.height - bottom - top) ? 1 : (view.frame.height - bottom - top)/size.height
            let newMidY = size.height * scale / 2 - view.frame.midY + top
            let scaleTf = CGAffineTransform(scaleX: scale, y: scale)
            let transTf = CGAffineTransform(translationX: 0, y: scale == 1 ? -bottom/2 : newMidY)
            if animated {
                UIView.animate(withDuration: 0.3) {
                    self.contentView.transform = scaleTf.concatenating(transTf)
                }
            }else{
                self.contentView.transform = scaleTf.concatenating(transTf)
            }
        }
    }
    
}

extension ADVideoEditController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: view)
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            if controlsView.point(inside: point, with: nil) {
                return false
            }
            return true
        }
        return contentView.gestureShouldBegin(gestureRecognizer, point: point) && !controlsView.point(inside: point, with: nil)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ADVideoEditController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = ADPresentationController(presentedViewController: presented, presenting: presenting)
        controller.appearance = self
        return controller
    }
}

extension ADVideoEditController: ADAppearanceDelegate {
    func presentationTransitionWillBegin() {
        isControlShow = false
    }
    
    func presentationTransitionDidEnd() {
        
    }
    
    func presentationDismissalWillBegin() {
        isControlShow = true
    }
    
    func presentationDismissalDidEnd() {
        
    }
}
