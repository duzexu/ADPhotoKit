//
//  ADAssetModelBrowserController.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/5.
//

import UIKit

class ADAssetModelBrowserController: ADAssetBrowserController {

    var listData: ADAssetListDataSource
    
    init(model: ADPhotoKitConfig, dataSource: ADAssetListDataSource, index: Int? = nil) {
        self.listData = dataSource
        let selects = dataSource.selects.compactMap { $0.index }
        super.init(model: model, assets: dataSource.list, index: index, selects: selects)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didSelectsUpdate() {
        super.didSelectsUpdate()
        listData.reloadSelectAssetIndexs(dataSource.selectIndexs, current: dataSource.index)
    }
    
    override func finishSelection() {
        if model.browserOpts.contains(.fetchImage) {
            listData.fetchSelectImages(original: toolBarView.isOriginal, asGif: model.assetOpts.contains(.selectAsGif)) { [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }else{
            let selected = listData.selects.map { ADPhotoKitUI.Asset($0.asset,nil,nil) }
            ADPhotoKitUI.config.pickerSelect?(selected, toolBarView.isOriginal)
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func canSelectWithCurrentIndex() -> Bool {
        let item = listData.list[dataSource.index]
        switch item.type {
        case let .video(duration, _):
            if super.canSelectWithCurrentIndex() {
                if let max = model.params.maxVideoTime {
                    if duration > max {
                        let message = String(format: ADLocale.LocaleKey.longerThanMaxVideoDuration.localeTextValue, max)
                        ADAlert.alert(on: self, message: message)
                        return false
                    }
                }
                if let min = model.params.minVideoTime {
                    if duration < min {
                        let message = String(format: ADLocale.LocaleKey.shorterThanMaxVideoDuration.localeTextValue, min)
                        ADAlert.alert(on: self, message: message)
                        return false
                    }
                }
                return true
            }else{
                return false
            }
        default:
            return super.canSelectWithCurrentIndex()
        }
    }
}
