//
//  File.swift
//  ADPhotoKit
//
//  Created by xu on 2021/8/19.
//

import Foundation

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
    
    func isApproaching(to other: CGRect) -> Bool {
        let minX = fabsf(Float(minX-other.minX)) < Float.ulpOfOne
        let minY = fabsf(Float(minY-other.minY)) < Float.ulpOfOne
        let width = fabsf(Float(width-other.width)) < Float.ulpOfOne
        let height = fabsf(Float(height-other.height)) < Float.ulpOfOne
        return (minX && minY && width && height)
    }
    
}

extension CGFloat {
    func round(by place: Int) -> CGFloat {
        let divisor = pow(10.0,CGFloat(place))
        return (self * divisor).rounded() / divisor
    }
}
