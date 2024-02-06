//
//  ADAlbumListView.swift
//  ADPhotoKit
//
//  Created by du on 2024/2/1.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct ADAlbumListControllerWrapped: UIViewControllerRepresentable {
    let style: ADPickerStyle
    let configuration: ADPhotoKitConfig
    let models: [ADSelectAssetModel]
    
    func makeUIViewController(context: Context) -> ADPhotoNavController {
        if style == .normal {
            let album = ADAlbumListController(config: configuration, selects: models)
            let nav = ADPhotoNavController(rootViewController: album)
            ADPhotoManager.cameraRollAlbum(options: configuration.albumOpts) { (model) in
                album.pushThumbnail(with: model, style: style, animated: false)
            }
            nav.modalPresentationStyle = .fullScreen
            return nav
        }else{
            let nav = ADPhotoNavController()
            ADPhotoManager.cameraRollAlbum(options: configuration.albumOpts) { (model) in
                let thumbnail = ADThumbnailViewController(config: configuration, album: model, style: style, selects: models)
                nav.setViewControllers([thumbnail], animated: false)
            }
            nav.modalPresentationStyle = .fullScreen
            return nav
        }
    }
    
    func updateUIViewController(_ uiViewController: ADPhotoNavController, context: Context) {
        
    }
    
    typealias UIViewControllerType = ADPhotoNavController
    
}

@available(iOS 13.0.0, *)
struct ADAlbumListSwiftUIView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let style: ADPickerStyle
    let configuration: ADPhotoKitConfig
    let models: [ADSelectAssetModel]
    
    var body: some View {
        ADAlbumListControllerWrapped(style: style, configuration: configuration, models: models)
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .preferredColorScheme(.light)
    }
}
