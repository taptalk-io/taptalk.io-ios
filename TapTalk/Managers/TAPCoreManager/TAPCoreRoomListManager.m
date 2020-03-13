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
        for (TAPMessageModel *message in resultArray) {
            TAPRoomModel *room = message.room;
            NSString *roomID = room.roomID;
            roomID = [TAPUtil nullToEmptyString:roomID];
            
            TAPRoomListModel *roomList = [TAPRoomListModel new];
            roomList.lastMessage = message;
            
            [roomListResultArray addObject:roomList];
        }
        
        success([roomListResultArray copy]);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getUpdatedRoomListWithSuccess:(void (^)(NSArray <TAPRoomListModel *> *roomListArray))success
                              failure:(void (^)(NSError *error))failure {
    [TAPDataManager getRoomListSuccess:^(NSArray *resultArray) {
        if ([resultArray count] == 0) {
            //Data is empty
            TAPUserModel *activeUser = [TAPDataManager getActiveUser];
            NSString *userID = activeUser.userID;
            userID = [TAPUtil nullToEmptyString:userID];
            if ([userID isEqualToString:@""]) {
                NSError *localizedError = [NSError errorWithDomain:NSLocalizedStringFromTableInBundle(@"Current active user is not found...", nil, [TAPUtil currentBundle], @"") code:999 userInfo:@{@"message": NSLocalizedStringFromTableInBundle(@"Current active user is not found...", nil, [TAPUtil currentBundle], @"")}];
                failure(localizedError);
            }
            
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
