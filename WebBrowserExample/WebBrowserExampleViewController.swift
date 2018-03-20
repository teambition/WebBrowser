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
private let urlStrings: [String] = ["https://www.apple.com/cn/",
                                    "https://github.com/teambition/WebBrowser",
                                    "https://www.teambition.com",
                                    "http://www.sina.com.cn",
                                    "http://www.qq.com",
                                    "http://www.163.com",
                                    "http://cn.bing.com/ditu/",
                                    "http://www.youku.com",
                                    "http://www.google.com",
                                    "https://www.facebook.com/",
                                    "mailto:zi@123.com"]
private let websiteTitles: [String] = ["Apple",
                                       "WebBrowser - Github",
                                       "Teambition",
                                       "新浪网",
                                       "腾讯网",
                                       "网易",
                                       "必应地图",
                                       "优酷",
                                       "Google",
                                       "Facebook",
                                        "邮箱"]

class WebBrowserExampleViewController: UITableViewController {
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Helper
    fileprivate func setupUI() {
        navigationItem.title = "WebBrowser Example"
        tableView.tableFooterView = UIView()
        tableView.tintColor = kTBBlueColor

        let backButton = UIBarButtonItem()
        backButton.title = " "
        navigationItem.backBarButtonItem = backButton
    }

    // MARK: - Table view data source and delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urlStrings.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kWebBrowserExampleCellID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: kWebBrowserExampleCellID)
        }
        cell?.textLabel?.text = websiteTitles[indexPath.row]
        cell?.textLabel?.textColor = UIColor(white: 38 / 255, alpha: 1)
        cell?.detailTextLabel?.text = urlStrings[indexPath.row]
        cell?.detailTextLabel?.textColor = kTBBlueColor
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let url = URL(string: urlStrings[indexPath.row]) {
            let webBrowserViewController = WebBrowserViewController()
            webBrowserViewController.delegate = self

            webBrowserViewController.onOpenExternalAppHandler = { [weak self] _ in
                guard let `self` = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            
            webBrowserViewController.language = .simplifiedChinese
            webBrowserViewController.tintColor = kTBBlueColor
            webBrowserViewController.loadURL(url)

            navigationController?.pushViewController(webBrowserViewController, animated: true)
        }
    }
}

extension WebBrowserExampleViewController: WebBrowserDelegate {
    func webBrowser(_ webBrowser: WebBrowserViewController, didStartLoad url: URL?) {
        print("Start loading...")
    }

    func webBrowser(_ webBrowser: WebBrowserViewController, didFinishLoad url: URL?) {
        print("Finish loading!")
    }

    func webBrowser(_ webBrowser: WebBrowserViewController, didFailLoad url: URL?, withError error: Error) {
        print("Failed to load! \n error: \(error)")
    }

    func webBrowserWillDismiss(_ webBrowser: WebBrowserViewController) {

    }

    func webBrowserDidDismiss(_ webBrowser: WebBrowserViewController) {

    }
}
