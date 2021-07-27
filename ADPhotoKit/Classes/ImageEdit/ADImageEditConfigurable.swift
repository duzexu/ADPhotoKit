//
//  ADImageEditConfigurable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

public protocol ImageProcessor: AnyObject {
    
    func process() -> UIImage?
    
}

public protocol ImageEditTool: ImageProcessor {
    
    var image: UIImage { get }
    var selectImage: UIImage? { get }
    var isSelected: Bool { set get }
    
    var toolConfigView: UIView? { set get }
    
    func toolDidSelect(ctx: UIViewController?) -> Bool
        
}

public extension ImageEditTool {
    var selectImage: UIImage? { return nil }
}

