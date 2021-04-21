//
//  ADAlbumListNavBarView.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/19.
//

import UIKit

class ADAlbumListNavBarView: ADBaseNavBarView, ADAlbumListNavBarConfigurable {

    init() {
        super.init(leftItem: nil, rightItem: (nil,nil,ADLocale.LocaleKey.cancel.localeTextValue))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
