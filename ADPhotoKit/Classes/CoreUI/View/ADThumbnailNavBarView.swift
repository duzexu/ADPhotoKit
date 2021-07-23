//
//  ADThumbnailNavBarView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/14.
//

import UIKit

class ADThumbnailNavBarView: ADBaseNavBarView, ADThumbnailNavBarConfigurable {
    
    var reloadAlbumBlock: ((ADAlbumModel)->Void)?
        
    var arrowImageView: UIImageView?
    var albumListView: ADEmbedAlbumListView?
    
    override var title: String? {
        didSet {
            titleLabel.text = title
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        }
    }
    
    required init(style: ADPickerStyle) {
        if style == .normal {
            super.init(rightItem: (nil,nil,ADLocale.LocaleKey.cancel.localeTextValue))
        }else{
            super.init(leftItem: (nil,nil,ADLocale.LocaleKey.cancel.localeTextValue), rightItem: nil)
            setupChildUI()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        UIView.animate(withDuration: 0.25) {
            self.arrowImageView?.transform = .identity
        }
    }
    
}

private extension ADThumbnailNavBarView {
    
    func setupChildUI() {
        let titleBg = UIControl()
        titleBg.backgroundColor = UIColor(hex: 0x505050)
        titleBg.layer.cornerRadius = 16
        titleBg.layer.masksToBounds = true
        titleBg.addTarget(self, action: #selector(titleBgAction), for: .touchUpInside)
        addSubview(titleBg)
        titleBg.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
            make.height.equalTo(32)
            make.width.lessThanOrEqualTo(screenWidth/2)
        }
        
        titleBg.addSubview(titleLabel)
        titleLabel.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
        }
        
        arrowImageView = UIImageView(image: Bundle.image(name: "downArrow"))
        titleBg.addSubview(arrowImageView!)
        arrowImageView!.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
        }
    }
    
    @objc
    func titleBgAction() {
        if arrowImageView?.transform == .identity {
            var reload: Bool = false
            if albumListView == nil {
                reload = true
                albumListView = ADEmbedAlbumListView(config: ADPhotoKitUI.config)
                albumListView!.selectAlbumBlock = { [weak self] album in
                    self?.reset()
                    if let al = album {
                        self?.title = al.title
                        self?.reloadAlbumBlock?(al)
                    }
                }
            }
            superview?.insertSubview(albumListView!, belowSubview: self)
            albumListView?.snp.makeConstraints({ (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(topBarHeight)
            })
            albumListView?.show(reload: reload)
            UIView.animate(withDuration: 0.25) {
                self.arrowImageView?.transform = CGAffineTransform(rotationAngle: .pi)
            }
        } else {
            albumListView?.hide()
            UIView.animate(withDuration: 0.25) {
                self.arrowImageView?.transform = .identity
            }
        }
    }
    
}
