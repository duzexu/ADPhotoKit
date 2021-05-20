//
//  Progress.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class Progress: UIView, ADProgressConfigurable {
    
    var progress: CGFloat {
        set {
            progressV.progress = Float(newValue)
        }
        get {
            return CGFloat(progressV.progress)
        }
    }
    
    private var progressV: UIProgressView!
    
    init() {
        super.init(frame: .zero)
        progressV = UIProgressView(progressViewStyle: .default)
        progressV.tintColor = .white
        addSubview(progressV)
        progressV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
        }
        self.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 120, height: 20))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
