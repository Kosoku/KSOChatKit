Pod::Spec.new do |s|
  s.name             = 'KSOChatKit'
  s.version          = '0.1.0'
  s.summary          = 'KSOChatKit is an iOS framework that provides various controls for building a Messages like UI.'
  s.description      = <<-DESC
KSOChatKit is an iOS framework that provides various controls for building a Messages like UI. It provides an automatically expanding text view, automatic scroll view management and various completion behavior.
                       DESC

  s.homepage         = 'https://github.com/Kosoku/KSOChatKit'
  s.screenshots      = ['https://github.com/Kosoku/KSOChatKit/raw/master/screenshots/iOS-1.png','https://github.com/Kosoku/KSOChatKit/raw/master/screenshots/iOS-2.png','https://github.com/Kosoku/KSOChatKit/raw/master/screenshots/iOS-3.png','https://github.com/Kosoku/KSOChatKit/raw/master/screenshots/iOS-3.png']
  s.license          = { :type => 'BSD', :file => 'license.txt' }
  s.author           = { 'William Towe' => 'willbur1984@gmail.com' }
  s.source           = { :git => 'https://github.com/Kosoku/KSOChatKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  
  s.requires_arc = true

  s.source_files = 'KSOChatKit/**/*.{h,m}'
  s.exclude_files = 'KSOChatKit/KSOChatKit-Info.h'
  s.private_header_files = 'KSOChatKit/Private/*.h'
  
  s.resource_bundles = {
    'KSOChatKit' => ['KSOChatKit/**/*.{lproj}']
  }

  s.ios.frameworks = 'UIKit'
  
  s.dependency 'Ditko'
  s.dependency 'Agamotto'
  s.dependency 'Quicksilver'
end
