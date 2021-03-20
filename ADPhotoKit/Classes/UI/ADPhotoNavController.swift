//
//  ADPhotoNavController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import UIKit

class ADPhotoNavController: UINavigationController {
    
    let internalModel: ADPhotoKitInternal
    
    init(rootViewController: UIViewController, model: ADPhotoKitInternal) {
        self.internalModel = model
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}
