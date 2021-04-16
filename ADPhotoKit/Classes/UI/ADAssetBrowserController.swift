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
    
    let model: ADPhotoKitConfig
    
    /// dataSource
    var dataSource: ADAssetBrowserDataSource!
    
    /// ui
    var collectionView: UICollectionView!
    
    var controlsView: ADBrowserControlsView!
    var navBarView: ADNavBarable!
    var toolBarView: ADBrowserToolBarable!
    
    /// trans
    var popTransition: ADAssetBrowserInteractiveTransition?
    
    init(model: ADPhotoKitConfig, assets: [ADAssetBrowsable], index: Int? = nil, selects: [Int] = []) {
        self.model = model
        self.dataSource = ADAssetBrowserDataSource(options: .default, list: assets, index: (index ?? selects.first) ?? 0, selects: selects)
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
        toolBarView.isOriginal = ADPhotoKitUI.config.isOriginal
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ADPhotoKitUI.config.isOriginal = toolBarView.isOriginal
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open func didSelectsUpdate() {
        
    }
    
    open func finishSelection() {
        ADPhotoKitUI.config.browserSelect?(dataSource.selects)
    }
    
    open func canSelectWithCurrentIndex() -> Bool {
        let selected = dataSource.selects.count
        let max = model.params.maxCount ?? Int.max
        let item = dataSource.current
        if selected < max {
            let itemIsImage = item.browseAsset.isImage
            if model.assetOpts.contains(.mixSelect) {
                let videoCount = dataSource.selects.filter { !$0.browseAsset.isImage }.count
                let maxVideoCount = model.params.maxVideoCount ?? Int.max
                let maxImageCount = model.params.maxImageCount ?? Int.max
                if videoCount >= maxVideoCount, !itemIsImage {
                    let message = String(format: ADLocale.LocaleKey.exceededMaxVideoSelectCount.localeTextValue, maxVideoCount)
                    ADAlert.alert(on: self, message: message)
                    return false
                }else if (dataSource.selects.count - videoCount) >= maxImageCount, itemIsImage {
                    ADAlert.alert(on: self, message: "最多选择\(maxImageCount)个图片")
                    return false
                }
            }else{
                if item.browseAsset.isImage != model.selectMediaImage {
                    if model.selectMediaImage {
                        ADAlert.alert(on: self, message: "不能选择视频")
                    }else{
                        ADAlert.alert(on: self, message: "不能选择图片")
                    }
                    return false
                }else{
                    let videoCount = dataSource.selects.filter { !$0.browseAsset.isImage }.count
                    let maxVideoCount = model.params.maxVideoCount ?? Int.max
                    let maxImageCount = model.params.maxImageCount ?? Int.max
                    if videoCount >= maxVideoCount, !itemIsImage {
                        let message = String(format: ADLocale.LocaleKey.exceededMaxVideoSelectCount.localeTextValue, maxVideoCount)
                        ADAlert.alert(on: self, message: message)
                        return false
                    }else if (dataSource.selects.count - videoCount) >= maxImageCount, itemIsImage {
                        ADAlert.alert(on: self, message: "最多选择\(maxImageCount)个图片")
                        return false
                    }
                }
            }
        }else{
            let message = String(format: ADLocale.LocaleKey.exceededMaxSelectCount.localeTextValue, max)
            ADAlert.alert(on: self, message: message)
            return false
        }
        return true
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
        
        navBarView = ADBrowserNavBarView(dataSource: dataSource)
        navBarView.leftActionBlock = { [weak self] btn in
            self?.didSelectsUpdate()
            if let _ = self?.navigationController?.popViewController(animated: true) {
            }else{
                ADPhotoKitUI.config.canceled?()
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        navBarView.rightActionBlock = { [weak self] btn in
            guard let strong = self else { return }
            if btn.isSelected {
                self?.dataSource.deleteSelect(strong.dataSource.index)
            }else{
                if strong.canSelectWithCurrentIndex() {
                    self?.dataSource.appendSelect(strong.dataSource.index)
                }
            }
        }
        toolBarView = ADBrowserToolBarView(dataSource: dataSource)
        controlsView = ADBrowserControlsView(topView: navBarView, bottomView: toolBarView)
        view.addSubview(controlsView)
        controlsView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        toolBarView.doneActionBlock = { [weak self] in
            self?.finishSelection()
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
