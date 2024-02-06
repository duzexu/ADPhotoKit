//
//  MainSwiftUIView.swift
//  ADPhotoKit_Example
//
//  Created by du on 2024/1/31.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import ADPhotoKit
import Kingfisher
import Photos

@available(iOS 14, *)
struct MainSwiftUIView: View {
    
    let configs: Configs
    
    let browsers: [ADAssetBrowsable] = [NetImage(url: "https://cdn.pixabay.com/photo/2020/10/14/18/35/sign-post-5655110_1280.png"),NetImage(url: "https://pic.netbian.com/uploads/allimg/190518/174718-1558172838db13.jpg"),NetImage(url: "http://5b0988e595225.cdn.sohucs.com/images/20190420/1d1070881fd540db817b2a3bdd967f37.gif"),NetVideo(url: "https://freevod.nf.migu.cn/mORsHmtum1AysKe3Ry%2FUb5rA1WelPRwa%2BS7ylo4qQCjcD5a2YuwiIC7rpFwwdGcgkgMxZVi%2FVZ%2Fnxf6NkQZ75HC0xnJ5rlB8UwiH8cZUuvErkVufDlxxLUBF%2FIgUEwjiq%2F%2FV%2FoxBQBVMUzAZaWTvOE5dxUFh4V3Oa489Ec%2BPw0IhEGuR64SuKk3MOszdFg0Q/600575Y9FGZ040325.mp4?msisdn=2a257d4c-1ee0-4ad8-8081-b1650c26390a&spid=600906&sid=50816168212200&timestamp=20201026155427&encrypt=70fe12c7473e6d68075e9478df40f207&k=dc156224f8d0835e&t=1603706067279&ec=2&flag=+&FN=%E5%B0%86%E6%95%85%E4%BA%8B%E5%86%99%E6%88%90%E6%88%91%E4%BB%AC")]

    @State private var showImagePicker = false
    @State private var showImageBrowser = false
    @State private var selected: [ADAssetBrowsable] = [NetImage(url: "https://cdn.pixabay.com/photo/2020/10/14/18/35/sign-post-5655110_1280.png"),NetImage(url: "https://pic.netbian.com/uploads/allimg/190518/174718-1558172838db13.jpg"),NetImage(url: "http://5b0988e595225.cdn.sohucs.com/images/20190420/1d1070881fd540db817b2a3bdd967f37.gif"),NetVideo(url: "https://freevod.nf.migu.cn/mORsHmtum1AysKe3Ry%2FUb5rA1WelPRwa%2BS7ylo4qQCjcD5a2YuwiIC7rpFwwdGcgkgMxZVi%2FVZ%2Fnxf6NkQZ75HC0xnJ5rlB8UwiH8cZUuvErkVufDlxxLUBF%2FIgUEwjiq%2F%2FV%2FoxBQBVMUzAZaWTvOE5dxUFh4V3Oa489Ec%2BPw0IhEGuR64SuKk3MOszdFg0Q/600575Y9FGZ040325.mp4?msisdn=2a257d4c-1ee0-4ad8-8081-b1650c26390a&spid=600906&sid=50816168212200&timestamp=20201026155427&encrypt=70fe12c7473e6d68075e9478df40f207&k=dc156224f8d0835e&t=1603706067279&ec=2&flag=+&FN=%E5%B0%86%E6%95%85%E4%BA%8B%E5%86%99%E6%88%90%E6%88%91%E4%BB%AC")]
    
    var body: some View {
        VStack {
            HStack(spacing: 20, content: {
                Button("PickerImage") {
                    showImagePicker.toggle()
                }
                Button("BrowserImage") {
                    showImageBrowser.toggle()
                }
            })
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
            Spacer()
        }
        .navigationTitle(Text("SwiftUIDemo"))
        .imagePicker(isPresented: $showImagePicker,
                     style: configs.pickerStyle,
                     modelsSel: [],
                     albumOpts: configs.albumOptions,
                     assetOpts: configs.assetOptions,
                     browserOpts: configs.browserOptions,
                     params: configs.params,
                     selected: { (assets, value) in
                        selected = assets.map { $0.asset as ADAssetBrowsable }
                        selected.append(contentsOf: browsers)
                        print(selected)
                    },
                    canceled: {
                        print("cancel")
                    })
        .assetBrowser(isPresented: $showImageBrowser, assets: selected, selected: { select in
            print(select)
        })
    }
    
    func ss() {
        let scene = UIApplication.shared.connectedScenes.first
        let root = (scene as? UIWindowScene)?.windows.first?.rootViewController
        if root != nil {
            ADPhotoKitUI.imagePicker(present: root!) { _, _ in
                
            }
        }
    }
}

@available(iOS 14, *)
#Preview {
    MainSwiftUIView(configs: Configs())
}
