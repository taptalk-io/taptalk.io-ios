//
//  TAPMessageModel.m
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/8/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPMessageModel.h"

@implementation TAPMessageModel

#pragma mark - Lifecycle

#pragma mark - Custom Method
+ (instancetype)createMessageWithUser:(TAPUserModel *)user created:(NSNumber *)created room:(TAPRoomModel *)room body:(NSString *)body type:(TAPChatMessageType)type {
    TAPMessageModel *messageForReturn = [[TAPMessageModel alloc] init];
    
    //DV Note - Set message ID to string 0 because server accepted as an integer, so empty string will cause a trouble in server
    messageForReturn.messageID = @"0";
    
    messageForReturn.user = user;
    messageForReturn.room = room;
    messageForReturn.type = type;
    messageForReturn.body = body;
    messageForReturn.localID = [messageForReturn generateLocalIDwithLength:32];
    messageForReturn.created = created;
    messageForReturn.isSending = YES;
    messageForReturn.isDeleted = NO;
    messageForReturn.isFailedSend = NO;
    messageForReturn.isRead = NO;
    messageForReturn.isDelivered = NO;
    messageForReturn.isHidden = NO;
    
    //Obtain other user ID
    NSString *roomID = room.roomID;
    roomID = [TAPUtil nullToEmptyString:roomID];
    
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    NSString *currentUserID = currentUser.userID;
    currentUserID = [TAPUtil nullToEmptyString:currentUserID];
    
    if (room.type == RoomTypePersonal) {
        NSString *otherUserID = @"";
        NSArray *userIDArray = [roomID componentsSeparatedByString:@"-"];
        
        for (NSString *userID in userIDArray) {
            if (![userID isEqualToString:currentUserID]) {
                otherUserID = userID;
            }
        }
        
        messageForReturn.recipientID = otherUserID;
    }
    else {
        //If group or channel set recipientID to 0
        messageForReturn.recipientID = @"0";
    }
    
    return messageForReturn;
}

+ (instancetype)createMessageWithUser:(TAPUserModel *)user room:(TAPRoomModel *)room body:(NSString *)body type:(TAPChatMessageType)type {
    NSDate *date = [NSDate date];
    double createdDate = [date timeIntervalSince1970] * 1000.0f;
    NSNumber *createdDateNumber = [NSNumber numberWithLong:createdDate];
    
    TAPMessageModel *messageForReturn = [[TAPMessageModel alloc] init];
    messageForReturn = [self createMessageWithUser:user created:createdDateNumber room:room body:body type:type];
    return messageForReturn;
}

- (NSString *)generateLocalIDwithLength:(int)length {
    NSString* AB = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [AB characterAtIndex: arc4random_uniform([AB length])]];
    }
    
    return randomString;
}

- (TAPMessageModel *)copyMessageModel {
    TAPMessageModel *newModel = [TAPMessageModel new];
       
    newModel.messageID = self.messageID;
    newModel.localID = self.localID;
    newModel.filterID = self.filterID;
    newModel.type = self.type;
    newModel.body = self.body;
    newModel.room = self.room;
    newModel.recipientID = self.recipientID;
    newModel.created = self.created;
    newModel.updated = self.updated;
    newModel.deleted = self.deleted;
    newModel.user = self.user;
    newModel.quote = self.quote;
    newModel.replyTo = self.replyTo;
    newModel.forwardFrom = self.forwardFrom;
    newModel.action = self.action;
    newModel.target = self.target;
    newModel.data = self.data;
    newModel.isDeleted = self.isDeleted;
    newModel.isSending = self.isSending;
    newModel.isFailedSend = self.isFailedSend;
    newModel.isRead = self.isRead;
    newModel.isDelivered = self.isDelivered;
    newModel.isHidden = self.isHidden;
    
    return newModel;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    if([[dict objectForKey:@"data"] isKindOfClass:[NSString class]]) {
        //convert data from JSONString to NSDictionary
        NSDictionary *data = [TAPUtil jsonObjectFromString:[dict objectForKey:@"data"]];
        data = [TAPUtil nullToEmptyDictionary:data];
        
        NSMutableDictionary *mutableDictionary = [dict mutableCopy];
        [mutableDictionary setObject:data forKey:@"data"];
        
        TAPMessageModel *message = [super initWithDictionary:mutableDictionary error:err];
        return message;
    }
    return [super initWithDictionary:dict error:err];
}
@end
