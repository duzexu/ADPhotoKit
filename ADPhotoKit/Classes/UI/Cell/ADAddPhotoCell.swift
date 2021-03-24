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
        
        imageView = UIImageView(image: Bundle.uiBundle?.image(name: "takePhoto"))
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width / 3, height: self.bounds.width / 3)
        self.imageView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
    }
    
}
