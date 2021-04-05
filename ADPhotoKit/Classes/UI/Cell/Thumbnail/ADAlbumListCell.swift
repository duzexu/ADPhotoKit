//
//  ADAlbumListCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import UIKit
import Photos

class ADAlbumListCell: UITableViewCell {

    var albumModel: ADAlbumModel!
    
    /// ui
    var albumImageView: UIImageView!
    var albumTitleLabel: UILabel!
    var albumCountLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        albumImageView = UIImageView()
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.clipsToBounds = true
        contentView.addSubview(albumImageView)
        albumImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-2)
            make.width.equalTo(albumImageView.snp.height)
        }
        
        albumTitleLabel = UILabel()
        albumTitleLabel.font = UIFont.systemFont(ofSize: 17)
        albumTitleLabel.textColor = .white
        albumTitleLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(albumTitleLabel)
        albumTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(albumImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        albumCountLabel = UILabel()
        albumCountLabel.font = UIFont.systemFont(ofSize: 16)
        albumCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        albumCountLabel.textColor = UIColor(hex: 0xB4B4B4)
        contentView.addSubview(albumCountLabel)
        albumCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(albumTitleLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-40)
        }
        
    }
    
}

extension ADAlbumListCell: ADAlbumListConfigurable {
    
    func configure(with model: ADAlbumModel) {
        albumModel = model
        albumTitleLabel.text = model.title
        albumCountLabel.text = "(\(model.count))"
        if let asset = model.lastestAsset {
            albumImageView.kf.setImage(with: PHAssetImageDataProvider(asset: asset, size: CGSize(width: 65*UIScreen.main.scale, height: 65*UIScreen.main.scale)), placeholder: Bundle.uiBundle?.image(name: "defaultphoto"))
        }
    }
    
}

/// UIAppearance
extension ADAlbumListCell {
    
    /// 封面圆角
    @objc
    public dynamic var cornerRadius: CGFloat {
        set {
            albumImageView.layer.cornerRadius = newValue
        }
        get {
            return albumImageView.layer.cornerRadius
        }
    }
    
    /// 标题颜色
    @objc
    public dynamic var titleColor: UIColor {
        set {
            albumTitleLabel.textColor = newValue
        }
        get {
            return albumTitleLabel.textColor
        }
    }
    
    /// 标题颜色
    @objc
    public dynamic var countColor: UIColor {
        set {
            albumCountLabel.textColor = newValue
        }
        get {
            return albumCountLabel.textColor
        }
    }
}
