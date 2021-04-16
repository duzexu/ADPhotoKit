//
//  ADBaseNavBarView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/14.
//

import UIKit

class ADBaseNavBarView: UIView, ADNavBarConfigurable {
    
    typealias ButtonItem = (normal: UIImage?, select: UIImage?)

    var height: CGFloat {
        return statusBarHeight + 44
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var leftActionBlock: ((UIButton)->Void)?
    var rightActionBlock: ((UIButton)->Void)?
    
    var leftBtnItem: UIButton!
    var rightBtnItem: UIButton!
    var titleLabel: UILabel!

    init(leftItem: ButtonItem? = (Bundle.uiBundle?.image(name: "navBack"),nil), rightItem: ButtonItem? = nil) {
        super.init(frame: .zero)
        setupUI(leftItem: leftItem, rightItem: rightItem)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ADBaseNavBarView {
    func setupUI(leftItem: ButtonItem?, rightItem: ButtonItem?) {
        backgroundColor = UIColor(hex: 0xA0A0A0, alpha: 0.65)
        
        let effect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        addSubview(effect)
        effect.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        leftBtnItem = UIButton(type: .custom)
        leftBtnItem.contentMode = .left
        leftBtnItem.addTarget(self, action: #selector(leftBtnItemAction(sender:)), for: .touchUpInside)
        addSubview(leftBtnItem)
        leftBtnItem.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 44))
        }
        
        if let left = leftItem {
            leftBtnItem.setImage(left.normal, for: .normal)
            leftBtnItem.setImage(left.select, for: .selected)
        }
        
        rightBtnItem = UIButton(type: .custom)
        rightBtnItem.contentMode = .right
        rightBtnItem.addTarget(self, action: #selector(rightBtnItemAction(sender:)), for: .touchUpInside)
        addSubview(rightBtnItem)
        rightBtnItem.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 44))
        }
        
        if let right = rightItem {
            rightBtnItem.setImage(right.normal, for: .normal)
            rightBtnItem.setImage(right.select, for: .selected)
        }
    }
}

extension ADBaseNavBarView {
    @objc func leftBtnItemAction(sender: UIButton) {
        leftActionBlock?(sender)
    }
    
    @objc func rightBtnItemAction(sender: UIButton) {
        rightActionBlock?(sender)
    }
}