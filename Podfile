source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

def tapTalk_pods
    pod 'AFNetworking', '~> 3.1.0'
    pod 'SocketRocket'
    pod 'JSONModel', '~> 1.1'
    pod 'Realm'
    pod 'ZBarSDK', '~> 1.3'
    pod 'PodAsset'
    pod 'SDWebImage', '4.4.2'
    pod 'GooglePlaces'
    pod 'GooglePlacePicker'
    pod 'GoogleMaps'
end

target "TapTalk" do
    tapTalk_pods
end

#libwebp framework is currently doesn't support bitcode, must disable all bitcode for project, please check it gradually and remove below line to enable bitcode once libwebp have support bitcode
#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        target.build_configurations.each do |config|
#            config.build_settings['ENABLE_BITCODE'] = 'NO'
#            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
#        end
#    end
#end
