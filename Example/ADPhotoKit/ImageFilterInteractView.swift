//
//  ImageFilterInteractView.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/9/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class ImageFilterInteractView: UIView, ADToolInteractable {

    var zIndex: Int {
        return 0
    }
    
    var strategy: ADInteractStrategy {
        return .none
    }
    
    var interactClipBounds: Bool {
        return true
    }
    
    var clipingScreenInfo: ADClipingInfo?
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
