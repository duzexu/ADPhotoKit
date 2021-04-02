//
//  ADPhotoKitConstant.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/2.
//

import Foundation

let isPad:Bool = { return UIDevice.current.userInterfaceIdiom == .pad }()
let isPhone:Bool = { return UIDevice.current.userInterfaceIdiom == .phone }()

let screenBounds:CGRect = { return UIScreen.main.bounds }()
let screenWidth:CGFloat = { return UIScreen.main.bounds.size.width }()
let screenHeight:CGFloat = { return UIScreen.main.bounds.size.height }()

///包含 iPhone12 mini
let isPhoneX:Bool = { return isPhone && screenHeight >= 812.0 }()

let tabBarOffset:CGFloat = { return isPhoneX ? 34.0:0.0 }()
