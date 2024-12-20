//
//  ADEditToolCell.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/26.
//

import UIKit

class ADEditToolCell: UICollectionViewCell {
    
    private var iconImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        iconImageView = UIImageView(frame: .zero)
        iconImageView.transform = ADLocale.isRTL ? CGAffineTransform.identity.scaledBy(x: -1.0, y: 1) : CGAffineTransform.identity
        iconImageView.contentMode = .center
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tool: ADEditTool) {
        iconImageView.image = tool.isSelected ? (tool.selectImage ?? tool.image) : tool.image
    }
    
}
