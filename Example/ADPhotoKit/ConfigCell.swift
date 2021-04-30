//
//  ConfigCell.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/4/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class ConfigCell: UITableViewCell {
    
    var config: ConfigModel!
    
    @IBOutlet weak var titleLabel: UILabel!
    var customView: UIView?

    func config(model: ConfigModel) {
        config = model
        titleLabel.text = model.title
        customView?.removeFromSuperview()
        customView = nil
        if let v = model.rightView() {
            customView = v
            contentView.addSubview(v)
            v.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
            }
        }
    }

}
