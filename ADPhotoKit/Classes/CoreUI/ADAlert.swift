//
//  ADAlert.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/16.
//

import UIKit

public enum ADAlertAction {
    case `default`(String)
    case cancel(String)
    case destructive(String)
}

public extension ADAlertAction {
    var title: String {
        switch self {
        case let .default(s):
            return s
        case let .cancel(s):
            return s
        case let .destructive(s):
            return s
        }
    }
}

/// Protocol use to show alert.
public protocol ADAlertConfigurable {
    
    /// Show alert on controller.
    /// - Parameters:
    ///   - on: The controller to show alert.
    ///   - title: Alert title.
    ///   - message: Alert message.
    ///   - actions: Alert actions.
    ///   - completion: Called when button click.
    static func alert(on: UIViewController, title: String?, message: String, actions: [ADAlertAction], completion: ((Int)->Void)?)
        
}

class ADAlert: ADAlertConfigurable {

    static func alert(on: UIViewController, title: String?, message: String, actions: [ADAlertAction], completion: ((Int)->Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, item) in actions.enumerated() {
            let action = UIAlertAction(title: item.title, style: item.uiActionStyle) { (_) in
                completion?(index)
            }
            alert.addAction(action)
        }
        on.present(alert, animated: true, completion: nil)
    }

}

extension ADAlertAction {
    var uiActionStyle: UIAlertAction.Style {
        switch self {
        case .default(_):
            return .default
        case .cancel(_):
            return .cancel
        case .destructive(_):
            return .destructive
        }
    }
}

extension ADAlert {
    
    static func alert() -> ADAlertConfigurable.Type {
        return ADPhotoKitConfiguration.default.customAlert ?? ADAlert.self
    }
    
}
