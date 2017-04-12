target 'BitBar' do
  use_frameworks!
  platform :osx, '10.10'

  pod 'Hue'
  pod 'SwiftyUserDefaults'
  pod 'Sparkle'
  pod 'EmitterKit'
  pod 'AsyncSwift'
  pod 'FootlessParser'
  pod 'SwiftyTimer'
  pod 'SwiftTryCatch', git: 'https://github.com/oleander/SwiftTryCatch.git'
  pod 'Files', git: 'https://github.com/JohnSundell/Files.git'
  pod 'DateToolsSwift', git: 'https://github.com/MatthewYork/DateTools.git'
  pod 'Emojize', git: 'https://github.com/oleander/Emojize.git'

  target 'BitBarTests' do
    inherit! :search_paths
    pod 'Nimble'
    pod 'Quick'
    pod 'SwiftCheck'
  end
end
