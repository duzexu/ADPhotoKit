//
//  ADImageEditContentView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/28.
//

import UIKit

class ADEditContainerView: UIView {
    
    var scaleRatio: CGFloat = 1
    
    private let clipBoundsView = UIView()
    fileprivate var interactContainer: UIView!
    
    private var imageView: UIImageView!
        
    init(image: UIImage) {
        super.init(frame: .zero)
        clipBoundsView.clipsToBounds = true
        addSubview(clipBoundsView)
        clipBoundsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        clipBoundsView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.size.equalTo(image.size)
            make.center.equalToSuperview()
        }
        
        interactContainer = UIView()
        interactContainer.isUserInteractionEnabled = false
        addSubview(interactContainer)
        interactContainer.snp.remakeConstraints { make in
            make.size.equalTo(image.size)
            make.center.equalToSuperview()
        }
    }
    
    func addInteractView(_ interact: (UIView & ADToolInteractable)) {
        interactContainer.addSubview(interact)
        interact.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func orderInteractViews() {
        let order = interactContainer.subviews.sorted { v1, v2 in
            return (v1 as! ADToolInteractable).zIndex < (v2 as! ADToolInteractable).zIndex
        }
        for item in order {
            interactContainer.bringSubviewToFront(item)
        }
    }
    
    func setClipRect(_ viewSize: CGSize, rect: CGRect?) {
        let imageSize = imageView.image!.size
        if let clip = rect {
            let ratio = viewSize.height/(clip.height*imageSize.height)
            let scale = CGAffineTransform(scaleX: ratio, y: ratio)
            let trans = CGAffineTransform(translationX: (0.5-clip.midX)*imageSize.width*ratio, y: (0.5-clip.midY)*imageSize.height*ratio)
            imageView.transform = scale.concatenating(trans)
            interactContainer.transform = scale.concatenating(trans)
//            interactContainer.frame = imgClipView.convert(imageView.frame, to: self)
//            interactContainer.center = CGPoint(x: viewSize.width/2+(0.5-clip.midX)*imageSize.width*ratio, y: viewSize.height/2+(0.5-clip.midY)*imageSize.height*ratio)
            scaleRatio = ratio
        }else{
            let ratio = viewSize.width/imageSize.width
            imageView.transform = CGAffineTransform(scaleX: ratio, y: ratio)
            interactContainer.transform = CGAffineTransform(scaleX: ratio, y: ratio)
//            interactContainer.frame = imgClipView.convert(imageView.frame, to: self)
//            interactContainer.center = CGPoint(x: viewSize.width/2, y: viewSize.height/2)
            scaleRatio = ratio
        }
    }
    
    fileprivate func interactContainerImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(interactContainer.bounds.size, false, UIScreen.main.scale)
        if let ctx = UIGraphicsGetCurrentContext() {
            interactContainer.layer.render(in: ctx)
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ADImageEditContentView: UIView {
    
    let image: UIImage

    var scrollView: UIScrollView!
    var container: ADEditContainerView!
    
    private var interactTools: [ADImageEditTool] = []
    private var target: ADImageEditTool?

    init(image: UIImage, tools: [ADImageEditTool]) {
        self.image = image
        super.init(frame: .zero)
        setupUI(image: image)
        
        for tool in tools {
            if let interact = tool.toolInteractView {
                container.addInteractView(interact)
                interactTools.append(tool)
            }
        }
        container.orderInteractViews()
        interactTools = interactTools.sorted(by: { t1, t2 in
            return t1.toolInteractView!.zIndex > t2.toolInteractView!.zIndex
        })
    }
    
    func updateClipRect(_ rect: CGRect?) {
        let size = rect == nil ? image.size : image.size*rect!.size
        resizeView(pixelWidth: size.width, pixelHeight: size.height)
        container.setClipRect(container.frame.size, rect: rect)
    }
    
    func editImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        container.interactContainerImage()?.draw(in: CGRect(origin: .zero, size: image.size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func clipImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(container.bounds.size, false, UIScreen.main.scale)
        if let ctx = UIGraphicsGetCurrentContext() {
            container.layer.render(in: ctx)
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
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
    
    func interact(with type: ADInteractType, state: UIGestureRecognizer.State) {
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
                tool.toolInteractView!.interact(with: .pan(loc: convert, trans: trans), scale: scrollView.zoomScale*container.scaleRatio, state: state)
            default:
                tool.toolInteractView!.interact(with: type, scale: scrollView.zoomScale*container.scaleRatio, state: state)
            }
        }
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
        
        container = ADEditContainerView(image: image)
        scrollView.addSubview(container)
        resizeView(pixelWidth: image.size.width, pixelHeight: image.size.height)
        container.setClipRect(container.bounds.size, rect: nil)
    }
    
    func updateState() {
        let center = convert(CGPoint(x: bounds.width/2, y: bounds.height/2), to: container.interactContainer)
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
        
        container.frame = frame
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            contentSize = CGSize(width: width, height: max(viewH, frame.height))
            if frame.height < viewH {
                container.center = CGPoint(x: viewW / 2, y: viewH / 2)
            } else {
                container.frame = CGRect(origin: CGPoint(x: (viewW-frame.width)/2, y: 0), size: frame.size)
            }
        } else {
            contentSize = frame.size
            if frame.width < viewW || frame.height < viewH {
                container.center = CGPoint(x: viewW / 2, y: viewH / 2)
            }
        }
        
        scrollView.contentSize = contentSize
        scrollView.contentOffset = .zero
    }
}

extension ADImageEditContentView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return container
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        container.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        updateState()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateState()
    }
}
