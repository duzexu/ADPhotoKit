//
//  ADCameraCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/24.
//

import UIKit
import AVFoundation

public class ADCameraCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    private var session: AVCaptureSession?
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(image: Bundle.uiBundle?.image(name: "takePhoto"))
        imageView.backgroundColor = UIColor(white: 0.3, alpha: 1)
        imageView.contentMode = .center
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
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

/// UIAppearance
extension ADCameraCell {
    
    public enum Key: String {
        case cornerRadius /// 圆角
        case bgColor /// 背景颜色
    }
    
    @objc
    public func setAttributes(_ attrs: [String : Any]?) {
        if let kvs = attrs {
            for (k,v) in kvs {
                if let key = Key(rawValue: k) {
                    switch key {
                    case .cornerRadius:
                        contentView.layer.cornerRadius = CGFloat((v as? Int) ?? 0)
                        contentView.layer.masksToBounds = true
                    case .bgColor:
                        imageView.backgroundColor = (v as? UIColor) ?? UIColor(white: 0.3, alpha: 1)
                    }
                }
            }
        }
    }
    
}
