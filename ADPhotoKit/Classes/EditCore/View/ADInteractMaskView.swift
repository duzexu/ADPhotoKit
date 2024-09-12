//
//  ADInteractMaskView.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/7.
//

import UIKit

class ADInteractContainerView: UIView {
    
    var clipRect: CGRect = .zero {
        didSet {
            allViews.forEach { $0.clipRect = clipRect }
        }
    }
    
    var clipingScreenInfo: ADClipingInfo? = nil {
        didSet {
            allViews.forEach { $0.interactView.clipingScreenInfo = clipingScreenInfo }
        }
    }
    
    override func addSubview(_ view: UIView) {
        if let view = view as? ADInteractMaskView {
            super.addSubview(view)
        }else{
            fatalError("only can add ADInteractMaskView")
        }
    }
    
    var allViews: [ADInteractMaskView] {
        return subviews as! [ADInteractMaskView]
    }
    
    func orderInteractViews() {
        let order = allViews.sorted { v1, v2 in
            return v1.interactView.zIndex < v2.interactView.zIndex
        }
        for item in order {
            bringSubviewToFront(item)
        }
    }
    
}

class ADInteractMaskView: UIView {

    var interactView: ADToolInteractable
    
    var clipRect: CGRect = .zero {
        didSet {
            mask?.frame = clipRect
        }
    }
    
    var clipBounds: Bool = true {
        didSet {
            self.mask = clipBounds ? maskV : nil
        }
    }
    
    private let maskV = UIView()
    
    init(view: ADToolInteractable) {
        self.interactView = view
        super.init(frame: .zero)
        addSubview(interactView)
        interactView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        maskV.backgroundColor = UIColor.black
        self.mask = maskV
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
