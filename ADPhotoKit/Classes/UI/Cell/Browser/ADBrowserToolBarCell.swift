//
//  ADAssetBrowserToolBarSelectCell.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/12.
//

import UIKit

class ADBrowserToolBarCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    var tagImageView: UIImageView!
    
    var tagLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor(hex: 0x50A938)?.cgColor
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tagImageView = UIImageView()
        contentView.addSubview(tagImageView)
        tagImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        tagLabel = UILabel()
        tagLabel.font = UIFont.systemFont(ofSize: 13)
        tagLabel.textColor = .white
        contentView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: ADAssetBrowsable) {
        tagImageView.isHidden = true
        tagLabel.isHidden = true
        switch model.browseAsset {
        case let .image(source):
            switch source {
            case let .network(url):
                imageView.kf.setImage(with: url)
            case let .album(asset):
                if asset.isGif {
                    tagLabel.isHidden = false
                    tagLabel.text = "GIF"
                }else if asset.isLivePhoto {
                    tagImageView.isHidden = false
                    tagImageView.image = Bundle.uiBundle?.image(name: "livePhoto")
                }
                imageView.setAsset(asset, size: CGSize(width: 60*UIScreen.main.scale, height: 60*UIScreen.main.scale), placeholder: Bundle.uiBundle?.image(name: "defaultphoto"))
            case let .local(img,_):
                imageView.image = img
            }
        case let .video(source):
            switch source {
            case let .network(url):
                imageView.setVideoUrlAsset(url)
            case let .album(asset):
                tagImageView.isHidden = false
                tagImageView.image = Bundle.uiBundle?.image(name: "video")
                imageView.setAsset(asset, size: CGSize(width: 60*UIScreen.main.scale, height: 60*UIScreen.main.scale), placeholder: Bundle.uiBundle?.image(name: "defaultphoto"))
            case let .local(url):
                imageView.setVideoUrlAsset(url)
            }
        }
        
    }
    
}
