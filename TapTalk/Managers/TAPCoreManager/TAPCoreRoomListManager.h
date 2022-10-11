//
//  TAPCoreRoomListManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 25/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPMutedRoomModel.h"
@class TAPRoomListModel;

NS_ASSUME_NONNULL_BEGIN

@protocol TAPCoreRoomListManagerDelegate <NSObject>

- (void)tapTalkDidDeleteChatRoom:(NSString *)roomID;
- (void)tapTalkDidPinChatRoom:(NSString *)roomID;
- (void)tapTalkDidUnpinChatRoom:(NSString *)roomID;
- (void)tapTalkDidMuteChatRoom:(NSString *)roomID expiredAt:(NSNumber *)expiredAt;
- (void)tapTalkDidUnmuteChatRoom:(NSString *)roomID;
- (void)tapTalkDidMarkChatRoomAsUnread:(NSString *)roomID;
- (void)tapTalkDidMarkChatRoomAsRead:(NSString *)roomID;

@end

@interface TAPCoreRoomListManager : NSObject

+ (TAPCoreRoomListManager *)sharedManager;

@property (weak, nonatomic) id<TAPCoreRoomListManagerDelegate> delegate;

- (void)fetchNewMessagesWithSuccess:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                            failure:(void (^)(NSError *error))failure;
- (void)getRoomListFromCacheWithSuccess:(void (^)(NSArray <TAPRoomListModel *> *roomListResultArray))success
                                failure:(void (^)(NSError *error))failure;
- (void)getUpdatedRoomListWithSuccess:(void (^)(NSArray <TAPRoomListModel *> *roomListArray))success
                              failure:(void (^)(NSError *error))failure;
- (void)searchLocalRoomListWithKeyword:(NSString *)keyword
                               success:(void (^)(NSArray <TAPRoomListModel *> *roomListArray))success
                               failure:(void (^)(NSError *error))failure;
- (void)markChatRoomAsUnreadWithRoomID:(NSString *)roomID
                               success:(void (^)(void))success
                               failure:(void (^)(NSError *error))failure;
- (void)markChatRoomsAsUnreadWithRoomID:(NSArray<NSString *> *)roomIDs
                                success:(void (^)(void))success
                                failure:(void (^)(NSError *error))failure;
- (void)removeUnreadMarkFromChatRoom:(NSString *)roomID
                             success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure;
- (void)removeUnreadMarkFromChatRooms:(NSArray<NSString *> *)roomIDs
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure;
- (void)getMarkedAsUnreadChatRoomListWithSuccess:(void (^)(NSArray *unreadRoomIDs))success
                                         failure:(void (^)(NSError *error))failure;
- (void)muteChatRoomsWithRoomIDs:(NSArray<NSString *> *)roomIDs expiredAt:(NSNumber *)expiredAt
                                success:(void (^)(NSArray *roomIDs))success
                         failure:(void (^)(NSError *error))failure;

- (void)unmuteChatRoomsWithRoomIDs:(NSArray<NSString *> *)roomIDs
                                success:(void (^)(NSArray *roomIDs))success
                           failure:(void (^)(NSError *error))failure;

- (void)muteChatRoomWithRoomID:(NSString *)roomID expiredAt:(NSNumber *)expiredAt
                                success:(void (^)(NSArray *roomIDs))success
                        failure:(void (^)(NSError *error))failure;

- (void)unmuteChatRoomWithRoomID:(NSString *)roomID
                                success:(void (^)(NSArray *roomIDs))success
                          failure:(void (^)(NSError *error))failure;

- (void)getMutedChatRoomListWithSuccess:(void (^)(NSMutableArray<TAPMutedRoomModel *> *mutedRoomListArray))success failure:(void (^)(NSError *error))failure;

- (NSInteger)getMaxPinnedRoom;

- (void)pinChatRoomsWithRoomIDs:(NSArray<NSString *> *)roomIDs
                           success:(void (^)(NSArray<NSString *> *roomIDs))success
                   failure:(void (^)(NSError *error))failure;

- (void)pinChatRoomWithRoomID:(NSString *)roomID
                           success:(void (^)(NSArray<NSString *> *roomIDs))success
                  failure:(void (^)(NSError *error))failure;

- (void)unpinChatRoomsWithRoomIDs:(NSArray<NSString *> *)roomIDs
                           success:(void (^)(NSArray<NSString *> *roomIDs))success
                     failure:(void (^)(NSError *error))failure;

- (void)unpinChatRoomWithRoomID:(NSString *)roomID
                           success:(void (^)(NSArray<NSString *> *roomIDs))success
                    failure:(void (^)(NSError *error))failure;

- (void)getPinnedChatRoomIDsWithSuccess:(void (^)(NSArray *pinnedRoomIDs))success failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
