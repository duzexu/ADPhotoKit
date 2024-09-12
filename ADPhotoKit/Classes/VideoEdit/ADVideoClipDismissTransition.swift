//
//  ADVideoClipDismissTransition.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/12.
//

import Foundation
import UIKit

protocol ADVideoClipDismissTransitionContextFrom: AnyObject {
    func transitionInfo(convertTo: UIView) -> (UIImage,CGRect)
}

protocol ADVideoClipDismissTransitionContextTo: AnyObject {
    func transitionRect(convertTo: UIView) -> CGRect?
    
    func transitionDidFinish()
}

class ADVideoClipDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    typealias Transable = (ADVideoClipDismissTransitionContextFrom & UIViewController)
    
    weak var transable: Transable?
    
    init(transable: Transable) {
        super.init()
        self.transable = transable
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
                
        if let from = fromVC as? ADImageClipDismissTransitionContextFrom {
            let info = from.transitionInfo(convertTo: containerView)
            let imageView = UIImageView(frame: info.1)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = info.0
            containerView.addSubview(imageView)
            
            if let to = toVC as? ADImageClipDismissTransitionContextTo {
                let toFrame = to.transitionRect(convertTo: containerView)
                UIView.animate(withDuration: 0.3) {
                    if let to = toFrame {
                        imageView.frame = to
                    }
                } completion: { _ in
                    to.transitionDidFinish()
                    imageView.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }else{
                fatalError("toVC must confirm `ADImageClipDismissTransitionContextTo`")
            }

        }else{
            fatalError("fromVC must confirm `ADImageClipDismissTransitionContextFrom`")
        }
    }
    
}
