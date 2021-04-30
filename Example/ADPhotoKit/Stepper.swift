//
//  Stepper.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/4/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class Stepper: UIView {

    let tager: String?
    
    let label = UILabel()
    let control = UIStepper()
    
    var valueChanged: ((Int)->Void)?
    
    init(value: Int, tager: String? = nil) {
        self.tager = tager
        super.init(frame: .zero)
        addSubview(label)
        label.text = "\(tager ?? "")\(value)"
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        addSubview(control)
        control.value = Double(value)
        control.addTarget(target, action: #selector(stepperAction(_:)), for: .valueChanged)
        control.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(2)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func stepperAction(_ sender: UIStepper) {
        label.text = "\(tager ?? "")\(Int(sender.value))"
        valueChanged?(Int(sender.value))
    }
    
}
