//
//  ADAddPhotoCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/24.
//

import UIKit

/// Cell for add asset in thumbnail controller.
public class ADAddPhotoCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(image: Bundle.image(name: "addPhoto"))
        imageView.backgroundColor = UIColor(white: 0.3, alpha: 1)
        imageView.contentMode = .center
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/// UIAppearance
extension ADAddPhotoCell {
    
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
    
    /// You may specify the corner radius, bg color properties for the cell in the attributes dictionary, using the keys found in `ADAddPhotoCell.Key`.
    /// - Parameter attrs: Attributes dictionary.
    @objc
    public func setAttributes(_ attrs: [Key : Any]?) {
        if let kvs = attrs {
            for (k,v) in kvs {
                if k == .bgColor {
                    imageView.backgroundColor = (v as? UIColor) ?? UIColor(white: 0.3, alpha: 1)
                }
                if k == .cornerRadius {
                    contentView.layer.cornerRadius = CGFloat((v as? Int) ?? 0)
                    contentView.layer.masksToBounds = true
                }
            }
        }
    }
    
}

extension ADAddPhotoCell.Key {
    /// Int, default 0
    public static let cornerRadius = ADAddPhotoCell.Key(rawValue: "cornerRadius")
    /// UIColor, default UIColor(white: 0.3, alpha: 1)
    public static let bgColor = ADAddPhotoCell.Key(rawValue: "bgColor")
}
