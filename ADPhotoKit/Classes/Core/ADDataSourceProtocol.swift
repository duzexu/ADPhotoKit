//
//  ADDataSourceProtocol.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import Foundation

public protocol ADDataSourceReloadable: class {
    
    func reloadData()
    
}

extension UITableView: ADDataSourceReloadable {
}

extension UICollectionView: ADDataSourceReloadable {
}
