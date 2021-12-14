//
//  TAPCoreRoomListManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 25/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TAPRoomListModel;

NS_ASSUME_NONNULL_BEGIN

@interface TAPCoreRoomListManager : NSObject

+ (TAPCoreRoomListManager *)sharedManager;

- (void)fetchNewMessagesWithSuccess:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                            failure:(void (^)(NSError *error))failure;
- (void)getRoomListFromCacheWithSuccess:(void (^)(NSArray <TAPRoomListModel *> *roomListResultArray))success
                                failure:(void (^)(NSError *error))failure;
- (void)getUpdatedRoomListWithSuccess:(void (^)(NSArray <TAPRoomListModel *> *roomListArray))success
                              failure:(void (^)(NSError *error))failure;
- (void)searchLocalRoomListWithKeyword:(NSString *)keyword
                               success:(void (^)(NSArray <TAPRoomListModel *> *roomListArray))success
                               failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
