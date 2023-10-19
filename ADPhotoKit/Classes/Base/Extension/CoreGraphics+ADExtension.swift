//
//  File.swift
//  ADPhotoKit
//
//  Created by xu on 2021/8/19.
//

import Foundation
import UIKit

infix operator |-> : MultiplicationPrecedence
func |->(left: CGRect, right: CGRect) -> CGRect {
    return CGRect(x: right.minX*left.width, y: right.midY*left.height, width: right.width*left.width, height: right.height*left.height)
}

func |->(left: CGSize, right: CGRect) -> CGRect {
    return CGRect(x: right.minX*left.width, y: right.minY*left.height, width: right.width*left.width, height: right.height*left.height)
}

infix operator * : MultiplicationPrecedence
func *(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width*right.width, height: left.height*right.height)
}

extension CGRect {
    
    static var normalize: CGRect {
        return CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    var approximate: CGRect {
        return CGRect(x: minX.round(by: 2), y: minY.round(by: 2), width: width.round(by: 2), height: height.round(by: 2))
    }
    
    var normalizedVerfy: CGRect {
        return CGRect(x: max(0, minX), y: max(0, minY), width: min(1, width), height: min(1, height))
    }
    
    func rotateLeft() -> CGRect {
        return CGRect(x: minY, y: 1-maxX, width: height, height: width)
    }
    
    func rotateRight() -> CGRect {
        return CGRect(x: 1-maxY, y: minX, width: height, height: width)
    }
    
    func isApproaching(to other: CGRect) -> Bool {
        let minX = fabsf(Float(minX-other.minX)) < Float.ulpOfOne
        let minY = fabsf(Float(minY-other.minY)) < Float.ulpOfOne
        let width = fabsf(Float(width-other.width)) < Float.ulpOfOne
        let height = fabsf(Float(height-other.height)) < Float.ulpOfOne
        return (minX && minY && width && height)
    }
    
    func rectFit(with size: CGSize, mode: UIView.ContentMode) -> CGRect {
        let stdRect = self.standardized
        let center = CGPoint(x: stdRect.midX, y: stdRect.midY)
        var ret: CGRect = .zero
        switch mode {
        case .scaleAspectFit,.scaleAspectFill:
            var scale: CGFloat = 0
            if mode == .scaleAspectFit {
                if (size.width / size.height < stdRect.size.width / stdRect.size.height) {
                    scale = stdRect.size.height / size.height;
                } else {
                    scale = stdRect.size.width / size.width;
                }
            }else{
                if (size.width / size.height < stdRect.size.width / stdRect.size.height) {
                    scale = stdRect.size.width / size.width;
                } else {
                    scale = stdRect.size.height / size.height;
                }
                ret.size = CGSize(width: size.width * scale, height: size.height * scale)
                ret.origin = CGPoint(x: center.x - ret.size.width * 0.5, y: center.y - ret.size.height * 0.5)
            }
        case .center:
            ret.size = size
            ret.origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
        case .top:
            ret.size = size
            ret.origin.x = center.x - size.width * 0.5
        case .bottom:
            ret.size = size
            ret.origin = CGPoint(x: center.x - size.width * 0.5, y: self.size.height - size.height)
        case .left:
            ret.size = size
            ret.origin.y = center.y - size.height * 0.5
        case .right:
            ret.size = size
            ret.origin = CGPoint(x: self.size.width - size.width, y: center.y - size.height * 0.5)
        case .scaleToFill,.redraw:
            ret = stdRect
        default:
            ret = stdRect
        }
        return ret
    }
    
}

extension CGFloat {
    func round(by place: Int) -> CGFloat {
        let divisor = pow(10.0,CGFloat(place))
        return (self * divisor).rounded() / divisor
    }
}
