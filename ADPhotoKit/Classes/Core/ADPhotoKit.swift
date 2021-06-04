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
    /// Allow toolbar in thumbnail controller
    public static let thumbnailToolBar = ADAssetSelectOptions(rawValue: 1 << 11)
    /// Allow select full image.
    public static let selectOriginal = ADAssetSelectOptions(rawValue: 1 << 12)
        
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let `default`: ADAssetSelectOptions = [.mixSelect,.selectOriginal,.slideSelect,.autoScroll,allowTakePhotoAsset,.thumbnailToolBar,.allowBrowser]
    
}

/// Options to control the asset browser condition and ui.
public struct ADAssetBrowserOptions: OptionSet {
    public let rawValue: Int
    
    /// Allow select full image.
    public static let selectOriginal = ADAssetBrowserOptions(rawValue: 1 << 0)
    /// Display the selected photos at the bottom of the browse large photos interface.
    public static let selectBrowser = ADAssetBrowserOptions(rawValue: 1 << 1)
    /// Display the index of the selected photos at navbar.
    public static let selectIndex = ADAssetBrowserOptions(rawValue: 1 << 2)
    /// Allow framework fetch image when callback.
    public static let fetchImage = ADAssetBrowserOptions(rawValue: 1 << 3)
    
    public static let `default`: ADAssetBrowserOptions = [.selectOriginal, .selectBrowser, .selectIndex, .fetchImage]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// Params to control the asset select condition.
public enum ADPhotoSelectParams: Hashable, Equatable {
    /// Limit the max count you can select. Set `nil` means no limit. Default is no limit.
    case maxCount(max: Int?)
    /// Limit the min and max image count you can select. Set `nil` means no limit. Default is no limit.
    case imageCount(min: Int?, max:Int?)
    /// Limit the min and max video count you can select. Set `nil` means no limit. Default is no limit.
    case videoCount(min: Int?, max:Int?)
    /// Limit the min and max video time you can select. Set `nil` means no limit. Default is no limit.
    case videoTime(min: Int?, max: Int?)
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
        }
        return value
    }
}

/// Represent thumbnail cell's select status.
public enum ADThumbnailSelectStatus {
    /// Cell can be selet.
    /// - Parameter index: If not nil, the cell is seleted and the value is select index.
    case select(index: Int?)
    /// Cell can not be selet.
    case deselect

    /// Return cell is select or not.
    public var isSelect: Bool {
        switch self {
        case let .select(index):
            if let _ = index {
                return true
            }else{
                return false
            }
        case .deselect:
            return false
        }
    }
    
    /// Return cell is selectable or not.
    public var isEnable: Bool {
        switch self {
        case .select:
            return true
        case .deselect:
            return false
        }
    }
}
