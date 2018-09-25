//
//  WebBrowserViewController.swift
//  WebBrowser
//
//  Created by Xin Hong on 16/4/26.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import WebKit

open class WebBrowserViewController: UIViewController {
    open weak var delegate: WebBrowserDelegate?
    open var language: WebBrowserLanguage = .english {
        didSet {
            InternationalControl.sharedControl.language = language
        }
    }
    open var tintColor = UIColor.blue {
        didSet {
            updateTintColor()
        }
    }
    open var barTintColor: UIColor? {
        didSet {
            updateBarTintColor()
        }
    }
    open var isToolbarHidden = false {
        didSet {
            navigationController?.setToolbarHidden(isToolbarHidden, animated: true)
        }
    }
    open var toolbarItemSpace = WebBrowser.defaultToolbarItemSpace {
        didSet {
            itemFixedSeparator.width = toolbarItemSpace
        }
    }
    open var isShowActionBarButton = true {
        didSet {
            updateToolBarState()
        }
    }
    open var customApplicationActivities = [UIActivity]()
    open var isShowURLInNavigationBarWhenLoading = true
    open var isShowPageTitleInNavigationBar = true

    fileprivate var webView = WKWebView(frame: CGRect.zero)
    fileprivate lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = .clear
        progressView.tintColor = self.tintColor
        return progressView
    }()
    fileprivate var previousNavigationControllerNavigationBarAppearance = NavigationBarAppearance()
    fileprivate var previousNavigationControllerToolbarAppearance = ToolbarAppearance()

    fileprivate lazy var refreshButton: UIBarButtonItem = {
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(WebBrowserViewController.refreshButtonTapped(_:)))
        return refreshButton
    }()
    fileprivate lazy var stopButton: UIBarButtonItem = {
        let stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(WebBrowserViewController.stopButtonTapped(_:)))
        return stopButton
    }()
    fileprivate lazy var backButton: UIBarButtonItem = {
        let backIcon = WebBrowser.image(named: "backIcon")
        let backButton = UIBarButtonItem(image: backIcon, style: .plain, target: self, action: #selector(WebBrowserViewController.backButtonTapped(_:)))
        return backButton
    }()
    fileprivate lazy var forwardButton: UIBarButtonItem = {
        let forwardIcon = WebBrowser.image(named: "forwardIcon")
        let forwardButton = UIBarButtonItem(image: forwardIcon, style: .plain, target: self, action: #selector(WebBrowserViewController.forwardButtonTapped(_:)))
        return forwardButton
    }()
    fileprivate lazy var actionButton: UIBarButtonItem = {
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(WebBrowserViewController.actionButtonTapped(_:)))
        return actionButton
    }()
    fileprivate lazy var itemFixedSeparator: UIBarButtonItem = {
        let itemFixedSeparator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        itemFixedSeparator.width = self.toolbarItemSpace
        return itemFixedSeparator
    }()
    fileprivate lazy var itemFlexibleSeparator: UIBarButtonItem = {
        let itemFlexibleSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        return itemFlexibleSeparator
    }()

    public var onOpenExternalAppHandler: ((_ isOpen: Bool) -> Void)?
    
    // MARK: - Life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()

        savePreviousNavigationControllerState()
        configureWebView()
        configureProgressView()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.addSubview(progressView)
        navigationController?.setToolbarHidden(isToolbarHidden, animated: true)

        progressView.alpha = 0
        updateTintColor()
        updateBarTintColor()
        updateToolBarState()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restorePreviousNavigationControllerState(animated: animated)
        progressView.removeFromSuperview()
    }

    public convenience init(configuration: WKWebViewConfiguration) {
        self.init()
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
    }

    open class func rootNavigationWebBrowser(webBrowser: WebBrowserViewController) -> UINavigationController {
        webBrowser.navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedString(key: "Done"), style: .done, target: webBrowser, action: #selector(WebBrowserViewController.doneButtonTapped(_:)))
        let navigationController = UINavigationController(rootViewController: webBrowser)
        return navigationController
    }

    deinit {
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
        if isViewLoaded {
            webView.removeObserver(self, forKeyPath: WebBrowser.estimatedProgressKeyPath)
        }
    }

    // MARK: - Public
    open func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }

    open func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    open func loadURLString(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        webView.load(URLRequest(url: url))
    }

    open func loadHTMLString(_ htmlString: String, baseURL: URL?) {
        webView.loadHTMLString(htmlString, baseURL: baseURL)
    }
}

extension WebBrowserViewController {
    // MARK: - Helper
    fileprivate func configureWebView() {
        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.autoresizesSubviews = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isMultipleTouchEnabled = true
        webView.scrollView.alwaysBounceVertical = true
        view.addSubview(webView)

        webView.addObserver(self, forKeyPath: WebBrowser.estimatedProgressKeyPath, options: .new, context: &WebBrowser.estimatedProgressContext)
    }

    fileprivate func configureProgressView() {
        let yPosition: CGFloat = {
            guard let navigationBar = self.navigationController?.navigationBar else {
                return 0
            }
            return navigationBar.frame.height - self.progressView.frame.height
        }()
        progressView.frame = CGRect(x: 0, y: yPosition, width: view.frame.width, height: progressView.frame.width)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    }

    fileprivate func savePreviousNavigationControllerState() {
        guard let navigationController = navigationController else {
            return
        }

        var navigationBarAppearance = NavigationBarAppearance(navigationBar: navigationController.navigationBar)
        navigationBarAppearance.isHidden = navigationController.isNavigationBarHidden
        previousNavigationControllerNavigationBarAppearance = navigationBarAppearance

        var toolbarAppearance = ToolbarAppearance(toolbar: navigationController.toolbar)
        toolbarAppearance.isHidden = navigationController.isToolbarHidden
        previousNavigationControllerToolbarAppearance = toolbarAppearance
    }

    fileprivate func restorePreviousNavigationControllerState(animated: Bool) {
        guard let navigationController = navigationController else {
            return
        }

        navigationController.setNavigationBarHidden(previousNavigationControllerNavigationBarAppearance.isHidden, animated: animated)
        navigationController.setToolbarHidden(previousNavigationControllerToolbarAppearance.isHidden, animated: animated)

        previousNavigationControllerNavigationBarAppearance.apply(to: navigationController.navigationBar)
        previousNavigationControllerToolbarAppearance.apply(to: navigationController.toolbar)
    }

    fileprivate func updateTintColor() {
        progressView.tintColor = tintColor
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.toolbar.tintColor = tintColor
    }

    fileprivate func updateBarTintColor() {
        navigationController?.navigationBar.barTintColor = barTintColor
        navigationController?.toolbar.barTintColor = barTintColor
    }
}

extension WebBrowserViewController {
    // MARK: - UIBarButtonItem actions
    @objc func refreshButtonTapped(_ sender: UIBarButtonItem) {
        webView.stopLoading()
        webView.reload()
    }

    @objc func stopButtonTapped(_ sender: UIBarButtonItem) {
        webView.stopLoading()
    }

    @objc func backButtonTapped(_ sender: UIBarButtonItem) {
        webView.goBack()
        updateToolBarState()
    }

    @objc func forwardButtonTapped(_ sender: UIBarButtonItem) {
        webView.goForward()
        updateToolBarState()
    }

    @objc func actionButtonTapped(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            var activityItems = [Any]()
            if let url = self.webView.url {
                activityItems.append(url)
            }
            var applicationActivities = [UIActivity]()
            applicationActivities.append(SafariActivity())
            applicationActivities.append(contentsOf: self.customApplicationActivities)

            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
            activityViewController.view.tintColor = self.tintColor

            if UIDevice.current.userInterfaceIdiom == .pad {
                activityViewController.popoverPresentationController?.barButtonItem = sender
                activityViewController.popoverPresentationController?.permittedArrowDirections = .any
                self.present(activityViewController, animated: true, completion: nil)
            } else {
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }

    @objc func doneButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.webBrowserWillDismiss(self)
        dismiss(animated: true) {
            self.delegate?.webBrowserDidDismiss(self)
        }
    }
}

extension WebBrowserViewController {
    // MARK: - Tool bar
    fileprivate func updateToolBarState() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward

        var barButtonItems = [UIBarButtonItem]()
        if webView.isLoading {
            barButtonItems = [backButton, itemFixedSeparator, forwardButton, itemFixedSeparator, stopButton, itemFlexibleSeparator]
            if let urlString = webView.url?.absoluteString, isShowURLInNavigationBarWhenLoading {
                var titleString = urlString.replacingOccurrences(of: "http://", with: "", options: .literal, range: nil)
                titleString = titleString.replacingOccurrences(of: "https://", with: "", options: .literal, range: nil)
                navigationItem.title = titleString
            }
        } else {
            barButtonItems = [backButton, itemFixedSeparator, forwardButton, itemFixedSeparator, refreshButton, itemFlexibleSeparator]
            if isShowPageTitleInNavigationBar {
                navigationItem.title = webView.title
            }
        }

        if isShowActionBarButton {
            barButtonItems.append(actionButton)
        }

        setToolbarItems(barButtonItems, animated: true)
    }
}

extension WebBrowserViewController {
    // MARK: - External app support
    fileprivate func externalAppRequiredToOpen(_ url: URL) -> Bool {
        let validSchemes: Set<String> = ["http", "https"]
        if let urlScheme = url.scheme {
            return !validSchemes.contains(urlScheme)
        } else {
            return false
        }
    }

    fileprivate func openExternalApp(with url: URL) {
        let externalAppPermissionAlert = UIAlertController(title: LocalizedString(key: "OpenExternalAppAlert.title"), message: LocalizedString(key: "OpenExternalAppAlert.message"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizedString(key: "Cancel"), style: .cancel, handler: { [weak self] (action) in
            self?.onOpenExternalAppHandler?(false)
        })
        let openAction = UIAlertAction(title: LocalizedString(key: "Open"), style: .default) { [weak self] (action) in
            UIApplication.shared.openURL(url)
            self?.onOpenExternalAppHandler?(true)
        }
        externalAppPermissionAlert.addAction(cancelAction)
        externalAppPermissionAlert.addAction(openAction)
        present(externalAppPermissionAlert, animated: true, completion: nil)
    }
}

extension WebBrowserViewController {
    // MARK: - Observer
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, (keyPath == WebBrowser.estimatedProgressKeyPath && context == &WebBrowser.estimatedProgressContext) {
            progressView.alpha = 1
            let animated = webView.estimatedProgress > Double(progressView.progress)
            progressView.setProgress(Float(webView.estimatedProgress), animated: animated)

            if webView.estimatedProgress >= 1 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                    }, completion: { (finished) in
                        self.progressView.progress = 0
                })
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension WebBrowserViewController: WKNavigationDelegate {
    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateToolBarState()
        delegate?.webBrowser(self, didStartLoad: webView.url)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateToolBarState()
        delegate?.webBrowser(self, didFinishLoad: webView.url)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        updateToolBarState()
        delegate?.webBrowser(self, didFailLoad: webView.url, withError: error)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateToolBarState()
        delegate?.webBrowser(self, didFailLoad: webView.url, withError: error)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let oriDelegate = delegate, oriDelegate.webBrowser(self, decidePolicyFor: navigationAction, decisionHandler: decisionHandler) {
            return
        }
        if let url = navigationAction.request.url {
            if !externalAppRequiredToOpen(url) {
                if navigationAction.targetFrame == nil {
                    loadURL(url)
                    decisionHandler(.cancel)
                    return
                }
            } else if UIApplication.shared.canOpenURL(url) {
                openExternalApp(with: url)
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }
}

extension WebBrowserViewController: WKUIDelegate {
    // MARK: - WKUIDelegate
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let mainFrame = navigationAction.targetFrame?.isMainFrame, mainFrame == false {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
