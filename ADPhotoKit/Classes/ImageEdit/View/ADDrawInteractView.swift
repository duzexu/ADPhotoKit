//
//  ADDrawInteractView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/28.
//

import UIKit

class ADDrawInteractView: UIView, ADToolInteractable {
    
    var zIndex: Int {
        switch style {
        case .line:
            return ADInteractZIndex.Bottom.rawValue+1
        case .mosaic:
            return ADInteractZIndex.Bottom.rawValue
        }
    }
    
    var strategy: ADInteractStrategy {
        return .single
    }
    
    var interactClipBounds: Bool {
        return true
    }
    
    var clipingScreenInfo: ADClipingInfo? = nil
        
    enum Style {
        case line((() -> UIColor))
        case mosaic(UIImage)
    }
    
    var actionsDidChange: ((DrawActionData) -> Void)?
    
    let style: Style
        
    var paths: [DrawPath] = [] {
        didSet {
            reloadPaths()
        }
    }
    
    var erase: Bool = false {
        didSet {
            eraserView.isHidden = !erase
        }
    }
    
    private var eraserView: UIImageView!
    private var mosaicView: MosaicView?
    private var impactFeedback: UIImpactFeedbackGenerator!
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        impactFeedback = UIImpactFeedbackGenerator(style: .light)
        eraserView = UIImageView(image: Bundle.image(name: "eraser_circle", module: .imageEdit))
        eraserView.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
        eraserView.isHidden = true
        eraserView.alpha = 0
        addSubview(eraserView)
        switch style {
        case .line:
            break
        case let .mosaic(img):
            mosaicView = MosaicView(image: img)
            addSubview(mosaicView!)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shouldInteract(_ gesture: UIGestureRecognizer, point: CGPoint) -> Bool {
        if gesture.isKind(of: UIPanGestureRecognizer.self) {
            return true
        }
        return false
    }
    
    func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) -> TimeInterval? {
        switch type {
        case let .pan(point, _):
            if erase {
                var needReload = false
                if state == .began {
                    impactFeedback.prepare()
                    eraserView.center = point
                    eraserView.alpha = 1
                    for path in paths {
                        if path.path.contains(point) {
                            if !path.delete {
                                impactFeedback.impactOccurred()
                            }
                            path.delete = true
                            needReload = true
                        }
                    }
                }else if state == .changed {
                    eraserView.center = point
                    for path in paths {
                        if path.path.contains(point) {
                            if !path.delete {
                                impactFeedback.impactOccurred()
                            }
                            path.delete = true
                            needReload = true
                        }
                    }
                }else{
                    eraserView.alpha = 0
                    let new = paths.filter { !$0.delete }
                    if new.count != paths.count {
                        let erased = paths.filter { $0.delete }
                        needReload = true
                        paths = new
                        actionsDidChange?(.erase(erased))
                    }
                }
                if needReload {
                    reloadPaths()
                }
            }else{
                switch style {
                case let .line(color):
                    switch state {
                    case .began:
                        let width = ADPhotoKitConfiguration.default.lineDrawWidth
                        let path = DrawPath(color: color(), width: width, scale: scale, point: point)
                        paths.append(path)
                        setNeedsDisplay()
                    case .changed:
                        paths.last?.move(to: point)
                        setNeedsDisplay()
                    case .ended, .cancelled, .failed:
                        actionsDidChange?(.draw(paths.last!))
                    default:
                        break
                    }
                case .mosaic:
                    switch state {
                    case .began:
                        let width = ADPhotoKitConfiguration.default.mosaicDrawWidth
                        let path = DrawPath(color: .black, width: width, scale: scale, point: point)
                        paths.append(path)
                        mosaicView?.paths = paths
                    case .changed:
                        paths.last?.move(to: point)
                        mosaicView?.paths = paths
                    case .ended, .cancelled, .failed:
                        actionsDidChange?(.draw(paths.last!))
                    default:
                        break
                    }
                }
            }
        default:
            break
        }
        return nil
    }
    
    func undo(action: DrawActionData) {
        switch action {
        case .draw(_):
            paths.removeLast()
            reloadPaths()
        case let .erase(data):
            data.forEach { $0.delete = false }
            paths.append(contentsOf: data)
            paths = paths.sorted { $0.index < $1.index }
            reloadPaths()
        }
    }
    
    func redo(action: DrawActionData) {
        switch action {
        case let .draw(path):
            paths.append(path)
            reloadPaths()
        case let .erase(data):
            paths.removeAll { path in
                data.contains(path)
            }
            reloadPaths()
        }
    }
    
    private func reloadPaths() {
        switch style {
        case .line:
            setNeedsDisplay()
        case .mosaic:
            mosaicView?.paths = paths
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mosaicView?.frame = bounds
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        switch style {
        case .line:
            for path in paths {
                path.draw()
            }
        case .mosaic:
            break
        }
    }
    
    class MosaicView: UIView {
        
        var paths: [DrawPath] = [] {
            didSet {
                outlineView.paths = paths
                contentMaskView.paths = paths
            }
        }
        
        var image: UIImage {
            didSet {
                update(image: image)
            }
        }
        
        var contentView: UIView!
        var contentMaskView: MaskView!
        var outlineView: OutlineView!
        
        init(image: UIImage) {
            self.image = image
            super.init(frame: .zero)
            isUserInteractionEnabled = false
            contentView = UIView()
            addSubview(contentView)
            contentMaskView = MaskView()
            contentMaskView?.isOpaque = false
            contentView.mask = contentMaskView
            outlineView = OutlineView()
            outlineView.isOpaque = false
            addSubview(outlineView)
            update(image: image)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            contentView.frame = bounds
            contentMaskView.frame = bounds
            outlineView.frame = bounds
        }
        
        func update(image: UIImage) {
            if let cgImg = image.cgImage {
                let ciImage = CIImage(cgImage: cgImg)
                let filter = CIFilter(name: "CIPixellate")
                filter?.setValue(ciImage, forKey: kCIInputImageKey)
                filter?.setValue(20, forKey: kCIInputScaleKey)
                if let output = filter?.outputImage {
                    let context = CIContext()
                    contentView.layer.contents = context.createCGImage(output, from: CGRect(origin: .zero, size: image.size))
                }
            }
        }
        
        class MaskView: UIView {
            
            var paths: [DrawPath] = [] {
                didSet {
                    setNeedsDisplay()
                }
            }
            
            override func draw(_ rect: CGRect) {
                super.draw(rect)
                for path in paths {
                    path.draw(outline: false)
                }
            }
        }
        
        class OutlineView: UIView {
            
            var paths: [DrawPath] = [] {
                didSet {
                    setNeedsDisplay()
                }
            }
            
            override func draw(_ rect: CGRect) {
                super.draw(rect)
                for path in paths {
                    if path.delete {
                        UIColor.white.set()
                        path.outline.stroke()
                        path.color.set()
                        path.path.stroke(with: .clear, alpha: 1)
                    }
                }
            }
        }
    }
}

extension ADDrawInteractView: ADSourceImageModify {
    func sourceImageDidModify(_ image: UIImage) {
        switch style {
        case .line(_):
            break
        case .mosaic(_):
            mosaicView?.image = image
        }        
    }
}

class DrawPath: Equatable {
    
    private static var pathIndex = 0
    
    let width: CGFloat
    let color: UIColor
    var delete: Bool = false
    let index: Int
    
    let path: UIBezierPath
    let outline: UIBezierPath
    
    init(color: UIColor, width: CGFloat, scale: CGFloat, point: CGPoint) {
        self.color = color
        self.width = width
        self.index = DrawPath.pathIndex
        DrawPath.pathIndex += 1
        path = UIBezierPath()
        path.lineWidth = width/scale
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: point)
        
        outline = UIBezierPath()
        outline.lineWidth = width/scale + ADPhotoKitConfiguration.default.eraseOutlineWidth*2
        outline.lineCapStyle = .round
        outline.lineJoinStyle = .round
        outline.move(to: point)
    }
    
    func move(to point: CGPoint) {
        path.addLine(to: point)
        outline.addLine(to: point)
    }
    
    func draw(path: Bool = true, outline: Bool = true) {
        if delete && outline {
            UIColor.white.set()
            self.outline.stroke()
        }
        if path {
            color.set()
            self.path.stroke()
        }
    }
    
    static func == (lhs: DrawPath, rhs: DrawPath) -> Bool {
        return lhs.index == rhs.index
    }
}
