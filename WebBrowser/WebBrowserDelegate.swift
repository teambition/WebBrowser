//
//  WebBrowserDelegate.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/26.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

public protocol WebBrowserDelegate: class {
    func webBrowser(_ webBrowser: WebBrowserViewController, didStartLoad url: URL?)
    func webBrowser(_ webBrowser: WebBrowserViewController, didFinishLoad url: URL?)
    func webBrowser(_ webBrowser: WebBrowserViewController, didFailLoad url: URL?, withError error: Error)

    func webBrowserWillDismiss(_ webBrowser: WebBrowserViewController)
    func webBrowserDidDismiss(_ webBrowser: WebBrowserViewController)
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
}
