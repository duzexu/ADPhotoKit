//
//  AlbumCell.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class AlbumCell: UITableViewCell, ADAlbumListCellConfigurable {
    
    var albumModel: ADAlbumModel!
    
    var style: ADPickerStyle!
    
    func configure(with model: ADAlbumModel) {
        albumModel = model
        titleLabel.text = model.title+"(\(model.count))"
        if let asset = model.lastestAsset {
            albumImageView.setAsset(asset, size: CGSize(width: 65*UIScreen.main.scale, height: 65*UIScreen.main.scale))
        }
    }
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
}
