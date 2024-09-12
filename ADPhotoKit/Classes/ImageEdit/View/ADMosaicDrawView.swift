//
//  ADMoasicControlView.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/9/12.
//

import UIKit

class ADMosaicDrawView: UIView, ADToolConfigable {

    var eraseAction: ((Bool) -> Void)?

    private var eraserBtn: ADEraserButton!
    
    init() {
        super.init(frame: .zero)
        
        eraserBtn = ADEraserButton()
        eraserBtn.clickAction = { [weak self] sel in
            self?.eraseAction?(sel)
        }
        addSubview(eraserBtn)
        eraserBtn.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottomMargin).offset(-64)
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return eraserBtn.frame.contains(point)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
