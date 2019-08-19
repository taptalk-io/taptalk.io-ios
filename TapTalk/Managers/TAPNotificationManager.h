//
//  TAPNotificationManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 23/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPNotificationManagerDelegate <NSObject>

@optional
- (void)notificationManagerDidHandleTappedNotificationWithMessage:(TAPMessageModel *)message;

@end

@interface TAPNotificationManager : NSObject

@property (weak, nonatomic) id<TAPNotificationManagerDelegate> delegate;

+ (TAPNotificationManager *)sharedManager;

- (void)setPushToken:(NSString *)pushToken;
- (void)handlePushNotificationWithUserInfo:(NSDictionary *)userInfo;
- (void)handleIncomingMessage:(TAPMessageModel *)message shouldShowNotification:(BOOL)shouldShowNotification;
- (void)handleTappedNotificationWithUserInfo:(NSDictionary *)userInfo;
- (void)updateApplicationBadgeCount;

@end

NS_ASSUME_NONNULL_END
