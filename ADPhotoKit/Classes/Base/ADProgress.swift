//
//  ADProgress.swift
//  ADPhotoKit
//
//  Created by xu on 2021/12/20.
//

import Foundation

/// View use to show download or loading progress.
public typealias ADProgressableable = (UIView & ADProgressConfigurable)
/// Used to indicator a time-consuming operation's progress.
public protocol ADProgressConfigurable {
    
    /// Task progress.
    var progress: CGFloat { set get }
    
}

/// View showed when load albums and assets or request images from assets.
public typealias ADProgressHUDable = (UIView & ADProgressHUDConfigurable)
/// Used to indicator a time-consuming operation is in progress.
public protocol ADProgressHUDConfigurable {
    
    /// Called when task timeout.
    var timeoutBlock: (() -> Void)? { set get }
    
    /// Show ProgressHUD.
    /// - Parameter timeout: The duration before the task is timeout. If set 0, view will not hide automatic.
    func show(timeout: TimeInterval)
    
    /// Dismiss ProgressHUD.
    func hide()
    
}

struct ADProgress {
    
    static func progressHUD() -> ADProgressHUDable {
        return ADPhotoKitConfiguration.default.customProgressHUDBlock?() ?? ADProgressHUD()
    }
    
    static func progress() -> ADProgressableable {
        return ADPhotoKitConfiguration.default.customProgressBlock?() ?? ADProgressView()
    }
    
}
