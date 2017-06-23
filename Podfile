use_frameworks!
inhibit_all_warnings!
platform :osx, "10.11"
workspace "BitBar.xcworkspace"

target "Packages" do
  use_frameworks!
  project "Packages/Packages.xcodeproj"

  target "BitBar" do
    use_frameworks!
    inherit! :search_paths
    project "BitBar.xcodeproj"

    pod "Hue"
    pod "SwiftyBeaver"
    pod "SwiftyUserDefaults"
    pod "Alamofire"
    pod "Sparkle"
    pod "AlamofireImage"
    pod "AsyncSwift"
    pod "SwiftyTimer"
    pod "Cent"
    pod "BonMot"
    pod "OcticonsSwift"
    pod "Ansi"
    pod "Dollar"
    pod "Files"
    pod "Emojize"
    pod "FootlessParser", git: "https://github.com/oleander/FootlessParser.git"
    pod "DateToolsSwift", git: "https://github.com/MatthewYork/DateTools.git"
    pod "Parser", git: "https://github.com/oleander/BitBarParser.git"
    pod "Script", git: "https://github.com/oleander/Script.git"

    target "BitBarTests" do
      inherit! :search_paths
      pod "Nimble"
      pod "Quick"
    end
  end
end

pre_install do
  system "make prebuild_vapor symlink_vapor"
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
    end
  end
end
