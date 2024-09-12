//
//  ImageFilterTool.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/9/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

#if Module_ImageEdit
enum Filter: CaseIterable {
    case none
    case chrome
    case fade
    case instant
    case process
    case transfer
    
    var name: String {
        switch self {
        case .none:
            return "None"
        case .chrome:
            return "Chrome"
        case .fade:
            return "Fade"
        case .instant:
            return "Instant"
        case .process:
            return "Process"
        case .transfer:
            return "Transfer"
        }
    }
    
    var filterName: String {
        switch self {
        case .none:
            return ""
        case .chrome:
            return "CIPhotoEffectChrome"
        case .fade:
            return "CIPhotoEffectFade"
        case .instant:
            return "CIPhotoEffectInstant"
        case .process:
            return "CIPhotoEffectProcess"
        case .transfer:
            return "CIPhotoEffectTransfer"
        }
    }
    
    func process(img: UIImage) -> UIImage {
        if self == .none {
            return img
        }
        if let cgImg = img.cgImage {
            let ciImage = CIImage(cgImage: cgImg)
            let filter = CIFilter(name: filterName)
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            if let output = filter?.outputImage {
                let context = CIContext()
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return img
    }
}

enum FilterActionData {
    case update(old: Int, new: Int)
}

class FilterAction: ADEditAction {
    var data: FilterActionData
    var identifier: String
    
    init(data: FilterActionData, identifier: String) {
        self.data = data
        self.identifier = identifier
    }
}

class ImageFilterTool: NSObject, ADImageEditTool, ADSourceImageEditable {
    
    var modifySourceImage: ((UIImage) -> Void)?
    
    var image: UIImage {
        return UIImage(named: "filter")!
    }
    
    var selectImage: UIImage? {
        return UIImage(named: "filter_selected")
    }
    
    var isSelected: Bool = false
    
    var contentLockStatus: ((Bool) -> Void)?
    
    var toolConfigView: ADToolConfigable?
    
    var toolInteractView: ADToolInteractable?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        return true
    }
    
    var identifier: String {
        return "com.adphoto.demo.imagefilter"
    }
    
    func encode() -> Any? {
        return ["index":selectIndex]
    }
    
    func decode(from: Any) {
        if let json = from as? Dictionary<String,Any> {
            selectIndex = json["index"] as? Int ?? 0
        }
        indexDidChange()
    }
    
    let originImage: UIImage
    var filterInfos: [(String,UIImage)] = []
    var filterImages: [UIImage] = []
    var selectIndex: Int = -1
    
    init(image: UIImage, filters: [Filter] = Filter.allCases) {
        originImage = image
        super.init()
        
        let thumbnail = generateThumbnailImage(img: image) ?? image
        
        let selectV = ImageFilterSelectView(dataSource: self)
        toolConfigView = selectV
        
        DispatchQueue.global().async {
            for filter in filters {
                let img = filter.process(img: thumbnail)
                self.filterInfos.append((filter.name,img))
                self.filterImages.append(filter.process(img: image))
            }
            DispatchQueue.main.async {
                self.indexDidChange()
            }
        }
        
        func generateThumbnailImage(img: UIImage) -> UIImage? {
            let size: CGSize
            let ratio = (img.size.width / img.size.height)
            let fixLength: CGFloat = 200
            if ratio >= 1 {
                size = CGSize(width: fixLength * ratio, height: fixLength)
            } else {
                size = CGSize(width: fixLength, height: fixLength / ratio)
            }
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            img.draw(in: CGRect(origin: .zero, size: size))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        }
    }
    
    func indexDidChange() {
        guard selectIndex >= 0 else {
            (toolConfigView as? ImageFilterSelectView)?.collectionView.reloadData()
            modifySourceImage?(originImage)
            return
        }
        guard selectIndex < filterImages.count else {
            return
        }
        (toolConfigView as? ImageFilterSelectView)?.collectionView.reloadData()
        modifySourceImage?(filterImages[selectIndex])
    }
    
    func undo(action: any ADEditAction) {
        if let action = action as? FilterAction {
            switch action.data {
            case .update(let old, _):
                selectIndex = old
                indexDidChange()
            }
        }
    }
    
    func redo(action: any ADEditAction) {
        if let action = action as? FilterAction {
            switch action.data {
            case .update(_, let new):
                selectIndex = new
                indexDidChange()
            }
        }
    }
    
}

extension ImageFilterTool: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        
        let info = filterInfos[indexPath.row]
        
        cell.nameLabel.text = info.0
        cell.imageView.image = info.1
        
        if selectIndex == indexPath.row {
            cell.nameLabel.textColor = .red
        } else {
            cell.nameLabel.textColor = .white
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        undoManager.push(action: FilterAction(data: .update(old: selectIndex, new: indexPath.row), identifier: identifier))
        selectIndex = indexPath.row
        indexDidChange()
    }
}
#endif
