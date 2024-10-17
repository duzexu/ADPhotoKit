//
//  ADVideoBGMSelectView.swift
//  ADPhotoKit
//
//  Created by du on 2024/10/11.
//

import UIKit

class ADVideoSoundWrapped {
    var lyricOn: Bool {
        didSet {
            sound.lyricOn = lyricOn
            change()
        }
    }
    var ostOn: Bool {
        didSet {
            sound.ostOn = ostOn
            change()
        }
    }
    var bgm: ADMusicItem? {
        didSet {
            if bgm == nil {
                lyricOn = false
            }
            sound.bgm = bgm
            change()
        }
    }
    
    let sound: ADVideoSound
    let change: (() -> Void)
    
    init(sound: ADVideoSound, change: @escaping (() -> Void)) {
        self.sound = sound
        self.lyricOn = sound.lyricOn
        self.ostOn = sound.ostOn
        self.bgm = sound.bgm
        self.change = change
    }
}

class ADVideoBGMSelectView: UIView {
    
    var wrapper: ADVideoSoundWrapped!
    
    private var contentView: ADVideoBGMContentView!
    private var bottomView: ADVideoBGMBottomView!
    private var selectIndex: Int = 0

    init(sound: ADVideoSound, change: @escaping (() -> Void)) {
        super.init(frame: .zero)
        wrapper = ADVideoSoundWrapped(sound: sound, change: { [weak self] in
            change()
            self?.bottomView.reloadBtn()
        })
        contentView = ADVideoBGMContentView()
        contentView.tableView.didSelectRow = { [weak self] index,_ in
            self?.selectIndex = index
            self?.music(isOn: true)
        }
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-64)
        }
        
        bottomView = ADVideoBGMBottomView(wrapper: wrapper)
        bottomView.musicSwitch = { [weak self] isOn in
            self?.music(isOn: isOn)
        }
        addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(64)
        }
    }
    
    func reload(items: [ADMusicItem]) {
        contentView.tableView.reload(items: items, selected: wrapper.bgm)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func music(isOn: Bool) {
        if isOn {
            if selectIndex < contentView.tableView.musicItems.count {
                wrapper.bgm = contentView.tableView.musicItems[selectIndex]
                contentView.tableView.selectRow(selectIndex)
            }
        }else{
            wrapper.bgm = nil
            contentView.tableView.cancelSelect()
        }
    }
    
}

class ADVideoBGMContentView: UIView {
    
    var tableView: ADVideoBGMTableView!
    
    init() {
        super.init(frame: .zero)
        let searchBar = SearchBar()
        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(36)
            make.top.equalToSuperview().offset(10)
        }
        tableView = ADVideoBGMTableView()
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(56)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class SearchBar: UIView {
        
        init() {
            super.init(frame: .zero)
            backgroundColor = UIColor(hex: 0xededed)
            layer.cornerRadius = 4
            let view = UIView()
            addSubview(view)
            view.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.equalTo(36)
            }
            let icon = UIImageView(image: Bundle.image(name: "icons_bgm_search", module: .videoEdit))
            view.addSubview(icon)
            icon.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            let label = UILabel()
            label.text = "搜索歌名/歌手/歌词/情绪"
            label.font = UIFont.systemFont(ofSize: 17)
            label.textColor = UIColor.black.withAlphaComponent(0.3)
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(icon.snp.right).offset(12)
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }
    
}

class ADVideoBGMBottomView: UIView {
    
    let wrapper: ADVideoSoundWrapped
    var musicSwitch: ((Bool) -> Void)?
    
    private var musicOnBtn: UIButton!
    private var ostOnBtn: UIButton!
    private var lyricOnBtn: UIButton!
    
    init(wrapper: ADVideoSoundWrapped) {
        self.wrapper = wrapper
        super.init(frame: .zero)
        musicOnBtn = createBtn(title: "配乐", action: #selector(musicOnAction(_:)))
        addSubview(musicOnBtn)
        musicOnBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(16)
        }
        ostOnBtn = createBtn(title: "视频原声", action: #selector(ostOnAction(_:)))
        addSubview(ostOnBtn)
        ostOnBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(16)
        }
        lyricOnBtn = createBtn(title: "歌词", action: #selector(lyricOnAction(_:)))
        addSubview(lyricOnBtn)
        lyricOnBtn.snp.makeConstraints { make in
            make.leading.equalTo(musicOnBtn.snp.trailing).offset(24)
            make.top.equalToSuperview().offset(16)
        }
        let separator = UIImageView()
        separator.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        reloadBtn()
    }
    
    func reloadBtn() {
        musicOnBtn.isSelected = wrapper.bgm != nil
        ostOnBtn.isSelected = wrapper.ostOn
        lyricOnBtn.isSelected = wrapper.lyricOn
        lyricOnBtn.isEnabled = wrapper.bgm != nil
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func musicOnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        musicSwitch?(sender.isSelected)
    }
    
    @objc
    func ostOnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        wrapper.ostOn = sender.isSelected
    }
    
    @objc
    func lyricOnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        wrapper.lyricOn = sender.isSelected
    }
    
    func createBtn(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.black.withAlphaComponent(0.9), for: .normal)
        btn.setTitleColor(UIColor(hex: 0x7f7f7f), for: .disabled)
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.setImage(Bundle.image(name: "icons_unselected", module: .videoEdit), for: .normal)
        btn.setImage(Bundle.image(name: "icons_selected", module: .videoEdit), for: .selected)
        if ADLocale.isRTL {
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        } else {
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        }
        return btn
    }
    
}
