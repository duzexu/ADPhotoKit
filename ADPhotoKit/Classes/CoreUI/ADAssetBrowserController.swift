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
    var navBarView: ADBrowserNavBarConfigurable!
    var toolBarView: ADBrowserToolBarConfigurable!
    
    /// trans
    var popTransition: ADAssetBrowserInteractiveTransition?
    
    init(config: ADPhotoKitConfig, assets: [ADAssetBrowsable], selects: [ADAssetBrowsable] = [], index: Int? = nil) {
        self.config = config
        self.dataSource = ADAssetBrowserDataSource(options: config.browserOpts, list: assets, selects: selects, index: index)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        ADPhotoKitConfiguration.default.customBrowserControllerBlock?(self)
        setupTransition()
        collectionView.layoutIfNeeded()
        if dataSource.list.count > 0 {
            collectionView.scrollToItem(at: IndexPath(row: dataSource.index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolBarView.isOriginal = config.isOriginal
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        config.isOriginal = toolBarView.isOriginal
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
        config.browserSelect?(dataSource.selects)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    #if Module_ImageEdit
    /// Called when image edit finished.
    open func didImageEditInfoUpdate(_ info: ADImageEditInfo) {
        dataSource.list[dataSource.index].imageEditInfo = info
        if !dataSource.isSelected && canSelectWithCurrentIndex() {
            dataSource.appendSelect(dataSource.index)
        }
        collectionView.reloadData()
        dataSource.selectView?.reloadData()
        if config.browserOpts.contains(.saveImageAfterEdit), let img = info.editImg {
            ADPhotoManager.saveImageToAlbum(image: img, completion: nil)
        }
    }
    #endif
    
    #if Module_VideoEdit
    /// Called when video edit finished.
    open func didVideoEditInfoUpdate(_ info: ADVideoEditInfo) {
        dataSource.list[dataSource.index].videoEditInfo = info
        if !dataSource.isSelected && canSelectWithCurrentIndex() {
            dataSource.appendSelect(dataSource.index)
        }
        collectionView.reloadData()
        dataSource.selectView?.reloadData()
        if config.browserOpts.contains(.saveVideoAfterEdit), let url = info.editUrl {
            ADPhotoManager.saveVideoToAlbum(url: url, completion: nil)
        }
    }
    #endif
    
    /// Indicated current asset can select or not. Subclass can override to do something.
    /// - Returns: If `true`, means you can select. Otherwise can't.
    open func canSelectWithCurrentIndex() -> Bool {
        let selected = dataSource.selects.count
        let max = config.params.maxCount ?? UInt.max
        guard let item = dataSource.current else {
            return false
        }
        let itemIsImage = item.browseAsset.isImage

        func canSelect() -> Bool? {
            let videoCount = dataSource.selects.filter { !$0.browseAsset.isImage }.count
            let maxVideoCount = config.params.maxVideoCount ?? UInt.max
            let maxImageCount = config.params.maxImageCount ?? UInt.max
            if videoCount >= maxVideoCount, !itemIsImage {
                let message = String(format: ADLocale.LocaleKey.exceededMaxVideoSelectCount.localeTextValue, maxVideoCount)
                ADAlert.alert().alert(on: self, title: nil, message: message, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                return false
            }else if (dataSource.selects.count - videoCount) >= maxImageCount, itemIsImage {
                let message = String(format: ADLocale.LocaleKey.exceededMaxImageSelectCount.localeTextValue, maxImageCount)
                ADAlert.alert().alert(on: self, title: nil, message: message, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                return false
            }
            return nil
        }
        
        if selected < max {
            if config.assetOpts.contains(.mixSelect) {
                if let value = canSelect() {
                    return value
                }
            }else{
                if let selectMediaImage = config.selectMediaImage, item.browseAsset.isImage != selectMediaImage {
                    if selectMediaImage {
                        ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.videoNotSelectable.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                    }else{
                        ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.imageNotSelectable.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                    }
                    return false
                }else{
                    if let value = canSelect() {
                        return value
                    }
                }
            }
        }else{
            let message = String(format: ADLocale.LocaleKey.exceededMaxSelectCount.localeTextValue, max)
            ADAlert.alert().alert(on: self, title: nil, message: message, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
            return false
        }
        return true
    }
}

private extension ADAssetBrowserController {
    
    func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .black
        
        let layout = ADCollectionViewFlowLayout()
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
        dataSource.selectAssetExistOrNot = { [weak self] exist in
            self?.popTransition?.isEnabled = exist
        }
        dataSource.selectAssetChanged = { [weak self] count in
            #if Module_UI
            if count == 1 {
                if let model = self?.dataSource.selects.randomElement() {
                    self?.config.selectMediaImage = model.browseAsset.isImage
                }
            }
            if count == 0 {
                self?.config.selectMediaImage = nil
            }
            #endif
        }
        
        navBarView = ADPhotoUIConfigurable.browserNavBar(dataSource: dataSource, config: config)
        navBarView.leftActionBlock = { [weak self] in
            self?.didSelectsUpdate()
            if let _ = self?.navigationController?.popViewController(animated: true) {
            }else{
                self?.config.canceled?()
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
        toolBarView = ADPhotoUIConfigurable.browserToolBar(dataSource: dataSource, config: config)
        controlsView = ADBrowserControlsView(topView: navBarView, bottomView: toolBarView)
        view.addSubview(controlsView)
        controlsView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        toolBarView.editActionBlock = { [weak self] in
            self?.editAssetAction()
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
    
    func editAssetAction() {
        guard let current = dataSource.current else {
            return
        }
        let maxSize = CGSize(width: screenHeight*UIScreen.main.scale, height: screenHeight*UIScreen.main.scale)
        switch current.browseAsset {
        case let .image(imageSource):
            switch imageSource {
            case let .network(url):
                var task: DownloadTask?
                let hud = ADProgress.progressHUD()
                hud.timeoutBlock = {
                    ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.timeout.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                    if let task = task {
                        task.cancel()
                    }
                }
                hud.show(timeout: ADPhotoKitConfiguration.default.fetchTimeout)
                task = KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                    let img = try? result.get().image
                    self?.editImage(img?.resize(to: maxSize, mode: .scaleAspectFit))
                    hud.hide()
                }
            case let .album(asset):
                var requestId: PHImageRequestID?
                let hud = ADProgress.progressHUD()
                hud.timeoutBlock = {
                    ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.timeout.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                    if let requestId = requestId {
                        PHImageManager.default().cancelImageRequest(requestId)
                    }
                }
                hud.show(timeout: ADPhotoKitConfiguration.default.fetchTimeout)
                requestId = ADPhotoManager.fetchImage(for: asset, size: maxSize, synchronous: true) { [weak self] img, _, _ in
                    self?.editImage(img)
                    hud.hide()
                }
            case let .local(img, _):
                editImage(img.resize(to: maxSize, mode: .scaleAspectFit))
            }
            break
        case let .video(videoSource):
            switch videoSource {
            case let .network(url):
                editVideo(AVAsset(url: url))
            case let .album(asset):
                var requestId: PHImageRequestID?
                let hud = ADProgress.progressHUD()
                hud.timeoutBlock = {
                    ADAlert.alert().alert(on: self, title: nil, message: ADLocale.LocaleKey.timeout.localeTextValue, actions: [.default(ADLocale.LocaleKey.ok.localeTextValue)], completion: nil)
                    if let requestId = requestId {
                        PHImageManager.default().cancelImageRequest(requestId)
                    }
                }
                hud.show(timeout: ADPhotoKitConfiguration.default.fetchTimeout)
                requestId = ADPhotoManager.fetchAVAsset(for: asset, completion: { [weak self] asset, _, _ in
                    self?.editVideo(asset)
                    hud.hide()
                })
            case let .local(url):
                editVideo(AVAsset(url: url))
            }
            break
        }
    }
    
    func editImage(_ img: UIImage?) {
        #if Module_ImageEdit
        if let image = img, !config.assetOpts.contains(.selectAsLivePhoto) {
            let vc = ADImageEditConfigure.imageEditVC(image: image, editInfo: dataSource.current!.imageEditInfo)
            vc.imageDidEdit = { [weak self] editInfo in
                self?.didImageEditInfoUpdate(editInfo)
            }
            navigationController?.pushViewController(vc, animated: false)
        }
        #endif
    }
    
    func editVideo(_ asset: AVAsset?) {
        #if Module_VideoEdit
        if let asset = asset {
            let vc = ADVideoEditConfigure.videoEditVC(config: config, asset: asset, editInfo: dataSource.current!.videoEditInfo)
            vc.videoDidEdit = { [weak self] editInfo in
                self?.didVideoEditInfoUpdate(editInfo)
            }
            navigationController?.pushViewController(vc, animated: false)
        }
        #endif
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
        let cell = ADPhotoUIConfigurable.browserCell(collectionView: collectionView, indexPath: indexPath, asset: model.browseAsset)
        cell.singleTapBlock = { [weak self] in
            self?.hideOrShowControlsView()
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = dataSource.list[indexPath.row]
        switch model.browseAsset {
        case let .image(source):
            if let imageCell = cell as? ADImageBrowserCellConfigurable {
                #if Module_ImageEdit
                if let editImg = model.imageEditInfo?.editImg {
                    imageCell.configure(with: .local(editImg, UUID().uuidString), config: config)
                }else{
                    imageCell.configure(with: source, config: config)
                }
                #else
                imageCell.configure(with: source, config: config)
                #endif
            }
        case let .video(source):
            if let videoCell = cell as? ADVideoBrowserCellConfigurable {
                #if Module_VideoEdit
                if let url = model.videoEditInfo?.editUrl {
                    videoCell.configure(with: .local(url))
                }else{
                    videoCell.configure(with: source)
                }
                #else
                videoCell.configure(with: source)
                #endif
                
            }
        }
        (cell as? ADBrowserCellConfigurable)?.cellWillDisplay()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ADBrowserCellConfigurable)?.cellDidEndDisplay()
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
        let cell = collectionView.cellForItem(at: IndexPath(row: dataSource.index, section: 0)) as! ADBrowserCellConfigurable
        cell.transationCancel(view: view!)
    }
    
    func transitionDidFinish() {
        didSelectsUpdate()
    }
}

extension ADAssetBrowserController: ADAssetBrowserTransitionContextFrom {
    
    var contextIdentifier: String {
        return dataSource.current?.browseAsset.identifier ?? ""
    }
    
    func transitionInfo(convertTo: UIView) -> (UIView, CGRect) {
        let cell = collectionView.cellForItem(at: IndexPath(row: dataSource.index, section: 0)) as! ADBrowserCellConfigurable
        let info = cell.transationBegin()
        return (info.0, cell.convert(info.1, to: convertTo))
    }
    
}
