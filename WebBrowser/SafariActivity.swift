//
//  SafariActivity.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/27.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

public class SafariActivity: UIActivity {
    public var URL: NSURL?

    public override func activityType() -> String? {
        return NSStringFromClass(self.dynamicType)
    }

    public override func activityTitle() -> String? {
        return LocalizedString(key: "Open in Safari")
    }

    public override func activityImage() -> UIImage? {
        return UIImage(named: "safariIcon", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
    }

    public override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for activityItem in activityItems {
            if let activityURL = activityItem as? NSURL {
                return UIApplication.sharedApplication().canOpenURL(activityURL)
            }
        }
        return false
    }

    public override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for activityItem in activityItems {
            if let activityURL = activityItem as? NSURL {
                URL = activityURL
            }
        }
    }

    public override func performActivity() {
        if let URL = URL {
            let completed = UIApplication.sharedApplication().openURL(URL)
            activityDidFinish(completed)
        }
    }
}
