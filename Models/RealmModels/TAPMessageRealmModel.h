//
//  TAPMessageRealmModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 28/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseRealmModel.h"

@interface TAPMessageRealmModel : TAPBaseRealmModel

@property (nonatomic, strong) NSString *messageID;
@property (nonatomic, strong) NSString *localID;
@property (nonatomic, strong) NSString *filterID;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *recipientID;
@property (nonatomic) TAPChatMessageType type;
@property (nonatomic, strong) NSNumber<RLMDouble> *created;
@property (nonatomic, strong) NSNumber<RLMDouble> *updated;
@property (nonatomic, strong) NSNumber<RLMDouble> *deleted;
@property (nonatomic, strong) NSNumber<RLMBool> *isRead;
@property (nonatomic, strong) NSNumber<RLMBool> *isDelivered;
@property (nonatomic, strong) NSNumber<RLMBool> *isHidden;
@property (nonatomic, strong) NSNumber<RLMBool> *isDeleted;
@property (nonatomic, strong) NSNumber<RLMBool> *isSending;
@property (nonatomic, strong) NSNumber<RLMBool> *isFailedSend;

//Room
@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *roomColor;
@property (nonatomic, strong) NSString *roomImage;
@property (nonatomic) RoomType roomType;

//User
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *xcUserID;
@property (nonatomic, strong) NSString *userFullName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *userImage;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userPhone;
@property (nonatomic, strong) NSString *userRole;
@property (strong, nonatomic) NSNumber<RLMDouble> *lastLogin;
@property (strong, nonatomic) NSNumber<RLMBool> *requireChangePassword;
@property (strong, nonatomic) NSNumber<RLMDouble> *userCreated;
@property (strong, nonatomic) NSNumber<RLMDouble> *userUpdated;

@end
