//
//  MainSwiftUIView.swift
//  ADPhotoKit_Example
//
//  Created by du on 2024/1/31.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
import ADPhotoKit
import Kingfisher
import Photos

@available(iOS 13, *)
struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
         configuration.label
            .padding(8) 
            .background(Color.blue)
            .cornerRadius(10)
            .foregroundColor(.white)
            .font(.callout)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
        }
}

@available(iOS 13, *)
struct MainSwiftUIView: View {
    
    let configs: Configs

    @State private var showImagePicker = false
    @State private var showImageBrowser = false
    @State private var showSelected = false
    @State private var selected: [ADAssetBrowsable] = []
    @State private var keepSelected = false
    
    var body: some View {
        ScrollView {
            VStack {
                HStack(spacing: 8, content: {
                    Button("PickerImage") {
                        showImagePicker.toggle()
                    }.buttonStyle(RoundedButtonStyle())
                    Button("BrowserImage") {
                        showImageBrowser.toggle()
                    }
                    Button("BrowserSelect") {
                        showSelected.toggle()
                    }
                })
                HStack(spacing: 50, content: {
                    Toggle("KeepSelected", isOn: $keepSelected)
                    Button("PickerImage Old") {
                        imagePickerAction()
                    }
                }).font(.callout).padding([.leading,.trailing],16)
                let select_count = selected.count
                if select_count > 0 {
                    GeometryReader(content: { geometry in
                        let count: Int = select_count > 4 ? 3 : 2
                        let row: Int = select_count % count == 0 ? select_count/count : select_count/count + 1
                        VStack(alignment: .leading, spacing: 10, content: {
                            Text("Selected Images")
                            ForEach(0..<row, id: \.self) { r in
                                HStack(spacing: 10, content: {
                                    ForEach(0..<count, id: \.self) { c in
                                        let index = r * count + c
                                        if index < select_count {
                                            let s: ADAssetBrowsable = selected[index]
                                            KFImage.dataProvider(ADAssetImageDataProvider(asset: s.browseAsset, size: CGSizeMake((geometry.size.width-32-20)/CGFloat(count), (geometry.size.width-32-20)/CGFloat(count))))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: (geometry.size.width-32-20)/CGFloat(count), height:(geometry.size.width-32-20)/CGFloat(count))
                                                .clipped()
                                        }
                                    }
                                }).frame(height: (geometry.size.width-32-20)/CGFloat(count))
                            }
                        }).padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    })
                }
            }.buttonStyle(RoundedButtonStyle())
        }
        .imagePicker(isPresented: $showImagePicker,
                     style: configs.pickerStyle,
                     modelsSel: keepSelected ? selected.compactMap({ asset in
            if let asset = asset as? PHAsset {
                let model = ADSelectAssetModel(asset: asset)
                #if Module_ImageEdit
                model.imageEditInfo = asset.imageEditInfo
                #endif
                #if Module_VideoEdit
                asset.videoEditInfo = asset.videoEditInfo
                #endif
                return model
            }
            return nil
        }) : [],
                     albumOpts: configs.albumOptions,
                     assetOpts: configs.assetOptions,
                     browserOpts: configs.browserOptions,
                     params: configs.params,
                     selected: { (assets, value) in
            selected = assets.map({ asset,result,err in
                #if Module_ImageEdit
                asset.imageEditInfo = result?.imageEditInfo
                #endif
                #if Module_VideoEdit
                asset.videoEditInfo = result?.videoEditInfo
                #endif
                return asset
            })
            print(assets)
        },
        canceled: {
            print("cancel")
        })
        .assetBrowser(isPresented: $showImageBrowser, 
                      assets: DemosViewController.browsers,
                      selects: keepSelected ? selected : [],
                      options: configs.browserOptions,
                      selected: { select in
            selected = select
            print(select)
        }, canceled: {
            print("cancel")
        })
        .assetBrowser(isPresented: $showSelected, assets: selected, selected: { select in
            selected = select
            print(select)
        }, canceled: {
            print("cancel")
        })
    }
    
    func imagePickerAction() {
        let scene = UIApplication.shared.connectedScenes.first
        let root = (scene as? UIWindowScene)?.windows.first?.rootViewController
        if root != nil {
            let s: [ADSelectAssetModel] = keepSelected ? selected.compactMap({ asset in
                if let asset = asset as? PHAsset {
                    let model = ADSelectAssetModel(asset: asset)
                    #if Module_ImageEdit
                    model.imageEditInfo = asset.imageEditInfo
                    #endif
                    #if Module_VideoEdit
                    model.videoEditInfo = asset.videoEditInfo
                    #endif
                    return model
                }
                return nil
            }) : []
            ADPhotoKitUI.imagePicker(present: root!,
                                     style: configs.pickerStyle,
                                     modelsSel: s,
                                     albumOpts: configs.albumOptions,
                                     assetOpts: configs.assetOptions,
                                     browserOpts: configs.browserOptions,
                                     params: configs.params,
                                     selected: { (assets, value) in
                selected = assets.map({ asset,result,err in
                    #if Module_ImageEdit
                    asset.imageEditInfo = result?.imageEditInfo
                    #endif
                    #if Module_VideoEdit
                    asset.videoEditInfo = result?.videoEditInfo
                    #endif
                    return asset
                })
                print(assets)
            },
                                     canceled: {
                print("cancel")
            })
        }
    }
}

//@available(iOS 13, *)
//#Preview {
//    MainSwiftUIView(configs: Configs())
//}
#endif
