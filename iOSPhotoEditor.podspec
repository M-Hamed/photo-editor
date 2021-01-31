Pod::Spec.new do |s|
  s.name             = 'iOSPhotoEditor'
  s.version          = '2.0.0'
  s.summary          = 'Photo Editor supports drawing, writing text and adding stickers and emojis'

  s.description      = <<-DESC
Photo Editor supports drawing, writing text and adding stickers and emojis
with the ability to scale and rotate objects
                       DESC

  s.homepage         = 'https://github.com/M-Hamed/photo-editor'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Mohamed Hamed' => 'mohamed.hamed.ibrahem@gmail.com' }
  s.source           = { :git => 'https://github.com/M-Hamed/photo-editor.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '10.3'
  s.source_files = 'iOSPhotoEditor/**/*.{swift}'
  s.resource_bundle = { 'iOSPhotoEditor' => ['iOSPhotoEditor/**/*.{storyboard,xib,xcassets}'] }

end
