//
//  ADEnum.swift
//  ADPhotoKit
//
//  Created by du on 2024/6/28.
//

import Foundation

/// Errors throw by framework.
public enum ADError: Error {
    /// App have no permission to access photo album.
    case noAuthorization
    /// AVAssetExportSession init failed when export video.
    case exportSessionCreateFailed
}

/// Capture resolution.
public enum ADCapturePreset {
    case cif352x288
    case vga640x480
    case hd1280x720
    case hd1920x1080
    case hd4K3840x2160
    case photo
}

/// Camera focus mode.
public enum ADFocusMode {
    case autoFocus
    case continuousAutoFocus
}

/// Camera exposure mode.
public enum ADExposureMode {
    case autoExpose
    case continuousAutoExposure
}

/// Capture device position.
public enum ADDevicePosition {
    case back
    case front
}
