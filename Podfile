platform :ios, '9.0'

target 'Amble' do
  use_frameworks!
  
  # Pods for Amble
  pod 'SwiftyJSON'
  pod 'Alamofire', '~> 4.4'
  pod 'Locksmith'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'NVActivityIndicatorView'
  
  target 'AmbleTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Mockingjay'
    pod 'Quick'
    pod 'Nimble'
  end
  
  target 'AmbleUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
end
