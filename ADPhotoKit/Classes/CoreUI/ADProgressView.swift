//
//  ADProgressView.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/22.
//

import UIKit

class ADProgressView: UIView, ADProgressConfigurable {

    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var progressLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressLayer = CAShapeLayer()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 4
        
        layer.addSublayer(progressLayer)
        
        self.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = rect.width / 2
        let end = -(.pi / 2) + (.pi * 2 * self.progress)
        progressLayer.frame = self.bounds
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(.pi / 2), endAngle: end, clockwise: true)
        progressLayer.path = path.cgPath
    }

}
