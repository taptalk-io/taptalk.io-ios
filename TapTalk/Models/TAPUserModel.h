//
//  TAPUserModel.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/8/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"
#import "TAPImageURLModel.h"
#import "TAPUserRoleModel.h"

@interface TAPUserModel : TAPBaseModel

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *xcUserID;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *phoneWithCode;
@property (nonatomic, strong) NSString *countryCallingCode;
@property (nonatomic, strong) NSString *countryID;
@property (nonatomic, strong) TAPImageURLModel *imageURL;
@property (nonatomic, strong) TAPUserRoleModel *userRole;
@property (strong, nonatomic) NSNumber *lastLogin;
@property (strong, nonatomic) NSNumber<Optional> *lastActivity;
@property (nonatomic) BOOL requireChangePassword;
@property (strong, nonatomic) NSNumber *created;
@property (strong, nonatomic) NSNumber *updated;
@property (strong, nonatomic) NSNumber *deleted;

//Optional
@property (nonatomic) BOOL isRequestPending;
@property (nonatomic) BOOL isRequestAccepted;
@property (nonatomic) BOOL isContact;
@property (nonatomic) BOOL isOnline;
@property (nonatomic) BOOL isEmailVerified;
@property (nonatomic) BOOL isPhoneVerified;

@end
