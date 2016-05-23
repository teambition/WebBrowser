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

    static var resourceBundleURL: NSURL? {
        let resourceBundleURL = NSBundle(forClass: WebBrowserViewController.self).URLForResource("WebBrowser", withExtension: "bundle")
        return resourceBundleURL
    }

    static func localizationPath(forIdentifier identifier: String) -> String? {
        if let  path = NSBundle(identifier: "Teambition.WebBrowser")?.pathForResource(identifier, ofType: "lproj") {
            return path
        } else if let resourceBundleURL = resourceBundleURL, resourceBundle = NSBundle(URL: resourceBundleURL) {
            return resourceBundle.pathForResource(identifier, ofType: "lproj")
        }
        return nil
    }

    static func image(named name: String) -> UIImage? {
        if let image = UIImage(named: name, inBundle: NSBundle(forClass: WebBrowserViewController.self), compatibleWithTraitCollection: nil) {
            return image
        } else if let resourceBundleURL = resourceBundleURL, resourceBundle = NSBundle(URL: resourceBundleURL) {
            return UIImage(named: name, inBundle: resourceBundle, compatibleWithTraitCollection: nil)
        }
        return nil
    }
}
