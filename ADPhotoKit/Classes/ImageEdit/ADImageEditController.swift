//
//  ADImageEditController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit
import SnapKit

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
    /// Contains all tools.
    public static let all: ADImageEditTools = [.lineDraw, .imageStkr, .textStkr, .clip, .mosaicDraw]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// Image edit info.
public struct ADImageEditInfo {
    
    /// Tools saved data. `Key` is tool's `identifier`.
    public var toolsJson: Dictionary<String,Any>?
    
    /// Origin image.
    public var originImg: UIImage
    
    /// Modifyed origin image.
    public var modifyImg: UIImage?
    
    /// Edit result image.
    public var editImg: UIImage?
    
}

class ADImageEditController: UIViewController, ADImageEditConfigurable {
    
    var imageDidEdit: ((ADImageEditInfo) -> Void)?
    
    var cancelEdit: (() -> Void)?
    
    let image: UIImage
    var editInfo: ADImageEditInfo
    var clipInfo: ClipInfo = ClipInfo()
    
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

    required init(image: UIImage, editInfo: ADImageEditInfo?) {
        self.image = image
        self.editInfo = editInfo ?? ADImageEditInfo(originImg: image)
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
        
        ADUndoManager.shared.clear()
        ADStickerInteractView.shared.ctx = self
        setupUI()
    }
    
    deinit {
        ADStickerInteractView.shared.clear()
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
            if ADPhotoKitConfiguration.default.customImageStickerSelectVCBlock == nil && ADPhotoKitConfiguration.default.imageStickerDataSource == nil {
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
            ADUndoManager.shared.regist(tool: tool)
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
        let rotation = clipInfo.rotation
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
        var edited = false
        var json = Dictionary<String,Any>()
        for tool in controlsView.tools {
            if tool.isEdited {
                json[tool.identifier] = tool.encode()
                edited = true
            }
        }
        if edited {
            editInfo.toolsJson = json
            if let editImage = contentView.editImage() {
                let ori = clipInfo.rotation.imageOrientation
                let edit = UIImage(cgImage: editImage.cgImage!, scale: editImage.scale, orientation: ori)
                if clipInfo.clipRect == nil {
                    editInfo.editImg = edit
                }else{
                    let rotation = clipInfo.rotation
                    let imageSize = rotation.imageSize(editImage.size)
                    let clipRect = imageSize|->clipInfo.clipRect!
                    UIGraphicsBeginImageContextWithOptions(clipRect.size, true, 1)
                    edit.draw(at: CGPoint(x: -clipRect.origin.x, y: -clipRect.origin.y))
                    let result = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    editInfo.editImg = result
                }
            }
            imageDidEdit?(editInfo)
        }else{
            cancelEdit?()
        }
        if let _ = navigationController?.popViewController(animated: false) {
        }else{
            dismiss(animated: false, completion: nil)
        }
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
        clipInfo.clipRect = clipRect
        clipInfo.rotation = rotation
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
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
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
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ADImageEditController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
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
        controlsView.reloadData()
    }
    
    func presentationDismissalDidEnd() {
        
    }
}

