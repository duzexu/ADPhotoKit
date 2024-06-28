//
//  SwiftUIViewController.swift
//  ADPhotoKit_Example
//
//  Created by du on 2024/1/31.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#if canImport(SwiftUI)
import UIKit
import SwiftUI

@available(iOS 13.0, *)
class SwiftUIViewController: UIHostingController<MainSwiftUIView> {

    init(configs: Configs) {
        super.init(rootView: MainSwiftUIView(configs: configs))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SwiftUIDemo"
    }

}
#endif
