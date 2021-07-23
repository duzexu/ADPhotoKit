//
//  VideoBrowserCell.swift
//  ADPhotoKit_Example
//
//  Created by xu on 2021/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AVKit
import ADPhotoKit
import Photos

class VideoBrowserCell: UICollectionViewCell, ADVideoBrowserCellConfigurable {
    
    var editData: ADAssetEditData? {
        return nil
    }
    
    func configure(with source: ADVideoSource) {
        switch source {
        case let .network(url):
            imageView.isHidden = true
            configWithPlayItem(AVPlayerItem(url: url))
        case let .album(asset):
            imageView.setAsset(asset, size: asset.browserSize, placeholder: nil, completionHandler:  { [weak self] (img) in
                self?.loadVideoData(asset: asset)
            })
        case let .local(url):
            imageView.isHidden = true
            configWithPlayItem(AVPlayerItem(url: url))
        }
    }
    
    var singleTapBlock: (() -> Void)?
    
    func cellWillDisplay() {
        playerVC.player?.play()
    }
    
    func cellDidEndDisplay() {
        playerVC.player?.pause()
    }
    
    func transationBegin() -> (UIView, CGRect) {
        let v = UIView(frame: UIScreen.main.bounds)
        v.addSubview(playerVC.view)
        playerVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return (v,UIScreen.main.bounds)
    }
    
    func transationCancel(view: UIView) {
        let pv = view.subviews[0]
        contentView.addSubview(pv)
        pv.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    var playerVC: AVPlayerViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playerVC = AVPlayerViewController()
        contentView.addSubview(playerVC.view)
        playerVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func configWithPlayItem(_ item: AVPlayerItem) {
        playerVC.player = AVPlayer(playerItem: item)
        playerVC.player?.play()
    }
    
    private var requestID: PHImageRequestID?
    
    func loadVideoData(asset: PHAsset) {
        requestID = ADPhotoManager.fetch(for: asset, type: .video, progress: { (progress, _, _, _) in
            
        },completion: { [weak self] (item, info, _) in
            if let play = item as? AVPlayerItem {
                self?.configWithPlayItem(play)
            }
        })
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
}
