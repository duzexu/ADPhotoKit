//
//  ADImageStickerView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit

/// Base class for storing sticker information.
/// - Note: You need to inherit and use it's subclass.
/// - Note: To create a new sticker type you need to create a class that inherits `ADStickerInfo` and a corresponding class that inherits `ADStickerContentView`.
/// - SeeAlso ``ADStickerContentView``
public class ADStickerInfo {
    
    /// Identifier of content view.
    public let id: String
    /// Transform of content view.
    public let transform: CGAffineTransform
    /// Center of content view.
    public let center: CGPoint
    /// Normalize center of content view.
    public let normalizeCenter: CGPoint
    
    /// Default Initialization Method.
    public init(id: String, transform: CGAffineTransform, center: CGPoint, normalizeCenter: CGPoint) {
        self.id = id
        self.transform = transform
        self.center = center
        self.normalizeCenter = normalizeCenter
    }
}

/// Class for storing image sticker information.
public class ADImageStickerInfo: ADStickerInfo {
    
    /// Stciker image.
    public let image: UIImage
    
    /// Default Initialization Method.
    public init(id: String, transform: CGAffineTransform, center: CGPoint, normalizeCenter: CGPoint, image: UIImage) {
        self.image = image
        super.init(id: id, transform: transform, center: center, normalizeCenter: normalizeCenter)
    }
}

class ADTextStickerInfo: ADImageStickerInfo {
    let sticker: ADTextSticker
    
    init(id: String, transform: CGAffineTransform, center: CGPoint, normalizeCenter: CGPoint, image: UIImage, sticker: ADTextSticker) {
        self.sticker = sticker
        super.init(id: id, transform: transform, center: center, normalizeCenter: normalizeCenter, image: image)
    }
}

/// Used to record sticker editing operations.
public enum ADStickerActionData {
    /// Add or remove sticker operation.
    case update(old: ADStickerInfo?, new: ADStickerInfo?)
    /// Move sticker operation.
    case move(old: ADStickerInfo, new: ADStickerInfo)
}

/// Handler for different sticker types.
public struct ADStickerInteractHandle<T: ADStickerInfo> {
    
    /// Called when editing operation changed.
    public var actionDataDidChange: ((ADStickerActionData) -> Void)
    
    /// Called when create view from sticker info.
    public var contentViewWithInfo: ((T) -> ADStickerContentView)
}

/// Shared view that you can add sticker to.
public class ADStickerInteractView: UIView, ADToolInteractable {
    
    public var zIndex: Int {
        return ADInteractZIndex.Top.rawValue
    }
    
    public var strategy: ADInteractStrategy  {
        return .simult
    }
    
    public var interactClipBounds: Bool {
        return false
    }
    
    public var clipingScreenInfo: ADClipingInfo? = nil {
        didSet {
            updateClipingScreenInfo()
        }
    }
    
    public func shouldInteract(_ gesture: UIGestureRecognizer, point: CGPoint) -> Bool {
        for item in container.subviews.reversed() {
            if item.frame.contains(point) {
                target = item as? ADStickerContentView
                break
            }
        }
        if target != activeTarget {
            activeTarget?.resignActive()
        }
        if gesture.isKind(of: UITapGestureRecognizer.self) {
            if let t = target {
                activeTarget = t
                if (gesture as! UITapGestureRecognizer).numberOfTapsRequired == 1 {
                    if t.isActive {
                        t.resignActive()
                    }else{
                        t.beginActive()
                    }
                }else{
                    t.doubleTapAction(ctx: ctx)
                }
                target = nil
                return true
            }
        }else{
            return target != nil
        }
        return false
    }
    
    public func interact(with interactType: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) -> TimeInterval? {
        switch interactType {
        case let .pan(loc, trans):
            target?.translation(by: CGPoint(x: trans.x/scale, y: trans.y/scale))
            if state == .changed {
                if trashView.frame.contains(loc) {
                    trashView.isConfirmed = true
                }else{
                    if trashView.isConfirmed {
                        trashView.isHidden = true
                    }
                }
            }
        case let .pinch(scale,_):
            target?.pinch(by: scale)
        case let .rotate(angle,_):
            target?.rotate(by: angle)
        }
        switch state {
        case .began:
            oldSrickerInfo = target?.stickerInfo
            presentTrashView()
            target?.beginActive(resignable: false)
            if let tg = target {
                tg.center = container.convert(tg.center, to: self)
                insertSubview(tg, belowSubview: trashView)
            }
        case .ended, .cancelled, .failed:
            if trashView.isConfirmed && !trashView.isHidden {
                if let _ = target?.stickerID {
                    if let handle = stickerHandles[String(describing: type(of: oldSrickerInfo!))] {
                        handle.actionDataDidChange(.update(old: oldSrickerInfo, new: nil))
                    }
                }
                target?.removeFromSuperview()
                target = nil
            }
            dismissTrashView()
            var animated: Bool = false
            if let tg = target {
                let clipCenter = clipView.center
                let height = clipingScreenInfo?.clip.height ?? bounds.height
                let width = clipingScreenInfo?.clip.width ?? bounds.width
                if abs(Float(clipCenter.y - tg.center.y)) - Float(height/2+tg.frame.height/2) >= -10 || abs(Float(clipCenter.x - tg.center.x)) - Float(width/2+tg.frame.width/2) >= -10 {
                    animated = true
                }else{
                    tg.center = convert(tg.center, to: container)
                }
                
                if let handle = stickerHandles[String(describing: type(of: oldSrickerInfo!))] {
                    handle.actionDataDidChange(.move(old: oldSrickerInfo!, new: tg.stickerInfo))
                }

                if animated {
                    UIView.animate(withDuration: 0.3) {
                        tg.center = clipCenter
                    } completion: { _ in
                        self.container.addSubview(tg)
                    }
                }else{
                    container.addSubview(tg)
                }
            }
            target?.beginActive()
            activeTarget = target
            target = nil
            oldSrickerInfo = nil
            if animated {
                return 0.3
            }
        default:
            break
        }
        return nil
    }
    
    public func willBeginRenderImage() {
        for item in container.subviews {
            (item as! ADStickerContentView).resignActive()
        }
        clipView.clipsToBounds = false
    }
    
    public func didEndRenderImage() {
        clipView.clipsToBounds = true
    }
    
    /// Get shared sticker interact view.
    public static var shared = ADStickerInteractView()
        
    weak var ctx: UIViewController?
    
    private var clipView: UIView!
    internal var container: UIView!
    
    private lazy var trashView: TrashView = {
        let view = TrashView(frame: CGRect(x: 0, y: 0, width: 160, height: 80))
        view.isHidden = true
        addSubview(view)
        return view
    }()
    
    private var trashIdentifyTrans: CGAffineTransform = .identity
        
    private weak var target: ADStickerContentView?
    private weak var activeTarget: ADStickerContentView?
    private var oldSrickerInfo: ADStickerInfo?
    
    struct InteractHandleInternal {
        var actionDataDidChange: ((ADStickerActionData) -> Void)
        var contentViewWithInfo: ((ADStickerInfo) -> ADStickerContentView)
    }
    
    private var stickerHandles: [String:InteractHandleInternal] = [:]
    
    init() {
        super.init(frame: .zero)
        clipView = UIView()
        clipView.clipsToBounds = true
        addSubview(clipView)
        container = UIView()
        container.clipsToBounds = false
        clipView.addSubview(container)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateClipingScreenInfo()
    }
    
    /// Add sticker content to shared view.
    /// - Parameter view: Sticker content.
    public func addContent<T>(_ view: T) where T : ADStickerContentView {
        activeTarget?.resignActive()
        activeTarget = view
        if let info = clipingScreenInfo {
            view.outerScale = info.scale
            view.pinch(by: 1/info.scale)
            view.rotate(by: -info.rotate.rawValue/180.0*CGFloat.pi)
            view.center = CGPoint(x: info.screen.midX, y: info.screen.midY)
        }else{
            view.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        }
        container.addSubview(view)
        view.actionDataDidChange = { [weak self] cls,action in
            if let handle = self?.stickerHandles[String(describing: cls)] as? ADStickerInteractHandle {
                handle.actionDataDidChange(action)
            }
        }
        view.beginActive()
    }
    
    /// Add sticker content to shared view.
    /// - Parameter view: Sticker content
    /// - Note: Use this method when revert saved data from encode data.
    /// - Note: The difference from ``addContent(_:)`` is you must set `contentView`'s transform, center and scale by yourself.`
    public func appendContent<T>(_ view: T) where T : ADStickerContentView {
        container.addSubview(view)
        view.actionDataDidChange = { [weak self] cls,action in
            if let handle = self?.stickerHandles[String(describing: cls)] as? ADStickerInteractHandle {
                handle.actionDataDidChange(action)
            }
        }
    }
    
    /// Regist handler for different sticker types.
    /// - Parameters:
    ///   - handle: sticker handle.
    ///   - cls: Your sticker info type.
    public func registHandle<T: ADStickerInfo>(_ handle: ADStickerInteractHandle<T>, for cls: T.Type) {
        stickerHandles[String(describing: cls)] = InteractHandleInternal(actionDataDidChange: handle.actionDataDidChange, contentViewWithInfo: { info in
            handle.contentViewWithInfo(info as! T)
        })
    }
    
    /// Add sticker content with sticker info.
    /// - Parameter info: Sticker info.
    /// - Returns: Added content view.
    /// - Note: You must call ``registHandle(_:for:)`` first to make it possible to create different views based on different sticker infos.
    @discardableResult
    public func addContentWithInfo(_ info: ADStickerInfo) -> ADStickerContentView? {
        if let handle = stickerHandles[String(describing: type(of: info))] {
            let content = handle.contentViewWithInfo(info)
            appendContent(content)
            return content
        }
        return nil
    }
    
    /// Undo sticker editing action.
    /// - Parameter action: Edit action data.
    /// - Returns: Added content view.
    @discardableResult
    public func undo(action: ADStickerActionData) -> ADStickerContentView? {
        switch action {
        case .update(let old, let new):
            guard let old else {
                if let id = new?.id {
                    removeContent(id)
                }
                return nil
            }
            removeContent(old.id)
            if let handle = stickerHandles[String(describing: type(of: old))] {
                let content = handle.contentViewWithInfo(old)
                appendContent(content)
                return content
            }
        case .move(old: let old, new: _):
            for sub in container.subviews.reversed() {
                if (sub as! ADStickerContentView).stickerID == old.id {
                    (sub as! ADStickerContentView).update(info: old)
                    break
                }
            }
        }
        return nil
    }
    
    /// Redo sticker editing action.
    /// - Parameter action: Edit action data.
    /// - Returns: Added content view.
    @discardableResult
    public func redo(action: ADStickerActionData) -> ADStickerContentView? {
        switch action {
        case .update(let old, let new):
            guard let new else {
                if let id = old?.id {
                    removeContent(id)
                }
                return nil
            }
            removeContent(new.id)
            if let handle = stickerHandles[String(describing: type(of: new))] {
                let content = handle.contentViewWithInfo(new)
                appendContent(content)
            }
        case .move(old: _, new: let new):
            for sub in container.subviews.reversed() {
                if (sub as! ADStickerContentView).stickerID == new.id {
                    (sub as! ADStickerContentView).update(info: new)
                    break
                }
            }
        }
        return nil
    }
    
    /// Clear all content in shared view.
    public func clear() {
        container.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// Remove sticker content.
    /// - Parameter stickerID: Sticker stickerID.
    public func removeContent(_ stickerID: String) {
        for sub in container.subviews.reversed() {
            if (sub as! ADStickerContentView).stickerID == stickerID {
                sub.removeFromSuperview()
                break
            }
        }
    }
    
    /// Get sticker content with stickerID.
    /// - Parameter stickerID: Sticker stickerID.
    /// - Returns: Sticker content view.
    public func contentWithId(_ stickerID: String) -> ADStickerContentView? {
        for sub in container.subviews.reversed() {
            if (sub as! ADStickerContentView).stickerID == stickerID {
                return (sub as! ADStickerContentView)
            }
        }
        return nil
    }
        
    func presentTrashView() {
        guard trashView.isHidden else {
            return
        }
        trashView.isHidden = false
        trashView.transform = trashIdentifyTrans.translatedBy(x: 0, y: 130)
        UIView.animate(withDuration: 0.2) {
            self.trashView.transform = self.trashIdentifyTrans
        }
    }
    
    func dismissTrashView() {
        trashView.isConfirmed = false
        UIView.animate(withDuration: 0.2) {
            self.trashView.transform = self.trashIdentifyTrans.translatedBy(x: 0, y: 130)
        } completion: { _ in
            self.trashView.isHidden = true
        }
    }
    
    func updateClipingScreenInfo() {
        if let info = clipingScreenInfo {
            let scale = CGAffineTransform(scaleX: 1/info.scale, y: 1/info.scale)
            let rotate = CGAffineTransform(rotationAngle: -info.rotate.rawValue/180*CGFloat.pi)
            trashIdentifyTrans = rotate.concatenating(scale)
            switch info.rotate {
            case .idle:
                trashView.center = CGPoint(x: info.screen.midX, y: info.screen.maxY - (40 + 15)/info.scale)
            case .left:
                trashView.center = CGPoint(x: info.screen.minX + (40 + 15)/info.scale, y: info.screen.midY)
            case .right:
                trashView.center = CGPoint(x: info.screen.maxX - (40 + 15)/info.scale, y: info.screen.midY)
            case .down:
                trashView.center = CGPoint(x: info.screen.midX, y: info.screen.minY + (40 + 15)/info.scale)
            }
            for view in container.subviews {
                let content = view as! ADStickerContentView
                content.outerScale = info.scale
            }
            clipView.frame = info.clip
            container.frame = convert(bounds, to: clipView)
        }else{
            trashView.center = CGPoint(x: bounds.width/2, y: bounds.height - 56)
            trashIdentifyTrans = .identity
            for content in container.subviews {
                (content as! ADStickerContentView).outerScale = 1
            }
            clipView.frame = bounds
            container.frame = bounds
        }
    }
    
    class TrashView: UIView {
        
        var isConfirmed: Bool = false {
            didSet {
                imageView.isHighlighted = isConfirmed
                bgView.isHidden = isConfirmed
                backgroundColor = isConfirmed ? UIColor(hex: 0xF14F4F, alpha: 0.98) : .clear
                tipsLabel.text = isConfirmed ? ADLocale.LocaleKey.textStickerReleaseToDelete.localeTextValue : ADLocale.LocaleKey.textStickerDeleteTips.localeTextValue
            }
        }
        
        var bgView: UIVisualEffectView!
        var imageView: UIImageView!
        var tipsLabel: UILabel!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.cornerRadius = 15
            layer.masksToBounds = true
            
            bgView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            addSubview(bgView)
            bgView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            imageView = UIImageView(image: Bundle.image(name: "icons_filled_delete", module: .imageEdit), highlightedImage: Bundle.image(name: "icons_filled_delete_on", module: .imageEdit))
            addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(18)
                make.centerX.equalToSuperview()
            }
            tipsLabel = UILabel()
            tipsLabel.textAlignment = .center
            tipsLabel.font = UIFont.systemFont(ofSize: 12)
            tipsLabel.textColor = .white
            tipsLabel.text = ADLocale.LocaleKey.textStickerDeleteTips.localeTextValue
            addSubview(tipsLabel)
            tipsLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalTo(34)
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}

/// Sticker base content view that you can add to `ADStickerInteractView`.
/// - Note: You need to inherit and use it's subclass.
/// - Note: To create a new sticker type you need to create a class that inherits `ADStickerInfo` and a corresponding class that inherits `ADStickerContentView`.
/// - SeeAlso ``ADStickerInfo``
public class ADStickerContentView: UIView {
    
    /// Identifier of the content view.
    public let stickerID: String
    
    /// Sticker info from current view state.
    public var stickerInfo: ADStickerInfo {
        return ADStickerInfo(id: stickerID, transform: transform, center: center, normalizeCenter: normalizeCenter)
    }
    
    /// Normalize center of content view.
    public var normalizeCenter: CGPoint {
        if let clip = superview?.superview {
            let convert = superview!.convert(center, to: clip)
            return CGPoint(x: convert.x/superview!.superview!.frame.width, y: convert.y/superview!.superview!.frame.height)
        }
        return .zero
    }
    
    var actionDataDidChange: ((AnyClass,ADStickerActionData) -> Void)?
    
    var isActive: Bool = false
    
    let maxScale: CGFloat = 10
    
    fileprivate var scale: CGFloat = 1 {
        didSet {
            updateBorderWidth()
        }
    }
    
    fileprivate var outerScale: CGFloat = 1 {
        didSet {
            updateBorderWidth()
        }
    }
    
    /// Initial view whith frame.
    /// - Parameter size: View size.
    /// - Parameter id: View identifier.
    public init(size: CGSize, id: String = UUID().uuidString) {
        self.stickerID = id
        super.init(frame: CGRect(origin: .zero, size: size))
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.clear.cgColor
    }
    
    /// Initial view whith sticker info.
    /// - Parameter info: Sticker info.
    public init(info: ADStickerInfo) {
        stickerID = info.id
        super.init(frame: .zero)
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.clear.cgColor
        transform = info.transform
        center = info.center
        scale = getScale(from: info.transform).scaleX
    }
    
    /// Update view whith sticker info.
    /// - Parameter info: Sticker info.
    public func update(info: ADStickerInfo) {
        guard info.id == stickerID else {
            return
        }
        transform = info.transform
        center = info.center
        scale = getScale(from: info.transform).scaleX
    }
    
    /// Call this method when sticker size changed.
    /// - Parameter size: New sticker size.
    public func sizeDidChange(_ size: CGSize) {
        let oldCenter = center
        let oldTrans = transform
        transform = .identity
        frame.size = size
        transform = oldTrans
        center = oldCenter
    }
    
    /// Called when double tap the content view. Subclass can override and do some operation.
    /// - Parameter ctx: Image edit controller.
    open func doubleTapAction(ctx: UIViewController?) {
        
    }
    
    /// Called when translation the content view. Subclass can override and do some operation.
    /// - Parameter trans: translate distance.
    open func translation(by trans: CGPoint) {
        center = CGPoint(x: center.x+trans.x, y: center.y+trans.y)
    }
    
    /// Called when pinch the content view. Subclass can override and do some operation.
    /// - Parameter scale: pinch scale.
    open func pinch(by scale: CGFloat) {
        if scale != 0 {
            let scal = self.scale * scale
            if scal <= maxScale/outerScale {
                self.scale = scal
                transform = transform.scaledBy(x: scale, y: scale)
            }
        }
    }
    
    /// Called when rotate the content view. Subclass can override and do some operation.
    /// - Parameter angle: rotate angle.
    open func rotate(by angle: CGFloat) {
        transform = transform.rotated(by: angle)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginActive(resignable: Bool = true) {
        isActive = true
        layer.borderColor = UIColor(white: 1, alpha: 0.8).cgColor
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if resignable {
            perform(#selector(resignActive), with: nil, afterDelay: 2)
        }
    }
    
    @objc func resignActive() {
        isActive = false
        layer.borderColor = UIColor.clear.cgColor
    }
    
    private func updateBorderWidth() {
        layer.borderWidth = 0.5 / (outerScale * scale)
    }
    
    private func getScale(from transform: CGAffineTransform) -> (scaleX: CGFloat, scaleY: CGFloat) {
        let scaleX = sqrt(transform.a * transform.a + transform.c * transform.c)
        let scaleY = sqrt(transform.b * transform.b + transform.d * transform.d)
        return (scaleX, scaleY)
    }
    
}

/// Subclass of `ADStickerContentView`, Used to display image sticker.
public class ADImageStickerContentView: ADStickerContentView {
    
    var image: UIImage
    
    var imageView: UIImageView!
    
    public override var stickerInfo: ADImageStickerInfo {
        return ADImageStickerInfo(id: stickerID, transform: transform, center: center, normalizeCenter: normalizeCenter, image: image)
    }
    
    /// Create content view with image.
    /// - Parameter image: Sticker image.
    public init(image: UIImage) {
        self.image = image
        super.init(size: CGSize(width: image.size.width+20, height: image.size.height+20))
        
        imageView = UIImageView(image: image)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// Initial view whith info.
    /// - Parameter info: Image sticker info.
    public init(info: ADImageStickerInfo) {
        image = info.image
        super.init(info: info)
        imageView = UIImageView(image: image)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        updateImage(image)
        transform = info.transform
        center = info.center
    }
    
    public func update(info: ADImageStickerInfo) {
        updateImage(info.image)
        super.update(info: info)
    }
    
    /// Call when image changed.
    /// - Parameter img: New sticker image.
    public func updateImage(_ img: UIImage) {
        sizeDidChange(CGSize(width: img.size.width+20, height: img.size.height+20) )
        image = img
        imageView.image = img
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ADTextStickerContentView: ADImageStickerContentView {
    
    var sticker: ADTextSticker
    
    override var stickerInfo: ADTextStickerInfo {
        return ADTextStickerInfo(id: stickerID, transform: transform, center: center, normalizeCenter: normalizeCenter, image: image, sticker: sticker)
    }
    
    init(image: UIImage, sticker: ADTextSticker) {
        self.sticker = sticker
        super.init(image: image)
    }
    
    init(info: ADTextStickerInfo) {
        sticker = info.sticker
        super.init(info: info)
    }
    
    func update(info: ADTextStickerInfo) {
        super.update(info: info)
        sticker = info.sticker
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func doubleTapAction(ctx: UIViewController?) {
        let sticker = ADEditConfigure.textStickerEditVC(sticker: sticker)
        sticker.textDidEdit = { [weak self] image, sticker in
            let old = self?.stickerInfo
            self?.updateImage(image)
            self?.sticker = sticker
            self?.actionDataDidChange?(ADTextStickerInfo.self,.update(old: old, new: self?.stickerInfo))
        }
        sticker.modalPresentationStyle = .custom
        sticker.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
        ctx?.present(sticker, animated: true, completion: nil)
    }
}
