//
//  ADImageStickerView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit

public class ADStickerInteractView: UIView, ToolInteractable {
    
    public var zIndex: Int {
        return InteractZIndex.Top.rawValue
    }
    
    public static var share = ADStickerInteractView()
    
}
