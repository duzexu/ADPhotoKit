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
    
    var policy: ADInteractPolicy {
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
    
    var lineCountChange: ((Int) -> Void)?
    
    let style: Style
        
    var paths: [DrawPath] = [] {
        didSet {
            setNeedsDisplay()
            pathMaskView?.paths = paths
        }
    }
    
    var pathMaskView: MaskView?
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        switch style {
        case .line:
            break
        case let .mosaic(img):
            pathMaskView = MaskView()
            pathMaskView?.isOpaque = false
            addSubview(pathMaskView!)
            mask = pathMaskView
            if let cgImg = img.cgImage {
                let ciImage = CIImage(cgImage: cgImg)
                let filter = CIFilter(name: "CIPixellate")
                filter?.setValue(ciImage, forKey: kCIInputImageKey)
                filter?.setValue(10, forKey: kCIInputScaleKey)
                if let output = filter?.outputImage {
                    let context = CIContext()
                    layer.contents = context.createCGImage(output, from: CGRect(origin: .zero, size: img.size))
                }
            }
        }
    }
    
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
            switch style {
            case let .line(color):
                switch state {
                case .began:
                    let width = ADPhotoKitConfiguration.default.lineDrawWidth
                    let path = DrawPath(color: color(), width: width/scale, point: point)
                    paths.append(path)
                    setNeedsDisplay()
                case .changed:
                    paths.last?.move(to: point)
                    setNeedsDisplay()
                case .ended, .cancelled, .failed:
                    lineCountChange?(paths.count)
                default:
                    break
                }
            case .mosaic:
                switch state {
                case .began:
                    let width = ADPhotoKitConfiguration.default.mosaicDrawWidth
                    let path = DrawPath(color: .black, width: width/scale, point: point)
                    paths.append(path)
                    pathMaskView?.paths = paths
                case .changed:
                    paths.last?.move(to: point)
                    pathMaskView?.paths = paths
                case .ended, .cancelled, .failed:
                    lineCountChange?(paths.count)
                default:
                    break
                }
            }
        default:
            break
        }
        return nil
    }
    
    func revoke() {
        switch style {
        case .line(_):
            if paths.count > 0 {
                paths.removeLast()
            }
            setNeedsDisplay()
        case .mosaic:
            if paths.count > 0 {
                paths.removeLast()
                pathMaskView?.paths = paths
            }
        }
        lineCountChange?(paths.count)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pathMaskView?.frame = bounds
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        switch style {
        case .line:
            for path in paths {
                path.color.set()
                path.path.stroke()
            }
        case .mosaic:
            break
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
                path.color.set()
                path.path.stroke()
            }
        }
    }

}

struct DrawPath {
    
    let width: CGFloat
    let color: UIColor
    
    let path: UIBezierPath
    
    init(color: UIColor, width: CGFloat, point: CGPoint) {
        self.color = color
        self.width = width
        path = UIBezierPath()
        path.lineWidth = width
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: point)
    }
    
    func move(to point: CGPoint) {
        path.addLine(to: point)
    }
}
