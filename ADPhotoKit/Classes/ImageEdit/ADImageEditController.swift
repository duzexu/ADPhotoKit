//
//  ADImageEditController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit

public struct ADImageEditTool: OptionSet {
    public let rawValue: Int
    
    public static let lineDraw = ADImageEditTool(rawValue: 1 << 0)
    public static let imageStkr = ADImageEditTool(rawValue: 1 << 1)
    public static let textStkr = ADImageEditTool(rawValue: 1 << 2)
    public static let clip = ADImageEditTool(rawValue: 1 << 3)
    public static let mosaicDraw = ADImageEditTool(rawValue: 1 << 4)
    
    public static let all: ADImageEditTool = [.lineDraw, .imageStkr, .textStkr, .clip, .mosaicDraw]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

class ADImageEditController: UIViewController {
    
    let image: UIImage
    
    var contentView: ADImageEditContentView!
    var controlsView: ADImageEditControlsView!
    
    private var isControlShow: Bool = true {
        didSet {
            if isControlShow {
                UIView.animate(withDuration: 0.25) {
                    self.controlsView.alpha = 1
                }
            }else{
                UIView.animate(withDuration: 0.25) {
                    self.controlsView.alpha = 0
                }
            }
        }
    }
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("[deinit]ADImageEditController")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = UIColor.black
    }
    

}

extension ADImageEditController {
    
    func setupUI() {
        var tools: [ImageEditTool] = []
        let tool = ADPhotoKitConfiguration.default.systemImageEditTool
        if tool.contains(.lineDraw) {
            if ADPhotoKitConfiguration.default.lineDrawDefaultColorIndex > ADPhotoKitConfiguration.default.lineDrawColors.count {
                fatalError("`defaultLineDrawColorIndex` must less then `lineDrawColors`'s count")
            }
            tools.append(ADImageDraw(style: .line(ADPhotoKitConfiguration.default.lineDrawColors, ADPhotoKitConfiguration.default.lineDrawDefaultColorIndex)))
        }
        if tool.contains(.imageStkr) {
            tools.append(ADImageSticker(style: .image([])))
        }
        if tool.contains(.textStkr) {
            tools.append(ADImageSticker(style: .text([])))
        }
        if tool.contains(.clip) {
            tools.append(ADImageClip())
        }
        if tool.contains(.mosaicDraw) {
            tools.append(ADImageDraw(style: .mosaic(image)))
        }
        if let custom = ADPhotoKitConfiguration.default.customImageEditTools {
            tools.append(contentsOf: custom)
        }
        
        contentView = ADImageEditContentView(image: image, tools: tools)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        controlsView = ADImageEditControlsView(vc: self, tools: tools)
        controlsView.contentStatus = { [weak self] lock in
            self?.contentView.scrollView.isScrollEnabled = !lock
        }
        view.addSubview(controlsView)
        controlsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        view.addGestureRecognizer(singleTap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        view.addGestureRecognizer(pan)

        singleTap.require(toFail: pan)
    }
    
}

extension ADImageEditController {
    
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: view)
        if controlsView.singleTap(with: point) {
            return
        }
        isControlShow = !isControlShow
    }
    
    @objc func panAction(_ pan: UITapGestureRecognizer) {
        let point = pan.location(in: view)
        contentView.move(to: point, state: pan.state)
        switch pan.state {
        case .began:
            isControlShow = false
        case .changed:
            break
        case .ended, .cancelled, .failed:
            isControlShow = true
        default:
            break
        }
    }
    
}
