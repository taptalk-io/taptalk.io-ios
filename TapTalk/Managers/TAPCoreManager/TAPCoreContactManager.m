//
//  TAPCoreContactManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCoreContactManager.h"
#import "PowerTalk.h"

@interface TAPCoreContactManager () <TAPChatManagerDelegate>

@end

@implementation TAPCoreContactManager
#pragma mark - Lifecycle
+ (TAPCoreContactManager *)sharedManager {
    
    //Check if only implement TAPUI, don't init the core manager
    TapTalkImplentationType implementationType = [[TapTalk sharedInstance] getTapTalkImplementationType];
    if (implementationType == TapTalkImplentationTypeUI) {
        return nil;
    }
    
    static TAPCoreContactManager *sharedManager = nil;
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

#pragma mark - TAPChatManagerDelegate
- (void)chatManagerDidReceiveBlockUser:(TAPUserModel *)user {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidBlockContact:)]) {
        [self.delegate tapTalkDidBlockContact:user];
    }
}

- (void)chatManagerDidReceiveUnblockUser:(TAPUserModel *)user {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidUnblockContact:)]) {
        [self.delegate tapTalkDidUnblockContact:user];
    }
}

#pragma mark - Custom Method
- (void)getAllUserContactsWithSuccess:(void (^)(NSArray <TAPUserModel *>*userArray))success
                              failure:(void (^)(NSError *error))failure {
    [TAPDataManager getDatabaseAllContactSortBy:@"fullname" success:^(NSArray *resultArray) {
        success(resultArray);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)fetchAllUserContactsFromServerWithSuccess:(void (^)(NSArray <TAPUserModel *>*userArray))success
                                          failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIGetContactList:^(NSArray *responseContacts) {
        NSMutableArray<NSString *> *contactIDs = [NSMutableArray array];
        for (TAPUserModel *user in responseContacts) {
            [contactIDs addObject:user.userID];
        }
        [self getAllUserContactsWithSuccess:^(NSArray<TAPUserModel *> * _Nonnull localContacts) {
            NSMutableArray<TAPUserModel *> *updatedContacts = [responseContacts mutableCopy];
            for (TAPUserModel *user in localContacts) {
                if (![contactIDs containsObject:user.userID]) {
                    user.isContact = NO;
                    [updatedContacts addObject:user];
                }
            }
            [[TAPContactManager sharedManager] addContactWithUserArray:updatedContacts saveToDatabase:YES];
            success(responseContacts);
        }
        failure:^(NSError * _Nonnull error) {
            success(responseContacts);
        }];
    }
    failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (TAPUserModel *)getLocalUserDataWithUserID:(NSString *)userID {
    TAPUserModel *activeUser = [[TapTalk sharedInstance] getTapTalkActiveUser];
    if ([userID isEqualToString:activeUser.userID]) {
        return  activeUser;
    }
    return [[TAPContactManager sharedManager] getUserWithUserID:userID];
}

- (void)getUserDataWithUserID:(NSString *)userID
                      success:(void (^)(TAPUserModel *user))success
                      failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetUserByUserID:userID success:^(TAPUserModel *user) {
        [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:YES saveActiveUser:YES];
        success(user);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getUserDataWithXCUserID:(NSString *)xcUserID
                        success:(void (^)(TAPUserModel *user))success
                        failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetUserByXCUserID:xcUserID success:^(TAPUserModel *user) {
        [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:YES saveActiveUser:YES];
        success(user);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)saveUserData:(TAPUserModel *)user {
    [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:YES saveActiveUser:NO];
}

- (void)addToTapTalkContactsWithUserID:(NSString *)userID
                               success:(void (^)(void))success
                               failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIAddContactWithUserID:userID success:^(NSString *message, TAPUserModel *user) {
        [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:YES saveActiveUser:NO];
        success();
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)addToTapTalkContactsWithPhoneNumber:(NSString *)phoneNumber
                                    success:(void (^)(void))success
                                    failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIAddContactWithPhones:@[phoneNumber] success:^(NSArray *users) {
        if ([users count] != 0) {
            [[TAPContactManager sharedManager] addContactWithUserArray:users saveToDatabase:YES];
        }
        success();
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)removeFromTapTalkContactsWithUserID:(NSString *)userID
                                    success:(void (^)(NSString *successMessage))success
                                    failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIRemoveContactWithUserID:userID success:^(NSString *message) {
        [[TAPContactManager sharedManager] removeFromContactsWithUserID:userID];
        success(message);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)searchLocalContactsByName:(NSString *)keyword
                          success:(void (^)(NSArray <TAPUserModel *>*userArray))success
                          failure:(void (^)(NSError *error))failure {
    
    NSString *queryClause = [NSString stringWithFormat:@"fullname CONTAINS[c] \'%@\'", keyword];
    [TAPDatabaseManager loadDataFromTableName:@"TAPContactRealmModel"
                             whereClauseQuery:queryClause
                             sortByColumnName:@"fullname"
                                  isAscending:YES
                                      success:^(NSArray *resultArray) {
        
        NSMutableArray <TAPUserModel *> *searchResultArray = [NSMutableArray array];
        for (NSInteger count = 0; count < [resultArray count]; count++) {
            NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[resultArray objectAtIndex:count]];
            TAPUserModel *user = [TAPDataManager userModelFromDictionary:databaseDictionary];
            [searchResultArray addObject:user];
        }
        success(searchResultArray);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)updateActiveUserBio:(NSString *)bio
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIUpdateBio:bio success:^(TAPUserModel *user) {
        
        success(user);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getGroupsInCommon:(NSString *)userID
                    success:(void (^)(NSArray<TAPRoomModel *> *groupRooms))success
                    failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIGetGroupsInCommon:userID success:^(NSMutableArray<TAPRoomModel *> *groupsInCommonRoom) {
        success(groupsInCommonRoom);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)blockUserWithUserID:(NSString *)userID
                    success:(void (^)(TAPUserModel *blockedUser))success
                    failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIBlockUser:userID success:^(TAPUserModel *blockedUser) {
        [[TAPContactManager sharedManager] removeFromContactsWithUserID:userID];
        if ([self.delegate respondsToSelector:@selector(tapTalkDidBlockContact:)]) {
            [self.delegate tapTalkDidBlockContact:blockedUser];
        }
        success(blockedUser);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)unblockUserWithUserID:(NSString *)userID
                      success:(void (^)(TAPUserModel *unblockedUser))success
                      failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIUnblockUser:userID success:^(BOOL isSuccess) {
        [self fetchAllUserContactsFromServerWithSuccess:^(NSArray<TAPUserModel *> * _Nonnull userArray) {
            [self finishUnblockUser:userID success:success];
        }
        failure:^(NSError * _Nonnull error) {
            [self finishUnblockUser:userID success:success];
        }];
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)finishUnblockUser:(NSString *)userID
                  success:(void (^)(TAPUserModel *unblockedUser))success {
    
    TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:userID];
    if ([self.delegate respondsToSelector:@selector(tapTalkDidUnblockContact:)]) {
        [self.delegate tapTalkDidUnblockContact:user];
    }
    success(user);
}

- (void)getBlockedUserList:(void (^)(NSArray<TAPUserModel *> *blockedUserList))success
                    failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetBlockedUserList:^(NSArray<TAPUserModel *> *blockedUserList) {
        success(blockedUserList);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getBlockedUserIDs:(void (^)(NSArray<NSString *> *blockedUserIDs))success
                    failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetBlockedUserIDs:^(NSArray<NSString *> *blockedUserIDs) {
        success(blockedUserIDs);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)reportUser:(NSString *)userID
          category:(NSString *)category
   isOtherCategory:(BOOL)isOtherCategory
            reason:(NSString *)reason
           success:(void (^)(BOOL isSuccess))success
           failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIReportUser:userID category:category isOtherCategory:isOtherCategory reason:reason success:^(BOOL isSuccess) {
        success(isSuccess);
    } failure:^(NSError *error) {
        
    }];
}

- (void)reportMessage:(NSString *)messageID
               roomID:(NSString *)roomID
          category:(NSString *)category
   isOtherCategory:(BOOL)isOtherCategory
            reason:(NSString *)reason
           success:(void (^)(BOOL isSuccess))success
           failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIReportMessage:messageID roomID:roomID category:category isOtherCategory:isOtherCategory reason:reason success:^(BOOL isSuccess) {
        success(isSuccess);
    } failure:^(NSError *error) {
        
    }];
}
@end
