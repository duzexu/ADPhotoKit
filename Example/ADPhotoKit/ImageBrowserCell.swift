//
//  ImageBrowserCell.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class ImageBrowserCell: UICollectionViewCell, ADImageBrowserCellConfigurable {
    
    func configure(with source: ADImageSource) {
        switch source {
        case let .network(url):
            imageView.kf.setImage(with: url)
        case let .album(asset):
            imageView.setAsset(asset)
        case let .local(img, _):
            imageView.image = img
        }
    }
    
    var singleTapBlock: (() -> Void)?
    
    func cellWillDisplay() {
        
    }
    
    func cellDidEndDisplay() {
        
    }
    
    func transationBegin() -> (UIView, CGRect) {
        let v = UIImageView(image: imageView.image)
        v.contentMode = .scaleAspectFit
        return (v,imageView.bounds)
    }
    
    func transationCancel(view: UIView) {
        
    }

    @IBOutlet weak var imageView: UIImageView!

}
