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
        grideView.clipRectChanged = { [weak self] rect,initial in
            self?.clipRectDidChanged(rect, initial: initial)
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
    
    func clipRectDidChanged(_ clip: CGRect, initial: Bool) {
        let contentInset = UIEdgeInsets(top: clip.minY, left: clip.minX, bottom: scrollView.frame.maxY-clip.maxY, right: scrollView.frame.maxX-clip.maxX)
        if initial {
            if scrollView.zoomScale == scrollView.minimumZoomScale {
                scrollView.minimumZoomScale = max(clip.size.height/editInfo.image.size.height, clip.size.width/editInfo.image.size.width)
                scrollView.zoomScale = scrollView.minimumZoomScale
            }
        }else{
            scrollView.minimumZoomScale = max(clip.size.height/editInfo.image.size.height, clip.size.width/editInfo.image.size.width)
            let newClip = grideView.convert(clip, to: contentView)
            let scale = max(editInfo.image.size.height/(newClip.size.height/scrollView.zoomScale), editInfo.image.size.width/(newClip.size.width/scrollView.zoomScale))
            //scrollView.setZoomScale(scale, animated: true)
            scrollView.zoomScale = scale
            if scale < scrollView.maximumZoomScale {
                print("newClip \(newClip) clip \(clip)")
                let scal = min(scale, scrollView.maximumZoomScale)
                let offset = CGPoint(x: newClip.midX-clip.width/2, y: newClip.midY-clip.height/2)
                scrollView.contentOffset = CGPoint(x: -contentInset.left+offset.x*scal, y: -contentInset.top+offset.y*scal)
            }
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
