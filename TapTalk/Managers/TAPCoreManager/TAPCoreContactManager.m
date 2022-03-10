//
//  TAPCoreContactManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCoreContactManager.h"

@interface TAPCoreContactManager ()

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

@end
