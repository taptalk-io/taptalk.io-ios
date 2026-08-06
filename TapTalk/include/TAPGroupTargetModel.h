//
//  TAPGroupTargetModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 09/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPGroupTargetModel : TAPBaseModel

//Use to store group target user
@property (strong, nonatomic) NSString *targetType;
@property (strong, nonatomic) NSString *targetID;
@property (strong, nonatomic) NSString *targetXCID;
@property (strong, nonatomic) NSString *targetName;

@end

NS_ASSUME_NONNULL_END
