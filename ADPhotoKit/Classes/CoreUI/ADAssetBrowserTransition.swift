//
//  ADAssetBrowserTransition.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/9.
//

import Foundation
import UIKit

class ADAssetBrowserTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
    
}

protocol ADAssetBrowserInteractiveTransitionDelegate: AnyObject {
    func transitionShouldStart(_ point: CGPoint) -> Bool
    
    func transitionDidStart()
    
    func transitionDidCancel(view: UIView?)
    
    func transitionDidFinish()
}

extension ADAssetBrowserInteractiveTransitionDelegate {
    func transitionShouldStart(_ point: CGPoint) -> Bool {
        return true
    }
}

protocol ADAssetBrowserTransitionContextFrom: AnyObject {
    var contextIdentifier: String { get }
    
    func transitionInfo(convertTo: UIView) -> (UIView,CGRect)
}

protocol ADAssetBrowserTransitionContextTo: AnyObject {
    func transitionRect(identifier: String, convertTo: UIView) -> CGRect?
}

class ADAssetBrowserInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    typealias Transable = (ADAssetBrowserInteractiveTransitionDelegate & ADAssetBrowserTransitionContextFrom & UIViewController)
    
    weak var transable: Transable?
    
    var interactive: Bool = false
    
    /// private
    private weak var ctx: UIViewControllerContextTransitioning?

    private var beginPoint: CGPoint = .zero
    private var imageViewFrame: CGRect = .zero
    
    /// view
    private var bgView: UIView?
    private var imageView: UIView?
    
    init(transable: Transable) {
        super.init()
        self.transable = transable
        let dismissPan = UIPanGestureRecognizer(target: self, action: #selector(dismissPanAction(_:)))
        transable.view.addGestureRecognizer(dismissPan)
    }
    
    @objc func dismissPanAction(_ pan: UIPanGestureRecognizer) {
        guard let trans = transable else {
            return
        }
        
        let point = pan.location(in: trans.view)
        
        if pan.state == .began {
            if trans.transitionShouldStart(point) {
                interactive = true
                beginPoint = point
                trans.transitionDidStart()
                trans.navigationController?.popViewController(animated: true)
            }
        } else if pan.state == .changed {
            if interactive {
                let translation = pan.translation(in: trans.view)
                
                let result = panResult(translation: translation, point: point)
                
                imageView?.frame = result.frame
                bgView?.alpha = pow(result.scale, 2)
                
                update(result.scale)
            }
        } else if pan.state == .cancelled || pan.state == .ended {
            if interactive {
                let vel = pan.velocity(in: trans.view)
                let tran = pan.translation(in: trans.view)
                let percent: CGFloat = max(0.0, tran.y / trans.view.bounds.height)
                
                let dismiss = vel.y > 300 || (percent > 0.2 && vel.y > -300)
                
                if dismiss {
                    finish()
                    finishAnimation()
                } else {
                    cancel()
                    cancelAnimation()
                }
                beginPoint = .zero
                interactive = false
            }
        }
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        ctx = transitionContext
        beginAnimation()
    }
    
}

private extension ADAssetBrowserInteractiveTransition {
    
    func panResult(translation: CGPoint, point: CGPoint) -> (frame: CGRect, scale: CGFloat) {
        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - translation.y / UIScreen.main.bounds.height))
        
        let width = imageViewFrame.size.width * scale
        let height = imageViewFrame.size.height * scale
        
        // 计算x和y。保持手指在图片上的相对位置不变。
        let xRate = (beginPoint.x - imageViewFrame.origin.x) / imageViewFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = point.x - currentTouchDeltaX
        
        let yRate = (beginPoint.y - imageViewFrame.origin.y) / imageViewFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = point.y - currentTouchDeltaY
        
        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }
    
    func beginAnimation() {
        guard let context = ctx else {
            return
        }
        
        let containerView = context.containerView
        
        let fromVC = context.viewController(forKey: .from)
        let toVC = context.viewController(forKey: .to)
        
        containerView.addSubview(toVC!.view)
        
        bgView = UIView(frame: containerView.bounds)
        bgView?.backgroundColor = UIColor.black
        containerView.addSubview(bgView!)
                
        if let from = fromVC as? ADAssetBrowserTransitionContextFrom {
            let info = from.transitionInfo(convertTo: containerView)
            imageViewFrame = info.1
            
            imageView = info.0
            imageView?.frame = imageViewFrame
            containerView.addSubview(imageView!)
        }else{
            fatalError("fromVC must confirm `ADAssetBrowserTransitionContextFrom`")
        }
    }
    
    func finishAnimation() {
        guard let context = ctx else {
            return
        }
        
        let fromVC = context.viewController(forKey: .from)
        let toVC = context.viewController(forKey: .to)
        
        var toFrame: CGRect? = nil
        
        if let from = fromVC as? ADAssetBrowserTransitionContextFrom, let to = toVC as? ADAssetBrowserTransitionContextTo {
            toFrame = to.transitionRect(identifier: from.contextIdentifier, convertTo: context.containerView)
            UIView.animate(withDuration: 0.25) {
                if let to = toFrame {
                    self.imageView?.frame = to
                }
                self.imageView?.alpha = 0
                self.bgView?.alpha = 0
            } completion: { (_) in
                self.imageView?.removeFromSuperview()
                self.bgView?.removeFromSuperview()
                self.transable?.transitionDidFinish()
                context.completeTransition(!context.transitionWasCancelled)
            }

        }else{
            fatalError("toVC must confirm `ADAssetBrowserTransitionContextTo`")
        }
    }
    
    func cancelAnimation() {
        guard let context = ctx else {
            return
        }
        UIView.animate(withDuration: 0.25) {
            self.imageView?.frame = self.imageViewFrame
            self.bgView?.alpha = 1
        } completion: { (_) in
            self.imageView?.removeFromSuperview()
            self.bgView?.removeFromSuperview()
            self.transable?.transitionDidCancel(view: self.imageView)
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
}
