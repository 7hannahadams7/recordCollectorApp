# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'

target 'recordCollector' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for recordCollector
	pod 'FirebaseCore'
  pod 'FirebaseDatabase'
	pod 'FirebaseStorage'
	pod 'FirebaseAuth'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
