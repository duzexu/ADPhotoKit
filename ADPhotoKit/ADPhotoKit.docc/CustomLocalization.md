# Use Custom Localized Strings

Learn how to use custom localized strings.

## Overview

ADPhotoKit supports localization in 11 languages by default. If the default localized characters do not meet your requirements or add languages that are not supported by default, you can add custom localized strings by yourself.

## Examples

* Change display language.

ADPhotoKit use system language by default, you can change as you wish.

```swift
ADPhotoKitConfiguration.default.locale = Locale(identifier: "ru")
```

* Modify exist localized strings.

If the default localized characters do not meet your requirements，you can modify some or all strings by yourself.

```swift
ADPhotoKitConfiguration.default.customLocaleValue = [ Locale(identifier: "en"):[.cancel:"Cancel Select",.cameraRoll:"All"] ]
```

* Add unsupported localized strings.

If any languages that are not supported by default, framework will use english instead, you can add your language support.

```swift
ADPhotoKitConfiguration.default.customLocaleValue = [ Locale(identifier: "ta-IN"):[.cancel:"ரத்து செய்",...] ]
```
