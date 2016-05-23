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
    public var language: WebBrowserLanguage = .English {
        didSet {
            InternationalControl.sharedControl.language = language
        }
    }
    public var tintColor = UIColor.blueColor() {
        didSet {
            updateTintColor()
        }
    }
    public var barTintColor: UIColor? {
        didSet {
            updateBarTintColor()
        }
    }
    public var toolbarHidden = false {
        didSet {
            navigationController?.setToolbarHidden(toolbarHidden, animated: true)
        }
    }
    public var toolbarItemSpace = WebBrowser.defaultToolbarItemSpace {
        didSet {
            itemFixedSeparator.width = toolbarItemSpace
        }
    }
    public var showActionBarButton = true {
        didSet {
            updateToolBarState()
        }
    }
    public var customApplicationActivities = [UIActivity]()
    public var showURLInNavigationBarWhenLoading = true
    public var showsPageTitleInNavigationBar = true

    private var webView = WKWebView(frame: CGRect.zero)
    private lazy var progressView: UIProgressView = { [unowned self] in
        let progressView = UIProgressView(progressViewStyle: .Default)
        progressView.trackTintColor = UIColor.clearColor()
        progressView.tintColor = self.tintColor
        return progressView
    }()
    private var previousNavigationControllerNavigationBarAppearance = NavigationBarAppearance()
    private var previousNavigationControllerToolbarAppearance = ToolbarAppearance()

    private lazy var refreshButton: UIBarButtonItem = {
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(WebBrowserViewController.refreshButtonTapped(_:)))
        return refreshButton
    }()
    private lazy var stopButton: UIBarButtonItem = {
        let stopButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(WebBrowserViewController.stopButtonTapped(_:)))
        return stopButton
    }()
    private lazy var backButton: UIBarButtonItem = {
        let backIcon = UIImage(named: "backIcon", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil) ?? UIImage(named: "backIcon", inBundle: NSBundle.mainBundle(), compatibleWithTraitCollection: nil)
        let backButton = UIBarButtonItem(image: backIcon, style: .Plain, target: self, action: #selector(WebBrowserViewController.backButtonTapped(_:)))
        return backButton
    }()
    private lazy var forwardButton: UIBarButtonItem = {
        let forwardIcon = UIImage(named: "forwardIcon", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil) ?? UIImage(named: "forwardIcon", inBundle: NSBundle.mainBundle(), compatibleWithTraitCollection: nil)
        let forwardButton = UIBarButtonItem(image: forwardIcon, style: .Plain, target: self, action: #selector(WebBrowserViewController.forwardButtonTapped(_:)))
        return forwardButton
    }()
    private lazy var actionButton: UIBarButtonItem = {
        let actionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(WebBrowserViewController.actionButtonTapped(_:)))
        return actionButton
    }()
    private lazy var itemFixedSeparator: UIBarButtonItem = { [unowned self] in
        let itemFixedSeparator = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        itemFixedSeparator.width = self.toolbarItemSpace
        return itemFixedSeparator
    }()
    private lazy var itemFlexibleSeparator: UIBarButtonItem = {
        let itemFlexibleSeparator = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        return itemFlexibleSeparator
    }()

    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        savePreviousNavigationControllerState()
        configureWebView()
        configureProgressView()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.addSubview(progressView)
        navigationController?.setToolbarHidden(toolbarHidden, animated: true)

        progressView.alpha = 0
        updateTintColor()
        updateBarTintColor()
        updateToolBarState()
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        restorePreviousNavigationControllerState(animated: animated)
        progressView.removeFromSuperview()
    }

    public convenience init(configuration: WKWebViewConfiguration) {
        self.init()
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
    }

    public class func rootNavigationWebBrowser(webBrowser webBrowser: WebBrowserViewController) -> UINavigationController {
        webBrowser.navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedString(key: "Done"), style: .Done, target: webBrowser, action: #selector(WebBrowserViewController.doneButtonTapped(_:)))
        let navigationController = UINavigationController(rootViewController: webBrowser)
        return navigationController
    }

    deinit {
        webView.UIDelegate = nil
        webView.navigationDelegate = nil
        if isViewLoaded() {
            webView.removeObserver(self, forKeyPath: WebBrowser.estimatedProgressKeyPath)
        }
    }

    // MARK: - Public
    public func loadRequest(request: NSURLRequest) {
        webView.loadRequest(request)
    }

    public func loadURL(URL: NSURL) {
        webView.loadRequest(NSURLRequest(URL: URL))
    }

    public func loadURLString(URLString: String) {
        guard let URL = NSURL(string: URLString) else {
            return
        }
        webView.loadRequest(NSURLRequest(URL: URL))
    }

    public func loadHTMLString(HTMLString: String, baseURL: NSURL?) {
        webView.loadHTMLString(HTMLString, baseURL: baseURL)
    }
}

extension WebBrowserViewController {
    // MARK: - Helper
    private func configureWebView() {
        webView.frame = view.bounds
        webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        webView.autoresizesSubviews = true
        webView.navigationDelegate = self
        webView.UIDelegate = self
        webView.multipleTouchEnabled = true
        webView.scrollView.alwaysBounceVertical = true
        view.addSubview(webView)

        webView.addObserver(self, forKeyPath: WebBrowser.estimatedProgressKeyPath, options: .New, context: &WebBrowser.estimatedProgressContext)
    }

    private func configureProgressView() {
        let yPosition: CGFloat = { [unowned self] in
            guard let navigationBar = self.navigationController?.navigationBar else {
                return 0
            }
            return navigationBar.frame.height - self.progressView.frame.height
        }()
        progressView.frame = CGRect(x: 0, y: yPosition, width: view.frame.width, height: progressView.frame.width)
        progressView.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
    }

    private func savePreviousNavigationControllerState() {
        guard let navigationController = navigationController else {
            return
        }

        var navigationBarAppearance = NavigationBarAppearance(navigationBar: navigationController.navigationBar)
        navigationBarAppearance.hidden = navigationController.navigationBarHidden
        previousNavigationControllerNavigationBarAppearance = navigationBarAppearance

        var toolbarAppearance = ToolbarAppearance(toolbar: navigationController.toolbar)
        toolbarAppearance.hidden = navigationController.toolbarHidden
        previousNavigationControllerToolbarAppearance = toolbarAppearance
    }

    private func restorePreviousNavigationControllerState(animated animated: Bool) {
        guard let navigationController = navigationController else {
            return
        }

        navigationController.setNavigationBarHidden(previousNavigationControllerNavigationBarAppearance.hidden, animated: animated)
        navigationController.setToolbarHidden(previousNavigationControllerToolbarAppearance.hidden, animated: animated)

        previousNavigationControllerNavigationBarAppearance.applyToNavigationBar(navigationController.navigationBar)
        previousNavigationControllerToolbarAppearance.applyToToolbar(navigationController.toolbar)
    }

    private func updateTintColor() {
        progressView.tintColor = tintColor
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.toolbar.tintColor = tintColor
    }

    private func updateBarTintColor() {
        navigationController?.navigationBar.barTintColor = barTintColor
        navigationController?.toolbar.barTintColor = barTintColor
    }
}

extension WebBrowserViewController {
    // MARK: - UIBarButtonItem actions
    func refreshButtonTapped(sender: UIBarButtonItem) {
        webView.stopLoading()
        webView.reload()
    }

    func stopButtonTapped(sender: UIBarButtonItem) {
        webView.stopLoading()
    }

    func backButtonTapped(sender: UIBarButtonItem) {
        webView.goBack()
        updateToolBarState()
    }

    func forwardButtonTapped(sender: UIBarButtonItem) {
        webView.goForward()
        updateToolBarState()
    }

    func actionButtonTapped(sender: UIBarButtonItem) {
        dispatch_async(dispatch_get_main_queue()) {
            var activityItems = [AnyObject]()
            if let URL = self.webView.URL {
                activityItems.append(URL)
            }
            var applicationActivities = [UIActivity]()
            applicationActivities.append(SafariActivity())
            applicationActivities.appendContentsOf(self.customApplicationActivities)

            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
            activityViewController.view.tintColor = self.tintColor

            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                activityViewController.popoverPresentationController?.barButtonItem = sender
                activityViewController.popoverPresentationController?.permittedArrowDirections = .Any
                self.presentViewController(activityViewController, animated: true, completion: nil)
            } else {
                self.presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }

    func doneButtonTapped(sender: UIBarButtonItem) {
        delegate?.webBrowserWillDismiss(self)
        dismissViewControllerAnimated(true) {
            self.delegate?.webBrowserDidDismiss(self)
        }
    }
}

extension WebBrowserViewController {
    // MARK: - Tool bar
    private func updateToolBarState() {
        backButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward

        var barButtonItems = [UIBarButtonItem]()
        if webView.loading {
            barButtonItems = [backButton, itemFixedSeparator, forwardButton, itemFixedSeparator, stopButton, itemFlexibleSeparator]
            if let URLString = webView.URL?.absoluteString where showURLInNavigationBarWhenLoading {
                var titleString = URLString.stringByReplacingOccurrencesOfString("http://", withString: "", options: .LiteralSearch, range: nil)
                titleString = titleString.stringByReplacingOccurrencesOfString("https://", withString: "", options: .LiteralSearch, range: nil)
                navigationItem.title = titleString
            }
        } else {
            barButtonItems = [backButton, itemFixedSeparator, forwardButton, itemFixedSeparator, refreshButton, itemFlexibleSeparator]
            if showsPageTitleInNavigationBar {
                navigationItem.title = webView.title
            }
        }

        if showActionBarButton {
            barButtonItems.append(actionButton)
        }

        setToolbarItems(barButtonItems, animated: true)
    }
}

extension WebBrowserViewController {
    // MARK: - External app support
    private func externalAppRequiredToOpenURL(URL: NSURL) -> Bool {
        let validSchemes: Set<String> = ["http", "https"]
        return !validSchemes.contains(URL.scheme)
    }

    private func openExternalAppWithURL(URL: NSURL) {
        let externalAppPermissionAlert = UIAlertController(title: LocalizedString(key: "OpenExternalAppAlert.title"), message: LocalizedString(key: "OpenExternalAppAlert.message"), preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: LocalizedString(key: "Cancel"), style: .Cancel, handler: nil)
        let openAction = UIAlertAction(title: LocalizedString(key: "Open"), style: .Default) { (action) in
            UIApplication.sharedApplication().openURL(URL)
        }
        externalAppPermissionAlert.addAction(cancelAction)
        externalAppPermissionAlert.addAction(openAction)
        presentViewController(externalAppPermissionAlert, animated: true, completion: nil)
    }
}

extension WebBrowserViewController {
    // MARK: - Observer
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath where (keyPath == WebBrowser.estimatedProgressKeyPath && context == &WebBrowser.estimatedProgressContext) {
            progressView.alpha = 1
            let animated = webView.estimatedProgress > Double(progressView.progress)
            progressView.setProgress(Float(webView.estimatedProgress), animated: animated)

            if webView.estimatedProgress >= 1 {
                UIView.animateWithDuration(0.3, delay: 0.3, options: .CurveEaseOut, animations: {
                    self.progressView.alpha = 0
                    }, completion: { (finished) in
                        self.progressView.progress = 0
                })
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}

extension WebBrowserViewController: WKNavigationDelegate {
    // MARK: - WKNavigationDelegate
    public func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateToolBarState()
        delegate?.webBrowser(self, didStartLoadingURL: webView.URL)
    }

    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        updateToolBarState()
        delegate?.webBrowser(self, didFinishLoadingURL: webView.URL)
    }

    public func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        updateToolBarState()
        delegate?.webBrowser(self, didFailToLoadURL: webView.URL, error: error)
    }

    public func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        updateToolBarState()
        delegate?.webBrowser(self, didFailToLoadURL: webView.URL, error: error)
    }

    public func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let URL = navigationAction.request.URL {
            if !externalAppRequiredToOpenURL(URL) {
                if navigationAction.targetFrame == nil {
                    loadURL(URL)
                    decisionHandler(.Cancel)
                    return
                }
            } else if UIApplication.sharedApplication().canOpenURL(URL) {
                openExternalAppWithURL(URL)
                decisionHandler(.Cancel)
                return
            }
        }

        decisionHandler(.Allow)
    }
}

extension WebBrowserViewController: WKUIDelegate {
    // MARK: - WKUIDelegate
    public func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let mainFrame = navigationAction.targetFrame?.mainFrame where mainFrame == false {
            webView.loadRequest(navigationAction.request)
        }
        return nil
    }
}
