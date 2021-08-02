//
//  ADDrawColorsView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/28.
//

import UIKit

class ADDrawColorsView: UIView, ADToolConfigable {
    
    class ColorCell: UIView {
        
        var isSelect: Bool = false {
            didSet {
                bgView.transform = isSelect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            }
        }
        
        private var bgView: UIView!
        
        init(color: UIColor) {
            super.init(frame: .zero)
            bgView = UIView()
            bgView.backgroundColor = .white
            bgView.layer.masksToBounds = true
            bgView.layer.cornerRadius = 11
            addSubview(bgView)
            bgView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 22, height: 22))
            }
            
            let center = UIView()
            center.backgroundColor = color
            center.layer.masksToBounds = true
            center.layer.cornerRadius = 9
            addSubview(center)
            center.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 18, height: 18))
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var selectColor: UIColor {
        return colors[select]
    }
    
    let colors: [UIColor]
    var select: Int = 0 {
        didSet {
            for (i,cell) in colorCells.enumerated() {
                cell.isSelect = i == select
            }
        }
    }
    
    private var stackView: UIStackView!
    private var revokeBtn: UIButton!
    private var colorCells: [ColorCell] = []

    init(colors: [UIColor], select: Int) {
        self.colors = colors
        self.select = select
        super.init(frame: .zero)
        
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottomMargin).offset(-64)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(30)
        }
        
        revokeBtn = UIButton(type: .custom)
        revokeBtn.setImage(Bundle.image(name: "revoke", module: .imageEdit), for: .normal)
        
        for (i,color) in colors.enumerated() {
            let cell = ColorCell(color: color)
            cell.isSelect = i == select
            stackView.addArrangedSubview(cell)
            colorCells.append(cell)
        }
        
        stackView.addArrangedSubview(revokeBtn)
    }
    
    func singleTap(with point: CGPoint) -> Bool {
        if stackView.frame.contains(point) {
            let sub = convert(point, to: stackView)
            if revokeBtn.frame.contains(sub) {
                print("点击撤销")
                return true
            }
            for (i,cell) in colorCells.enumerated() {
                if cell.frame.contains(sub) {
                    select = i
                    return true
                }
            }
        }
        return false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
