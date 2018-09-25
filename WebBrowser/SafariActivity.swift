//
//  SafariActivity.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/27.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

open class SafariActivity: UIActivity {
    open var url: URL?

    open override var activityType: UIActivity.ActivityType? {
        return ActivityType(String(describing: self))
    }

    open override var activityTitle : String? {
        return LocalizedString(key: "Open in Safari")
    }

    open override var activityImage : UIImage? {
        return WebBrowser.image(named: "safariIcon")
    }

    open override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for activityItem in activityItems {
            if let activityURL = activityItem as? URL {
                return UIApplication.shared.canOpenURL(activityURL)
            }
        }
        return false
    }

    open override func prepare(withActivityItems activityItems: [Any]) {
        for activityItem in activityItems {
            if let activityURL = activityItem as? URL {
                url = activityURL
            }
        }
    }

    open override func perform() {
        if let url = url {
            let completed = UIApplication.shared.openURL(url)
            activityDidFinish(completed)
        }
    }
}
