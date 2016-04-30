//
//  NavigationBarAppearance.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/30.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

internal struct NavigationBarAppearance {
    var hidden = false
    var tintColor = UIColor.blueColor()
    var barTintColor: UIColor?
    var translucent = true
    var shadowImage: UIImage?
    var backgroundImageForBarMetricsDefault: UIImage?
    var backgroundImageForBarMetricsCompact: UIImage?

    init() { }

    init(navigationBar: UINavigationBar) {
        tintColor = navigationBar.tintColor
        barTintColor = navigationBar.barTintColor
        translucent = navigationBar.translucent
        shadowImage = navigationBar.shadowImage
        backgroundImageForBarMetricsDefault = navigationBar.backgroundImageForBarMetrics(.Default)
        backgroundImageForBarMetricsCompact = navigationBar.backgroundImageForBarMetrics(.Compact)
    }

    func applyToNavigationBar(navigationBar: UINavigationBar) {
        navigationBar.tintColor = tintColor
        navigationBar.barTintColor = barTintColor
        navigationBar.translucent = translucent
        navigationBar.shadowImage = shadowImage
        navigationBar.setBackgroundImage(backgroundImageForBarMetricsDefault, forBarMetrics: .Default)
        navigationBar.setBackgroundImage(backgroundImageForBarMetricsCompact, forBarMetrics: .Compact)
    }
}
