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

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    TAPRoomModel *room = [super initWithDictionary:dict error:err];
    NSArray *participantsArray = [dict objectForKey:@"participants"];
    NSMutableArray *participantsModelArray = [NSMutableArray array];
    for (NSDictionary *userDictionary in participantsArray) {
        TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:userDictionary error:err];
        [participantsModelArray addObject:user];
    }
    room.participants = participantsModelArray;
    return room;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [[super toDictionary] mutableCopy];
    NSMutableArray *participantsArray = [NSMutableArray array];
    for(TAPUserModel *user in self.participants) {
            [participantsArray addObject:[user toDictionary]];
    }
    [dictionary setObject:participantsArray forKey:@"participants"];
    return dictionary;
}

//used to save model to preference
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.roomID forKey:@"roomID"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeInteger:self.type forKey:@"type"];
    [encoder encodeObject:self.color forKey:@"color"];
    [encoder encodeBool:self.isDeleted forKey:@"isDeleted"];
    [encoder encodeBool:self.isDeleted forKey:@"isLocked"];
    [encoder encodeObject:self.deleted forKey:@"deleted"];
    [encoder encodeObject:self.participants forKey:@"participants"];
    [encoder encodeObject:self.admins forKey:@"admins"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.roomID = [decoder decodeObjectForKey:@"roomID"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.type = [decoder decodeIntegerForKey:@"type"];
        self.color = [decoder decodeObjectForKey:@"color"];
        self.isDeleted = [decoder decodeBoolForKey:@"isDeleted"];
        self.isLocked = [decoder decodeBoolForKey:@"isLocked"];
        self.deleted = [decoder decodeObjectForKey:@"deleted"];
        self.participants = [decoder decodeObjectForKey:@"participants"];
        self.admins = [decoder decodeObjectForKey:@"admins"];
    }
    return self;
}

@end
