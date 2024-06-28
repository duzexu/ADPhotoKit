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
    
    func image(clip normalize: CGRect, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let clipTo = CGRect(x: normalize.minX*size.width, y: normalize.minY*size.height, width: normalize.width*size.width, height: normalize.height*size.height)
        UIGraphicsBeginImageContextWithOptions(clipTo.size, false, scale)
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
    
    func resize(to size: CGSize, mode: UIView.ContentMode) -> UIImage? {
        if self.size.width < size.width  && self.size.height < size.height {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let fitRect = CGRect(x: 0, y: 0, width: size.width, height: size.height).rectFit(with: self.size, mode: mode)
        self.draw(in: fitRect)
        let ret = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return ret
    }
    
    func hasAlphaChannel() -> Bool {
        guard let info = self.cgImage?.alphaInfo else {
            return false
        }
        
        return info == .first || info == .last || info == .premultipliedFirst || info == .premultipliedLast
    }
    
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        guard let cgImage = cgImage, let colorSpace = cgImage.colorSpace else {
            return self
        }
        var transform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = CGAffineTransform(translationX: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = CGAffineTransform(translationX: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = CGAffineTransform(translationX: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        )
        context?.concatenate(transform)
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        guard let newCgImage = context?.makeImage() else {
            return self
        }
        return UIImage(cgImage: newCgImage)
    }
}
