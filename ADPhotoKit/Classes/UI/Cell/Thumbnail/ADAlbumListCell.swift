//
//  ADAlbumListCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import UIKit
import Photos

public class ADAlbumListCell: UITableViewCell, ADAlbumListCellConfigurable {

    public var albumModel: ADAlbumModel!
    
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
    
    public func configure(with model: ADAlbumModel) {
        albumModel = model
        albumTitleLabel.text = model.title
        albumCountLabel.text = "(\(model.count))"
        if let asset = model.lastestAsset {
            albumImageView.setAsset(asset, size: CGSize(width: 65*UIScreen.main.scale, height: 65*UIScreen.main.scale), placeholder: Bundle.uiBundle?.image(name: "defaultphoto"))
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
        accessory.image = Bundle.uiBundle?.image(name: "albumSelect")
        accessory.isHidden = true
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryView?.isHidden = !selected
    }
    
}

/// UIAppearance
extension ADAlbumListCell {
    
    public enum Key: String {
        case cornerRadius /// 封面圆角
        case titleColor /// 标题颜色
        case titleFont /// 标题
        case countColor /// 数量颜色
        case countFont //数量
    }
    
    @objc
    public func setAttributes(_ attrs: [String : Any]?) {
        if let kvs = attrs {
            for (k,v) in kvs {
                if let key = Key(rawValue: k) {
                    switch key {
                    case .cornerRadius:
                        albumImageView.layer.cornerRadius = CGFloat((v as? Int) ?? 0)
                    case .titleColor:
                        albumTitleLabel.textColor = (v as? UIColor) ?? .white
                    case .countColor:
                        albumCountLabel.textColor = (v as? UIColor) ?? UIColor(hex: 0xB4B4B4)
                    case .titleFont:
                        albumTitleLabel.font = (v as? UIFont) ?? UIFont.systemFont(ofSize: 17)
                    case .countFont:
                        albumCountLabel.font = (v as? UIFont) ?? UIFont.systemFont(ofSize: 16)
                    }
                }
            }
        }
    }
    
}
