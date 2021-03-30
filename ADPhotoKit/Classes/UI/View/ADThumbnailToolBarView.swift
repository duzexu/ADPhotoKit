//
//  ADThumbnailToolBarView.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/27.
//

import UIKit

class ADThumbnailToolBarView: UIView, ADThumbnailToolBarConfigurable {
    
    var height: CGFloat {
        return 40
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
