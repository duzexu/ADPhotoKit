//
//  ADThumbnailToolBarView.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/27.
//

import UIKit
import Photos

class ADThumbnailToolBarView: UIView, ADThumbnailToolBarConfigurable {
    
    var height: CGFloat {
        var hi: CGFloat = 0
        if config.assetOpts.contains(.thumbnailToolBar) {
            hi += 55+tabBarOffset
            if authTipsEnable {
                hi += 70
            }
        }
        return hi
    }
    
    var isOriginal: Bool = false {
        didSet {
            originalBtn.isSelected = isOriginal
            refreshTotalSize()
        }
    }
    
    public var selectCount: Int = 0 {
        didSet {
            if selectCount > 0 {
                var title = ADLocale.LocaleKey.done.localeTextValue
                if (config.browserOpts.contains(.selectCountOnDoneBtn)) {
                    title += "(\(selectCount))"
                }
                doneBtn.setTitle(title, for: .normal)
                doneBtn.isEnabled = true
                browseBtn.isEnabled = true
            }else{
                doneBtn.setTitle(ADLocale.LocaleKey.done.localeTextValue, for: .normal)
                doneBtn.isEnabled = false
                browseBtn.isEnabled = false
            }
            refreshTotalSize()
        }
    }
    
    var authTipsEnable: Bool {
        if #available(iOS 14.0, *), PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited, config.assetOpts.contains(.allowAuthTips) {
            return true
        } else {
            return false
        }
    }
    
    var browserActionBlock: (()->Void)?
    var doneActionBlock: (()->Void)?
    
    weak var dataSource: ADAssetListDataSource?
    let config: ADPhotoKitConfig
    
    /// ui
    var browseBtn: UIButton!
    var originalBtn: UIButton!
    var doneBtn: UIButton!
    var sizeLabel: UILabel!
    
    required init(dataSource: ADAssetListDataSource, config: ADPhotoKitConfig) {
        self.dataSource = dataSource
        self.config = config
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: 0x232323, alpha: 0.3)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ADThumbnailToolBarView {
    
    func setupUI() {
        let effect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        addSubview(effect)
        effect.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if authTipsEnable {
            let tipsView = UIView()
            addSubview(tipsView)
            tipsView.snp.makeConstraints { (make) in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(70)
            }
            
            let icon = UIImageView(image: Bundle.image(name: "warning"))
            tipsView.addSubview(icon)
            icon.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.centerY.equalToSuperview()
            }
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = ADLocale.LocaleKey.unableToAccessAllPhotos.localeTextValue
            label.textColor = UIColor(hex: 0xA8A8A8)
            label.numberOfLines = 2
            label.lineBreakMode = .byTruncatingTail
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            tipsView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(55)
                make.right.equalToSuperview().offset(-30)
                make.centerY.equalToSuperview()
                make.height.equalTo(40)
            }
            
            let arrow = UIImageView(image: Bundle.image(name: "right_arrow"))
            tipsView.addSubview(arrow)
            arrow.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-13)
                make.centerY.equalToSuperview()
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
            tipsView.addGestureRecognizer(tap)
        }
        
        let btnsView = UIView()
        addSubview(btnsView)
        btnsView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(authTipsEnable ? 70 : 0)
            make.height.equalTo(55)
        }
        
        browseBtn = createBtn(ADLocale.LocaleKey.preview.localeTextValue, #selector(previewAction))
        btnsView.addSubview(browseBtn)
        browseBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(34)
            make.centerY.equalToSuperview()
        }
        
        originalBtn = createBtn(ADLocale.LocaleKey.originalPhoto.localeTextValue, #selector(originalAction))
        originalBtn.isHidden = !config.browserOpts.contains(.selectOriginal) && config.albumOpts.contains(.allowImage)
        originalBtn.isSelected = isOriginal
        originalBtn.setImage(Bundle.image(name: "btn_original_circle"), for: .normal)
        originalBtn.setImage(Bundle.image(name: "btn_original_selected"), for: .selected)
        if ADLocale.isRTL {
            originalBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
            originalBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        } else {
            originalBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
            originalBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        }
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
    
    func refreshTotalSize() {
        guard config.assetOpts.contains(.totalOriginalSize) else {
            return
        }
        if !originalBtn.isSelected || dataSource?.selects.count == 0 {
            sizeLabel.isHidden = true
        }else{
            sizeLabel.isHidden = false
            let total = dataSource?.selects.reduce(into: 0) { $0 += ($1.asset.assetSize ?? 0) * 1024 } ?? 0
            let str = ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .binary).replacingOccurrences(of: " ", with: "")
            sizeLabel.text = ADLocale.LocaleKey.originalTotalSize.localeTextValue + "\(str)"
        }
    }
}

private extension ADThumbnailToolBarView {
    
    @objc
    func tapAction() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc
    func previewAction() {
        browserActionBlock?()
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
