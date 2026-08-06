//
//  TAPOnlineStatusModel.h
//  TapTalk
//
//  Created by Cundy Sunardy on 05/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"
#import "TAPUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPOnlineStatusModel : TAPBaseModel

@property (nonatomic, strong) NSNumber *lastActive;
@property (nonatomic, strong) TAPUserModel *user;
@property (nonatomic) BOOL isOnline;

@end

NS_ASSUME_NONNULL_END
