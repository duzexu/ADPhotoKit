//
//  ADAlbumListController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import UIKit
import SnapKit

/// Controller to display albums.
public class ADAlbumListController: UIViewController {
    
    let config: ADPhotoKitConfig
    
    /// Use to show albums.
    public var tableView: UITableView!
    /// Data source contain album models.
    public var dataSource: ADAlbumListDataSource!
    
    var selects: [ADSelectAssetModel] = []
    
    init(config: ADPhotoKitConfig, selects: [ADSelectAssetModel] = []) {
        self.config = config
        self.selects = selects
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        ADPhotoKitConfiguration.default.customAlbumListControllerBlock?(self)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if dataSource.list.count == 0 {
            dataSource.reloadData { [weak self] in
                self?.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return ADPhotoKitConfiguration.default.statusBarStyle ?? .lightContent
    }
    
    func pushThumbnail(with album: ADAlbumModel, style: ADPickerStyle, animated: Bool) {
        let thumbnail = ADThumbnailViewController(config: config, album: album, style: style, selects: selects)
        thumbnail.selectAlbumBlock = { [weak self] selects in
            self?.selects = selects
        }
        navigationController?.pushViewController(thumbnail, animated: animated)
    }
}

extension ADAlbumListController {
    
    func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor(hex: 0x2D2D2D)
        
        tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(hex: 0x3C3C3C)
        tableView.rowHeight = 65
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tableView.regisiter(cell: ADAlbumListCell.self)
        
        ADPhotoKitConfiguration.default.customAlbumListCellRegistor?(tableView)
                
        let navBarView = ADPhotoUIConfigurable.albumListNavBar()
        navBarView.title = ADLocale.LocaleKey.photo.localeTextValue
        navBarView.rightActionBlock = { [weak self] btn in
            ADPhotoKitUI.config.canceled?()
            if let _ = self?.navigationController?.popViewController(animated: true) {
            }else{
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        view.addSubview(navBarView)
        navBarView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navBarView.height)
        }
        
        tableView.contentInset = UIEdgeInsets(top: navBarView.height, left: 0, bottom: tabBarOffset, right: 0)
        
        dataSource = ADAlbumListDataSource(reloadable: tableView, options: config.albumOpts)
    }
    
}

extension ADAlbumListController: UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ADPhotoUIConfigurable.albumListCell(tableView: tableView, indexPath: indexPath)
        
        cell.style = .normal
        cell.configure(with: dataSource.list[indexPath.row])
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushThumbnail(with: dataSource.list[indexPath.row], style: .normal, animated: true)
    }
    
}
