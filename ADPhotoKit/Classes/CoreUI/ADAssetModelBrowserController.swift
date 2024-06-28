//
//  ADAssetModelBrowserController.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/4/5.
//

import UIKit
import Photos

/// Subclass of `ADAssetBrowserController` to browser `PHAsset` in big mode.
class ADAssetModelBrowserController: ADAssetBrowserController {

    var listData: ADAssetListDataSource
    
    init(config: ADPhotoKitConfig, dataSource: ADAssetListDataSource, index: Int? = nil) {
        self.listData = dataSource
        var selects: [PHAsset] = []
        #if Module_ImageEdit
        for item in dataSource.selects {
            let asset = item.asset
            asset.imageEditInfo = item.imageEditInfo
            selects.append(asset)
        }
        #else
        selects = dataSource.selects.map { $0.asset }
        #endif
        super.init(config: config, assets: dataSource.list, selects: selects, index: index)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didSelectsUpdate() {
        super.didSelectsUpdate()
        listData.reloadSelectAssetIndexs(dataSource.selectIndexs.compactMap { $0 }, current: dataSource.index)
    }
    
    override func finishSelection() {
        didSelectsUpdate()
        if config.browserOpts.contains(.fetchImage) {
            listData.fetchSelectImages(original: toolBarView.isOriginal, asGif: config.assetOpts.contains(.selectAsGif), inQueue: config.fetchImageQueue) { [weak self] selected in
                self?.config.pickerSelect?(selected, self!.toolBarView.isOriginal)
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }else{
            let selected = listData.selects.map { ADPhotoKitUI.Asset($0.asset,$0.result(with: nil),nil) }
            config.pickerSelect?(selected, toolBarView.isOriginal)
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    #if Module_ImageEdit
    override func didImageEditInfoUpdate(_ info: ADImageEditInfo) {
        super.didImageEditInfoUpdate(info)
        listData.reloadImageEditInfo(info, at: dataSource.index)
    }
    #endif
    
    override func canSelectWithCurrentIndex() -> Bool {
        guard dataSource.index >= 0 else {
            return false
        }
        let item = listData.list[dataSource.index]
        switch item.type {
        case let .video(duration, _):
            if super.canSelectWithCurrentIndex() {
                if let max = config.params.maxVideoTime {
                    if duration > max {
                        let message = String(format: ADLocale.LocaleKey.longerThanMaxVideoDuration.localeTextValue, max)
                        ADAlert.alert().alert(on: self, title: nil, message: message, actions: [ADLocale.LocaleKey.ok.localeTextValue], completion: nil)
                        return false
                    }
                }
                if let min = config.params.minVideoTime {
                    if duration < min {
                        let message = String(format: ADLocale.LocaleKey.shorterThanMinVideoDuration.localeTextValue, min)
                        ADAlert.alert().alert(on: self, title: nil, message: message, actions: [ADLocale.LocaleKey.ok.localeTextValue], completion: nil)
                        return false
                    }
                }
                if let size = item.assetSize {
                    if let max = config.params.maxVideoSize {
                        if size > max {
                            let message = String(format: ADLocale.LocaleKey.largerThanMaxVideoDataSize.localeTextValue, max)
                            ADAlert.alert().alert(on: self, title: nil, message: message, actions: [ADLocale.LocaleKey.ok.localeTextValue], completion: nil)
                            return false
                        }
                    }
                    if let min = config.params.minVideoSize {
                        if size < min {
                            let message = String(format: ADLocale.LocaleKey.smallerThanMinVideoDataSize.localeTextValue, min)
                            ADAlert.alert().alert(on: self, title: nil, message: message, actions: [ADLocale.LocaleKey.ok.localeTextValue], completion: nil)
                            return false
                        }
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
