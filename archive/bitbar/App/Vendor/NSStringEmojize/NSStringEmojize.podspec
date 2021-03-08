Pod::Spec.new do |s|
  s.name     = 'NSStringEmojize'
  s.version  = '0.2.0'
  s.license  = 'Apache 2.0'
  s.summary  = 'A category on NSString to turn codes from Emoji Cheat Sheet (http://www.emoji-cheat-sheet.com/) into Unicode emoji characters.'
  s.homepage = 'https://github.com/diy/nsstringemojize'
  s.authors  = {'Jon Beilin' => 'jon@diy.org'}
  s.source   = { :git => 'https://github.com/diy/NSStringEmojize.git', :tag => 'v0.2.0' }
  s.platform = :ios
  s.source_files = 'NSStringEmojize'
  s.requires_arc = true

  s.framework = 'UIKit'
end
