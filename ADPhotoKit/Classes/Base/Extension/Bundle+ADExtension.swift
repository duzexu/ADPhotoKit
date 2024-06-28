//
//  Bundle+ADExtension.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import Foundation
import UIKit

extension Bundle {
    
    static var baseBundle: Bundle? = Bundle.bundle(name: "ADPhotoKitBase", cls: ADPhotoKitConfiguration.self)
    
    #if Module_UI
    static var coreUIBundle: Bundle? = Bundle.bundle(name: "ADPhotoKitCoreUI", cls: ADPhotoKitUI.self)
    #endif
    
    #if Module_ImageEdit
    static var imageEditBundle: Bundle? = Bundle.bundle(name: "ADPhotoKitImageEdit", cls: ADImageEditController.self)
    #endif
    
    enum Module {
        case coreUI
        case imageEdit
    }
    
    static func image(name: String, module: Module = .coreUI) -> UIImage? {
        switch module {
        case .coreUI:
            #if Module_UI
            let bundle = ADPhotoKitConfiguration.default.customCoreUIBundle
            return bundle?.image(name: name) ?? coreUIBundle?.image(name: name)
            #else
            return nil
            #endif
        case .imageEdit:
            #if Module_ImageEdit
            let bundle = ADPhotoKitConfiguration.default.customImageEditBundle
            return bundle?.image(name: name) ?? imageEditBundle?.image(name: name)
            #else
            return nil
            #endif
        }
    }
}

// MARK: - Localized
extension Bundle {
    
    class func localizedString(_ key: String) -> String {
        if self.locale_bundle == nil {
            guard let path = Bundle.baseBundle?.path(forResource: languageCode(), ofType: "lproj") else {
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
        } else if language.hasPrefix("id") {
            language = "id"
        } else if language.hasPrefix("pt") {
            language = "pt-BR"
        } else if language.hasPrefix("es") {
            language = "es-419"
        } else if language.hasPrefix("tr") {
            language = "tr"
        } else if language.hasPrefix("ar") {
            language = "ar"
        } else if language.hasPrefix("nl") {
            language = "nl"
        } else {
            language = "en"
        }
        return language
    }
}

extension Bundle {
    
    static func bundle(name: String, cls: AnyClass) -> Bundle? {
        var candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: cls).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]
        
        #if SWIFT_PACKAGE
        // For SWIFT_PACKAGE.
        candidates.append(Bundle.module.bundleURL)
        #endif

        for candidate in candidates {
            let bundlePath: URL? = candidate?.absoluteString.range(of: ".bundle") == nil ? candidate?.appendingPathComponent(name + ".bundle") : candidate
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        return nil
    }
    
    func image(name: String) -> UIImage? {
        var path = self.bundlePath
        path.append("/\(name)")
        return UIImage(named: path)
    }
    
}
