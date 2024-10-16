//
//  ADPageSheetDragBar.swift
//  ADPhotoKit
//
//  Created by du on 2024/10/11.
//

import UIKit

class ADPageSheetDragBar: UIView {
    
    let threshold: CGFloat
    
    var offsetDidChange: ((CGFloat) -> Void)?
    var dragDidEnded: ((Bool) -> Void)?
    
    private var offset: CGFloat = 0
    private let indicatorOffset: CGFloat = 70
    private var dragIndicator = UIImageView()
    private var indicatorArrow = UIImageView()

    init(threshold: CGFloat) {
        self.threshold = threshold
        super.init(frame: .zero)
        dragIndicator.layer.cornerRadius = 2
        dragIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        addSubview(dragIndicator)
        dragIndicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(4)
            make.size.equalTo(CGSize(width: 40, height: 4))
        }
        indicatorArrow = UIImageView(image: Bundle.image(name: "icons_drag_arrow", module: .videoEdit))
        indicatorArrow.alpha = 0
        dragIndicator.addSubview(indicatorArrow)
        indicatorArrow.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        addGestureRecognizer(panGes)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -28, right: 0)).contains(point)
    }
    
}

extension ADPageSheetDragBar {
    @objc func panAction(_ pan: UIPanGestureRecognizer) {
        let trans = pan.translation(in: self)
        offset = max(0, offset+trans.y)
        if pan.state == .cancelled || pan.state == .ended {
            let valid = offset>=threshold
            offset = 0
            if !valid {
                updateWith(progress: 0, animated: true)
            }
            dragDidEnded?(valid)
        }else{
            offsetDidChange?(offset)
            updateWith(progress: min(offset / indicatorOffset, 1), animated: false)
        }
        pan.setTranslation(.zero, in: self)
    }
    
    func updateWith(progress: CGFloat, animated: Bool) {
        let height = 4+12*progress
        dragIndicator.snp.updateConstraints({ make in
            make.height.equalTo(height)
        })
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.dragIndicator.layer.cornerRadius = height/2
                self.indicatorArrow.alpha = progress
                self.layoutIfNeeded()
            }
        }else{
            dragIndicator.layer.cornerRadius = height/2
            indicatorArrow.alpha = progress
            layoutIfNeeded()
        }
    }
}
