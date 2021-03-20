//
//  ViewController.swift
//  ADPhotoKit
//
//  Created by zexu007@qq.com on 03/14/2021.
//  Copyright (c) 2021 zexu007@qq.com. All rights reserved.
//

import UIKit
import ADPhotoKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ADPhotoKitConfiguration.default.locale = Locale(identifier: "zh-Hans")
        ADPhotoManager.allPhotoAlbumList() { (list) in
            print(list)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        ADPhotoKitUI.imagePicker(present: self) { (assets, value) in
            print(assets)
        }
    }
    
}

