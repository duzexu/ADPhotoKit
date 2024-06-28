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
        if let ds = dataSource, ds.options.contains(.selectThumbnil) {
            hi += 100
        }
        return hi
    }
    
    var modifyHeight: CGFloat {
        return bgView.frame.height
    }
    
    var isOriginal: Bool = false {
        didSet {
            originalBtn.isSelected = isOriginal
            refreshTotalSize()
        }
    }

    weak var dataSource: ADAssetBrowserDataSource?
    let config: ADPhotoKitConfig
    
    var editActionBlock: (()->Void)?
    var doneActionBlock: (()->Void)?
    
    /// ui
    var bgView: UIView!
    
    var editBtn: UIButton?
    var originalBtn: UIButton!
    var doneBtn: UIButton!
    var sizeLabel: UILabel!
    
    var selectView: ADBrowserToolBarSelectView!
    
    private var indexToken: NSKeyValueObservation?
    private var selectCountToken: NSKeyValueObservation?

    required init(dataSource: ADAssetBrowserDataSource, config: ADPhotoKitConfig) {
        self.dataSource = dataSource
        self.config = config
        super.init(frame: .zero)
        
        selectView = ADBrowserToolBarSelectView(dataSource: dataSource)

        setupUI()
        
        reloadCount(dataSource.selects.count)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        indexToken?.invalidate()
        selectCountToken?.invalidate()
    }
}

private extension ADBrowserToolBarView {
    
    func setupUI() {
        clipsToBounds = true
        
        bgView = UIView()
        bgView.backgroundColor = UIColor(hex: 0x232323, alpha: 0.3)
        addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(height).labeled("bgViewHeight")
        }
        
        let effect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        bgView.addSubview(effect)
        effect.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let btnsView = UIView()
        addSubview(btnsView)
        btnsView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-tabBarOffset)
            make.height.equalTo(55)
        }
        
        #if Module_ImageEdit
        editBtn = createBtn(ADLocale.LocaleKey.edit.localeTextValue, #selector(editAction))
        btnsView.addSubview(editBtn!)
        editBtn!.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(34)
            make.centerY.equalToSuperview()
        }
        #endif
        
        originalBtn = createBtn(ADLocale.LocaleKey.originalPhoto.localeTextValue, #selector(originalAction))
        originalBtn.isHidden = !(dataSource?.options.contains(.selectOriginal) ?? false)
        originalBtn.isSelected = isOriginal
        originalBtn.setImage(Bundle.image(name: "btn_original_circle"), for: .normal)
        originalBtn.setImage(Bundle.image(name: "btn_original_selected"), for: .selected)
        originalBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        originalBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        btnsView.addSubview(originalBtn)
        originalBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(34)
        }
        
        sizeLabel = UILabel()
        sizeLabel.font = UIFont.systemFont(ofSize: 12)
        sizeLabel.textColor = UIColor(hex: 0x828282)
        sizeLabel.textAlignment = .center
        sizeLabel.minimumScaleFactor = 0.5
        sizeLabel.adjustsFontSizeToFitWidth = true
        sizeLabel.isHidden = true
        btnsView.addSubview(sizeLabel)
        sizeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(originalBtn.snp.bottom)
            make.height.equalTo(14)
            make.centerX.equalTo(originalBtn.snp.centerX)
            make.width.equalTo(230)
        }
        
        doneBtn = createBtn(ADLocale.LocaleKey.done.localeTextValue, #selector(doneAction))
        doneBtn.setBackgroundImage(UIImage.image(color: UIColor(hex: 0x10C060)!), for: .normal)
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
        
        if let ass = dataSource?.current {
            reload(asset: ass)
        }
        indexToken = dataSource?.observe(\.index, options: .new) { [weak self] (dataSource, change) in
            if let ass = self?.dataSource?.current {
                self?.reload(asset: ass)
            }else{
                self?.editBtn?.isHidden = true
                self?.originalBtn.alpha = 0
            }
        }
        selectCountToken = dataSource?.observe(\.selectCount, options: .new, changeHandler: { (dataSource, change) in
            guard let count = change.newValue else { return }
            self.reloadCount(count)
        })
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
    
    func reload(asset: ADAssetBrowsable) {
        editBtn?.isHidden = true
        switch asset.browseAsset {
        case let .image(source):
            switch source {
            case .network(_):
                editBtn?.isHidden = true
                originalBtn.alpha = 0
                #if Module_ImageEdit
                editBtn?.isHidden = false
                #endif
            case let .album(ass):
                if ass.isGif || ass.isLivePhoto {
                    editBtn?.isHidden = true
                    originalBtn.alpha = 0
                }else{
                    editBtn?.isHidden = false
                    originalBtn.alpha = 1
                }
                #if Module_ImageEdit
                if ass.mediaType == .image {
                    editBtn?.isHidden = false
                }
                #endif
            case .local:
                editBtn?.isHidden = true
                originalBtn.alpha = 0
                #if Module_ImageEdit
                editBtn?.isHidden = false
                #endif
            }
        case .video(_):
            editBtn?.isHidden = true
            originalBtn.alpha = 0
        }
    }
    
    func reloadCount(_ count: Int) {
        if count > 0 {
            selectView.isHidden = false
            var title = ADLocale.LocaleKey.done.localeTextValue
            let selectCount = config.browserOpts.contains(.selectCountOnDoneBtn)
            if (selectCount) {
                title += "(\(count))"
            }
            doneBtn.setTitle(title, for: .normal)
            for item in bgView.constraints {
                if item.identifier == "bgViewHeight" {
                    item.constant = height
                    break
                }
            }
        }else{
            selectView.isHidden = true
            doneBtn.setTitle(ADLocale.LocaleKey.done.localeTextValue, for: .normal)
            for item in bgView.constraints {
                if item.identifier == "bgViewHeight" {
                    item.constant = 55+tabBarOffset
                    break
                }
            }
        }
        refreshTotalSize()
    }
    
    func refreshTotalSize() {
        guard config.assetOpts.contains(.totalOriginalSize) else {
            return
        }
        if !originalBtn.isSelected {
            sizeLabel.isHidden = true
        }else{
            sizeLabel.isHidden = false
            let total = dataSource?.selects.reduce(into: 0) { $0 += ($1.browseAsset.assetSize ?? 0) * 1024 } ?? 0
            let str = ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .binary).replacingOccurrences(of: " ", with: "")
            sizeLabel.text = ADLocale.LocaleKey.originalTotalSize.localeTextValue + "\(str)"
        }
    }
}

private extension ADBrowserToolBarView {
    
    @objc
    func editAction() {
        editActionBlock?()
    }
    
    @objc
    func originalAction() {
        isOriginal = !isOriginal
        refreshTotalSize()
    }
    
    @objc
    func doneAction() {
        doneActionBlock?()
    }
    
}
