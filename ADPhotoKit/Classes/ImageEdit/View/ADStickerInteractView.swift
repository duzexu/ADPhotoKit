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
    
    public func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) -> Bool {
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
        case let .pinch(scale):
            target?.pinch(by: scale)
        case let .rotate(angle):
            target?.rotate(by: angle)
        }
        var clip: Bool = false
        switch state {
        case .began:
            target?.beginActive(resignable: false)
        case .ended, .cancelled, .failed:
            target?.beginActive()
            target = nil
            clip = true
        default:
            break
        }
        return clip
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
        addSubview(view)
        let y = UIApplication.shared.keyWindow?.convert(CGPoint(x: 0, y: screenHeight-15), to: self).y
        let offset = y == nil ? -15 : y! - frame.size.height
        view.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(offset)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(160)
            make.height.equalTo(80)
        }
        view.transform = CGAffineTransform(translationX: 0, y: 130)
        return view
    }()
        
    private weak var target: ADStickerContentView?
    
    public func clear() {
        container.subviews.forEach { $0.removeFromSuperview() }
    }
    
    public func addContent(_ view: ADStickerContentView) {
        if let scale = ADImageEditConfigurable.contentViewState?.scale {
            view.pinch(by: 1/scale)
        }
        let center = ADImageEditConfigurable.contentViewState?.center ?? CGPoint(x: bounds.width/2, y: bounds.height/2)
        view.center = center
        container.addSubview(view)
        view.beginActive()
    }
        
    func presentTrashView() {
        trashView.isHidden = false
        trashView.isConfirmed = false
        UIView.animate(withDuration: 0.2) {
            self.trashView.transform = .identity
        }
    }
    
    func dismissTrashView() {
        UIView.animate(withDuration: 0.2) {
            self.trashView.transform = CGAffineTransform(translationX: 0, y: 130)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1 / UIScreen.main.scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginActive(resignable: Bool = true) {
        isActive = true
        layer.borderColor = UIColor.white.cgColor
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
            transform = transform.scaledBy(x: scale, y: scale)
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
