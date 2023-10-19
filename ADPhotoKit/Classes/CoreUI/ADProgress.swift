//
//  ADProgress.swift
//  ADPhotoKit
//
//  Created by xu on 2021/12/20.
//

import Foundation
import UIKit

/// Used to indicator a time-consuming operation's progress.
public protocol ADProgressConfigurable where Self: UIView {
    
    /// Task progress.
    var progress: CGFloat { set get }
    
}

/// Used to indicator a time-consuming operation is in progress.
public protocol ADProgressHUDConfigurable where Self: UIView {
    
    /// Called when task timeout.
    var timeoutBlock: (() -> Void)? { set get }
    
    /// Show ProgressHUD.
    /// - Parameter timeout: The duration before the task is timeout. If set 0, view will not hide automatic.
    func show(timeout: TimeInterval)
    
    /// Dismiss ProgressHUD.
    func hide()
    
}

struct ADProgress {
    
    static func progressHUD() -> ADProgressHUDConfigurable {
        return ADPhotoKitConfiguration.default.customProgressHUDBlock?() ?? ADProgressHUD()
    }
    
    static func progress() -> ADProgressConfigurable {
        return ADPhotoKitConfiguration.default.customProgressBlock?() ?? ADProgressView()
    }
    
}
