//
//  ADImageStickerSelectController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/27.
//

import UIKit

class ADImageStickerSelectController: UIViewController, ADImageStickerSelectConfigurable {
    
    var imageDidSelect: ((UIImage) -> Void)?

    var imagesView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagesView = UIView()
        imagesView.backgroundColor = UIColor.gray
        view.addSubview(imagesView)
        imagesView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(240)
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        view.addGestureRecognizer(singleTap)
    }

}

extension ADImageStickerSelectController {
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        imageDidSelect?(Bundle.image(name: "imageSticker1", module: .imageEdit)!)
        dismiss(animated: true, completion: nil)
    }
}
