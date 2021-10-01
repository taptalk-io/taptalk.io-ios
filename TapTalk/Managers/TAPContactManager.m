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
@property (strong, nonatomic) NSMutableDictionary *phoneUserDictionary;
@property (strong, nonatomic) NSString *userCountryCode;
@property (nonatomic) BOOL contactSyncPermissionAsked;

- (void)populateCountryCodeFromPreference;
- (void)populateContactPermissionFromPreference;

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
        _phoneUserDictionary = [[NSMutableDictionary alloc] init];
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

- (void)addContactWithUserModel:(TAPUserModel *)user saveToDatabase:(BOOL)save saveActiveUser:(BOOL)saveActiveUser {
    TAPUserModel *savedUser = [self.contactUserDictionary objectForKey:user.userID];
    if(savedUser != nil && savedUser.isContact) {
        user.isContact = YES;
    }
    
    TAPUserModel *activeUser = [TAPDataManager getActiveUser];
    if(user.userID != activeUser.userID && user.userID != nil) {
        //if user != self set to Dictionary
        
        TAPUserModel *currentSavedUser = [self.contactUserDictionary objectForKey:user.userID];
        if ([user.updated longValue] < [currentSavedUser.updated longValue]) {
            return;
        }
        
        [self.contactUserDictionary setObject:user forKey:user.userID];
        [self.phoneUserDictionary setObject:user forKey:user.phoneWithCode];
        
        if(save) {
            //save user to database directly
            NSArray *userDataArray = @[user];
            [TAPDataManager updateOrInsertDatabaseContactWithData:userDataArray success:^{
                
            } failure:^(NSError *error) {
                
            }];
        }
    }
    else {
        //update active user data
        if (!saveActiveUser) {
            return;
        }
        else if (user.userID != nil) {
            TAPUserModel *currentSavedUser = [self.contactUserDictionary objectForKey:user.userID];
            if ([user.updated longValue] < [currentSavedUser.updated longValue]) {
                return;
            }

            [TAPDataManager setActiveUser:user];
        }
    }
}

- (void)addContactWithUserArray:(NSArray <TAPUserModel *> *)userArray saveToDatabase:(BOOL)save {
    
    NSMutableArray *userDataArray = [NSMutableArray array];
    for (TAPUserModel *user in userArray) {
        TAPUserModel *savedUser = [self.contactUserDictionary objectForKey:user.userID];
        if(savedUser != nil && savedUser.isContact) {
            user.isContact = YES;
        }
        
        TAPUserModel *activeUser = [TAPDataManager getActiveUser];
        if(user.userID != activeUser.userID && user.userID != nil) {
            //if user != self set to Dictionary
            
            TAPUserModel *currentSavedUser = [self.contactUserDictionary objectForKey:user.userID];
            if ([user.updated longValue] < [currentSavedUser.updated longValue]) {
                return;
            }
            
            [self.contactUserDictionary setObject:user forKey:user.userID];
            [self.phoneUserDictionary setObject:user forKey:user.phoneWithCode];
            
            if (save) {
                [userDataArray addObject:user];
            }
        }
        else {
            //update active user data
            if (user.userID != nil) {
                TAPUserModel *currentSavedUser = [self.contactUserDictionary objectForKey:user.userID];
                if ([user.updated longValue] < [currentSavedUser.updated longValue]) {
                    return;
                }
                
                [TAPDataManager setActiveUser:user];
            }
        }
    }
    
    if(save) {
        //save user to database directly
        [TAPDataManager updateOrInsertDatabaseContactWithData:userDataArray success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
}

- (TAPUserModel *)getUserWithUserID:(NSString *)userID {
    TAPUserModel *user = [self.contactUserDictionary objectForKey:userID];
    return user;
}
         
 - (BOOL)checkUserExistWithPhoneNumber:(NSString *)phoneNumberWithCode {
     if ([self.phoneUserDictionary objectForKey:phoneNumberWithCode]) {
         return YES;
     }
     return NO;
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
            if (user.phoneWithCode != nil && ![user.phoneWithCode isEqualToString:@""]) {
                [self.phoneUserDictionary setObject:user forKey:user.phoneWithCode];
            }
        }
    } failure:^(NSError *error) {
        
    }];
    [[TAPContactManager sharedManager] populateCountryCodeFromPreference];
    [[TAPContactManager sharedManager] populateContactPermissionFromPreference];
}

- (void)saveUserCountryCode:(NSString *)countryCode {
    _userCountryCode = countryCode;
    [[NSUserDefaults standardUserDefaults] setSecureObject:countryCode forKey:TAP_PREFS_USER_COUNTRY_CODE];
    [[NSUserDefaults standardUserDefaults] synchronize];}

- (NSString *)getUserCountryCode {
    return [TAPUtil nullToEmptyString:self.userCountryCode];
}

- (void)populateCountryCodeFromPreference {
    NSString *countryCode = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_USER_COUNTRY_CODE valid:nil];
    countryCode = [TAPUtil nullToEmptyString:countryCode];
    _userCountryCode = countryCode;
}

- (void)setContactPermissionAsked {
    _contactSyncPermissionAsked = YES;
    [[NSUserDefaults standardUserDefaults] setSecureBool:YES forKey:TAP_PREFS_CONTACT_PERMISSION_ASKED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isContactPermissionAsked {
    return self.contactSyncPermissionAsked;
}

- (void)populateContactPermissionFromPreference {
    BOOL contactPermissionAsked = [[NSUserDefaults standardUserDefaults] secureBoolForKey:TAP_PREFS_CONTACT_PERMISSION_ASKED valid:nil];
    _contactSyncPermissionAsked = contactPermissionAsked;
}

- (void)clearContactManagerData {
    [self.contactUserDictionary removeAllObjects];
    [self.phoneUserDictionary removeAllObjects];
    self.userCountryCode = @"";
    _contactSyncPermissionAsked = NO;
}

- (void)removeFromContactsWithUserID:(NSString *)userID {
    if (userID == nil || [userID isEqualToString:@""]) {
        return;
    }
    TAPUserModel *user = [self.contactUserDictionary objectForKey:userID];
    if (user == nil) {
        return;
    }
    //Set isContact to NO
    user.isContact = NO;
    //Update dictionary
    [self.contactUserDictionary setObject:user forKey:userID];
    [self.phoneUserDictionary setObject:user forKey:user.phoneWithCode];
    //Update database
    [TAPDataManager updateOrInsertDatabaseContactWithData:@[user] success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

@end
