Pod::Spec.new do |spec|
  spec.name = 'AHProxySettings'
  spec.version = '0.1.1'
  spec.platform = :osx
  spec.license = 'MIT'
  spec.summary = 'Objective-c lib to easily acquire the current system proxy settings'
  spec.homepage = 'https://github.com/eahrold/AHProxySettings'
  spec.authors  = { 'Eldon Ahrold' => 'eldon.ahrold@gmail.com' }
  spec.source   = { :git => 'https://github.com/eahrold/AHProxySettings.git', :tag => "v#{spec.version}" }
  spec.requires_arc = true
  spec.frameworks = 'Foundation','SystemConfiguration','Security'
  spec.public_header_files = 'AHProxySettings/*.h'
  spec.source_files = 'AHProxySettings/*.{h,m}'
end
