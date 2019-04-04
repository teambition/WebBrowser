Pod::Spec.new do |s|

  s.name                 = "WebBrowser"
  s.version              = "0.1.5"
  s.summary              = "A web browser using WebKit and written in Swift for iOS apps."

  s.homepage             = "https://github.com/teambition/WebBrowser"
  s.license              = { :type => "MIT", :file => "LICENSE.md" }
  s.author               = "Xin Hong"

  s.source               = { :git => "https://github.com/teambition/WebBrowser.git", :tag => s.version.to_s }
  s.source_files         = "WebBrowser/*.swift"
  s.resource_bundles     = { 'WebBrowser' => ['WebBrowser/Resources/WebBrowser.xcassets', 'WebBrowser/Resources/*/*.lproj'] }

  s.platform             = :ios, "8.0"
  s.requires_arc         = true

  s.frameworks           = "Foundation", "UIKit"

end
