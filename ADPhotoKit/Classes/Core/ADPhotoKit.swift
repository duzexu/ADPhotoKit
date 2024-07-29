//
//  File.swift
//  ADPhotoKit
//
//  Created by xu on 2021/6/3.
//

import Foundation
import UIKit

/// Options to set the album type and order.
public struct ADAlbumSelectOptions: OptionSet {
    public let rawValue: Int
    
    /// If contain, assets will return with lastest time at last, if not, the results will revert. Default is not contain.
    public static let ascending = ADAlbumSelectOptions(rawValue: 1 << 0)
    /// If contain, results will have image assets. Default is contain.
    public static let allowImage = ADAlbumSelectOptions(rawValue: 1 << 1)
    /// If contain, results will have video assets. Default is contain.
    public static let allowVideo = ADAlbumSelectOptions(rawValue: 1 << 2)
    
    /// Default options.
    public static let `default`: ADAlbumSelectOptions = [.allowImage, .allowVideo]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// Options to control the asset select condition and ui.
public struct ADAssetSelectOptions: OptionSet {
    public let rawValue: Int
    
    /// Whether photos and videos can be selected together.
    public static let mixSelect = ADAssetSelectOptions(rawValue: 1 << 0)
    /// Allow select Gif, it only controls whether it is displayed in Gif form.
    public static let selectAsGif = ADAssetSelectOptions(rawValue: 1 << 1)
    /// Allow select LivePhoto, it only controls whether it is displayed in LivePhoto form.
    public static let selectAsLivePhoto = ADAssetSelectOptions(rawValue: 1 << 2)
    /// You can slide select photos in album.
    public static let slideSelect = ADAssetSelectOptions(rawValue: 1 << 3)
    /// If `slideSelect` contain, Will auto scroll to top or bottom when your finger at the top or bottom.
    public static let autoScroll = ADAssetSelectOptions(rawValue: 1 << 4)
    /// Allow take photo asset in the album.
    public static let allowTakePhotoAsset = ADAssetSelectOptions(rawValue: 1 << 5)
    /// Allow take video asset in the album.
    public static let allowTakeVideoAsset = ADAssetSelectOptions(rawValue: 1 << 6)
    /// Show the image captured by the camera is displayed on the camera button inside the album.
    public static let captureOnTakeAsset = ADAssetSelectOptions(rawValue: 1 << 7)
    /// If user choose limited Photo mode, a button with '+' will be added. It will call PHPhotoLibrary.shared().presentLimitedLibraryPicker(from:) to add photo.
    @available(iOS 14, *)
    public static let allowAddAsset = ADAssetSelectOptions(rawValue: 1 << 8)
    /// iOS14 limited Photo mode, will show collection footer view in ADThumbnailViewController.
    /// Will go to system setting if clicked.
    @available(iOS 14, *)
    public static let allowAuthTips = ADAssetSelectOptions(rawValue: 1 << 9)
    /// Allow access to the browse large image interface (That is, whether to allow access to the large image interface after clicking the thumbnail image).
    public static let allowBrowser = ADAssetSelectOptions(rawValue: 1 << 10)
    /// Allow toolbar in thumbnail controller.
    public static let thumbnailToolBar = ADAssetSelectOptions(rawValue: 1 << 11)
    /// Display the index of the selected photos at cell.
    public static let selectIndex = ADAssetSelectOptions(rawValue: 1 << 12)
    /// In single selection mode, whether to display the selection button.
    public static let selectBtnWhenSingleSelect = ADAssetSelectOptions(rawValue: 1 << 13)
    /// Whether to display the selected count on the button.
    public static let selectCountOnDoneBtn = ADAssetSelectOptions(rawValue: 1 << 14)
    /// Whether to show the total size of selected photos when selecting the original image.
    /// - Note: The framework uses a conversion ratio of 1KB=1024Byte, while the system album uses 1KB=1000Byte, so the displayed photo size within the framework will be smaller than the size in the system album.
    public static let totalOriginalSize = ADAssetSelectOptions(rawValue: 1 << 15)
    /// Whether to use system image picker to take asset.
    public static let systemCapture = ADAssetSelectOptions(rawValue: 1 << 16)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Default options.
    public static let `default`: ADAssetSelectOptions = [.mixSelect,.slideSelect,.autoScroll,.allowTakePhotoAsset,.allowTakeVideoAsset,.thumbnailToolBar,.allowBrowser,.selectIndex,.totalOriginalSize,.selectCountOnDoneBtn]
    
    /// Options do not allow mix select.
    public static let exclusive: ADAssetSelectOptions = [.slideSelect,.autoScroll,.allowTakePhotoAsset,.allowTakeVideoAsset,.thumbnailToolBar,.allowBrowser,.selectIndex,.totalOriginalSize,.selectCountOnDoneBtn]
    
}

/// Options to control the asset browser condition and ui.
public struct ADAssetBrowserOptions: OptionSet {
    public let rawValue: Int
    
    /// Allow select full image.
    ///
    /// Identify whether the user selects the original image. If contains `fetchImage`, will fetch orginal image, otherwise return the screen-fit-size image.
    public static let selectOriginal = ADAssetBrowserOptions(rawValue: 1 << 0)
    /// Display the selected photos at the bottom of the browse large photos interface.
    public static let selectThumbnil = ADAssetBrowserOptions(rawValue: 1 << 1)
    /// Display the index of the selected photos at navbar.
    public static let selectIndex = ADAssetBrowserOptions(rawValue: 1 << 2)
    /// Allow framework fetch image when callback.
    public static let fetchImage = ADAssetBrowserOptions(rawValue: 1 << 3)
    /// In single selection mode, whether to display the selection button.
    public static let selectBtnWhenSingleSelect = ADAssetBrowserOptions(rawValue: 1 << 4)
    /// Whether to display the selected count on the button.
    public static let selectCountOnDoneBtn = ADAssetBrowserOptions(rawValue: 1 << 5)
    /// Whether to show the total size of selected photos when selecting the original image.
    /// - Note: The framework uses a conversion ratio of 1KB=1024Byte, while the system album uses 1KB=1000Byte, so the displayed photo size within the framework will be smaller than the size in the system album.
    public static let totalOriginalSize = ADAssetBrowserOptions(rawValue: 1 << 6)
    // Save the edited image to the album after editing.
    public static let saveAfterEdit = ADAssetBrowserOptions(rawValue: 1 << 7)
    
    /// Default options.
    public static let `default`: ADAssetBrowserOptions = [.selectOriginal, .selectThumbnil, .selectIndex, .fetchImage, .totalOriginalSize, .selectCountOnDoneBtn, .saveAfterEdit]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// Params to control the asset select condition.
public enum ADPhotoSelectParams: Hashable, Equatable {
    /// Limit the max count you can select. Set `nil` means no limit. Default is no limit.
    case maxCount(max: Int?)
    /// Limit the min and max image count you can select. Set `nil` means no limit. Default is no limit.
    case imageCount(min: Int?, max: Int?)
    /// Limit the min and max video count you can select. Set `nil` means no limit. Default is no limit.
    case videoCount(min: Int?, max: Int?)
    /// Limit the min and max video time you can select. Set `nil` means no limit. Default is no limit.
    case videoTime(min: Int?, max: Int?)
    /// Limit the min and max video size you can select. Set `nil` means no limit. Default is no limit.
    case videoSize(min: CGFloat?, max: CGFloat?)
    /// Limit the min and max video time you can record. Set `nil` means no limit. Default is no limit.
    case recordTime(min: Int?, max: Int?)
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public var hashValue: Int {
        var value: Int = 0
        switch self {
        case .maxCount:
            value = 0
        case .imageCount:
            value = 1
        case .videoCount:
            value = 2
        case .videoTime:
            value = 3
        case .recordTime:
            value = 4
        case .videoSize:
            value = 5
        }
        return value
    }
}


