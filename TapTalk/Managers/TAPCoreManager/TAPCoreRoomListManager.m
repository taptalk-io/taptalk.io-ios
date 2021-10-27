//
//  TAPCoreRoomListManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 25/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCoreRoomListManager.h"
#import "TAPRoomListModel.h"

@interface TAPCoreRoomListManager ()

- (void)fetchNewMessagesWithSuccess:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                            failure:(void (^)(NSError *error))failure;

@end

@implementation TAPCoreRoomListManager
#pragma mark - Lifecycle
+ (TAPCoreRoomListManager *)sharedManager {

    //Check if only implement TAPUI, don't init the core manager
    TapTalkImplentationType implementationType = [[TapTalk sharedInstance] getTapTalkImplementationType];
    if (implementationType == TapTalkImplentationTypeUI) {
        return nil;
    }

    static TAPCoreRoomListManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

- (void)dealloc {

}

#pragma mark - Custom Method
- (void)fetchNewMessagesWithSuccess:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                            failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetNewAndUpdatedMessageSuccess:^(NSArray *messageArray) {
        
        //Update leftover message status to delivered
        if ([messageArray count] != 0) {
            [[TAPMessageStatusManager sharedManager] filterAndUpdateBulkMessageStatusToDeliveredWithArray:messageArray];
        }
        
        //Save messages to database
        [TAPDataManager updateOrInsertDatabaseMessageInMainThreadWithData:messageArray success:^{

            //Delete physical files when isDeleted = 1 (message is deleted)
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                for (TAPMessageModel *message in messageArray) {
                    if (message.isDeleted) {
                        [TAPDataManager deletePhysicalFilesInBackgroundWithMessage:message success:^{
                            
                        } failure:^(NSError *error) {
                            
                        }];
                    }
                }
            });
            
            success(messageArray);
        } failure:^(NSError *error) {
            //Failure save messages to database
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failure(localizedError);
        }];
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getRoomListFromCacheWithSuccess:(void (^)(NSArray <TAPRoomListModel *> *roomListResultArray))success
                                failure:(void (^)(NSError *error))failure {
    [TAPDataManager getRoomListSuccess:^(NSArray *resultArray) {
        //Converting to TAPRoomListModel
        NSMutableArray *roomListResultArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *unreadMentionDataDictionary = [NSMutableDictionary dictionary];
        __block NSInteger countedMessage = 0;
        
        for (TAPMessageModel *message in resultArray) {
            TAPRoomModel *room = message.room;
            NSString *roomID = room.roomID;
            roomID = [TAPUtil nullToEmptyString:roomID];
            
            TAPRoomListModel *roomList = [TAPRoomListModel new];
            roomList.lastMessage = message;
            
            [roomListResultArray addObject:roomList];
            
            // Calculate unread message & mention count
            NSString *username = [TAPDataManager getActiveUser].username;
            username = [TAPUtil nullToEmptyString:username];
            NSString *activeUserID = [TAPDataManager getActiveUser].userID;
            activeUserID = [TAPUtil nullToEmptyString:activeUserID];
            
            [TAPDataManager getDatabaseUnreadMentionsInRoomWithUsername:username roomID:roomID activeUserID:activeUserID success:^(NSArray *unreadMentionMessages) {
                NSInteger totalUnreadMention = [unreadMentionMessages count];
                [unreadMentionDataDictionary setObject:[NSNumber numberWithInteger:totalUnreadMention] forKey:roomID];
                
                [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:roomID activeUserID:[TAPChatManager sharedManager].activeUser.userID success:^(NSArray *unreadMessages) {
                    //Set number of unread messages to array and dictionary
                    NSInteger numberOfUnreadMessages = [unreadMessages count];
                    NSInteger numberOfUnreadMentions = [[unreadMentionDataDictionary objectForKey:roomID] integerValue];
                    roomList.numberOfUnreadMessages = numberOfUnreadMessages;
                    roomList.numberOfUnreadMentions = numberOfUnreadMentions;
                    
                    if (roomList.numberOfUnreadMessages < 0) {
                        roomList.numberOfUnreadMessages = 0;
                    }
                    
                    if (roomList.numberOfUnreadMentions < 0) {
                        roomList.numberOfUnreadMentions = 0;
                    }
                    
                    countedMessage++;
                    if (countedMessage >= resultArray.count) {
                        success([roomListResultArray copy]);
                    }
                } failure:^(NSError *error) {
                    countedMessage++;
                    if (countedMessage >= resultArray.count) {
                        success([roomListResultArray copy]);
                    }
                }];
            } failure:^(NSError *error) {
                countedMessage++;
                if (countedMessage >= resultArray.count) {
                    success([roomListResultArray copy]);
                }
            }];
        }
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getUpdatedRoomListWithSuccess:(void (^)(NSArray <TAPRoomListModel *> *roomListArray))success
                              failure:(void (^)(NSError *error))failure {
    
    TAPUserModel *activeUser = [TAPDataManager getActiveUser];
    NSString *userID = activeUser.userID;
    userID = [TAPUtil nullToEmptyString:userID];
    if ([userID isEqualToString:@""]) {
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedStringFromTableInBundle(@"Current active user is not found.", nil, [TAPUtil currentBundle], @"") code:999 userInfo:@{@"message": NSLocalizedStringFromTableInBundle(@"Current active user is not found.", nil, [TAPUtil currentBundle], @"")}];
        failure(localizedError);
    }
    [TAPDataManager getRoomListSuccess:^(NSArray *resultArray) {
        if ([resultArray count] == 0) {
            //Data is empty
            
            //Get data from API
            [TAPDataManager callAPIGetMessageRoomListAndUnreadWithUserID:userID success:^(NSArray *messageArray) {
                //Save messages to database
                [TAPDataManager updateOrInsertDatabaseMessageInMainThreadWithData:messageArray success:^{
                    //Delete physical files when isDeleted = 1 (message is deleted)
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        for (TAPMessageModel *message in messageArray) {
                            if (message.isDeleted) {
                                [TAPDataManager deletePhysicalFilesInBackgroundWithMessage:message success:^{
                                    
                                } failure:^(NSError *error) {
                                    
                                }];
                            }
                        }
                    });
                    
                    [self getRoomListFromCacheWithSuccess:^(NSArray * _Nonnull roomListResultArray) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success(roomListResultArray);
                        });
                    } failure:^(NSError * _Nonnull error) {
                        //Failure get room list
                        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
                        failure(localizedError);
                    }];
                } failure:^(NSError *error) {
                    //Failure save messages to database
                    NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
                    failure(localizedError);
                }];
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
                    failure(localizedError);
                });
            }];
        }
        else {
            //Data not empty
            //Fetch new Messages
            [self fetchNewMessagesWithSuccess:^(NSArray * _Nonnull roomListArray) {
                    //Load from database
                    [self getRoomListFromCacheWithSuccess:^(NSArray * _Nonnull roomListResultArray) {
                        success(roomListResultArray);
                    } failure:^(NSError * _Nonnull error) {
                        //Failure load from database
                        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
                        failure(localizedError);
                    }];
            } failure:^(NSError * _Nonnull error) {
                //Failure fetch new messages
                NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
                failure(localizedError);
            }];
        }
    } failure:^(NSError *error) {
        //Failure get room list
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

@end
