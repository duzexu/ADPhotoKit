//
//  File.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/4/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class ConfigSection {
    let title: String
    let models: [ConfigModel]
    
    init(title: String,
         models: [ConfigModel]) {
        self.title = title
        self.models = models
    }
}

class ConfigModel {
    
    enum Mode {
        case none
        case segment([String],Int)
        case `switch`(Bool)
        case stepper(Int)
        case range(Int,Int)
        
        func view(target: ConfigModel) -> UIView? {
            switch self {
            case .none:
                return nil
            case let .segment(array,index):
                let control = UISegmentedControl(items: array)
                control.addTarget(target, action: #selector(segmentedAction(_:)), for: .valueChanged)
                control.selectedSegmentIndex = index
                return control
            case let .switch(value):
                let control = UISwitch()
                control.isOn = value
                control.addTarget(target, action: #selector(switchAction(_:)), for: .valueChanged)
                return control
            case let .stepper(value):
                let control = Stepper(value: value)
                control.valueChanged = { [weak target] value in
                    target?.refreshMode(value: value)
                    target?.action?(value)
                }
                return control
            case let .range(min, max):
                let control = Ranger(min: min, max: max)
                control.valueChanged = { [weak target] min,max in
                    let trup = (min,max)
                    target?.refreshMode(value: trup)
                    target?.action?(trup)
                }
                return control
            }
        }
    }
    
    let title: String
    var mode: Mode
    let action: ((Any?) -> Void)?
    
    init(title: String,
         mode: Mode,
         action: ((Any?) -> Void)? = nil) {
        self.title = title
        self.mode = mode
        self.action = action
    }
    
    lazy var rightView: UIView? = {
        return mode.view(target: self)
    }()
    
    @objc func segmentedAction(_ sender: UISegmentedControl) {
        refreshMode(value: sender.selectedSegmentIndex)
        action?(sender.selectedSegmentIndex)
    }
    
    @objc func switchAction(_ sender: UISwitch) {
        refreshMode(value: sender.isOn)
        action?(sender.isOn)
    }
    
    private func refreshMode(value: Any) {
        switch mode {
        case .none:
            break
        case let .segment(array,_):
            mode = .segment(array, value as! Int)
        case .switch(_):
            mode = .switch(value as! Bool)
        case .stepper(_):
            mode = .stepper(value as! Int)
        case .range(_, _):
            let trup = value as! (Int,Int)
            mode = .range(trup.0, trup.1)
        }
    }
    
}
