//
//  ADImageStickerSelectController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/27.
//

import UIKit

public struct ADImageStickerDataSource {
    
    public struct StickerItem {
        public let image: UIImage
        public let name: String?
        
        public init(image: UIImage, name: String? = nil) {
            self.image = image
            self.name = name
        }
    }
    
    public struct StickerSection {
        public let name: String
        public let icon: UIImage
        public let items: [StickerItem]
        public let itemNameOn: Bool
        public let info: Dictionary<String,Any>?
        
        public init(icon: UIImage, name: String, items: [StickerItem], itemNameOn: Bool = true, info: Dictionary<String,Any>? = nil) {
            self.icon = icon
            self.name = name
            self.items = items
            self.itemNameOn = itemNameOn
            self.info = info
        }
    }
    
    public let sections: [StickerSection]
    
    public init(sections: [StickerSection]) {
        self.sections = sections
    }
    
}

class ADImageStickerSelectController: UIViewController, ADImageStickerSelectConfigurable {
    
    var imageDidSelect: ((UIImage) -> Void)?
    
    let dataSource: ADImageStickerDataSource
    
    private var bottomView: UIView!
    private var sectionsView: ADImageStickerSectionsView!
    private var collectionView: UICollectionView!
    
    required init(dataSource: ADImageStickerDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        singleTap.delegate = self
        view.addGestureRecognizer(singleTap)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let path = UIBezierPath(roundedRect: bottomView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8))
        bottomView.layer.mask = nil
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        bottomView.layer.mask = maskLayer
    }

}

private extension ADImageStickerSelectController {
    func setupUI() {
        bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(400+tabBarOffset)
        }
        
        let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        bottomView.addSubview(visualView)
        visualView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        sectionsView = ADImageStickerSectionsView(dataSource: self)
        sectionsView.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        sectionsView.didSelect(section: 0)
        bottomView.addSubview(sectionsView)
        sectionsView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: screenWidth, height: 340+tabBarOffset)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        bottomView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }
        collectionView.regisiter(cell: ADImageStickerSectionCell.self)
    }
}

extension ADImageStickerSelectController {
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension ADImageStickerSelectController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADImageStickerSectionCell.reuseIdentifier, for: indexPath) as! ADImageStickerSectionCell
        cell.configure(with: dataSource.sections[indexPath.row])
        cell.didSelectImage = { [weak self] img in
            self?.imageDidSelect?(img)
            self?.dismiss(animated: true, completion: nil)
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            let index = Int(scrollView.contentOffset.x / screenWidth)
            sectionsView.didSelect(section: index)
        }
    }
}

extension ADImageStickerSelectController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: view)
        return !bottomView.frame.contains(point)
    }
}

extension ADImageStickerSelectController: ADImageStickerSectionsDataSource {
    func numberOfSections(in sectionView: ADImageStickerSectionsView) -> Int {
        return dataSource.sections.count
    }
    
    func sectionsView(_ sectionsView: ADImageStickerSectionsView, sectionAt index: Int) -> ADImageStickerDataSource.StickerSection {
        return dataSource.sections[index]
    }
    
    func sectionsView(_ sectionsView: ADImageStickerSectionsView, didSelect section: Int) {
        collectionView.selectItem(at: IndexPath(row: section, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }
    
    func dismiss(_ sectionsView: ADImageStickerSectionsView) {
        dismiss(animated: true, completion: nil)
    }
}
