//
//  ADDrawColorsView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/28.
//

import UIKit

class ADLineDrawView: UIView, ADToolConfigable {
    
    var selectColor: UIColor {
        return colors[select]
    }
    
    var revokeAction: (() -> Void)?
    var lineCount: Int = 0 {
        didSet {
            revokeBtn.isEnabled = lineCount > 0
        }
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
    private var colorCells: [ADColorCell] = []

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
        revokeBtn.addTarget(self, action: #selector(revokeAction(_:)), for: .touchUpInside)
        revokeBtn.isEnabled = false
        revokeBtn.setImage(Bundle.image(name: "icons_filled_previous", module: .imageEdit), for: .normal)
        
        for (i,color) in colors.enumerated() {
            let cell = ADColorCell(color: color)
            cell.cellSelectBlock = { [weak self] index in
                self?.select = index
            }
            cell.isSelect = i == select
            cell.tag = i
            stackView.addArrangedSubview(cell)
            colorCells.append(cell)
        }
        
        stackView.addArrangedSubview(revokeBtn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return stackView.frame.contains(point)
    }
    
    @objc func revokeAction(_ sender: UIButton) {
        revokeAction?()
    }
    
}
