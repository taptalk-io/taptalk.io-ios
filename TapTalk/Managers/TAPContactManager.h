//
//  TAPContactManager.h
//  TapTalk
//
//  Created by Cundy Sunardy on 05/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface TAPContactManager : NSObject

+ (TAPContactManager *)sharedManager;

- (void)addContactWithUserModel:(TAPUserModel *)user saveToDatabase:(BOOL)save;
- (TAPUserModel *)getUserWithUserID:(NSString *)userID;
- (void)populateContactFromDatabase;
- (void)saveContactToDatabase;
- (void)saveUserCountryCode:(NSString *)countryCode;
- (void)setContactPermissionAsked;
- (BOOL)isContactPermissionAsked;
- (NSString *)getUserCountryCode;
- (BOOL)checkUserExistWithPhoneNumber:(NSString *)phoneNumberWithCode;

@end

NS_ASSUME_NONNULL_END
