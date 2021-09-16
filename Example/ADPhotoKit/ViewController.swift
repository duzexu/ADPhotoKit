//
//  ViewController.swift
//  ADPhotoKit
//
//  Created by zexu007@qq.com on 03/14/2021.
//  Copyright (c) 2021 zexu007@qq.com. All rights reserved.
//

import UIKit
@_exported import ADPhotoKit
import Photos
import ProgressHUD

struct NetImage: ADAssetBrowsable {
    
    var browseAsset: ADAsset {
        return .image(.network(URL(string: url)!))
    }
    
    var imageEditInfo: ADImageEditInfo?
    
    let url: String
}

struct NetVideo: ADAssetBrowsable {
    var browseAsset: ADAsset {
        return .video(.network(URL(string: url)!))
    }
    
    var imageEditInfo: ADImageEditInfo?
    
    let url: String
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pickerStyle: ADPickerStyle = .normal
    var albumOptions: ADAlbumSelectOptions = .default
    var assetOptions: ADAssetSelectOptions = .default
    var browserOptions: ADAssetBrowserOptions = .default
    var params: Set<ADPhotoSelectParams> = []
    
    var selected: [ADPhotoKitUI.Asset] = []
    
    private var dataSource: [ConfigSection] = []
    private var keepSelect: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        ADPhotoKitConfiguration.default.customImageEditToolsBlock = { image in
            return [ImageFilterTool(image: image)]
        }
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        let browser = UIButton(type: .system)
        browser.setTitle("Browser", for: .normal)
        browser.addTarget(self, action: #selector(presentAssetBrowser(_:)), for: .touchUpInside)
        stack.addArrangedSubview(browser)
        let picker = UIButton(type: .system)
        picker.setTitle("Picker", for: .normal)
        picker.addTarget(self, action: #selector(presentImagePicker(_:)), for: .touchUpInside)
        stack.addArrangedSubview(picker)
        let selected = UIButton(type: .system)
        selected.setTitle("ShowSel", for: .normal)
        selected.addTarget(self, action: #selector(presentSelectAsset(_:)), for: .touchUpInside)
        stack.addArrangedSubview(selected)
        let control = UIView()
        let label = UILabel()
        label.text = "KeepSelect"
        label.font = UIFont.systemFont(ofSize: 10)
        control.addSubview(label)
        let sw = UISwitch()
        control.addSubview(sw)
        sw.addTarget(self, action: #selector(switchAction(sender:)), for: .touchUpInside)
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalTo(sw.snp.top)
        }
        sw.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
        }
        stack.addArrangedSubview(control)
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
                self?.params.update(with: .maxCount(max: count))
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        paramsModels.append(maxCount)
        
        let imageCount = ConfigModel(title: "ImageCount", mode: .range(0, 0)) { [weak self] (value) in
            if let trup = value as? (Int,Int) {
                self?.params.update(with: .imageCount(min: trup.0, max: trup.1))
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        paramsModels.append(imageCount)
        
        let videoCount = ConfigModel(title: "VideoCount", mode: .range(0, 0)) { [weak self] (value) in
            if let trup = value as? (Int,Int) {
                self?.params.update(with: .videoCount(min: trup.0, max: trup.1))
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        paramsModels.append(videoCount)
        
        let videoTime = ConfigModel(title: "VideoTime", mode: .range(0, 0)) { [weak self] (value) in
            if let trup = value as? (Int,Int) {
                self?.params.update(with: .videoTime(min: trup.0, max: trup.1))
                ProgressHUD.showSuccess("Update Success!")
            }
        }
        paramsModels.append(videoTime)
        
        let recordTime = ConfigModel(title: "RecordTime", mode: .range(0, 0)) { [weak self] (value) in
            if let trup = value as? (Int,Int) {
                self?.params.update(with: .recordTime(min: trup.0, max: trup.1))
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
        
        var customModels: [ConfigModel] = []
        
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
                    ADPhotoKitConfiguration.default.customThumbnailNavBarBlock = { style in
                        return ThumbnailNavBar(style: style)
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
                    ADPhotoKitConfiguration.default.customThumbnailToolBarBlock = { config in
                        return ThumbnailToolBar()
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
                    ADPhotoKitConfiguration.default.customBrowserNavBarBlock = { dataSource in
                        return BrowserNavBar(dataSource: dataSource)
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
                    ADPhotoKitConfiguration.default.customBrowserToolBarBlock = { dataSource in
                        return BrowserToolBar(dataSource: dataSource)
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
    }

    @IBAction func presentImagePicker(_ sender: UIButton) {
        let s: [ADSelectAssetModel] = keepSelect ? selected.map {
            let model = ADSelectAssetModel(asset: $0.asset)
            model.imageEditInfo = $0.result?.imageEditInfo
            return model
        } : []
        ADPhotoKitUI.imagePicker(present: self,
                                 style: pickerStyle,
                                 assets: s,
                                 albumOpts: albumOptions,
                                 assetOpts: assetOptions,
                                 browserOpts: browserOptions,
                                 params: params,
                                 selected: { [weak self] (assets, value) in
            self?.selected = assets
            print(assets)
        },
                                 canceled: {
            print("cancel")
        })
    }
    
    @IBAction func presentAssetBrowser(_ sender: UIButton) {
        ADPhotoKitUI.assetBrowser(present: self, assets: [NetImage(url: "https://cdn.pixabay.com/photo/2020/10/14/18/35/sign-post-5655110_1280.png"),NetImage(url: "https://pic.netbian.com/uploads/allimg/190518/174718-1558172838db13.jpg"),NetImage(url: "http://5b0988e595225.cdn.sohucs.com/images/20190420/1d1070881fd540db817b2a3bdd967f37.gif"),NetVideo(url: "https://freevod.nf.migu.cn/mORsHmtum1AysKe3Ry%2FUb5rA1WelPRwa%2BS7ylo4qQCjcD5a2YuwiIC7rpFwwdGcgkgMxZVi%2FVZ%2Fnxf6NkQZ75HC0xnJ5rlB8UwiH8cZUuvErkVufDlxxLUBF%2FIgUEwjiq%2F%2FV%2FoxBQBVMUzAZaWTvOE5dxUFh4V3Oa489Ec%2BPw0IhEGuR64SuKk3MOszdFg0Q/600575Y9FGZ040325.mp4?msisdn=2a257d4c-1ee0-4ad8-8081-b1650c26390a&spid=600906&sid=50816168212200&timestamp=20201026155427&encrypt=70fe12c7473e6d68075e9478df40f207&k=dc156224f8d0835e&t=1603706067279&ec=2&flag=+&FN=%E5%B0%86%E6%95%85%E4%BA%8B%E5%86%99%E6%88%90%E6%88%91%E4%BB%AC")], options: browserOptions, selected: { (assets) in
            print(assets)
        }, canceled: {
            print("cancel")
        })
    }
    
    @IBAction func presentSelectAsset(_ sender: UIButton) {
        let assets: [PHAsset] = selected.map {
            let asset = $0.asset
            asset.imageEditInfo = $0.result?.imageEditInfo
            return asset
        }
        ADPhotoKitUI.assetBrowser(present: self, assets: assets, options: browserOptions) { (assets) in
            print(assets)
        }
    }

    @IBAction func switchAction(sender: UISwitch) {
        keepSelect = sender.isOn
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

