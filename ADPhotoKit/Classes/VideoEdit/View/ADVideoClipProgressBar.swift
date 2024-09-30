//
//  ADVideoEditProgressBar.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/10.
//

import UIKit
import AVFoundation

class ADVideoClipProgressBar: UIView {
    
    let asset: AVAsset
    let minValue: CGFloat?
    let maxValue: CGFloat?
    let clipRange: CMTimeRange?
    var seekTimeReview: ((CMTime) -> Void)?
    var timeRangeChanged: ((CMTimeRange) -> Void)?
    var progerss: CGFloat = 0 {
        didSet {
            borderView.progress = progerss
        }
    }
    
    private let interval: TimeInterval

    private var collectionView: UICollectionView!
    private var borderView: ADVideoClipProgressBorder!
    
    private lazy var frameRequestQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
    
    private var frameImageCache: [Int: UIImage] = [:]
    
    private lazy var generator: AVAssetImageGenerator = {
        let g = AVAssetImageGenerator(asset: asset)
        g.appliesPreferredTrackTransform = true
        g.requestedTimeToleranceBefore = .zero
        g.requestedTimeToleranceAfter = .zero
        g.apertureMode = .productionAperture
        return g
    }()
    
    init(asset: AVAsset, min: CGFloat?, max: CGFloat?, clipRange: CMTimeRange?) {
        self.asset = asset
        self.minValue = min
        self.maxValue = max
        self.clipRange = clipRange
        self.interval = asset.duration.seconds/10
        super.init(frame: .zero)
        setupUI()
    }
    
    deinit {
        frameRequestQueue.cancelAllOperations()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -40, dy: -20).contains(point)
    }
    
}

extension ADVideoClipProgressBar {
    func setupUI() {
        backgroundColor = .clear
        let layout = ADCollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isUserInteractionEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.regisiter(cell: ADVideoClipFrameCell.self)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        borderView = ADVideoClipProgressBorder(min: minValue, max: maxValue)
        addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        if let clipRange = clipRange {
            let duration = asset.duration.seconds
            borderView.left = clipRange.start.seconds/duration
            let right = (clipRange.start.seconds+clipRange.duration.seconds)/duration
            borderView.right = min(1, right)
        }else{
            if maxValue != nil {
                borderView.right = maxValue!
                let start = CMTime(seconds: asset.duration.seconds*borderView.left, preferredTimescale: asset.duration.timescale)
                let end = CMTime(seconds: asset.duration.seconds*borderView.right, preferredTimescale: asset.duration.timescale)
                timeRangeChanged?(CMTimeRange(start: start, end: end))
            }
        }
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        panGes.delegate = self
        addGestureRecognizer(panGes)
    }
    
    @objc
    func panAction(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        let value = borderView.trySetValue(point.x / frame.width)
        if sender.state == .began {
            borderView.highlight = true
            borderView.value = value
            seekTimeReview?(CMTime(seconds: asset.duration.seconds*value, preferredTimescale: asset.duration.timescale))
        } else if sender.state == .changed {
            borderView.value = value
            seekTimeReview?(CMTime(seconds: asset.duration.seconds*value, preferredTimescale: asset.duration.timescale))
        } else if sender.state == .ended || sender.state == .cancelled {
            borderView.highlight = false
            let start = CMTime(seconds: asset.duration.seconds*borderView.left, preferredTimescale: asset.duration.timescale)
            let end = CMTime(seconds: asset.duration.seconds*borderView.right, preferredTimescale: asset.duration.timescale)
            timeRangeChanged?(CMTimeRange(start: start, end: end))
        }
    }
}

extension ADVideoClipProgressBar: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.size.width/10, height: frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADVideoClipFrameCell.reuseIdentifier, for: indexPath) as! ADVideoClipFrameCell
        let image = frameImageCache[indexPath.row]
        cell.imageView.image = image
        if image == nil {
            let mes = TimeInterval(indexPath.row) * interval
            let time = CMTimeMakeWithSeconds(Float64(mes), preferredTimescale: asset.duration.timescale)
            let operation = ADVideoThumbnailOperation(generator: generator, time: time) { [weak self] image in
                self?.frameImageCache[indexPath.row] = image
                self?.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
            }
            frameRequestQueue.addOperation(operation)
        }
        return cell
    }
}

extension ADVideoClipProgressBar: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        return borderView.progressShouldBegin(in: point)
    }
    
}

class ADVideoClipFrameCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ADVideoClipProgressBorder: UIView {
    
    enum ClipMode {
        case none
        case left
        case right
    }
    
    var value: CGFloat = 0 {
        didSet {
            switch clipMode {
            case .none:
                break
            case .left:
                left = value
            case .right:
                right = value
            }
            indicator.center = CGPoint(x: value*frame.size.width, y: frame.midY)
        }
    }
    
    var left: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
            leftHandler.center = CGPoint(x: left*frame.size.width, y: frame.midY)
        }
    }
    
    var right: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
            rightHandler.center = CGPoint(x: right*frame.size.width, y: frame.midY)
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            if !highlight {
                indicator.center = CGPoint(x: (left+(right-left)*progress)*frame.size.width, y: frame.midY)
            }
        }
    }
    
    var highlight: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.layer.borderColor = self.highlight ? UIColor(white: 1, alpha: 0.4).cgColor : UIColor.clear.cgColor
            }
        }
    }
    
    let minValue: CGFloat?
    let maxValue: CGFloat?
    
    private var clipMode: ClipMode = .none
    private var leftHandler: UIImageView!
    private var rightHandler: UIImageView!
    private var indicator: UIView!
    
    init(min: CGFloat? = nil, max: CGFloat? = nil) {
        self.minValue = min
        self.maxValue = max
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = .clear
        isOpaque = false
        indicator = UIView()
        indicator.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        addSubview(indicator)
        leftHandler = UIImageView(image: Bundle.image(name: "icons_clip_left", module: .videoEdit))
        rightHandler = UIImageView(image: Bundle.image(name: "icons_clip_right", module: .videoEdit))
        addSubview(leftHandler)
        addSubview(rightHandler)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        leftHandler.frame = CGRect(origin: .zero, size: CGSize(width: 16, height: 50))
        rightHandler.frame = CGRect(origin: .zero, size: CGSize(width: 16, height: 50))
        leftHandler.center = CGPoint(x: left*frame.size.width, y: frame.midY)
        rightHandler.center = CGPoint(x: right*frame.size.width, y: frame.midY)
        indicator.frame =  CGRect(origin: .zero, size: CGSize(width: 2, height: 50))
        indicator.center = CGPoint(x: progress*frame.size.width, y: frame.midY)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(4)
        
        context?.move(to: CGPoint(x: left*rect.size.width, y: 0))
        context?.addLine(to: CGPoint(x: right*rect.size.width, y: 0))
        
        context?.move(to: CGPoint(x: left*rect.size.width, y: rect.height))
        context?.addLine(to: CGPoint(x: right*rect.size.width, y: rect.height))
        
        context?.strokePath()
    }
    
    func progressShouldBegin(in point: CGPoint) -> Bool {
        let leftRect = leftHandler.frame.inset(by: UIEdgeInsets(top: -20, left: -40, bottom: -20, right: -20))
        let rightRect = rightHandler.frame.inset(by: UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -40))
        if leftRect.contains(point) {
            clipMode = .left
        }else if rightRect.contains(point) {
            clipMode = .right
        }else{
            clipMode = .none
        }
        return clipMode != .none
    }
    
    func trySetValue(_ v: CGFloat) -> CGFloat {
        let value = min(1 ,max(v, 0))
        let width = frame.size.width
        let min = minValue != nil ? minValue!*width : 40
        let max = maxValue != nil ? maxValue!*width : width
        switch clipMode {
        case .none:
            return value
        case .left:
            if right*width-value*width < min {
                return right-min/width
            }else if right*width-value*width > max {
                return right-max/width
            }else{
                return value
            }
        case .right:
            if value*width-left*width < min {
                return left+min/width
            }else if value*width-left*width > max {
                return left+max/width
            }else{
                return value
            }
        }
    }
}
