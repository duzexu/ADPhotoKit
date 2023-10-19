//
//  ADImageBrowserCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/5.
//

import UIKit
import Photos
import PhotosUI

extension PHAsset {
    
    /// Prefered size to browse.
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

extension ADImageSource {
    var isLivePhoto: Bool {
        switch self {
        case let .album(asset):
            if #available(iOS 9.1, *) {
                return asset.isLivePhoto
            }
            return false
        default:
            return false
        }
    }
    var livePhotoAsset: PHAsset? {
        switch self {
        case let .album(asset):
            if #available(iOS 9.1, *) {
                return asset
            }
            return nil
        default:
            return nil
        }
    }
}

/// Cell for browse image asset in browser controller.
class ADImageBrowserCell: ADBrowserBaseCell, ADImageBrowserCellConfigurable {
    
    var imageBrowserView: ADImageBrowserView!
    
    var livePhotoBrowserView: ADLivePhotoBrowserView!
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageBrowserView = ADImageBrowserView(frame: .zero)
        imageBrowserView.singleTapBlock = { [weak self] in
            self?.singleTapBlock?()
        }
        contentView.addSubview(imageBrowserView)
        imageBrowserView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        livePhotoBrowserView = ADLivePhotoBrowserView(frame: .zero)
        livePhotoBrowserView.singleTapBlock = { [weak self] in
            self?.singleTapBlock?()
        }
        contentView.addSubview(livePhotoBrowserView)
        livePhotoBrowserView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with source: ADImageSource) {
        imageBrowserView.isHidden = source.isLivePhoto
        livePhotoBrowserView.isHidden = !source.isLivePhoto
        if source.isLivePhoto && ADPhotoKitUI.config.assetOpts.contains(.selectAsLivePhoto) {
            livePhotoBrowserView.asset = source.livePhotoAsset!
        }else{
            imageBrowserView.isHidden = false
            imageBrowserView.source = source
        }
    }
        
    override func transationBegin() -> (UIView, CGRect) {
        if !imageBrowserView.isHidden {
            let trans = imageBrowserView.imageView
            let frame = trans!.superview!.convert(trans!.frame, to: self)
            let imageView = UIImageView(image: trans!.image)
            imageView.contentMode = .scaleAspectFit
            return (imageView,frame)
        }else{
            let trans = livePhotoBrowserView.imageView
            let frame = trans!.superview!.convert(trans!.frame, to: self)
            let imageView = UIImageView(image: trans!.image)
            imageView.contentMode = .scaleAspectFit
            return (imageView,frame)
        }
    }
    
}

class ADImageBrowserView: UIView {
    
    var source: ADImageSource! {
        didSet {
            if source.identifier != identifier {
                loadImageSource(source)
            }
        }
    }
        
    var singleTapBlock: (() -> Void)?
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    var imageView: UIImageView!
    
    var progressView: ADProgressConfigurable!
    
    private var identifier: String?
    
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
        
        progressView = ADProgress.progress()
        progressView.isHidden = true
        addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
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
        identifier = source.identifier
        scrollView.zoomScale = 1
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
            progressView.isHidden = true
            progressView.progress = 0
            resizeView(pixelWidth: CGFloat(asset.pixelWidth), pixelHeight: CGFloat(asset.pixelHeight))
            if asset.isGif { //gif 情况下优先加载一个小的缩略图
                imageView.setAsset(asset, size: CGSize(width: asset.browserSize.width/2, height: asset.browserSize.height/2), placeholder: Bundle.image(name: "defaultphoto"), completionHandler:  { [weak self] (img) in
                    self?.loadOriginImageData(asset: asset)
                })
            }else{
                imageView.setAsset(asset, size: asset.browserSize, placeholder: Bundle.image(name: "defaultphoto")) { [weak self] (progress) in
                    if progress >= 1 {
                        self?.progressView.isHidden = true
                    }else{
                        self?.progressView.isHidden = false
                    }
                    self?.progressView.progress = CGFloat(progress)
                } completionHandler: { [weak self] (img) in
                    self?.progressView.isHidden = true
                }
            }
        case let .local(img,_):
            progressView.isHidden = true
            imageView.image = img
            resizeView(pixelWidth: img.size.width, pixelHeight: img.size.height)
        }
    }
    
    func loadOriginImageData(asset: PHAsset) {
        imageView.kf.setImage(with: PHAssetImageDataProvider(asset: asset))
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
    
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        singleTapBlock?()
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
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        contentView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}

class ADLivePhotoBrowserView: UIView {
    
    var asset: PHAsset! {
        didSet {
            if identifier != asset.localIdentifier {
                loadAsset(asset)
            }
        }
    }
    
    var singleTapBlock: (() -> Void)?
    
    var livePhotoView: PHLivePhotoView!
    
    var imageView: UIImageView!
    
    private var identifier: String?
    
    private var requestID: PHImageRequestID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ADLivePhotoBrowserView {
    func setupUI() {
        livePhotoView = PHLivePhotoView()
        livePhotoView.contentMode = .scaleAspectFit
        addSubview(livePhotoView)
        livePhotoView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func loadAsset(_ asset: PHAsset) {
        identifier = asset.localIdentifier
        livePhotoView.isHidden = true
        imageView.isHidden = false
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        imageView.setAsset(asset, size: CGSize(width: asset.browserSize.width/2, height: asset.browserSize.height/2), placeholder: Bundle.image(name: "defaultphoto"), completionHandler:  { [weak self] (img) in
            self?.loadLivePhotoData(asset: asset)
        })
    }
    
    func loadLivePhotoData(asset: PHAsset) {
        requestID = ADPhotoManager.fetch(for: asset, type: .livePhoto, completion: { [weak self] (livePhoto, _, _) in
            self?.livePhotoView.livePhoto = livePhoto as? PHLivePhoto
            self?.livePhotoView.isHidden = false
            self?.imageView.isHidden = true
            self?.livePhotoView.startPlayback(with: .full)
        })
    }
}
