//
//  ViewController.swift
//  ADPhotoKit
//
//  Created by zexu007@qq.com on 03/14/2021.
//  Copyright (c) 2021 zexu007@qq.com. All rights reserved.
//

import UIKit
import ADPhotoKit
import ProgressHUD

class ViewController: UIViewController {
    
    var pickerStyle: ADPickerStyle = .normal
    var albumOptions: ADAlbumSelectOptions = .default

    override func viewDidLoad() {
        super.viewDidLoad()
        let rightBtnItem = UIBarButtonItem(title: "Image Picker", style: .plain, target: self, action: #selector(presentImagePicker(_:)))
        navigationItem.rightBarButtonItem = rightBtnItem

        ADAlbumListCell.appearance().setAttributes([ADAlbumListCell.Key.titleColor:UIColor.lightGray,ADAlbumListCell.Key.cornerRadius:6])
        ADThumbnailListCell.appearance().setAttributes([ADThumbnailListCell.Key.cornerRadius:8,ADThumbnailListCell.Key.indexColor:UIColor.lightText])
        ADAddPhotoCell.appearance().setAttributes([ADAddPhotoCell.Key.cornerRadius:8,ADAddPhotoCell.Key.bgColor:UIColor.lightText])
        ADCameraCell.appearance().setAttributes([ADCameraCell.Key.cornerRadius:8, ADCameraCell.Key.bgColor:UIColor.gray])
        ADBrowserToolBarCell.appearance().setAttributes([ADBrowserToolBarCell.Key.cornerRadius:8, ADBrowserToolBarCell.Key.borderColor:UIColor.red])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func presentImagePicker(_ sender: UIButton) {
        if #available(iOS 14, *) {
            ADPhotoKitUI.imagePicker(present: self, style: pickerStyle, albumOpts: albumOptions, assetOpts: .default, params: [.maxCount(max: 9),.imageCount(min: 1, max: 8),.videoCount(min: 0, max: 1)]) { (assets, value) in
                print(assets)
            }
        } else {
            ADPhotoKitUI.imagePicker(present: self, style: pickerStyle, albumOpts: albumOptions, assetOpts: [.default], params: [.maxCount(max: 9),.imageCount(min: 1, max: 8),.videoCount(min: 0, max: 1)]) { (assets, value) in
                print(assets)
            }
        }
    }

}

extension ViewController {
    @IBAction func customLocaleValue(_ sender: UIButton) {
        ADPhotoKitConfiguration.default.locale = Locale(identifier: "en")
        ADPhotoKitConfiguration.default.customLocaleValue = [ Locale(identifier: "en"):[.cancel:"Cancel Select",.cameraRoll:"All"] ]
        ProgressHUD.showSuccess("Update Success!")
    }
    
    @IBAction func customAlbumOrder(_ sender: UIButton) {
        ADPhotoKitConfiguration.default.customAlbumOrders = [.cameraRoll,.videos,.screenshots]
        ProgressHUD.showSuccess("Update Success!")
    }
    
    @IBAction func pickerStyle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            pickerStyle = .normal
        }else{
            pickerStyle = .embed
        }
        ProgressHUD.showSuccess("Update Success!")
    }
    
    @IBAction func customAlbumOptions(_ sender: UISwitch) {
        if sender.tag == 0 {
            if sender.isOn {
                albumOptions.insert(.allowImage)
            }else{
                albumOptions.remove(.allowImage)
            }
        }
        if sender.tag == 1 {
            if sender.isOn {
                albumOptions.insert(.allowVideo)
            }else{
                albumOptions.remove(.allowVideo)
            }
        }
        if sender.tag == 2 {
            if sender.isOn {
                albumOptions.insert(.ascending)
            }else{
                albumOptions.remove(.ascending)
            }
        }
        ProgressHUD.showSuccess("Update Success!")
    }
    
}
