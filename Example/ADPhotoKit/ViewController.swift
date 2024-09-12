//
//  ViewController.swift
//  ADPhotoKit
//
//  Created by zexu007@qq.com on 03/14/2021.
//  Copyright (c) 2021 zexu007@qq.com. All rights reserved.
//

import UIKit
import ADPhotoKit
import Photos
import ProgressHUD

struct NetImage: ADAssetBrowsable {
    
    var browseAsset: ADAsset {
        return .image(.network(URL(string: url)!))
    }
    #if Module_ImageEdit
    var imageEditInfo: ADImageEditInfo?
    #endif
    
    let url: String
}

struct NetVideo: ADAssetBrowsable {
    var browseAsset: ADAsset {
        return .video(.network(URL(string: url)!))
    }
    #if Module_ImageEdit
    var imageEditInfo: ADImageEditInfo?
    #endif
    
    let url: String
}

class Configs {
    var pickerStyle: ADPickerStyle = .normal
    var albumOptions: ADAlbumSelectOptions = .default
    var assetOptions: ADAssetSelectOptions = .default
    var browserOptions: ADAssetBrowserOptions = .default
    var params: Set<ADPhotoSelectParams> = []
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let configs = Configs()
    
    private var dataSource: [ConfigSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Configurations"
        #if Module_ImageEdit || Module_VideoEdit
        // image sticker
        var sections: [ADImageStickerDataSource.StickerSection] = []
        do {
            var items: [ADImageStickerDataSource.StickerItem] = []
            for i in 0..<6 {
                items.append(ADImageStickerDataSource.StickerItem(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "like_\(i)", ofType: "jpeg")!)!))
            }
            let section = ADImageStickerDataSource.StickerSection(icon: UIImage(named: "icons_outlined_like")!, name: "添加的单个表情", items: items, itemNameOn: false)
            sections.append(section)
        }
        do {
            var items: [ADImageStickerDataSource.StickerItem] = []
            for i in 0..<24 {
                items.append(ADImageStickerDataSource.StickerItem(image: UIImage(named: "pig_\(i)")!, name: "pig_\(i)"))
            }
            let section = ADImageStickerDataSource.StickerSection(icon: UIImage(named: "pig_21")!, name: "小小胖滚家族", items: items)
            sections.append(section)
        }
        do {
            var items: [ADImageStickerDataSource.StickerItem] = []
            for i in 0..<10 {
                items.append(ADImageStickerDataSource.StickerItem(image: UIImage(named: "dog_\(i)")!, name: "dog_\(i)"))
            }
            let section = ADImageStickerDataSource.StickerSection(icon: UIImage(named: "dog_3")!, name: "柴犬的日常", items: items)
            sections.append(section)
        }
        do {
            var items: [ADImageStickerDataSource.StickerItem] = []
            for i in 0..<16 {
                items.append(ADImageStickerDataSource.StickerItem(image: UIImage(named: "agg_\(i)")!, name: "agg_\(i)"))
            }
            let section = ADImageStickerDataSource.StickerSection(icon: UIImage(named: "agg_cover")!, name: "抹茶蛋蛋2", items: items)
            sections.append(section)
        }
        ADPhotoKitConfiguration.default.imageStickerDataSource = ADImageStickerDataSource(sections: sections)
        #endif
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        let config = UIButton(type: .system)
        config.setTitle("Demos", for: .normal)
        config.addTarget(self, action: #selector(pushDemos), for: .touchUpInside)
        stack.addArrangedSubview(config)
        let rightBtnItem = UIBarButtonItem(customView: stack)
        navigationItem.rightBarButtonItem = rightBtnItem
        
        setupConfig()
    }
    
    func setupConfig() {
        var globalModels: [ConfigModel] = []
        
        let lang = ConfigModel(title: "Custom Language", mode: .none, action: { [weak self] (_) in
            self?.performSegue(withIdentifier: "language", sender: self!)
        })
        globalModels.append(lang)
        
        let locale = ConfigModel(title: "Custom Locale Text", mode: .switch(false), action: { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.locale = Locale(identifier: "en")
                    ADPhotoKitConfiguration.default.customLocaleValue = [ Locale(identifier: "en"):[.cancel:"Cancel Select",.cameraRoll:"All"] ]
                }else{
                    ADPhotoKitConfiguration.default.customLocaleValue = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }            
        })
        globalModels.append(locale)
        
        let order = ConfigModel(title: "Custom Album Order", mode: .switch(false), action: { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customAlbumOrders = [.cameraRoll,.videos,.screenshots]
                }else{
                    ADPhotoKitConfiguration.default.customAlbumOrders = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        globalModels.append(order)
        
        let globalConfig = ConfigSection(title: "Global", models: globalModels)
        
        dataSource.append(globalConfig)
        
        let pickerConfig = ConfigSection(title: "Picker", models: [ConfigModel(title: "PickerStyle", mode: .segment(["Normal","Embed"], 0), action: { [weak self] (index) in
            if let idx = index as? Int {
                if idx == 0 {
                    self?.configs.pickerStyle = .normal
                }else{
                    self?.configs.pickerStyle = .embed
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })])
        dataSource.append(pickerConfig)
        
        var albumModels: [ConfigModel] = []
        
        let allowImg = ConfigModel(title: "AllowImage", mode: .switch(true), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.configs.albumOptions.insert(.allowImage)
                }else{
                    self?.configs.albumOptions.remove(.allowImage)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        albumModels.append(allowImg)
        
        let allowVideo = ConfigModel(title: "AllowVideo", mode: .switch(true), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.configs.albumOptions.insert(.allowVideo)
                }else{
                    self?.configs.albumOptions.remove(.allowVideo)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        albumModels.append(allowVideo)
        
        let ascending = ConfigModel(title: "Ascending", mode: .switch(false), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                if isOn {
                    self?.configs.albumOptions.insert(.ascending)
                }else{
                    self?.configs.albumOptions.remove(.ascending)
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        })
        albumModels.append(ascending)
        
        let albumConfig = ConfigSection(title: "AlbumOptions", models: albumModels)
        dataSource.append(albumConfig)
        
        do {
            var assetModels: [ConfigModel] = []
            
            let mixSelect = ConfigModel(title: "MixSelect", mode: .switch(true)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.mixSelect)
                    }else{
                        self?.configs.assetOptions.remove(.mixSelect)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(mixSelect)
            
            let selectAsGif = ConfigModel(title: "SelectAsGif", mode: .switch(false)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.selectAsGif)
                    }else{
                        self?.configs.assetOptions.remove(.selectAsGif)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(selectAsGif)
            
            let selectAsLivePhoto = ConfigModel(title: "SelectAsLivePhoto", mode: .switch(false)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.selectAsLivePhoto)
                    }else{
                        self?.configs.assetOptions.remove(.selectAsLivePhoto)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(selectAsLivePhoto)
            
            let slideSelect = ConfigModel(title: "SlideSelect", mode: .switch(true)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.slideSelect)
                    }else{
                        self?.configs.assetOptions.remove(.slideSelect)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(slideSelect)
            
            let autoScroll = ConfigModel(title: "AutoScroll", mode: .switch(true)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.autoScroll)
                    }else{
                        self?.configs.assetOptions.remove(.autoScroll)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(autoScroll)
            
            let allowTakePhotoAsset = ConfigModel(title: "AllowTakePhotoAsset", mode: .switch(true)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.allowTakePhotoAsset)
                    }else{
                        self?.configs.assetOptions.remove(.allowTakePhotoAsset)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(allowTakePhotoAsset)
            
            let allowTakeVideoAsset = ConfigModel(title: "AllowTakeVideoAsset", mode: .switch(false)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.allowTakeVideoAsset)
                    }else{
                        self?.configs.assetOptions.remove(.allowTakeVideoAsset)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(allowTakeVideoAsset)
            
            let captureOnTakeAsset = ConfigModel(title: "CaptureOnTakeAsset", mode: .switch(false)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.captureOnTakeAsset)
                    }else{
                        self?.configs.assetOptions.remove(.captureOnTakeAsset)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(captureOnTakeAsset)
            
            if #available(iOS 14, *) {
                let allowAddAsset = ConfigModel(title: "AllowAddAsset", mode: .switch(false)) { [weak self] (value) in
                    if let isOn = value as? Bool {
                        if isOn {
                            self?.configs.assetOptions.insert(.allowAddAsset)
                        }else{
                            self?.configs.assetOptions.remove(.allowAddAsset)
                        }
                        ProgressHUD.showSuccess("Update Success!")
                    }
                }
                assetModels.append(allowAddAsset)
                
                let allowAuthTips = ConfigModel(title: "AllowAuthTips", mode: .switch(false)) { [weak self] (value) in
                    if let isOn = value as? Bool {
                        if isOn {
                            self?.configs.assetOptions.insert(.allowAuthTips)
                        }else{
                            self?.configs.assetOptions.remove(.allowAuthTips)
                        }
                        ProgressHUD.showSuccess("Update Success!")
                    }
                }
                assetModels.append(allowAuthTips)
            }
            
            let allowBrowser = ConfigModel(title: "AllowBrowser", mode: .switch(true)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.allowBrowser)
                    }else{
                        self?.configs.assetOptions.remove(.allowBrowser)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(allowBrowser)
            
            let thumbnailToolBar = ConfigModel(title: "ThumbnailToolBar", mode: .switch(true)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.thumbnailToolBar)
                    }else{
                        self?.configs.assetOptions.remove(.thumbnailToolBar)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(thumbnailToolBar)
            
            let selectIndex = ConfigModel(title: "SelectIndex", mode: .switch(true)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.selectIndex)
                    }else{
                        self?.configs.assetOptions.remove(.selectIndex)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(selectIndex)
            
            let selectBtnWhenSingleSelect = ConfigModel(title: "SelectBtnWhenSingleSelect", mode: .switch(false)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.selectBtnWhenSingleSelect)
                    }else{
                        self?.configs.assetOptions.remove(.selectBtnWhenSingleSelect)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(selectBtnWhenSingleSelect)
            
            let selectCountOnDoneBtn = ConfigModel(title: "SelectCountOnDoneBtn", mode: .switch(true)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.selectCountOnDoneBtn)
                    }else{
                        self?.configs.assetOptions.remove(.selectCountOnDoneBtn)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(selectCountOnDoneBtn)
            
            let totalOriginalSize = ConfigModel(title: "TotalOriginalSize", mode: .switch(true)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.totalOriginalSize)
                    }else{
                        self?.configs.assetOptions.remove(.totalOriginalSize)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(totalOriginalSize)
            
            let systemCapture = ConfigModel(title: "SystemCapture", mode: .switch(false)) { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.assetOptions.insert(.systemCapture)
                    }else{
                        self?.configs.assetOptions.remove(.systemCapture)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
            assetModels.append(systemCapture)
            
            let assetConfig = ConfigSection(title: "AssetOptions", models: assetModels)
            dataSource.append(assetConfig)
        }
        
        do {
            var browserModels: [ConfigModel] = []
            
            let selectOri = ConfigModel(title: "SelectOriginal", mode: .switch(true), action: { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.browserOptions.insert(.selectOriginal)
                    }else{
                        self?.configs.browserOptions.remove(.selectOriginal)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            })
            browserModels.append(selectOri)
            
            let selectThumbnil = ConfigModel(title: "selectThumbnil", mode: .switch(true), action: { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.browserOptions.insert(.selectThumbnil)
                    }else{
                        self?.configs.browserOptions.remove(.selectThumbnil)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            })
            browserModels.append(selectThumbnil)
            
            let selectIndex = ConfigModel(title: "SelectIndex", mode: .switch(true), action: { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.browserOptions.insert(.selectIndex)
                    }else{
                        self?.configs.browserOptions.remove(.selectIndex)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            })
            browserModels.append(selectIndex)
            
            let fetchImage = ConfigModel(title: "FetchImage", mode: .switch(true), action: { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.browserOptions.insert(.fetchImage)
                    }else{
                        self?.configs.browserOptions.remove(.fetchImage)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            })
            browserModels.append(fetchImage)
            
            let selectBtnWhenSingleSelect = ConfigModel(title: "SelectBtnWhenSingleSelect", mode: .switch(false), action: { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.browserOptions.insert(.selectBtnWhenSingleSelect)
                    }else{
                        self?.configs.browserOptions.remove(.selectBtnWhenSingleSelect)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            })
            browserModels.append(selectBtnWhenSingleSelect)
            
            let selectCountOnDoneBtn = ConfigModel(title: "SelectCountOnDoneBtn", mode: .switch(true), action: { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.browserOptions.insert(.selectCountOnDoneBtn)
                    }else{
                        self?.configs.browserOptions.remove(.selectCountOnDoneBtn)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            })
            browserModels.append(selectCountOnDoneBtn)
            
            let totalOriginalSize = ConfigModel(title: "TotalOriginalSize", mode: .switch(true), action: { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.browserOptions.insert(.totalOriginalSize)
                    }else{
                        self?.configs.browserOptions.remove(.totalOriginalSize)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            })
            browserModels.append(totalOriginalSize)
            
            let saveAfterEdit = ConfigModel(title: "SaveAfterEdit", mode: .switch(true), action: { [weak self] (value) in
                if let isOn = value as? Bool {
                    if isOn {
                        self?.configs.browserOptions.insert(.saveAfterEdit)
                    }else{
                        self?.configs.browserOptions.remove(.saveAfterEdit)
                    }
                    ProgressHUD.showSuccess("Update Success!")
                }
            })
            browserModels.append(saveAfterEdit)
            
            let browserConfig = ConfigSection(title: "BrowserConfig", models: browserModels)
            dataSource.append(browserConfig)
        }
        
        var paramsModels: [ConfigModel] = []
        
        let maxCount = ConfigModel(title: "MaxCount", mode: .stepper(0)) { [weak self] (value) in
            if let count = value as? UInt {
                self?.configs.params.update(with: .maxCount(max: count))
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        paramsModels.append(maxCount)
        
        let imageCount = ConfigModel(title: "ImageCount", mode: .range(0, 0)) { [weak self] (value) in
            if let trup = value as? (UInt,UInt) {
                self?.configs.params.update(with: .imageCount(min: trup.0, max: trup.1))
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        paramsModels.append(imageCount)
        
        let videoCount = ConfigModel(title: "VideoCount", mode: .range(0, 0)) { [weak self] (value) in
            if let trup = value as? (UInt,UInt) {
                self?.configs.params.update(with: .videoCount(min: trup.0, max: trup.1))
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        paramsModels.append(videoCount)
        
        let videoSize = ConfigModel(title: "VideoSize", mode: .range(0, 0)) { [weak self] (value) in
            if let trup = value as? (UInt,UInt) {
                self?.configs.params.update(with: .videoSize(min: CGFloat(trup.0), max: CGFloat(trup.1)))
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        paramsModels.append(videoSize)
        
        let videoTime = ConfigModel(title: "VideoTime", mode: .range(0, 0)) { [weak self] (value) in
            if let trup = value as? (UInt,UInt) {
                self?.configs.params.update(with: .videoTime(min: trup.0, max: trup.1))
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        paramsModels.append(videoTime)
        
        let recordTime = ConfigModel(title: "RecordTime", mode: .range(0, 0)) { [weak self] (value) in
            if let trup = value as? (UInt,UInt) {
                self?.configs.params.update(with: .recordTime(min: trup.0, max: trup.1))
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        paramsModels.append(recordTime)
        
        let paramsConfig = ConfigSection(title: "ParamsConfig", models: paramsModels)
        dataSource.append(paramsConfig)
        
        var uiModels: [ConfigModel] = []
        
        let statusBar = ConfigModel(title: "StatusBar", mode: .segment(["Light","Dark"], 0)) { (index) in
            if let idx = index as? Int {
                if idx == 0 {
                    ADPhotoKitConfiguration.default.statusBarStyle = .lightContent
                }else{
                    ADPhotoKitConfiguration.default.statusBarStyle = .default
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        uiModels.append(statusBar)
        
        let thumbnailColumnCount = ConfigModel(title: "Thumbnail ColumnCount", mode: .stepper(4)) { (value) in
            if let count = value as? Int {
                ADPhotoKitConfiguration.default.thumbnailLayout.columnCount = count
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        uiModels.append(thumbnailColumnCount)
        
        let thumbnailItemSpace = ConfigModel(title: "Thumbnail ItemSpace", mode: .stepper(2)) { (value) in
            if let count = value as? Int {
                ADPhotoKitConfiguration.default.thumbnailLayout.itemSpacing = CGFloat(count)
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        uiModels.append(thumbnailItemSpace)
        
        let thumbnailLineSpace = ConfigModel(title: "Thumbnail LineSpace", mode: .stepper(2)) { (value) in
            if let count = value as? Int {
                ADPhotoKitConfiguration.default.thumbnailLayout.lineSpacing = CGFloat(count)
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        uiModels.append(thumbnailLineSpace)
        
        let browserItemSpace = ConfigModel(title: "Browser ItemSpace", mode: .stepper(40)) { (value) in
            if let count = value as? Int {
                ADPhotoKitConfiguration.default.browseItemSpacing = CGFloat(count)
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        uiModels.append(browserItemSpace)
        
        let albumListCell = ConfigModel(title: "AlbumListCell", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADAlbumListCell.appearance().setAttributes([ADAlbumListCell.Key.titleColor:UIColor.white,ADAlbumListCell.Key.cornerRadius:6])
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
        }
        uiModels.append(albumListCell)
        
        let thumbnailListCell = ConfigModel(title: "ThumbnailListCell", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADThumbnailListCell.appearance().setAttributes([ADThumbnailListCell.Key.cornerRadius:8,ADThumbnailListCell.Key.indexColor:UIColor.lightText])
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
        }
        uiModels.append(thumbnailListCell)
        
        let addPhotoCell = ConfigModel(title: "AddPhotoCell", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADAddPhotoCell.appearance().setAttributes([ADAddPhotoCell.Key.cornerRadius:8,ADAddPhotoCell.Key.bgColor:UIColor.lightText])
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
        }
        uiModels.append(addPhotoCell)
        
        let cameraCell = ConfigModel(title: "CameraCell", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADCameraCell.appearance().setAttributes([ADCameraCell.Key.cornerRadius:8, ADCameraCell.Key.bgColor:UIColor.gray])
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
        }
        uiModels.append(cameraCell)
        
        let browserToolBarCell = ConfigModel(title: "BrowserToolBar", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADBrowserToolBarCell.appearance().setAttributes([ADBrowserToolBarCell.Key.cornerRadius:8, ADBrowserToolBarCell.Key.borderColor:UIColor.red])
                    ProgressHUD.showSuccess("Update Success!")
                }
            }
        }
        uiModels.append(browserToolBarCell)
        
        let uiConfig = ConfigSection(title: "UIConfig", models: uiModels)
        dataSource.append(uiConfig)
        
        var captureModels: [ConfigModel] = []
        
        let cameraPositionCell = ConfigModel(title: "CameraPosition", mode: .segment(["back","front"], 0)) { (index) in
            if let idx = index as? Int {
                if idx == 0 {
                    ADPhotoKitConfiguration.default.captureConfig.cameraPosition = .back
                }else{
                    ADPhotoKitConfiguration.default.captureConfig.cameraPosition = .front
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        captureModels.append(cameraPositionCell)
        
        let flashSwitchCell = ConfigModel(title: "FlashSwitch", mode: .switch(true)) { (value) in
            if let isOn = value as? Bool {
                ADPhotoKitConfiguration.default.captureConfig.flashSwitch = isOn
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        captureModels.append(flashSwitchCell)
        
        let cameraSwitchCell = ConfigModel(title: "CameraSwitch", mode: .switch(true)) { (value) in
            if let isOn = value as? Bool {
                ADPhotoKitConfiguration.default.captureConfig.cameraSwitch = isOn
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        captureModels.append(cameraSwitchCell)
        
        let videoMirroredCell = ConfigModel(title: "VideoMirrored", mode: .switch(true)) { (value) in
            if let isOn = value as? Bool {
                ADPhotoKitConfiguration.default.captureConfig.videoMirrored = isOn
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        captureModels.append(videoMirroredCell)
        
        let sessionPresetCell = ConfigModel(title: "SessionPreset", mode: .segment(["1280*720","1920*1080","3840*2160"], 0)) { (index) in
            if let idx = index as? Int {
                if idx == 0 {
                    ADPhotoKitConfiguration.default.captureConfig.sessionPreset = .hd1280x720
                }else if idx == 1 {
                    ADPhotoKitConfiguration.default.captureConfig.sessionPreset = .hd1920x1080
                }else if idx == 2 {
                    ADPhotoKitConfiguration.default.captureConfig.sessionPreset = .hd4K3840x2160
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        captureModels.append(sessionPresetCell)
        
        let focusModeCell = ConfigModel(title: "FocusMode", mode: .segment(["continuousAuto","auto"], 0)) { (index) in
            if let idx = index as? Int {
                if idx == 0 {
                    ADPhotoKitConfiguration.default.captureConfig.focusMode = .continuousAutoFocus
                }else if idx == 1 {
                    ADPhotoKitConfiguration.default.captureConfig.focusMode = .autoFocus
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        captureModels.append(focusModeCell)
        
        let exposureModeCell = ConfigModel(title: "exposureMode", mode: .segment(["continuousAuto","auto"], 0)) { (index) in
            if let idx = index as? Int {
                if idx == 0 {
                    ADPhotoKitConfiguration.default.captureConfig.exposureMode = .continuousAutoExposure
                }else if idx == 1 {
                    ADPhotoKitConfiguration.default.captureConfig.exposureMode = .autoExpose
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        captureModels.append(exposureModeCell)
        
        let captureConfig = ConfigSection(title: "CaptureConfig", models: captureModels)
        dataSource.append(captureConfig)
        
        var customModels: [ConfigModel] = []
        
        let alert = ConfigModel(title: "Custom Alert", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customAlert = CustomAlertViewController.self
                }else{
                    ADPhotoKitConfiguration.default.customAlert = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(alert)
        
        let progressHud = ConfigModel(title: "Hud", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customProgressHUDBlock = {
                        return CustomProgressHUD()
                    }
                }else{
                    ADPhotoKitConfiguration.default.customProgressHUDBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(progressHud)
        
        let progress = ConfigModel(title: "Progress", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customProgressBlock = {
                        return Progress()
                    }
                }else{
                    ADPhotoKitConfiguration.default.customProgressBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(progress)
        
        let albumVC = ConfigModel(title: "Album Controller", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customAlbumListControllerBlock = { vc in
                        vc.tableView.backgroundColor = UIColor.darkGray
                        vc.tableView.rowHeight = 80
                    }
                }else{
                    ADPhotoKitConfiguration.default.customAlbumListControllerBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(albumVC)
        
        let albumNav = ConfigModel(title: "Album Navbar", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customAlbumListNavBarBlock = {
                        return AlbumNavBar()
                    }
                }else{
                    ADPhotoKitConfiguration.default.customAlbumListNavBarBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(albumNav)
        
        let albumCell = ConfigModel(title: "Album Cell", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customAlbumListCellRegistor = {
                        tb in
                        tb.register(UINib(nibName: "AlbumCell", bundle: nil), forCellReuseIdentifier: "AlbumCell")
                    }
                    ADPhotoKitConfiguration.default.customAlbumListCellBlock = { tb,index in
                        return tb.dequeueReusableCell(withIdentifier: "AlbumCell", for: index) as! AlbumCell
                    }
                }else{
                    ADPhotoKitConfiguration.default.customAlbumListCellRegistor = nil
                    ADPhotoKitConfiguration.default.customAlbumListCellBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(albumCell)
        
        let thumbnailVC = ConfigModel(title: "Thumbnail Controller", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customThumbnailControllerBlock = { vc in
                        vc.collectionView.backgroundColor = UIColor.darkGray
                    }
                }else{
                    ADPhotoKitConfiguration.default.customThumbnailControllerBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(thumbnailVC)
        
        let thumbnailNav = ConfigModel(title: "Thumbnail Navbar", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customThumbnailNavBarBlock = { style, config in
                        return ThumbnailNavBar(style: style, config: config)
                    }
                }else{
                    ADPhotoKitConfiguration.default.customThumbnailNavBarBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(thumbnailNav)
        
        let thumbnailTool = ConfigModel(title: "Thumbnail Toolbar", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customThumbnailToolBarBlock = { dataSource,config in
                        return ThumbnailToolBar(dataSource: dataSource, config: config)
                    }
                }else{
                    ADPhotoKitConfiguration.default.customThumbnailToolBarBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(thumbnailTool)
        
        let thumbnailCell = ConfigModel(title: "Thumbnail Cell", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customThumbnailCellRegistor = {
                        cl in
                        cl.register(UINib(nibName: "ThumbnailCell", bundle: nil), forCellWithReuseIdentifier: "ThumbnailCell")
                    }
                    ADPhotoKitConfiguration.default.customThumbnailCellBlock = { cl,index in
                        return cl.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: index) as! ThumbnailCell
                    }
                }else{
                    ADPhotoKitConfiguration.default.customThumbnailCellRegistor = nil
                    ADPhotoKitConfiguration.default.customThumbnailCellBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(thumbnailCell)
        
        let browserVC = ConfigModel(title: "Browser Controller", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customBrowserControllerBlock = { vc in
                        vc.collectionView.backgroundColor = UIColor.darkGray
                    }
                }else{
                    ADPhotoKitConfiguration.default.customBrowserControllerBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(browserVC)
        
        let browserNav = ConfigModel(title: "Browser Navbar", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customBrowserNavBarBlock = { dataSource,config in
                        return BrowserNavBar(dataSource: dataSource, config: config)
                    }
                }else{
                    ADPhotoKitConfiguration.default.customBrowserNavBarBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(browserNav)
        
        let browserTool = ConfigModel(title: "Browser Toolbar", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customBrowserToolBarBlock = { dataSource,config in
                        return BrowserToolBar(dataSource: dataSource, config: config)
                    }
                }else{
                    ADPhotoKitConfiguration.default.customBrowserToolBarBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(browserTool)
        
        let browserCell = ConfigModel(title: "Browser Cell", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customBrowserCellRegistor = {
                        cl in
                        cl.register(UINib(nibName: "ImageBrowserCell", bundle: nil), forCellWithReuseIdentifier: "ImageBrowserCell")
                        cl.register(UINib(nibName: "VideoBrowserCell", bundle: nil), forCellWithReuseIdentifier: "VideoBrowserCell")
                    }
                    ADPhotoKitConfiguration.default.customBrowserCellBlock = { cl,index,asset in
                        switch asset {
                        case .image(_):
                            return cl.dequeueReusableCell(withReuseIdentifier: "ImageBrowserCell", for: index) as! ImageBrowserCell
                        case .video(_):
                            return cl.dequeueReusableCell(withReuseIdentifier: "VideoBrowserCell", for: index) as! VideoBrowserCell
                        }
                    }
                }else{
                    ADPhotoKitConfiguration.default.customBrowserCellRegistor = nil
                    ADPhotoKitConfiguration.default.customBrowserCellBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        customModels.append(browserCell)
        
        let customConfig = ConfigSection(title: "CustomUIConfig", models: customModels)
        dataSource.append(customConfig)
        
        var imageEditModels: [ConfigModel] = []
      
#if Module_ImageEdit
        let systenTools = ConfigModel(title: "System Tools", mode: .switch(true)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.systemImageEditTools = .all
                }else{
                    ADPhotoKitConfiguration.default.systemImageEditTools = [.clip, .textStkr]
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        imageEditModels.append(systenTools)
        
        let filter = ConfigModel(title: "Image Filter", mode: .switch(false)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.customImageEditToolsBlock = { image in
                        return [ImageFilterTool(image: image)]
                    }
                }else{
                    ADPhotoKitConfiguration.default.customImageEditToolsBlock = nil
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        imageEditModels.append(filter)
        
        let drawColors = ConfigModel(title: "Draw Colors", mode: .switch(true)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.lineDrawColors = [.systemBlue, .systemRed, .systemPink]
                }else{
                    ADPhotoKitConfiguration.default.lineDrawColors = [.white, .black]
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        imageEditModels.append(drawColors)
        
        let lineWidth = ConfigModel(title: "Line Width", mode: .stepper(5)) { (value) in
            if let count = value as? Int {
                ADPhotoKitConfiguration.default.lineDrawWidth = CGFloat(count)
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        imageEditModels.append(lineWidth)
        
        let mosaicWidth = ConfigModel(title: "Mosaic Width", mode: .stepper(5)) { (value) in
            if let count = value as? Int {
                ADPhotoKitConfiguration.default.mosaicDrawWidth = CGFloat(count)
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        imageEditModels.append(mosaicWidth)
#endif
        
#if Module_ImageEdit || Module_VideoEdit
        let textColors = ConfigModel(title: "Text Colors", mode: .switch(true)) { (value) in
            if let isOn = value as? Bool {
                if isOn {
                    ADPhotoKitConfiguration.default.textStickerColors = [(.white,.black,.gray),(.black,.white,.gray)]
                }else{
                    ADPhotoKitConfiguration.default.textStickerColors = [(.systemBlue,.black,.gray),(.systemGray,.white,.gray)]
                }
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        imageEditModels.append(textColors)
#endif
        
        let imageEditConfig = ConfigSection(title: "ImageEditConfig", models: imageEditModels)
        dataSource.append(imageEditConfig)
    }
    
    @IBAction func pushDemos() {
        let config = DemosViewController(conifgs: configs)
        navigationController?.pushViewController(config, animated: true)
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

