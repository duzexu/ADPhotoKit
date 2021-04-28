# ADPhotoKit

[![CI Status](https://img.shields.io/travis/zexu007@qq.com/ADPhotoKit.svg?style=flat)](https://travis-ci.org/zexu007@qq.com/ADPhotoKit)
[![Version](https://img.shields.io/cocoapods/v/ADPhotoKit.svg?style=flat)](https://cocoapods.org/pods/ADPhotoKit)
[![License](https://img.shields.io/cocoapods/l/ADPhotoKit.svg?style=flat)](https://cocoapods.org/pods/ADPhotoKit)
[![Platform](https://img.shields.io/cocoapods/p/ADPhotoKit.svg?style=flat)](https://cocoapods.org/pods/ADPhotoKit)

ADPhotoKit is a pure-Swift library to select assets (e.g. photo,video,gif,livephoto) from system album.

### Features

* [ ] 

### Usage

```swift
ADPhotoKitUI.imagePicker(present: self) { (assets, origin) in
    // do something
}
```

## Learn More

To lean more use of ADPhotoKit, take a look at the example.

## Requirements

* iOS 10.0
* Swift 5.0+

### Installation

ADPhotoKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
source 'https://cdn.cocoapods.org/'
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
  pod 'ADPhotoKit'
end
```

<font color=#B30E44>**You need to add the following key-value pairs in your app's Info.plist**</font>

```swift
// If you don’t add this key-value pair, multiple languages are not supported, and the system PhotoKitUI language defaults to English
Localized resources can be mixed   YES
// You must add follow in your app's Info.plist
Privacy - Photo Library Usage Description
// If you `assetOpts` contain `allowTakePhotoAsset`, you must add follow
Privacy - Camera Usage Description
// If you `assetOpts` contain `allowTakeVideoAsset`, you must add follow
Privacy - Microphone Usage Description
```
### Thanks

Some code and resource are copy from **ZLPhotoBrowser**

## License

ADPhotoKit is available under the MIT license. See the LICENSE file for more info.
