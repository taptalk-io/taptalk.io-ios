//
//  TAPTypingModel.h
//  TapTalk
//
//  Created by Cundy Sunardy on 07/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPTypingModel : TAPBaseModel

@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) TAPUserModel *user;

@end

NS_ASSUME_NONNULL_END
