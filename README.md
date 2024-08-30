<p align="center">
<img src="https://raw.githubusercontent.com/duzexu/ADPhotoKit/master/ADPhotoKit/ADPhotoKit.docc/Resources/logo@3x.png" alt="ADPhotoKit" title="ADPhotoKit" width="557"/>
</p>

<p align="center">
<a href="https://swift.org/"><img src="https://img.shields.io/badge/Language-%20Swift%20-E57141.svg"></a>
<a href="https://duzexu.github.io/ADPhotoKit/"><img src="https://img.shields.io/cocoapods/p/ADPhotoKit.svg?style=flat"></a>
<a href="https://duzexu.github.io/ADPhotoKit/"><img src="https://img.shields.io/badge/Swift-Doc-DE5C43.svg?style=flat"></a>
<a href="https://cocoapods.org/pods/ADPhotoKit"><img src="https://img.shields.io/cocoapods/v/ADPhotoKit.svg?style=flat"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
<a href="https://raw.githubusercontent.com/duzexu/ADPhotoKit/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-black"></a>
</p>

ADPhotoKit is a pure-Swift library to select assets (e.g. photo,video,gif,livephoto) from system album. Default appearance is Wechat-like.

## Features

* [x] Well documentation.
* [x] Supports both single and multiple selection.
* [x] Supports filtering albums and sorting by type.
* [x] iCloud Support.
* [x] Multi-language.
* [x] Highly customizable base on protocol(UI/Image/Color/Font).
* [x] UIAppearance support.
* [x] Supports batch export PHAsset to image.
* [x] Image editor.
* [x] DocC support.
* [x] SwiftUI support.
* [x] Custom capture support.
* [ ] Video editor.

## Usage

### Quick Start

The simplest use-case is present the image picker on your controller:

```swift
ADPhotoKitUI.imagePicker(present: self) { (assets, origin) in
    // do something
}
```

Also you can present the image pricker on swiftUI:

```
import SwiftUI

struct SwiftUIView: View {
    
    @State private var showImagePicker = false
    
    var body: some View {
        Button("PickerImage") {
            showImagePicker.toggle()
        }
        .imagePicker(isPresented: $showImagePicker,
                     selected: { (assets, origin) in
            // do something
        })
    }
}
```

### More Advanced Example

Select up to 9 images or videos:

```swift
ADPhotoKitUI.imagePicker(present: self,
                          params: [.maxCount(max: 9)],
                        selected: { (assets, origin) in
    // do something
})
```

Select 1 video or 9 images:

```swift
ADPhotoKitUI.imagePicker(present: self,
                       assetOpts: .exclusive,
                          params: [.maxCount(max: 9),.imageCount(min: nil, max: 9),.videoCount(min: nil, max: 1)],
                        selected: { (assets, origin) in
    // do something
})
```

Select max 8 images:

```swift
ADPhotoKitUI.imagePicker(present: self,
                       albumOpts: [.allowImage],
                       assetOpts: .exclusive,
                          params: [.maxCount(max: 8)],
                        selected: { (assets, origin) in
    // do something
})
```

Browser network image and video:

```swift
ADPhotoKitUI.assetBrowser(present: self, 
                           assets: [NetImage(url: "https://example.com/xx.png"), NetVideo(url: "https://example.com/xx.mp4")]) { assets in
    // do something
}
```

For more usage configuration, you can see [ADPhotoKitConfiguration](./ADPhotoKit/Classes/Base/ADPhotoKitConfiguration.swift) and [SelectionRestrict](./ADPhotoKit/ADPhotoKit.docc/SelectionRestrict.md).

## Learn More

To lean more use of ADPhotoKit, refer to the example and [API Reference](https://duzexu.github.io/ADPhotoKit/).

## Requirements

* iOS 10.0
* Swift 5.0+
* Xcode 15+

> Objective-C is not supported. Swift is the future and dropping Obj-C is the price to pay to keep our velocity on this library :)

### Installation

#### CocoaPods

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

> DocC support need cocoaPods 1.12.0+

##### Subspecs

There are 4 subspecs available now:

| Subspec | Description |
|---|---|
| Base | Required. This subspec provides base configuration and extensions. |
| Core | Optional. This subspec provides raw data. |
| CoreUI | Optional. The subspec provides ui for photo select. |
| ImageEdit | Optional. The subspec provides image edit ability. |

You can install only some of the ADPhotoKit modules. By default, you get `CoreUI` subspecs.

#### Swift Package Manager

* File > Swift Packages > Add Package Dependency
* Add https://github.com/duzexu/ADPhotoKit.git
* Select "Branch" with "master"

#### Note

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

## Contributing

If you have feature requests or bug reports, feel free to help out by sending pull requests or by creating new issues.

## License

ADPhotoKit is available under the MIT license. See the LICENSE file for more info.

> Some code and resource are copy from **ZLPhotoBrowser**
