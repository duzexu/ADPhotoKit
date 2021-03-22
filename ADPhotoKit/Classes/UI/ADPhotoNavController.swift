//
//  ADPhotoNavController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import UIKit

class ADPhotoNavController: UINavigationController {
    
    var internalModel: ADPhotoKitInternal!
    
    convenience init(rootViewController: UIViewController, model: ADPhotoKitInternal) {
        self.init(rootViewController: rootViewController)
        self.internalModel = model
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}
