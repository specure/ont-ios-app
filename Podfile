platform :ios, '13.0'

use_frameworks!

# ignore all warnings from all pods
#inhibit_all_warnings!

abstract_target 'All' do
  pod 'RMBTClient', :git => 'https://github.com/specure/ont-ios-client.git', :branch => 'main'
  
  pod 'TUSafariActivity'
  pod 'GoogleMaps'
  pod 'BCGenieEffect'
  pod 'SVProgressHUD'
  pod 'KINWebBrowser', :git => 'https://github.com/sglushchenko/KINWebBrowser', :branch => 'master'
  pod 'Firebase/Core'
  pod 'Firebase/Crashlytics'
  pod 'FacebookSDK'
  pod 'FacebookCore'
  pod 'Google-Mobile-Ads-SDK'
  pod 'MapboxMaps', '10.6.0'
  pod 'MarkdownView', '~> 1.8.3'
  pod 'DropDown'
  
  # now in the folder Vendor
  #pod 'SWRevealViewController', '~> 2.3.0' # TODO: not possible to use the version from cocoapods because tb changed something in the implementation...
  
  pod 'ActionKit'
  
  pod 'XCGLogger'
  
  target 'RMBT_ONT' do
    target 'UnitTests' do
      inherit! :search_paths
    end
    
    target 'UITests' do
      inherit! :search_paths
    end
  end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
  end
end

end
