//
//  File.swift
//  ADPhotoKit
//
//  Created by xu on 2021/8/19.
//

import Foundation

infix operator & : MultiplicationPrecedence
func &(left: CGRect, right: CGRect) -> CGRect {
    return CGRect(x: right.minX*left.width, y: right.midY*left.height, width: right.width*left.width, height: right.height*left.height)
}

func &(left: CGSize, right: CGRect) -> CGRect {
    return CGRect(x: right.minX*left.width, y: right.minY*left.height, width: right.width*left.width, height: right.height*left.height)
}

infix operator * : MultiplicationPrecedence
func *(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width*right.width, height: left.height*right.height)
}

extension CGRect {
    
    func rotateLeft() -> CGRect {
        return CGRect(x: minY, y: 1-maxX, width: height, height: width)
    }
    
}
