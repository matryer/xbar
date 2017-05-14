target 'BitBar' do
  use_frameworks!
  inhibit_all_warnings!
  platform :osx, '10.11'

  pod 'Hue'
  pod 'SwiftyUserDefaults'
  pod 'Alamofire'
  pod 'Sparkle'
  pod 'AlamofireImage'
  pod 'AsyncSwift'
  pod 'FootlessParser'
  pod 'SwiftyTimer'
  pod 'Cent'
  pod 'Emojize'
  pod 'BonMot'
  pod 'Ansi'
  pod 'SwiftTryCatch', git: 'https://github.com/oleander/SwiftTryCatch.git'
  pod 'Files', git: 'https://github.com/JohnSundell/Files.git'
  pod 'DateToolsSwift', git: 'https://github.com/MatthewYork/DateTools.git'
  pod 'Parser', git: 'https://github.com/oleander/BitBarParser.git'

  target 'Tests' do
    inherit! :search_paths
    pod 'Nimble'
    pod 'Quick'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end
