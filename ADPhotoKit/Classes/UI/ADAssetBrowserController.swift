//
//  ADAssetViewerController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/2.
//

import UIKit
import Photos
import Kingfisher

class ADAssetBrowserController: UIViewController {
    
    let dataSource: [ADAssetBrowsable]
    var index: Int
    var selects: [Int]
    
    var collectionView: UICollectionView!
    
    init(assets: [ADAssetBrowsable], index: Int = 0, selects: [Int] = []) {
        self.dataSource = assets
        self.index = index
        self.selects = selects
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
    }
    
}

private extension ADAssetBrowserController {
    
    func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .black
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: -ADPhotoKitConfiguration.default.browseItemSpacing / 2, bottom: 0, right: -ADPhotoKitConfiguration.default.browseItemSpacing / 2))
        }
        
        collectionView.regisiter(cell: ADImageBrowserCell.self)
        collectionView.regisiter(cell: ADVideoBrowserCell.self)
    }
    
}

extension ADAssetBrowserController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ADPhotoKitConfiguration.default.browseItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ADPhotoKitConfiguration.default.browseItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: ADPhotoKitConfiguration.default.browseItemSpacing / 2, bottom: 0, right: ADPhotoKitConfiguration.default.browseItemSpacing / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = dataSource[indexPath.row]
        var cell: ADBrowserBaseCell
        switch model.browseAsset {
        case let .image(source):
            let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ADImageBrowserCell.reuseIdentifier, for: indexPath) as! ADImageBrowserCell
            imageCell.configure(with: source)
            cell = imageCell
        case let .video(source):
            let videoCell = collectionView.dequeueReusableCell(withReuseIdentifier: ADVideoBrowserCell.reuseIdentifier, for: indexPath) as! ADVideoBrowserCell
            cell = videoCell
        }
        return cell
    }
    
}
