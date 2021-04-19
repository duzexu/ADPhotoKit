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
        ADAlbumListCell.appearance().setAttributes([ADAlbumListCell.Key.titleColor.rawValue:UIColor.lightGray,ADAlbumListCell.Key.cornerRadius.rawValue:6])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        if #available(iOS 14, *) {
            ADPhotoKitUI.imagePicker(present: self, style: .normal, assetOpts: .defaultiOS14, params: [.maxCount(max: 9),.imageCount(min: 1, max: 8),.videoCount(min: 0, max: 1),.videoTime(min: 10, max: nil)]) { (assets, value) in
                print(assets)
            }
        }else{
            ADPhotoKitUI.imagePicker(present: self, assetOpts: .default, params: [.maxCount(max: 9),.imageCount(min: 1, max: 8),.videoCount(min: 0, max: 1)]) { (assets, value) in
                print(assets)
            }
        }
    }
    
}

