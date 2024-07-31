//
//  BrowserNavBar.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class BrowserNavBar: UIView, ADBrowserNavBarConfigurable {
    
    var height: CGFloat {
        return 84
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var leftActionBlock: (() -> Void)?
    
    var selectActionBlock: ((Bool)->Bool)?
    
    let titleLabel = UILabel()
    
    private var selectToken: NSKeyValueObservation?
    
    required init(dataSource: ADAssetBrowserDataSource, config: ADPhotoKitConfig) {
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        let leftBtnItem = UIButton(type: .custom)
        leftBtnItem.contentHorizontalAlignment = .left
        leftBtnItem.setTitle("<", for: .normal)
        leftBtnItem.setTitleColor(.white, for: .normal)
        leftBtnItem.addTarget(self, action: #selector(leftBtnItemAction(sender:)), for: .touchUpInside)
        addSubview(leftBtnItem)
        leftBtnItem.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(60)
        }
        
        let sw = UISwitch()
        sw.addTarget(self, action: #selector(switchAction(sender:)), for: .valueChanged)
        addSubview(sw)
        sw.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-5)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        sw.isOn = dataSource.isSelected
        selectToken = dataSource.observe(\.isSelected, options: .new, changeHandler: { (dataSource, change) in
            guard let selected = change.newValue else { return }
            sw.isOn = selected
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        selectToken?.invalidate()
    }
    
    @objc func leftBtnItemAction(sender: UIButton) {
        leftActionBlock?()
    }
    
    @objc func switchAction(sender: UISwitch) {
        _ = selectActionBlock?(!sender.isOn)
    }
    
}
