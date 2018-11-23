//
//  TAPMessageStatusManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPMessageStatusManager : NSObject

+ (TAPMessageStatusManager *)sharedManager;

- (void)triggerUpdateStatus;
- (void)stopTimerUpdateStatus;
- (void)markMessageAsReadWithMessage:(TAPMessageModel *)message;
- (void)markMessageAsDeliveredWithMessage:(TAPMessageModel *)message;
- (void)filterAndUpdateBulkMessageStatusToDeliveredWithArray:(NSArray *)messageArray;
- (void)markMessageAsDeliveredFromPushNotificationWithMessage:(TAPMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
