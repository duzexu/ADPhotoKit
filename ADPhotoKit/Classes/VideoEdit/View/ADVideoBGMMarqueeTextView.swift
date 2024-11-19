//
//  ADVideoBGMMarqueeTextView.swift
//  ADPhotoKit
//
//  Created by du on 2024/11/18.
//

import UIKit

class ADVideoBGMMarqueeTextView: UIView {
    
    var text: String? {
        set {
            textLabel.text = newValue
            textLabel.sizeToFit()
        }
        get {
            return textLabel.text
        }
    }
    
    var font: UIFont {
        set {
            textLabel.font = newValue
        }
        get {
            return textLabel.font
        }
    }
    
    var textColor: UIColor {
        set {
            textLabel.textColor = newValue
        }
        get {
            return textLabel.textColor
        }
    }
    
    var isHighlight: Bool = false {
        didSet {
            if isHighlight && textLabel.frame.width > bounds.width {
                if displayLink == nil {
                    let _displayLink = CADisplayLink(target: ADWeakProxy(target: self), selector: #selector(onScreenUpdate))
                    _displayLink.preferredFramesPerSecond = 30
                    _displayLink.add(to: .main, forMode: RunLoop.Mode.common)
                    displayLink = _displayLink
                }
            }else{
                displayLink?.invalidate()
                displayLink = nil
                textLabel.transform = .identity
                translationX = 0
            }
        }
    }

    private let textLabel: UILabel = UILabel(frame: .zero)
    private var displayLink: CADisplayLink?
    private var translationX: CGFloat = 0
    private let speed: CGFloat = 1
    private var maskLayer: CAGradientLayer!
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        maskLayer = CAGradientLayer()
        maskLayer.startPoint = CGPoint(x: 0, y: 0)
        maskLayer.endPoint = CGPoint(x: 1, y: 0)
        maskLayer.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        maskLayer.locations = [0.0, 0.9, 1.0]
        layer.mask = maskLayer
    }
    
    deinit {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = bounds
    }
    
    @objc func onScreenUpdate() {
        translationX -= speed
        if abs(translationX) >= textLabel.frame.width {
            translationX = 0
        }
        textLabel.transform = CGAffineTransform(translationX: translationX, y: 0)
    }
}
