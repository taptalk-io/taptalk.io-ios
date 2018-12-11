//
//  TAPRoomListModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 01/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"
#import "TAPMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPRoomListModel : TAPBaseModel

@property (strong, nonatomic) TAPMessageModel *lastMessage;
@property (nonatomic) NSInteger numberOfUnreadMessages;

@end

NS_ASSUME_NONNULL_END
