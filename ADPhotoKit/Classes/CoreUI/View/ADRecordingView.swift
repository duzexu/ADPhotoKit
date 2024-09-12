//
//  ADRecordingView.swift
//  ADPhotoKit
//
//  Created by du on 2024/6/5.
//

import UIKit

class ADRecordingView: UIView {
    
    enum VideoTakeState {
        case begin
        case change(CGFloat)
        case end
    }
    
    var takeImageAction: (() -> Void)?
    var takeVideoAction: ((ADRecordingView, VideoTakeState) -> Void)?
    var isStarted: Bool = false
    
    private let allowPhoto: Bool
    private let allowVideo: Bool
    private let maxTime: Double
    
    enum Layout {
        static let largeCircleRecordScale: CGFloat = 1.2
        static let smallCircleRecordScale: CGFloat = 0.5
        static let borderLayerWidth: CGFloat = 1.8
        static let progressLayerWidth: CGFloat = 5
        static let normalColor: UIColor = .white
        static let recodingBorderColor: UIColor = .white.withAlphaComponent(0.8)
        static let recodingProgressColor: UIColor = UIColor(hex: 0x10C060)!
    }
    
    private var borderView: UIView!
    private var borderLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    private var centerView: UIView!
    private var tipsLabel: UILabel!
    
    init(allowPhoto: Bool, allowVideo: Bool, maxTime: Double) {
        self.allowPhoto = allowPhoto
        self.allowVideo = allowVideo
        self.maxTime = maxTime
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        borderView = UIView()
        borderView.isUserInteractionEnabled = false
        borderView.backgroundColor = UIColor.clear
        addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        borderLayer = CAShapeLayer()
        borderLayer.strokeColor = Layout.normalColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = Layout.borderLayerWidth
        borderView.layer.addSublayer(borderLayer)
        progressLayer = CAShapeLayer()
        progressLayer.strokeColor = Layout.recodingProgressColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = Layout.progressLayerWidth
        progressLayer.lineCap = .round
        centerView = UIView()
        centerView.layer.masksToBounds = true
        centerView.isUserInteractionEnabled = false
        centerView.backgroundColor = Layout.normalColor
        addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(7.5)
        }
        
        var longGesture: UIGestureRecognizer?
        var panGesture: UIGestureRecognizer?
        if allowVideo {
            let longGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
            longGes.minimumPressDuration = 0.3
            longGes.delegate = self
            addGestureRecognizer(longGes)
            let panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
            panGes.delegate = self
            panGes.maximumNumberOfTouches = 1
            addGestureRecognizer(panGes)
            longGesture = longGes
            panGesture = panGes
        }
        
        if allowPhoto {
            let singleTapGes = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
            addGestureRecognizer(singleTapGes)
            if let longGes = longGesture {
                singleTapGes.require(toFail: longGes)
            }
            if let panGes = panGesture {
                singleTapGes.require(toFail: panGes)
            }
        }
        
        tipsLabel = UILabel()
        tipsLabel.font = UIFont.systemFont(ofSize: 14)
        tipsLabel.textColor = .white
        tipsLabel.textAlignment = .center
        tipsLabel.numberOfLines = 2
        tipsLabel.lineBreakMode = .byWordWrapping
        tipsLabel.alpha = 0
        addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.top).offset(-35)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(screenWidth-20)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerView.layer.cornerRadius = centerView.frame.width / 2.0
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.width), cornerRadius: frame.width / 2)
        progressLayer.path = path.cgPath
        borderLayer.path = path.cgPath
    }
    
    func showTips(text: String) {
        tipsLabel.text = text
        tipsLabel.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.25) {
            self.tipsLabel.alpha = 1
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(hideTips), with: nil, afterDelay: 3)
    }
}

extension ADRecordingView {
    func startRecordAnimation() {
        isStarted = true
        UIView.animate(withDuration: 0.1, animations: {
            self.borderView.transform = CGAffineTransformMakeScale(Layout.largeCircleRecordScale, Layout.largeCircleRecordScale)
            self.centerView.transform = CGAffineTransformMakeScale(Layout.smallCircleRecordScale, Layout.smallCircleRecordScale)
            self.borderLayer.strokeColor = Layout.recodingBorderColor.cgColor
            self.borderLayer.lineWidth = Layout.progressLayerWidth
        }) { _ in
            self.borderView.layer.addSublayer(self.progressLayer)
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = self.maxTime
            animation.delegate = self
            self.progressLayer.add(animation, forKey: nil)
        }
    }
    
    func pauseRecordAnimation() {
        if isStarted {
            let pauseTime = progressLayer.convertTime(CACurrentMediaTime(), from: nil)
            progressLayer.speed = 0
            progressLayer.timeOffset = pauseTime
        }
    }
    
    func continueRecordAnimation() {
        if isStarted {
            let time = progressLayer.timeOffset
            progressLayer.speed = 1
            progressLayer.timeOffset = 0
            progressLayer.beginTime = 0
            progressLayer.beginTime = progressLayer.convertTime(CACurrentMediaTime(), from: nil) - time
        }
    }
    
    func stopRecordAnimation() {
        isStarted = false
        borderLayer.strokeColor = Layout.normalColor.cgColor
        borderLayer.lineWidth = Layout.borderLayerWidth
        progressLayer.speed = 1
        progressLayer.timeOffset = 0
        progressLayer.beginTime = 0
        progressLayer.removeFromSuperlayer()
        progressLayer.removeAllAnimations()
        borderView.transform = .identity
        centerView.transform = .identity
    }
    
    @objc
    func hideTips() {
        tipsLabel.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.25) {
            self.tipsLabel.alpha = 0
        }
    }
}

extension ADRecordingView {
    
    @objc func singleTapAction(_ sender: UITapGestureRecognizer) {
        takeImageAction?()
    }
    
    @objc func longPressAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if !isStarted {
                guard ADPhotoManager.cameraAuthority() else {
                    return
                }
                takeVideoAction?(self, .begin)
            }
        } else if sender.state == .cancelled || sender.state == .ended {
            if isStarted {
                takeVideoAction?(self, .end)
                stopRecordAnimation()
            }
        }
    }
    
    @objc func panAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            if !isStarted {
                guard ADPhotoManager.cameraAuthority() else {
                    return
                }
                takeVideoAction?(self, .begin)
            }
        } else if sender.state == .changed {
            if isStarted {
                let point = sender.location(in: self)
                let factor = (frame.width/2 - point.y) / frame.width
                takeVideoAction?(self, .change(max(0, min(factor, 1))))
            }
        } else if sender.state == .cancelled || sender.state == .ended {
            if isStarted {
                takeVideoAction?(self, .end)
                stopRecordAnimation()
            }
        }
    }
    
}

extension ADRecordingView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if isStarted {
            takeVideoAction?(self, .end)
            stopRecordAnimation()
        }
    }
}

extension ADRecordingView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
