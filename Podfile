source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
inhibit_all_warnings!

def tapTalk_pods
#    pod 'AFNetworking', '~> 4.0.0', :modular_headers => true
    pod 'SocketRocket'
    pod 'JSONModel', '1.8.0', :modular_headers => true
    pod 'Realm', '10.1.0'
    pod 'PodAsset'
    pod 'SDWebImage'
    pod 'GooglePlaces'
    pod 'GoogleMaps', '5.2.0'
    pod 'ZSWTappableLabel', '2.0'
end

target "TapTalk" do
    tapTalk_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            target.build_settings(config.name)['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        end
    end
end
