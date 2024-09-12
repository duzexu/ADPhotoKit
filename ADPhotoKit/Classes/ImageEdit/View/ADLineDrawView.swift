//
//  ADDrawColorsView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/28.
//

import UIKit

class ADLineDrawView: UIView, ADToolConfigable {
    
    var selectColor: UIColor {
        return colors[select]
    }
    
    var eraseAction: ((Bool) -> Void)?
    
    private let colors: [UIColor]
    private var select: Int = 0 {
        didSet {
            index = select
            eraserBtn.isSelected = false
            eraseAction?(false)
            collectionView.reloadData()
        }
    }
    private var index: Int = 0
    
    private var collectionView: UICollectionView!
    private var eraserBtn: ADEraserButton!

    init(colors: [UIColor], select: Int) {
        self.colors = colors
        self.select = select
        self.index = select
        super.init(frame: .zero)
        
        eraserBtn = ADEraserButton()
        eraserBtn.clickAction = { [weak self] sel in
            if sel {
                self?.index = -1
            }else{
                self?.index = self!.select
            }
            self?.eraseAction?(sel)
            self?.collectionView.reloadData()
        }
        addSubview(eraserBtn)
        eraserBtn.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottomMargin).offset(-64)
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.regisiter(cell: ADColorCell.self)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottomMargin).offset(-55)
            make.left.equalToSuperview().offset(80)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return collectionView.frame.contains(point) || eraserBtn.frame.contains(point)
    }
    
}

extension ADLineDrawView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADColorCell.reuseIdentifier, for: indexPath) as! ADColorCell
        
        cell.isSelect = indexPath.row == index
        cell.color = colors[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        select = indexPath.row
    }
    
}
