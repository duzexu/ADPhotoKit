//
//  ADAddPhotoCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/24.
//

import UIKit

public class ADAddPhotoCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(image: Bundle.uiBundle?.image(name: "addPhoto"))
        imageView.backgroundColor = UIColor(white: 0.3, alpha: 1)
        imageView.contentMode = .center
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/// UIAppearance
extension ADAddPhotoCell {
    
    public enum Key: String {
        case cornerRadius /// 圆角
        case bgColor /// 背景颜色
    }
    
    @objc
    public func setAttributes(_ attrs: [String : Any]?) {
        if let kvs = attrs {
            for (k,v) in kvs {
                if let key = Key(rawValue: k) {
                    switch key {
                    case .cornerRadius:
                        imageView.layer.cornerRadius = CGFloat((v as? Int) ?? 0)
                    case .bgColor:
                        imageView.backgroundColor = (v as? UIColor) ?? UIColor(white: 0.3, alpha: 1)
                    }
                }
            }
        }
    }
    
}
