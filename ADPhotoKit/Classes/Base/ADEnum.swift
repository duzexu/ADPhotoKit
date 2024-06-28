//
//  ADEnum.swift
//  ADPhotoKit
//
//  Created by du on 2024/6/28.
//

import Foundation

public enum ADCapturePreset {
    case cif352x288
    case vga640x480
    case hd1280x720
    case hd1920x1080
    case hd4K3840x2160
    case photo
}

public enum ADFocusMode {
    case autoFocus
    case continuousAutoFocus
}

public enum ADExposureMode {
    case autoExpose
    case continuousAutoExposure
}

public enum ADDevicePosition {
    case back
    case front
}
