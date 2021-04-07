//
//  ADImageBrowserCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/5.
//

import UIKit
import Photos

extension PHAsset {
    public var browserSize: CGSize {
        let scale: CGFloat = 2
        if whRatio > 1 {
            let h = min(UIScreen.main.bounds.height, 600) * scale
            let w = h * whRatio
            return CGSize(width: w, height: h)
        } else {
            let w = min(UIScreen.main.bounds.width, 600) * scale
            let h = w / whRatio
            return CGSize(width: w, height: h)
        }
    }
}

class ADImageBrowserCell: ADBrowserBaseCell {
    
    var browserView: ADImageBrowserView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        browserView = ADImageBrowserView(frame: .zero)
        addSubview(browserView)
        browserView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with source: ADImageSource, indexPath: IndexPath? = nil) {
        browserView.source = source
    }
}

class ADImageBrowserView: UIView {
    
    var source: ADImageSource! {
        didSet {
            loadImageSource(source)
        }
    }
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    var imageView: UIImageView!
    
    var progressView: ADProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ADImageBrowserView {
    func setupUI() {
        scrollView = UIScrollView()
        scrollView.maximumZoomScale = 3
        scrollView.minimumZoomScale = 1
        scrollView.isMultipleTouchEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView = UIView()
        scrollView.addSubview(contentView)
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        progressView = ADProgressView()
        progressView.isHidden = true
        addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.center.equalToSuperview()
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
    }
    
    func loadImageSource(_ source: ADImageSource) {
        switch source {
        case let .network(url):
            progressView.isHidden = false
            progressView.progress = 0
            imageView.kf.setImage(with: url, placeholder: nil) { [weak self] (c, t) in
                self?.progressView.progress = CGFloat(c/t)
            } completionHandler: { [weak self] (result) in
                self?.progressView.isHidden = true
                if let img = try? result.get() {
                    self?.resizeView(pixelWidth: img.image.size.width, pixelHeight: img.image.size.height)
                }
            }
        case let .album(asset):
            progressView.isHidden = false
            progressView.progress = 0
            resizeView(pixelWidth: CGFloat(asset.pixelWidth), pixelHeight: CGFloat(asset.pixelHeight))
            if asset.isGif { //gif 情况下优先加载一个小的缩略图
                imageView.setAsset(asset, size: CGSize(width: asset.browserSize.width/2, height: asset.browserSize.height/2), placeholder: Bundle.uiBundle?.image(name: "defaultphoto")) { [weak self] (p) in
                    self?.progressView.progress = CGFloat(p)
                }
            }else{
                imageView.setAsset(asset, size: asset.browserSize, placeholder: Bundle.uiBundle?.image(name: "defaultphoto"))
            }
        case let .local(img):
            progressView.isHidden = true
            imageView.image = img
            resizeView(pixelWidth: img.size.width, pixelHeight: img.size.height)
        }
    }
    
    func resizeView(pixelWidth: CGFloat, pixelHeight: CGFloat) {
        let imageSize = CGSize(width: pixelWidth, height: pixelHeight)
        
        var frame: CGRect = .zero
        var contenSize: CGSize = .zero
        
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
            contenSize = CGSize(width: width, height: max(viewH, frame.height))
            if frame.height < viewH {
                contentView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            } else {
                contentView.frame = CGRect(origin: CGPoint(x: (viewW-frame.width)/2, y: 0), size: frame.size)
            }
        } else {
            contenSize = frame.size
            if frame.width < viewW || frame.height < viewH {
                contentView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            }
        }
        
        scrollView.contentSize = contenSize
        scrollView.contentOffset = .zero
    }
    
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
    }
    
    @objc func doubleTapAction(_ tap: UITapGestureRecognizer) {
        let scale: CGFloat = self.scrollView.zoomScale != self.scrollView.maximumZoomScale ? self.scrollView.maximumZoomScale : 1
        let tapPoint = tap.location(in: self)
        var rect = CGRect.zero
        rect.size.width = self.scrollView.frame.width / scale
        rect.size.height = self.scrollView.frame.height / scale
        rect.origin.x = tapPoint.x - (rect.size.width / 2)
        rect.origin.y = tapPoint.y - (rect.size.height / 2)
        self.scrollView.zoom(to: rect, animated: true)
    }
}

extension ADImageBrowserView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}
