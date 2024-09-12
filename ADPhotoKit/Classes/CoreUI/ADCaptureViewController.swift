//
//  ADCaptureViewController.swift
//  ADPhotoKit
//
//  Created by du on 2024/6/3.
//

import UIKit
import AVFoundation
import CoreMotion

/// Controller to capture assets.
class ADCaptureViewController: UIViewController, ADAssetCaptureConfigurable {
    
    /// Called when finish capture asset.
    public var assetCapture: ((UIImage?, URL?) -> Void)?
    /// Called when cancel capture asset.
    public var cancelCapture: (() -> Void)?
    
    private let config: ADPhotoKitConfig
    
    private let session = AVCaptureSession()
    private let captureDevice = AVCaptureDevice.default(for: .video)
    private let sessionQueue = DispatchQueue(label: "com.adphotokit.sessionQueue", attributes: .concurrent)
    private let motionManager = CMMotionManager()
    
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoPlayLayer: AVPlayerLayer?
    private var takedImageView: UIImageView!
    private var focusView: UIImageView!
    private var recordingView: ADRecordingView!
    private var closeBtn: UIButton!
    private var flashBtn: UIButton!
    private var retakeBtn: UIButton!
    private var doneBtn: UIButton!
    
    private var micIsAvailable = true
    private var isFocusPoint = false
    private var isTakingPhoto = false
    private var isSwitchCamera = false
    private var restartRecord = false
    private var flashSwitch: Bool {
        get {
            return captureConfig.flashSwitch && captureDevice?.hasFlash == true
        }
    }
    
    private var captureInput: AVCaptureDeviceInput?
    private var imageOutput: AVCapturePhotoOutput?
    private var fileOutput: AVCaptureMovieFileOutput?
    private var recordInfos: [(URL,Double)] = []
    private var videoURL: URL?
    
    private let captureConfig = ADPhotoKitConfiguration.default.captureConfig
    
    /// Create capture asset controller.
    /// - Parameter config: input config setting.
    required public init(config: ADPhotoKitConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        motionManager.stopDeviceMotionUpdates()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestAccess()
        if config.assetOpts.contains(.allowTakeVideoAsset) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoRecording, options: .duckOthers)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                let err = error as NSError
                if err.code == AVAudioSession.ErrorCode.insufficientPriority.rawValue ||
                    err.code == AVAudioSession.ErrorCode.isBusy.rawValue {
                    micIsAvailable = false
                }
            }
        }
        
        motionManager.deviceMotionUpdateInterval = 0.5
        
        sessionQueue.async { [weak self] in
            self?.setupSession()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if motionManager.isDeviceMotionActive {
            motionManager.startDeviceMotionUpdates()
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopDeviceMotionUpdates()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if session.isRunning {
            sessionQueue.async {
                self.session.stopRunning()
            }
        }
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        isPhone ? .portrait : .all
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-120-safeAreaInsets.bottom)
        videoPlayLayer?.frame = view.frame
    }

}

private extension ADCaptureViewController {
    
    func setupUI() {
        view.backgroundColor = .black
        view.layer.masksToBounds = true
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.opacity = 1
        view.layer.addSublayer(previewLayer)
        
        if config.assetOpts.contains(.allowTakeVideoAsset) {
            videoPlayLayer = AVPlayerLayer()
            videoPlayLayer?.backgroundColor = UIColor.black.cgColor
            videoPlayLayer?.videoGravity = .resizeAspect
            videoPlayLayer?.isHidden = true
            view.layer.addSublayer(videoPlayLayer!)
        }
        
        let gestureView = UIView()
        view.addSubview(gestureView)
        gestureView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-safeAreaInsets.bottom-120)
        }
        
        closeBtn = UIButton(type: .custom)
        closeBtn.setImage(Bundle.image(name: "nav_close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        closeBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(55)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        takedImageView = UIImageView()
        takedImageView.backgroundColor = .black
        takedImageView.isHidden = true;
        takedImageView.contentMode = .scaleAspectFit
        view.addSubview(takedImageView)
        takedImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(takedImageView.snp.width).dividedBy(9/16.0)
            make.top.equalToSuperview()
        }
        
        focusView = UIImageView(image: Bundle.image(name: "focus"))
        focusView.contentMode = .scaleAspectFit
        focusView.clipsToBounds = true
        focusView.frame = CGRectMake(0, 0, 70, 70)
        focusView.alpha = 0
        view.addSubview(focusView)
        
        let bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-safeAreaInsets.bottom)
            make.height.equalTo(120)
        }
        
        flashBtn = UIButton(type: .custom)
        flashBtn.setImage(Bundle.image(name: "flash_off"), for: .normal)
        flashBtn.setImage(Bundle.image(name: "flash_on"), for: .selected)
        flashBtn.adjustsImageWhenHighlighted = false
        flashBtn.addTarget(self, action: #selector(flashBtnAction), for: .touchUpInside)
        bottomView.addSubview(flashBtn)
        flashBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(60)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 25, height: 25))
        }
        
        let deviceCount = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices.count
        let toggleBtn = UIButton(type: .custom)
        toggleBtn.setImage(Bundle.image(name: "toggle_camera"), for: .normal)
        toggleBtn.adjustsImageWhenHighlighted = false
        toggleBtn.addTarget(self, action: #selector(switchCameraBtnAction), for: .touchUpInside)
        toggleBtn.isHidden = !captureConfig.cameraSwitch || deviceCount <= 1
        bottomView.addSubview(toggleBtn)
        toggleBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-60)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 25, height: 25))
        }
        
        recordingView = ADRecordingView(allowPhoto: config.assetOpts.contains(.allowTakePhotoAsset), allowVideo: config.assetOpts.contains(.allowTakeVideoAsset), maxTime: Double(config.params.maxRecordTime))
        recordingView.takeImageAction = { [weak self] in
            self?.takeImage()
        }
        recordingView.takeVideoAction = { [weak self] view, state in
            switch state {
            case .begin:
                self?.startRecord()
            case let .change(factor):
                self?.setZoomFactor(value: .factor(factor))
            case .end:
                self?.stopRecord()
            }
        }
        bottomView.addSubview(recordingView)
        recordingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
        
        retakeBtn = UIButton(type: .custom)
        retakeBtn.setImage(Bundle.image(name: "retake"), for: .normal)
        retakeBtn.adjustsImageWhenHighlighted = false
        retakeBtn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        retakeBtn.addTarget(self, action: #selector(retakeBtnAction), for: .touchUpInside)
        retakeBtn.isHidden = true
        view.addSubview(retakeBtn)
        retakeBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(54)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        doneBtn = UIButton(type: .custom)
        doneBtn.setTitle(ADLocale.LocaleKey.done.localeTextValue, for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        doneBtn.layer.cornerRadius = 5
        doneBtn.layer.masksToBounds = true
        doneBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        doneBtn.setTitleColor(UIColor.white, for: .normal)
        doneBtn.adjustsImageWhenHighlighted = false
        doneBtn.backgroundColor = UIColor(hex: 0x10C060)!
        doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        doneBtn.isHidden = true
        view.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-57-safeAreaInsets.bottom)
            make.height.equalTo(34)
        }
        
        let focusGes = UITapGestureRecognizer()
        focusGes.addTarget(self, action: #selector(focusGesAction(_:)))
        view.addGestureRecognizer(focusGes)
        
        let pinchGes = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesAction(_:)))
        gestureView.addGestureRecognizer(pinchGes)
    }
    
    func refreshUI() {
        if Thread.isMainThread {
            if session.isRunning {
                showTipsInfo()
                recordingView.superview?.isHidden = false
                closeBtn.isHidden = false
                flashBtn.isHidden = captureDevice?.hasFlash == false;
                retakeBtn.isHidden = true
                doneBtn.isHidden = true
                takedImageView.isHidden = true
                takedImageView.image = nil
            }else{
                recordingView.hideTips()
                recordingView.superview?.isHidden = true
                closeBtn.isHidden = true
                retakeBtn.isHidden = false
                doneBtn.isHidden = false
            }
        }else{
            DispatchQueue.main.async {
                self.refreshUI()
            }
        }
    }
    
    func showTipsInfo() {
        if config.assetOpts.contains(.allowTakePhotoAsset) && config.assetOpts.contains(.allowTakeVideoAsset) {
            recordingView.showTips(text: ADLocale.LocaleKey.customCameraTips.localeTextValue)
        }else if config.assetOpts.contains(.allowTakePhotoAsset) {
            recordingView.showTips(text: ADLocale.LocaleKey.customCameraTakePhotoTips.localeTextValue)
        }else if config.assetOpts.contains(.allowTakeVideoAsset) {
            recordingView.showTips(text: ADLocale.LocaleKey.customCameraRecordVideoTips.localeTextValue)
        }
    }
    
    func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                self.addNotifications()
                if self.config.assetOpts.contains(.allowTakeVideoAsset) {
                    AVCaptureDevice.requestAccess(for: .audio) { granted in
                        if !granted {
                            ADAlert.alert().alert(on: self, title: nil, message: String(format: ADLocale.LocaleKey.noMicrophoneAuthority.localeTextValue, appName), actions: [.cancel(ADLocale.LocaleKey.keepRecording.localeTextValue),.default(ADLocale.LocaleKey.gotoSettings.localeTextValue)]) { index in
                                if index == 1 {
                                    guard let url = URL(string: UIApplication.openSettingsURLString) else {
                                        return
                                    }
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }else{
                ADAlert.alert().alert(on: self, title: nil, message: String(format: ADLocale.LocaleKey.noCameraAuthority.localeTextValue, appName), actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)]) { _ in
                    self.closeBtnAction()
                }
            }
        }
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main) { [weak self] noti in
            if self?.session.isRunning == true {
                self?.dismiss(animated: true, completion: nil)
            }
            self?.videoPlayLayer?.player?.pause()
        }
        if config.assetOpts.contains(.allowTakeVideoAsset) {
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) { [weak self] noti in
                self?.videoPlayLayer?.player?.pause()
            }
            NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: OperationQueue.main) { [weak self] noti in
                if self?.videoPlayLayer?.player?.rate == 0 && self?.videoPlayLayer?.isHidden == false {
                    let type = noti.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
                    let option = noti.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt
                    if type == AVAudioSession.InterruptionType.ended.rawValue, option == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                        self?.videoPlayLayer?.player?.play()
                    }
                }
            }
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: OperationQueue.main) { [weak self] noti in
                self?.videoPlayLayer?.player?.seek(to: .zero)
                self?.videoPlayLayer?.player?.play()
            }
        }
    }
    
    func setupSession() {
        guard let camera = getCamera(position: captureConfig.cameraPosition.devicePosition) else { return }
        guard let input = try? AVCaptureDeviceInput(device: camera) else { return }
        
        session.beginConfiguration()
        let preset = captureConfig.sessionPreset.sessionPreset
        if camera.supportsSessionPreset(preset) && session.canSetSessionPreset(preset) {
            session.sessionPreset = preset
        }else{
            session.sessionPreset = .photo
        }
        
        if session.canAddInput(input) {
            captureInput = input
            session.addInput(input)
        }
        
        let fileOutput = AVCaptureMovieFileOutput()
        fileOutput.movieFragmentInterval = .invalid
        if session.canAddOutput(fileOutput) {
            self.fileOutput = fileOutput
            session.addOutput(fileOutput)
        }
        
        let imageOutput = AVCapturePhotoOutput()
        if session.canAddOutput(imageOutput) {
            self.imageOutput = imageOutput
            session.addOutput(imageOutput)
        }
        
        if config.assetOpts.contains(.allowTakeVideoAsset) && micIsAvailable {
            let microphone = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: .audio, position: .unspecified).devices.first
            if let microphone = microphone {
                if let audio = try? AVCaptureDeviceInput(device: microphone) {
                    if session.canAddInput(audio) {
                        session.addInput(audio)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.showTipsInfo()
            self.focusAt(point: self.view.center)
            self.flashBtn.isHidden = !self.flashSwitch;
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    func getCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    func takeImage() {
        guard ADPhotoManager.cameraAuthority() && !isTakingPhoto else {
            return
        }
        guard let imageOutput = imageOutput else {
            return
        }
        guard session.outputs.contains(imageOutput) else {
            ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.cameraUnavailable.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
            return
        }
        isTakingPhoto = true
        
        let connection = imageOutput.connection(with: .video)
        connection?.videoOrientation = getOrientation()
        if captureInput?.device.position == .front, connection?.isVideoMirroringSupported == true {
            connection?.isVideoMirrored = captureConfig.videoMirrored
        }
        let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])
        if captureInput?.device.hasFlash == true, flashBtn.isSelected {
            setting.flashMode = .on
        } else {
            setting.flashMode = .off
        }
        
        imageOutput.capturePhoto(with: setting, delegate: self)
    }
    
    func startRecord() {
        guard let fileOutput = fileOutput, !fileOutput.isRecording else {
            return
        }
        guard session.outputs.contains(fileOutput) else {
            ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.cameraUnavailable.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
            return
        }
        closeBtn.isHidden = true
        flashBtn.isHidden = true
        
        let connection = fileOutput.connection(with: .video)
        connection?.videoScaleAndCropFactor = 1
        connection?.videoOrientation = getOrientation()
        // 解决不同系统版本,因为录制视频编码导致安卓端无法播放的问题
        if #available(iOS 11.0, *),
           fileOutput.availableVideoCodecTypes.contains(.h264),
           let connection = connection {
            fileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.h264], for: connection)
        }
        // 解决前置摄像头录制视频时候左右颠倒的问题
        if captureInput?.device.position == .front {
            // 镜像设置
            if connection?.isVideoMirroringSupported == true {
                connection?.isVideoMirrored = captureConfig.videoMirrored
            }
            closeTorch()
        } else {
            openTorch()
        }
        let path = NSTemporaryDirectory().appendingFormat("%@.mp4", UUID().uuidString)
        fileOutput.startRecording(to: URL(fileURLWithPath: path), recordingDelegate: self)
    }
    
    func stopRecord() {
        guard let fileOutput = fileOutput, fileOutput.isRecording else {
            return
        }
        closeTorch()
        restartRecord = false
        fileOutput.stopRecording()
    }
    
    func finishRecord() {
        sessionQueue.async {
            self.session.stopRunning()
            self.refreshUI()
        }
        if recordInfos.count > 1 {
            let hud = ADProgress.progressHUD()
            hud.show(timeout: 0)
            mergeVideos(fileURLs: recordInfos.map { $0.0 }) { [weak self] url in
                hud.hide()
                self?.videoURL = url
                if let url = url {
                    self?.playVideo(fileURL: url)
                }else if let strong = self {
                    ADAlert.alert().alert(on: strong, title: nil, message: "video merge failed", actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                }
                self?.recordInfos.forEach { try? FileManager.default.removeItem(at: $0.0) }
                self?.recordInfos.removeAll()
            }
        }else{
            videoURL = recordInfos[0].0
            playVideo(fileURL: videoURL!)
            recordInfos.removeAll()
        }
    }
    
    func playVideo(fileURL: URL) {
        videoPlayLayer?.isHidden = false
        let player = AVPlayer(url: fileURL)
        player.automaticallyWaitsToMinimizeStalling = false
        videoPlayLayer?.player = player
        player.play()
    }
    
    func focusAt(point: CGPoint) {
        guard !isFocusPoint else {
            return
        }
        guard let device = captureInput?.device else {
            return
        }
        isFocusPoint = true
        let cameraPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(captureConfig.focusMode.focusMode) {
                device.focusMode = captureConfig.focusMode.focusMode
            }
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = cameraPoint
            }
            if device.isExposureModeSupported(captureConfig.exposureMode.exposureMode) {
                device.exposureMode = captureConfig.exposureMode.exposureMode
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = cameraPoint
            }
            
            device.unlockForConfiguration()
        } catch {
            print("相机聚焦设置失败 \(error.localizedDescription)")
        }
        focusView.layer.removeAllAnimations()
        focusView.center = point
        focusView.alpha = 0
        focusView.transform = CGAffineTransformMakeScale(2, 2)
        
        UIView.animate(withDuration: 0.25) {
            self.focusView.alpha = 1
            self.focusView.transform = CGAffineTransformIdentity
        } completion: { finish in
            UIView.animate(withDuration: 0.25, delay: 0.25) {
                self.focusView.alpha = 0
                self.isFocusPoint = false
            }
        }
    }
    
    enum ZoomFactor {
        case raw(CGFloat)
        case factor(CGFloat)
    }
    
    func setZoomFactor(value: ZoomFactor) {
        guard let device = captureInput?.device else {
            return
        }
        var maxValue: CGFloat = 1
        if #available(iOS 11.0, *) {
            maxValue = min(15, device.maxAvailableVideoZoomFactor)
        } else {
            maxValue = min(15, device.activeFormat.videoMaxZoomFactor)
        }
        var zoom: CGFloat = 1
        switch value {
        case let .raw(v):
            zoom = v
        case let .factor(v):
            zoom = maxValue * v
        }
        zoom = max(1, min(zoom, maxValue))
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoom
            device.unlockForConfiguration()
        } catch {
            print("调整焦距失败 \(error.localizedDescription)")
        }
    }
    
    func openTorch() {
        guard flashBtn.isSelected,
              captureDevice?.isTorchAvailable == true,
              captureDevice?.torchMode == .off else {
            return
        }
        
        sessionQueue.async { [weak self] in
            do {
                try self?.captureDevice?.lockForConfiguration()
                self?.captureDevice?.torchMode = .on
                self?.captureDevice?.unlockForConfiguration()
            } catch {
                print("打开手电筒失败 \(error.localizedDescription)")
            }
        }
    }
    
    func closeTorch() {
        guard flashBtn.isSelected,
              captureDevice?.isTorchAvailable == true,
              captureDevice?.torchMode == .on else {
            return
        }
        
        sessionQueue.async { [weak self] in
            do {
                try self?.captureDevice?.lockForConfiguration()
                self?.captureDevice?.torchMode = .off
                self?.captureDevice?.unlockForConfiguration()
            } catch {
                print("关闭手电筒失败 \(error.localizedDescription)")
            }
        }
    }
    
    func getOrientation() -> AVCaptureVideoOrientation {
        let x = motionManager.deviceMotion?.gravity.x ?? 0
        let y = motionManager.deviceMotion?.gravity.y ?? 0
        
        if abs(y) >= abs(x) || abs(x) < 0.45 {
            if y >= 0.45 {
                return .portraitUpsideDown
            } else {
                return .portrait
            }
        } else {
            if x >= 0 {
                return .landscapeLeft
            } else {
                return .landscapeRight
            }
        }
    }
}

private extension ADCaptureViewController {
    
    @objc
    func closeBtnAction() {
        dismiss(animated: true) { [weak self] in
            self?.cancelCapture?()
        }
    }
    
    @objc
    func doneBtnClick() {
        videoPlayLayer?.player?.pause()
        dismiss(animated: true) { [weak self] in
            self?.assetCapture?(self?.takedImageView.image, self?.videoURL)
        }
    }
    
    @objc
    func retakeBtnAction() {
        sessionQueue.async {
            self.session.startRunning()
            self.refreshUI()
        }
        if let videoURL = videoURL {
            videoPlayLayer?.player?.pause()
            videoPlayLayer?.player = nil
            videoPlayLayer?.isHidden = true
            try? FileManager.default.removeItem(at: videoURL)
        }
        videoURL = nil
    }
    
    @objc
    func flashBtnAction() {
        flashBtn.isSelected.toggle()
    }
    
    @objc
    func switchCameraBtnAction() {
        guard let input = captureInput, !restartRecord, !isSwitchCamera else {
            return
        }
        isSwitchCamera = true
        if fileOutput?.isRecording == true {
            recordingView.pauseRecordAnimation()
            restartRecord = true
        }
        sessionQueue.async { [weak self] in
            var newInput: AVCaptureDeviceInput?
            if input.device.position == .back, let front = self?.getCamera(position: .front) {
                newInput = try? AVCaptureDeviceInput(device: front)
            }else if input.device.position == .front, let back = self?.getCamera(position: .back) {
                newInput = try? AVCaptureDeviceInput(device: back)
            }
            if let newInput = newInput {
                self?.session.beginConfiguration()
                self?.session.removeInput(input)
                if self?.session.canAddInput(newInput) == true {
                    if newInput.device.supportsSessionPreset(.hd1920x1080) && self?.session.canSetSessionPreset(.hd1920x1080) == true {
                        self?.session.sessionPreset = .hd1920x1080
                    }else{
                        self?.session.sessionPreset = .photo
                    }
                    self?.session.addInput(newInput)
                    self?.captureInput = newInput
                }else{
                    self?.session.addInput(input)
                }
                self?.session.commitConfiguration()
            }
            self?.isSwitchCamera = false
        }
    }
    
    @objc
    func focusGesAction(_ sender: UITapGestureRecognizer) {
        guard session.isRunning else {
            return
        }
        let point = sender.location(in: view)
        if point.y > view.frame.height - 150 - safeAreaInsets.bottom {
            return
        }
        focusAt(point: point)
    }
    
    @objc
    func pinchGesAction(_ sender: UIPinchGestureRecognizer) {
        guard let device = captureInput?.device else {
            return
        }
        let factor: CGFloat = device.videoZoomFactor * sender.scale
        setZoomFactor(value: .raw(factor))
        sender.scale = 1
    }
}

extension ADCaptureViewController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        DispatchQueue.main.async {
            let animation = ADPhotoKitUI.animation(type: .fade, fromValue: 0, toValue: 1, duration: 0.25)
            self.previewLayer?.add(animation, forKey: nil)
        }
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        DispatchQueue.main.async {
            defer {
                self.isTakingPhoto = false
            }
            
            if photoSampleBuffer == nil || error != nil {
                print("拍照失败 \(error?.localizedDescription ?? "")")
                return
            }
            
            if let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                self.sessionQueue.async {
                    self.session.stopRunning()
                    self.refreshUI()
                }
                let image = UIImage(data: data)?.fixOrientation()
                self.takedImageView.image = image
                self.takedImageView.isHidden = false
#if Module_ImageEdit
                if let image = image {
                    let vc = ADImageEditConfigure.imageEditVC(image: image, editInfo: nil)
                    vc.cancelEdit = { [weak self] in
                        self?.retakeBtnAction()
                    }
                    vc.imageDidEdit = { [weak self] editInfo in
                        self?.takedImageView.image = editInfo.editImg
                    }
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: false, completion: nil)
                }
#endif
            } else {
                print("拍照失败，data为空")
            }
        }
    }
}


extension ADCaptureViewController: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        if restartRecord {
            restartRecord = false
            DispatchQueue.main.async {
                self.recordingView.continueRecordAnimation()
            }
        }else{
            DispatchQueue.main.async {
                self.recordingView.startRecordAnimation()
            }
        }
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        recordInfos.append((outputFileURL,output.recordedDuration.seconds))
        if restartRecord {
            startRecord()
        }else{
            DispatchQueue.main.async {
                self.recordingView.stopRecordAnimation()
            }
            setZoomFactor(value: .raw(1))
            let total = recordInfos.reduce(0) { partialResult, item in
                return partialResult + item.1
            }
            if total < Double(config.params.minRecordTime) {
                recordInfos.forEach { try? FileManager.default.removeItem(at: $0.0) }
                recordInfos.removeAll()
                DispatchQueue.main.async {
                    self.refreshUI()
                    ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.minRecordTimeTips.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                }
                return
            }
            finishRecord()
        }
    }
}

private extension ADCaptureViewController {
    func mergeVideos(fileURLs: [URL], completion: @escaping ((URL?) -> Void)) {
        let composition = AVMutableComposition()
        let assets = fileURLs.map { AVURLAsset(url: $0) }
        
        var insertTime: CMTime = .zero
        var assetVideoTracks: [AVAssetTrack] = []
        
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID())!
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())!
        
        for asset in assets {
            do {
                let timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
                if let videoTrack = asset.tracks(withMediaType: .video).first {
                    try compositionVideoTrack.insertTimeRange(
                        timeRange,
                        of: videoTrack,
                        at: insertTime
                    )
                    
                    assetVideoTracks.append(videoTrack)
                }
                
                if let audioTrack = asset.tracks(withMediaType: .audio).first {
                    try compositionAudioTrack.insertTimeRange(
                        timeRange,
                        of: audioTrack,
                        at: insertTime
                    )
                }
                
                insertTime = CMTimeAdd(insertTime, asset.duration)
            } catch {
                completion(nil)
                return
            }
        }
        
        guard assetVideoTracks.count == assets.count else {
            completion(nil)
            return
        }
        
        var size = assetVideoTracks[0].naturalSize
        if isPortraitVideoTrack(assetVideoTracks[0]) {
            swap(&size.width, &size.height)
        }
        
        var instructions: [AVMutableVideoCompositionInstruction] = []
        
        var start: CMTime = .zero
        for (index, videoTrack) in assetVideoTracks.enumerated() {
            let asset = assets[index]
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
            layerInstruction.setTransform(videoTrack.preferredTransform, at: .zero)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: start, duration: asset.duration)
            instruction.layerInstructions = [layerInstruction]
            instructions.append(instruction)
            
            start = CMTimeAdd(start, asset.duration)
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = instructions
        videoComposition.frameDuration = assetVideoTracks[0].minFrameDuration
        videoComposition.renderSize = size
        videoComposition.renderScale = 1
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1280x720) else {
            completion(nil)
            return
        }
        let path = NSTemporaryDirectory().appendingFormat("%@.mp4", UUID().uuidString)
        exportSession.outputURL = URL(fileURLWithPath: path)
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputFileType = AVFileType.mp4
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously(completionHandler: {
            let suc = exportSession.status == .completed
            if exportSession.status == .failed {
                print("video merge failed:  \(exportSession.error?.localizedDescription ?? "")")
            }
            DispatchQueue.main.async {
                completion(suc ? URL(fileURLWithPath: path) : nil)
            }
        })
    }
    
    func isPortraitVideoTrack(_ track: AVAssetTrack) -> Bool {
        let transform = track.preferredTransform
        let tfA = transform.a
        let tfB = transform.b
        let tfC = transform.c
        let tfD = transform.d
        
        if (tfA == 0 && tfB == 1 && tfC == -1 && tfD == 0) ||
            (tfA == 0 && tfB == 1 && tfC == 1 && tfD == 0) ||
            (tfA == 0 && tfB == -1 && tfC == 1 && tfD == 0) {
            return true
        } else {
            return false
        }
    }
}
