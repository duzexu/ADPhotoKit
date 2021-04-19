//
//  ADEmbedAlbumListView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/19.
//

import UIKit

class ADEmbedAlbumListView: UIView {
    
    var tableBgView: UIView!
    var tableView: UITableView!
    var dataSource: ADAlbumListDataSource!

    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ADEmbedAlbumListView {
    func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        tableBgView = UIView()
        addSubview(tableBgView)
        tableBgView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        
    }
}
