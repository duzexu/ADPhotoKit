//
//  ADBrowserControlsView.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/11.
//

import UIKit

class ADBrowserControlsView: UIView {
    
    weak var topView: ADBrowserNavBarable?
    weak var bottomView: ADBrowserToolBarable?

    init(topView: ADBrowserNavBarable?, bottomView: ADBrowserToolBarable?) {
        self.topView = topView
        self.bottomView = bottomView
        super.init(frame: .zero)
        if let top = topView {
            addSubview(top)
            top.snp.makeConstraints { (make) in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(top.height)
            }
        }
        if let bottom = bottomView {
            addSubview(bottom)
            bottom.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(bottom.height)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insideTransitionArea(point: CGPoint) -> Bool {
        let top = topView?.height ?? 0
        let bottom = bottomView?.height ?? 0
        if point.y < top || point.y > frame.height - bottom {
            return false
        }
        return true
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let top = topView?.height ?? 0
        let bottom = bottomView?.height ?? 0
        if point.y < top || point.y > frame.height - bottom {
            return super.point(inside: point, with: event)
        }
        return false
    }
    
}
