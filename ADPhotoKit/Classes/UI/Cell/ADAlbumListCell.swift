//
//  ADAlbumListCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import UIKit

class ADAlbumListCell: UITableViewCell {

    var identifier: String?
    
    var albumModel: ADAlbumModel!

}

extension ADAlbumListCell: ADAlbumListConfigurable {
    
    func configure(with model: ADAlbumModel) {
        albumModel = model
        identifier = model.lastestAsset?.localIdentifier
        textLabel?.text = model.title + "(\(model.count))"
        if let asset = model.lastestAsset {
            ADPhotoManager.fetch(for: asset, type: .image(size: CGSize(width: 80, height: 80)), progress: nil) { [weak self] (image, _, _) in
                if self?.identifier == self?.albumModel.lastestAsset?.localIdentifier {
                    self?.imageView?.image =  image as? UIImage
                }
            }
        }
    }
    
}
