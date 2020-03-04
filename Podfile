source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
inhibit_all_warnings!
use_frameworks!

def tapTalk_pods
    pod 'AFNetworking', '~> 3.1.0'
    pod 'SocketRocket'
    pod 'JSONModel', '~> 1.1'
    pod 'Realm', '3.13.1'
    pod 'PodAsset'
    pod 'SDWebImage'
    pod 'GooglePlaces'
    pod 'GoogleMaps'
    pod 'ZSWTappableLabel', '~> 2.0'
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
