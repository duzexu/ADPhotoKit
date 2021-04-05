//
//  ADImageBrowserCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/5.
//

import UIKit

extension ADAssetModel {
    public var browserSize: CGSize {
        let scale: CGFloat = UIScreen.main.scale
        if self.whRatio > 1 {
            let h = min(UIScreen.main.bounds.height, 600) * scale
            let w = h * self.whRatio
            return CGSize(width: w, height: h)
        } else {
            let w = min(UIScreen.main.bounds.width, 600) * scale
            let h = w / self.whRatio
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
                    self?.imageView.image = img.image
                }else{
                    
                }
            }
        case let .album(asset):
            contentView.frame = CGRect(x: 0, y: 0, width: asset.pixelWidth, height: asset.pixelHeight)
            scrollView.contentSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            let model = ADAssetModel(asset: asset)
            if model.type == .gif {
                
            }else{
                
            }
            imageView.kf.setImage(with: PHAssetImageDataProvider(asset: asset, size: model.browserSize))
        case let .local(img):
            imageView.image = img
        }
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
