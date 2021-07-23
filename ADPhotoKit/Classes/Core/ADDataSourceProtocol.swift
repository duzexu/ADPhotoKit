//
//  ADDataSourceProtocol.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import Foundation
import UIKit

/// Associate reloadable view.
public protocol ADDataSourceReloadable: AnyObject {
    
    func reloadData()
    
}

extension UITableView: ADDataSourceReloadable {
}

extension UICollectionView: ADDataSourceReloadable {
}
