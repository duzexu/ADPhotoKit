//
//  ADAssetBrowserSwiftUIView.swift
//  ADPhotoKit
//
//  Created by du on 2024/2/4.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct ADAssetBrowserControllerWrapped: UIViewControllerRepresentable {
    let configuration: ADPhotoKitConfig
    let assets:  [ADAssetBrowsable]
    let selects: [ADAssetBrowsable]
    let index: Int?
    
    func makeUIViewController(context: Context) -> ADPhotoNavController {
        let browser = ADAssetBrowserController(config: configuration, assets: assets, selects: selects, index: index)
        let nav = ADPhotoNavController(rootViewController: browser)
        return nav
    }
    
    func updateUIViewController(_ uiViewController: ADPhotoNavController, context: Context) {
        
    }
    
    typealias UIViewControllerType = ADPhotoNavController
    
}

@available(iOS 13.0.0, *)
struct ADAssetBrowserSwiftUIView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let configuration: ADPhotoKitConfig
    let assets:  [ADAssetBrowsable]
    let selects: [ADAssetBrowsable]
    let index: Int?
    
    var body: some View {
        ADAssetBrowserControllerWrapped(configuration: configuration, assets: assets, selects: selects, index: index)
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .preferredColorScheme(.light)
    }
}
