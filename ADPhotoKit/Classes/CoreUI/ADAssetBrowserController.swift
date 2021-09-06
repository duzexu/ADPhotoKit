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

/// Controller to browser asset in big mode.
public class ADAssetBrowserController: UIViewController {
    
    let config: ADPhotoKitConfig
    
    /// The data source of browser assets.
    public var dataSource: ADAssetBrowserDataSource!
    
    /// View to display asset.
    public var collectionView: UICollectionView!
    
    var controlsView: ADBrowserControlsView!
    var navBarView: ADBrowserNavBarable!
    var toolBarView: ADBrowserToolBarable!
    
    /// trans
    var popTransition: ADAssetBrowserInteractiveTransition?
    
    init(config: ADPhotoKitConfig, assets: [ADAssetBrowsable], index: Int? = nil, selects: [Int] = []) {
        self.config = config
        self.dataSource = ADAssetBrowserDataSource(options: config.browserOpts, list: assets, index: (index ?? selects.first) ?? 0, selects: selects)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        ADPhotoKitConfiguration.default.customBrowserControllerBlock?(self)
        setupTransition()
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(row: dataSource.index, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolBarView.isOriginal = ADPhotoKitUI.config.isOriginal
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ADPhotoKitUI.config.isOriginal = toolBarView.isOriginal
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return ADPhotoKitConfiguration.default.statusBarStyle ?? .lightContent
    }
    
    /// Called when return to thumbnail controller. Subclass can override to refresh thumbnail controller.
    open func didSelectsUpdate() {
        
    }
    
    /// Called when finish selection. Subclass can override to do something.
    open func finishSelection() {
        ADPhotoKitUI.config.browserSelect?(dataSource.selects)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    #if Module_ImageEdit
    /// Called when image edit finished.
    open func didImageEditInfoUpdate(_ info: ADImageEditInfo) {
        dataSource.list[dataSource.index].imageEditInfo = info
        collectionView.reloadData()
        if !dataSource.isSelected && canSelectWithCurrentIndex() {
            dataSource.appendSelect(dataSource.index)
        }
        dataSource.selectView?.reloadData()
    }
    #endif
    
    /// Indicated current asset can select or not. Subclass can override to do something.
    /// - Returns: If `true`, means you can select. Otherwise can't.
    open func canSelectWithCurrentIndex() -> Bool {
        let selected = dataSource.selects.count
        let max = config.params.maxCount ?? Int.max
        let item = dataSource.current
        if selected < max {
            let itemIsImage = item.browseAsset.isImage
            if config.assetOpts.contains(.mixSelect) {
                let videoCount = dataSource.selects.filter { !$0.browseAsset.isImage }.count
                let maxVideoCount = config.params.maxVideoCount ?? Int.max
                let maxImageCount = config.params.maxImageCount ?? Int.max
                if videoCount >= maxVideoCount, !itemIsImage {
                    let message = String(format: ADLocale.LocaleKey.exceededMaxVideoSelectCount.localeTextValue, maxVideoCount)
                    ADPhotoUIConfigurable.alert().alert(on: self, title: nil, message: message, completion: nil)
                    return false
                }else if (dataSource.selects.count - videoCount) >= maxImageCount, itemIsImage {
                    ADPhotoUIConfigurable.alert().alert(on: self, title: nil, message: "最多选择\(maxImageCount)个图片", completion: nil)
                    return false
                }
            }else{
                if let selectMediaImage = config.selectMediaImage, item.browseAsset.isImage != selectMediaImage {
                    if selectMediaImage {
                        ADPhotoUIConfigurable.alert().alert(on: self, title: nil, message: "不能选择视频", completion: nil)
                    }else{
                        ADPhotoUIConfigurable.alert().alert(on: self, title: nil, message: "不能选择图片", completion: nil)
                    }
                    return false
                }else{
                    let videoCount = dataSource.selects.filter { !$0.browseAsset.isImage }.count
                    let maxVideoCount = config.params.maxVideoCount ?? Int.max
                    let maxImageCount = config.params.maxImageCount ?? Int.max
                    if videoCount >= maxVideoCount, !itemIsImage {
                        let message = String(format: ADLocale.LocaleKey.exceededMaxVideoSelectCount.localeTextValue, maxVideoCount)
                        ADPhotoUIConfigurable.alert().alert(on: self, title: nil, message: message, completion: nil)
                        return false
                    }else if (dataSource.selects.count - videoCount) >= maxImageCount, itemIsImage {
                        ADPhotoUIConfigurable.alert().alert(on: self, title: nil, message: "最多选择\(maxImageCount)个图片", completion: nil)
                        return false
                    }
                }
            }
        }else{
            let message = String(format: ADLocale.LocaleKey.exceededMaxSelectCount.localeTextValue, max)
            ADPhotoUIConfigurable.alert().alert(on: self, title: nil, message: message, completion: nil)
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
        
        ADPhotoKitConfiguration.default.customBrowserCellRegistor?(collectionView)
        
        dataSource?.listView = collectionView
        
        navBarView = ADPhotoUIConfigurable.browserNavBar(dataSource: dataSource)
        navBarView.leftActionBlock = { [weak self] in
            self?.didSelectsUpdate()
            if let _ = self?.navigationController?.popViewController(animated: true) {
            }else{
                ADPhotoKitUI.config.canceled?()
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        navBarView.selectActionBlock = { [weak self] value in
            guard let strong = self else { return false }
            if value {
                self?.dataSource.deleteSelect(strong.dataSource.index)
            }else{
                if strong.canSelectWithCurrentIndex() {
                    self?.dataSource.appendSelect(strong.dataSource.index)
                }else{
                    return false
                }
            }
            return true
        }
        toolBarView = ADPhotoUIConfigurable.browserToolBar(dataSource: dataSource)
        controlsView = ADBrowserControlsView(topView: navBarView, bottomView: toolBarView)
        view.addSubview(controlsView)
        controlsView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        func editAssetAction() {
            switch dataSource.current.browseAsset {
            case let .image(imageSource):
                switch imageSource {
                case let .network(url):
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        let img = try? result.get().image
                        editImage(img)
                    }
                case let .album(asset):
                    ADPhotoManager.fetchImage(for: asset, synchronous: true) { img, _, _ in
                        editImage(img)
                    }
                case let .local(img, _):
                    editImage(img)
                }
                break
            case .video(_):
                break
            }
        }
        
        func editImage(_ img: UIImage?) {
            #if Module_ImageEdit
            if let image = img, !ADPhotoKitUI.config.assetOpts.contains(.selectAsLivePhoto) {
                let vc = ADImageEditController(image: image, editInfo: dataSource.current.imageEditInfo)
                vc.imageDidEdit = { [weak self] editInfo in
                    self?.didImageEditInfoUpdate(editInfo)
                }
                navigationController?.pushViewController(vc, animated: false)
            }
            #endif
        }
        
        toolBarView.editActionBlock = {
            editAssetAction()
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
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ADPhotoKitConfiguration.default.browseItemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ADPhotoKitConfiguration.default.browseItemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: ADPhotoKitConfiguration.default.browseItemSpacing / 2, bottom: 0, right: ADPhotoKitConfiguration.default.browseItemSpacing / 2)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.list.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = dataSource.list[indexPath.row]
        var cell = ADPhotoUIConfigurable.browserCell(collectionView: collectionView, indexPath: indexPath, asset: model.browseAsset)
        cell.singleTapBlock = { [weak self] in
            self?.hideOrShowControlsView()
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = dataSource.list[indexPath.row]
        switch model.browseAsset {
        case let .image(source):
            if let imageCell = cell as? ADImageBrowserCellable {
                #if Module_ImageEdit
                if let editImg = model.imageEditInfo?.editImg {
                    imageCell.configure(with: .local(editImg, UUID().uuidString))
                }else{
                    imageCell.configure(with: source)
                }
                #else
                imageCell.configure(with: source)
                #endif
            }
        case let .video(source):
            if let videoCell = cell as? ADVideoBrowserCellable {
                videoCell.configure(with: source)
            }
        }
        (cell as? ADBrowserCellable)?.cellWillDisplay()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ADBrowserCellable)?.cellDidEndDisplay()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        var idx = Int(offset.x / scrollView.bounds.width)
        idx = max(0, min(idx, dataSource.list.count-1))
        if idx != dataSource.index  {
            dataSource.didIndexChange(idx)
        }
    }
    
}

extension ADAssetBrowserController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            return popTransition?.interactive == true ? ADAssetBrowserTransition() : nil
        }
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
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
        let cell = collectionView.cellForItem(at: IndexPath(row: dataSource.index, section: 0)) as! ADBrowserCellable
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
        let cell = collectionView.cellForItem(at: IndexPath(row: dataSource.index, section: 0)) as! ADBrowserCellable
        let info = cell.transationBegin()
        return (info.0, cell.convert(info.1, to: convertTo))
    }
    
}
