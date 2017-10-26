//
//  WebBrowserDelegate.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/26.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import WebKit

public protocol WebBrowserDelegate: class {
    func webBrowser(_ webBrowser: WebBrowserViewController, didStartLoad url: URL?)
    func webBrowser(_ webBrowser: WebBrowserViewController, didFinishLoad url: URL?)
    func webBrowser(_ webBrowser: WebBrowserViewController, didFailLoad url: URL?, withError error: Error)

    func webBrowserWillDismiss(_ webBrowser: WebBrowserViewController)
    func webBrowserDidDismiss(_ webBrowser: WebBrowserViewController)
    func webBrowser(_ webBrowser: WebBrowserViewController, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> Bool
}

public extension WebBrowserDelegate {
    func webBrowser(_ webBrowser: WebBrowserViewController, didStartLoad url: URL?) {

    }

    func webBrowser(_ webBrowser: WebBrowserViewController, didFinishLoad url: URL?) {

    }

    func webBrowser(_ webBrowser: WebBrowserViewController, didFailLoad url: URL?, withError error: Error) {

    }

    func webBrowserWillDismiss(_ webBrowser: WebBrowserViewController) {

    }

    func webBrowserDidDismiss(_ webBrowser: WebBrowserViewController) {

    }
    
    func webBrowser(_ webBrowser: WebBrowserViewController, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> Bool {
        return false
    }
}
