//
//  ADAlbumListCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import UIKit
import Photos

class ADAlbumListCell: UITableViewCell {

    var identifier: String?
    
    var requestID: PHImageRequestID?
    
    var albumModel: ADAlbumModel!
    
    /// ui
    var albumImageView: UIImageView!
    var albumLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
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
        
        albumLabel = UILabel()
        albumLabel.font = UIFont.systemFont(ofSize: 17)
        albumLabel.textColor = .white
        albumLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(albumLabel)
        albumLabel.snp.makeConstraints { (make) in
            make.left.equalTo(albumImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-40)
        }
    }
    
}

extension ADAlbumListCell: ADAlbumListConfigurable {
    
    func configure(with model: ADAlbumModel) {
        albumModel = model
        identifier = model.lastestAsset?.localIdentifier
        albumLabel.text = model.title + "  (\(model.count))"
        if let asset = model.lastestAsset {
            if let id = requestID {
                PHImageManager.default().cancelImageRequest(id)
            }
            requestID = ADPhotoManager.fetch(for: asset, type: .image(size: CGSize(width: 80, height: 80)), progress: nil) { [weak self] (image, _, _) in
                if self?.identifier == self?.albumModel.lastestAsset?.localIdentifier {
                    self?.albumImageView?.image =  image as? UIImage
                }
            }
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
            albumLabel.textColor = newValue
        }
        get {
            return albumLabel.textColor ?? .white
        }
    }
}
