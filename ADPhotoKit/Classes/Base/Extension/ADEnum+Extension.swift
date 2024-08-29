//
//  ADEnum+Extension.swift
//  ADPhotoKit
//
//  Created by du on 2024/6/28.
//

import Foundation
import AVFoundation
import UIKit

extension ADCapturePreset {
    var sessionPreset: AVCaptureSession.Preset {
        switch self {
        case .cif352x288:
            return .cif352x288
        case .vga640x480:
            return .vga640x480
        case .hd1280x720:
            return .hd1280x720
        case .hd1920x1080:
            return .hd1920x1080
        case .hd4K3840x2160:
            return .hd4K3840x2160
        case .photo:
            return .photo
        }
    }
}

extension ADFocusMode {
    var focusMode: AVCaptureDevice.FocusMode {
        switch self {
        case .autoFocus:
            return .autoFocus
        case .continuousAutoFocus:
            return .continuousAutoFocus
        }
    }
}

extension ADExposureMode {
    var exposureMode: AVCaptureDevice.ExposureMode {
        switch self {
        case .autoExpose:
            return .autoExpose
        case .continuousAutoExposure:
            return .continuousAutoExposure
        }
    }
}

extension ADDevicePosition {
    var devicePosition: AVCaptureDevice.Position {
        switch self {
        case .back:
            return .back
        case .front:
            return .front
        }
    }
    
    var cameraDevice: UIImagePickerController.CameraDevice {
        switch self {
        case .back:
            return .rear
        case .front:
            return .front
        }
    }
}
