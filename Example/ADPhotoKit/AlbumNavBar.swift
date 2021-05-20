//
//  AlbumNavbar.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class AlbumNavBar: UIView, ADAlbumListNavBarConfigurable {
    
    var height: CGFloat {
        return UIApplication.shared.statusBarFrame.height+34
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
        
    var rightActionBlock: ((UIButton) -> Void)?
    
    let titleLabel = UILabel()
    
    init() {
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
        
        let rightBtnItem = UIButton(type: .system)
        rightBtnItem.contentHorizontalAlignment = .right
        rightBtnItem.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        rightBtnItem.setTitleColor(.systemRed, for: .normal)
        rightBtnItem.setTitle("Exit", for: .normal)
        rightBtnItem.addTarget(self, action: #selector(rightBtnItemAction(sender:)), for: .touchUpInside)
        addSubview(rightBtnItem)
        rightBtnItem.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(60)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func rightBtnItemAction(sender: UIButton) {
        rightActionBlock?(sender)
    }
}
