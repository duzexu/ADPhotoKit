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
        self.scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView = UIView()
        scrollView.addSubview(contentView)
        
        imageView = UIImageView()
        imageView.image = editInfo.image
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        grideView = ADClipGrideView(safeInsets: clipAreaInsets)
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
        
        resizeView(pixelWidth: editInfo.image.size.width, pixelHeight: editInfo.image.size.height)
    }
    
    @objc func panAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        grideView.interact(with: point, state: pan.state)
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
        return ADImageClipDismissAnimatedTransition()
    }
}
