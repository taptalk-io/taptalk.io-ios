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
    RoomTypeGroup = 2
};

@interface TAPRoomModel : TAPBaseModel

@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) TAPImageURLModel *imageURL;
@property (nonatomic) RoomType type;
@property (nonatomic, strong) NSString *color;

+ (TAPRoomModel *)createPersonalRoomIDWithOtherUser:(TAPUserModel *)otherUser;
+ (TAPRoomModel *)createGroupRoomIDWithID:(NSString *)groupID name:(NSString *)name imageURL:(NSString *)imageURL;

@end
