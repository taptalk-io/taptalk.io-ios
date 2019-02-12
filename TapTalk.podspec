#
#  Be sure to run `pod spec lint TapTalk.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "TapTalk"
  s.version      = "0.2.4"
  s.summary      = "Powerful Chat Engine"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = "A powerful chat engine."

  s.homepage     = "https://www.moselo.com"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = "MIT"
  # s.license      = s.source       = { :path => '.' }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "Ritchie Nathaniel" => "ritchie@moselo.com" }
  # Or just: s.author    = "Dominic Vedericho"
  # s.authors            = { "Dominic Vedericho" => "dominic@moselo.com" }
  # s.social_media_url   = "http://twitter.com/Dominic Vedericho"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  s.platform     = :ios, "10.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "9.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

#   s.source       = { :path => '.' }
    s.source       = { :git => 'git@git.moselo.com:taptalk/taptalk-ios.git', :tag => '0.2.4' }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

    s.source_files  = "TapTalk", "TapTalk/*{h,m}", "TapTalk/**/*.{h,m}", "TapTalk/**/**/*.{h,m}"

  # s.exclude_files = "Classes/Exclude", "TapTalk/**/*.plist"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

    s.resources = "TapTalk/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,ttf,otf}"
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
  
# s.vendored_frameworks = 'WebP.framework'


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PROJECT_DIR}/.."/**' }

    s.dependency "AFNetworking", "~> 3.1.0"
    s.dependency "SocketRocket"
    s.dependency "JSONModel", "~> 1.1"
    s.dependency "Realm"
    s.dependency "SDWebImage", "4.4.2"
    s.dependency "ZBarSDK", "~> 1.3"
    s.dependency "PodAsset"
    
    # ――― Prefix Header ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

    s.prefix_header_contents ='#import "Configs.h"', '#import "AFNetworkActivityIndicatorManager.h"', '#import "NSUserDefaults+MPSecureUserDefaults.h"', '#import "PodAsset.h"', '#import "TapTalk.h"', '#import "TAPUtil.h"', '#import "TAPChatManager.h"', '#import "TAPConnectionManager.h"', '#import "TAPContactManager.h"', '#import "TAPContactCacheManager.h"', '#import "TAPCustomBubbleManager.h"', '#import "TAPCustomKeyboardManager.h"', '#import "TAPDataManager.h"', '#import "TAPDatabaseManager.h"', '#import "TAPEncryptorManager.h"', '#import "TAPFileDownloadManager.h"', '#import "TAPFileUploadManager.h"', '#import "TAPMessageStatusManager.h"', '#import "TAPNetworkManager.h"', '#import "TAPNotificationManager.h"', '#import "TAPOldDataManager.h"', '#import "TAPGrowingTextView.h"', '#import "TAPImageView.h"', '#import "TAPSearchBarView.h"'
    
    # ――― Bundle ------―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    
    s.resource_bundles = {
        'TapTalk' => [
            'Pod/**/*.xib',
            'Pod/**/*.storyboard',
            'Pod/**/*.{png,jpeg,jpg,xcassets,ttf,otf,caf}',
            'TapTalk/**/*.xib',
            'TapTalk/**/*.storyboard',
            'TapTalk/**/*.{png,jpeg,jpg,xcassets,ttf,otf,caf}'
        ]
    }


    # ――― XCConfig ------―――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    #uncomment to disable bitcode
#    s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'DEBUG_INFORMATION_FORMAT' => 'dwarf' }

end
