#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TapAFNetworking.h"
#import "TapAFHTTPSessionManager.h"
#import "TapAFURLSessionManager.h"
#import "TapAFCompatibilityMacros.h"
#import "TapAFNetworkReachabilityManager.h"
#import "TapAFSecurityPolicy.h"
#import "TapAFURLRequestSerialization.h"
#import "TapAFURLResponseSerialization.h"
#import "TapAFAutoPurgingImageCache.h"
#import "TapAFImageDownloader.h"
#import "TapAFNetworkActivityIndicatorManager.h"
#import "UIActivityIndicatorView+TapAFNetworking.h"
#import "UIButton+TapAFNetworking.h"
#import "UIImageView+TapAFNetworking.h"
#import "UIKit+TapAFNetworking.h"
#import "UIProgressView+TapAFNetworking.h"
#import "UIRefreshControl+TapAFNetworking.h"
#import "WKWebView+TapAFNetworking.h"

FOUNDATION_EXPORT double AFNetworkingVersionNumber;
FOUNDATION_EXPORT const unsigned char AFNetworkingVersionString[];

