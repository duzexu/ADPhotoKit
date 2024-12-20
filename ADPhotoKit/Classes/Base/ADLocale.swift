//
//  ADLocale.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/14.
//

import UIKit

/// Class for language localizable.
public class ADLocale {
    
    class var current: Locale {
        return ADPhotoKitConfiguration.default.locale ?? Locale.current
    }
    
    /// Key for localizable.
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
        /// loading... (正在加载)
        case hudLoading
        /// waiting... (正在处理...)
        case hudProcessing
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
        /// Total (共)
        case originalTotalSize
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
        /// Max select count: %ld (最多只能选择%ld个)
        case exceededMaxSelectCount
        /// Cannot select image (不能选择图片)
        case imageNotSelectable
        /// Cannot select video (不能选择视频)
        case videoNotSelectable
        /// Max count for image selection: %ld (最多只能选择%ld张图片)
        case exceededMaxImageSelectCount
        /// Max count for video selection: %ld (最多只能选择%ld个视频)
        case exceededMaxVideoSelectCount
        /// Min count for video selection: %ld (最少选择%ld个视频)
        case lessThanMinVideoSelectCount
        /// Unable to select video with a duration longer than %lds
        /// (不能选择超过%ld秒的视频)
        case longerThanMaxVideoDuration
        /// Unable to select video with a duration shorter than %lds
        /// (不能选择低于%ld秒的视频)
        case shorterThanMinVideoDuration
        /// Can't select videos larger than %@MB
        /// (不能选择大于%@MB的视频)
        case largerThanMaxVideoDataSize
        /// Can't select videos smaller than %@MB
        /// (不能选择小于%@MB的视频)
        case smallerThanMinVideoDataSize
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
        /// Release to delete (松手即可删除)
        case textStickerReleaseToDelete
        /// Drag here to remove (拖到此处删除)
        case textStickerDeleteTips
        /// Brightness (亮度)
        case brightness
        /// Contrast (对比度)
        case contrast
        /// Saturation (饱和度)
        case saturation
        /// Keep Recording (继续拍摄)
        case keepRecording
        /// Go to Settings (前往设置)
        case gotoSettings
        /// Export failed (导出失败)
        case exportFailed
        /// No music (暂无音乐)
        case noMusic
        /// Music (配乐)
        case music
        /// OST (视频原声)
        case ost
        /// Lyrics (歌词)
        case lyrics
        /// Search by name/singer/lyrics/mood (搜索歌名/歌手/歌词/情绪)
        case musicSearch
        
        /// Return key's localizable text.
        public var localeTextValue: String {
            if let value = ADPhotoKitConfiguration.default.customLocaleValue?[ADLocale.current]?[self] {
                return value
            }
            return Bundle.localizedString(rawValue)
        }
    }

    class var isRTL: Bool {
        return UIView.userInterfaceLayoutDirection(for: UIView.appearance().semanticContentAttribute) == .rightToLeft
    }

}
