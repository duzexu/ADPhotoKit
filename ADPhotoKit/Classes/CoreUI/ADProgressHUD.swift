//
//  ADProgressHUDView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/24.
//

import UIKit

class ADProgressHUD: UIView, ADProgressHUDConfigurable {
    
    enum HUDStyle: Int {
        
        case light
        
        case lightBlur
        
        case dark
        
        case darkBlur
        
        func bgColor() -> UIColor {
            switch self {
            case .light:
                return .white
            case .dark:
                return .darkGray
            default:
                return .clear
            }
        }
        
        func textColor() -> UIColor {
            switch self {
            case .light, .lightBlur:
                return .black
            case .dark, .darkBlur:
                return .white
            }
        }
        
        func indicatorStyle() -> UIActivityIndicatorView.Style {
            switch self {
            case .light, .lightBlur:
                return .gray
            case .dark, .darkBlur:
                return .white
            }
        }
        
        func blurEffectStyle() -> UIBlurEffect.Style? {
            switch self {
            case .light, .dark:
                return nil
            case .lightBlur:
                return .extraLight
            case .darkBlur:
                return .dark
            }
        }
        
    }
    
    let style: HUDStyle
    
    var timeoutBlock: (() -> Void)?
    
    init(style: HUDStyle = .lightBlur) {
        self.style = style
        super.init(frame: UIScreen.main.bounds)
        self.setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cleanTimer()
    }
    
    func show(timeout: TimeInterval = 0) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self)
        }
        if timeout > 0 {
            cleanTimer()
            timer = Timer.scheduledTimer(timeInterval: timeout, target: ADWeakProxy(target: self), selector: #selector(timeout(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timer!, forMode: .default)
        }
    }
    
    func hide() {
        cleanTimer()
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    
    private var timer: Timer?
}

private extension ADProgressHUD {
    
    func setupUI() {
        let view = UIView(frame: .zero)
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        view.backgroundColor = style.bgColor()
        view.alpha = 0.8
        addSubview(view)
        view.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 110, height: 90))
        }
        
        if style == .lightBlur || style == .darkBlur {
            let effect = UIBlurEffect(style: style.blurEffectStyle()!)
            let effectView = UIVisualEffectView(effect: effect)
            view.addSubview(effectView)
            effectView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        let indicator = UIActivityIndicatorView(style: style.indicatorStyle())
        indicator.startAnimating()
        view.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
        }
        
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.textColor = style.textColor()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = ADLocale.LocaleKey.hudProcessing.localeTextValue
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.left.right.equalToSuperview()
        }
    }
    
    @objc func timeout(_ timer: Timer) {
        timeoutBlock?()
        hide()
    }
    
    func cleanTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
