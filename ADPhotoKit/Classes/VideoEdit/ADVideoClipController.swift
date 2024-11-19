//
//  ADVideoClipController.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/7.
//

import UIKit
import AVFoundation

/// Video clip info.
public struct ADVideoClipInfo {
    
    /// Origin video asset.
    public let asset: AVAsset
    
    /// Normalized min video edit time. `nil` means no limit.
    public let normalizeMinTime: CGFloat?
    /// Normalized max video edit time. `nil` means no limit.
    public let normalizeMaxTime: CGFloat?
    
    /// Video clip range.
    public var clipRange: CMTimeRange?
}

class ADVideoClipController: UIViewController, ADVideoClipConfigurable {
    
    let clipInfo: ADVideoClipInfo
    
    var clipCancel: (() -> Void)?
    var clipRangeChange: ((CMTimeRange) -> Void)?
    var clipRangeConfirm: (() -> Void)?
    var seekReview: ((CMTime) -> Void)?
    
    private var clipProgressBar: ADVideoClipProgressBar?
    
    required init(clipInfo: ADVideoClipInfo) {
        self.clipInfo = clipInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
        }
    }
    
    func updateProgress(_ progress: CGFloat) {
        clipProgressBar?.progerss = progress
    }
    
}

extension ADVideoClipController {
    func setupUI() {
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle(ADLocale.LocaleKey.cancel.localeTextValue, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 60, height: 34))
            make.bottom.equalToSuperview().offset(-safeAreaInsets.bottom-24)
        }
                
        let doneBtn = UIButton(type: .custom)
        doneBtn.addTarget(self, action: #selector(doneBtnAction), for: .touchUpInside)
        doneBtn.setBackgroundImage(UIImage.image(color: UIColor(hex: 0x10C060)!), for: .normal)
        doneBtn.setBackgroundImage(UIImage.image(color: UIColor(hex: 0x323232)!), for: .disabled)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        doneBtn.setTitle(ADLocale.LocaleKey.done.localeTextValue, for: .normal)
        doneBtn.setTitleColor(UIColor.white, for: .normal)
        doneBtn.setTitleColor(UIColor(hex: 0xA8A8A8), for: .disabled)
        doneBtn.layer.cornerRadius = 5
        doneBtn.layer.masksToBounds = true
        doneBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        view.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 60, height: 34))
            make.bottom.equalToSuperview().offset(-safeAreaInsets.bottom-24)
        }
        
        let progressBar = ADVideoClipProgressBar(clipInfo: clipInfo)
        progressBar.timeRangeChanged = { [weak self] range in
            self?.clipRangeChange?(range)
        }
        progressBar.seekTimeReview = { [weak self] time in
            self?.seekReview?(time)
        }
        view.addSubview(progressBar)
        progressBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(45)
            make.right.equalToSuperview().offset(-45)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-78-safeAreaInsets.bottom)
        }
        clipProgressBar = progressBar
    }
    
}

extension ADVideoClipController {
    @objc
    func cancelBtnAction() {
        clipCancel?()
        dismiss(animated: false, completion: nil)
    }
    
    @objc
    func doneBtnAction() {
        clipRangeConfirm?()
        dismiss(animated: false, completion: nil)
    }
}
