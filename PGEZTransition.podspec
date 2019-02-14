#
#  Be sure to run `pod spec lint PGEZTransition.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name             = 'PGEZTransition'
  s.version          = '1.1.0'
  s.summary          = 'Easy Transform Transition.'
  s.description      = 'You can set an animation for each "view" that works in the ViewController Transition.'
  s.homepage         = 'https://github.com/ipagong/PGEZTransition'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ipagong' => 'ipagong.dev@gmail.com' }
  s.source           = { :git => 'https://github.com/ipagong/PGEZTransition.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'PGEZTransition/Classes/**/*'

end
