#
# Be sure to run `pod lib lint ADPhotoKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ADPhotoKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ADPhotoKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zexu007@qq.com/ADPhotoKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zexu007@qq.com' => 'zexu007@qq.com' }
  s.source           = { :git => 'https://github.com/zexu007@qq.com/ADPhotoKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.requires_arc          = true
  s.frameworks            = 'UIKit','Photos','PhotosUI','AVFoundation'
  s.default_subspec = 'UI'
  
  s.subspec "Core" do |c|
    c.source_files  = ["ADPhotoKit/Classes/Core/**/*.swift"]
    c.resource_bundles = {
      'ADPhotoKitCore' => ['ADPhotoKit/Assets/Core/**/*']
    }
  end
  
  s.subspec "UI" do |ui|
    ui.dependency 'ADPhotoKit/Core'
    ui.dependency 'SnapKit'
    ui.dependency 'Kingfisher'
    ui.source_files  = ["ADPhotoKit/Classes/UI/**/*.swift"]
    ui.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'Module_UI'}
    ui.resource_bundles = {
      'ADPhotoKitUI' => ['ADPhotoKit/Assets/UI/**/*']
    }
  end

  # s.source_files = 'ADPhotoKit/Classes/**/*'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'
end
