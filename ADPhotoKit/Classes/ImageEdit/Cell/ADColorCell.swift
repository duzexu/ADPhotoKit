//
//  ADColorCell.swift
//  ADPhotoKit
//
//  Created by xu on 2021/8/3.
//

import UIKit

class ADColorCell: UICollectionViewCell {

    var isSelect: Bool = false {
        didSet {
            centerView.transform = isSelect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            bgView.transform = isSelect ? CGAffineTransform(scaleX: 1.3, y: 1.3) : .identity
        }
    }
    
    var color: UIColor = .white {
        didSet {
            centerView.backgroundColor = color
        }
    }
    
    var cellSelectBlock: ((Int) -> Void)?
    
    private var bgView: UIView!
    private var centerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 11
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
        
        centerView = UIView()
        centerView.backgroundColor = color
        centerView.layer.masksToBounds = true
        centerView.layer.cornerRadius = 9
        addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
