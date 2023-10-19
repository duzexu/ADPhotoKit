# Restrict selection conditions

Lean how to set selection conditions.

## Overview

ADPhotoKit can set selection conditions by different parameters according to different scenes.

## Scenes

* Upload avatar - Select only 1 image and don't show video assets

```swift
ADPhotoKitUI.imagePicker(present: self,
                       albumOpts: [.allowImage],
                          params: [.imageCount(min: nil, max: 1)],
                        selected: { (assets, origin) in
    // do something
})
```

* Upload video - Select 1 video that duration is greater than 5 seconds but less than 2 minutes and don't show image assets

```swift
ADPhotoKitUI.imagePicker(present: self,
                       albumOpts: [.allowVideo],
                          params: [.videoCount(min: nil, max: 1),.videoTime(min: 5, max: 120)],
                        selected: { (assets, origin) in
    // do something
})
```

* Send chat message - Select up to 9 images or videos

```swift
ADPhotoKitUI.imagePicker(present: self,
                          params: [.maxCount(max: 9)],
                        selected: { (assets, origin) in
    // do something
})
```

* Post Moments - Select only 1 video or max 9 images

```swift
ADPhotoKitUI.imagePicker(present: self,
                       assetOpts: .exclusive,
                          params: [.maxCount(max: 9),.imageCount(min: nil, max: 9),.videoCount(min: nil, max: 1)],
                        selected: { (assets, origin) in
    // do something
})
```

* Post vlog - Select only 1 video or max 8 images and video duration is greater than 30 seconds but less than 5 minutes

```swift
ADPhotoKitUI.imagePicker(present: self,
                       assetOpts: .exclusive,
                          params: [.imageCount(min: nil, max: 9),.videoCount(min: nil, max: 1),.videoTime(min: 30, max: 300)],
                        selected: { (assets, origin) in
    // do something
})
```
