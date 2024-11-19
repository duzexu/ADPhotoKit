//
//  ADCameraCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/24.
//

import UIKit
import AVFoundation

/// Cell for take asset in thumbnail controller.
public class ADCameraCell: UICollectionViewCell {
    
    public var selectable: Bool {
        set {
            coverView.isHidden = newValue
        }
        get {
            return coverView.isHidden
        }
    }
    
    private var imageView: UIImageView!
    private var coverView: UIImageView!
    
    private var session: AVCaptureSession?
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(white: 0.3, alpha: 1)
        imageView = UIImageView(image: Bundle.image(name: "takePhoto"))
        imageView.contentMode = .center
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        coverView = UIImageView()
        coverView.isHidden = true
        coverView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        contentView.addSubview(coverView)
        coverView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
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
    
    /// Key for attribute.
    public class Key: NSObject {
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        static func == (lhs: Key, rhs: Key) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    
    /// You may specify the corner radius, bg color properties for the cell in the attributes dictionary, using the keys found in `ADCameraCell.Key`.
    /// - Parameter attrs: Attributes dictionary.
    @objc
    public func setAttributes(_ attrs: [Key : Any]?) {
        if let kvs = attrs {
            for (k,v) in kvs {
                if k == .bgColor {
                    contentView.backgroundColor = (v as? UIColor) ?? UIColor(white: 0.3, alpha: 1)
                }
                if k == .cornerRadius {
                    contentView.layer.cornerRadius = CGFloat((v as? Int) ?? 0)
                    contentView.layer.masksToBounds = true
                }
            }
        }
    }
    
}

extension ADCameraCell.Key {
    /// Int, default 0
    public static let cornerRadius = ADCameraCell.Key(rawValue: "cornerRadius")
    /// UIColor, default UIColor(white: 0.3, alpha: 1)
    public static let bgColor = ADCameraCell.Key(rawValue: "bgColor")
}
