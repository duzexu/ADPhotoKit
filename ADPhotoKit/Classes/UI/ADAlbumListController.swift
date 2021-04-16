//
//  ADAlbumListController.swift
//  ADPhotoKit
//
//  Created by xu on 2021/3/19.
//

import UIKit
import SnapKit

class ADAlbumListController: UIViewController {
    
    let model: ADPhotoKitConfig
    
    var tableView: UITableView!
    var dataSource: ADAlbumListDataSource!
    
    init(model: ADPhotoKitConfig) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if dataSource.list.count == 0 {
            dataSource.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        tableView.contentInset = UIEdgeInsets(top: topBarHeight, left: 0, bottom: tabBarOffset, right: 0)
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
        
        let navBarView = ADThumbnailNavBarView()
        navBarView.title = ADLocale.LocaleKey.photo.localeTextValue
        navBarView.leftActionBlock = { [weak self] btn in
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
        
        dataSource = ADAlbumListDataSource(reloadable: tableView, options: model.albumOpts)
    }
    
}

extension ADAlbumListController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ADAlbumListCell.reuseIdentifier, for: indexPath) as! ADAlbumListCell

        cell.configure(with: dataSource.list[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thumbnail = ADThumbnailViewController(model: model, albumList: dataSource.list[indexPath.row])
        navigationController?.pushViewController(thumbnail, animated: true)
    }
    
}
