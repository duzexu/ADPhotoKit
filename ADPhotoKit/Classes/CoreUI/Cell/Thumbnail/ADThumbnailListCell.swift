//
//  ADThumbnailListCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/21.
//

import UIKit
import Photos

extension ADAssetModel {
    static var thumbnailSize: CGSize {
        let columnCount: CGFloat = CGFloat(ADPhotoKitConfiguration.default.thumbnailLayout.columnCount)
        let totalW = screenWidth - (columnCount - 1) * ADPhotoKitConfiguration.default.thumbnailLayout.itemSpacing
        let singleW = totalW / columnCount
        return CGSize(width: singleW, height: singleW)
    }
}

/// Cell for display asset in thumbnail controller.
public class ADThumbnailListCell: UICollectionViewCell {
    
    /// Thumbnail cell select status.
    public var selectStatus: ADAssetModel.SelectStatus = .select(index: nil) {
        didSet {
            selectStatusDidChange()
        }
    }
    
    /// Called when cell select or deselect. The parameter `Bool` represent asset is selet or not.
    public var selectAction: ((ADThumbnailCellConfigurable,Bool)->Void)?
    
    /// Asset model to config cell interface.
    public var assetModel: ADAssetModel!
    
    /// Cell indexPath in collection view.
    public var indexPath: IndexPath!
    
    // ui
    var imageView: UIImageView!
    var selectBtn: UIButton!
    var bottomMaskView: UIImageView!
    var tagImageView: UIImageView!
    var descLabel: UILabel!
    var indexLabel: UILabel!
    var coverView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        coverView = UIView()
        coverView.isUserInteractionEnabled = false
        coverView.isHidden = true
        contentView.addSubview(coverView)
        coverView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        selectBtn = UIButton(type: .custom)
        selectBtn.setBackgroundImage(Bundle.image(name: "btn_unselected"), for: .normal)
        selectBtn.setBackgroundImage(Bundle.image(name: "btn_selected"), for: .selected)
        selectBtn.addTarget(self, action: #selector(selectBtnAction(sender:)), for: .touchUpInside)
        contentView.addSubview(selectBtn)
        selectBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-7)
        }
        
        indexLabel = UILabel()
        indexLabel.backgroundColor = UIColor(hex: 0x10C060)
        indexLabel.layer.cornerRadius = 12
        indexLabel.layer.masksToBounds = true
        indexLabel.textColor = .white
        indexLabel.font = UIFont.systemFont(ofSize: 14)
        indexLabel.adjustsFontSizeToFitWidth = true
        indexLabel.minimumScaleFactor = 0.5
        indexLabel.textAlignment = .center
        selectBtn.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bottomMaskView = UIImageView(frame: .zero)
        bottomMaskView.image = Bundle.image(name: "shadow")
        contentView.addSubview(bottomMaskView)
        bottomMaskView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(25)
        }
        
        tagImageView = UIImageView(frame: .zero)
        tagImageView.image = nil
        tagImageView.contentMode = .center
        bottomMaskView.addSubview(tagImageView)
        tagImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(1)
        }
        
        descLabel = UILabel()
        descLabel.font = UIFont.systemFont(ofSize: 13)
        descLabel.textAlignment = .right
        descLabel.textColor = .white
        bottomMaskView.addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(1)
            make.right.equalToSuperview().offset(-5)
        }
    }
    
    func selectStatusDidChange() {
        switch selectStatus {
        case let .select(index):
            selectBtn.isEnabled = true
            if let idx = index {
                coverView.isHidden = false
                coverView.backgroundColor = UIColor(white: 0, alpha: 0.2)
                selectBtn.isSelected = true
                indexLabel.isHidden = false
                indexLabel.text = "\(idx)"
                contentView.layer.borderWidth = 0
                if let set = ADThumbnailListCell.appearanceAttributes[.select] {
                    for item in set {
                        switch item {
                        case let .borderColor(color):
                            contentView.layer.borderColor = color.cgColor
                        case let .borderWidth(width):
                            contentView.layer.borderWidth = width
                        case let .coverColor(color):
                            coverView.backgroundColor = color
                        }
                    }
                }
            }else{
                coverView.isHidden = true
                indexLabel.isHidden = true
                selectBtn.isSelected = false
                contentView.layer.borderWidth = 0
                if let set = ADThumbnailListCell.appearanceAttributes[.normal] {
                    for item in set {
                        switch item {
                        case let .borderColor(color):
                            contentView.layer.borderColor = color.cgColor
                        case let .borderWidth(width):
                            contentView.layer.borderWidth = width
                        case let .coverColor(color):
                            coverView.backgroundColor = color
                        }
                    }
                }
            }
        case .deselect:
            coverView.isHidden = false
            coverView.backgroundColor = UIColor(white: 1, alpha: 0.5)
            indexLabel.isHidden = true
            selectBtn.isSelected = false
            selectBtn.isEnabled = false
            contentView.layer.borderWidth = 0
            if let set = ADThumbnailListCell.appearanceAttributes[.disabled] {
                for item in set {
                    switch item {
                    case let .borderColor(color):
                        contentView.layer.borderColor = color.cgColor
                    case let .borderWidth(width):
                        contentView.layer.borderWidth = width
                    case let .coverColor(color):
                        coverView.backgroundColor = color
                    }
                }
            }
        }
    }
    
    @objc
    func selectBtnAction(sender: UIButton) {
        selectBtn.layer.removeAllAnimations()
        if !selectBtn.isSelected {
            selectBtn.layer.add(ADPhotoKitUI.springAnimation(), forKey: nil)
        }
        selectAction?(self,!sender.isSelected)
    }
}

extension ADThumbnailListCell: ADThumbnailCellConfigurable {
    
    /// Config cell with asset model.
    /// - Parameter model: Asset info.
    public func configure(with model: ADAssetModel, config: ADPhotoKitConfig) {
        assetModel = model
        selectStatus = model.selectStatus
        selectBtn.isHidden = !config.displaySelectBtn(model: model)
        indexLabel.alpha = config.assetOpts.contains(.selectIndex) ? 1 : 0

        switch model.type {
        case .unknown:
            bottomMaskView.isHidden = true
        case .image:
            bottomMaskView.isHidden = true
        case .gif:
            bottomMaskView.isHidden = !config.assetOpts.contains(.selectAsGif)
            tagImageView.image = nil
            descLabel.text = "GIF"
        case .livePhoto:
            bottomMaskView.isHidden = !config.assetOpts.contains(.selectAsLivePhoto)
            tagImageView.image = Bundle.image(name: "livePhoto")
            descLabel.text = "Live"
        case let .video(_, format):
            tagImageView.image = Bundle.image(name: "video")
            bottomMaskView.isHidden = false
            descLabel.text = format
        }
        
        #if Module_ImageEdit
        if let imageEdit = model.imageEditInfo?.editImg {
            descLabel.text = ""
            imageView.image = imageEdit
            bottomMaskView.isHidden = false
            tagImageView.image = Bundle.image(name: "EditedIcon_Normal", module: .imageEdit)
            return
        }
        #endif
        
        imageView.setAsset(model.asset, size: CGSize(width: ADAssetModel.thumbnailSize.width*UIScreen.main.scale, height: ADAssetModel.thumbnailSize.height*UIScreen.main.scale), placeholder: Bundle.image(name: "defaultphoto"))
    }
    
    /// Select or deselect cell.
    public func cellSelectAction() {
        selectBtnAction(sender: selectBtn)
    }
    
}

/// UIAppearance
extension ADThumbnailListCell {
    
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
    
    /// You may specify the corner radius, index color, index font, desc font, and desc color properties for the cell in the attributes dictionary, using the keys found in `ADThumbnailListCell.Key`.
    /// - Parameter attrs: Attributes dictionary.
    @objc
    public func setAttributes(_ attrs: [Key : Any]?) {
        if let kvs = attrs {
            for (k,v) in kvs {
                if k == .cornerRadius {
                    contentView.layer.cornerRadius = CGFloat((v as? Int) ?? 0)
                    contentView.layer.masksToBounds = true
                }
                if k == .indexColor {
                    indexLabel.textColor = (v as? UIColor) ?? .white
                }
                if k == .indexBgColor {
                    indexLabel.backgroundColor = (v as? UIColor) ?? UIColor(hex: 0x10C060)
                }
                if k == .indexFont {
                    indexLabel.font = (v as? UIFont) ?? UIFont.systemFont(ofSize: 14)
                }
                if k == .descColor {
                    descLabel.textColor = (v as? UIColor) ?? .white
                }
                if k == .descFont {
                    descLabel.font = (v as? UIFont) ?? UIFont.systemFont(ofSize: 13)
                }
            }
        }
    }
    
    /// State of cell.
    public enum State {
        /// cell is normal.
        case normal
        /// cell is select.
        case select
        /// cell is deselect.
        case disabled
    }
    
    /// Appearance of cell.
    public enum Appearance: Hashable {
        case borderColor(UIColor)
        case borderWidth(CGFloat)
        case coverColor(UIColor)
        
        public func hash(into hasher: inout Hasher) {
            var value: Int = 0
            switch self {
            case .borderColor(_):
                value = 1
            case .borderWidth(_):
                value = 2
            case .coverColor(_):
                value = 3
            }
            hasher.combine(value)
        }
    }
    
    private(set) static var appearanceAttributes: [State:Set<Appearance>] = [:]
    
    /// Config appearance for diffent cell state.
    /// - Parameters:
    ///   - appearance: Appearance of cell.
    ///   - state: State of cell.
    public static func setAppearance(_ appearance: Appearance, for state: State) {
        if var value = appearanceAttributes[state] {
            value.insert(appearance)
            appearanceAttributes[state] = value
        }else{
            appearanceAttributes[state] = Set<Appearance>(arrayLiteral: appearance)
        }
    }
    
}

extension ADThumbnailListCell.Key {
    /// Int, default 0
    public static let cornerRadius = ADThumbnailListCell.Key(rawValue: "cornerRadius")
    /// UIColor, default .white
    public static let indexColor = ADThumbnailListCell.Key(rawValue: "indexColor")
    /// UIColor, default UIColor(hex: 0x10C060)
    public static let indexBgColor = ADThumbnailListCell.Key(rawValue: "indexBgColor")
    /// UIFont, default UIFont.systemFont(ofSize: 14)
    public static let indexFont = ADThumbnailListCell.Key(rawValue: "indexFont")
    /// UIColor, default .white
    public static let descColor = ADThumbnailListCell.Key(rawValue: "descColor")
    /// UIFont, default UIFont.systemFont(ofSize: 13)
    public static let descFont = ADThumbnailListCell.Key(rawValue: "descFont")
}

extension ADPhotoKitConfig {
    
    fileprivate func displaySelectBtn(model: ADAssetModel) -> Bool {
        if let max = params.maxCount {
            if max > 1 {
                if !assetOpts.contains(.mixSelect), let type = selectMediaImage {
                    return model.type.isImage == type
                }else{
                    return true
                }
            }else{
                return assetOpts.contains(.selectBtnWhenSingleSelect)
            }
        }
        return true
    }
    
}
