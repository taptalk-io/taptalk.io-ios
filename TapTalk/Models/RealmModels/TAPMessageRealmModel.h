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
@property (nonatomic, strong) NSString *xcRoomID;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *roomColor;
@property (nonatomic, strong) NSString *roomImage;
@property (nonatomic) RoomType roomType;
@property (strong, nonatomic) NSNumber<RLMBool> *roomIsDeleted; //added in schema 5 migration
@property (strong, nonatomic) NSNumber<RLMBool> *roomIsLocked; //added in schema 6 migration
@property (strong, nonatomic) NSNumber<RLMDouble> *roomDeleted; //added in schema 5 migration

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
@property (strong, nonatomic) NSNumber<RLMDouble> *userDeleted; //added in schema 3 migration

//Data
@property (nonatomic, strong) NSString *data; //contains JSONString converted from NSDictionary

//Quote
@property (nonatomic, strong) NSString *quoteTitle;
@property (nonatomic, strong) NSString *quoteContent;
@property (nonatomic, strong) NSString *quoteFileID; //Image from TapTalk
@property (nonatomic, strong) NSString *quoteImageURL; //Image from Client
@property (nonatomic, strong) NSString *quoteFileType; //Image from Client

//ReplyTo
@property (nonatomic, strong) NSString *replyToMessageID;
@property (nonatomic, strong) NSString *replyToLocalID;
@property (nonatomic, strong) NSString *replyToUserID;
@property (nonatomic, strong) NSString *replyToXcUserID;
@property (nonatomic, strong) NSString *replyToFullname;
@property (nonatomic) TAPChatMessageType replyMessageType;

//ForwardFrom
@property (nonatomic, strong) NSString *forwardFromUserID;
@property (nonatomic, strong) NSString *forwardFromXcUserID;
@property (nonatomic, strong) NSString *forwardFromFullname;
@property (nonatomic, strong) NSString *forwardFromMessageID;
@property (nonatomic, strong) NSString *forwardFromLocalID;

//Group Target
@property (nonatomic, strong) NSString *action; //added in schema 4 migration
@property (nonatomic, strong) NSString *groupTargetType; //added in schema 4 migration
@property (strong, nonatomic) NSString *groupTargetID; //added in schema 4 migration
@property (strong, nonatomic) NSString *groupTargetXCID; //added in schema 4 migration
@property (strong, nonatomic) NSString *groupTargetName; //added in schema 4 migration

@end
