//
//  WebBrowserExampleViewController.swift
//  WebBrowserExample
//
//  Created by Xin Hong on 16/4/26.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import WebBrowser

private let kTBBlueColor = UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)
private let kWebBrowserExampleCellID = "WebBrowserExampleCell"
private let URLStrings: [String] = ["https://www.apple.com/cn/",
                                    "https://github.com/teambition/WebBrowser",
                                    "https://www.teambition.com",
                                    "http://www.sina.com.cn",
                                    "http://www.qq.com",
                                    "http://www.163.com",
                                    "http://cn.bing.com/ditu/",
                                    "http://www.youku.com",
                                    "http://www.google.com",
                                    "https://www.facebook.com/",]
private let websiteTitles: [String] = ["Apple",
                                       "WebBrowser - Github",
                                       "Teambition",
                                       "新浪网",
                                       "腾讯网",
                                       "网易",
                                       "必应地图",
                                       "优酷",
                                       "Google",
                                       "Facebook"]

class WebBrowserExampleViewController: UITableViewController {
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Helper
    private func setupUI() {
        navigationItem.title = "WebBrowser Example"
        tableView.tableFooterView = UIView()
        tableView.tintColor = kTBBlueColor

        let backButton = UIBarButtonItem()
        backButton.title = " "
        navigationItem.backBarButtonItem = backButton
    }

    // MARK: - Table view data source and delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return URLStrings.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kWebBrowserExampleCellID)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: kWebBrowserExampleCellID)
        }
        cell?.textLabel?.text = websiteTitles[indexPath.row]
        cell?.textLabel?.textColor = UIColor(white: 38 / 255, alpha: 1)
        cell?.detailTextLabel?.text = URLStrings[indexPath.row]
        cell?.detailTextLabel?.textColor = kTBBlueColor
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let URL = NSURL(string: URLStrings[indexPath.row]) {
            let webBrowserViewController = WebBrowserViewController()
            webBrowserViewController.delegate = self

//            webBrowserViewController.barTintColor = UIColor.redColor()
//            webBrowserViewController.title = websiteTitles[indexPath.row]
//            webBrowserViewController.toolbarHidden = true
//            webBrowserViewController.showActionBarButton = false
//            webBrowserViewController.toolbarItemSpace = 80
//            webBrowserViewController.showURLInNavigationBarWhenLoading = false
//            webBrowserViewController.showsPageTitleInNavigationBar = false

            webBrowserViewController.language = .English
            webBrowserViewController.tintColor = kTBBlueColor
            webBrowserViewController.loadURL(URL)

//            let navigationWebBrowser = WebBrowserViewController.rootNavigationWebBrowser(webBrowser: webBrowserViewController)
//            presentViewController(navigationWebBrowser, animated: true, completion: nil)
            navigationController?.pushViewController(webBrowserViewController, animated: true)
        }
    }
}

extension WebBrowserExampleViewController: WebBrowserDelegate {
    func webBrowser(webBrowser: WebBrowserViewController, didStartLoadingURL URL: NSURL?) {
        print("Start loading...")
    }

    func webBrowser(webBrowser: WebBrowserViewController, didFinishLoadingURL URL: NSURL?) {
        print("Finish loading!")
    }

    func webBrowser(webBrowser: WebBrowserViewController, didFailToLoadURL URL: NSURL?, error: NSError) {
        print("Failed to load! \n error: \(error)")
    }

    func webBrowserWillDismiss(webBrowser: WebBrowserViewController) {

    }

    func webBrowserDidDismiss(webBrowser: WebBrowserViewController) {

    }
}
