//
//  ADPhotoNavController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import UIKit

class ADPhotoNavController: UINavigationController {
    
    override var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
        
}
