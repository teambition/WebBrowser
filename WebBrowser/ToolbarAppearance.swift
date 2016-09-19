//
//  ToolbarAppearance.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/30.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

internal struct ToolbarAppearance {
    var isHidden = true
    var tintColor = UIColor.blue
    var barTintColor: UIColor?
    var isTranslucent = true

    init() { }

    init(toolbar: UIToolbar) {
        tintColor = toolbar.tintColor
        barTintColor = toolbar.barTintColor
        isTranslucent = toolbar.isTranslucent
    }

    func apply(to toolbar: UIToolbar) {
        toolbar.tintColor = tintColor
        toolbar.barTintColor = barTintColor
        toolbar.isTranslucent = isTranslucent
    }
}
