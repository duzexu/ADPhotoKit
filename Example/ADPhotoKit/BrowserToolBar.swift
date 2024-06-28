//
//  BrowserToolBar.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class BrowserToolBar: UIView, ADBrowserToolBarConfigurable {
    
    var height: CGFloat {
        return 64
    }
    
    var modifyHeight: CGFloat {
        return 64
    }
    
    var isOriginal: Bool = false {
        didSet {
            originalBtn.isOn = isOriginal
        }
    }
    
    var editActionBlock: (() -> Void)?
    
    var doneActionBlock: (() -> Void)?
    
    var originalBtn: UISwitch!
    
    required init(dataSource: ADAssetBrowserDataSource, config: ADPhotoKitConfig) {
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 1, alpha: 0.6)
        
        let leftBtnItem = UIButton(type: .custom)
        leftBtnItem.contentHorizontalAlignment = .left
        leftBtnItem.setTitle("Edit", for: .normal)
        leftBtnItem.setTitleColor(UIColor.white, for: .normal)
        leftBtnItem.addTarget(self, action: #selector(previewAction), for: .touchUpInside)
        addSubview(leftBtnItem)
        leftBtnItem.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(60)
        }
        
        let sw = UISwitch()
        sw.isOn = isOriginal
        sw.addTarget(self, action: #selector(originalAction), for: .valueChanged)
        addSubview(sw)
        sw.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        originalBtn = sw
        
        let rightBtnItem = UIButton(type: .custom)
        rightBtnItem.contentHorizontalAlignment = .right
        rightBtnItem.setTitle("Done", for: .normal)
        rightBtnItem.setTitleColor(UIColor.white, for: .normal)
        rightBtnItem.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        addSubview(rightBtnItem)
        rightBtnItem.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(60)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func previewAction() {
        editActionBlock?()
    }
    
    @objc
    func originalAction() {
        isOriginal = !isOriginal
    }
    
    @objc
    func doneAction() {
        doneActionBlock?()
    }
    

}
