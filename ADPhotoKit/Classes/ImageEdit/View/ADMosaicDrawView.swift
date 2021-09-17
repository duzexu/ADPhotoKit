//
//  ADMoasicControlView.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/9/12.
//

import UIKit

class ADMosaicDrawView: UIView, ADToolConfigable {

    var revokeAction: (() -> Void)?
    var lineCount: Int = 0 {
        didSet {
            revokeBtn.isEnabled = lineCount > 0
        }
    }

    private var revokeBtn: UIButton!
    
    init() {
        super.init(frame: .zero)
        
        revokeBtn = UIButton(type: .custom)
        revokeBtn.isEnabled = false
        revokeBtn.setImage(Bundle.image(name: "icons_filled_previous", module: .imageEdit), for: .normal)
        addSubview(revokeBtn)
        revokeBtn.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottomMargin).offset(-57)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
    }
    
    func singleTap(with point: CGPoint) -> Bool {
        if revokeBtn.frame.contains(point) {
            revokeAction?()
            return true
        }
        return false
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return revokeBtn.frame.contains(point)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
