//
//  ProgressHUD.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class CustomProgressHUD: UIView, ADProgressHUDConfigurable {
    
    var timeoutBlock: (() -> Void)?
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.layer.cornerRadius = 10
        addSubview(view)
        view.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        let indi = UIActivityIndicatorView(style: .whiteLarge)
        indi.startAnimating()
        view.addSubview(indi)
        indi.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cleanTimer()
    }
    
    private var timer: Timer?
    
    func show(timeout: TimeInterval) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self)
        }
        if timeout > 0 {
            cleanTimer()
            timer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(timeout(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timer!, forMode: .default)
        }
    }
    
    func hide() {
        cleanTimer()
        DispatchQueue.main.async {
            self.removeFromSuperview()
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
