//
//  Cell+ADExtension.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation

extension UITableView {
    
    func regisiter(cell: AnyClass) {
        register(cell, forCellReuseIdentifier: NSStringFromClass(cell))
    }
    
    func regisiter(nib: AnyClass) {
        register(UINib(nibName: NSStringFromClass(nib).components(separatedBy: ".").last!, bundle: nil), forCellReuseIdentifier: NSStringFromClass(nib))
    }
    
    func regisiterHeaderFooter(view: AnyClass) {
        register(view, forHeaderFooterViewReuseIdentifier: NSStringFromClass(view))
    }
    
    func regisiterHeaderFooter(nib: AnyClass) {
        register(UINib(nibName: NSStringFromClass(nib).components(separatedBy: ".").last!, bundle: nil), forHeaderFooterViewReuseIdentifier: NSStringFromClass(nib))
    }
    
}

extension UITableViewCell {
    
    class var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
    
}

extension UITableViewHeaderFooterView {
    
    class var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
    
}

extension UICollectionView {
    
    func regisiter(cell: AnyClass) {
        register(cell, forCellWithReuseIdentifier: NSStringFromClass(cell))
    }
    
    func regisiter(nib: AnyClass) {
        register(UINib(nibName: NSStringFromClass(nib).components(separatedBy: ".").last!, bundle: nil), forCellWithReuseIdentifier: NSStringFromClass(nib))
    }
    
    func regisiterHeader(cell: AnyClass) {
        register(cell, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(cell))
    }
    
    func regisiterFooter(cell: AnyClass) {
        register(cell, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(cell))
    }
    
    func regisiterHeader(nib: AnyClass) {
        register(UINib(nibName: NSStringFromClass(nib).components(separatedBy: ".").last!, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(nib))
    }
    
    func regisiterFooter(nib: AnyClass) {
        register(UINib(nibName: NSStringFromClass(nib).components(separatedBy: ".").last!, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(nib))
    }
    
}

extension UICollectionReusableView {
    class var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}
