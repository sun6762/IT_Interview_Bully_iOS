platform :ios, '13.0'
use_frameworks!

target 'IT_Interview_Bully' do
  pod 'MarkdownView', '~> 1.9'
  pod 'Highlightr', '~> 2.1'
  pod 'SnapKit', '~> 5.7'
end

target 'IT_Interview_BullyTests' do
  inherit! :search_paths
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
