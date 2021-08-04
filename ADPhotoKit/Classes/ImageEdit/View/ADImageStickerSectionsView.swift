//
//  ADImageStickerSectionsView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/8/4.
//

import UIKit

protocol ADImageStickerSectionsDataSource: AnyObject {
    func numberOfSections(in sectionView: ADImageStickerSectionsView) -> Int
    func sectionsView(_ sectionsView: ADImageStickerSectionsView, sectionAt index: Int) -> ADImageStickerDataSource.StickerSection
    
    func sectionsView(_ sectionsView: ADImageStickerSectionsView, didSelect section: Int)
    func dismiss(_ sectionsView: ADImageStickerSectionsView)
}

class ADImageStickerSectionsView: UIView {

    weak var dataSource: ADImageStickerSectionsDataSource?
    
    var collectionView: UICollectionView!
    
    var selectSection: Int = -1
    
    init(dataSource: ADImageStickerSectionsDataSource) {
        self.dataSource = dataSource
        super.init(frame: .zero)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 44, height: 44)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-60)
        }
        collectionView.regisiter(cell: ADImageStickerSectionSelectCell.self)
        
        let closeBtn = UIButton(type: .custom)
        closeBtn.setImage(Bundle.image(name: "icons_outlined_session_arrow_down", module: .imageEdit), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didSelect(section: Int) {
        if selectSection != section {
            selectSection = section
            collectionView.selectItem(at: IndexPath(row: section, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    @objc func closeAction(_ sender: UIButton) {
        dataSource?.dismiss(self)
    }
    
}

extension ADImageStickerSectionsView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADImageStickerSectionSelectCell.reuseIdentifier, for: indexPath) as! ADImageStickerSectionSelectCell
        if let item = dataSource?.sectionsView(self, sectionAt: indexPath.row) {
            cell.configure(with: item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource?.sectionsView(self, didSelect: indexPath.row)
    }
}
