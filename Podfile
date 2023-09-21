# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'bumpd' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for bumpd
  
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Functions'
  pod 'Firebase/Firestore'
  pod 'Firebase/Messaging'
  pod 'Firebase/Storage'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'IQKeyboardManager'
  pod 'FSCalendar'

  target 'bumpdTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'bumpdUITests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
    end
  end
end
