//
//  ConfigurationViewController.swift
//  ADPhotoKit_Example
//
//  Created by du on 2024/1/31.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit
import Photos
import ProgressHUD

class DemosViewController: UIViewController {
    
    static let browsers: [ADAssetBrowsable] = [NetImage(url: "https://cdn.pixabay.com/photo/2020/10/14/18/35/sign-post-5655110_1280.png"),NetImage(url: "https://pic.netbian.com/uploads/allimg/190518/174718-1558172838db13.jpg"),NetImage(url: "http://5b0988e595225.cdn.sohucs.com/images/20190420/1d1070881fd540db817b2a3bdd967f37.gif"),NetVideo(url: "https://freevod.nf.migu.cn/mORsHmtum1AysKe3Ry%2FUb5rA1WelPRwa%2BS7ylo4qQCjcD5a2YuwiIC7rpFwwdGcgkgMxZVi%2FVZ%2Fnxf6NkQZ75HC0xnJ5rlB8UwiH8cZUuvErkVufDlxxLUBF%2FIgUEwjiq%2F%2FV%2FoxBQBVMUzAZaWTvOE5dxUFh4V3Oa489Ec%2BPw0IhEGuR64SuKk3MOszdFg0Q/600575Y9FGZ040325.mp4?msisdn=2a257d4c-1ee0-4ad8-8081-b1650c26390a&spid=600906&sid=50816168212200&timestamp=20201026155427&encrypt=70fe12c7473e6d68075e9478df40f207&k=dc156224f8d0835e&t=1603706067279&ec=2&flag=+&FN=%E5%B0%86%E6%95%85%E4%BA%8B%E5%86%99%E6%88%90%E6%88%91%E4%BB%AC")]
    
    private var configs: Configs!
    
    private var dataSource: [ConfigSection] = []
    private var selected: [ADAssetBrowsable] = []
    private var keepSelect: Bool = false
    
    init(conifgs: Configs) {
        super.init(nibName: nil, bundle: nil)
        self.configs = conifgs
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Demos"
        let tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ConfigCell", bundle: nil), forCellReuseIdentifier: "ConfigCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupConfig()
    }
    
    func setupConfig() {
        var normalModels: [ConfigModel] = []
        
        let picker = ConfigModel(title: "PickerImage", mode: .none, action: { [weak self] (_) in
            self?.presentImagePicker()
        })
        normalModels.append(picker)
        
        let browser = ConfigModel(title: "BrowserImage", mode: .none, action: { [weak self] (_) in
            self?.presentAssetBrowser()
        })
        normalModels.append(browser)
        
        let selected = ConfigModel(title: "ShowSelected", mode: .none, action: { [weak self] (_) in
            self?.presentSelectAsset()
        })
        normalModels.append(selected)
        
        let keep = ConfigModel(title: "KeepSelected", mode: .switch(false), action: { [weak self] (value) in
            if let isOn = value as? Bool {
                self?.keepSelect = isOn
            }
        })
        normalModels.append(keep)
        
        let normalConfig = ConfigSection(title: "Normal Demos", models: normalModels)
        dataSource.append(normalConfig)
        
        var swiftuiModels: [ConfigModel] = []
        
        #if canImport(SwiftUI)
        let swiftui = ConfigModel(title: "SwiftUI Demo", mode: .none, action: { [weak self] (_) in
            if #available(iOS 13.0, *) {
                let vc = SwiftUIViewController(configs: self!.configs)
                self?.navigationController?.pushViewController(vc, animated: true)
            } else {
                ProgressHUD.showError("No Support under iOS 13")
            }
        })
        swiftuiModels.append(swiftui)
        #endif
        
        let swiftuiConfig = ConfigSection(title: "SwiftUI Demos", models: swiftuiModels)
        dataSource.append(swiftuiConfig)
    }
    
    @IBAction func presentImagePicker() {
        let s: [ADSelectAssetModel] = keepSelect ? selected.compactMap({ asset in
            if let asset = asset as? PHAsset {
                let model = ADSelectAssetModel(asset: asset)
                model.imageEditInfo = asset.imageEditInfo
                return model
            }
            return nil
        }) : []
        ADPhotoKitUI.imagePicker(present: self,
                                 style: configs.pickerStyle,
                                 modelsSel: s,
                                 albumOpts: configs.albumOptions,
                                 assetOpts: configs.assetOptions,
                                 browserOpts: configs.browserOptions,
                                 params: configs.params,
                                 selected: { [weak self] (assets, value) in
            self?.selected = assets.map({ asset,result,err in
                asset.imageEditInfo = result?.imageEditInfo
                return asset
            })
            print(assets)
        },
                                 canceled: {
            print("cancel")
        })
    }
    
    @IBAction func presentAssetBrowser() {
        let s: [ADAssetBrowsable] = keepSelect ? selected : []
        ADPhotoKitUI.assetBrowser(present: self,
                                  assets: DemosViewController.browsers,
                                  selects: s,
                                  options: configs.browserOptions,
                                  selected: { (assets) in
            print(assets)
        }, canceled: {
            print("cancel")
        })
    }
    
    @IBAction func presentSelectAsset() {
        let assets: [PHAsset] = selected.compactMap({ asset in
            if let asset = asset as? PHAsset {
                return asset
            }
            return nil
        })
        ADPhotoKitUI.assetBrowser(present: self, assets: assets, options: configs.browserOptions) { (assets) in
            print(assets)
        }
    }
    
}

extension DemosViewController: UITableViewDelegate,UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
