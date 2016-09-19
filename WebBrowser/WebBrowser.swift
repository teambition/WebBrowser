//
//  WebBrowser.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/27.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

internal struct WebBrowser {
    static let estimatedProgressKeyPath = "estimatedProgress"
    static var estimatedProgressContext = 0
    static let defaultToolbarItemSpace: CGFloat = 50

    static var resourceBundleURL: URL? {
        let resourceBundleURL = Bundle(for: WebBrowserViewController.self).url(forResource: "WebBrowser", withExtension: "bundle")
        return resourceBundleURL
    }

    static func localizationPath(forIdentifier identifier: String) -> String? {
        if let  path = Bundle(identifier: "Teambition.WebBrowser")?.path(forResource: identifier, ofType: "lproj") {
            return path
        } else if let resourceBundleURL = resourceBundleURL, let resourceBundle = Bundle(url: resourceBundleURL) {
            return resourceBundle.path(forResource: identifier, ofType: "lproj")
        }
        return nil
    }

    static func image(named name: String) -> UIImage? {
        if let image = UIImage(named: name, in: Bundle(for: WebBrowserViewController.self), compatibleWith: nil) {
            return image
        } else if let resourceBundleURL = resourceBundleURL, let resourceBundle = Bundle(url: resourceBundleURL) {
            return UIImage(named: name, in: resourceBundle, compatibleWith: nil)
        }
        return nil
    }
}
