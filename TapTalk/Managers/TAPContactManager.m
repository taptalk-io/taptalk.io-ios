//
//  TAPContactManager.m
//  TapTalk
//
//  Created by Cundy Sunardy on 05/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPContactManager.h"

@interface TAPContactManager() <TAPConnectionManagerDelegate>

@property (strong, nonatomic) NSMutableDictionary *contactUserDictionary;

- (void)saveContactToDatabase;
- (void)populateContactFromDatabase;

@end

@implementation TAPContactManager
#pragma mark - Life Cycle
+ (TAPContactManager *)sharedManager {
    static TAPContactManager *sharedManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[TAPContactManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _contactUserDictionary = [[NSMutableDictionary alloc] init];
        [[TAPConnectionManager sharedManager] addDelegate:self];
    }
    
    return self;
}

- (void)dealloc {
    //Remove Connection Manager delegate
    [[TAPConnectionManager sharedManager] removeDelegate:self];
}

#pragma mark - Delegate
#pragma mark TAPConnectionManager
- (void)connectionManagerDidConnected {
    [self populateContactFromDatabase];
}

- (void)connectionManagerDidDisconnectedWithCode:(NSInteger)code reason:(NSString *)reason cleanClose:(BOOL)clean {
    [self saveContactToDatabase];
}

#pragma mark - Custom Method
- (void)addContactWithUserModel:(TAPUserModel *)user saveToDatabase:(BOOL)save {
    TAPUserModel *savedUser = [self.contactUserDictionary objectForKey:user.userID];
    if(savedUser != nil && savedUser.isContact) {
        user.isContact = YES;
    }
    
    TAPUserModel *activeUser = [TAPDataManager getActiveUser];
    if(user.userID != activeUser.userID) {
        //if user != self set to Dictionary
        [self.contactUserDictionary setObject:user forKey:user.userID];
        
        if(save) {
            //save user to database directly
            NSArray *userDataArray = @[user];
            [TAPDataManager updateOrInsertDatabaseContactWithData:userDataArray success:^{
                
            } failure:^(NSError *error) {
                
            }];
        }
    }
}

- (TAPUserModel *)getUserWithUserID:(NSString *)userID {
    TAPUserModel *user = [self.contactUserDictionary objectForKey:userID];
    return user;
}

- (void)saveContactToDatabase {
    NSArray *userDataArray = [self.contactUserDictionary allValues];
    [TAPDataManager updateOrInsertDatabaseContactWithData:userDataArray success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)populateContactFromDatabase {
    [TAPDataManager getDatabaseAllUserSortBy:@"fullname" success:^(NSArray *resultArray) {
        for (TAPUserModel *user in resultArray) {
            [self.contactUserDictionary setObject:user forKey:user.userID];
        }
    } failure:^(NSError *error) {
        
    }];
}

@end
