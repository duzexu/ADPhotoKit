//
//  Ranger.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/4/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class Ranger: UIView {
    
    var valueChanged: ((Int,Int)->Void)?
    
    init(min: Int, max: Int) {
        super.init(frame: .zero)
        let minStepper = Stepper(value: min, tager: "min:")
        addSubview(minStepper)
        minStepper.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
        }
        let maxStepper = Stepper(value: max, tager: "max:")
        addSubview(maxStepper)
        maxStepper.snp.makeConstraints { (make) in
            make.left.equalTo(minStepper.snp.right).offset(10)
            make.right.top.bottom.equalToSuperview()
        }
        
        minStepper.valueChanged = { [weak self] value in
            self?.valueChanged?(Int(minStepper.control.value),Int(maxStepper.control.value))
        }
        maxStepper.valueChanged = { [weak self] value in
            self?.valueChanged?(Int(minStepper.control.value),Int(maxStepper.control.value))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
