//
//  ADImageEditContentView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/28.
//

import UIKit

class ADImageEditContentView: UIView {

    var scrollView: UIScrollView!
    var contentView: UIView!
    var interactContainer: UIView!
    
    private var interactTools: [ADImageEditTool] = []
    private var target: ADImageEditTool?

    init(image: UIImage, tools: [ADImageEditTool]) {
        super.init(frame: .zero)
        setupUI(image: image)
        
        for tool in tools {
            if let interact = tool.toolInteractView {
                interactContainer.addSubview(interact)
                interact.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                interactTools.append(tool)
            }
        }
        let order = interactContainer.subviews.sorted { v1, v2 in
            return (v1 as! ADToolInteractable).zIndex < (v2 as! ADToolInteractable).zIndex
        }
        for item in order {
            interactContainer.bringSubviewToFront(item)
        }
        interactTools = interactTools.sorted(by: { t1, t2 in
            return t1.toolInteractView!.zIndex > t2.toolInteractView!.zIndex
        })
    }
    
    func gestureShouldBegin(_ gestureRecognizer: UIGestureRecognizer, point: CGPoint) -> Bool {
        let isSingleTap = gestureRecognizer.isKind(of: UITapGestureRecognizer.self)
        for tool in interactTools {
            if !isSingleTap && target != nil {
                return true
            }
            
            let convert = convert(point, to: tool.toolInteractView!)
            switch tool.toolInteractView!.policy {
            case .simult: // Allow interact with simult tool view
                if tool.toolInteractView!.shouldInteract(gestureRecognizer, point: convert) {
                    if !isSingleTap {
                        target = tool
                    }
                    return true
                }
            case .single:
                // Only allow interact with select tool view
                if tool.isSelected && tool.toolInteractView!.shouldInteract(gestureRecognizer, point: convert) {
                    if !isSingleTap {
                        target = tool
                    }
                    return true
                }
            case .none:
                break
            }
        }
        return false
    }
    
    func interact(with type: ADInteractType, state: UIGestureRecognizer.State) -> Bool {
        if let tool = target {
            defer {
                switch state {
                case .ended,.failed,.cancelled:
                    target = nil
                default:
                    break
                }
            }
            switch type {
            case let .pan(point,trans):
                let convert = convert(point, to: tool.toolInteractView!)
                return tool.toolInteractView!.interact(with: .pan(loc: convert, trans: trans), scale: scrollView.zoomScale, state: state)
            default:
                return tool.toolInteractView!.interact(with: type, scale: scrollView.zoomScale, state: state)
            }
        }
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateState()
    }
}

private extension ADImageEditContentView {
    func setupUI(image: UIImage) {
        scrollView = UIScrollView()
        scrollView.maximumZoomScale = 3
        scrollView.minimumZoomScale = 1
        scrollView.isMultipleTouchEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView = UIView()
        scrollView.addSubview(contentView)
        resizeView(pixelWidth: image.size.width, pixelHeight: image.size.height)
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        interactContainer = UIView()
        interactContainer.clipsToBounds = true
        interactContainer.isUserInteractionEnabled = false
        contentView.addSubview(interactContainer)
        interactContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateState() {
        let center = convert(CGPoint(x: bounds.width/2, y: bounds.height/2), to: interactContainer)
        ADImageEditConfigurable.contentViewState = (center,scrollView.zoomScale)
    }
    
    func resizeView(pixelWidth: CGFloat, pixelHeight: CGFloat) {
        let imageSize = CGSize(width: pixelWidth, height: pixelHeight)
        
        var frame: CGRect = .zero
        var contentSize: CGSize = .zero
        
        let viewW = screenWidth
        let viewH = screenHeight
        
        var width = viewW
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            let height = viewH
            frame.size.height = height
            
            let imageWHRatio = imageSize.width / imageSize.height
            let viewWHRatio = viewW / viewH
            
            if imageWHRatio > viewWHRatio {
                frame.size.width = floor(height * imageWHRatio)
                if frame.size.width > viewW {
                    // 宽图
                    frame.size.width = viewW
                    frame.size.height = viewW / imageWHRatio
                }
            } else {
                width = floor(height * imageWHRatio)
                if width < 1 || width.isNaN {
                    width = viewW
                }
                frame.size.width = width
            }
        } else {
            frame.size.width = width
            
            let imageHWRatio = imageSize.height / imageSize.width
            let viewHWRatio = viewH / viewW
            
            if imageHWRatio > viewHWRatio {
                // 长图
                frame.size.width = min(imageSize.width, viewW)
                frame.size.height = floor(frame.size.width * imageHWRatio)
            } else {
                var height = floor(frame.size.width * imageHWRatio)
                if height < 1 || height.isNaN {
                    height = viewH
                }
                frame.size.height = height
            }
        }
        
        // 优化 scroll view zoom scale
        if frame.width < frame.height {
            scrollView.maximumZoomScale = max(3, viewW / frame.width)
        } else {
            scrollView.maximumZoomScale = max(3, viewH / frame.height)
        }
        
        contentView.frame = frame
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            contentSize = CGSize(width: width, height: max(viewH, frame.height))
            if frame.height < viewH {
                contentView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            } else {
                contentView.frame = CGRect(origin: CGPoint(x: (viewW-frame.width)/2, y: 0), size: frame.size)
            }
        } else {
            contentSize = frame.size
            if frame.width < viewW || frame.height < viewH {
                contentView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            }
        }
        
        scrollView.contentSize = contentSize
        scrollView.contentOffset = .zero
    }
    
}

extension ADImageEditContentView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        contentView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        updateState()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateState()
    }
}
