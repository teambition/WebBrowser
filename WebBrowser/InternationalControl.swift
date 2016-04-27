//
//  InternationalControl.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/27.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public enum WebBrowserLanguage {
    case English
    case SimplifiedChinese
    case TraditionalChinese
    case Korean
    case Japanese

    internal var identifier: String {
        switch self {
        case .English: return "en"
        case .SimplifiedChinese: return "zh-Hans"
        case .TraditionalChinese: return "zh-Hant"
        case .Korean: return "ko"
        case .Japanese: return "ja"
        }
    }
}

internal func LocalizedString(key key: String, comment: String? = nil) -> String {
    return InternationalControl.sharedControl.localizedString(key: key, comment: comment)
}

internal struct InternationalControl {
    internal static var sharedControl = InternationalControl()
    internal var language: WebBrowserLanguage = .English

    internal func localizedString(key key: String, comment: String? = nil) -> String {
        let path = NSBundle(identifier: "Teambition.WebBrowser")?.pathForResource(language.identifier, ofType: "lproj") ?? NSBundle.mainBundle().pathForResource(language.identifier, ofType: "lproj")
        guard let localizationPath = path else {
            return key
        }
        let bundle = NSBundle(path: localizationPath)
        return bundle?.localizedStringForKey(key, value: nil, table: "WebBrowser") ?? key
    }
}
