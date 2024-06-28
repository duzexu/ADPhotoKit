//
//  LanguageViewController.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/4/29.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit
import ProgressHUD

class LanguageViewController: UITableViewController {
    
    enum Language: CaseIterable {
        case system
        case chineseSimplified
        case chineseTraditional
        case english
        case japanese
        case french
        case german
        case russian
        case vietnamese
        case korean
        case malay
        case italian
        case indonesian
        case portuguese
        case spanish
        case turkish
        case arabic
        case dutch
    }
    
    let dataSource: [Language] = Language.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
}

extension LanguageViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanugageCell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].desc
        if ADPhotoKitConfiguration.default.locale?.identifier == dataSource[indexPath.row].code {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let code = dataSource[indexPath.row].code {
            ADPhotoKitConfiguration.default.locale = Locale(identifier: code)
        }else{
            ADPhotoKitConfiguration.default.locale = nil
        }
        tableView.reloadData()
        ProgressHUD.showSuccess("Update Success!")
    }
}

extension LanguageViewController.Language {
    
    var desc: String {
        switch self {
        case .system:
            return "System"
        case .english:
            return "English"
        case .chineseSimplified:
            return "中文简体 (Chinese Simplified)"
        case .chineseTraditional:
            return "中文繁体 (Chinese Traditional)"
        case .japanese:
            return "日本語 (Japanese)"
        case .french:
            return "Français (French)"
        case .german:
            return "Deutsch (German)"
        case .russian:
            return "Pусский (Russian)"
        case .vietnamese:
            return "Tiếng Việt (Vietnamese)"
        case .korean:
            return "한국어 (Korean)"
        case .malay:
            return "Bahasa Melayu (Malay)"
        case .italian:
            return "Italiano (Italian)"
        case .indonesian:
            return "Bahasa Indonesia (Indonesian)"
        case .portuguese:
            return "Português (Portuguese)"
        case .spanish:
            return "Español (Spanish)"
        case .turkish:
            return "Türkçe (Turkish)"
        case .arabic:
            return "عربي (Arabic)"
        case .dutch:
            return "Nederlands (Dutch)"
        }
    }
    
    var code: String? {
        switch self {
        case .system:
            return nil
        case .english:
            return "en"
        case .chineseSimplified:
            return "zh-Hans"
        case .chineseTraditional:
            return "zh-Hant"
        case .japanese:
            return "ja-US"
        case .french:
            return "fr"
        case .german:
            return "de"
        case .russian:
            return "ru"
        case .vietnamese:
            return "vi"
        case .korean:
            return "ko"
        case .malay:
            return "ms"
        case .italian:
            return "it"
        case .indonesian:
            return "id"
        case .portuguese:
            return "pt-BR"
        case .spanish:
            return "es-419"
        case .turkish:
            return "tr"
        case .arabic:
            return "ar"
        case .dutch:
            return "nl"
        }
    }
    
}
