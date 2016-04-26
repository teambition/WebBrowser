//
//  WebBrowserViewController.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/26.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import WebKit

public class WebBrowserViewController: UIViewController {
    public weak var delegate: WebBrowserDelegate?
    public var tintColor = UIColor.blueColor()
    public private(set) var webView: WKWebView?

    private var progressView: UIProgressView?
}
