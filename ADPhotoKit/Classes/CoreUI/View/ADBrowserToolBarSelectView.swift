//
//  ADBrowserToolBarSelectView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/12.
//

import UIKit

class ADBrowserToolBarSelectView: UIView {
        
    weak var dataSource: ADAssetBrowserDataSource?
    
    private var collectionView: UICollectionView!
    
    private var isDraging = false

    init(dataSource: ADAssetBrowserDataSource) {
        self.dataSource = dataSource
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ADBrowserToolBarSelectView {
    func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        collectionView.regisiter(cell: ADBrowserToolBarCell.self)
        
        if #available(iOS 11.0, *) {
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
            collectionView.dragInteractionEnabled = true
            collectionView.isSpringLoaded = true
        } else {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
            collectionView.addGestureRecognizer(longPressGesture)
        }
        
        dataSource?.selectView = collectionView
    }
    
    // MARK: iOS10 拖动
    @objc func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            isDraging = true
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        } else if gesture.state == .changed {
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        } else if gesture.state == .ended {
            isDraging = false
            collectionView.endInteractiveMovement()
        } else {
            isDraging = false
            collectionView.cancelInteractiveMovement()
        }
    }
}

extension ADBrowserToolBarSelectView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.selects.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADBrowserToolBarCell.reuseIdentifier, for: indexPath) as! ADBrowserToolBarCell
        
        if let selects = dataSource?.selects {
            let asset = selects[indexPath.row]
            cell.configure(with: asset)
            if asset.browseAsset == dataSource?.current?.browseAsset {
                cell.layer.borderWidth = 4
            }else{
                cell.layer.borderWidth = 0
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if #available(iOS 11.0, *) {
            dataSource?.didSelectIndexChange(indexPath.row)
        }else{
            if !isDraging {
                dataSource?.didSelectIndexChange(indexPath.row)
            }
        }
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        isDraging = true
        let itemProvider = NSItemProvider()
        let item = UIDragItem(itemProvider: itemProvider)
        return [item]
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        isDraging = false
        
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }
        guard let item = coordinator.items.first else {
            return
        }
        guard let sourceIndexPath = item.sourceIndexPath else {
            return
        }
        
        if coordinator.proposal.operation == .move {
            dataSource?.moveSelect(from: sourceIndexPath.row, to: destinationIndexPath.row, reload: true)
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        dataSource?.moveSelect(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
}
