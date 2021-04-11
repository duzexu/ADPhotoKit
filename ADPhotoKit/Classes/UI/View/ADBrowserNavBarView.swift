//
//  ADBrowserNavBarView.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/11.
//

import UIKit

class ADBrowserNavBarView: UIView, ADBrowserNavBarConfigurable {
    
    var height: CGFloat {
        return UIApplication.shared.statusBarFrame.height + 44
    }
    
    let options: ADAssetBrowserOptions

    init(options: ADAssetBrowserOptions) {
        self.options = options
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: 0x232323, alpha: 0.3)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ADBrowserNavBarView {
    
    func setupUI() {
        let effect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        addSubview(effect)
        effect.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let backBtn = UIButton(type: .custom)
        backBtn.contentMode = .left
        backBtn.setImage(Bundle.uiBundle?.image(name: "navBack"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 44))
        }
        
        let selectBtn = UIButton(type: .custom)
        selectBtn.contentMode = .right
        selectBtn.setImage(Bundle.uiBundle?.image(name: "btn_circle"), for: .normal)
        selectBtn.setImage(Bundle.uiBundle?.image(name: "btn_selected"), for: .selected)
        selectBtn.addTarget(self, action: #selector(selectBtnAction), for: .touchUpInside)
        addSubview(selectBtn)
        selectBtn.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 44))
        }
    }
}

extension ADBrowserNavBarView {
    @objc func backBtnAction() {
        
    }
    
    @objc func selectBtnAction() {
        
    }
}
