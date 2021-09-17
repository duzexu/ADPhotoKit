//
//  ADImageEditController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit

/// System defalut image edit tools.
public struct ADImageEditTools: OptionSet {
    public let rawValue: Int
    
    /// Tool used to add color line to image.
    public static let lineDraw = ADImageEditTools(rawValue: 1 << 0)
    /// Tool used to add image sticker to image.
    public static let imageStkr = ADImageEditTools(rawValue: 1 << 1)
    /// Tool used to add text sticker to image.
    public static let textStkr = ADImageEditTools(rawValue: 1 << 2)
    /// Tool used to clip image.
    public static let clip = ADImageEditTools(rawValue: 1 << 3)
    /// Tool used to add mosaic effect to image.
    public static let mosaicDraw = ADImageEditTools(rawValue: 1 << 4)
    
    public static let all: ADImageEditTools = [.lineDraw, .imageStkr, .textStkr, .clip, .mosaicDraw]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// Image edit info.
public struct ADImageEditInfo {
    
    /// Tools saved data. `Key` is tool's `identifier`.
    public var toolsJson: Dictionary<String,Any>?
    
    /// Modifyed origin image.
    public var modifyImg: UIImage?
    
    /// Edit result image.
    public var editImg: UIImage?
    
    var clipRect: CGRect?
    var rotation: ADRotation?
    
}

/// Image rotation.
public enum ADRotation: CGFloat {
    /// No rotation.
    case idle = 0
    /// Rotate left.
    case left = -90
    /// Rotate right.
    case right = 90
    /// Rotate upside down.
    case down = 180
    
    /// Rotate left.
    /// - Returns: Rotation after rotate left.
    public func rotateLeft() -> ADRotation {
        switch self {
        case .idle:
            return .left
        case .left:
            return .down
        case .right:
            return .idle
        case .down:
            return .right
        }
    }
    
    func imageSize(_ size: CGSize) -> CGSize {
        switch self {
        case .idle,.down:
            return size
        case .left,.right:
            return CGSize(width: size.height, height: size.width)
        }
    }
    
    func clipRect(_ rect: CGRect) -> CGRect {
        switch self {
        case .idle:
            return rect
        case .left:
            return rect.rotateRight()
        case .right:
            return rect.rotateRight().rotateRight().rotateRight()
        case .down:
            return rect.rotateRight().rotateRight()
        }
    }
    
    var imageOrientation: UIImage.Orientation {
        switch self {
        case .idle:
            return .up
        case .left:
            return .left
        case .right:
            return .right
        case .down:
            return .down
        }
    }
}

class ADImageEditController: UIViewController {
    
    var imageDidEdit: ((ADImageEditInfo) -> Void)?
    
    let image: UIImage
    var editInfo: ADImageEditInfo
    
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
    
    init(image: UIImage, editInfo: ADImageEditInfo? = nil) {
        self.image = image
        self.editInfo = editInfo ?? ADImageEditInfo()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        definesPresentationContext = true
        
        ADStickerInteractView.share.clear()
        ADStickerInteractView.share.ctx = self
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
            tools.append(ADImageSticker(style: .image))
        }
        if tool.contains(.textStkr) {
            tools.append(ADImageSticker(style: .text))
        }
        if tool.contains(.clip) {
            tools.append(ADImageClip(source: self))
        }
        if tool.contains(.mosaicDraw) {
            tools.append(ADImageDraw(style: .mosaic(image)))
        }
        if let custom = ADPhotoKitConfiguration.default.customImageEditToolsBlock?(image) {
            tools.append(contentsOf: custom)
        }
        
        for tool in tools {
            if var editable = tool as? ADSourceImageEditable {
                editable.modifySourceImage = { [weak self] image in
                    self?.sourceImageDidChanged(image)
                }
            }
        }
        
        contentView = ADImageEditContentView(image: editInfo.modifyImg ?? image, tools: tools)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.update(clipRect: nil, rotation: .idle)
        
        controlsView = ADImageEditControlsView(vc: self, tools: tools)
        controlsView.contentStatus = { [weak self] lock in
            self?.contentView.scrollView.isScrollEnabled = !lock
        }
        controlsView.confirmActionBlock = { [weak self] in
            self?.confirmAction()
        }
        view.addSubview(controlsView)
        controlsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if let json = editInfo.toolsJson {
            for tool in controlsView.tools {
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
        
        contentView.scrollView.pinchGestureRecognizer?.require(toFail: pinchGes)
        contentView.scrollView.panGestureRecognizer.require(toFail: panGes)
    }
    
    func sourceImageDidChanged(_ image: UIImage) {
        editInfo.modifyImg = image
        contentView.sourceImageChanged(image)
        for tool in controlsView.tools {
            if let modify = tool as? ADSourceImageModify {
                modify.sourceImageDidModify(image)
            }
        }
    }
}

extension ADImageEditController {
    
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
        var trans = pan.translation(in: view)
        let rotation = editInfo.rotation ?? .idle
        switch rotation {
        case .idle:
            break
        case .left:
            trans = CGPoint(x: -trans.y, y: trans.x)
        case .right:
            trans = CGPoint(x: trans.y, y: -trans.x)
        case .down:
            trans = CGPoint(x: -trans.x, y: -trans.y)
        }
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
        var json = Dictionary<String,Any>()
        for tool in controlsView.tools {
            json[tool.identifier] = tool.encode()
        }
        editInfo.toolsJson = json
        if let editImage = contentView.editImage() {
            let ori = editInfo.rotation?.imageOrientation ?? .up
            let edit = UIImage(cgImage: editImage.cgImage!, scale: editImage.scale, orientation: ori)
            if editInfo.clipRect == nil {
                editInfo.editImg = edit
            }else{
                let rotation = editInfo.rotation ?? .idle
                let imageSize = rotation.imageSize(editImage.size)
                let clipRect = imageSize|->editInfo.clipRect!
                UIGraphicsBeginImageContextWithOptions(clipRect.size, true, 1)
                edit.draw(at: CGPoint(x: -clipRect.origin.x, y: -clipRect.origin.y))
                let result = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                editInfo.editImg = result
            }
        }
        imageDidEdit?(editInfo)
        navigationController?.popViewController(animated: false)
    }
    
}

extension ADImageEditController: ADImageClipSource {
    func clipSource() -> ADClipSource {
        defer {
            contentView.resetZoomLevel()
        }
        let img = contentView.editImage() ?? image
        let clipImage = contentView.clipImage() ?? image
        let rect = contentView.scrollView.convert(contentView.container.frame, to: view)
        return ADClipSource(image: img, clipImage: clipImage, clipFrom: rect)
    }
    
    func clipInfoDidConfirmed(_ clipRect: CGRect?, rotation: ADRotation) {
        editInfo.clipRect = clipRect
        editInfo.rotation = rotation
        contentView.update(clipRect: clipRect, rotation: rotation)
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
        if contentView.scrollView.isZooming {
            return false
        }
        let point = gestureRecognizer.location(in: view)
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            if controlsView.point(inside: point, with: nil) {
                return false
            }
            return true
        }
        return contentView.gestureShouldBegin(gestureRecognizer, point: point) && !controlsView.point(inside: point, with: nil)
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

