//
//  TAPGroupModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 24/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPGroupModel : TAPBaseModel
@property (strong, nonatomic) NSArray *groupMembers;
@property (strong, nonatomic) NSString *groupName;
@property (strong, nonatomic) NSString *groupImage;
@end

NS_ASSUME_NONNULL_END
