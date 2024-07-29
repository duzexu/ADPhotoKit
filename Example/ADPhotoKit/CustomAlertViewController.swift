//
//  CustomAlertViewController.swift
//  ADPhotoKit_Example
//
//  Created by du on 2024/7/25.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import ADPhotoKit

class CustomAlertViewController: UIViewController {

    private let alert: String?
    private let message: String
    private let actions: [ADAlertAction]
    private let callBack: ((Int) -> Void)?
    
    init(alert: String?, message: String, actions: [ADAlertAction], callBack:((Int) -> Void)?) {
        self.alert = alert
        self.message = message
        self.actions = actions
        self.callBack = callBack
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let container = UIView()
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        container.backgroundColor = .white
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.8)
        }
        
        var titleL: UILabel?
        if let alert = alert, alert.isEmpty {
            let titleLabel = UILabel()
            titleL = titleLabel
            titleLabel.text = alert
            titleLabel.textColor = UIColor.darkText
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0
            titleLabel.lineBreakMode = .byCharWrapping
            container.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(container.snp.top).offset(28)
                make.left.equalToSuperview().offset(25)
                make.right.equalToSuperview().offset(-25)
            }
        }
        
        let msgLabel = UILabel()
        msgLabel.textAlignment = .center
        msgLabel.numberOfLines = 0
        msgLabel.lineBreakMode = .byCharWrapping
        msgLabel.text = message
        msgLabel.font = UIFont.systemFont(ofSize: 16)
        msgLabel.textColor = UIColor.darkText
        container.addSubview(msgLabel)
        msgLabel.snp.makeConstraints { make in
            if let label = titleL {
                make.top.equalTo(label.snp.bottom).offset(16)
            } else {
                make.top.equalTo(container.snp.top).offset(28)
            }
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        let separator = UIView()
        separator.backgroundColor = .darkGray
        container.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(msgLabel.snp.bottom).offset(28)
            make.left.right.equalToSuperview()
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        
        let actionsView = UIStackView()
        actionsView.distribution = .fillEqually
        actionsView.alignment = .fill
        actionsView.spacing = 1 / UIScreen.main.scale
        actionsView.axis = .horizontal
        container.addSubview(actionsView)
        actionsView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        for (index, item) in actions.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = index
            btn.backgroundColor = .white
            btn.setTitle(item.title, for: .normal)
            btn.setTitleColor(item.color, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            btn.addTarget(self, action: #selector(btnClickAction(_:)), for: .touchUpInside)
            actionsView.addArrangedSubview(btn)
        }
    }
    
    @objc 
    private func btnClickAction(_ btn: UIButton) {
        callBack?(btn.tag)
        dismiss(animated: false)
    }
}

extension ADAlertAction {
    var color: UIColor {
        switch self {
        case .default(_):
            return UIColor.systemBlue
        case .cancel(_):
            return UIColor.systemGray
        case .destructive(_):
            return UIColor.systemRed
        }
    }
}

extension CustomAlertViewController: ADAlertConfigurable {
    static func alert(on: UIViewController, title: String?, message: String, actions: [ADAlertAction], completion: ((Int) -> Void)?) {
        let alert = CustomAlertViewController(alert: title, message: message, actions: actions, callBack: completion)
        on.present(alert, animated: false, completion: nil)
    }
}
