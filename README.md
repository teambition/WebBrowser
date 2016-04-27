#WebBrowser
A web browser using WebKit and written in Swift for iOS apps.

![Example](Gif/WebBrowserExample.gif "WebBrowserExample")

##How To Get Started
###Carthage
Specify "WebBrowser" in your ```Cartfile```:
```ogdl 
github "teambition/WebBrowser"
```

###Usage
##### Initialization
```swift
let webBrowserViewController = WebBrowserViewController(configuration: nil)
// assign delegate
webBrowserViewController.delegate = self

webBrowserViewController.language = .English
webBrowserViewController.tintColor = ...
webBrowserViewController.barTintColor = ...
webBrowserViewController.toolbarHidden = false
webBrowserViewController.showActionBarButton = true
webBrowserViewController.toolbarItemSpace = 50
webBrowserViewController.showURLInNavigationBarWhenLoading = true
webBrowserViewController.showsPageTitleInNavigationBar = true
webBrowserViewController.customApplicationActivities = ...

webBrowserViewController.loadURLString("https://www.apple.com/cn/")
```

##### Pushing to the navigation stack
```swift
navigationController?.pushViewController(webBrowserViewController, animated: true)
```

##### Presenting modally
```swift
let navigationWebBrowser = WebBrowserViewController.rootNavigationWebBrowser(webBrowser: webBrowserViewController)
presentViewController(navigationWebBrowser, animated: true, completion: nil)
```

#####  Implement the delegate
```swift
func webBrowser(webBrowser: WebBrowserViewController, didStartLoadingURL URL: NSURL?) {
    // do something
}

func webBrowser(webBrowser: WebBrowserViewController, didFinishLoadingURL URL: NSURL?) {
    // do something
}

func webBrowser(webBrowser: WebBrowserViewController, didFailToLoadURL URL: NSURL?, error: NSError) {
    // do something
}

func webBrowserWillDismiss(webBrowser: WebBrowserViewController) {
    // do something
}

func webBrowserDidDismiss(webBrowser: WebBrowserViewController) {
    // do something
}
```

## Minimum Requirement
iOS 8.0

##Localization
WebBrowser supports 5 languages: English, Simplified Chinese, Traditional Chinese, Korean, Japanese. You can set the language when initialization.

## Release Notes
* [Release Notes](https://github.com/teambition/WebBrowser/releases)

## License
WebBrowser is released under the MIT license. See [LICENSE](https://github.com/teambition/WebBrowser/blob/master/LICENSE.md) for details.

## More Info
Have a question? Please [open an issue](https://github.com/teambition/WebBrowser/issues/new)!
