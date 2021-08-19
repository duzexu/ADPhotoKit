//
//  ADImageEditController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit

public struct ADImageEditTools: OptionSet {
    public let rawValue: Int
    
    public static let lineDraw = ADImageEditTools(rawValue: 1 << 0)
    public static let imageStkr = ADImageEditTools(rawValue: 1 << 1)
    public static let textStkr = ADImageEditTools(rawValue: 1 << 2)
    public static let clip = ADImageEditTools(rawValue: 1 << 3)
    public static let mosaicDraw = ADImageEditTools(rawValue: 1 << 4)
    
    public static let all: ADImageEditTools = [.lineDraw, .imageStkr, .textStkr, .clip, .mosaicDraw]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct ADEditInfo {
    var editImg: UIImage?
    var clipRect: CGRect?
    var rotation: CGFloat?
}

class ADImageEditController: UIViewController {
    
    let image: UIImage
    
    var editInfo: ADEditInfo!
    
    var contentView: ADImageEditContentView!
    var controlsView: ADImageEditControlsView!
    
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
    
    init(image: UIImage) {
        self.image = image
        self.editInfo = ADEditInfo()
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("[deinit]ADImageEditController")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        definesPresentationContext = true
        
        ADStickerInteractView.share.clear()
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension ADImageEditController {
    
    func setupUI() {
        var tools: [ADImageEditTool] = []
        let tool = ADPhotoKitConfiguration.default.systemImageEditTools
        if tool.contains(.lineDraw) {
            if ADPhotoKitConfiguration.default.lineDrawDefaultColorIndex > ADPhotoKitConfiguration.default.lineDrawColors.count {
                fatalError("`lineDrawDefaultColorIndex` must less then `lineDrawColors`'s count")
            }
            tools.append(ADImageDraw(style: .line(ADPhotoKitConfiguration.default.lineDrawColors, ADPhotoKitConfiguration.default.lineDrawDefaultColorIndex)))
        }
        if tool.contains(.imageStkr) {
            if ADPhotoKitConfiguration.default.customImageStickerSelectVC == nil && ADPhotoKitConfiguration.default.imageStickerDataSource == nil {
                fatalError("`imageStickerDataSource` must not be `nil`")
            }
            tools.append(ADImageSticker(style: .image([])))
        }
        if tool.contains(.textStkr) {
            tools.append(ADImageSticker(style: .text([])))
        }
        if tool.contains(.clip) {
            tools.append(ADImageClip(source: self))
        }
        if tool.contains(.mosaicDraw) {
            tools.append(ADImageDraw(style: .mosaic(image)))
        }
        if let custom = ADPhotoKitConfiguration.default.customImageEditTools {
            tools.append(contentsOf: custom)
        }
        
        contentView = ADImageEditContentView(image: image, tools: tools)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        controlsView = ADImageEditControlsView(vc: self, tools: tools)
        controlsView.contentStatus = { [weak self] lock in
            self?.contentView.scrollView.isScrollEnabled = !lock
        }
        view.addSubview(controlsView)
        controlsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        view.addGestureRecognizer(singleTap)

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
        
        contentView.scrollView.pinchGestureRecognizer?.require(toFail: pinchGes)
        contentView.scrollView.panGestureRecognizer.require(toFail: panGes)
    }
    
}

extension ADImageEditController {
    
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: view)
        if controlsView.singleTap(with: point) {
            return
        }
        if contentView.gestureShouldBegin(tap, point: point) {
            return
        }
        isControlShow = !isControlShow
    }
    
    @objc func panAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        let trans = pan.translation(in: view)
        contentView.container.interactContainer.clipsToBounds = contentView.interact(with: .pan(loc: point, trans: trans), state: pan.state)
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
        contentView.container.interactContainer.clipsToBounds = contentView.interact(with: .pinch(pinch.scale), state: pinch.state)
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
        contentView.container.interactContainer.clipsToBounds = contentView.interact(with: .rotate(rotate.rotation), state: rotate.state)
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
    
}

extension ADImageEditController: ADImageClipSource {
    func clipInfo() -> ADClipInfo {
        let img = contentView.container.processImage() ?? image
        let clipImage = contentView.clipImage() ?? image
        let rect = contentView.scrollView.convert(contentView.container.frame, to: view)
        return ADClipInfo(image: img, clipRect: editInfo.clipRect, rotation: nil, clipImage: clipImage, clipFrom: rect)
    }
    
    func clipRectDidConfirmed(_ rect: CGRect?) {
        editInfo.clipRect = rect
        contentView.updateClipRect(rect)
    }
}

extension ADImageEditController: ADImageClipDismissTransitionContextTo {
    func transitionRect(convertTo: UIView) -> CGRect? {
        return contentView.scrollView.convert(contentView.container.frame, to: convertTo)
    }
    
    func transitionDidFinish() {
        isControlShow = true
    }
}

extension ADImageEditController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: view)
        return contentView.gestureShouldBegin(gestureRecognizer, point: point)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ADImageEditController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = ADPresentationController(presentedViewController: presented, presenting: presenting)
        controller.appearance = self
        return controller
    }
}

extension ADImageEditController: ADAppearanceDelegate {
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

