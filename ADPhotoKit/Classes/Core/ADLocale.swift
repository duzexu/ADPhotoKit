//
//  ADLocale.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import UIKit

public class ADLocale {
    
    class var current: Locale {
        return ADPhotoKitConfiguration.default.locale ?? Locale.current
    }
    
    public enum LocaleKey: String {
        /// Camera (拍照)
        case previewCamera
        /// Record (拍摄)
        case previewCameraRecord
        /// Album (相册)
        case previewAlbum
        /// Cancel (取消)
        case cancel
        /// No Photo (无照片)
        case noPhotoTips
        /// loading, waiting please (加载中，请稍后)
        case loading
        /// waiting... (正在处理...)
        case hudLoading
        /// Done (确定)
        case done
        /// OK (确定)
        case ok
        /// Request timed out (请求超时)
        case timeout
        /// Allow %@ to access your album in \"Settings\"->\"Privacy\"->\"Photos\"
        /// (请在iPhone的\"设置-隐私-照片\"选项中，允许%@访问你的照片)
        case noPhotoLibratyAuthority
        /// Please allow %@ to access your device's camera in \"Settings\"->\"Privacy\"->\"Camera\"
        /// (请在iPhone的\"设置-隐私-相机\"选项中，允许%@访问你的相机)
        case noCameraAuthority
        /// Please allow %@ to access your device's microphone in \"Settings\"->\"Privacy\"->\"Microphone\"
        /// (请在iPhone的\"设置-隐私-麦克风\"选项中，允许%@访问你的麦克风)
        case noMicrophoneAuthority
        /// Camera is unavailable (相机不可用)
        case cameraUnavailable
        /// Photos (照片)
        case photo
        /// Full Image (原图)
        case originalPhoto
        /// Back (返回)
        case back
        /// Edit (编辑)
        case edit
        /// Done (完成)
        case editFinish
        /// Undo (还原)
        case revert
        /// Preview (预览)
        case preview
        /// Unable to select video (不能同时选择照片和视频)
        case notAllowMixSelect
        /// Save (保存)
        case save
        /// Failed to save the image (图片保存失败)
        case saveImageError
        /// Failed to save the video (视频保存失败)
        case saveVideoError
        /// Max select count: %ld (最多只能选择%ld张图片)
        case exceededMaxSelectCount
        /// Max count for video selection: %ld (最多只能选择%ld个视频)
        case exceededMaxVideoSelectCount
        /// Min count for video selection: %ld (最少选择%ld个视频)
        case lessThanMinVideoSelectCount
        /// Unable to select video with a duration longer than %lds
        /// (不能选择超过%ld秒的视频)
        case longerThanMaxVideoDuration
        /// Unable to select video with a duration shorter than %lds
        /// (不能选择低于%ld秒的视频)
        case shorterThanMaxVideoDuration
        /// Unable to sync from iCloud (iCloud无法同步)
        case iCloudVideoLoadFaild
        /// loading failed (图片加载失败)
        case imageLoadFailed
        /// Tap to take photo and hold to record video (轻触拍照，按住摄像)
        case customCameraTips
        /// Tap to take photo (轻触拍照)
        case customCameraTakePhotoTips
        /// hold to record video (按住摄像)
        case customCameraRecordVideoTips
        /// Record at least %lds (至少录制%ld秒)
        case minRecordTimeTips
        /// Recents (所有照片)
        case cameraRoll
        /// Panoramas (全景照片)
        case panoramas
        /// Videos (视频)
        case videos
        /// Favorites (个人收藏)
        case favorites
        /// Time-Lapse (延时摄影)
        case timelapses
        /// Recently Added (最近添加)
        case recentlyAdded
        /// Bursts (连拍快照)
        case bursts
        /// Slo-mo (慢动作)
        case slomoVideos
        /// Selfies (自拍)
        case selfPortraits
        /// Screenshots (屏幕快照)
        case screenshots
        /// Portrait (人像)
        case depthEffect
        /// Live Photo
        case livePhotos
        /// Animated (动图)
        case animated
        /// My Photo Stream (我的照片流)
        case myPhotoStream
        /// All Photos (所有照片)
        case noTitleAlbumListPlaceholder
        /// Unable to access all photos, go to settings (无法访问所有照片，前往设置)
        case unableToAccessAllPhotos
        /// Drag here to remove (拖到此处删除)
        case textStickerRemoveTips
        
        public var localeTextValue: String {
            if let value = ADPhotoKitConfiguration.default.customLocaleValue?[ADLocale.current]?[self] {
                return value
            }
            return Bundle.ad_LocalizedString(rawValue)
        }
    }

}
