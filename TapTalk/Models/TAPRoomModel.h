//
//  TAPRoomModel.h
//  TapTalk
//
//  Created by Ritchie Nathaniel on 31/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"
#import "TAPImageURLModel.h"
#import "TAPUserModel.h"

typedef NS_ENUM(NSInteger, RoomType) {
    RoomTypePersonal = 1,
    RoomTypeGroup = 2,
    RoomTypeChannel = 3,
    RoomTypeTransaction = 4
};

@interface TAPRoomModel : TAPBaseModel

@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) NSString *xcRoomID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) TAPImageURLModel *imageURL;
@property (nonatomic) RoomType type;
@property (nonatomic, strong) NSString *color;
@property (nonatomic) BOOL isDeleted;
@property (nonatomic) BOOL isLocked;
@property (strong, nonatomic) NSNumber *deleted;
@property (strong, nonatomic) NSArray <TAPUserModel *> *participants;
@property (strong, nonatomic) NSArray *admins;

+ (TAPRoomModel *)createPersonalRoomIDWithOtherUser:(TAPUserModel *)otherUser;
+ (TAPRoomModel *)createGroupRoomIDWithID:(NSString *)groupID name:(NSString *)name imageURL:(NSString *)imageURL;

@end
