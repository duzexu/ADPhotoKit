//
//  ADBrowserToolBarView.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/11.
//

import UIKit

class ADBrowserToolBarView: UIView, ADBrowserToolBarConfigurable {

    var height: CGFloat {
        var hi: CGFloat = 55+tabBarOffset
        if options.contains(.selectBrowser) {
            hi += 100
        }
        return hi
    }
    
    public var isSelectedOriginal: Bool = false {
        didSet {
            originalBtn.isSelected = isSelectedOriginal
        }
    }
    
    public var selectCount: Int = 0 {
        didSet {
            if selectCount > 0 {
                doneBtn.setTitle(ADLocale.LocaleKey.done.localeTextValue + "(\(selectCount))", for: .normal)
                doneBtn.isEnabled = true
                editBtn.isEnabled = true
            }else{
                doneBtn.setTitle(ADLocale.LocaleKey.done.localeTextValue, for: .normal)
                doneBtn.isEnabled = false
                editBtn.isEnabled = false
            }
        }
    }
    
    var selectBrowserEnable: Bool {
        if options.contains(.selectBrowser) && selectCount > 0 {
            return true
        } else {
            return false
        }
    }

    let options: ADAssetBrowserOptions
    
    /// ui
    var editBtn: UIButton!
    var originalBtn: UIButton!
    var doneBtn: UIButton!
    
    var btnsView: UIView!
    var selectView: ADBrowserToolBarSelectView!

    init(options: ADAssetBrowserOptions, selects: [ADAssetBrowsable], current: ADAssetBrowsable) {
        self.options = options
        self.selectCount = selects.count
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: 0x232323, alpha: 0.3)
        
        selectView = ADBrowserToolBarSelectView(selects: selects, current: current)

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ADBrowserToolBarView {
    
    func setupUI() {
        let effect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        addSubview(effect)
        effect.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        btnsView = UIView()
        addSubview(btnsView)
        btnsView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-tabBarOffset)
            make.height.equalTo(55)
        }
        
        editBtn = createBtn(ADLocale.LocaleKey.edit.localeTextValue, #selector(editAction))
        btnsView.addSubview(editBtn)
        editBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(34)
            make.centerY.equalToSuperview()
        }
        
        originalBtn = createBtn(ADLocale.LocaleKey.originalPhoto.localeTextValue, #selector(originalAction))
        originalBtn.isHidden = !options.contains(.selectOriginal)
        originalBtn.isSelected = isSelectedOriginal
        originalBtn.setImage(Bundle.uiBundle?.image(name: "btn_original_circle"), for: .normal)
        originalBtn.setImage(Bundle.uiBundle?.image(name: "btn_original_selected"), for: .selected)
        originalBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        originalBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        btnsView.addSubview(originalBtn)
        originalBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(34)
        }
        
        doneBtn = createBtn(ADLocale.LocaleKey.done.localeTextValue, #selector(doneAction))
        doneBtn.setBackgroundImage(UIImage.image(color: UIColor(hex: 0x50A938)!), for: .normal)
        doneBtn.setBackgroundImage(UIImage.image(color: UIColor(hex: 0x323232)!), for: .disabled)
        doneBtn.layer.cornerRadius = 5
        doneBtn.layer.masksToBounds = true
        doneBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btnsView.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(34)
            make.centerY.equalToSuperview()
        }
        
        addSubview(selectView)
        selectView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-tabBarOffset-55)
            make.height.equalTo(100)
        }
    }
    
    func createBtn(_ title: String, _ action: Selector) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor(hex: 0xA8A8A8), for: .disabled)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
}

private extension ADBrowserToolBarView {
    
    @objc
    func editAction() {
        
    }
    
    @objc
    func originalAction() {
        isSelectedOriginal = !isSelectedOriginal
    }
    
    @objc
    func doneAction() {
        
    }
    
}
