//
//  ADImageClipController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/27.
//

import UIKit

class ADImageClipController: UIViewController {
    
    let editInfo: ADEditInfo
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var imageView: UIImageView!
    
    private var toolBarView: ADClipToolBarView!
    private var grideView: ADClipGrideView!
    
    private let clipAreaInsets: UIEdgeInsets = isPhoneX ? UIEdgeInsets(top: 70, left: 20, bottom: 160, right: 20) : UIEdgeInsets(top: 20, left: 20, bottom: 126, right: 20)
    
    private var oldClipRect: CGRect?
    
    init(editInfo: ADEditInfo, editFromRect: CGRect) {
        self.editInfo = editInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        transitioningDelegate = self
        
        oldClipRect = editInfo.clipRect
        setupUI()
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
        contentView.frame = CGRect(origin: .zero, size: editInfo.image.size)
        scrollView.addSubview(contentView)
        
        imageView = UIImageView()
        imageView.image = editInfo.image
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        grideView = ADClipGrideView(safeInsets: clipAreaInsets, clipSize: editInfo.clipRect?.size ?? editInfo.image.size)
        view.addSubview(grideView)
        grideView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        grideView.clipRectChanged = { [weak self] pan,final in
            self?.rectDidChanged(panRect: pan, finalRect: final)
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
    
    func rectDidChanged(panRect: CGRect?, finalRect: CGRect) {
        let contentInset = UIEdgeInsets(top: finalRect.minY, left: finalRect.minX, bottom: scrollView.frame.maxY-finalRect.maxY, right: scrollView.frame.maxX-finalRect.maxX)
        scrollView.minimumZoomScale = max(finalRect.size.height/editInfo.image.size.height, finalRect.size.width/editInfo.image.size.width)
        if let pan = panRect {
            let panClip = grideView.convert(pan, to: contentView)
            let finalClip = grideView.convert(finalRect, to: contentView)
            let scale = finalRect.width/pan.width
            //scrollView.setZoomScale(scale, animated: true)
            scrollView.zoomScale *= scale
            if scale < scrollView.maximumZoomScale - CGFloat.ulpOfOne {
                print("newClip \(panClip) clip \(finalClip)")
                let scal = min(scale, scrollView.maximumZoomScale)
                let offset = CGPoint(x: panClip.midX-finalRect.width/2, y: panClip.midY-finalRect.height/2)
                scrollView.contentOffset = CGPoint(x: -contentInset.left+offset.x*scal, y: -contentInset.top+offset.y*scal)
            }
        }else{
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
        scrollView.contentInset = contentInset
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
        print("offset \(scrollView.contentOffset)")
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
        return (editInfo.image, grideView.convert(grideView.clipRect, to: convertTo))
    }
}
