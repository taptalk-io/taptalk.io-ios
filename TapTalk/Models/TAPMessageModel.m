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
+ (instancetype)createMessageWithUser:(TAPUserModel *)user room:(TAPRoomModel *)room body:(NSString *)body type:(TAPChatMessageType)type {
    TAPMessageModel *messageForReturn = [[TAPMessageModel alloc] init];
    
    //DV Note - Set message ID to string 0 because server accepted as an integer, so empty string will cause a trouble in server
    messageForReturn.messageID = @"0";
    //END DV Temp
    
    messageForReturn.user = user;
    messageForReturn.room = room;
    messageForReturn.type = type;
    messageForReturn.body = body;
    messageForReturn.localID = [messageForReturn generateLocalIDwithLength:32];
    messageForReturn.isSending = YES;
    
    //Obtain other user ID
    NSString *roomID = room.roomID;
    roomID = [TAPUtil nullToEmptyString:roomID];
    
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    NSString *currentUserID = currentUser.userID;
    currentUserID = [TAPUtil nullToEmptyString:currentUserID];
    
    NSString *otherUserID = @"";
    NSArray *userIDArray = [roomID componentsSeparatedByString:@"-"];
    
    for(NSString *userID in userIDArray) {
        if(![userID isEqualToString:currentUserID]) {
            otherUserID = userID;
        }
    }
    
    //If group, recipient ID is group ID
    messageForReturn.recipientID = otherUserID;
    
    NSDate *date = [NSDate date];
    double createdDate = [date timeIntervalSince1970] * 1000.0f;
    messageForReturn.created = [NSNumber numberWithLong:createdDate];
    
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
    newModel.type = self.type;
    newModel.body = self.body;
    newModel.room = self.room;
    newModel.recipientID = self.recipientID;
    newModel.created = self.created;
    newModel.updated = self.updated;
    newModel.user = self.user;
    newModel.isDeleted = self.isDeleted;
    newModel.isSending = self.isSending;
    newModel.isFailedSend = self.isFailedSend;
    newModel.isRead = self.isRead;
    newModel.isDelivered = self.isDelivered;
    newModel.isHidden = self.isHidden;
    
    return newModel;
}

@end
