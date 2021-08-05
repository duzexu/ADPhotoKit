//
//  ADClipControllerViews.swift
//  ADPhotoKit
//
//  Created by xu on 2021/8/5.
//

import UIKit

class ADClipToolBarView: UIView {
    
    weak var ctx: UIViewController?
    
    var bottomLayer: CAGradientLayer!

    init(ctx: UIViewController) {
        self.ctx = ctx
        super.init(frame: .zero)
        clipsToBounds = false
        
        bottomLayer = CAGradientLayer()
        bottomLayer.colors = [UIColor(white: 0, alpha: 0.15).cgColor, UIColor(white: 0, alpha: 0.35).cgColor]
        bottomLayer.locations = [0, 1]
        layer.addSublayer(bottomLayer)
        
        let line = UIView()
        line.backgroundColor = UIColor(hex: 0xF0F0F0)
        addSubview(line)
        line.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1/UIScreen.main.scale)
        }
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setImage(Bundle.image(name: "close", module: .imageEdit), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.centerY.equalToSuperview()
        }
        
        let revertBtn = UIButton(type: .custom)
        revertBtn.setTitleColor(.white, for: .normal)
        revertBtn.setTitleColor(UIColor(white: 1, alpha: 0.4), for: .disabled)
        revertBtn.setTitle(ADLocale.LocaleKey.revert.localeTextValue, for: .normal)
        revertBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        revertBtn.addTarget(self, action: #selector(revertBtnAction), for: .touchUpInside)
        addSubview(revertBtn)
        revertBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(60)
            make.width.greaterThanOrEqualTo(60)
        }
        
        let doneBtn = UIButton(type: .custom)
        doneBtn.setImage(Bundle.image(name: "confirm", module: .imageEdit), for: .normal)
        doneBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        addSubview(doneBtn)
        doneBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.centerY.equalToSuperview()
        }
        
        let rotateBtn = UIButton(type: .custom)
        rotateBtn.setImage(Bundle.image(name: "rotateimage", module: .imageEdit), for: .normal)
        rotateBtn.addTarget(self, action: #selector(rotateBtnAction), for: .touchUpInside)
        addSubview(rotateBtn)
        rotateBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.top.equalToSuperview().offset(-70)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cancelBtnAction() {
        ctx?.dismiss(animated: true, completion: nil)
    }
    
    @objc func revertBtnAction() {
        
    }
    
    @objc func confirmBtnAction() {
        ctx?.dismiss(animated: true, completion: nil)
    }
    
    @objc func rotateBtnAction() {
        
    }
    
}

class ADClipDarkView: UIView {
    
    var clearRect: CGRect = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        UIColor(white: 0, alpha: 0.7).setFill()
        UIRectFill(rect)
        let cr = clearRect.intersection(rect)
        UIColor.clear.setFill()
        UIRectFill(cr)
    }
    
}

class ADClipGrideView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(1)

        context?.beginPath()
        var dw: CGFloat = 3
        for _ in 0..<4 {
            context?.move(to: CGPoint(x: rect.origin.x+dw, y: rect.origin.y+3))
            context?.addLine(to: CGPoint(x: rect.origin.x+dw, y: rect.origin.y+rect.height-3))
            dw += (rect.size.width - 6) / 3
        }

        var dh: CGFloat = 3
        for _ in 0..<4 {
            context?.move(to: CGPoint(x: rect.origin.x+3, y: rect.origin.y+dh))
            context?.addLine(to: CGPoint(x: rect.origin.x+rect.width-3, y: rect.origin.y+dh))
            dh += (rect.size.height - 6) / 3
        }

        context?.strokePath()

        context?.setLineWidth(3)

        let boldLineLength: CGFloat = 20
        // 左上
        context?.move(to: CGPoint(x: 0, y: 1.5))
        context?.addLine(to: CGPoint(x: boldLineLength, y: 1.5))

        context?.move(to: CGPoint(x: 1.5, y: 0))
        context?.addLine(to: CGPoint(x: 1.5, y: boldLineLength))

        // 右上
        context?.move(to: CGPoint(x: rect.width-boldLineLength, y: 1.5))
        context?.addLine(to: CGPoint(x: rect.width, y: 1.5))

        context?.move(to: CGPoint(x: rect.width-1.5, y: 0))
        context?.addLine(to: CGPoint(x: rect.width-1.5, y: boldLineLength))

        // 左下
        context?.move(to: CGPoint(x: 1.5, y: rect.height-boldLineLength))
        context?.addLine(to: CGPoint(x: 1.5, y: rect.height))

        context?.move(to: CGPoint(x: 0, y: rect.height-1.5))
        context?.addLine(to: CGPoint(x: boldLineLength, y: rect.height-1.5))

        // 右下
        context?.move(to: CGPoint(x: rect.width-boldLineLength, y: rect.height-1.5))
        context?.addLine(to: CGPoint(x: rect.width, y: rect.height-1.5))

        context?.move(to: CGPoint(x: rect.width-1.5, y: rect.height-boldLineLength))
        context?.addLine(to: CGPoint(x: rect.width-1.5, y: rect.height))

        context?.strokePath()

        context?.setShadow(offset: CGSize(width: 1, height: 1), blur: 0)
    }
    
}
