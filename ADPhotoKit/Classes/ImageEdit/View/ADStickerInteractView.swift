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
    
    public var policy: ADInteractPolicy {
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
        if gesture.isKind(of: UITapGestureRecognizer.self) {
            if let t = target {
                if t.isActive {
                    t.resignActive()
                }else{
                    t.beginActive()
                }
                target = nil
                return true
            }
        }else{
            return target != nil
        }
        return false
    }
    
    public func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) {
        switch type {
        case let .pan(loc, trans):
            target?.translation(by: CGPoint(x: trans.x/scale, y: trans.y/scale))
            if state == .began {
                presentTrashView()
            }else if state == .changed {
                if trashView.frame.contains(loc) {
                    trashView.isConfirmed = true
                }else{
                    if trashView.isConfirmed {
                        trashView.isHidden = true
                    }
                }
            }else{
                if trashView.isConfirmed && !trashView.isHidden {
                    target?.removeFromSuperview()
                }
                dismissTrashView()
            }
        case let .pinch(scale,point):
            if let tg = target {
                if state == .began {
                    let center = convert(point, to: tg)
                    tg.anchorPoint = CGPoint(x: center.x/tg.frame.width, y: (tg.frame.height-center.y)/tg.frame.height)
                }
            }
            target?.pinch(by: scale)
        case let .rotate(angle,point):
            if let tg = target {
                if state == .began {
                    let center = convert(point, to: tg)
                    tg.anchorPoint = CGPoint(x: center.x/tg.frame.width, y: (tg.frame.height-center.y)/tg.frame.height)
                }
            }
            target?.rotate(by: angle)
        }
        switch state {
        case .began:
            target?.beginActive(resignable: false)
        case .ended, .cancelled, .failed:
            target?.beginActive()
            target = nil
        default:
            break
        }
    }
    
    public func willBeginRenderImage() {
        container.subviews.forEach { $0.isHidden = false }
    }
    
    public func didEndRenderImage() {
        updateClipingScreenInfo()
    }
    
    public static var share = ADStickerInteractView()
    
    private lazy var container: UIView = {
        let view = UIView()
        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()
    
    private lazy var trashView: TrashView = {
        let view = TrashView()
        view.isHidden = true
        addSubview(view)
        view.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(160)
            make.height.equalTo(80)
        }
        layoutIfNeeded()
        return view
    }()
    
    private var trashIdentifyTrans: CGAffineTransform = .identity
        
    private weak var target: ADStickerContentView?
    
    public func clear() {
        container.subviews.forEach { $0.removeFromSuperview() }
    }
    
    public func addContent(_ view: ADStickerContentView) {
        if let info = clipingScreenInfo {
            view.pinch(by: 1/info.scale)
            view.center = CGPoint(x: info.screen.midX, y: info.screen.midY)
        }else{
            view.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        }
        container.addSubview(view)
        view.beginActive()
    }
        
    func presentTrashView() {
        trashView.isHidden = false
        trashView.isConfirmed = false
        trashView.transform = trashIdentifyTrans.translatedBy(x: 0, y: 130)
        UIView.animate(withDuration: 0.2) {
            self.trashView.transform = self.trashIdentifyTrans
        }
    }
    
    func dismissTrashView() {
        UIView.animate(withDuration: 0.2) {
            self.trashView.transform = self.trashIdentifyTrans.translatedBy(x: 0, y: 130)
        } completion: { _ in
            self.trashView.isHidden = true
        }
    }
    
    func updateClipingScreenInfo() {
        if let info = clipingScreenInfo {
            let y = info.screen.maxY - (40 + 15)/info.scale
            trashView.center = CGPoint(x: info.screen.midX, y: y)
            trashIdentifyTrans = CGAffineTransform(scaleX: 1/info.scale, y: 1/info.scale)
            for view in container.subviews {
                let content = view as! ADStickerContentView
                content.outerScale = info.scale
                if info.clip.intersects(content.frame) || info.clip.contains(content.frame) {
                    content.isHidden = false
                }else{
                    content.isHidden = true
                }
            }
        }else{
            trashView.center = CGPoint(x: bounds.width/2, y: bounds.height - 56)
            trashIdentifyTrans = .identity
            for content in container.subviews {
                (content as! ADStickerContentView).outerScale = 1
                (content as! ADStickerContentView).isHidden = false
            }
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
            
            imageView = UIImageView(image: Bundle.image(name: "ashbin", module: .imageEdit), highlightedImage: Bundle.image(name: "ashbin_open", module: .imageEdit))
            addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(15)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 25, height: 25))
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
            layer.borderWidth = 0.5 / outerScale
        }
    }
    
    fileprivate var internalScale: CGFloat = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginActive(resignable: Bool = true) {
        isActive = true
        layer.borderColor = UIColor(white: 1, alpha: 0.8).cgColor
        superview?.bringSubviewToFront(self)
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
            let scal = internalScale * scale
            if scal <= maxScale {
                internalScale = scal
                transform = transform.scaledBy(x: scale, y: scale)
            }
        }
    }
    
    func rotate(by angle: CGFloat) {
        transform = transform.rotated(by: angle)
    }
    
}

public class ADImageStickerContentView: ADStickerContentView {
    
    public init(image: UIImage) {
        super.init(frame: CGRect(origin: .zero, size: image.size).insetBy(dx: -10, dy: -10))
        
        let imageView = UIImageView(image: image)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ADTextStickerContentView: ADStickerContentView {
    
    init(text: String) {
        super.init(frame: .zero)
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
