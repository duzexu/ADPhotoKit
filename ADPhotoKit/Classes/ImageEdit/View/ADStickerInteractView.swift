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
    
    public func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) {
        switch type {
        case let .pan(_, trans):
            target?.translation(by: CGPoint(x: trans.x/scale, y: trans.y/scale))
        case let .pinch(scale):
            target?.pinch(by: scale)
        case let .rotate(angle):
            target?.rotate(by: angle)
        }
        switch state {
        case .ended, .cancelled, .failed:
            target = nil
        default:
            break
        }
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
    
    private weak var target: ADStickerContentView?
    
    func addContent(_ view: ADStickerContentView) {
        if let scale = ADImageEditConfigurable.contentViewState?.scale {
            view.pinch(by: 1/scale)
        }
        let center = ADImageEditConfigurable.contentViewState?.center ?? CGPoint(x: bounds.width/2, y: bounds.height/2)
        view.center = center
        container.addSubview(view)
        view.beginActive()
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
    
    func beginActive() {
        isActive = true
        layer.borderColor = UIColor.white.cgColor
        superview?.bringSubviewToFront(self)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(resignActive), with: nil, afterDelay: 2)
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
