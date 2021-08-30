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
    
    var startAngle: CGFloat {
        switch self {
        case .leftTop:
            return CGFloat.pi
        case .rightTop:
            return -CGFloat.pi/2
        case .rightBottom:
            return 0
        case .leftBottom:
            return CGFloat.pi/2
        }
    }
    
    var endAngle: CGFloat {
        switch self {
        case .leftTop:
            return -CGFloat.pi/2
        case .rightTop:
            return 0
        case .rightBottom:
            return CGFloat.pi/2
        case .leftBottom:
            return CGFloat.pi
        }
    }
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

enum RoundStyle {
    ///╭ ┃
    ///━━╋━━
    ///  ┃
    case leftTop(s: CGPoint, e: CGPoint)
    ///  ┃ ╮
    ///━━╋━━
    ///  ┃
    case rightTop(s: CGPoint, e: CGPoint)
    ///  ┃
    ///━━╋━━
    ///  ┃ ╯
    case rightBottom(s: CGPoint, e: CGPoint)
    ///  ┃
    ///━━╋━━
    ///╰ ┃
    case leftBottom(s: CGPoint, e: CGPoint)
    ///  ┃
    ///━━╋━━
    ///  ┃ ╭
    case inverseLeftTop(s: CGPoint, e: CGPoint)
    ///  ┃ ╰
    ///━━╋━━
    ///  ┃
    case inverseLeftBottom(s: CGPoint, e: CGPoint)
    ///
    case leftSemicircle(s: CGPoint, e: CGPoint)
}

enum Point {
    case round(center: CGPoint, radius: CGFloat, style: RoundStyle)
    case straight(CGPoint)
}

struct Border {
    let width: CGFloat
    let margin: CGFloat
}

class ADTextStickerInputView: UIView {
    
    let attributeString: NSAttributedString
    let width: CGFloat
    let margin: CGFloat
    
    private var framesetter: CTFramesetter?
    private var contentSize: CGSize = .zero
    
    private var textLabel: ADTextStickerLabel!
    private var borderView: ADTextStickerLabelBorder!

    init(attributeString: NSAttributedString, width: CGFloat, border: Border) {
        self.attributeString = attributeString
        self.width = width
        self.margin = border.margin
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
        
        let topBottom = border.width
        let leftRight = border.margin+border.width
        borderView = ADTextStickerLabelBorder(border: border)
        borderView.backgroundColor = .clear
        addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: -topBottom, left: -leftRight, bottom: -topBottom, right: -leftRight))
        }
        
        textLabel = ADTextStickerLabel()
        textLabel.backgroundColor = .clear
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(border.margin)
            make.right.equalToSuperview().offset(-border.margin)
        }
        
        update(string: attributeString)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    func update(string: NSAttributedString) {
        framesetter = CTFramesetterCreateWithAttributedString(attributeString)
        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter!, CFRange(), nil, CGSize(width: width, height: CGFloat.infinity), nil)
        contentSize = CGSize(width: width, height: frameSize.height)
        UIGraphicsBeginImageContext(contentSize)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let ctframe = CTFramesetterCreateFrame(framesetter!, CFRange(), CGPath(rect: CGRect(origin: .zero, size: frameSize), transform: nil), nil)
        textLabel.ctframe = ctframe
        let lines = CTFrameGetLines(ctframe) as? [CTLine]
        var rects: [CGRect] = []
        if let lines = lines  {
            let origins = [CGPoint](unsafeUninitializedCapacity: lines.count, initializingWith: { bufferPointer, count in
                CTFrameGetLineOrigins(ctframe, CFRange(), bufferPointer.baseAddress!)
                count = lines.count
            })
            for (i,line) in lines.enumerated() {
                var lineBounds = CTLineGetImageBounds(line, context)
                lineBounds.origin.x += origins[i].x
                lineBounds.origin.y += origins[i].y
                lineBounds.origin.y = contentSize.height - lineBounds.origin.y - lineBounds.height
                rects.append(lineBounds)
            }
        }
        borderView.lineRects = rects
        UIGraphicsEndImageContext()
        invalidateIntrinsicContentSize()
    }
    
}

class ADTextStickerLabel: UIView {
    
    var ctframe: CTFrame? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let fr = ctframe else {
            return
        }
        let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: bounds.height)
        context.concatenate(transform)
        CTFrameDraw(fr, context)
    }
    
}

class ADTextStickerLabelBorder: UIView {
    
    var lineRects: [CGRect] = [] {
        didSet {
            reloadBorder()
        }
    }
    
    let border: Border
    
    var roundCorners: [RoundCorner] = []
    var points: [Point] = []
    
    init(border: Border) {
        self.border = border
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadBorder() {
        var corners: [Corner] = []
        for i in 0..<lineRects.count {
            let rect = lineRects[i]
            if i == 0 {
                corners.append(Corner(point: CGPoint(x: border.width, y: border.width), quadrant: .leftTop))
                corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+rect.width, y: border.width), quadrant: .rightTop))
            }else{
                let last = lineRects[i-1]
                let diff = rect.maxX-last.maxX
                if diff > border.width {
                    corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+last.width, y: border.width+last.maxY), quadrant: .leftBottom))
                    corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+rect.width, y: border.width+rect.minY), quadrant: .rightTop))
                }else if diff < -border.width {
                    corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+last.width, y: border.width+last.maxY), quadrant: .rightBottom))
                    corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+rect.width, y: border.width+rect.minY), quadrant: .leftTop))
                }
                if i == lineRects.count-1 {
                    corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+rect.width, y: border.width+rect.maxY), quadrant: .rightBottom))
                    corners.append(Corner(point: CGPoint(x: border.width, y: border.width+rect.maxY), quadrant: .leftBottom))
                }
            }
        }
        roundCorners.removeAll()
        for item in corners {
            var start: CGPoint!
            var end: CGPoint!
            switch item.quadrant {
            case .leftTop:
                start = CGPoint(x: item.point.x - border.width, y: item.point.y)
                end = CGPoint(x: item.point.x, y: item.point.y - border.width)
            case .rightTop:
                start = CGPoint(x: item.point.x, y: item.point.y - border.width)
                end = CGPoint(x: item.point.x + border.width, y: item.point.y)
            case .rightBottom:
                start = CGPoint(x: item.point.x + border.width, y: item.point.y)
                end = CGPoint(x: item.point.x, y: item.point.y + border.width)
            case .leftBottom:
                start = CGPoint(x: item.point.x, y: item.point.y + border.width)
                end = CGPoint(x: item.point.x - border.width, y: item.point.y)
            }
            let roundCorner = RoundCorner(corner: item, start: start, end: end, radius: border.width)
            roundCorners.append(roundCorner)
        }
        points.removeAll()
        
        for item in roundCorners {
            let v = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 2, height: 2)))
            v.backgroundColor = .red
            addSubview(v)
            v.center = item.start
            
            let e = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 2, height: 2)))
            e.backgroundColor = .blue
            addSubview(e)
            e.center = item.end
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setFillColor(UIColor(white: 1, alpha: 0.5).cgColor)
        for (i,item) in roundCorners.enumerated() {
            if i == 0 {
                context.move(to: item.start)
                context.addArc(center: item.corner.point, radius: item.radius, startAngle: item.corner.quadrant.startAngle, endAngle: item.corner.quadrant.endAngle, clockwise: false)
            }else if i == roundCorners.count-1 {
                context.addLine(to: item.start)
                context.addArc(center: item.corner.point, radius: item.radius, startAngle: item.corner.quadrant.startAngle, endAngle: item.corner.quadrant.endAngle, clockwise: false)
                context.closePath()
            }else{
                context.addLine(to: item.start)
                context.addArc(center: item.corner.point, radius: item.radius, startAngle: item.corner.quadrant.startAngle, endAngle: item.corner.quadrant.endAngle, clockwise: false)
            }
        }
        context.fillPath()
    }
}
