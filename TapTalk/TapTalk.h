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
- (void)tapTalkShouldResetAuthTicket;

//Badge
- (void)tapTalkUnreadChatRoomBadgeCountUpdated:(NSInteger)numberOfUnreadRooms;

//Notification
- (void)tapTalkDidRequestRemoteNotification;
- (void)tapTalkDidTappedNotificationWithMessage:(TAPMessageModel *)message;
- (void)tapTalkDidTappedNotificationWithMessage:(TAPMessageModel *)message fromActiveController:(UIViewController *)currentActiveController;

@end

@interface TapTalk : NSObject

@property (weak, nonatomic) id<TapTalkDelegate> delegate;
@property (nonatomic) TapTalkInstanceState instanceState;
@property (strong, nonatomic) NSDictionary *projectConfigsDictionary;
@property (strong, nonatomic) NSDictionary *customConfigsDictionary;

//Initalization
+ (TapTalk *)sharedInstance;

//Authentication
- (void)authenticateWithAuthTicket:(NSString *)authTicket
                connectWhenSuccess:(BOOL)connectWhenSuccess
                           success:(void (^)(void))success
                           failure:(void (^)(NSError *error))failure;
- (BOOL)isAuthenticated;
- (void)connectWithSuccess:(void (^)(void))success
                   failure:(void (^)(NSError *error))failure;
- (void)disconnectWithCompletionHandler:(void (^)(void))completion;
- (void)enableAutoConnect;
- (void)disableAutoConnect;
- (BOOL)getAutoConnectStatus;

//AppDelegate Handling
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

//Push Notification
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler;

//Exception Handling
- (void)handleException:(NSException *)exception;

//Custom Method
//General Set Up
- (void)initWithAppKeyID:(NSString *)appKeyID
            appKeySecret:(NSString *)appKeySecret
            apiURLString:(NSString *)apiURLString
      implementationType:(TapTalkImplentationType)tapTalkImplementationType;
- (void)refreshActiveUser;
- (void)updateUnreadBadgeCount;
- (TAPUserModel *)getTapTalkActiveUser;

//Chat
- (void)getTapTalkUserWithClientUserID:(NSString *)clientUserID success:(void (^)(TAPUserModel *tapTalkUser))success failure:(void (^)(NSError *error))failure;

//Other
- (void)refreshRemoteConfigs;
- (TapTalkImplentationType)getTapTalkImplementationType;
- (void)logoutAndClearAllDataWithSuccess:(void (^)(void))success
                                 failure:(void (^)(NSError *error))failure;
- (void)clearAllData;

@end
