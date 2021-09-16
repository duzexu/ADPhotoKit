//
//  ImageFilterSelctView.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/9/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class ImageFilterSelectView: UIView, ADToolConfigable {

    func singleTap(with point: CGPoint) -> Bool {
        if collectionView.frame.contains(point) {
            let sub = convert(point, to: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: sub) {
                dataSource?.collectionView?(collectionView, didSelectItemAt: indexPath)
                return true
            }
        }
        return false
    }
    
    weak var dataSource: (UICollectionViewDataSource & UICollectionViewDelegate)?
    
    var collectionView: UICollectionView!
    
    init(dataSource: UICollectionViewDataSource & UICollectionViewDelegate) {
        self.dataSource = dataSource
        super.init(frame: .zero)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottomMargin).offset(-64)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(30)
        }
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: "FilterCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class FilterCell: UICollectionViewCell {
    
    var nameLabel: UILabel!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
        }
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
