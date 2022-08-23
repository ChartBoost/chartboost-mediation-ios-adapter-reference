Pod::Spec.new do |spec|
  spec.name        = 'ChartboostHeliumAdapterReference'
  spec.version     = '4.1.0.0.0'
  spec.license     = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.homepage    = 'https://www.chartboost.com/'
  spec.authors     = { 'Chartboost' => 'https://www.chartboost.com/' }
  spec.summary     = 'Helium iOS SDK Reference adapter.'
  spec.description = 'Reference Adapters for mediating through Helium. Supported ad formats: Banner, Interstitial, and Rewarded.'

  # Source
  spec.module_name  = 'HeliumAdapterReference'
  spec.source       = { :git => 'https://github.com/ChartBoost/helium-ios-adapter-reference.git', :tag => '1.0.0' }
  spec.source_files = 'ReferenceAdapter/**/*.{h,m,swift}'

  # Minimum supported versions
  spec.swift_version         = '5.0'
  spec.ios.deployment_target = '10.0'

  # System frameworks used
  spec.ios.frameworks = ['UIKit']
  
  # This adapter compatible with all Helium 4.X versions of the SDK.
  spec.dependency 'ChartboostHelium', '~> 4.0'
end
