//
//  ADPhotoUIConfigurable.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/20.
//

import Foundation

public protocol ADAlbumListConfigurable {
    
    var identifier: String? { set get }
    
    var albumModel: ADAlbumModel! { set get }
    
    func configure(with model: ADAlbumModel)
    
}
