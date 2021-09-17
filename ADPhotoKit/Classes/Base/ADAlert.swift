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
    ///   - completion: Called when confirm button click.
    static func alert(on: UIViewController, title: String?, message: String?, completion: ((Int)->Void)?)
        
}

class ADAlert: ADAlertConfigurable {

    static func alert(on: UIViewController, title: String? = nil, message: String? = nil, completion: ((Int)->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: ADLocale.LocaleKey.ok.localeTextValue, style: .default) { (_) in
            completion?(0)
        }
        alert.addAction(action)
        on.present(alert, animated: true, completion: nil)
    }

}

extension ADAlert {
    #if Module_Core
    static func alert() -> ADAlertConfigurable.Type {
        return ADPhotoKitConfiguration.default.customAlert ?? ADAlert.self
    }
    #endif
}
