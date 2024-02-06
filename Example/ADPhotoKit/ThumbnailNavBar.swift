//
//  ThumbnailNavBar.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class ThumbnailNavBar: UIView, ADThumbnailNavBarConfigurable {
    var height: CGFloat {
        UIApplication.shared.statusBarFrame.height+60
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var leftActionBlock: (() -> Void)?
    
    var rightActionBlock: ((UIButton) -> Void)?
    
    var reloadAlbumBlock: ((ADAlbumModel) -> Void)?
    
    let titleLabel = UILabel()
    
    required init(style: ADPickerStyle, config: ADPhotoKitConfig) {
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 0, alpha: 0.9)
        
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
        if style == .normal {
            leftBtnItem.setTitle("<", for: .normal)
            leftBtnItem.setTitleColor(.white, for: .normal)
        }else{
            leftBtnItem.setTitle("Exit", for: .normal)
            leftBtnItem.setTitleColor(UIColor.systemRed, for: .normal)
        }
        leftBtnItem.addTarget(self, action: #selector(leftBtnItemAction(sender:)), for: .touchUpInside)
        addSubview(leftBtnItem)
        leftBtnItem.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(60)
        }
        
        let rightBtnItem = UIButton(type: .custom)
        rightBtnItem.contentHorizontalAlignment = .right
        rightBtnItem.setTitle("Exit", for: .normal)
        rightBtnItem.setTitleColor(UIColor.systemRed, for: .normal)
        rightBtnItem.addTarget(self, action: #selector(rightBtnItemAction(sender:)), for: .touchUpInside)
        addSubview(rightBtnItem)
        rightBtnItem.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(60)
        }
        rightBtnItem.isHidden = style == .embed
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func leftBtnItemAction(sender: UIButton) {
        leftActionBlock?()
    }
    
    @objc func rightBtnItemAction(sender: UIButton) {
        rightActionBlock?(sender)
    }
    
}
