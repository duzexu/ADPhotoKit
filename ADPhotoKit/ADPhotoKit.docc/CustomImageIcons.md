# Use Custom Image Assets

Learn how to use custom image assets.

## Overview

ADPhotoKit use Wechat-like image assets, you can replace with your app style image assets.

## Methods

* Just replace the image of the same name at corresponding module bundle.
* Set different module's image bundle in ``ADPhotoKitConfiguration`` with your image bundle.

```swift
ADPhotoKitConfiguration.default.customCoreUIBundle = Bundle(url: ...)
```
