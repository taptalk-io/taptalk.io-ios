//
//  TAPUserRoleModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 26/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPUserRoleModel : TAPBaseModel
@property (strong, nonatomic) NSString *userRoleID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *iconURL;
@end

NS_ASSUME_NONNULL_END
