//
//  ADVideoEditContentView.swift
//  ADPhotoKit
//
//  Created by du on 2024/9/7.
//

import UIKit
import AVFoundation

class ADVideoEditContentView: UIView {

    let asset: AVAsset
    weak var videoPlayerView: ADVideoPlayable?
    
    private var interactContainer: ADInteractContainerView!
    
    private var interactTools: [ADVideoEditTool] = []
    private var target: ADVideoEditTool?
    
    init(asset: AVAsset, videoPlayer: ADVideoPlayable, tools: [ADVideoEditTool]) {
        self.asset = asset
        self.videoPlayerView = videoPlayer
        super.init(frame: .zero)
        setupUI()
        for tool in tools {
            if let interact = tool.toolInteractView {
                let view = ADInteractMaskView(view: interact)
                interactContainer.addSubview(view)
                view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                interactTools.append(tool)
            }
        }
        interactContainer.orderInteractViews()
        interactTools = interactTools.sorted(by: { t1, t2 in
            return t1.toolInteractView!.zIndex > t2.toolInteractView!.zIndex
        })
        updateClipRect(imageSize: asset.naturalSize)
    }
    
    func thumbnailImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(interactContainer.bounds.size, false, UIScreen.main.scale)
        if let ctx = UIGraphicsGetCurrentContext() {
            interactContainer.layer.render(in: ctx)
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func gestureShouldBegin(_ gestureRecognizer: UIGestureRecognizer, point: CGPoint) -> Bool {
        let isTap = gestureRecognizer.isKind(of: UITapGestureRecognizer.self)
        for tool in interactTools {
            if !isTap && target != nil {
                return true
            }
            
            let convert = convert(point, to: tool.toolInteractView!)
            switch tool.toolInteractView!.strategy {
            case .simult: // Allow interact with simult tool view
                if tool.toolInteractView!.shouldInteract(gestureRecognizer, point: convert) {
                    if !isTap {
                        target = tool
                    }
                    return true
                }
            case .single:
                // Only allow interact with select tool view
                if tool.isSelected && tool.toolInteractView!.shouldInteract(gestureRecognizer, point: convert) {
                    if !isTap {
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
            var delay: TimeInterval?
            defer {
                switch state {
                case .ended,.failed,.cancelled:
                    if let clipBounds = tool.toolInteractView?.interactClipBounds, !clipBounds {
                        if let package = tool.toolInteractView?.superview as? ADInteractMaskView {
                            if let ti = delay, ti > 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now()+ti) {
                                    package.clipBounds = true
                                }
                            }else{
                                package.clipBounds = true
                            }
                        }
                    }
                    target = nil
                case .began:
                    if let clipBounds = tool.toolInteractView?.interactClipBounds, !clipBounds {
                        if let package = tool.toolInteractView?.superview as? ADInteractMaskView {
                            package.clipBounds = false
                        }
                    }
                default:
                    break
                }
            }
            switch type {
            case let .pan(point,trans):
                let convert = convert(point, to: tool.toolInteractView!)
                delay = tool.toolInteractView!.interact(with: .pan(loc: convert, trans: trans), scale: 1, state: state)
            case let .pinch(scale, point):
                let convert = convert(point, to: tool.toolInteractView!)
                delay = tool.toolInteractView!.interact(with: .pinch(scale: scale, point: convert), scale: 1, state: state)
            default:
                delay = tool.toolInteractView!.interact(with: type, scale: 1, state: state)
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension ADVideoEditContentView {
    func setupUI() {
        if let player = videoPlayerView {
            addSubview(player)
            player.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        interactContainer = ADInteractContainerView()
        addSubview(interactContainer)
        interactContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateClipRect(imageSize: CGSize) {
        var frame: CGRect = .zero
        
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
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            frame = CGRect(origin: CGPoint(x: (viewH-frame.width)/2, y: (viewW-frame.height)/2), size: frame.size)
        } else {
            frame = CGRect(origin: CGPoint(x: (viewW-frame.width)/2, y: (viewH-frame.height)/2), size: frame.size)
        }
        
        interactContainer.clipRect = frame
        let clipInfo: ADClipingInfo = (UIScreen.main.bounds,frame,.idle,1)
        interactContainer.clipingScreenInfo = clipInfo
    }
}
