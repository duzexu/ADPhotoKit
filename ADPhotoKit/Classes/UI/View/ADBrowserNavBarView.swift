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
    
    var backActionBlock: (()->Void)?
    
    weak var dataSource: ADAssetBrowserDataSource?
    
    private var token: NSKeyValueObservation?

    init(dataSource: ADAssetBrowserDataSource) {
        self.dataSource = dataSource
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: 0x232323, alpha: 0.3)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        token?.invalidate()
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
        selectBtn.addTarget(self, action: #selector(selectBtnAction(sender:)), for: .touchUpInside)
        addSubview(selectBtn)
        selectBtn.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 44))
        }
        
        selectBtn.isSelected = dataSource?.isSelected ?? false
        token = dataSource?.observe(\.isSelected, options: .new) { (dataSource, change) in
            guard let selected = change.newValue else { return }
            selectBtn.isSelected = selected
        }
    }
}

extension ADBrowserNavBarView {
    @objc func backBtnAction() {
        backActionBlock?()
    }
    
    @objc func selectBtnAction(sender: UIButton) {
        if sender.isSelected {
            dataSource?.deleteSelect(dataSource!.index)
        }else{
            dataSource?.appendSelect(dataSource!.index)
        }
    }
}
