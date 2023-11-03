# Uncomment this line to define a global platform for your project
source 'https://cdn.cocoapods.org/'
platform :ios, '15.0'
inhibit_all_warnings!
install! 'cocoapods',
    :warn_for_unused_master_specs_repo => false
use_frameworks!

target 'PokemonController' do
    pod 'GCDWebServer'
end

post_install do |installer|
    
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |configuration|
            configuration.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            configuration.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            configuration.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            configuration.build_settings['SWIFT_VERSION'] = "5.9"
            configuration.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
            configuration.build_settings['ENABLE_BITCODE'] = 'NO'
            if ( configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0 )
                configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
            end
        end
        
        
    end
end
