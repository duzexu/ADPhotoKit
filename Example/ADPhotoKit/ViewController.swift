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
    
    @IBOutlet weak var tableView: UITableView!
    
    var pickerStyle: ADPickerStyle = .normal
    var albumOptions: ADAlbumSelectOptions = .default
    var assetOptions: ADAssetSelectOptions = .default
    var browserOptions: ADAssetBrowserOptions = .default
    var params: Set<ADPhotoSelectParams> = []
    
    private var dataSource: [ConfigSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let rightBtnItem = UIBarButtonItem(title: "Image Picker", style: .plain, target: self, action: #selector(presentImagePicker(_:)))
        navigationItem.rightBarButtonItem = rightBtnItem
        setupConfig()
        
        ADAlbumListCell.appearance().setAttributes([ADAlbumListCell.Key.titleColor:UIColor.lightGray,ADAlbumListCell.Key.cornerRadius:6])
        ADThumbnailListCell.appearance().setAttributes([ADThumbnailListCell.Key.cornerRadius:8,ADThumbnailListCell.Key.indexColor:UIColor.lightText])
        ADAddPhotoCell.appearance().setAttributes([ADAddPhotoCell.Key.cornerRadius:8,ADAddPhotoCell.Key.bgColor:UIColor.lightText])
        ADCameraCell.appearance().setAttributes([ADCameraCell.Key.cornerRadius:8, ADCameraCell.Key.bgColor:UIColor.gray])
        ADBrowserToolBarCell.appearance().setAttributes([ADBrowserToolBarCell.Key.cornerRadius:8, ADBrowserToolBarCell.Key.borderColor:UIColor.red])
    }
    
    func setupConfig() {
        var globalModels: [ConfigModel] = []
        
        let lang = ConfigModel(title: "Custom Language", mode: .none, action: { [weak self] (_) in
            self?.performSegue(withIdentifier: "language", sender: self!)
        })
        globalModels.append(lang)
        
        let locale = ConfigModel(title: "Custom Locale Text", mode: .none, action: { (_) in
            ADPhotoKitConfiguration.default.locale = Locale(identifier: "en")
            ADPhotoKitConfiguration.default.customLocaleValue = [ Locale(identifier: "en"):[.cancel:"Cancel Select",.cameraRoll:"All"] ]
            ProgressHUD.showSuccess("Update Success!")
        })
        globalModels.append(locale)
        
        let order = ConfigModel(title: "Custom Album Order", mode: .none, action: { (_) in
            ADPhotoKitConfiguration.default.customAlbumOrders = [.cameraRoll,.videos,.screenshots]
            ProgressHUD.showSuccess("Update Success!")
        })
        globalModels.append(order)
        
        let globalConfig = ConfigSection(title: "Global", models: globalModels)
        
        dataSource.append(globalConfig)
        
        let pickerConfig = ConfigSection(title: "Picker", models: [ConfigModel(title: "PickerStyle", mode: .segment(["Normal","Embed"], 0), action: { [weak self] (index) in
            if let idx = index as? Int {
                if idx == 0 {
                    self?.pickerStyle = .normal
                }else{
                    self?.pickerStyle = .embed
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })])
        dataSource.append(pickerConfig)
        
        var albumModels: [ConfigModel] = []
        
        let allowImg = ConfigModel(title: "AllowImage", mode: .switch(true), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.albumOptions.insert(.allowImage)
                }else{
                    self?.albumOptions.remove(.allowImage)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        albumModels.append(allowImg)
        
        let allowVideo = ConfigModel(title: "AllowVideo", mode: .switch(true), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.albumOptions.insert(.allowVideo)
                }else{
                    self?.albumOptions.remove(.allowVideo)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        albumModels.append(allowVideo)
        
        let ascending = ConfigModel(title: "Ascending", mode: .switch(false), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.albumOptions.insert(.ascending)
                }else{
                    self?.albumOptions.remove(.ascending)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        albumModels.append(ascending)
        
        let albumConfig = ConfigSection(title: "AlbumOptions", models: albumModels)
        dataSource.append(albumConfig)
        
        var assetModels: [ConfigModel] = []
        
        let mixSelect = ConfigModel(title: "MixSelect", mode: .switch(true)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.mixSelect)
                }else{
                    self?.assetOptions.remove(.mixSelect)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(mixSelect)
        
        let selectAsGif = ConfigModel(title: "SelectAsGif", mode: .switch(false)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.selectAsGif)
                }else{
                    self?.assetOptions.remove(.selectAsGif)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(selectAsGif)
        
        let selectAsLivePhoto = ConfigModel(title: "SelectAsLivePhoto", mode: .switch(false)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.selectAsLivePhoto)
                }else{
                    self?.assetOptions.remove(.selectAsLivePhoto)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(selectAsLivePhoto)
        
        let slideSelect = ConfigModel(title: "SlideSelect", mode: .switch(true)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.slideSelect)
                }else{
                    self?.assetOptions.remove(.slideSelect)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(slideSelect)
        
        let autoScroll = ConfigModel(title: "AutoScroll", mode: .switch(true)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.autoScroll)
                }else{
                    self?.assetOptions.remove(.autoScroll)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(autoScroll)
        
        let allowTakePhotoAsset = ConfigModel(title: "AllowTakePhotoAsset", mode: .switch(true)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.allowTakePhotoAsset)
                }else{
                    self?.assetOptions.remove(.allowTakePhotoAsset)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(allowTakePhotoAsset)
        
        let allowTakeVideoAsset = ConfigModel(title: "AllowTakeVideoAsset", mode: .switch(false)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.allowTakeVideoAsset)
                }else{
                    self?.assetOptions.remove(.allowTakeVideoAsset)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(allowTakeVideoAsset)
        
        let captureOnTakeAsset = ConfigModel(title: "CaptureOnTakeAsset", mode: .switch(false)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.captureOnTakeAsset)
                }else{
                    self?.assetOptions.remove(.captureOnTakeAsset)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(captureOnTakeAsset)
        
        if #available(iOS 14, *) {
            let allowAddAsset = ConfigModel(title: "AllowAddAsset", mode: .switch(false)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.assetOptions.insert(.allowAddAsset)
                    }else{
                        self?.assetOptions.remove(.allowAddAsset)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(allowAddAsset)
            
            let allowAuthTips = ConfigModel(title: "AllowAuthTips", mode: .switch(false)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.assetOptions.insert(.allowAuthTips)
                    }else{
                        self?.assetOptions.remove(.allowAuthTips)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(allowAuthTips)
        }
        
        let allowBrowser = ConfigModel(title: "AllowBrowser", mode: .switch(true)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.allowBrowser)
                }else{
                    self?.assetOptions.remove(.allowBrowser)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(allowBrowser)
        
        let thumbnailToolBar = ConfigModel(title: "ThumbnailToolBar", mode: .switch(true)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.thumbnailToolBar)
                }else{
                    self?.assetOptions.remove(.thumbnailToolBar)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(thumbnailToolBar)
        
        let selectOriginal = ConfigModel(title: "SelectOriginal", mode: .switch(true)) { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.assetOptions.insert(.selectOriginal)
                }else{
                    self?.assetOptions.remove(.selectOriginal)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        assetModels.append(selectOriginal)
        
        let assetConfig = ConfigSection(title: "AssetOptions", models: assetModels)
        dataSource.append(assetConfig)
        
        var browserModels: [ConfigModel] = []
        
        let selectOri = ConfigModel(title: "SelectOriginal", mode: .switch(true), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.browserOptions.insert(.selectOriginal)
                }else{
                    self?.browserOptions.remove(.selectOriginal)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        browserModels.append(selectOri)
        
        let selectBrowser = ConfigModel(title: "SelectBrowser", mode: .switch(true), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.browserOptions.insert(.selectBrowser)
                }else{
                    self?.browserOptions.remove(.selectBrowser)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        browserModels.append(selectBrowser)
        
        let selectIndex = ConfigModel(title: "SelectIndex", mode: .switch(true), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.browserOptions.insert(.selectIndex)
                }else{
                    self?.browserOptions.remove(.selectIndex)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        browserModels.append(selectIndex)
        
        let fetchImage = ConfigModel(title: "FetchImage", mode: .switch(true), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.browserOptions.insert(.fetchImage)
                }else{
                    self?.browserOptions.remove(.fetchImage)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        browserModels.append(fetchImage)
        
        let browserConfig = ConfigSection(title: "BrowserConfig", models: browserModels)
        dataSource.append(browserConfig)
        
        var paramsModels: [ConfigModel] = []
        
        let maxCount = ConfigModel(title: "MaxCount", mode: .stepper(0)) { [weak self] (value) in
            if let count = value as? Int {
                self?.params.insert(.maxCount(max: count))
            }
        }
        paramsModels.append(maxCount)
        
        let imageCount = ConfigModel(title: "ImageCount", mode: .range(0, 0)) { [weak self] (value) in
            if let trup = value as? (Int,Int) {
                self?.params.insert(.imageCount(min: trup.0, max: trup.1))
            }
        }
        paramsModels.append(imageCount)
        
        let paramsConfig = ConfigSection(title: "ParamsConfig", models: paramsModels)
        dataSource.append(paramsConfig)
    }

    @IBAction func presentImagePicker(_ sender: UIButton) {
        if #available(iOS 14, *) {
            ADPhotoKitUI.imagePicker(present: self, style: pickerStyle, albumOpts: albumOptions, assetOpts: assetOptions, browserOpts: browserOptions, params: params) { (assets, value) in
                print(assets)
            }
        } else {
            ADPhotoKitUI.imagePicker(present: self, style: pickerStyle, albumOpts: albumOptions, assetOpts: assetOptions, browserOpts: browserOptions, params: params) { (assets, value) in
                print(assets)
            }
        }
    }

}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].models.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigCell", for: indexPath) as! ConfigCell
        cell.config(model: dataSource[indexPath.section].models[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.section].models[indexPath.row]
        switch model.mode {
        case .none:
            model.action?(nil)
        default:
            break
        }
    }
}

