//
//  ADPhotoKitConfiguration.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import Foundation

public class ADPhotoKitConfiguration {
    
    public static var `default` = ADPhotoKitConfiguration()
    
    /// 指定语言
    public var locale: Locale? {
        didSet {
            Bundle.resetLocaleBundle()
        }
    }
    
    /// 自定义语言文案
    public var customLocaleValue: [Locale:[ADLocale.LocaleKey: String]]?
    
    /// 自定义相簿顺序 默认 ADAlbumType.allCases 顺序
    public var customAlbumOrders: [ADAlbumType]?
    
    #if Module_UI
    
    /// When slide select is active, will auto scroll to top or bottom when your finger at the top or bottom. Defaults to true.
    public var autoScrollWhenSlideSelectIsActive = true
    
    /// The max speed (pt/s) of auto scroll. Defaults to 600.
    public var autoScrollMaxSpeed: CGFloat = 600
    
    #endif

}
