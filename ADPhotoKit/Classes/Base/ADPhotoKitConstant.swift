//
//  ADPhotoKitConstant.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/2.
//

import Foundation
import UIKit

let appName:String = {
    if let name = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
        return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
        return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
        return name
    }
    return "App"
}()

let isPad:Bool = { return UIDevice.current.userInterfaceIdiom == .pad }()
let isPhone:Bool = { return UIDevice.current.userInterfaceIdiom == .phone }()

let screenBounds:CGRect = { return UIScreen.main.bounds }()
let screenWidth:CGFloat = { return UIScreen.main.bounds.size.width }()
let screenHeight:CGFloat = { return UIScreen.main.bounds.size.height }()

/// 包含 iPhone12 mini
let isPhoneXOrLater:Bool = { return isPhone && screenHeight >= 812.0 }()

let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
let topBarHeight: CGFloat = statusBarHeight + 44

let tabBarOffset: CGFloat = { return isPhoneXOrLater ? 34.0:0.0 }()

let safeAreaInsets:UIEdgeInsets = {
    if #available(iOS 11, *) {
        return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
    return .zero
}()

let isNotchScreen:Bool = { return safeAreaInsets.top > 0 }();
