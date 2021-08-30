//
//  ADTextStickerEditController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/27.
//

import UIKit

class ADTextStickerEditController: UIViewController, ADTextStickerEditConfigurable {
    
    var textDidEdit: ((String, ADTextStickerColor) -> Void)?
    
    let text: String?
    var color: ADTextStickerColor!
    
    private var colorsView: UIView!
    private var stackView: UIStackView!
    
    init(text: String? = nil, color: ADTextStickerColor? = nil) {
        self.text = text
        if ADPhotoKitConfiguration.default.textStickerDefaultColorIndex > ADPhotoKitConfiguration.default.textStickerColors.count {
            fatalError("`textStickerDefaultColorIndex` must less then `textStickerColors`'s count")
        }
        self.color = color ?? ADPhotoKitConfiguration.default.textStickerColors[ADPhotoKitConfiguration.default.textStickerDefaultColorIndex]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

private extension ADTextStickerEditController {
    func setupUI() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        let top = isPhoneX ? 7 + statusBarHeight : 7
        
        let cancelBtn = UIButton(type: .custom)
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
        
        let confirmBtn = UIButton(type: .custom)
        confirmBtn.setTitle(ADLocale.LocaleKey.done.localeTextValue, for: .normal)
        confirmBtn.setBackgroundImage(UIImage.image(color: UIColor(hex: 0x50A938)!), for: .normal)
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
        
        colorsView = UIView()
        view.addSubview(colorsView)
        colorsView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        let switchBtn = UIButton(type: .custom)
        switchBtn.setImage(Bundle.image(name: "icons_outlined_text", module: .imageEdit), for: .normal)
        switchBtn.setImage(Bundle.image(name: "icons_filled_text", module: .imageEdit), for: .selected)
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
        for (i,color) in colors.enumerated() {
            let cell = ADColorCell(color: color.textColor)
            cell.isSelect = ADPhotoKitConfiguration.default.textStickerDefaultColorIndex == i
            stackView.addArrangedSubview(cell)
        }
        
        let string = NSAttributedString(string: "hhahhsahdahd阿萨德卡的好看见那，阿萨德你去问那看来你这些处女座\n那倒是\n奥斯卡大道mdasd", attributes: [.font:UIFont.systemFont(ofSize: 29),.foregroundColor:UIColor.white])
        let label = ADTextStickerInputView(attributeString: string, width: screenWidth-50, border: Border(width: 12, margin: 4))
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            //make.edges.equalToSuperview().inset(UIEdgeInsets(top: 100, left: 20, bottom: 100, right: 20))
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        stackView.addGestureRecognizer(singleTap)
    }
    
    @objc func cancelBtnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func confirmBtnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: stackView)
        for (i,cell) in stackView.arrangedSubviews.enumerated() {
            if cell.frame.contains(point) {
                (cell as! ADColorCell).isSelect = true
                color = ADPhotoKitConfiguration.default.textStickerColors[i]
            }else{
                (cell as! ADColorCell).isSelect = false
            }
        }
    }
}

extension ADTextStickerEditController {
    
}
