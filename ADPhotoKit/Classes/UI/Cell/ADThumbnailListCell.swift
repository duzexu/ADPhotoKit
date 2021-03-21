//
//  ADThumbnailListCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/21.
//

import UIKit
import Photos

class ADThumbnailListCell: UICollectionViewCell {
    
    var identifier: String?
    
    var smallRequestID: PHImageRequestID?
    
    var bigRequestID: PHImageRequestID?
    
    var selectStatus: ADThumbnailSelectStatus = .select(index: nil) {
        didSet {
            selectStatusDidChange()
        }
    }
    
    var progressView: ADProgressableView!
    
    var assetModel: ADAssetModel!
    
    // ui
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        progressView = ADProgressView(frame: .zero)
        addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.center.equalToSuperview()
        }
        imageView = UIImageView(frame: .zero)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectStatusDidChange() {
        if let id = bigRequestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        switch selectStatus {
        case let .select(index):
            if let idx = index {
                bigRequestID = ADPhotoManager.fetch(for: assetModel.asset, type: .originImageData, progress: { [weak self] (progress, err, _, _) in
                    if self?.selectStatus.isSelect == true {
                        self?.progressView.isHidden = false
                        self?.progressView.progress = max(0.1, CGFloat(progress))
                        self?.imageView.alpha = 0.5
                        if progress >= 1 {
                            self?.progressView.isHidden = true
                            self?.imageView.alpha = 1
                        }
                    } else {
                        if let id = self?.bigRequestID {
                            PHImageManager.default().cancelImageRequest(id)
                        }
                    }
                }, completion: { [weak self] (_, _, _) in
                    self?.progressView.isHidden = true
                    self?.imageView.alpha = 1
                })
            }else{
                
            }
        case .deselect:
            break
        }
    }
}

extension ADThumbnailListCell: ADThumbnailListConfigurable {
    
    func configure(with model: ADAssetModel) {
        assetModel = model
        identifier = model.identifier
        if let id = smallRequestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        smallRequestID = ADPhotoManager.fetch(for: model.asset, type: .image(size: CGSize(width: 80, height: 80)), progress: nil) { [weak self] (image, _, _) in
            if self?.identifier == self?.assetModel.identifier {
                self?.imageView?.image =  image as? UIImage
            }
        }
    }
    
}
