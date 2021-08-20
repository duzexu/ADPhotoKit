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
    
    func image(clip normalize: CGRect) -> UIImage {
        let clipTo = CGRect(x: normalize.minX*size.width, y: normalize.minY*size.height, width: normalize.width*size.width, height: normalize.height*size.height)
        UIGraphicsBeginImageContextWithOptions(clipTo.size, false, UIScreen.main.scale)
        self.draw(at: CGPoint(x: -clipTo.origin.x, y: -clipTo.origin.y))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? self
    }
    
    func image(with degree: CGFloat) -> UIImage {
        guard degree != 0 else {
            return self
        }
        
        guard let cgImg = cgImage else {
            return self
        }
        
        let box = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        box.transform = CGAffineTransform(rotationAngle: degree)
        
        let boxSize = box.frame.size
        
        UIGraphicsBeginImageContext(boxSize)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.translateBy(x: boxSize.width / 2, y: boxSize.height / 2)
        ctx?.rotate(by: degree)
        ctx?.scaleBy(x: 1.0, y: -1.0)
        ctx?.draw(cgImg, in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result ?? self
    }
}
