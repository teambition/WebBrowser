//
//  WebBrowserDelegate.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/26.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

public protocol WebBrowserDelegate: class {
    func webBrowser(webBrowser: WebBrowserViewController, didStartLoadingURL URL: NSURL)
    func webBrowser(webBrowser: WebBrowserViewController, didFinishLoadingURL URL: NSURL)
    func webBrowser(webBrowser: WebBrowserViewController, didFailToLoadURL URL: NSURL, error: NSError)
}
