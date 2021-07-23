//
//  ADAlbumListCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import UIKit
import Photos

/// Cell for display album in album list controller.
public class ADAlbumListCell: UITableViewCell, ADAlbumListCellConfigurable {
    
    /// Album model to config cell interface.
    public var albumModel: ADAlbumModel!
    
    /// Album display style.
    public var style: ADPickerStyle! = .normal {
        didSet {
            if style == .normal {
                accessoryView = nil
                albumImageView.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(12)
                    make.top.equalToSuperview().offset(2)
                    make.bottom.equalToSuperview().offset(-2)
                    make.width.equalTo(albumImageView.snp.height)
                }
            }else{
                accessoryView = accessory
                albumImageView.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.top.equalToSuperview().offset(2)
                    make.bottom.equalToSuperview().offset(-2)
                    make.width.equalTo(albumImageView.snp.height)
                }
            }
        }
    }
    
    /// Config cell with album model.
    /// - Parameter model: Album info.
    public func configure(with model: ADAlbumModel) {
        albumModel = model
        albumTitleLabel.text = model.title
        albumCountLabel.text = "(\(model.count))"
        if let asset = model.lastestAsset {
            albumImageView.setAsset(asset, size: CGSize(width: 65*UIScreen.main.scale, height: 65*UIScreen.main.scale), placeholder: Bundle.image(name: "defaultphoto"))
        }
    }
    
    /// ui
    var albumImageView: UIImageView!
    var albumTitleLabel: UILabel!
    var albumCountLabel: UILabel!
    var accessory: UIImageView!
    
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
        accessoryType = .disclosureIndicator
        
        albumImageView = UIImageView()
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.clipsToBounds = true
        contentView.addSubview(albumImageView)
        albumImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
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
        
        accessory = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        accessory.image = Bundle.image(name: "albumSelect")
        accessory.isHidden = true
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryView?.isHidden = !selected
    }
    
}

/// UIAppearance
extension ADAlbumListCell {
    
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
    
    /// You may specify the corner radius, title color, title font, count font, and count color properties for the cell in the attributes dictionary, using the keys found in `ADAlbumListCell.Key`.
    /// - Parameter attrs: Attributes dictionary.
    @objc
    public func setAttributes(_ attrs: [Key : Any]?) {
        if let kvs = attrs {
            for (k,v) in kvs {
                if k == .cornerRadius {
                    albumImageView.layer.cornerRadius = CGFloat((v as? Int) ?? 0)
                }
                if k == .titleColor {
                    albumTitleLabel.textColor = (v as? UIColor) ?? .white
                }
                if k == .titleFont {
                    albumTitleLabel.font = (v as? UIFont) ?? UIFont.systemFont(ofSize: 17)
                }
                if k == .countColor {
                    albumCountLabel.textColor = (v as? UIColor) ?? UIColor(hex: 0xB4B4B4)
                }
                if k == .countFont {
                    albumCountLabel.font = (v as? UIFont) ?? UIFont.systemFont(ofSize: 16)
                }
            }
        }
    }
    
}

extension ADAlbumListCell.Key {
    /// Int, default 0
    public static let cornerRadius = ADAlbumListCell.Key(rawValue: "cornerRadius")
    /// UIColor, default .white
    public static let titleColor = ADAlbumListCell.Key(rawValue: "titleColor")
    /// UIFont, default UIFont.systemFont(ofSize: 17)
    public static let titleFont = ADAlbumListCell.Key(rawValue: "titleFont")
    /// UIColor, default UIColor(hex: 0xB4B4B4)
    public static let countColor = ADAlbumListCell.Key(rawValue: "countColor")
    /// UIFont, default UIFont.systemFont(ofSize: 16)
    public static let countFont = ADAlbumListCell.Key(rawValue: "countFont")
}
