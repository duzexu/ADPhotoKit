//
//  ADEraserButton.swift
//  ADPhotoKit
//
//  Created by du on 2024/8/10.
//

import UIKit

class ADEraserButton: UIView {
    
    public var isSelected: Bool {
        set {
            eraserBtn.isSelected = newValue
            blurBgView.isHidden = !newValue
        }
        get {
            return eraserBtn.isSelected
        }
    }
    
    public var clickAction: ((Bool) -> Void)?
    
    private var eraserBtn: UIButton!
    private var blurBgView: UIVisualEffectView!

    init() {
        super.init(frame: .zero)
        blurBgView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurBgView.clipsToBounds = true
        addSubview(blurBgView)
        blurBgView.isHidden = true
        blurBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        eraserBtn = UIButton(type: .custom)
        eraserBtn.setImage(Bundle.image(name: "icons_eraser", module: .imageEdit), for: .normal)
        eraserBtn.setImage(Bundle.image(name: "icons_eraser", module: .imageEdit), for: .highlighted)
        eraserBtn.addTarget(self, action: #selector(eraserBtnAction), for: .touchUpInside)
        addSubview(eraserBtn)
        eraserBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(hex: 0x595E6B, alpha: 0.8)
        addSubview(line)
        line.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.snp.right).offset(10)
            make.width.equalTo(1)
            make.height.equalTo(20)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurBgView.layer.cornerRadius = bounds.width / 2.0
    }
    
}

extension ADEraserButton {
    @objc func eraserBtnAction() {
        isSelected = !isSelected
        clickAction?(isSelected)
    }
}
