//
//  ThumbnailToolBar.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class ThumbnailToolBar: UIView, ADThumbnailToolBarConfigurable {
    
    var height: CGFloat {
        return 68
    }
    
    var isOriginal: Bool = false {
        didSet {
            originalBtn.isOn = isOriginal
        }
    }
    
    var selectCount: Int = 0 {
        didSet {
            browseBtn.isEnabled = selectCount > 0
            doneBtn.isEnabled = selectCount > 0
        }
    }
    
    var browserActionBlock: (() -> Void)?
    
    var doneActionBlock: (() -> Void)?
    
    var browseBtn: UIButton!
    var originalBtn: UISwitch!
    var doneBtn: UIButton!
    
    required init(dataSource: ADAssetListDataSource, config: ADPhotoKitConfig) {
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 0, alpha: 0.9)
        
        let leftBtnItem = UIButton(type: .custom)
        leftBtnItem.contentHorizontalAlignment = .left
        leftBtnItem.setTitle("Browser", for: .normal)
        leftBtnItem.setTitleColor(UIColor.white, for: .normal)
        leftBtnItem.addTarget(self, action: #selector(previewAction), for: .touchUpInside)
        addSubview(leftBtnItem)
        leftBtnItem.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(60)
        }
        browseBtn = leftBtnItem
        
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
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(60)
        }
        doneBtn = rightBtnItem
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func previewAction() {
        browserActionBlock?()
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
