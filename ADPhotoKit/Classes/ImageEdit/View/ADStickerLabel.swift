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

enum RoundStyle {
    ///╭ ┃
    ///━━╋━━
    ///  ┃
    case leftTop(CGPoint)
    ///  ┃ ╮
    ///━━╋━━
    ///  ┃
    case rightTop(CGPoint)
    ///  ┃
    ///━━╋━━
    ///  ┃ ╯
    case rightBottom(CGPoint)
    ///  ┃
    ///━━╋━━
    ///╰ ┃
    case leftBottom(CGPoint)
    ///  ┃
    ///━━╋━━
    ///  ┃ ╭
    case inverseLeftTop(CGPoint)
    ///  ┃ ╰
    ///━━╋━━
    ///  ┃
    case inverseLeftBottom(CGPoint)
    ///
    case leftSemicircle(CGPoint)
    
    typealias RoundStyleInfo = (cPos: CGPoint, sPos: CGPoint, ePos: CGPoint, sAngle: CGFloat, eAngle: CGFloat, clockwise: Bool)
    
    func infoWith(radius: CGFloat) -> RoundStyleInfo {
        switch self {
        case let .leftTop(center):
            let start = CGPoint(x: center.x - radius, y: center.y)
            let end = CGPoint(x: center.x, y: center.y - radius)
            return (center,start,end,CGFloat.pi,1.5*CGFloat.pi,false)
        case let .rightTop(center):
            let start = CGPoint(x: center.x, y: center.y - radius)
            let end = CGPoint(x: center.x + radius, y: center.y)
            return (center,start,end,CGFloat.pi*1.5,0,false)
        case let .rightBottom(center):
            let start = CGPoint(x: center.x + radius, y: center.y)
            let end = CGPoint(x: center.x, y: center.y + radius)
            return (center,start,end,0,0.5*CGFloat.pi,false)
        case let .leftBottom(center):
            let start = CGPoint(x: center.x, y: center.y + radius)
            let end = CGPoint(x: center.x - radius, y: center.y)
            return (center,start,end,CGFloat.pi*0.5,CGFloat.pi,false)
        case let .inverseLeftTop(center):
            let start = CGPoint(x: center.x, y: center.y - radius)
            let end = CGPoint(x: center.x - radius, y: center.y)
            return (center,start,end,CGFloat.pi*1.5,CGFloat.pi,true)
        case let .inverseLeftBottom(center):
            let start = CGPoint(x: center.x - radius, y: center.y)
            let end = CGPoint(x: center.x, y: center.y + radius)
            return (center,start,end,CGFloat.pi,0.5*CGFloat.pi,true)
        case let .leftSemicircle(center):
            let start = CGPoint(x: center.x, y: center.y - radius)
            let end = CGPoint(x: center.x, y: center.y + radius)
            return (center,start,end,CGFloat.pi*1.5,0.5*CGFloat.pi,true)
        }
    }
    
}

enum Point {
    case round(radius: CGFloat, style: RoundStyle)
    case straight(CGPoint)
}

struct Border {
    let width: CGFloat
    let margin: CGFloat
}

class ADTextStickerInputView: UIView {
    
    var color: ADTextStickerColor {
        didSet {
            update()
        }
    }
    
    var mode: ADTextSticker.Mode {
        didSet {
            update()
        }
    }
    
    let width: CGFloat
    let margin: CGFloat
    
    private var text: String? {
        didSet {
            update()
        }
    }
    
    private var framesetter: CTFramesetter?
    private var contentSize: CGSize = .zero
    
    private var textLabel: ADTextStickerLabel!
    private var borderView: ADTextStickerLabelBorder!

    init(width: CGFloat, border: Border, sticker: ADTextSticker) {
        self.width = width
        self.margin = border.margin
        self.color = sticker.color
        self.mode = sticker.mode
        self.text = sticker.text
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
        
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    func update() {
        var foregroundColor: UIColor
        var borderColor: UIColor
        switch mode {
        case .normal:
            foregroundColor = color.textColor
            borderColor = color.bgColor
        case .border:
            foregroundColor = color.bgColor
            borderColor = color.textColor
        }
        let attributeString = NSAttributedString(string: text ?? "", attributes: [.font:UIFont.systemFont(ofSize: 29),.foregroundColor:foregroundColor])
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
        borderView.isHidden = mode == .normal
        borderView.borderInfo = (rects,borderColor)
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
    
    var borderInfo: (lineRects:[CGRect],color:UIColor) = ([],UIColor.clear) {
        didSet {
            reloadBorder()
        }
    }
    
    let border: Border
    
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
        for i in 0..<borderInfo.lineRects.count {
            let rect = borderInfo.lineRects[i]
            if i == 0 {
                corners.append(Corner(point: CGPoint(x: border.width, y: border.width), quadrant: .rightBottom))
                corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+rect.width, y: border.width), quadrant: .leftBottom))
            }else{
                let last = borderInfo.lineRects[i-1]
                let diff = rect.maxX-last.maxX
                if diff > border.width {
                    corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+last.width, y: border.width+last.maxY), quadrant: .leftTop))
                    corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+rect.width, y: border.width+rect.minY), quadrant: .leftBottom))
                }else if diff < -border.width {
                    corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+last.width, y: border.width+last.maxY), quadrant: .leftTop))
                    corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+rect.width, y: border.width+rect.minY), quadrant: .leftBottom))
                }
                if i == borderInfo.lineRects.count-1 {
                    corners.append(Corner(point: CGPoint(x: border.margin*2+border.width+rect.width, y: border.width+rect.maxY), quadrant: .leftTop))
                    corners.append(Corner(point: CGPoint(x: border.width, y: border.width+rect.maxY), quadrant: .rightTop))
                }
            }
        }
        points.removeAll()
        var jump: Bool = false
        for (i,item) in corners.enumerated() {
            if i == 0 {
                points.append(.round(radius: border.width, style: .leftTop(item.point)))
            }else if i == 1 {
                points.append(.round(radius: border.width, style: .rightTop(item.point)))
            }else if i == corners.count-1 {
                points.append(.round(radius: border.width, style: .leftBottom(item.point)))
            }else if i == corners.count-2 {
                points.append(.round(radius: border.width, style: .rightBottom(item.point)))
            }else{
                if jump {
                    jump = false
                    continue
                }
                let last = corners[i-1]
                let next = corners[i+1]
                switch item.quadrant {
                case .leftTop:
                    let offX = item.point.x - next.point.x
                    if offX < 0 {
                        if -offX >= border.width*2 {
                            let point = CGPoint(x: item.point.x+border.width*2, y: next.point.y-border.width*2)
                            points.append(.round(radius: border.width, style: .inverseLeftBottom(point)))
                        }else{
                            let point = CGPoint(x: item.point.x+border.width, y: next.point.y-border.width)
                            points.append(.straight(point))
                        }
                    }else{
                        points.append(.round(radius: border.width, style: .rightBottom(item.point)))
                    }
                case .leftBottom:
                    let offX = item.point.x - last.point.x
                    if offX < 0 {
                        if -offX >= border.width*2 {
                            if i+2 < corners.count-2 {
                                let nn = corners[i+2]
                                let radius = (nn.point.y-last.point.y-border.width*2)/2
                                if nn.point.x > next.point.x && nn.point.x-next.point.x > radius+border.width {
                                    let point = CGPoint(x: item.point.x+radius+border.width, y: last.point.y+(nn.point.y-last.point.y)/2)
                                    points.append(.round(radius: border.width, style: .leftSemicircle(point)))
                                    jump = true
                                    continue
                                }
                            }
                            let point = CGPoint(x: item.point.x+border.width*2, y: last.point.y+border.width*2)
                            points.append(.round(radius: border.width, style: .inverseLeftTop(point)))
                        }else{
                            let point = CGPoint(x: item.point.x+border.width, y: last.point.y+border.width)
                            points.append(.straight(point))
                        }
                    }else{
                        points.append(.round(radius: border.width, style: .rightTop(item.point)))
                    }
                default:
                    break
                }
            }
        }
        for item in points {
            switch item {
            case let .round(radius, style):
                let info = style.infoWith(radius: radius)
                let s = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 2, height: 2)))
                s.backgroundColor = .red
                addSubview(s)
                s.center = info.sPos
                
                let e = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 2, height: 2)))
                e.backgroundColor = .blue
                addSubview(e)
                e.center = info.ePos
            case let .straight(center):
                let v = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 4, height: 4)))
                v.backgroundColor = .green
                addSubview(v)
                v.center = center
            }
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setFillColor(borderInfo.color.cgColor)
        for (i,item) in points.enumerated() {
            switch item {
            case let .round(radius, style):
                let info = style.infoWith(radius: radius)
                if i == 0 {
                    context.move(to: info.sPos)
                    context.addArc(center: info.cPos, radius: radius, startAngle: info.sAngle, endAngle: info.eAngle, clockwise: info.clockwise)
                }else{
                    context.addLine(to: info.sPos)
                    context.addArc(center: info.cPos, radius: radius, startAngle: info.sAngle, endAngle: info.eAngle, clockwise: info.clockwise)
                }
            case let .straight(pos):
                if i == 0 {
                    context.move(to: pos)
                }else{
                    context.addLine(to: pos)
                }
            }
        }
        context.closePath()
        context.fillPath()
    }
}
