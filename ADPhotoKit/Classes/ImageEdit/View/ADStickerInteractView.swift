//
//  ADImageStickerView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit

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
    
    public func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) -> TimeInterval? {
        switch type {
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
            presentTrashView()
            target?.beginActive(resignable: false)
            if let tg = target {
                tg.center = container.convert(tg.center, to: self)
                insertSubview(tg, belowSubview: trashView)
            }
        case .ended, .cancelled, .failed:
            if trashView.isConfirmed && !trashView.isHidden {
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
    
    public static var share = ADStickerInteractView()
    
    weak var ctx: UIViewController?
    
    private var clipView: UIView!
    private var container: UIView!
    
    private lazy var trashView: TrashView = {
        let view = TrashView(frame: CGRect(x: 0, y: 0, width: 160, height: 80))
        view.isHidden = true
        addSubview(view)
        return view
    }()
    
    private var trashIdentifyTrans: CGAffineTransform = .identity
        
    private weak var target: ADStickerContentView?
    private weak var activeTarget: ADStickerContentView?
    
    init() {
        super.init(frame: .zero)
        clipView = UIView()
        clipView.clipsToBounds = true
        addSubview(clipView)
        container = UIView()
        container.clipsToBounds = false
        clipView.addSubview(container)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func clear() {
        container.subviews.forEach { $0.removeFromSuperview() }
    }
    
    public func addContent(_ view: ADStickerContentView) {
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
        view.beginActive()
    }
    
    public func appendContent(_ view: ADStickerContentView) {
        container.addSubview(view)
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
                tipsLabel.text = isConfirmed ? "松手即可删除" : ADLocale.LocaleKey.textStickerRemoveTips.localeTextValue
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
            tipsLabel.text = ADLocale.LocaleKey.textStickerRemoveTips.localeTextValue
            addSubview(tipsLabel)
            tipsLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalTo(34)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}

public class ADStickerContentView: UIView {
    
    var isActive: Bool = false
    
    let maxScale: CGFloat = 10
    
    fileprivate var outerScale: CGFloat = 1 {
        didSet {
            updateBorderWidth()
        }
    }
    
    public var scale: CGFloat = 1 {
        didSet {
            updateBorderWidth()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.clear.cgColor
    }
    
    open func doubleTapAction(ctx: UIViewController?) {
        
    }
    
    public func sizeDidChange(_ size: CGSize) {
        let oldCenter = center
        let oldTrans = transform
        transform = .identity
        frame.size = size
        transform = oldTrans
        center = oldCenter
    }
    
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
    
    func translation(by trans: CGPoint) {
        center = CGPoint(x: center.x+trans.x, y: center.y+trans.y)
    }
    
    func pinch(by scale: CGFloat) {
        if scale != 0 {
            let scal = self.scale * scale
            if scal <= maxScale/outerScale {
                self.scale = scal
                transform = transform.scaledBy(x: scale, y: scale)
            }
        }
    }
    
    func rotate(by angle: CGFloat) {
        transform = transform.rotated(by: angle)
    }
    
    private func updateBorderWidth() {
        layer.borderWidth = 0.5 / (outerScale * scale)
    }
    
}

public class ADImageStickerContentView: ADStickerContentView {
    
    var image: UIImage
    
    var imageView: UIImageView!
    
    public init(image: UIImage) {
        self.image = image
        super.init(frame: CGRect(origin: .zero, size: image.size).insetBy(dx: -10, dy: -10))
        
        imageView = UIImageView(image: image)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    public func updateImage(_ img: UIImage) {
        sizeDidChange(CGSize(width: img.size.width+20, height: img.size.height+20) )
        image = img
        imageView.image = img
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ADTextStickerContentView: ADImageStickerContentView {
    
    var sticker: ADTextSticker
    
    init(image: UIImage, sticker: ADTextSticker) {
        self.sticker = sticker
        super.init(image: image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func doubleTapAction(ctx: UIViewController?) {
        let sticker = ADImageEditConfigurable.textStickerEditVC(sticker: sticker)
        sticker.textDidEdit = { [weak self] image, sticker in
            self?.updateImage(image)
            self?.sticker = sticker
        }
        sticker.modalPresentationStyle = .custom
        sticker.transitioningDelegate = ctx as? UIViewControllerTransitioningDelegate
        ctx?.present(sticker, animated: true, completion: nil)
    }
}
