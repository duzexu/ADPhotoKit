# Getting Started with ADPhotoKit

Learn how to install and use ADPhotoKit from the first step.

## Requirements

* iOS 10.0
* Swift 5.0+

> Objective-C is not supported. Swift is the future and dropping Obj-C is the price to pay to keep our velocity on this library.

## Installation

You can install ADPhotoKit by *CocoaPods* or *Swift Package Manager*.

### CocoaPods

 [CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

 ```bash
 $ gem install cocoapods
 ```

To integrate ADPhotoKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://cdn.cocoapods.org/'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
  pod 'ADPhotoKit'
end
```

Then, run the following command:

```bash
$ pod install
```

You should open the {Project}.xcworkspace instead of the {Project}.xcodeproj after you installed anything from CocoaPods.

#### Subspecs

There are 4 subspecs available now:

| Subspec | Description |
|---|---|
| Base | Required. This subspec provides base configuration and extensions. |
| Core | Optional. This subspec provides raw data. |
| CoreUI | Optional. The subspec provides ui for photo select. |
| ImageEdit | Optional. The subspec provides image edit ability. |

You can install only some of the ADPhotoKit modules. By default, you get `CoreUI` subspecs.

### Swift Package Manager

 [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

> Xcode 11+ is required to build ADPhotoKit using Swift Package Manager.

To integrate ADPhotoKit into your Xcode project using Swift Package Manager, follow the the steps below:

1. Select File > Swift Packages > Add Package Dependency. Enter `https://github.com/duzexu/ADPhotoKit.git` in the "Choose Package Repository" dialog.
2. In the next page, specify the version resolving rule as "Branch" with "master".
3. After Xcode checking out the source and resolving the version, you can choose the "ADPhotoKit" library and add it to your app target.

If you encounter any problem or have a question on adding the package to an Xcode project, I suggest reading the [Adding Package Dependencies](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) to Your App guide article from Apple.

### Manually

> Important: It is not recommended to install the framework manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate ADPhotoKit into your project manually. A regular way to use ADPhotoKit in your project would be using the Embedded Framework.

## Note

> Warning: You need to add the following key-value pairs in your app's Info.plist

```
// If you don’t add this key-value pair, multiple languages are not supported, and the system PhotoKitUI language defaults to English
Localized resources can be mixed YES
// You must add follow in your app's Info.plist
Privacy - Photo Library Usage Description
// If you `assetOpts` contain `allowTakePhotoAsset`, you must add follow
Privacy - Camera Usage Description
// If you `assetOpts` contain `allowTakeVideoAsset`, you must add follow
Privacy - Microphone Usage Description
```

## Next

After installation, you could import ADPhotoKit to your project by adding this:

```swift
import ADPhotoKit
```

to the files in which you want to use ADPhotoKit.

Once you prepared, continue to have a look at the Usage to see how to use ADPhotoKit.

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

For more usage configuration, you can see ``ADPhotoKitConfiguration`` and <doc:SelectionRestrict>.


