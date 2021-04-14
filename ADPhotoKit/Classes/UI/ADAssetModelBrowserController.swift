//
//  ADAssetModelBrowserController.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/5.
//

import UIKit

class ADAssetModelBrowserController: ADAssetBrowserController {

    var listData: ADAssetListDataSource
    
    init(dataSource: ADAssetListDataSource, index: Int? = nil) {
        self.listData = dataSource
        let selects = dataSource.selects.compactMap { $0.index }
        super.init(assets: dataSource.list, index: index, selects: selects)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didSelectsUpdate() {
        super.didSelectsUpdate()
        listData.reloadSelectAssetIndexs(dataSource.selectIndexs, current: dataSource.index)
    }
    
}
