//
//  InternationalControl.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/27.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public enum WebBrowserLanguage {
    case english
    case simplifiedChinese
    case traditionalChinese
    case korean
    case japanese

    internal var identifier: String {
        switch self {
        case .english: return "en"
        case .simplifiedChinese: return "zh-Hans"
        case .traditionalChinese: return "zh-Hant"
        case .korean: return "ko"
        case .japanese: return "ja"
        }
    }
}

internal func LocalizedString(key: String, comment: String? = nil) -> String {
    return InternationalControl.sharedControl.localizedString(key: key, comment: comment)
}

internal struct InternationalControl {
    internal static var sharedControl = InternationalControl()
    internal var language: WebBrowserLanguage = .english

    internal func localizedString(key: String, comment: String? = nil) -> String {
        guard let localizationPath = WebBrowser.localizationPath(forIdentifier: language.identifier) else {
            return key
        }
        let bundle = Bundle(path: localizationPath)
        return bundle?.localizedString(forKey: key, value: nil, table: "WebBrowser") ?? key
    }
}
