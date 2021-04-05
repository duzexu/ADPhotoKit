//
//  ADAddPhotoCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/24.
//

import UIKit

class ADAddPhotoCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.3, alpha: 1)
        
        imageView = UIImageView(image: Bundle.uiBundle?.image(name: "addPhoto"))
        imageView.contentMode = .center
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
