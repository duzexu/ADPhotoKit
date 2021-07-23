//
//  ADImageEditConfigurable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

protocol ImageProcessor {
    
    func process() -> UIImage?
    
}

protocol ImageEditTool: ImageProcessor {
    
}


