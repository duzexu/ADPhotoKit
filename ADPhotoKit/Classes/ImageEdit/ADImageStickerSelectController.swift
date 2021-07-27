//
//  ADImageStickerSelectController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/27.
//

import UIKit

class ADImageStickerSelectController: UIViewController {
    
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
        dismiss(animated: true, completion: nil)
    }
}
