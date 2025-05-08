#
# Be sure to run `pod lib lint GPUImage2.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GPUImage2'
  s.version          = '0.1.6'
  s.summary          = '基于GPUImage2自定义滤镜版本'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ZDerain/GPUImage2'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZDerain' => 'derainzhou@gmail.com' }
  s.source           = { :git => 'https://github.com/ATiOSGroup/GPUImage2.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GL_SILENCE_DEPRECATION=1 GLES_SILENCE_DEPRECATION=1' }
  
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '13.0'

  s.swift_version = '5.0'
  
  s.source_files = 'GPUImage2/**/*'
  s.source_files = 'GPUImage2/Source/**/*.{swift}'
  s.resources = 'GPUImage2/Source/Operations/Shaders/*.{fsh}'
  s.requires_arc = true
  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES', 'OTHER_SWIFT_FLAGS' => "$(inherited) -DGLES"}

end
