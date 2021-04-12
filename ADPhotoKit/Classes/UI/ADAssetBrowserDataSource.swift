//
//  ADAssetBrowserDataSource.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/12.
//

import UIKit

class ADAssetBrowserDataSource: NSObject {

    public weak var reloadable: ADDataSourceReloadable?
    public let options: ADAssetBrowserOptions
    
    public var list: [ADAssetBrowsable]
    public var selects: [ADAssetBrowsable] = []
    
    public var index: Int = 0
    public var selectIndexs: [Int] = []
    
    public init(reloadable: ADDataSourceReloadable,
                options: ADAssetBrowserOptions,
                list: [ADAssetBrowsable],
                selects: [Int] = []) {
        self.reloadable = reloadable
        self.options = options
        self.list = list
        self.selectIndexs = selects
        self.selects = selectIndexs.map { list[$0] }
        super.init()
    }
    
}
