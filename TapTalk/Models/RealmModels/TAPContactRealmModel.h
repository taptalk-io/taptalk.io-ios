//
//  TAPContactRealmModel.h
//  TapTalk
//
//  Created by Welly Kencana on 19/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseRealmModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPContactRealmModel : TAPBaseRealmModel

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *xcUserID;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *phoneWithCode; //Added in DB config version 1 via migration
@property (nonatomic, strong) NSString *countryCallingCode;  //Added in DB config version 1 via migration
@property (nonatomic, strong) NSString *countryID; //Added in DB config version 1 via migration

//User Role
@property (strong, nonatomic) NSString *userRoleCode;
@property (strong, nonatomic) NSString *userRoleName;
@property (strong, nonatomic) NSString *userRoleIconURL;

@property (nonatomic, strong) NSNumber<RLMDouble> *lastLogin;
@property (nonatomic, strong) NSNumber<RLMDouble> *lastActivity;
@property (nonatomic) BOOL requireChangePassword;
@property (nonatomic, strong) NSNumber<RLMDouble> *created;
@property (nonatomic, strong) NSNumber<RLMDouble> *updated;
@property (nonatomic, strong) NSNumber<RLMBool> *isRequestPending;
@property (nonatomic, strong) NSNumber<RLMBool> *isRequestAccepted;
@property (nonatomic, strong) NSNumber<RLMBool> *isContact;

@end

NS_ASSUME_NONNULL_END
