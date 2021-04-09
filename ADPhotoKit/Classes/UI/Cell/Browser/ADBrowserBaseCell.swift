//
//  ADBrowserBaseCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/4.
//

import UIKit

class ADBrowserBaseCell: UICollectionViewCell {
    
    var singleTapBlock: (() -> Void)?
    
    func cellWillDisplay() {
        
    }
    
    func cellDidEndDisplay() {
        
    }
    
    ///transation
    func transationBegin() -> (UIView,CGRect) {
        return (UIView(),.zero)
    }
    
    func transationCancel(view: UIView) {
        
    }
    
}



