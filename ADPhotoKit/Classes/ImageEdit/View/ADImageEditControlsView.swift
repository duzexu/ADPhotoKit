//
//  ADImageEditControlsView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit

class ADImageEditControlsView: ADEditControlsView {
    
    var contentStatus: ((Bool) -> Void)?
    
    private var selectToolIndex: Int? {
        didSet {
            if let new = selectToolIndex {
                if let old = oldValue, old != new {
                    tools[old].isSelected = false
                    tools[old].toolConfigView?.removeFromSuperview()
                    tools[new].isSelected = true
                }else{
                    tools[new].isSelected = true
                }
                if let config = tools[new].toolConfigView {
                    toolConfigContainer.addSubview(config)
                    config.snp.remakeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                }
                toolsCollectionView.reloadData()
            }else{
                if let old = oldValue {
                    tools[old].isSelected = false
                    tools[old].toolConfigView?.removeFromSuperview()
                }
                toolsCollectionView.reloadData()
            }
        }
    }
    
    private var undoBtn: UIButton!
    private var redoBtn: UIButton!

    init(vc: UIViewController, tools: [ADImageEditTool]) {
        super.init(vc: vc, tools: tools)
        
        for item in tools {
            item.contentLockStatus = { [weak self] lock in
                self?.contentStatus?(lock)
            }
        }
        
        setupUI()
        ADUndoManager.shared.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ADImageEditControlsView {
    
    func setupUI() {
        redoBtn = UIButton(type: .custom)
        redoBtn.adjustsImageWhenHighlighted = false
        redoBtn.setImage(Bundle.image(name: "icons_redo", module: .imageEdit)?.adaptRTL(), for: .normal)
        redoBtn.setImage(Bundle.image(name: "icons_redo_disable", module: .imageEdit)?.adaptRTL(), for: .disabled)
        redoBtn.addTarget(self, action: #selector(redoBtnAction(_:)), for: .touchUpInside)
        addSubview(redoBtn)
        redoBtn.snp.makeConstraints { (make) in
            let top = isPhoneXOrLater ? statusBarHeight : 0
            make.top.equalToSuperview().offset(top)
            make.trailing.equalToSuperview().offset(-8)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        userInteractionBtns.append(redoBtn)
        
        undoBtn = UIButton(type: .custom)
        undoBtn.adjustsImageWhenHighlighted = false
        undoBtn.setImage(Bundle.image(name: "icons_undo", module: .imageEdit)?.adaptRTL(), for: .normal)
        undoBtn.setImage(Bundle.image(name: "icons_undo_disable", module: .imageEdit)?.adaptRTL(), for: .disabled)
        undoBtn.addTarget(self, action: #selector(undoBtnAction(_:)), for: .touchUpInside)
        addSubview(undoBtn)
        undoBtn.snp.makeConstraints { (make) in
            let top = isPhoneXOrLater ? statusBarHeight : 0
            make.top.equalToSuperview().offset(top)
            make.trailing.equalTo(redoBtn.snp.leading)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        userInteractionBtns.append(undoBtn)
    }
    
}

extension ADImageEditControlsView {
    @objc
    func undoBtnAction(_ sender: UIButton) {
        ADUndoManager.shared.undo()
    }
    
    @objc
    func redoBtnAction(_ sender: UIButton) {
        ADUndoManager.shared.redo()
    }
}

extension ADImageEditControlsView: ADUndoManagerDelegate {
    
    func update(canUndo: Bool, canRedo: Bool) {
        undoBtn.isEnabled = canUndo
        redoBtn.isEnabled = canRedo
    }
    
}
