//
//  ADStickerLabel.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/8/28.
//

import UIKit
import CoreText

enum Quadrant {
    case leftTop
    case rightTop
    case rightBottom
    case leftBottom
}

struct Corner {
    let point: CGPoint
    let quadrant: Quadrant
}

struct RoundCorner {
    let corner: Corner
    let start: CGPoint
    let end: CGPoint
    let radius: CGFloat
}

class ADStickerLabel: UIView {
    
    let attributeString: NSAttributedString
    let edgeInsets: UIEdgeInsets
    
    private var framesetter: CTFramesetter!
    private var contentSize: CGSize = .zero

    init(attributeString: NSAttributedString, width: CGFloat, edgeInsets: UIEdgeInsets) {
        self.attributeString = attributeString
        self.edgeInsets = edgeInsets
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
        
        framesetter = CTFramesetterCreateWithAttributedString(attributeString)
        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(), nil, CGSize(width: width, height: CGFloat.infinity), nil)
        contentSize = CGSize(width: width, height: frameSize.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setFillColor(UIColor(white: 1, alpha: 0.5).cgColor)
        
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(), CGPath(rect: rect, transform: nil), nil)
        let lines = CTFrameGetLines(frame) as? [CTLine]
        var rects: [CGRect] = []
        if let lines = lines  {
            let origins = [CGPoint](unsafeUninitializedCapacity: lines.count, initializingWith: { bufferPointer, count in
                CTFrameGetLineOrigins(frame, CFRange(), bufferPointer.baseAddress!)
                count = lines.count
            })
            for (i,line) in lines.enumerated() {
                var bounds = CTLineGetImageBounds(line, context)
                bounds.origin.x += origins[i].x
                bounds.origin.y += origins[i].y
                bounds.origin.y = self.bounds.height - bounds.origin.y - bounds.height
                rects.append(bounds)
            }
        }
        context.fill(rects)
        let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: bounds.height)
        context.concatenate(transform)
        CTFrameDraw(frame, context)
    }
    
}
