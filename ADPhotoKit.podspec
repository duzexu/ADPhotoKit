#
# Be sure to run `pod lib lint ADPhotoKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ADPhotoKit'
  s.version          = '1.0.0'
  s.summary          = 'A library for select photos from album implemented by pure-Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  ADPhotoKit is a pure-Swift library to select assets (e.g. photo,video,gif,livephoto) from system album.
                       DESC

  s.homepage         = 'https://github.com/duzexu/ADPhotoKit.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'duzexu' => 'zexu007@qq.com' }
  s.source           = { :git => 'https://github.com/duzexu/ADPhotoKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.1'
  s.requires_arc          = true
  s.frameworks            = 'UIKit','Photos','PhotosUI','AVFoundation'
  s.default_subspec = 'CoreUI'
  
  s.subspec "Base" do |b|
    b.source_files  = ["ADPhotoKit/Classes/Base/**/*.swift"]
    b.resource_bundles = {
      'ADPhotoKitBase' => ['ADPhotoKit/Assets/Base/**/*']
    }
  end
  
  s.subspec "Core" do |c|
    c.dependency 'ADPhotoKit/Base'
    c.source_files  = ["ADPhotoKit/Classes/Core/**/*.swift"]
  end
  
  s.subspec "CoreUI" do |ui|
    ui.dependency 'ADPhotoKit/Core'
    ui.dependency 'SnapKit'
    ui.dependency 'Kingfisher', '~> 6.0'
    ui.source_files  = ["ADPhotoKit/Classes/CoreUI/**/*.swift"]
    ui.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'Module_UI'}
    ui.resource_bundles = {
      'ADPhotoKitCoreUI' => ['ADPhotoKit/Assets/CoreUI/**/*']
    }
  end
  
  s.subspec "ImageEdit" do |img|
    img.dependency 'ADPhotoKit/Base'
    img.dependency 'SnapKit'
    img.source_files  = ["ADPhotoKit/Classes/ImageEdit/**/*.swift"]
    img.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'Module_ImageEdit'}
    img.resource_bundles = {
      'ADPhotoKitImageEdit' => ['ADPhotoKit/Assets/ImageEdit/**/*']
    }
  end
  
end
