//
//  ADImageEditControlsView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import UIKit

class ADImageEditControlsView: UIView {
    
    weak var vc: UIViewController?
    
    private let tools: [ImageEditTool]
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
            }
        }
    }
    
    private var topShadow: CAGradientLayer!
    private var bottomShadow: CAGradientLayer!
    private var toolConfigContainer: UIView!
    private var toolsCollectionView: UICollectionView!

    init(vc: UIViewController, tools: [ImageEditTool]) {
        self.vc = vc
        self.tools = tools
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topShadow.frame = CGRect(x: 0, y: 0, width: frame.width, height: 150)
        bottomShadow.frame = CGRect(x: 0, y: frame.height-140-tabBarOffset, width: frame.width, height: 140+tabBarOffset)
    }
    
}

private extension ADImageEditControlsView {
    
    func setupUI() {
        let color1 = UIColor.black.withAlphaComponent(0.35).cgColor
        let color2 = UIColor.black.withAlphaComponent(0).cgColor
        
        topShadow = CAGradientLayer()
        topShadow.colors = [color1, color2]
        topShadow.locations = [0, 1]
        layer.addSublayer(topShadow)
        
        bottomShadow = CAGradientLayer()
        bottomShadow.colors = [color2, color1]
        bottomShadow.locations = [0, 1]
        layer.addSublayer(bottomShadow)
        
        toolConfigContainer = UIView()
        addSubview(toolConfigContainer)
        toolConfigContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let leftBtnItem = UIButton(type: .custom)
        leftBtnItem.contentHorizontalAlignment = .left
        leftBtnItem.setImage(Bundle.image(name: "retake", module: .imageEdit), for: .normal)
        leftBtnItem.addTarget(self, action: #selector(leftBtnItemAction(sender:)), for: .touchUpInside)
        addSubview(leftBtnItem)
        leftBtnItem.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(statusBarHeight)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(60)
        }
        
        let confirmBtn = UIButton(type: .custom)
        confirmBtn.setTitle(ADLocale.LocaleKey.done.localeTextValue, for: .normal)
        confirmBtn.setBackgroundImage(UIImage.image(color: UIColor(hex: 0x50A938)!), for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        confirmBtn.layer.cornerRadius = 5
        confirmBtn.layer.masksToBounds = true
        confirmBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        confirmBtn.addTarget(self, action: #selector(confirmBtnAction(sender:)), for: .touchUpInside)
        confirmBtn.setContentHuggingPriority(.required, for: .horizontal)
        confirmBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-tabBarOffset-20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(34)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        toolsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        toolsCollectionView.backgroundColor = .clear
        toolsCollectionView.delegate = self
        toolsCollectionView.dataSource = self
        toolsCollectionView.showsHorizontalScrollIndicator = false
        addSubview(toolsCollectionView)
        toolsCollectionView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-tabBarOffset-20)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(confirmBtn.snp.left).offset(-20)
            make.height.equalTo(30)
        }
        toolsCollectionView.regisiter(cell: ADEditToolCell.self)
    }
    
}

extension ADImageEditControlsView {
    @objc
    func leftBtnItemAction(sender: UIButton) {
        vc?.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func confirmBtnAction(sender: UIButton) {
        
    }
}

extension ADImageEditControlsView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tools.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ADEditToolCell.reuseIdentifier, for: indexPath) as! ADEditToolCell
        
        let tool = tools[indexPath.row]
        cell.configure(with: tool)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tool = tools[indexPath.row]
        if tool.toolDidSelect(ctx: vc) {
            selectToolIndex = indexPath.row
        }
    }
}
