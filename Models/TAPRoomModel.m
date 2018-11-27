//
//  TAPRoomModel.m
//  TapTalk
//
//  Created by Ritchie Nathaniel on 31/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPRoomModel.h"

@implementation TAPRoomModel

+ (TAPRoomModel *)createPersonalRoomIDWithOtherUser:(TAPUserModel *)otherUser {
    TAPRoomModel *newRoom = [TAPRoomModel new];
    
    NSInteger currentUserIDInteger = [[TAPChatManager sharedManager].activeUser.userID integerValue];
    NSInteger otherUserIDInteger = [otherUser.userID integerValue];
    
    NSString *roomID = @"";
    
    if (currentUserIDInteger <= otherUserIDInteger) {
        roomID = [NSString stringWithFormat:@"%li-%li", (long)currentUserIDInteger, (long)otherUserIDInteger];
    }
    else {
        roomID = [NSString stringWithFormat:@"%li-%li", (long)otherUserIDInteger, (long)currentUserIDInteger];
    }
    
    newRoom.roomID = roomID;
    newRoom.name = otherUser.fullname;
    newRoom.imageURL = otherUser.imageURL;
    newRoom.type = RoomTypePersonal;
    
    return newRoom;
}

+ (TAPRoomModel *)createGroupRoomIDWithID:(NSString *)groupID name:(NSString *)name imageURL:(TAPImageURLModel *)imageURL {
    TAPRoomModel *newRoom = [TAPRoomModel new];
    
    newRoom.roomID = groupID;
    newRoom.name = name;
    newRoom.imageURL = imageURL;
    newRoom.type = RoomTypeGroup;
    
    return newRoom;
}

@end
