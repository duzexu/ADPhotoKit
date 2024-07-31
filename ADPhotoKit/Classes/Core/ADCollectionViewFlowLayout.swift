//
//  ADCollectionViewFlowLayout.swift
//  ADPhotoKit
//
//  Created by du on 2024/7/30.
//

import UIKit

class ADCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool { ADLocale.isRTL }
}
