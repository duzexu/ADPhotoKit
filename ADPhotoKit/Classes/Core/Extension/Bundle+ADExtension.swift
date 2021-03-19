//
//  Bundle+ADExtension.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import Foundation

extension Bundle {
    
    static var photoKitBundle: Bundle? {
        return module
    }
    
    class func ad_LocalizedString(_ key: String) -> String {
        if self.locale_bundle == nil {
            guard let path = Bundle.photoKitBundle?.path(forResource: languageCode(), ofType: "lproj") else {
                return ""
            }
            self.locale_bundle = Bundle(path: path)
        }
        
        let value = self.locale_bundle?.localizedString(forKey: key, value: nil, table: nil)
        return Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }
    
    class func resetLocaleBundle() {
        locale_bundle = nil
    }
    
    private static var locale_bundle: Bundle? = nil
    
    private static var module: Bundle? = {
        let bundleName = "ADPhotoKit"

        var candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: ADPhotoManager.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]
        
        #if SWIFT_PACKAGE
        // For SWIFT_PACKAGE.
        candidates.append(Bundle.module.bundleURL)
        #endif

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        return nil
    }()
    
    private class func languageCode() -> String {
        var language = Locale.preferredLanguages.first ?? "en"
        
        if let locale = ADPhotoKitConfiguration.default.locale {
            language = locale.identifier
        }
        if language.hasPrefix("zh") {
            if language.range(of: "Hans") != nil {
                language = "zh-Hans"
            } else {
                language = "zh-Hant"
            }
        } else if language.hasPrefix("ja") {
            language = "ja-US"
        } else if language.hasPrefix("fr") {
            language = "fr"
        } else if language.hasPrefix("de") {
            language = "de"
        } else if language.hasPrefix("ru") {
            language = "ru"
        } else if language.hasPrefix("vi") {
            language = "vi"
        } else if language.hasPrefix("ko") {
            language = "ko"
        } else if language.hasPrefix("ms") {
            language = "ms"
        } else if language.hasPrefix("it") {
            language = "it"
        } else {
            language = "en"
        }
        return language
    }
    
}
