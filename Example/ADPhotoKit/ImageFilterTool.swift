//
//  ImageFilterTool.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/9/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

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

class ImageFilterTool: NSObject, ADImageEditTool {
    
    var image: UIImage {
        return UIImage(named: "filter")!
    }
    
    var selectImage: UIImage? {
        return UIImage(named: "filter_selected")
    }
    
    var isSelected: Bool = false
    
    var contentLockStatus: ((Bool) -> Void)?
    
    var toolConfigView: (UIView & ADToolConfigable)?
    
    var toolInteractView: (UIView & ADToolInteractable)?
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        return true
    }
    
    var identifier: String {
        return "com.adphoto.demo.imagefilter"
    }
    
    func encode() -> Any? {
        return nil
    }
    
    func decode(from: Any) {
        
    }
    
    let originImage: UIImage
    var filterInfos: [(String,UIImage)] = []
    var filterImages: [UIImage] = []
    var selectIndex: Int = 0
    
    init(image: UIImage, filters: [Filter] = Filter.allCases) {
        originImage = image
        super.init()
        
        let thumbnail = generateThumbnailImage(img: image) ?? image
        
        let selectV = ImageFilterSelectView(dataSource: self)
        toolConfigView = selectV
        let interactV = ImageFilterInteractView(frame: .zero)
        toolInteractView = interactV
        
        DispatchQueue.global().async {
            for filter in filters {
                let img = filter.process(img: thumbnail)
                self.filterInfos.append((filter.name,img))
                self.filterImages.append(filter.process(img: image))
            }
            DispatchQueue.main.async {
                interactV.imageView.image = self.filterImages[self.selectIndex]
                selectV.collectionView.reloadData()
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
        selectIndex = indexPath.row
        (toolInteractView as? ImageFilterInteractView)?.imageView.image = filterImages[indexPath.row]
        collectionView.reloadData()
    }
}
