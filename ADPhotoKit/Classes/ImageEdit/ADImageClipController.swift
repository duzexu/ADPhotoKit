//
//  ADImageClipController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/27.
//

import UIKit

class ADImageClipController: UIViewController {
    
    var clipInfo: ADClipInfo
    
    var clipRectConfirmBlock: ((CGRect?) -> Void)?
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var imageView: UIImageView!
    
    private var toolBarView: ADClipToolBarView!
    private var grideView: ADClipGrideView!
    
    private let clipAreaInsets: UIEdgeInsets = isPhoneX ? UIEdgeInsets(top: 70, left: 20, bottom: 160, right: 20) : UIEdgeInsets(top: 20, left: 20, bottom: 126, right: 20)
    
    private var editedImage: UIImage
    private var isOrigin: Bool = true {
        didSet {
            toolBarView.revertBtn.isEnabled = !isOrigin
        }
    }
        
    init(clipInfo: ADClipInfo) {
        self.clipInfo = clipInfo
        self.editedImage = clipInfo.image.image(with: clipInfo.rotation.rawValue/180.0*CGFloat.pi)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        transitioningDelegate = self
                
        setupUI()
        
        scrollView.alpha = 0
        grideView.alpha = 0
        toolBarView.alpha = 0
        
        isOrigin = clipInfo.isOrigin
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        grideView.clipRectChanged = { [weak self] mode in
            self?.clipRectChanged(with: mode)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

private extension ADImageClipController {
    
    func setupUI() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 10
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView = UIView()
        contentView.frame = CGRect(origin: .zero, size: editedImage.size)
        scrollView.addSubview(contentView)
        
        imageView = UIImageView()
        imageView.image = editedImage
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let clipSize = clipInfo.clipRect != nil ? clipInfo.clipRect!.size*editedImage.size : editedImage.size
        grideView = ADClipGrideView(safeInsets: clipAreaInsets, clipSize: clipSize)
        view.addSubview(grideView)
        grideView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        toolBarView = ADClipToolBarView(bottomInset: clipAreaInsets.bottom)
        toolBarView.actionBlock = { [weak self] action in
            self?.toolAction(action)
        }
        view.addSubview(toolBarView)
        toolBarView.snp.makeConstraints { make in
            make.right.left.bottom.equalToSuperview()
            make.height.equalTo(64+tabBarOffset)
        }
        
        grideView.rotateBtn = toolBarView.rotateBtn
        
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        panGes.delegate = self
        view.addGestureRecognizer(panGes)
        scrollView.panGestureRecognizer.require(toFail: panGes)
    }
    
    func clipRectChanged(with mode: ADClipGrideView.ClipRectChangeMode) {
        var contentInset: UIEdgeInsets!
        defer {
            scrollView.contentInset = contentInset
        }
        switch mode {
        case let .initial(finalRect):
            contentInset = config(with: finalRect)
            configZoomScale()
            initialAnimation(with: finalRect)
        case let .changed(finalRect):
            isOrigin = false
            contentInset = config(with: finalRect)
            let finalClip = grideView.convert(finalRect, to: scrollView)
            if !contentView.frame.contains(finalClip) {
                scrollView.zoomScale = scrollView.minimumZoomScale
            }
        case let .ended(panRect, finalRect):
            isOrigin = false
            contentInset = config(with: finalRect)
            let panClip = grideView.convert(panRect, to: contentView)
            let scale = scrollView.zoomScale*finalRect.width/panRect.width
            UIView.animate(withDuration: 0.3) {
                self.scrollView.zoomScale = scale
                if scale < self.scrollView.maximumZoomScale - CGFloat.ulpOfOne {
                    let adapt = min(scale, self.scrollView.maximumZoomScale)
                    let offset = CGPoint(x: panClip.midX*adapt-finalRect.width/2.0, y: panClip.midY*adapt-finalRect.height/2.0)
                    self.scrollView.contentOffset = CGPoint(x: -contentInset.left+offset.x, y: -contentInset.top+offset.y)
                }
            }
        case let .reset(finalRect,ani):
            contentInset = config(with: finalRect)
            configZoomScale(ani)
        }
        
        func initialAnimation(with finalRect: CGRect) {
            let imageView = UIImageView(image: clipInfo.clipImage)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.frame = clipInfo.clipFrom
            view.insertSubview(imageView, belowSubview: grideView)
            UIApplication.shared.beginIgnoringInteractionEvents()
            UIView.animate(withDuration: 0.5) {
                imageView.frame = finalRect
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.scrollView.alpha = 1
                    self.grideView.alpha = 1
                    self.toolBarView.alpha = 1
                } completion: { _ in
                    imageView.removeFromSuperview()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
        
        func config(with finalRect: CGRect) -> UIEdgeInsets {
            scrollView.minimumZoomScale = max(finalRect.size.height/editedImage.size.height, finalRect.size.width/editedImage.size.width)
            return UIEdgeInsets(top: finalRect.minY, left: finalRect.minX, bottom: scrollView.frame.maxY-finalRect.maxY, right: scrollView.frame.maxX-finalRect.maxX)
        }
        
        func configZoomScale(_ ani: Bool = false) {
            if let clip = clipInfo.clipRect {
                if ani {
                    UIView.animate(withDuration: 0.3) {
                        self.scrollView.zoomScale = self.scrollView.minimumZoomScale*min(1/clip.width, 1/clip.height)
                        self.scrollView.contentOffset = CGPoint(x: -contentInset.left+clip.minX*self.editedImage.size.width*self.scrollView.zoomScale, y: -contentInset.top+clip.minY*self.editedImage.size.height*self.scrollView.zoomScale)
                    }
                }else{
                    scrollView.zoomScale = scrollView.minimumZoomScale*min(1/clip.width, 1/clip.height)
                    scrollView.contentOffset = CGPoint(x: -contentInset.left+clip.minX*editedImage.size.width*scrollView.zoomScale, y: -contentInset.top+clip.minY*editedImage.size.height*scrollView.zoomScale)
                }
            }else{
                if ani {
                    UIView.animate(withDuration: 0.3) {
                        self.scrollView.zoomScale = self.scrollView.minimumZoomScale
                    }
                }else{
                    scrollView.zoomScale = scrollView.minimumZoomScale
                }
            }
        }
    }
    
    enum Animation {
        case rotation(CGRect?)
        case zooming
    }
    
    func beginAnimation(_ animation: Animation?) {
        editedImage = clipInfo.image.image(with: clipInfo.rotation.rawValue/180.0*CGFloat.pi)
        imageView.image = editedImage
        scrollView.zoomScale = 1
        contentView.frame = CGRect(origin: .zero, size: editedImage.size)
        let clipSize = clipInfo.clipRect != nil ? clipInfo.clipRect!.size*editedImage.size : imageView.image!.size
        
        if let ani = animation {
            switch ani {
            case let .rotation(clip):
                scrollView.alpha = 0
                grideView.alpha = 0
                toolBarView.alpha = 0
                
                let clipRect = grideView.convert(grideView.dynamicClipRect, to: view)
                let rotateView = UIView(frame: clipRect)
                rotateView.frame = clipRect
                view.insertSubview(rotateView, belowSubview: grideView)
                let imgView = UIImageView(image: rotateImage(clip: clip))
                let frame = view.convert(scrollView.convert(contentView.frame, to: view), to: rotateView)
                imgView.frame = frame
                imgView.backgroundColor = .red
                rotateView.addSubview(imgView)
                
                let final = grideView.resetClipSize(clipSize)
                let scaleW = final.width/clipRect.width
                let scaleH = final.height/clipRect.height
                let scale = CGAffineTransform(scaleX: scaleW, y: scaleW)
                let roate = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                
                UIApplication.shared.beginIgnoringInteractionEvents()
                UIView.animate(withDuration: 2) {
                    rotateView.transform = roate.concatenating(scale)
                } completion: { _ in
                    UIView.animate(withDuration: 0.3) {
                        self.scrollView.alpha = 1
                        self.grideView.alpha = 1
                        self.toolBarView.alpha = 1
                    } completion: { _ in
                        rotateView.removeFromSuperview()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                }
            case .zooming:
                grideView.resetClipSize(clipSize, animate: true)
            }
        }else{
            grideView.resetClipSize(clipSize)
        }
    }
    
    func newClipRect() -> CGRect? {
        if isOrigin { return nil }
        let panClip = grideView.convert(grideView.dynamicClipRect, to: contentView)
        return CGRect(x: panClip.minX/editedImage.size.width, y: panClip.minY/editedImage.size.height, width: panClip.width/editedImage.size.width, height: panClip.height/editedImage.size.height)
    }
    
    func revertOrigin() {
        let rotated = clipInfo.rotation != .idle
        //TODO
        let zoomed = clipInfo.clipRect != nil
        let old = clipInfo.clipRect ?? newClipRect()!
        clipInfo.clipRect = nil
        clipInfo.rotation = .idle
        isOrigin = true
        if rotated && zoomed {
            beginAnimation(nil)
        }else if rotated {
            beginAnimation(.rotation(old))
        }else if zoomed {
            beginAnimation(.zooming)
        }
    }
    
    func rotateLeft() {
        let old = newClipRect()
        clipInfo.clipRect = old?.rotateLeft()
        clipInfo.rotation = clipInfo.rotation.rotateLeft()
        beginAnimation(.rotation(old))
        isOrigin = false
    }
    
    func rotateImage(clip: CGRect?) -> UIImage {
        if let clip = clip {
            let dark = ADClipDarkView(frame: CGRect(origin: .zero, size: editedImage.size))
            dark.clearRect = editedImage.size&clip
            UIGraphicsBeginImageContextWithOptions(editedImage.size, false, UIScreen.main.scale)
            editedImage.draw(at: .zero)
            if let ctx = UIGraphicsGetCurrentContext() {
                dark.layer.render(in: ctx)
            }
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result ?? editedImage
        }else{
            return editedImage
        }
    }
    
}

private extension ADImageClipController {
    @objc func panAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        grideView.interact(with: point, state: pan.state)
    }
    
    func toolAction(_ action: ADClipToolBarView.Action) {
        switch action {
        case .cancel:
            dismiss(animated: true, completion: nil)
        case .confirm:
            clipRectConfirmBlock?(newClipRect())
            dismiss(animated: true, completion: nil)
        case .revert:
            revertOrigin()
        case .rotate:
            rotateLeft()
        }
    }
}

extension ADImageClipController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: view)
        return grideView.shouldInteract(with: point)
    }
}

extension ADImageClipController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        grideView.dragingStarted()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        grideView.dragingStarted()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isOrigin = false
        grideView.gestureEnded()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isOrigin = false
        grideView.gestureEnded()
    }
    
}

extension ADImageClipController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ADImageClipDismissTransition(transable: self)
    }
}

extension ADImageClipController: ADImageClipDismissTransitionContextFrom {
    func transitionInfo(convertTo: UIView) -> (UIImage, CGRect) {
        defer {
            scrollView.alpha = 0
            grideView.alpha = 0
            toolBarView.alpha = 0
        }
        let clipRect = newClipRect()
        let image = clipRect == nil ? editedImage : editedImage.image(clip: clipRect!)
        return (image, grideView.convert(grideView.clipRect, to: convertTo))
    }
}
