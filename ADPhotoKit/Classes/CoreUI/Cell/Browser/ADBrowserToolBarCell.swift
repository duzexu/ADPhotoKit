//
//  ADAssetBrowserToolBarSelectCell.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/12.
//

import UIKit

/// Select preview view cell in browser controller.
public class ADBrowserToolBarCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    var tagImageView: UIImageView!
    
    var tagLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor(hex: 0x10C060)?.cgColor
        
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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: ADAssetBrowsable) {
        tagImageView.isHidden = true
        tagLabel.isHidden = true
        #if Module_ImageEdit
        if model.imageEditInfo != nil {
            imageView.image = model.imageEditInfo?.editImg
            tagImageView.isHidden = false
            tagImageView.image = Bundle.image(name: "EditedIcon_Normal", module: .imageEdit)
            return
        }
        #endif
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
                    tagImageView.image = Bundle.image(name: "livePhoto")
                }
                imageView.setAsset(asset, size: CGSize(width: 60*UIScreen.main.scale, height: 60*UIScreen.main.scale), placeholder: Bundle.image(name: "defaultphoto"))
            case let .local(img,_):
                imageView.image = img
            }
        case let .video(source):
            switch source {
            case let .network(url):
                imageView.setVideoUrlAsset(url)
            case let .album(asset):
                tagImageView.isHidden = false
                tagImageView.image = Bundle.image(name: "video")
                imageView.setAsset(asset, size: CGSize(width: 60*UIScreen.main.scale, height: 60*UIScreen.main.scale), placeholder: Bundle.image(name: "defaultphoto"))
            case let .local(url):
                imageView.setVideoUrlAsset(url)
            }
        }
    }
    
}

/// UIAppearance
extension ADBrowserToolBarCell {
    
    /// Key for attribute.
    public class Key: NSObject {
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        static func == (lhs: Key, rhs: Key) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    
    /// You may specify the corner radius, tag color, tag font,and border color properties for the cell in the attributes dictionary, using the keys found in `ADBrowserToolBarCell.Key`.
    /// - Parameter attrs: Attributes dictionary.
    @objc
    public func setAttributes(_ attrs: [Key : Any]?) {
        if let kvs = attrs {
            for (k,v) in kvs {
                if k == .cornerRadius {
                    layer.cornerRadius = CGFloat((v as? Int) ?? 0)
                    layer.masksToBounds = true
                }
                if k == .tagColor {
                    tagLabel.textColor = (v as? UIColor) ?? .white
                }
                if k == .tagFont {
                    tagLabel.font = (v as? UIFont) ?? UIFont.systemFont(ofSize: 17)
                }
                if k == .borderColor {
                    layer.borderColor = (v as? UIColor)?.cgColor ?? UIColor(hex: 0x10C060)?.cgColor
                }
            }
        }
    }
    
}

extension ADBrowserToolBarCell.Key {
    /// Int, default 0
    public static let cornerRadius = ADBrowserToolBarCell.Key(rawValue: "cornerRadius")
    /// UIColor, default .white
    public static let tagColor = ADBrowserToolBarCell.Key(rawValue: "tagColor")
    /// UIFont, default UIFont.systemFont(ofSize: 13)
    public static let tagFont = ADBrowserToolBarCell.Key(rawValue: "tagFont")
    /// UIColor, default UIColor(hex: 0x10C060)
    public static let borderColor = ADBrowserToolBarCell.Key(rawValue: "borderColor")
}
