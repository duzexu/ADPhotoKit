//
//  ADBrowserNavBarView.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/11.
//

import UIKit

class ADBrowserNavBarView: ADBaseNavBarView, ADBrowserNavBarConfigurable {
        
    weak var dataSource: ADAssetBrowserDataSource?
    
    private var selectToken: NSKeyValueObservation?
    private var selectIndexToken: NSKeyValueObservation?

    required init(dataSource: ADAssetBrowserDataSource) {
        self.dataSource = dataSource
        super.init(rightItem: (Bundle.uiBundle?.image(name: "btn_circle"), Bundle.uiBundle?.image(name: "btn_selected"),nil))
        
        setupChildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        selectToken?.invalidate()
        selectIndexToken?.invalidate()
    }
    
}

private extension ADBrowserNavBarView {
    
    func setupChildUI() {
        let indexLabel = UILabel()
        indexLabel.backgroundColor = UIColor(hex: 0x50A938)
        indexLabel.layer.cornerRadius = 13
        indexLabel.layer.masksToBounds = true
        indexLabel.textColor = .white
        indexLabel.font = UIFont.systemFont(ofSize: 14)
        indexLabel.textAlignment = .center
        indexLabel.isHidden = true
        rightBtnItem.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 26, height: 26))
        }
        
        rightBtnItem.isSelected = dataSource?.isSelected ?? false
        selectToken = dataSource?.observe(\.isSelected, options: .new, changeHandler: { [weak self] (dataSource, change) in
            guard let selected = change.newValue else { return }
            self?.rightBtnItem.isSelected = selected
        })
        
        if let index = dataSource?.selectIndex {
            if index >= 0 {
                indexLabel.isHidden = false
                indexLabel.text = "\(index+1)"
            }else{
                indexLabel.isHidden = true
            }
        }
        selectIndexToken = dataSource?.observe(\.selectIndex, options: .new, changeHandler: { (dataSource, change) in
            guard let index = change.newValue else { return }
            if index >= 0 {
                indexLabel.isHidden = false
                indexLabel.text = "\(index+1)"
            }else{
                indexLabel.isHidden = true
            }
        })
    }
}
