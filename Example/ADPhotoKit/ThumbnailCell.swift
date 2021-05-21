//
//  ThumbnailCell.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class ThumbnailCell: UICollectionViewCell, ADThumbnailCellConfigurable {
    
    var selectStatus: ADThumbnailSelectStatus = .select(index: nil) {
        didSet {
            selectStatusDidChange()
        }
    }
    
    var assetModel: ADAssetModel!
    
    var indexPath: IndexPath!
    
    var selectAction: ((ADThumbnailCellable, Bool) -> Void)?
    
    func configure(with model: ADAssetModel) {
        assetModel = model
        selectStatus = model.selectStatus
        switch model.type {
        case .unknown:
            break
        case .image:
            descLabel.text = "Image"
        case .gif:
            descLabel.text = "Gif"
        case .livePhoto:
            descLabel.text = "LivePhoto"
        case let .video(_, format):
            descLabel.text = "Video:\(format)"
        }
        imageView.setAsset(model.asset, size: CGSize(width: 80*UIScreen.main.scale, height: 80*UIScreen.main.scale))
    }
    
    func cellSelectAction() {
        selectAction?(self,!selectStatus.isSelect)
    }
    
    private func selectStatusDidChange() {
        switch selectStatus {
        case let .select(index):
            if let idx = index {
                coverView.isHidden = false
                coverView.backgroundColor = UIColor(white: 0, alpha: 0.2)
                indexLabel.isHidden = false
                indexLabel.text = "\(idx)"
            }else{
                coverView.isHidden = true
                indexLabel.isHidden = true
            }
        case .deselect:
            coverView.isHidden = false
            coverView.backgroundColor = UIColor(white: 1, alpha: 0.5)
            indexLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var coverView: UIView!
    
}
