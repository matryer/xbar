use_frameworks!
inhibit_all_warnings!
platform :osx, "10.11"
workspace "BitBar.xcworkspace"

target "BitBar" do
  use_frameworks!
  project "BitBar.xcodeproj"
  pod "Hue"
  pod "SwiftyBeaver"
  pod "SwiftyUserDefaults"
  pod "Alamofire"
  # pod "Sparkle"
  pod "AlamofireImage"
  pod "AsyncSwift"
  pod "SwiftyTimer"
  pod "Cent"
  pod "Emojize"
  pod "BonMot"
  pod "OcticonsSwift"
  pod "Ansi"
  pod "SwiftyJSON"
  pod "Dollar"
  pod "Files"
  pod "FootlessParser", git: "https://github.com/oleander/FootlessParser.git"
  pod "DateToolsSwift", git: "https://github.com/MatthewYork/DateTools.git"
  pod "Parser", git: "https://github.com/oleander/BitBarParser.git"
  pod "Script", git: "https://github.com/oleander/Script.git"

  target "BitBarTests" do
    inherit! :search_paths
    pod "Nimble"
    pod "Quick"
  end

  target "Startup" do
    inherit! :search_paths
  end

  abstract_target "Packages" do
    project "Packages/Packages.xcodeproj"
    target "Vapor" do
      pod "OpenSSL-OSX", git: "https://github.com/GerTeunis/OpenSSL-OSX-Pod.git"
    end
  end

  # target "Config" do
  #   pod "Files"
  #
  #   target "ConfigTests" do
  #     inherit! :search_paths
  #     pod "Nimble"
  #     pod "Quick"
  #   end
  # end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
    end
  end
end


pre_install do
  puts `make prebuild_vapor symlink_vapor`
end
