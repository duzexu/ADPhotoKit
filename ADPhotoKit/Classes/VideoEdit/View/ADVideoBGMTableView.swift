//
//  ADVideoBGMTableView.swift
//  ADPhotoKit
//
//  Created by du on 2024/10/12.
//

import UIKit

class ADVideoBGMTableView: UIView {
    
    var didSelectRow: ((Int,ADMusicItem) -> Void)?
    var musicItems: [ADMusicItem] = []
    
    private var tableView: UITableView!
    private var footerView: FooterView!
    private var emptyLabel: UILabel!
    
    init() {
        super.init(frame: .zero)
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.regisiter(cell: ADVideoBGMCell.self)
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        footerView = FooterView()
        footerView.isHidden = true
        tableView.tableFooterView = footerView
        emptyLabel = UILabel()
        emptyLabel.isHidden = true
        emptyLabel.font = UIFont.systemFont(ofSize: 15)
        emptyLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        emptyLabel.text = "暂无音乐"
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(items: [ADMusicItem], selected: ADMusicItem? = nil) {
        musicItems = items
        tableView.reloadData()
        if let selected = selected {
            if let index = items.firstIndex(where: { item in
                return item.id == selected.id
            }) {
                tableView.reloadData()
                selectRow(index)
            }else{
                musicItems.insert(selected, at: 0)
                tableView.reloadData()
                selectRow(0)
            }
        }
        emptyLabel.isHidden = musicItems.count != 0
        footerView.isHidden = musicItems.count == 0
    }
    
    func selectItem(_ item: ADMusicItem) {
        if let index = musicItems.firstIndex(where: { value in
            return item.id == value.id
        }) {
            tableView.reloadData()
            selectRow(index)
        }else{
            musicItems.insert(item, at: 0)
            tableView.reloadData()
            selectRow(0)
        }
    }
    
    func cancelSelect() {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: false)
        }
    }
    
    func selectRow(_ row: Int) {
        tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
    }
    
    class FooterView: UIView {
        
        init() {
            super.init(frame: CGRect(origin: .zero, size: CGSize(width: screenWidth, height: 50)))
            let dot = UIImageView()
            dot.layer.cornerRadius = 2
            dot.backgroundColor = UIColor.black.withAlphaComponent(0.15)
            addSubview(dot)
            dot.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 4, height: 4))
                make.center.equalToSuperview()
            }
            let left = UIImageView()
            left.backgroundColor = UIColor.black.withAlphaComponent(0.15)
            addSubview(left)
            left.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 24, height: 1))
                make.right.equalTo(dot.snp.left).offset(-8)
                make.centerY.equalToSuperview()
            }
            let right = UIImageView()
            right.backgroundColor = UIColor.black.withAlphaComponent(0.15)
            addSubview(right)
            right.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 24, height: 1))
                make.left.equalTo(dot.snp.right).offset(8)
                make.centerY.equalToSuperview()
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }
    
}

extension ADVideoBGMTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ADVideoBGMCell.reuseIdentifier, for: indexPath) as! ADVideoBGMCell
        cell.configure(with: musicItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow?(indexPath.row, musicItems[indexPath.row])
    }
    
}

class ADVideoBGMCell: UITableViewCell {
    
    private var coverImageView: UIImageView!
    private var coverMaskView: UIImageView!
    private var checkImageView: UIImageView!
    private var playingView: UIImageView!
    private var titleView: UILabel!
    private var lyricsView: UILabel!
    private var gifUrl: URL!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        let path = Bundle.videoEditBundle?.bundlePath.appending("/music_playing.gif") ?? ""
        gifUrl = URL(fileURLWithPath: path)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        coverImageView = UIImageView()
        coverImageView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.size.equalTo(CGSize(width: 48, height: 48))
            make.centerY.equalToSuperview()
        }
        coverMaskView = UIImageView()
        coverMaskView.isHidden = true
        coverMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        coverImageView.addSubview(coverMaskView)
        coverMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playingView = UIImageView()
        coverMaskView.addSubview(playingView)
        playingView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.center.equalToSuperview()
        }
        titleView = UILabel()
        titleView.font = UIFont.systemFont(ofSize: 14)
        titleView.textColor = UIColor.black.withAlphaComponent(0.9)
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(84)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(18)
        }
        lyricsView = UILabel()
        lyricsView.font = UIFont.systemFont(ofSize: 14)
        lyricsView.textColor = UIColor.black.withAlphaComponent(0.3)
        contentView.addSubview(lyricsView)
        lyricsView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(84)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-18)
        }
        checkImageView = UIImageView(image: Bundle.image(name: "icons_bgm_check", module: .videoEdit))
        checkImageView.isHidden = true
        contentView.addSubview(checkImageView)
        checkImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.centerY.equalToSuperview()
        }
        let separator = UIImageView()
        separator.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(84)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(0.5)
        }
    }
    
    func configure(with item: ADMusicItem) {
        coverImageView.kf.setImage(with: item.cover)
        titleView.text = "\(item.name) - \(item.singer)"
        switch item.extra {
        case let .text(content):
            lyricsView.text = content
        case let .lyric(items):
            lyricsView.text = items.map { $0.text }.joined(separator: " ")
        case .none:
            lyricsView.text = ""
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            playingView.kf.setImage(with: gifUrl)
        }
        checkImageView.isHidden = !selected
        coverMaskView.isHidden = !selected
        lyricsView.snp.updateConstraints { make in
            make.trailing.equalToSuperview().offset(selected ? -60 : -24)
        }
        titleView.snp.updateConstraints { make in
            make.trailing.equalToSuperview().offset(selected ? -60 : -24)
        }
        layoutIfNeeded()
    }
    
}
