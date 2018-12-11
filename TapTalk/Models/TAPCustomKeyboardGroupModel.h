//
//  TAPCustomKeyboardGroupModel.h
//  TapTalk
//
//  Created by Cundy Sunardy on 30/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"
#import "TAPCustomKeyboardItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPCustomKeyboardGroupModel : TAPBaseModel

@property (strong, nonatomic) NSString *recipientRoleID;
@property (strong, nonatomic) NSString *senderRoleID;
@property (strong, nonatomic) NSArray<TAPCustomKeyboardItemModel *> *customKeyboardItemArray;

@end

NS_ASSUME_NONNULL_END
