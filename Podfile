target 'BitBar' do
  use_frameworks!
  inhibit_all_warnings!
  platform :osx, '10.10'

  pod 'Hue'
  pod 'SwiftyUserDefaults'
  pod 'Alamofire'
  pod 'Sparkle'
  pod 'EmitterKit'
  pod 'AsyncSwift'
  pod 'FootlessParser'
  pod 'SwiftyTimer'
  pod 'Cent'
  pod 'Emojize'
  pod 'SwiftTryCatch', git: 'https://github.com/oleander/SwiftTryCatch.git'
  pod 'Ansi', git: 'https://github.com/oleander/Ansi.git'
  pod 'Files', git: 'https://github.com/JohnSundell/Files.git'
  pod 'DateToolsSwift', git: 'https://github.com/MatthewYork/DateTools.git'
  pod 'Attr', git: 'https://github.com/oleander/Attr.git'
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
