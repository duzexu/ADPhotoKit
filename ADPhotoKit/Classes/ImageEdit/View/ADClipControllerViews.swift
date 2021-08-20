//
//  ADClipControllerViews.swift
//  ADPhotoKit
//
//  Created by xu on 2021/8/5.
//

import UIKit

class ADClipToolBarView: UIView {
    
    enum Action {
        case cancel
        case confirm
        case revert
        case rotate
    }
        
    var actionBlock: ((Action) -> Void)?
    
    var revertBtn: UIButton!
    var rotateBtn: UIButton!
    
    private var bottomLayer: CAGradientLayer!

    init(bottomInset: CGFloat) {
        super.init(frame: .zero)
        clipsToBounds = false
        
        bottomLayer = CAGradientLayer()
        bottomLayer.frame = CGRect(x: 0, y: 0, width: 0, height: bottomInset)
        bottomLayer.colors = [UIColor(white: 0, alpha: 0).cgColor, UIColor(white: 0, alpha: 0.35).cgColor]
        bottomLayer.locations = [0, 1]
        layer.addSublayer(bottomLayer)
        
        let line = UIView()
        line.backgroundColor = UIColor(hex: 0xF0F0F0)
        addSubview(line)
        line.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1/UIScreen.main.scale)
        }
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setImage(Bundle.image(name: "close", module: .imageEdit), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.centerY.equalToSuperview()
        }
        
        revertBtn = UIButton(type: .custom)
        revertBtn.isEnabled = false
        revertBtn.setTitleColor(.white, for: .normal)
        revertBtn.setTitleColor(UIColor(white: 1, alpha: 0.4), for: .disabled)
        revertBtn.setTitle(ADLocale.LocaleKey.revert.localeTextValue, for: .normal)
        revertBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        revertBtn.addTarget(self, action: #selector(revertBtnAction), for: .touchUpInside)
        addSubview(revertBtn)
        revertBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(60)
            make.width.greaterThanOrEqualTo(60)
        }
        
        let doneBtn = UIButton(type: .custom)
        doneBtn.setImage(Bundle.image(name: "confirm", module: .imageEdit), for: .normal)
        doneBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        addSubview(doneBtn)
        doneBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.centerY.equalToSuperview()
        }
        
        rotateBtn = UIButton(type: .custom)
        rotateBtn.setImage(Bundle.image(name: "rotateimage", module: .imageEdit), for: .normal)
        rotateBtn.addTarget(self, action: #selector(rotateBtnAction), for: .touchUpInside)
        addSubview(rotateBtn)
        rotateBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.top.equalToSuperview().offset(-70)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomLayer.frame = CGRect(x: 0, y: bounds.size.height-bottomLayer.frame.size.height, width: bounds.size.width, height: bottomLayer.frame.size.height)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return rotateBtn.frame.contains(point) || bounds.contains(point)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cancelBtnAction() {
        actionBlock?(.cancel)
    }
    
    @objc func revertBtnAction() {
        actionBlock?(.revert)
    }
    
    @objc func confirmBtnAction() {
        actionBlock?(.confirm)
    }
    
    @objc func rotateBtnAction() {
        actionBlock?(.rotate)
    }
    
}

class ADClipDarkView: UIView {
    
    var clearRect: CGRect = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        UIColor(white: 0, alpha: 0.8).setFill()
        UIRectFill(rect)
        let cr = clearRect.intersection(rect)
        UIColor.clear.setFill()
        UIRectFill(cr)
    }
    
}

class ADClipGrideView: UIView {
    
    enum ClipRectChangeMode {
        case initial(CGRect)
        case changed(CGRect)
        case ended(CGRect,CGRect)
        case reset(CGRect,Bool)
    }
    
    private struct GrideEdge: OptionSet {
        let rawValue: Int
        
        static let top = GrideEdge(rawValue: 1 << 0)
        static let left = GrideEdge(rawValue: 1 << 1)
        static let right = GrideEdge(rawValue: 1 << 2)
        static let bottom = GrideEdge(rawValue: 1 << 3)
    }
    
    let safeRect: CGRect
    
    var clipRect: CGRect!
    
    weak var rotateBtn: UIButton?
    
    var dynamicClipRect: CGRect {
        return contentV.frame
    }
    
    // panRect finalRect
    var clipRectChanged: ((ClipRectChangeMode)->Void)? {
        didSet {
            clipRectChanged?(.initial(clipRect))
        }
    }
    
    private let interactWidth: CGFloat = 60
    private let minSize: CGFloat = 60
    
    private var dimView: ADClipDarkView!
    private var contentV: UIView!
    private var panEdge: GrideEdge = []
    private var lastPoint: CGPoint?
    private var lastClipRect: CGRect?
    private var isDiming: Bool = false
    private var isRecting: Bool = false
    
    init(safeInsets: UIEdgeInsets, clipSize: CGSize) {
        safeRect = UIScreen.main.bounds.inset(by: safeInsets)
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        dimView = ADClipDarkView(frame: .zero)
        addSubview(dimView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentV = UIView(frame: .zero)
        let c = ContentView(inset: 10)
        contentV.addSubview(c)
        c.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(-10)
        }
        addSubview(contentV)
        clipRect = resizeClipRect(with: clipSize)
        dimView.clearRect = clipRect
        contentV.frame = clipRect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shouldInteract(with point: CGPoint) -> Bool {
        let frame = contentV.frame
        let inner = frame.insetBy(dx: interactWidth/2, dy: interactWidth/2)
        let outer = frame.insetBy(dx: -interactWidth/2, dy: -interactWidth/2)
        if inner.contains(point) || !outer.contains(point) {
            return false
        }
        return true
    }
    
    func interact(with point: CGPoint, state: UIGestureRecognizer.State) {
        if state == .began {
            lastPoint = point
            lastClipRect = clipRect
            panEdge = panEdge(with: point)
            gestureStarted()
        }else if state == .changed {
            let diff = CGPoint(x: point.x - lastPoint!.x, y: point.y - lastPoint!.y)
            var new: CGRect = contentV.frame
            if panEdge.contains(.top) {
                new.origin.y += diff.y
                if new.origin.y < safeRect.minY {
                    new.origin.y = safeRect.minY
                }else{
                    new.size.height += -diff.y
                    if new.size.height < minSize {
                        new.size.height = minSize
                        new.origin.y = contentV.frame.maxY - minSize
                    }
                }
                if let last = lastClipRect {
                    if last.minY > new.minY {
                        lastClipRect?.origin.y = new.origin.y
                        lastClipRect?.size.height = new.size.height
                    }
                }
            }
            if panEdge.contains(.bottom) {
                new.size.height += diff.y
                if new.size.height > safeRect.maxY - new.minY  {
                    new.size.height = safeRect.maxY - new.minY
                }
                if new.size.height < minSize {
                    new.size.height = minSize
                }
                if let last = lastClipRect {
                    if last.maxY < new.maxY {
                        lastClipRect?.size.height = new.size.height
                    }
                }
            }
            if panEdge.contains(.left) {
                new.origin.x += diff.x
                if new.origin.x < safeRect.minX {
                    new.origin.x = safeRect.minX
                }else{
                    new.size.width += -diff.x
                    if new.size.width < minSize {
                        new.size.width = minSize
                        new.origin.x = contentV.frame.maxX - minSize
                    }
                }
                if let last = lastClipRect {
                    if last.minX > new.minX {
                        lastClipRect?.origin.x = new.origin.x
                        lastClipRect?.size.width = new.size.width
                    }
                }
            }
            if panEdge.contains(.right) {
                new.size.width += diff.x
                if new.size.width > safeRect.maxX - new.minX  {
                    new.size.width = safeRect.maxX - new.minX
                }
                if new.size.width < minSize {
                    new.size.width = minSize
                }
                if let last = lastClipRect {
                    if last.maxX < new.maxX {
                        lastClipRect?.size.width = new.size.width
                    }
                }
            }
            contentV.frame = new
            clipRect = new
            lastPoint = point
            clipRectChanged?(.changed(lastClipRect!))
        }else{
            lastClipRect = nil
            gestureEnded()
        }
    }
    
    func dragingStarted() {
        isDiming = true
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        UIView.animate(withDuration: 0.2) {
            self.dimView.alpha = 0
            self.rotateBtn?.alpha = 0
        }
    }
    
    func gestureEnded() {
        perform(#selector(_gestureEnded), with: nil, afterDelay: 1)
    }
    
    @discardableResult
    func resetClipSize(_ size: CGSize, animate: Bool = false) -> CGRect {
        clipRect = resizeClipRect(with: size)
        dimView.clearRect = clipRect
        contentV.frame = clipRect
        clipRectChanged?(.reset(clipRect,animate))
        return clipRect
    }
    
    private func gestureStarted() {
        guard !panEdge.isEmpty else {
            return
        }
        isRecting = true
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        UIView.animate(withDuration: 0.2) {
            self.dimView.alpha = 0
            self.rotateBtn?.alpha = 0
        }
    }
    
    @objc private func _gestureEnded() {
        if isDiming && !isRecting {
            isDiming = false
            UIApplication.shared.beginIgnoringInteractionEvents()
            UIView.animate(withDuration: 0.2) {
                self.dimView.alpha = 1
                self.rotateBtn?.alpha = 1
            } completion: { _ in
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }else if isRecting {
            UIApplication.shared.beginIgnoringInteractionEvents()
            isRecting = false
            let panRect = clipRect
            clipRect = resizeClipRect(with: clipRect.size)
            dimView.clearRect = clipRect
            clipRectChanged?(.ended(panRect!, clipRect))
            UIView.animate(withDuration: 0.3) {
                self.contentV.frame = self.clipRect
                self.layoutIfNeeded()
            } completion: { finish in
                UIView.animate(withDuration: 0.2) {
                    self.dimView.alpha = 1
                    self.rotateBtn?.alpha = 1
                } completion: { _ in
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
            panEdge = []
        }
    }
    
    private func panEdge(with point: CGPoint) -> GrideEdge {
        let rect = clipRect.insetBy(dx: -interactWidth/2, dy: -interactWidth/2)
        let xMinIn = (point.x > rect.minX && point.x < rect.minX + interactWidth)
        let xMaxIn = (point.x > rect.maxX - interactWidth  && point.x < rect.maxX)
        let yMinIn = (point.y > rect.minY && point.y < rect.minY + interactWidth)
        let yMaxIn = (point.y > rect.maxY - interactWidth  && point.y < rect.maxY)
        
        if xMinIn {
            if yMinIn {
                return [.top, .left]
            }else if yMaxIn {
                return [.bottom, .left]
            }else{
                return .left
            }
        }else if xMaxIn {
            if yMinIn {
                return [.top, .right]
            }else if yMaxIn {
                return [.bottom, .right]
            }else{
                return .right
            }
        }else{
            if yMinIn {
                return .top
            }else if yMaxIn {
                return .bottom
            }
        }
        return []
    }
    
    private func resizeClipRect(with size: CGSize) -> CGRect {
        var rect: CGRect = .zero
        let imageHWRatio = size.height / size.width
        let viewHWRatio = safeRect.size.height / safeRect.size.width
        if imageHWRatio > viewHWRatio {
            rect.size.height = safeRect.size.height
            rect.size.width = safeRect.size.height / imageHWRatio
            rect.origin = CGPoint(x: (safeRect.size.width - rect.size.width)/2 + safeRect.origin.x, y: safeRect.origin.y)
        } else {
            rect.size.width = safeRect.size.width
            rect.size.height = safeRect.size.width * imageHWRatio
            rect.origin = CGPoint(x: safeRect.origin.x, y: (safeRect.size.height - rect.size.height)/2 + safeRect.origin.y)
        }
        return rect
    }
    
    class ContentView: UIView {
        
        let inset: CGFloat
        
        init(inset: CGFloat) {
            self.inset = inset
            super.init(frame: .zero)
            clipsToBounds = false
            layer.masksToBounds = false
            isOpaque = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setNeedsDisplay()
        }
        
        override func draw(_ rect: CGRect) {
            let insetRect = rect.insetBy(dx: inset, dy: inset)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor.clear.cgColor)
            context?.setStrokeColor(UIColor.white.cgColor)
            context?.setLineWidth(1)
            
            context?.setShadow(offset: .zero, blur: 4, color: UIColor(white: 0, alpha: 0.9).cgColor)
            let path = UIBezierPath(rect: insetRect)
            context?.addPath(path.cgPath)
            context?.strokePath()
            context?.setShadow(offset: .zero, blur: 0)
            
            context?.setLineWidth(0.5)
            context?.beginPath()
            var dw: CGFloat = 0
            for _ in 0..<4 {
                context?.move(to: CGPoint(x: insetRect.origin.x+dw, y: insetRect.origin.y))
                context?.addLine(to: CGPoint(x: insetRect.origin.x+dw, y: insetRect.origin.y+insetRect.height))
                dw += insetRect.size.width / 3
            }

            var dh: CGFloat = 0
            for _ in 0..<4 {
                context?.move(to: CGPoint(x: insetRect.origin.x, y: insetRect.origin.y+dh))
                context?.addLine(to: CGPoint(x: insetRect.origin.x+insetRect.width, y: insetRect.origin.y+dh))
                dh += insetRect.size.height / 3
            }

            context?.strokePath()

            context?.setLineWidth(3)

            let boldLineLength: CGFloat = 20
            // 左上
            context?.move(to: CGPoint(x: inset-3, y: -1.5+inset))
            context?.addLine(to: CGPoint(x: boldLineLength+inset, y: -1.5+inset))

            context?.move(to: CGPoint(x: -1.5+inset, y: inset))
            context?.addLine(to: CGPoint(x: -1.5+inset, y: boldLineLength+inset))

            // 右上
            context?.move(to: CGPoint(x: insetRect.width-boldLineLength+inset, y: -1.5+inset))
            context?.addLine(to: CGPoint(x: insetRect.width+inset+3, y: -1.5+inset))

            context?.move(to: CGPoint(x: insetRect.width+inset+1.5, y: inset))
            context?.addLine(to: CGPoint(x: insetRect.width+inset+1.5, y: boldLineLength+inset))

            // 左下
            context?.move(to: CGPoint(x: inset-1.5, y: insetRect.height-boldLineLength+inset-1.5))
            context?.addLine(to: CGPoint(x: inset-1.5, y: insetRect.height+inset))

            context?.move(to: CGPoint(x: inset-3, y: insetRect.height+1.5+inset))
            context?.addLine(to: CGPoint(x: boldLineLength+inset, y: insetRect.height+1.5+inset))

            // 右下
            context?.move(to: CGPoint(x: insetRect.width-boldLineLength+inset, y: insetRect.height+1.5+inset))
            context?.addLine(to: CGPoint(x: insetRect.width+inset+3, y: insetRect.height+1.5+inset))

            context?.move(to: CGPoint(x: insetRect.width+1.5+inset, y: insetRect.height-boldLineLength+inset))
            context?.addLine(to: CGPoint(x: insetRect.width+1.5+inset, y: insetRect.height+inset))

            context?.strokePath()
        }
    }
    
}
