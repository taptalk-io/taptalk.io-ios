//
//  TapTalk.h
//  TapTalk
//
//  Created by Ritchie Nathaniel on 11/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

#import "TAPChatViewController.h"
#import "TAPChatManager.h"
#import "TAPGroupManager.h"
#import "TAPAPIManager.h"

#import "TAPUserModel.h"
#import "TAPMessageModel.h"
#import "TAPProductModel.h"

#import <AVKit/AVKit.h>
#import <Photos/Photos.h>

//! Project version number for TapTalk.
FOUNDATION_EXPORT double TapTalkVersionNumber;

//! Project version string for TapTalk.
FOUNDATION_EXPORT const unsigned char TapTalkVersionString[];

@protocol TapTalkDelegate <NSObject>

//Authentication
- (void)tapTalkRefreshTokenExpired;

//Badge
- (void)tapTalkUnreadChatRoomBadgeCountUpdated:(NSInteger)numberOfUnreadRooms;

//Notification
- (void)tapTalkDidRequestRemoteNotification;
- (void)tapTalkDidTappedNotificationWithMessage:(TAPMessageModel *_Nonnull)message fromActiveController:(nullable UIViewController *)currentActiveController;

@end

@interface TapTalk : NSObject

@property (weak, nonatomic) id<TapTalkDelegate> _Nullable delegate;
@property (nonatomic) TapTalkInstanceState instanceState;

//Initalization
+ (TapTalk *_Nonnull)sharedInstance;

//==========================================================
//                     Authentication
//==========================================================
/**
 Authenticate user to TapTalk.io server by providing the auth ticket
 set connectWhenSuccess to YES if you want to connect to TapTalk.io automatically after authentication
 */
- (void)authenticateWithAuthTicket:(NSString *_Nonnull)authTicket
                connectWhenSuccess:(BOOL)connectWhenSuccess
                           success:(void (^_Nonnull)(void))success
                           failure:(void (^_Nonnull)(NSError * _Nonnull error))failure;

/**
 To check if user authenticated to TapTalk.io server or not
 return YES if the user is authenticated to TapTalk.io server
 */
- (BOOL)isAuthenticated;

/**
 Logout from TapTalk.io and clear all local cached data
 */
- (void)logoutAndClearAllTapTalkDataWithSuccess:(void (^_Nonnull)(void))success
                                        failure:(void (^_Nonnull)(NSError *_Nonnull error))failure;

/**
 Clear all local cached data
 */
- (void)clearAllTapTalkData;

//==========================================================
//                       Connection
//==========================================================
/**
 To enable auto connect to TapTalk.io server
 TapTalk will automatically connect to server everytime user open the app
 */
- (void)connectWithSuccess:(void (^_Nonnull)(void))success
                   failure:(void (^_Nonnull)(NSError *_Nonnull error))failure;

/**
 To enable auto connect to TapTalk.io server
 TapTalk will automatically connect to server everytime user open the app
 */
- (void)disconnectWithCompletionHandler:(void (^_Nonnull)(void))completion;

/**
 To enable auto connect to TapTalk.io server
 TapTalk will automatically connect to server everytime user open the app
 */
- (void)enableAutoConnect;

/**
 To disable auto connect to TapTalk.io server
 */
- (void)disableAutoConnect;

/**
 To obtain auto connect status
 return YES if auto connect status is enabled
 */
- (BOOL)isAutoConnectEnabled;

/**
 To check if user connected to TapTalk.io server or not
 return YES if the user is connected to TapTalk.io server
 */
- (BOOL)isConnected;

//==========================================================
//            UIApplicationDelegate Handling
//==========================================================
/**
 Tells the delegate that the launch process is almost done and the app is almost ready to run.
 */
- (void)application:(UIApplication *_Nonnull)application didFinishLaunchingWithOptions:(NSDictionary *_Nonnull)launchOptions;

/**
 Tells the delegate that the app is about to become inactive.
 */
- (void)applicationWillResignActive:(UIApplication *_Nonnull)application;

/**
 Tells the delegate that the app is now in the background.
 */
- (void)applicationDidEnterBackground:(UIApplication *_Nonnull)application;

/**
 Tells the delegate that the app is about to enter the foreground.
 */
- (void)applicationWillEnterForeground:(UIApplication *_Nonnull)application;

/**
 Tells the delegate that the app has become active.
 */
- (void)applicationDidBecomeActive:(UIApplication *_Nonnull)application;

/**
 Tells the delegate when the app is about to terminate.
 */
- (void)applicationWillTerminate:(UIApplication *_Nonnull)application;

/**
 Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
 */
- (void)application:(UIApplication *_Nonnull)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *_Nonnull)deviceToken;

/**
 Tells the app that a remote notification arrived that indicates there is data to be fetched.
 */
- (void)application:(UIApplication *_Nonnull)application didReceiveRemoteNotification:(NSDictionary *_Nonnull)userInfo fetchCompletionHandler:(void (^_Nonnull)(UIBackgroundFetchResult result))completionHandler;

//Push Notification
/**
 Asks the delegate how to handle a notification that arrived while the app was running in the foreground.
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *_Nonnull)center willPresentNotification:(UNNotification *_Nonnull)notification withCompletionHandler:(void (^_Nonnull)(UNNotificationPresentationOptions options))completionHandler;

/**
 Asks the delegate to process the user's response to a delivered notification.
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *_Nonnull)center didReceiveNotificationResponse:(UNNotificationResponse *_Nonnull)response withCompletionHandler:(void(^_Nonnull)(void))completionHandler;

//Exception Handling
/**
 Called when the application throws the exception
 */
- (void)handleException:(NSException * _Nonnull)exception;


//==========================================================
//                  General Setup & Methods
//==========================================================
/**
 Initialize app to TapTalk.io by providing app key credentials, url, and implementation type
 */
- (void)initWithAppKeyID:(NSString *_Nonnull)appKeyID
            appKeySecret:(NSString *_Nonnull)appKeySecret
            apiURLString:(NSString *_Nonnull)apiURLString
      implementationType:(TapTalkImplentationType)tapTalkImplementationType;

/**
 Obtain the implementation type of TapTalk.io set by user
 
 enum TapTalkImplentationType:
 TapTalkImplentationTypeUI,
 TapTalkImplentationTypeCore,
 TapTalkImplentationTypeCombine
 */
- (TapTalkImplentationType)getTapTalkImplementationType;

/**
 Fetch latest unread badge count and called tapTalkUnreadChatRoomBadgeCountUpdated: method in TapTalk delegate
 */
- (void)updateUnreadBadgeCount;

/**
 Fetch latest remote configs data
 */
- (void)refreshRemoteConfigs;

/**
 Get core configs data
 */
- (NSDictionary *)getCoreConfigs;

/**
 Get project configs data
 */
- (NSDictionary *)getProjectConfigs;

/**
 Get custom configs data
 */
- (NSDictionary *)getCustomConfigs;

/**
 Set Google Places API Key to pick and obtain location when send location chat
 */
- (void)initializeGooglePlacesAPIKey:(NSString * _Nonnull)apiKey;

//==========================================================
//                          User
//==========================================================
/**
 Refresh latest active user data from the server
 */
- (void)refreshActiveUser;

/**
 Obtain active user data
 return nil if active user data is not found
 */
- (TAPUserModel *_Nonnull)getTapTalkActiveUser;

@end
