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
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tool: ADImageEditTool) {
        iconImageView.image = tool.isSelected ? (tool.selectImage ?? tool.image) : tool.image
    }
    
}
