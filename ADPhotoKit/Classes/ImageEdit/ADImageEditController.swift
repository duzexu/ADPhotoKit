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
    
    var controlsView: ADImageEditControlsView!
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = UIColor.white
    }
    

}

extension ADImageEditController {
    
    func setupUI() {
        var tools: [ImageEditTool] = []
        let tool = ADPhotoKitConfiguration.default.defaultImageEditTool
        if tool.contains(.lineDraw) {
            tools.append(ADImageDraw(style: .line([])))
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
            tools.append(ADImageDraw(style: .mosaic))
        }
        if let custom = ADPhotoKitConfiguration.default.customImageEditTools {
            tools.append(contentsOf: custom)
        }
        controlsView = ADImageEditControlsView(vc: self, tools: tools)
        view.addSubview(controlsView)
        controlsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
