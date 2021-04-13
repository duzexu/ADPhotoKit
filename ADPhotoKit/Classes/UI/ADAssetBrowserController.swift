//
//  ADAssetViewerController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/2.
//

import UIKit
import Photos
import Kingfisher

extension ADAsset {
    var reuseIdentifier: String {
        switch self {
        case .image(_):
            return ADImageBrowserCell.reuseIdentifier
        case .video(_):
            return ADVideoBrowserCell.reuseIdentifier
        }
    }
}

class ADAssetBrowserController: UIViewController {
    
    /// dataSource
    var dataSource: ADAssetBrowserDataSource!
    
    /// ui
    var collectionView: UICollectionView!
    
    var controlsView: ADBrowserControlsView!
    var navView: ADBrowserNavBarable!
    var toolView: ADBrowserToolBarable!
    
    /// trans
    var popTransition: ADAssetBrowserInteractiveTransition?
    
    init(assets: [ADAssetBrowsable], index: Int = 0, selects: [Int] = []) {
        dataSource = ADAssetBrowserDataSource(options: .default, list: assets, index: index, selects: selects)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTransition()
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(row: dataSource.index, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func didSelectsUpdate() {
        
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
        
        dataSource?.listView = collectionView
        
        navView = ADBrowserNavBarView(dataSource: dataSource)
        navView.backActionBlock = { [weak self] in
            self?.didSelectsUpdate()
            if let _ = self?.navigationController?.popViewController(animated: true) {
            }else{
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        toolView = ADBrowserToolBarView(dataSource: dataSource)
        controlsView = ADBrowserControlsView(topView: navView, bottomView: toolView)
        view.addSubview(controlsView)
        controlsView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setupTransition() {
        guard let nav = navigationController else {
            return
        }
        guard nav.viewControllers.count > 1 else {
            return
        }
        let from = nav.viewControllers[nav.viewControllers.count-2]
        guard from is ADAssetBrowserTransitionContextTo else {
            return
        }
        navigationController?.delegate = self
        popTransition = ADAssetBrowserInteractiveTransition(transable: self)
    }
    
    func hideOrShowControlsView() {
        controlsView.isHidden = !controlsView.isHidden
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
        return dataSource.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = dataSource.list[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.browseAsset.reuseIdentifier, for: indexPath) as! ADBrowserBaseCell
        cell.singleTapBlock = { [weak self] in
            self?.hideOrShowControlsView()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = dataSource.list[indexPath.row]
        switch model.browseAsset {
        case let .image(source):
            if let imageCell = cell as? ADImageBrowserCell {
                imageCell.configure(with: source, indexPath: indexPath)
            }
        case let .video(source):
            if let videoCell = cell as? ADVideoBrowserCell {
                videoCell.configure(with: source, indexPath: indexPath)
            }
        }
        (cell as? ADBrowserBaseCell)?.cellWillDisplay()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ADBrowserBaseCell)?.cellDidEndDisplay()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        var idx = Int(offset.x / scrollView.bounds.width)
        idx = max(0, min(idx, dataSource.list.count-1))
        if idx != dataSource.index  {
            dataSource.didIndexChange(idx)
        }
    }
    
}

extension ADAssetBrowserController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            return popTransition?.interactive == true ? ADAssetBrowserTransition() : nil
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return popTransition?.interactive == true ? popTransition : nil
    }
    
}

extension ADAssetBrowserController: ADAssetBrowserInteractiveTransitionDelegate {
    
    func transitionShouldStart(_ point: CGPoint) -> Bool {
        if !controlsView.isHidden {
            return controlsView.insideTransitionArea(point: point)
        }
        return true
    }
    
    func transitionDidStart() {
        
    }
    
    func transitionDidCancel(view: UIView?) {
        let cell = collectionView.cellForItem(at: IndexPath(row: dataSource.index, section: 0)) as! ADBrowserBaseCell
        cell.transationCancel(view: view!)
    }
    
    func transitionDidFinish() {
        didSelectsUpdate()
    }
}

extension ADAssetBrowserController: ADAssetBrowserTransitionContextFrom {
    
    var contextIdentifier: String {
        return dataSource.current.browseAsset.identifier
    }
    
    func transitionInfo(convertTo: UIView) -> (UIView, CGRect) {
        let cell = collectionView.cellForItem(at: IndexPath(row: dataSource.index, section: 0)) as! ADBrowserBaseCell
        let info = cell.transationBegin()
        return (info.0, cell.convert(info.1, to: convertTo))
    }
    
}
