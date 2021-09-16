//
//  ADTextStickerEditController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/27.
//

import UIKit

class ADTextStickerEditController: UIViewController, ADTextStickerEditConfigurable {
    
    var textDidEdit: ((UIImage, ADTextSticker) -> Void)?
    
    var sticker: ADTextSticker
    
    private var textInputView: ADTextStickerInputView!
    
    private var cancelBtn: UIButton!
    private var confirmBtn: UIButton!
    
    private var colorsView: UIView!
    private var stackView: UIStackView!
    
    init(sticker: ADTextSticker? = nil) {
        if ADPhotoKitConfiguration.default.textStickerDefaultColorIndex > ADPhotoKitConfiguration.default.textStickerColors.count {
            fatalError("`textStickerDefaultColorIndex` must less then `textStickerColors`'s count")
        }
        let color = ADPhotoKitConfiguration.default.textStickerColors[ADPhotoKitConfiguration.default.textStickerDefaultColorIndex]
        self.sticker = sticker ?? ADTextSticker(color: color, style: .normal, text: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textInputView.beginInput()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

private extension ADTextStickerEditController {
    func setupUI() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        let top = isPhoneX ? 7 + statusBarHeight : 7
        
        cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle(ADLocale.LocaleKey.cancel.localeTextValue, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cancelBtn.addTarget(self, action: #selector(cancelBtnAction(_:)), for: .touchUpInside)
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(top)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(34)
        }
        
        confirmBtn = UIButton(type: .custom)
        confirmBtn.setTitle(ADLocale.LocaleKey.done.localeTextValue, for: .normal)
        confirmBtn.setBackgroundImage(UIImage.image(color: UIColor(hex: 0x10C060)!), for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        confirmBtn.layer.cornerRadius = 5
        confirmBtn.layer.masksToBounds = true
        confirmBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        confirmBtn.addTarget(self, action: #selector(confirmBtnAction(_:)), for: .touchUpInside)
        view.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(top)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(34)
        }
        
        let offsetY = (screenHeight-(top+34)-(tabBarOffset+60))/2-screenHeight/2
        
        textInputView = ADTextStickerInputView(width: screenWidth-50, border: Border(width: 12, margin: 4), sticker: sticker)
        view.addSubview(textInputView)
        textInputView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(offsetY)
        }
        
        textInputView.textDidChangeBlock = { [weak self] text in
            self?.sticker.text = text
        }
        
        colorsView = UIView()
        view.addSubview(colorsView)
        colorsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-tabBarOffset)
            make.height.equalTo(60)
        }
        
        let switchBtn = UIButton(type: .custom)
        switchBtn.setImage(Bundle.image(name: "icons_outlined_text", module: .imageEdit), for: .normal)
        switchBtn.setImage(Bundle.image(name: "icons_filled_text", module: .imageEdit), for: .selected)
        switchBtn.addTarget(self, action: #selector(modeSwitchAction(_:)), for: .touchUpInside)
        colorsView.addSubview(switchBtn)
        switchBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        colorsView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalTo(switchBtn.snp.right).offset(6)
            make.right.equalToSuperview().offset(-20)
            make.top.bottom.equalToSuperview()
        }
        
        let colors = ADPhotoKitConfiguration.default.textStickerColors
        for color in colors {
            let cell = ADColorCell(color: color.primaryColor)
            cell.isSelect = color == sticker.color
            stackView.addArrangedSubview(cell)
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        singleTap.delegate = self
        view.addGestureRecognizer(singleTap)
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
}

extension ADTextStickerEditController {
    @objc func cancelBtnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func confirmBtnAction(_ sender: UIButton) {
        if let image = textInputView.stickerImage() {
            textDidEdit?(image,sticker)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func modeSwitchAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        textInputView.style = sender.isSelected ? .border : .normal
        sticker.style = textInputView.style
    }
    
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: view)
        if colorsView.frame.contains(point) {
            let pos = view.convert(point, to: stackView)
            for (i,cell) in stackView.arrangedSubviews.enumerated() {
                if cell.frame.contains(pos) {
                    (cell as! ADColorCell).isSelect = true
                    let color = ADPhotoKitConfiguration.default.textStickerColors[i]
                    textInputView.color = color
                    sticker.color = color
                }else{
                    (cell as! ADColorCell).isSelect = false
                }
            }
        }else{
            textInputView.beginInput()
        }
    }
}

extension ADTextStickerEditController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: view)
        if cancelBtn.frame.contains(point) || confirmBtn.frame.contains(point) {
            return false
        }
        return true
    }
}

extension ADTextStickerEditController {
    @objc func keyboardWillShow(_ noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let frame = (userInfo[UIApplication.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: duration) {
            self.colorsView.transform = CGAffineTransform(translationX: 0, y: tabBarOffset-frame.height)
            self.textInputView.transform = CGAffineTransform(translationX: 0, y: (tabBarOffset-frame.height)/4)
        }
    }

    @objc func keyboardWillHide(_ noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: duration) {
            self.colorsView.transform = .identity
            self.textInputView.transform = .identity
        }
    }
}
