//
//  ADImageEditController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit

struct ADImageEditTool: OptionSet {
    let rawValue: Int
    
    static let lineDraw = ADImageEditTool(rawValue: 1 << 0)
    static let imageStkr = ADImageEditTool(rawValue: 1 << 1)
    static let textStkr = ADImageEditTool(rawValue: 1 << 2)
    static let clip = ADImageEditTool(rawValue: 1 << 3)
    static let mosaicDraw = ADImageEditTool(rawValue: 1 << 4)
    
    static let all: ADImageEditTool = [.lineDraw, .imageStkr, .textStkr, .clip, .mosaicDraw]
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
        controlsView = ADImageEditControlsView()
        view.addSubview(controlsView)
        controlsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
