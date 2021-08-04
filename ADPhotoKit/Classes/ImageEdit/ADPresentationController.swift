//
//  ADPresentationController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/8/3.
//

import UIKit

protocol ADAppearanceDelegate: AnyObject {
    func presentationTransitionWillBegin()
    func presentationTransitionDidEnd()
    func presentationDismissalWillBegin()
    func presentationDismissalDidEnd()
}

class ADPresentationController: UIPresentationController {

    weak var appearance: ADAppearanceDelegate?

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {
        appearance?.presentationTransitionWillBegin()
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        appearance?.presentationTransitionDidEnd()
    }

    override func dismissalTransitionWillBegin() {
        appearance?.presentationDismissalWillBegin()
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        appearance?.presentationDismissalDidEnd()
    }
    
}
