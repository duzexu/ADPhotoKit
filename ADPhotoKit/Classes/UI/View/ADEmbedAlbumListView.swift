//
//  ADEmbedAlbumListView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/19.
//

import UIKit

class ADEmbedAlbumListView: UIView {
    
    var selectAlbumBlock: ((ADAlbumModel?)->Void)?
    
    let config: ADPhotoKitConfig
    
    var tableBgView: UIView!
    var tableBgMask: CAShapeLayer!
    var tableView: UITableView!
    var dataSource: ADAlbumListDataSource!

    init(config: ADPhotoKitConfig) {
        self.config = config
        super.init(frame: .zero)
        isHidden = true
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect: tableBgView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 8, height: 8))
        tableBgMask.path = path.cgPath
    }
    
    func show(reload: Bool) {
        
        func internalShow() {
            var height: CGFloat = CGFloat(dataSource.list.count * 60)
            if UIApplication.shared.statusBarOrientation.isPortrait {
                height = min((screenHeight-topBarHeight) * 0.7, height)
            }else{
                height = min((screenHeight-topBarHeight) * 0.8, height)
            }
            for item in tableBgView.constraints {
                if item.identifier == "tableBgViewHeight" {
                    item.constant = height
                }
            }
            isHidden = false
            alpha = 0
            tableBgView.transform = CGAffineTransform(translationX: 0, y: -tableBgView.frame.height)
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1
                self.tableBgView.transform = .identity
            }
        }
        
        if reload {
            dataSource.reloadData { [weak self] in
                self?.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
                internalShow()
            }
        }else{
            internalShow()
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
            self.tableBgView.transform = CGAffineTransform(translationX: 0, y: -self.tableBgView.frame.height)
        } completion: { (_) in
            self.alpha = 1
            self.isHidden = true
        }
    }
}

private extension ADEmbedAlbumListView {
    
    func setupUI() {
        clipsToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
        
        tableBgMask = CAShapeLayer()
        tableBgView = UIView()
        tableBgView.layer.mask = tableBgMask
        addSubview(tableBgView)
        tableBgView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60*6).labeled("tableBgViewHeight")
        }
        
        tableView = UITableView(frame: .zero)
        tableView.backgroundColor = UIColor(hex: 0x2D2D2D)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(hex: 0x3C3C3C)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableBgView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tableView.regisiter(cell: ADAlbumListCell.self)
        
        ADPhotoKitConfiguration.default.customAlbumListCellRegistor?(tableView)
        
        dataSource = ADAlbumListDataSource(reloadable: tableView, options: config.albumOpts)
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        hide()
        selectAlbumBlock?(nil)
    }
    
}

extension ADEmbedAlbumListView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        return !tableBgView.frame.contains(point)
    }
    
}


extension ADEmbedAlbumListView: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ADPhotoUIConfigurable.albumListCell(tableView: tableView, indexPath: indexPath)
        
        cell.style = .embed
        cell.configure(with: dataSource.list[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hide()
        selectAlbumBlock?(dataSource.list[indexPath.row])
    }
    
}
