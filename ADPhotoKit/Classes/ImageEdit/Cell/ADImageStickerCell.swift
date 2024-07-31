//
//  ADImageStickerCell.swift
//  ADPhotoKit
//
//  Created by xu on 2021/8/4.
//

import UIKit

class ADImageStickerSectionSelectCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor(white: 0, alpha: 0.4) : .clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with section: ADImageStickerDataSource.StickerSection) {
        imageView.image = section.icon
    }
    
}

class ADImageStickerSectionCell: UICollectionViewCell {
    
    var didSelectImage: ((UIImage) -> Void)?
    
    var model: ADImageStickerDataSource.StickerSection?
    
    var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout = ADCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 64, height: 64)
        layout.headerReferenceSize = CGSize(width: screenWidth, height: 49)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        collectionView.regisiter(cell: ADImageStickerItemCell.self)
        collectionView.regisiterHeader(cell: ADImageStickerSectionHeader.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(with section: ADImageStickerDataSource.StickerSection) {
        model = section
        collectionView.reloadData()
    }
    
}

extension ADImageStickerSectionCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADImageStickerItemCell.reuseIdentifier, for: indexPath) as! ADImageStickerItemCell
        if let item = model?.items[indexPath.row] {
            cell.configure(with: item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ADImageStickerSectionHeader.reuseIdentifier, for: indexPath) as! ADImageStickerSectionHeader
        view.nameLabel.text = model?.name
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return (model?.itemNameOn ?? false) ? 27 : 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bottom: CGFloat = (model?.itemNameOn ?? false) ? 27+16 : 16
        return UIEdgeInsets(top: 0, left: 16, bottom: bottom, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = model?.items[indexPath.row] {
            didSelectImage?(item.image)
        }
    }
}

class ADImageStickerSectionHeader: UICollectionReusableView {
    
    var nameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(hex: 0xcfcfcf)
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ADImageStickerItemCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(hex: 0x7f7f7f)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(7)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: ADImageStickerDataSource.StickerItem) {
        imageView.image = item.image
        label.text = item.name
    }
    
}
