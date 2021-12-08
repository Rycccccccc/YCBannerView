#
# Be sure to run `pod lib lint YCBannerView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YCBannerView'
  s.version          = '0.0.1'
  s.summary          = 'YCBannerView.滚动轮播图'
  s.description      = '一款轻量级的滚动轮播图，支持自定义滚动视图'
  s.homepage         = 'https://github.com/Rycccccccc/YCBannerView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rycccccccc' => '787725121@qq.com' }
  s.source           = { :git => 'https://github.com/Rycccccccc/YCBannerView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'YCBannerView/Classes/**/*'
  s.dependency 'Masonry'
  
end
