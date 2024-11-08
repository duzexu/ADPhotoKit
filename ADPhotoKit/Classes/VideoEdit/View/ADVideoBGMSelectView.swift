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
    var searchMusic: ((String) -> Void)?
    
    private var contentView: ADVideoBGMContentView!
    private var bottomView: ADVideoBGMBottomView!
    private var searchView: ADVideoBGMSearchView?
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
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(searchAction))
        contentView.searchBar.addGestureRecognizer(tapGes)
        
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
        if searchView != nil {
            if wrapper.bgm != nil && items.contains(where: { item in
                return item.id == wrapper.bgm!.id
            }) {
                searchView!.tableView.reload(items: items, selected: wrapper.bgm)
            }else{
                searchView!.tableView.reload(items: items, selected: nil)
            }
        }else{
            contentView.tableView.reload(items: items, selected: wrapper.bgm)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func searchAction() {
        let view = ADVideoBGMSearchView()
        view.searchMusic = searchMusic
        view.tableView.didSelectRow = { [weak self] index, item in
            self?.wrapper.bgm = item
            self?.contentView.tableView.selectItem(item)
        }
        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        searchView = view
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
    let searchBar = SearchBar()
    
    init() {
        super.init(frame: .zero)
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

class ADVideoBGMSearchView: UIView, UITextFieldDelegate {
    
    var tableView: ADVideoBGMTableView!
    var searchMusic: ((String) -> Void)?
    
    private var inputField: UITextField!
    private var clearBtn: UIButton!
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        let searchBar = UIView()
        searchBar.backgroundColor = UIColor(hex: 0xededed)
        searchBar.layer.cornerRadius = 4
        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-67)
            make.height.equalTo(36)
            make.top.equalToSuperview().offset(10)
        }
        let icon = UIImageView(image: Bundle.image(name: "icons_bgm_search", module: .videoEdit))
        searchBar.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.centerY.equalToSuperview()
        }
        inputField = UITextField()
        inputField.tintColor = UIColor(hex: 0x07c160)
        inputField.delegate = self
        inputField.placeholder = "搜索歌名/歌手/歌词/情绪"
        inputField.font = UIFont.systemFont(ofSize: 17)
        inputField.textColor = UIColor.black.withAlphaComponent(0.9)
        searchBar.addSubview(inputField)
        inputField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(36)
            make.right.equalToSuperview().offset(-39)
            make.height.equalTo(22)
            make.centerY.equalToSuperview()
        }
        clearBtn = UIButton(type: .custom)
        clearBtn.isHidden = true
        clearBtn.setImage(Bundle.image(name: "icons_search_clear", module: .videoEdit), for: .normal)
        clearBtn.addTarget(self, action: #selector(clearSearchAction(_:)), for: .touchUpInside)
        searchBar.addSubview(clearBtn)
        clearBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 19, height: 22))
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle(ADLocale.LocaleKey.cancel.localeTextValue, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelBtn.setTitleColor(UIColor(hex: 0x576b95), for: .normal)
        cancelBtn.addTarget(self, action: #selector(removeFromSuperview), for: .touchUpInside)
        addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 35, height: 36))
        }
        tableView = ADVideoBGMTableView()
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(56)
        }
        inputField.becomeFirstResponder()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        clearBtn.isHidden = textField.text == nil || textField.text!.isEmpty
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if textField.markedTextRange == nil {
            self.perform(#selector(searchWithText(_:)), with: textField.text, afterDelay: 0.8)
        }
    }
    
    @objc func clearSearchAction(_ sender: UIButton) {
        sender.isHidden = true
        inputField.text = ""
        searchMusic?("")
    }
    
    @objc func searchWithText(_ text: String?) {
        searchMusic?(text ?? "")
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
