//
//  ADImageClipController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/27.
//

import UIKit

class ADImageClipController: UIViewController {
    
    let clipInfo: ADClipInfo
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var imageView: UIImageView!
    
    private var toolBarView: ADClipToolBarView!
    private var grideView: ADClipGrideView!
    
    private let clipAreaInsets: UIEdgeInsets = isPhoneX ? UIEdgeInsets(top: 70, left: 20, bottom: 160, right: 20) : UIEdgeInsets(top: 20, left: 20, bottom: 126, right: 20)
    
    private var oldClipRect: CGRect?
    
    init(cilpInfo: ADClipInfo) {
        self.clipInfo = cilpInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        transitioningDelegate = self
        
        oldClipRect = clipInfo.clipRect
        
        setupUI()
        
        scrollView.alpha = 0
        grideView.alpha = 0
        toolBarView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        grideView.clipRectChanged = { [weak self] pan,final,initial in
            self?.rectDidChanged(panRect: pan, finalRect: final, isInit: initial)
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
        contentView.frame = CGRect(origin: .zero, size: clipInfo.image.size)
        scrollView.addSubview(contentView)
        
        imageView = UIImageView()
        imageView.image = clipInfo.image
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        grideView = ADClipGrideView(safeInsets: clipAreaInsets, clipSize: clipInfo.clipRect?.size ?? clipInfo.image.size)
        view.addSubview(grideView)
        grideView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        toolBarView = ADClipToolBarView(ctx: self, bottomInset: clipAreaInsets.bottom)
        view.addSubview(toolBarView)
        toolBarView.snp.makeConstraints { make in
            make.right.left.bottom.equalToSuperview()
            make.height.equalTo(64+tabBarOffset)
        }
        
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        panGes.delegate = self
        view.addGestureRecognizer(panGes)
        scrollView.panGestureRecognizer.require(toFail: panGes)
    }
    
    @objc func panAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        grideView.interact(with: point, state: pan.state)
    }
    
    func rectDidChanged(panRect: CGRect?, finalRect: CGRect, isInit: Bool) {
        let contentInset = UIEdgeInsets(top: finalRect.minY, left: finalRect.minX, bottom: scrollView.frame.maxY-finalRect.maxY, right: scrollView.frame.maxX-finalRect.maxX)
        scrollView.minimumZoomScale = max(finalRect.size.height/clipInfo.image.size.height, finalRect.size.width/clipInfo.image.size.width)
        if let pan = panRect {
            let panClip = grideView.convert(pan, to: contentView)
            let scale = scrollView.zoomScale*finalRect.width/pan.width
            scrollView.setZoomScale(scale, animated: true)
            if scale < scrollView.maximumZoomScale - CGFloat.ulpOfOne {
                let adapt = min(scale, scrollView.maximumZoomScale)
                let offset = CGPoint(x: panClip.midX*adapt-finalRect.width/2.0, y: panClip.midY*adapt-finalRect.height/2.0)
                scrollView.setContentOffset(CGPoint(x: -contentInset.left+offset.x, y: -contentInset.top+offset.y), animated: true)
            }
        }else{
            let finalClip = grideView.convert(finalRect, to: scrollView)
            if isInit {
                initialAnimation(to: finalRect)
                scrollView.zoomScale = scrollView.minimumZoomScale
            }else if !contentView.frame.contains(finalClip) {
                scrollView.zoomScale = scrollView.minimumZoomScale
            }
        }
        scrollView.contentInset = contentInset
    }
    
    func initialAnimation(to rect: CGRect) {
        let imageView = UIImageView(image: clipInfo.clipImage)
        imageView.frame = clipInfo.clipFrom
        view.insertSubview(imageView, belowSubview: grideView)
        UIApplication.shared.beginIgnoringInteractionEvents()
        UIView.animate(withDuration: 0.5) {
            imageView.frame = rect
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
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        grideView.dragingStarted()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
        return (clipInfo.image, grideView.convert(grideView.clipRect, to: convertTo))
    }
}
