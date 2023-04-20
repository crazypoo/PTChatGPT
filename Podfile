platform :ios, '13.0'
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
      target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
            target.build_configurations.each do |config|
                config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
  require './Pods/YCSymbolTracker/YCSymbolTracker/symbol_tracker.rb'
  symbol_tracker(installer)
  end
end

target 'PTChatGPT' do  
  pod 'FLEX', :configurations => ['Debug']
  pod 'InAppViewDebugger', :configurations => ['Debug']
  pod 'LookinServer', :configurations => ['Debug']
  pod 'LifetimeTracker', :configurations => ['Debug']
  pod 'WoodPeckeriOS', :configurations => ['Debug']
  pod 'Bugly'
  pod "HyperioniOS/Core", :configurations => ['Debug']
  pod 'HyperioniOS/AttributesInspector', :configurations => ['Debug'] # Optional plugin
  pod 'HyperioniOS/Measurements', :configurations => ['Debug'] # Optional plugin
  pod 'HyperioniOS/SlowAnimations', :configurations => ['Debug'] # Optional plugin


  pod 'PooTools/Core', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/Picker', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/ColorPicker', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/DarkModeSetting', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/LanguageSetting', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/ImagePicker', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/MediaViewer', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/Slider', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/Instructions', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/CheckUpdate', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/PagingControl', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/Input', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/ZipArchive', :git => 'https://github.com/crazypoo/PTools.git'
  pod 'PooTools/GCDWebServer', :git => 'https://github.com/crazypoo/PTools.git'

  pod 'WhatsNew'
  pod 'TensorFlowLiteSwift', '~> 2.3.0', :subspecs => ['Metal']
  pod 'SwiftSpinner'
  pod 'KDCircularProgress'
  
  pod 'SwiftLint'
  pod 'Swinject'
  pod 'YCSymbolTracker'
  
end
