//
//  ADColorCell.swift
//  ADPhotoKit
//
//  Created by xu on 2021/8/3.
//

import UIKit

class ADColorCell: UIView {

    var isSelect: Bool = false {
        didSet {
            bgView.transform = isSelect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
        }
    }
    
    private var bgView: UIView!
    
    init(color: UIColor) {
        super.init(frame: .zero)
        bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 11
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
        
        let center = UIView()
        center.backgroundColor = color
        center.layer.masksToBounds = true
        center.layer.cornerRadius = 9
        addSubview(center)
        center.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
