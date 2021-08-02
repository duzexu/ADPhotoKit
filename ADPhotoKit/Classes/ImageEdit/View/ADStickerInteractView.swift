//
//  ADImageStickerView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit

public class ADStickerInteractView: UIView, ToolInteractable {
    
    public var zIndex: Int {
        return InteractZIndex.Top.rawValue
    }
    
    public var interactPolicy: InteractPolicy {
        return .simult
    }
    
    public var isInteracting: Bool = false
    
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
    
    public func interact(with type: InteractType, scale: CGFloat, state: UIGestureRecognizer.State) {
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
    
    typealias ViewState = (center: CGPoint, scale: CGFloat)
    
    var state: ViewState?
    
    func addContent(_ view: ADStickerContentView) {
        if let scale = state?.scale {
            view.pinch(by: 1/scale)
        }
        let center = state?.center ?? CGPoint(x: bounds.width/2, y: bounds.height/2)
        view.center = center
        container.addSubview(view)
        view.beginActive()
    }
    
}

class ADStickerContentView: UIView {
    
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

class ADImageStickerContentView: ADStickerContentView {
    
    init(image: UIImage) {
        super.init(frame: CGRect(origin: .zero, size: image.size).insetBy(dx: -20, dy: -20))
        
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
    
}
