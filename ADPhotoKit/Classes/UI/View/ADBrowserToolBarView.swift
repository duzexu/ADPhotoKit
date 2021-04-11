//
//  ADBrowserToolBarView.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/11.
//

import UIKit

class ADBrowserToolBarView: UIView, ADBrowserToolBarConfigurable {

    var height: CGFloat {
        return 55+tabBarOffset
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

private extension ADBrowserToolBarView {
    
    func setupUI() {
        let effect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        addSubview(effect)
        effect.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}
