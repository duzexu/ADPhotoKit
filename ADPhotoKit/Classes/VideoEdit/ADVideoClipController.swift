//
//  ADVideoClipController.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/7.
//

import UIKit
import AVFoundation

class ADVideoClipController: UIViewController {
    
    let asset: AVAsset
    weak var videoPlayer: ADVideoPlayable?
    let minValue: CGFloat?
    let maxValue: CGFloat?
    
    private var progressBar: ADVideoClipProgressBar!
    
    init(asset: AVAsset, videoPlayer: ADVideoPlayable?, min: CGFloat? = nil, max: CGFloat? = nil) {
        self.asset = asset
        self.videoPlayer = videoPlayer
        self.minValue = min
        self.maxValue = max
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    

}

extension ADVideoClipController {
    func setupUI() {
        view.backgroundColor = .black
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
        
        if let player = videoPlayer {
            view.addSubview(player)
            player.snp.makeConstraints({ make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 25, bottom: 80+safeAreaInsets.bottom, right: 25))
            })
        }
        
        progressBar = ADVideoClipProgressBar(asset: asset, min: minValue, max: maxValue)
        progressBar.timeRangeChanged = { [weak self] range in
            self?.videoPlayer?.setClipRange(range)
        }
        progressBar.seekTimeReview = { [weak self] time in
            self?.videoPlayer?.seek(to: time, pause: true)
        }
        view.addSubview(progressBar)
        progressBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(45)
            make.right.equalToSuperview().offset(-45)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-78-safeAreaInsets.bottom)
        }
        
        videoPlayer?.addProgressObserver { [weak self] progress in
            self?.progressBar.progerss = progress
        }
    }
    
    @objc
    func cancelBtnAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func doneBtnAction() {
        dismiss(animated: true, completion: nil)
    }
}
