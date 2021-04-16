//
//  ADAlert.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/16.
//

import UIKit

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
