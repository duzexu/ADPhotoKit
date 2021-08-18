//
//  UIImage+ADExtension.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/1.
//

import Foundation
import UIKit

extension UIImage {
    static func image(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        guard size.width > 0 && size.height > 0 else {
            return nil
        }
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func image(of clip: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(clip.size, false, UIScreen.main.scale)
        self.draw(at: CGPoint(x: -clip.origin.x, y: -clip.origin.y))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? self
    }
}
