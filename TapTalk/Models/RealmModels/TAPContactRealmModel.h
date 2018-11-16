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
//User Role
@property (strong, nonatomic) NSString *userRoleID;
@property (strong, nonatomic) NSString *userRoleName;
@property (strong, nonatomic) NSString *userRoleIconURL;

@property (nonatomic, strong) NSNumber<RLMDouble> *lastLogin;
@property (nonatomic, strong) NSNumber<RLMDouble> *lastActivity;
@property (nonatomic) BOOL requireChangePassword;
@property (nonatomic, strong) NSNumber<RLMDouble> *created;
@property (nonatomic, strong) NSNumber<RLMDouble> *updated;
@property (nonatomic, strong) NSNumber<RLMBool> *isRequestPending;
@property (nonatomic, strong) NSNumber<RLMBool> *isRequestAccepted;

@end

NS_ASSUME_NONNULL_END
