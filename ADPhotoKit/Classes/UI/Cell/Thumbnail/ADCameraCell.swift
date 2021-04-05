//
//  ADCameraCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/24.
//

import UIKit
import AVFoundation

class ADCameraCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    private var session: AVCaptureSession?
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.3, alpha: 1)
        
        imageView = UIImageView(image: Bundle.uiBundle?.image(name: "takePhoto"))
        imageView.contentMode = .center
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        session?.stopRunning()
        session = nil
    }
    
    func startCapture() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) || status == .denied {
            return
        }
        
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                }
            }
        } else {
            setupSession()
        }
    }
}

private extension ADCameraCell {
    func setupSession() {
        guard self.session == nil, (self.session?.isRunning ?? false) == false else {
            return
        }
        session?.stopRunning()
        if let input = deviceInput {
            session?.removeInput(input)
        }
        if let output = photoOutput {
            session?.removeOutput(output)
        }
        session = nil
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices
        for device in devices {
            if device.position == .back {
                deviceInput = try? AVCaptureDeviceInput(device: device)
            }
        }
        guard let input = deviceInput else {
            return
        }
        photoOutput = AVCapturePhotoOutput()
        
        session = AVCaptureSession()
        
        if session!.canAddInput(input) {
            session!.addInput(input)
        }
        if session!.canAddOutput(photoOutput!) {
            session!.addOutput(photoOutput!)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        contentView.layer.masksToBounds = true
        previewLayer?.frame = contentView.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        contentView.layer.insertSublayer(previewLayer!, at: 0)
        
        session!.startRunning()
    }
}
