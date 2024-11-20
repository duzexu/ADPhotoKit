//
//  VideoFilterTool.swift
//  ADPhotoKit_Example
//
//  Created by du on 2024/11/19.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import ADPhotoKit
import AVFoundation

#if Module_VideoEdit
enum VideoFilter: CaseIterable {
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

class VideoFilterTool: NSObject, ADVideoEditTool {
    var playableRectUpdate: ((CGFloat, CGFloat, Bool) -> Void)!
    
    weak var videoPlayable: ADVideoPlayable?
    
    var image: UIImage {
        return UIImage(named: "filter")!
    }
    
    var selectImage: UIImage? {
        return UIImage(named: "filter_selected")
    }
    
    var isSelected: Bool = false
    
    var isEdited: Bool {
        return selectIndex != -1
    }
    
    var toolConfigView: ADToolConfigable?
    
    var toolInteractView: ADToolInteractable?
    
    private var filterInfos: [(String,UIImage)] = []
    private var filterImages: [UIImage] = []
    private var selectIndex: Int = -1
    
    func toolDidSelect(ctx: UIViewController?) -> Bool {
        return true
    }
    
    var identifier: String {
        return "com.adphoto.demo.videofilter"
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
    
    init(asset: AVAsset, filters: [VideoFilter] = VideoFilter.allCases) {
        super.init()
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.apertureMode = .encodedPixels
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { [weak self] _, cgImage, _, result, error in
            if result == .succeeded, let cg = cgImage {
                let image = UIImage(cgImage: cg)
                DispatchQueue.global().async {
                    for filter in filters {
                        let img = filter.process(img: image)
                        self?.filterInfos.append((filter.name,img))
                        self?.filterImages.append(filter.process(img: image))
                    }
                    DispatchQueue.main.async {
                        self?.indexDidChange()
                    }
                }
            }
        }
        let selectV = FilterSelectView(dataSource: self)
        toolConfigView = selectV
    }
    
    func indexDidChange() {
        (videoPlayable as? VideoPlayerView)?.filterIndex = selectIndex
        (toolConfigView as? FilterSelectView)?.collectionView.reloadData()
    }
}


extension VideoFilterTool: UICollectionViewDataSource, UICollectionViewDelegate {
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
        indexDidChange()
    }
}
#endif
