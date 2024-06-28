//
//  ADAlert.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/16.
//

import UIKit

/// Protocol use to show alert.
public protocol ADAlertConfigurable {
    
    /// Show alert on controller.
    /// - Parameters:
    ///   - on: The controller to show alert.
    ///   - title: Alert title.
    ///   - message: Alert message.
    ///   - actions: Alert actions.
    ///   - completion: Called when confirm button click.
    static func alert(on: UIViewController, title: String?, message: String?, actions: [String], completion: ((Int)->Void)?)
        
}

class ADAlert: ADAlertConfigurable {

    static func alert(on: UIViewController, title: String?, message: String?, actions: [String], completion: ((Int)->Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, item) in actions.enumerated() {
            let action = UIAlertAction(title: item, style: .default) { (_) in
                completion?(index)
            }
            alert.addAction(action)
        }
        on.present(alert, animated: true, completion: nil)
    }

}

extension ADAlert {
    
    static func alert() -> ADAlertConfigurable.Type {
        return ADPhotoKitConfiguration.default.customAlert ?? ADAlert.self
    }
    
}
