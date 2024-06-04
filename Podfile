# Uncomment the next line to define a global platform for your project
# platform :ios, '15.0'

target 'FindVaccineCenter' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FindVaccineCenter
  pod 'NMapsMap'

  target 'FindVaccineCenterTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FindVaccineCenterUITests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
