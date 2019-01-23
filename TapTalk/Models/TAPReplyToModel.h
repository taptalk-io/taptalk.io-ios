//
//  TAPReplyToModel.h
//  TapTalk
//
//  Created by Cundy Sunardy on 09/01/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"
#import "Configs.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPReplyToModel : TAPBaseModel

@property (nonatomic, strong) NSString *messageID;
@property (nonatomic, strong) NSString *localID;
@property (nonatomic) TAPChatMessageType messageType;

@end

NS_ASSUME_NONNULL_END
