//
//  TAPDataManager.m
//  TapTalk
//
//  Created by Ritchie Nathaniel on 20/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPDataManager.h"
#import "TAPAPIManager.h"

#define kDatabaseTableMessage @"TAPMessageRealmModel"
#define kDatabaseTableRecentSearch @"TAPRecentSearchRealmModel"
#define kDatabaseTableContact @"TAPContactRealmModel"

@interface TAPDataManager()

@property (strong, nonatomic) NSLock *refreshTokenLock;
@property (nonatomic) BOOL isShouldRefreshToken;

@end

@implementation TAPDataManager

#pragma mark - Lifecycle
+ (TAPDataManager *)sharedManager {
    static TAPDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if(self) {
        //Add delegate to Connection Manager here
        _refreshTokenLock = [NSLock new];
    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    //Remove Connection Manager delegsate
}

#pragma mark - Convert
/*
 WK NOTE - THESE METHODS ARE CONVERTION FROM MODEL TO REALMMODEL
 FOR EXAMPLE:
 -> FROM messageRealmDictionary TO messageModel
 -> FROM messageModel TO messageRealmDictionary
 END NOTE
 */
#pragma mark From Dictionary
//WK NOTE - USUALLY USED ON GETDATABASE METHODS
+ (TAPMessageModel *)messageModelFromDictionary:(NSDictionary *)dictionary {
    dictionary = [TAPUtil nullToEmptyDictionary:dictionary];
    TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:dictionary error:nil];
    
    TAPRoomModel *room = [TAPRoomModel new];
    NSString *roomID = [dictionary objectForKey:@"roomID"];
    roomID = [TAPUtil nullToEmptyString:roomID];
    room.roomID = roomID;
    
    NSString *roomName = [dictionary objectForKey:@"roomName"];
    roomName = [TAPUtil nullToEmptyString:roomName];
    room.name = roomName;
    
    NSString *roomColor = [dictionary objectForKey:@"roomColor"];
    roomColor = [TAPUtil nullToEmptyString:roomColor];
    room.color = roomColor;
    
    TAPImageURLModel *roomImageURL = [TAPImageURLModel new];
    NSString *roomImageString = [dictionary objectForKey:@"roomImage"];
    if([roomImageString isEqualToString:@""] || roomImageString == nil) {
        roomImageURL.thumbnail = @"";
        roomImageURL.fullsize = @"";
    }
    else {
        NSDictionary *imageJSONDictionary = [TAPUtil jsonObjectFromString:roomImageString];
        NSString *thumbnail = [imageJSONDictionary objectForKey:@"thumbnail"];
        thumbnail = [TAPUtil nullToEmptyString:thumbnail];
        roomImageURL.thumbnail = thumbnail;
        
        NSString *fullsize = [imageJSONDictionary objectForKey:@"fullsize"];
        fullsize = [TAPUtil nullToEmptyString:fullsize];
        roomImageURL.fullsize = fullsize;
    }
    room.imageURL = roomImageURL;
    
    NSInteger roomType = [[dictionary objectForKey:@"roomType"] integerValue];
    room.type = roomType;
    message.room = room;
    
    TAPUserModel *user = [TAPUserModel new];
    NSString *userID = [dictionary objectForKey:@"userID"];
    userID = [TAPUtil nullToEmptyString:userID];
    user.userID = userID;
    
    NSString *xcUserID = [dictionary objectForKey:@"xcUserID"];
    xcUserID = [TAPUtil nullToEmptyString:xcUserID];
    user.xcUserID = xcUserID;
    
    NSString *userFullName = [dictionary objectForKey:@"userFullName"];
    userFullName = [TAPUtil nullToEmptyString:userFullName];
    user.fullname = userFullName;
    
    NSString *username = [dictionary objectForKey:@"username"];
    username = [TAPUtil nullToEmptyString:username];
    user.username = username;
    
    TAPImageURLModel *userImageURL = [TAPImageURLModel new];
    NSString *userImageString = [dictionary objectForKey:@"userImage"];
    if([userImageString isEqualToString:@""] || userImageString == nil) {
        userImageURL.thumbnail = @"";
        userImageURL.fullsize = @"";
    }
    else {
        NSDictionary *imageJSONDictionary = [TAPUtil jsonObjectFromString:userImageString];
        NSString *thumbnail = [imageJSONDictionary objectForKey:@"thumbnail"];
        thumbnail = [TAPUtil nullToEmptyString:thumbnail];
        userImageURL.thumbnail = thumbnail;
        
        NSString *fullsize = [imageJSONDictionary objectForKey:@"fullsize"];
        fullsize = [TAPUtil nullToEmptyString:fullsize];
        userImageURL.fullsize = fullsize;
    }
    user.imageURL = userImageURL;
    
    NSString *userEmail = [dictionary objectForKey:@"userEmail"];
    userEmail = [TAPUtil nullToEmptyString:userEmail];
    user.email = userEmail;
    
    NSString *userPhone = [dictionary objectForKey:@"userPhone"];
    userPhone = [TAPUtil nullToEmptyString:userPhone];
    user.phone = userPhone;
    
    TAPUserRoleModel *userRole = [TAPUserRoleModel new];
    NSString *userRoleString = [dictionary objectForKey:@"userRole"];
    if([userRoleString isEqualToString:@""] || userRoleString == nil) {
        userRole.userRoleID = @"";
        userRole.name = @"";
        userRole.iconURL = @"";
    }
    else {
        NSDictionary *userRoleJSONDictionary = [TAPUtil jsonObjectFromString:userRoleString];
        NSString *userRoleID = [userRoleJSONDictionary objectForKey:@"userRoleID"];
        userRoleID = [TAPUtil nullToEmptyString:userRoleID];
        userRole.userRoleID = userRoleID;
        
        NSString *name = [userRoleJSONDictionary objectForKey:@"name"];
        name = [TAPUtil nullToEmptyString:name];
        userRole.name = name;
        
        NSString *iconURL = [userRoleJSONDictionary objectForKey:@"iconURL"];
        iconURL = [TAPUtil nullToEmptyString:iconURL];
        userRole.iconURL = iconURL;
    }
    user.userRole = userRole;
    
    NSNumber *lastLogin = [dictionary objectForKey:@"lastLogin"];
    lastLogin = [TAPUtil nullToEmptyNumber:lastLogin];
    user.lastLogin = lastLogin;
    
    NSNumber *requireChangePassword = [dictionary objectForKey:@"requireChangePassword"];
    requireChangePassword = [TAPUtil nullToEmptyNumber:requireChangePassword];
    user.requireChangePassword = [requireChangePassword boolValue];
    
    NSNumber *userCreated = [dictionary objectForKey:@"userCreated"];
    userCreated = [TAPUtil nullToEmptyNumber:userCreated];
    user.created = userCreated;
    
    NSNumber *userUpdated = [dictionary objectForKey:@"userUpdated"];
    userUpdated = [TAPUtil nullToEmptyNumber:userUpdated];
    user.updated = userUpdated;
    message.user = user;
    
    return message;
}

+ (TAPMessageModel *)messageModelFromPayloadWithUserInfo:(NSDictionary *)dictionary {
    dictionary = [TAPUtil nullToEmptyDictionary:dictionary];
    TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:dictionary error:nil];
    
    NSDictionary *roomDictionary = [dictionary objectForKey:@"room"];
    TAPRoomModel *room = [TAPRoomModel new];
    NSString *roomID = [roomDictionary objectForKey:@"roomID"];
    roomID = [TAPUtil nullToEmptyString:roomID];
    room.roomID = roomID;
    
    NSString *roomName = [roomDictionary objectForKey:@"name"];
    roomName = [TAPUtil nullToEmptyString:roomName];
    room.name = roomName;
    
    NSString *roomColor = [roomDictionary objectForKey:@"color"];
    roomColor = [TAPUtil nullToEmptyString:roomColor];
    room.color = roomColor;
    
    TAPImageURLModel *roomImageURL = [TAPImageURLModel new];
    NSDictionary *roomImageDictionary = [roomDictionary objectForKey:@"imageURL"];
    roomImageDictionary = [TAPUtil nullToEmptyDictionary:roomImageDictionary];
    
    NSString *thumbnail = [roomImageDictionary objectForKey:@"thumbnail"];
    thumbnail = [TAPUtil nullToEmptyString:thumbnail];
    roomImageURL.thumbnail = thumbnail;
        
    NSString *fullsize = [roomImageDictionary objectForKey:@"fullsize"];
    fullsize = [TAPUtil nullToEmptyString:fullsize];
    roomImageURL.fullsize = fullsize;

    room.imageURL = roomImageURL;
    
    NSInteger roomType = [[roomDictionary objectForKey:@"type"] integerValue];
    room.type = roomType;
    message.room = room;
    
    NSDictionary *userDictionary = [dictionary objectForKey:@"user"];
    TAPUserModel *user = [TAPUserModel new];
    NSString *userID = [userDictionary objectForKey:@"userID"];
    userID = [TAPUtil nullToEmptyString:userID];
    user.userID = userID;
    
    NSString *xcUserID = [userDictionary objectForKey:@"xcUserID"];
    xcUserID = [TAPUtil nullToEmptyString:xcUserID];
    user.xcUserID = xcUserID;
    
    NSString *userFullName = [userDictionary objectForKey:@"fullname"];
    userFullName = [TAPUtil nullToEmptyString:userFullName];
    user.fullname = userFullName;
    
    NSString *username = [userDictionary objectForKey:@"username"];
    username = [TAPUtil nullToEmptyString:username];
    user.username = username;
    
    TAPImageURLModel *userImageURL = [TAPImageURLModel new];
    NSDictionary *userImageDictionary = [userDictionary objectForKey:@"imageURL"];
    userImageDictionary = [TAPUtil nullToEmptyDictionary:userImageDictionary];
    
    NSString *userThumbnail = [userImageDictionary objectForKey:@"thumbnail"];
    userThumbnail = [TAPUtil nullToEmptyString:userThumbnail];
    userImageURL.thumbnail = thumbnail;
    
    NSString *userFullsize = [userImageDictionary objectForKey:@"fullsize"];
    userFullsize = [TAPUtil nullToEmptyString:userFullsize];
    userImageURL.fullsize = fullsize;
    
    user.imageURL = userImageURL;
    
    NSString *userEmail = [userDictionary objectForKey:@"email"];
    userEmail = [TAPUtil nullToEmptyString:userEmail];
    user.email = userEmail;
    
    NSString *userPhone = [userDictionary objectForKey:@"phone"];
    userPhone = [TAPUtil nullToEmptyString:userPhone];
    user.phone = userPhone;
    
    NSDictionary *userRoleDictionary = [userDictionary objectForKey:@"userRole"];
    userRoleDictionary = [TAPUtil nullToEmptyDictionary:userRoleDictionary];
    
    TAPUserRoleModel *userRole = [TAPUserRoleModel new];
    NSString *userRoleID = [userRoleDictionary objectForKey:@"userRoleID"];
    userRoleID = [TAPUtil nullToEmptyString:userRoleID];
    userRole.userRoleID = userRoleID;
    
    NSString *name = [userRoleDictionary objectForKey:@"name"];
    name = [TAPUtil nullToEmptyString:name];
    userRole.name = name;
    
    NSString *iconURL = [userRoleDictionary objectForKey:@"iconURL"];
    iconURL = [TAPUtil nullToEmptyString:iconURL];
    userRole.iconURL = iconURL;
    
    user.userRole = userRole;
    
    NSNumber *lastLogin = [userDictionary objectForKey:@"lastLogin"];
    lastLogin = [TAPUtil nullToEmptyNumber:lastLogin];
    user.lastLogin = lastLogin;
    
    NSNumber *lastActivity = [userDictionary objectForKey:@"lastActivity"];
    lastActivity = [TAPUtil nullToEmptyNumber:lastActivity];
    user.lastActivity = lastActivity;
    
    NSNumber *userCreated = [userDictionary objectForKey:@"created"];
    userCreated = [TAPUtil nullToEmptyNumber:userCreated];
    user.created = userCreated;
    
    NSNumber *userUpdated = [userDictionary objectForKey:@"updated"];
    userUpdated = [TAPUtil nullToEmptyNumber:userUpdated];
    user.updated = userUpdated;
    message.user = user;
    
    return message;
}

+ (TAPUserModel *)userModelFromDictionary:(NSDictionary *)dictionary {
    dictionary = [TAPUtil nullToEmptyDictionary:dictionary];
    TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:dictionary error:nil];
    
    NSString *userID = [dictionary objectForKey:@"userID"];
    userID = [TAPUtil nullToEmptyString:userID];
    user.userID = userID;
    
    NSString *xcUserID = [dictionary objectForKey:@"xcUserID"];
    xcUserID = [TAPUtil nullToEmptyString:xcUserID];
    user.xcUserID = xcUserID;
    
    NSString *fullname = [dictionary objectForKey:@"fullname"];
    fullname = [TAPUtil nullToEmptyString:fullname];
    user.fullname = fullname;
    
    NSString *email = [dictionary objectForKey:@"email"];
    email = [TAPUtil nullToEmptyString:email];
    user.email = email;
    
    NSString *phone = [dictionary objectForKey:@"phone"];
    phone = [TAPUtil nullToEmptyString:phone];
    user.phone = phone;
    
    NSString *username = [dictionary objectForKey:@"username"];
    username = [TAPUtil nullToEmptyString:username];
    user.username = username;
    
    TAPImageURLModel *imageURL = [TAPImageURLModel new];
    NSString *imageURLString = [dictionary objectForKey:@"imageURL"];
    if([imageURLString isEqualToString:@""] || imageURLString == nil) {
        imageURL.thumbnail = @"";
        imageURL.fullsize = @"";
    }
    else {
        NSDictionary *imageJSONDictionary = [TAPUtil jsonObjectFromString:imageURLString];
        NSString *thumbnail = [imageJSONDictionary objectForKey:@"thumbnail"];
        thumbnail = [TAPUtil nullToEmptyString:thumbnail];
        imageURL.thumbnail = thumbnail;
        
        NSString *fullsize = [imageJSONDictionary objectForKey:@"fullsize"];
        fullsize = [TAPUtil nullToEmptyString:fullsize];
        imageURL.fullsize = fullsize;
    }
    user.imageURL = imageURL;
    
    TAPUserRoleModel *userRole = [TAPUserRoleModel new];
    NSString *userRoleID = [dictionary objectForKey:@"userRoleID"];
    userRoleID = [TAPUtil nullToEmptyString:userRoleID];
    userRole.userRoleID = userRoleID;
    
    NSString *userRoleName = [dictionary objectForKey:@"userRoleName"];
    userRoleName = [TAPUtil nullToEmptyString:userRoleName];
    userRole.name = userRoleName;
    
    NSString *userRoleIconURL = [dictionary objectForKey:@"userRoleIconURL"];
    userRoleIconURL = [TAPUtil nullToEmptyString:userRoleIconURL];
    userRole.iconURL = userRoleIconURL;
    user.userRole = userRole;
    
    NSNumber *lastLogin = [dictionary objectForKey:@"lastLogin"];
    lastLogin = [TAPUtil nullToEmptyNumber:lastLogin];
    user.lastLogin = lastLogin;
    
    NSNumber *lastActivity = [dictionary objectForKey:@"lastActivity"];
    lastActivity = [TAPUtil nullToEmptyNumber:lastActivity];
    user.lastActivity = lastActivity;
    
    BOOL requireChangePassword = [[dictionary objectForKey:@"requireChangePassword"] boolValue];
    user.requireChangePassword = requireChangePassword;
    
    NSNumber *created = [dictionary objectForKey:@"created"];
    created = [TAPUtil nullToEmptyNumber:created];
    user.created = created;
    
    NSNumber *updated = [dictionary objectForKey:@"updated"];
    updated = [TAPUtil nullToEmptyNumber:updated];
    user.updated = updated;
    
    return user;
}

+ (TAPRecentSearchModel *)recentSearchModelFromDictionary:(NSDictionary *)dictionary {
    dictionary = [TAPUtil nullToEmptyDictionary:dictionary];
    TAPRecentSearchModel *recentSearch = [[TAPRecentSearchModel alloc] initWithDictionary:dictionary error:nil];
    
    TAPRoomModel *room = [TAPRoomModel new];
    NSString *roomID = [dictionary objectForKey:@"roomID"];
    roomID = [TAPUtil nullToEmptyString:roomID];
    room.roomID = roomID;
    
    NSString *name = [dictionary objectForKey:@"roomName"];
    name = [TAPUtil nullToEmptyString:name];
    room.name = name;
    
    NSString *color = [dictionary objectForKey:@"roomColor"];
    color = [TAPUtil nullToEmptyString:color];
    room.color = color;
    
    TAPImageURLModel *imageURL = [TAPImageURLModel new];
    NSString *imageURLString = [dictionary objectForKey:@"imageURL"];
    if([imageURLString isEqualToString:@""] || imageURLString == nil) {
        imageURL.thumbnail = @"";
        imageURL.fullsize = @"";
    }
    else {
        NSDictionary *imageJSONDictionary = [TAPUtil jsonObjectFromString:imageURLString];
        NSString *thumbnail = [imageJSONDictionary objectForKey:@"thumbnail"];
        thumbnail = [TAPUtil nullToEmptyString:thumbnail];
        imageURL.thumbnail = thumbnail;
        
        NSString *fullsize = [imageJSONDictionary objectForKey:@"fullsize"];
        fullsize = [TAPUtil nullToEmptyString:fullsize];
        imageURL.fullsize = fullsize;
    }
    room.imageURL = imageURL;
    
    NSInteger type = [[dictionary objectForKey:@"roomType"] integerValue];
    room.type = type;
    recentSearch.room = room;
    
    return recentSearch;
}

#pragma mark From Model
//WK NOTE - USUALLY USED ON UPDATE AND INSERTION METHODS
+ (NSDictionary *)dictionaryFromMessageModel:(TAPMessageModel *)message {
    NSDictionary *messageDictionary = [message toDictionary];
    messageDictionary = [TAPUtil nullToEmptyDictionary:messageDictionary];
    
    NSMutableDictionary *messageMutableDictionary = [messageDictionary mutableCopy];
    
    NSMutableDictionary *roomDicitonary = [messageMutableDictionary objectForKey:@"room"];
    NSString *roomID = [roomDicitonary objectForKey:@"roomID"];
    roomID = [TAPUtil nullToEmptyString:roomID];
    [messageMutableDictionary setValue:roomID forKey:@"roomID"];
    
    NSString *roomName = [roomDicitonary objectForKey:@"name"];
    roomName = [TAPUtil nullToEmptyString:roomName];
    [messageMutableDictionary setValue:roomName forKey:@"roomName"];
    
    NSString *roomColor = [roomDicitonary objectForKey:@"color"];
    roomColor = [TAPUtil nullToEmptyString:roomColor];
    [messageMutableDictionary setValue:roomColor forKey:@"roomColor"];
    
    NSString *roomImage = [TAPUtil jsonStringFromObject:[roomDicitonary objectForKey:@"imageURL"]];
    roomImage = [TAPUtil nullToEmptyString:roomImage];
    [messageMutableDictionary setValue:roomImage forKey:@"roomImage"];
    
    NSNumber *roomType = [roomDicitonary objectForKey:@"type"];
    roomType = [TAPUtil nullToEmptyNumber:roomType];
    [messageMutableDictionary setValue:roomType forKey:@"roomType"];
    
    [messageMutableDictionary removeObjectForKey:@"room"];
    
    NSDictionary *userDictionary = [messageMutableDictionary objectForKey:@"user"];
    NSString *userID = [userDictionary objectForKey:@"userID"];
    userID = [TAPUtil nullToEmptyString:userID];
    [messageMutableDictionary setValue:userID forKey:@"userID"];
    
    NSString *xcUserID = [userDictionary objectForKey:@"xcUserID"];
    xcUserID = [TAPUtil nullToEmptyString:xcUserID];
    [messageMutableDictionary setValue:xcUserID forKey:@"xcUserID"];
    
    NSString *userFullName = [userDictionary objectForKey:@"fullname"];
    userFullName = [TAPUtil nullToEmptyString:userFullName];
    [messageMutableDictionary setValue:userFullName forKey:@"userFullName"];
    
    NSString *username = [userDictionary objectForKey:@"username"];
    username = [TAPUtil nullToEmptyString:username];
    [messageMutableDictionary setValue:username forKey:@"username"];
    
    NSString *userImage = [TAPUtil jsonStringFromObject:[userDictionary objectForKey:@"imageURL"]];
    userImage = [TAPUtil nullToEmptyString:userImage];
    [messageMutableDictionary setValue:userImage forKey:@"userImage"];
    
    NSString *userEmail = [userDictionary objectForKey:@"email"];
    userEmail = [TAPUtil nullToEmptyString:userEmail];
    [messageMutableDictionary setValue:userEmail forKey:@"userEmail"];
    
    NSString *userPhone = [userDictionary objectForKey:@"phone"];
    userPhone = [TAPUtil nullToEmptyString:userPhone];
    [messageMutableDictionary setValue:userPhone forKey:@"userPhone"];
    
    NSString *userRole = [TAPUtil jsonStringFromObject:[userDictionary objectForKey:@"userRole"]];
    userRole = [TAPUtil nullToEmptyString:userRole];
    [messageMutableDictionary setValue:userRole forKey:@"userRole"];
    
    NSNumber *lastLogin = [userDictionary objectForKey:@"lastLogin"];
    lastLogin = [TAPUtil nullToEmptyNumber:lastLogin];
    [messageMutableDictionary setValue:lastLogin forKey:@"lastLogin"];
    
    NSNumber *requireChangePassword = [userDictionary objectForKey:@"requireChangePassword"];
    requireChangePassword = [TAPUtil nullToEmptyNumber:requireChangePassword];
    [messageMutableDictionary setValue:requireChangePassword forKey:@"requireChangePassword"];
    
    NSNumber *userCreated = [userDictionary objectForKey:@"created"];
    userCreated = [TAPUtil nullToEmptyNumber:userCreated];
    [messageMutableDictionary setValue:userCreated forKey:@"userCreated"];
    
    NSNumber *userUpdated = [userDictionary objectForKey:@"updated"];
    userUpdated = [TAPUtil nullToEmptyNumber:userUpdated];
    [messageMutableDictionary setValue:userUpdated forKey:@"userUpdated"];
    
    [messageMutableDictionary removeObjectForKey:@"user"];
    
    return messageMutableDictionary;
}

+ (NSDictionary *)dictionaryFromUserModel:(TAPUserModel *)user {
    NSDictionary *userDictionary = [user toDictionary];
    userDictionary = [TAPUtil nullToEmptyDictionary:userDictionary];
    
    NSMutableDictionary *userMutableDictionary = [userDictionary mutableCopy];
    NSString *userID = [userDictionary objectForKey:@"userID"];
    userID = [TAPUtil nullToEmptyString:userID];
    [userMutableDictionary setValue:userID forKey:@"userID"];
    
    NSString *xcUserID = [userDictionary objectForKey:@"xcUserID"];
    xcUserID = [TAPUtil nullToEmptyString:xcUserID];
    [userMutableDictionary setValue:xcUserID forKey:@"xcUserID"];
    
    NSString *fullname = [userDictionary objectForKey:@"fullname"];
    fullname = [TAPUtil nullToEmptyString:fullname];
    [userMutableDictionary setValue:fullname forKey:@"fullname"];
    
    NSString *email = [userDictionary objectForKey:@"email"];
    email = [TAPUtil nullToEmptyString:email];
    [userMutableDictionary setValue:email forKey:@"email"];
    
    NSString *phone = [userDictionary objectForKey:@"phone"];
    phone = [TAPUtil nullToEmptyString:phone];
    [userMutableDictionary setValue:phone forKey:@"phone"];
    
    NSString *username = [userDictionary objectForKey:@"username"];
    username = [TAPUtil nullToEmptyString:username];
    [userMutableDictionary setValue:username forKey:@"username"];
    
    NSString *imageURL = [userDictionary objectForKey:@"imageURL"];
    imageURL = [TAPUtil nullToEmptyString:imageURL];
    [userMutableDictionary setValue:imageURL forKey:@"imageURL"];
    
    NSDictionary *userRole = [userDictionary objectForKey:@"userRole"];
    userRole = [TAPUtil nullToEmptyDictionary:userRole];
    NSString *userRoleID = [userRole objectForKey:@"userRoleID"];
    userRoleID = [TAPUtil nullToEmptyString:userRoleID];
    [userMutableDictionary setValue:userRoleID forKey:@"userRoleID"];
    
    NSString *userRoleName = [userRole objectForKey:@"name"];
    userRoleName = [TAPUtil nullToEmptyString:userRoleName];
    [userMutableDictionary setValue:userRoleName forKey:@"userRoleName"];
    
    NSString *userRoleIconURL = [userRole objectForKey:@"iconURL"];
    userRoleIconURL = [TAPUtil nullToEmptyString:userRoleIconURL];
    [userMutableDictionary setValue:userRoleIconURL forKey:@"userRoleIconURL"];
    [userMutableDictionary removeObjectForKey:@"userRole"];
    
    NSNumber *lastLogin = [userDictionary objectForKey:@"lastLogin"];
    lastLogin = [TAPUtil nullToEmptyNumber:lastLogin];
    [userMutableDictionary setValue:lastLogin forKey:@"lastLogin"];
    
    NSNumber *lastActivity = [userDictionary objectForKey:@"lastActivity"];
    lastActivity = [TAPUtil nullToEmptyNumber:lastActivity];
    [userMutableDictionary setValue:lastActivity forKey:@"lastActivity"];
    
    NSNumber *requireChangePassword = [userDictionary objectForKey:@"requireChangePassword"];
    requireChangePassword = [TAPUtil nullToEmptyNumber:requireChangePassword];
    [userMutableDictionary setValue:requireChangePassword forKey:@"requireChangePassword"];
    
    NSNumber *created = [userDictionary objectForKey:@"created"];
    created = [TAPUtil nullToEmptyNumber:created];
    [userMutableDictionary setValue:created forKey:@"created"];
    
    NSNumber *updated = [userDictionary objectForKey:@"updated"];
    updated = [TAPUtil nullToEmptyNumber:updated];
    [userMutableDictionary setValue:updated forKey:@"updated"];
    [userMutableDictionary removeObjectForKey:@"user"];
    
    return userMutableDictionary;
}

+ (NSDictionary *)dictionaryFromRecentSearchModel:(TAPRecentSearchModel *)recentSearch {
    NSDictionary *recentSearchDictionary = [recentSearch toDictionary];
    recentSearchDictionary = [TAPUtil nullToEmptyDictionary:recentSearchDictionary];
    NSMutableDictionary *recentSearchMutableDictionary = [recentSearchDictionary mutableCopy];
    NSDictionary *roomDictionary = [recentSearchMutableDictionary objectForKey:@"room"];
    NSString *roomID = [roomDictionary objectForKey:@"roomID"];
    roomID = [TAPUtil nullToEmptyString:roomID];
    [recentSearchMutableDictionary setValue:roomID forKey:@"roomID"];
    
    NSString *roomName = [roomDictionary objectForKey:@"name"];
    roomName = [TAPUtil nullToEmptyString:roomName];
    [recentSearchMutableDictionary setValue:roomName forKey:@"roomName"];
    
    NSString *roomColor = [roomDictionary objectForKey:@"color"];
    roomColor = [TAPUtil nullToEmptyString:roomColor];
    [recentSearchMutableDictionary setValue:roomColor forKey:@"roomColor"];
    
    NSString *roomImage = [TAPUtil jsonStringFromObject:[roomDictionary objectForKey:@"imageURL"]];
    roomImage = [TAPUtil nullToEmptyString:roomImage];
    [recentSearchMutableDictionary setValue:roomImage forKey:@"roomImage"];
    
    NSNumber *roomType = [roomDictionary objectForKey:@"type"];
    roomType = [TAPUtil nullToEmptyNumber:roomType];
    [recentSearchMutableDictionary setValue:roomType forKey:@"roomType"];
    [recentSearchMutableDictionary removeObjectForKey:@"room"];
    
    return recentSearchMutableDictionary;
}

#pragma mark - Custom Method
+ (void)logErrorStringFromError:(NSError *)error {
    NSString *dataString = [[NSString alloc] initWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
#if DEBUG
    NSLog(@"Error Response: %@", dataString);
#endif
}

+ (BOOL)isDataEmpty:(NSDictionary *)responseDictionary {
    NSDictionary *dataDictionary = [responseDictionary objectForKey:@"data"];
    
    if(dataDictionary == nil || [dataDictionary allKeys].count == 0) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isResponseSuccess:(NSDictionary *)responseDictionary {
    NSDictionary *errorDictionary = [responseDictionary objectForKey:@"error"];
    
    if(errorDictionary == nil || [errorDictionary allKeys].count == 0) {
        return YES;
    }
    
    NSInteger httpStatusCode = [[responseDictionary valueForKeyPath:@"status"] integerValue];
    
//    if(errorCode == 299 || errorCode == 499) {
//        //Success but need to refresh token = 299
//        //Failed but need to refresh token = 499 - if errorCode == 499 need to reload API
//
//        if(errorCode == 299) {
//            BOOL isCallingAPIRefreshToken = [[NSUserDefaults standardUserDefaults] secretBoolForKey:PREFS_IS_CALLING_API_REFRESH_TOKEN];
//            if(!isCallingAPIRefreshToken) {
//                [TAPDataManager performSelector:@selector(callAPIRefreshToken) withObject:nil afterDelay:1.0f];
//            }
//        }
//
//        return YES;
//    }
    if([[NSString stringWithFormat:@"%li", (long)httpStatusCode] hasPrefix:@"2"]) {
        return YES;
    }
    
    return NO;
}


+ (void)setActiveUser:(TAPUserModel *)user {
    if(user != nil) {
        NSDictionary *userDictionary = [user toDictionary];
        
        //Update user in chat manager
        [TAPChatManager sharedManager].activeUser = user;
        
        [[NSUserDefaults standardUserDefaults] setSecureObject:userDictionary forKey:TAP_PREFS_ACTIVE_USER];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (TAPUserModel *)getActiveUser {
    NSDictionary *userDictionary = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_ACTIVE_USER valid:nil];
    
    if(userDictionary == nil) {
        return nil;
    }
    
    TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:userDictionary error:nil];
    
    return user;
}

+ (void)setAccessToken:(NSString *)accessToken expiryDate:(NSTimeInterval)expiryDate {
    accessToken = [TAPUtil nullToEmptyString:accessToken];
    
    [[NSUserDefaults standardUserDefaults] setSecureObject:accessToken forKey:TAP_PREFS_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setSecureDouble:expiryDate forKey:TAP_PREFS_ACCESS_TOKEN_EXPIRED_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getAccessToken {
    return [TAPUtil nullToEmptyString:[[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_ACCESS_TOKEN valid:nil]];
}

+ (void)setRefreshToken:(NSString *)refreshToken expiryDate:(NSTimeInterval)expiryDate {
    refreshToken = [TAPUtil nullToEmptyString:refreshToken];
    
    [[NSUserDefaults standardUserDefaults] setSecureObject:refreshToken forKey:TAP_PREFS_REFRESH_TOKEN];
    [[NSUserDefaults standardUserDefaults] setSecureDouble:expiryDate forKey:TAP_PREFS_REFRESH_TOKEN_EXPIRED_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getRefreshToken {
    return [TAPUtil nullToEmptyString:[[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_REFRESH_TOKEN valid:nil]];
}

+ (void)updateMessageToFailedWhenClosedInDatabase {
    [[TAPDatabaseManager sharedManager] updateMessageToFailedWhenClosed];
}

+ (void)setMessageLastUpdatedWithRoomID:(NSString *)roomID lastUpdated:(NSNumber *)lastUpdated {
    NSDictionary *preferenceLastUpdatedDictionary = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_LAST_UPDATED_CHAT_ROOM valid:nil];
    preferenceLastUpdatedDictionary = [TAPUtil nullToEmptyDictionary:preferenceLastUpdatedDictionary];
    
    NSMutableDictionary *lastUpdatedDictionary = [NSMutableDictionary dictionaryWithDictionary:preferenceLastUpdatedDictionary];
    [lastUpdatedDictionary setObject:lastUpdated forKey:roomID];
    [[NSUserDefaults standardUserDefaults] setSecureObject:lastUpdatedDictionary forKey:TAP_PREFS_LAST_UPDATED_CHAT_ROOM];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSNumber *)getMessageLastUpdatedWithRoomID:(NSString *)roomID {
    NSDictionary *lastUpdatedDictionary = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_LAST_UPDATED_CHAT_ROOM valid:nil];
    NSNumber *lastUpdated = [lastUpdatedDictionary objectForKey:roomID];
    lastUpdated = [TAPUtil nullToEmptyNumber:lastUpdated];
    return lastUpdated;
}

#pragma mark - Database Call
+ (void)searchMessageWithString:(NSString *)searchString
                         sortBy:(NSString *)columnName
                        success:(void (^)(NSArray *resultArray))success
                        failure:(void (^)(NSError *error))failure {
    //WK Note - Create nonAlphaNumericCharacters
    NSMutableCharacterSet *nonAlphaNumericCharacters = [[NSMutableCharacterSet alloc] init];
    [nonAlphaNumericCharacters formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    [nonAlphaNumericCharacters removeCharactersInString:@" "]; //Remove space from nonAlphaNumericCharacters
    
    NSString *alphaNumericSearchString = [[searchString componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""]; //Remove all string that is nonAlphaNumericCharacters
    //End Note
    
    NSString *queryClause = [NSString stringWithFormat:@"body CONTAINS[c] \'%@\'", alphaNumericSearchString];
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableMessage whereClauseQuery:queryClause sortByColumnName:columnName isAscending:NO success:^(NSArray *resultArray) {
        NSMutableArray *modelArray = [NSMutableArray array];
        for(NSInteger count = 0; count < [resultArray count]; count++) {
            NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[resultArray objectAtIndex:count]];
            
            TAPMessageModel *messageModel = [TAPDataManager messageModelFromDictionary:databaseDictionary];
            [modelArray addObject:messageModel];
        }
        success(modelArray);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)getMessageWithRoomID:(NSString *)roomID
        lastMessageTimeStamp:(NSNumber *)timeStamp
                   limitData:(NSInteger)limit
                     success:(void (^)(NSArray<TAPMessageModel *> *messageArray))success
                     failure:(void (^)(NSError *error))failure {
    NSString *predicateString = [NSString stringWithFormat:@"created < %lf", [timeStamp doubleValue]];
    [TAPDatabaseManager loadMessageWithRoomID:roomID predicateString:predicateString numberOfItems:limit success:^(NSArray *resultArray) {
        NSArray *messageArray = [TAPUtil nullToEmptyArray:resultArray];
        
        if([messageArray count] == 0) {
            success([NSArray array]);
        }
        else {
            NSMutableArray *modelArray = [NSMutableArray array];
            for(NSInteger count = 0; count < [messageArray count]; count++) {
                NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[messageArray objectAtIndex:count]];

                TAPMessageModel *messageModel = [TAPDataManager messageModelFromDictionary:databaseDictionary];
                [modelArray addObject:messageModel];
                
                NSError *error;
                
                if(error) {
                    failure(error);
                    return;
                }
            }
            
            success(modelArray);
        }
    } failure:^(NSError *error) {
        //Do nothing.
    }];
}

+ (void)getAllMessageWithRoomID:(NSString *)roomID
                      sortByKey:(NSString *)columnName
                      ascending:(BOOL)isAscending
                        success:(void (^)(NSArray<TAPMessageModel *> *messageArray))success
                        failure:(void (^)(NSError *error))failure {
    NSString *query = [NSString stringWithFormat:@"roomID == '%@'", roomID];
    [TAPDatabaseManager loadAllDataFromDatabaseWithQuery:query tableName:kDatabaseTableMessage sortByKey:columnName ascending:isAscending success:^(NSArray *resultArray) {
        NSArray *messageArray = [TAPUtil nullToEmptyArray:resultArray];
        
        if([messageArray count] == 0) {
            success([NSArray array]);
        }
        else {
            NSMutableArray *modelArray = [NSMutableArray array];
            for(NSInteger count = 0; count < [messageArray count]; count++) {
                NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[messageArray objectAtIndex:count]];
                
                TAPMessageModel *messageModel = [TAPDataManager messageModelFromDictionary:databaseDictionary];
                [modelArray addObject:messageModel];
                
                NSError *error;
                
                if(error) {
                    failure(error);
                    return;
                }
            }
            
            success(modelArray);
        }
    } failure:^(NSError *error) {
        
    }];
}

+ (void)getRoomListSuccess:(void (^)(NSArray *resultArray))success
                   failure:(void (^)(NSError *error))failure {
    [TAPDatabaseManager loadRoomListSuccess:^(NSArray *resultArray) {
        NSArray *messageArray = [TAPUtil nullToEmptyArray:resultArray];
        NSMutableArray *modelArray = [NSMutableArray array];
        for(NSInteger count = 0; count < [messageArray count]; count++) {
            NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[messageArray objectAtIndex:count]];
            
            TAPMessageModel *messageModel = [TAPDataManager messageModelFromDictionary:databaseDictionary];
            [modelArray addObject:messageModel];
            
            NSError *error;
            
            if(error) {
                failure(error);
                return;
            }
        }
        
        success(modelArray);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)getDatabaseRecentSearchResultSuccess:(void (^)(NSArray<TAPRecentSearchModel *> *recentSearchArray, NSArray *unreadCountArray))success
                                     failure:(void (^)(NSError *error))failure {
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableRecentSearch whereClauseQuery:@"" sortByColumnName:@"created" isAscending:NO success:^(NSArray *resultArray) {
        resultArray = [TAPUtil nullToEmptyArray:resultArray];
        
        NSMutableArray *obtainedArray = [NSMutableArray array];
        NSMutableArray *unreadCountArray = [NSMutableArray arrayWithCapacity:[resultArray count]];
        NSInteger __block counterLoop = 0;
        for(NSDictionary *databaseDictionary in resultArray) {
            TAPRecentSearchModel *recentSearch = [TAPDataManager recentSearchModelFromDictionary:databaseDictionary];
            [obtainedArray addObject:recentSearch];
            [unreadCountArray addObject:@"0"];
            TAPRoomModel *room = recentSearch.room;
            [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:room.roomID activeUserID:[TAPChatManager sharedManager].activeUser.userID success:^(NSArray *unreadMessages) {
                NSString *unreadCountString = [NSString stringWithFormat:@"%ld", [unreadMessages count]];
//                [unreadCountArray addObject:unreadCountString];
                [unreadCountArray replaceObjectAtIndex:[obtainedArray indexOfObject:recentSearch] withObject:unreadCountString];
                if (counterLoop == [resultArray count] - 1) {
                    success(obtainedArray, unreadCountArray);
                }
                
                counterLoop += 1;
            } failure:^(NSError *error) {
                [unreadCountArray addObject:@"0"];
            }];
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)getDatabaseAllUnreadMessagesWithSuccess:(void (^)(NSArray *unreadMessages))success
                                        failure:(void (^)(NSError *error))failure {
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableMessage whereClauseQuery:@"isRead == 0" sortByColumnName:@"" isAscending:NO success:^(NSArray *resultArray) {
        resultArray = [TAPUtil nullToEmptyArray:resultArray];
        
        NSMutableArray *obtainedArray = [NSMutableArray array];
        for(NSDictionary *databaseDictionary in resultArray) {
            TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:databaseDictionary error:nil];
            [obtainedArray addObject:message];
        }
        
        success(obtainedArray);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)getDatabaseUnreadMessagesInRoomWithRoomID:(NSString *)roomID
                                     activeUserID:(NSString *)activeUserID
                                          success:(void (^)(NSArray *))success
                                          failure:(void (^)(NSError *))failure {
    
    NSString *queryString = [NSString stringWithFormat:@"isRead == 0 && roomID LIKE '%@' && !(userID LIKE '%@')", roomID, activeUserID];
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableMessage whereClauseQuery:queryString sortByColumnName:@"" isAscending:NO success:^(NSArray *resultArray) {
        
        resultArray = [TAPUtil nullToEmptyArray:resultArray];
        
        NSMutableArray *obtainedArray = [NSMutableArray array];
        for(NSDictionary *databaseDictionary in resultArray) {
            TAPMessageModel *message = [TAPDataManager messageModelFromDictionary:databaseDictionary];
            [obtainedArray addObject:message];
        }
        
        success(resultArray);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)searchChatAndContactWithString:(NSString *)searchString
                                SortBy:(NSString *)columnName
                               success:(void (^)(NSArray *roomArray, NSArray *unreadCountArray))success
                               failure:(void (^)(NSError *error))failure {
    //WK Note - Create nonAlphaNumericCharacters
    NSMutableCharacterSet *nonAlphaNumericCharacters = [[NSMutableCharacterSet alloc] init];
    [nonAlphaNumericCharacters formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    [nonAlphaNumericCharacters removeCharactersInString:@" "]; //Remove space from nonAlphaNumericCharacters
    
    NSString *alphaNumericSearchString = [[searchString componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""]; //Remove all string that is nonAlphaNumericCharacters
    //End Note
    
    NSString __block *queryClause = [NSString stringWithFormat:@"roomName CONTAINS[c] \'%@\'", alphaNumericSearchString];
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableMessage whereClauseQuery:queryClause sortByColumnName:@"" isAscending:YES distinctBy:@"roomID" success:^(NSArray *resultArray) {
        
        NSArray *databaseArray = [NSArray array];
        databaseArray = resultArray;
        
        NSMutableDictionary *modelDictionary = [NSMutableDictionary dictionary];
        for(NSInteger count = 0; count < [databaseArray count]; count++) {
            NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[databaseArray objectAtIndex:count]];
            
            TAPMessageModel *messageModel = [TAPDataManager messageModelFromDictionary:databaseDictionary];
            TAPRoomModel *room = messageModel.room;
            [modelDictionary setObject:room forKey:room.roomID];
        }
        
        queryClause = [NSString stringWithFormat:@"fullname CONTAINS[c] \'%@\'", alphaNumericSearchString];
        [TAPDatabaseManager loadDataFromTableName:kDatabaseTableContact whereClauseQuery:queryClause sortByColumnName:@"fullname" isAscending:YES success:^(NSArray *resultArray) {
            for(NSInteger count = 0; count < [resultArray count]; count++) {
                NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[resultArray objectAtIndex:count]];
                
                TAPUserModel *user = [TAPDataManager userModelFromDictionary:databaseDictionary];
                TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:user];
                [modelDictionary setObject:room forKey:room.roomID];
            }
            
            NSMutableArray *valuesArray = [NSMutableArray arrayWithArray:[modelDictionary allValues]];
            NSMutableArray *roomArray = [NSMutableArray array];
            NSMutableArray *unreadCountArray = [NSMutableArray array];
            if ([valuesArray count] == 0) {
                success(roomArray, unreadCountArray);
            }
            else {
                NSInteger __block counterLoop = 0;
                for (TAPRoomModel *room in valuesArray) {
                    [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:room.roomID activeUserID:[TAPChatManager sharedManager].activeUser.userID success:^(NSArray *unreadMessages) {
                        NSString *unreadCountString = [NSString stringWithFormat:@"%ld", [unreadMessages count]];
                        [unreadCountArray addObject:unreadCountString];
                        [roomArray addObject:room];
                        if (counterLoop == [valuesArray count] - 1) {
                            success(roomArray, unreadCountArray);
                        }
                        counterLoop += 1;
                    } failure:^(NSError *error) {
                        [unreadCountArray addObject:@"0"];
                    }];
                }
            }
        } failure:^(NSError *error) {
            failure(error);
        }];
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)insertDatabaseMessageWithData:(NSArray *)dataArray
                            tableName:(NSString *)tableName
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    NSMutableArray *messageDictionaryArray = [NSMutableArray array];
    
    for (TAPMessageModel *message in dataArray) {
        NSDictionary *messageDictionary = [TAPDataManager dictionaryFromMessageModel:message];
        messageDictionary = [TAPUtil nullToEmptyDictionary:messageDictionary];
        
        [messageDictionaryArray addObject:messageDictionary];
    }
    
    [TAPDatabaseManager insertDataToDatabaseWithData:messageDictionaryArray tableName:tableName success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)updateOrInsertDatabaseMessageWithData:(NSArray *)dataArray
                                    tableName:(NSString *)tableName
                                      success:(void (^)(void))success
                                      failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    
    NSMutableArray *messageDictionaryArray = [NSMutableArray array];
    for (TAPMessageModel *message in dataArray) {
        NSDictionary *messageDictionary = [TAPDataManager dictionaryFromMessageModel:message];
        messageDictionary = [TAPUtil nullToEmptyDictionary:messageDictionary];
        
        [messageDictionaryArray addObject:messageDictionary];
    }
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseWithData:messageDictionaryArray tableName:tableName success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)updateOrInsertDatabaseMessageInMainThreadWithData:(NSArray *)dataArray
                                                tableName:(NSString *)tableName
                                                  success:(void (^)(void))success
                                                  failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    
    NSMutableArray *messageDictionaryArray = [NSMutableArray array];
    for (TAPMessageModel *message in dataArray) {
        NSDictionary *messageDictionary = [TAPDataManager dictionaryFromMessageModel:message];
        messageDictionary = [TAPUtil nullToEmptyDictionary:messageDictionary];
        
        [messageDictionaryArray addObject:messageDictionary];
    }
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseInMainThreadWithData:messageDictionaryArray tableName:tableName success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)updateOrInsertDatabaseRecentSearchWithData:(NSArray *)dataArray
                                         tableName:(NSString *)tableName
                                           success:(void (^)(void))success
                                           failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }

    NSMutableArray *recentSearchDictionaryArray = [NSMutableArray array];
    for (TAPRecentSearchModel *recentSearch in dataArray) {
        NSDictionary *recentSearchDictionary = [TAPDataManager dictionaryFromRecentSearchModel:recentSearch];
        recentSearchDictionary = [TAPUtil nullToEmptyDictionary:recentSearchDictionary];
        
        [recentSearchDictionaryArray addObject:recentSearchDictionary];
    }
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseWithData:recentSearchDictionaryArray tableName:tableName success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)updateOrInsertDatabaseContactWithData:(NSArray *)dataArray
                                    tableName:(NSString *)tableName
                                      success:(void (^)(void))success
                                      failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    
    NSMutableArray *userDictionaryArray = [NSMutableArray array];
    for (TAPUserModel *user in dataArray) {
        NSDictionary *userDictionary = [TAPDataManager dictionaryFromUserModel:user];
        userDictionary = [TAPUtil nullToEmptyDictionary:userDictionary];
        
        [userDictionaryArray addObject:userDictionary];
    }
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseWithData:userDictionaryArray tableName:tableName success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)updateMessageReadStatusToDatabaseWithData:(NSArray *)dataArray
                                        tableName:(NSString *)tableName
                                          success:(void (^)(void))success
                                          failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    
    NSMutableArray *messageDictionaryArray = [NSMutableArray array];
    for (TAPMessageModel *message in dataArray) {

        //Changing isRead to true
        message.isRead = YES;
        
        NSDictionary *messageDictionary = [TAPDataManager dictionaryFromMessageModel:message];
        messageDictionary = [TAPUtil nullToEmptyDictionary:messageDictionary];
        
        [messageDictionaryArray addObject:messageDictionary];
    }
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseWithData:messageDictionaryArray tableName:tableName success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)deleteDatabaseMessageWithData:(NSArray *)dataArray
                            tableName:(NSString *)tableName
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    
    NSMutableArray *messageDictionaryArray = [NSMutableArray array];
    for (TAPMessageModel *message in dataArray) {
        NSDictionary *messageDictionary = [TAPDataManager dictionaryFromMessageModel:message];
        messageDictionary = [TAPUtil nullToEmptyDictionary:messageDictionary];
        
        [messageDictionaryArray addObject:messageDictionary];
    }
    
    [TAPDatabaseManager deleteDataInDatabaseWithData:messageDictionaryArray tableName:tableName success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)deleteDatabaseMessageWithPredicateString:(NSString *)predicateString
                                         success:(void (^)(void))success
                                         failure:(void (^)(NSError *error))failure {
    if ([predicateString isEqualToString:@""]) {
        success();
    }
    else {
        [TAPDatabaseManager deleteDataInDatabaseWithPredicateString:predicateString tableName:kDatabaseTableMessage success:^{
            success();
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
}

+ (void)getDatabaseContactSearchKeyword:(NSString *)keyword
                                 sortBy:(NSString *)columnName
                                success:(void (^)(NSArray *resultArray))success
                                failure:(void (^)(NSError *error))failure {
    //WK Note - Create nonAlphaNumericCharacters
    NSMutableCharacterSet *nonAlphaNumericCharacters = [[NSMutableCharacterSet alloc] init];
    [nonAlphaNumericCharacters formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    [nonAlphaNumericCharacters removeCharactersInString:@" "]; //Remove space from nonAlphaNumericCharacters
    
    NSString *alphaNumericSearchString = [[keyword componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""]; //Remove all string that is nonAlphaNumericCharacters
    //End Note
    
    NSString *queryClause = [NSString stringWithFormat:@"fullname CONTAINS[c] \'%@\'", alphaNumericSearchString];
    
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableContact whereClauseQuery:queryClause sortByColumnName:columnName isAscending:YES success:^(NSArray *resultArray) {
        
        NSMutableArray *modelArray = [NSMutableArray array];
        for (NSInteger count = 0; count < [resultArray count]; count++) {
            NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[resultArray objectAtIndex:count]];
            
            TAPUserModel *user = [TAPDataManager userModelFromDictionary:databaseDictionary];
            [modelArray addObject:user];
        }
        
        success(modelArray);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)getDatabaseAllContactSortBy:(NSString *)columnName
                            success:(void (^)(NSArray *resultArray))success
                            failure:(void (^)(NSError *error))failure {
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableContact 
                            whereClauseQuery:@""
                            sortByColumnName:columnName
                                 isAscending:YES
                                     success:^(NSArray *resultArray) {
                                         NSMutableArray *modelArray = [NSMutableArray array];
                                         for (NSInteger count = 0; count < [resultArray count]; count++) {
                                             NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[resultArray objectAtIndex:count]];
                                             
                                             TAPUserModel *user = [TAPDataManager userModelFromDictionary:databaseDictionary];
                                             [modelArray addObject:user];
                                         }
                                         success(modelArray);
                                 } failure:^(NSError *error) {
                                     failure(error);
                                 }];
}

+ (void)getDatabaseContactByUserID:(NSString *)userID
                           success:(void (^)(BOOL isContact))success
                           failure:(void (^)(NSError *error))failure {
    userID = [TAPUtil nullToEmptyString:userID];
    NSString *queryClause = [NSString stringWithFormat:@"userID == \'%@\'", userID];
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableContact
                            whereClauseQuery:queryClause
                            sortByColumnName:@""
                                 isAscending:NO
                                     success:^(NSArray *resultArray) {
                                         if ([resultArray count] > 0) {
                                             success(YES);
                                         }
                                         else {
                                             success(NO);
                                         }
                                     } failure:^(NSError *error) {
                                         failure(error);
                                     }];
}

#pragma mark - API Call
 //DV Temp
 //DV Note - Temporary force call API to server to get Auth Ticket

+ (void)callAPIGetAuthTicketWithUser:(TAPUserModel *)user
                             success:(void (^)(NSString *authTicket))success
                             failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetAuthTicket];
    
    NSString *IPAddress = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://api.ipify.org/"] encoding:NSUTF8StringEncoding error:nil];
    IPAddress = [TAPUtil nullToEmptyString:IPAddress];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:IPAddress forKey:@"userIPAddress"];
    [parameterDictionary setObject:@"ios" forKey:@"userAgent"];
    [parameterDictionary setObject:@"ios" forKey:@"userPlatform"];
    [parameterDictionary setObject:[[UIDevice currentDevice] identifierForVendor].UUIDString forKey:@"userDeviceID"];
    
    NSString *xcUserID = user.xcUserID;
    xcUserID = [TAPUtil nullToEmptyString:xcUserID];
    NSString *fullName = user.fullname;
    fullName = [TAPUtil nullToEmptyString:fullName];
    NSString *email = user.email;
    email = [TAPUtil nullToEmptyString:email];
    NSString *phone = user.phone;
    phone = [TAPUtil nullToEmptyString:phone];
    NSString *username = user.username;
    username = [TAPUtil nullToEmptyString:username];

    [parameterDictionary setObject:xcUserID forKey:@"xcUserID"];
    [parameterDictionary setObject:fullName forKey:@"fullName"];
    [parameterDictionary setObject:email forKey:@"email"];
    [parameterDictionary setObject:phone forKey:@"phone"];
    [parameterDictionary setObject:username forKey:@"username"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            success([NSString string]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        NSString *authTicket = [dataDictionary objectForKey:@"ticket"];
        authTicket = [TAPUtil nullToEmptyString:authTicket];
        
        success(authTicket);

    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}
//END DV Temp

+ (void)callAPIGetAccessTokenWithAuthTicket:(NSString *)authTicket
                                    success:(void (^)(void))success
                                    failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetAccessToken];
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    
    [[TAPNetworkManager sharedManager] post:requestURL authTicket:authTicket parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            success();
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        
        NSString *accessToken = [dataDictionary objectForKey:@"accessToken"];
        accessToken = [TAPUtil nullToEmptyString:accessToken];
        
        NSTimeInterval accessTokenExpiry = [[dataDictionary objectForKey:@"accessToken"] longLongValue];
        
        NSTimeInterval refreshTokenExpiry = [[dataDictionary objectForKey:@"refreshTokenExpiry"] longLongValue];
        
        NSString *refreshToken = [dataDictionary objectForKey:@"refreshToken"];
        refreshToken = [TAPUtil nullToEmptyString:refreshToken];
        
        NSDictionary *userDictionary = [dataDictionary objectForKey:@"user"];
        userDictionary = [TAPUtil nullToEmptyDictionary:userDictionary];
        
        TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:userDictionary error:nil];
        
        [TAPDataManager setAccessToken:accessToken expiryDate:accessTokenExpiry];
        [TAPDataManager setRefreshToken:refreshToken expiryDate:refreshTokenExpiry];
        [TAPDataManager setActiveUser:user];
        
        success();
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}

- (void)callAPIRefreshAccessTokenSuccess:(void (^)(void))success
                                 failure:(void (^)(NSError *error))failure {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        _isShouldRefreshToken = YES;
        
        [self.refreshTokenLock lock];
        
        if(self.isShouldRefreshToken) {
            NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeRefreshAccessToken];
            NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
            NSString *refreshToken = [TAPDataManager getRefreshToken];
            
            [[TAPNetworkManager sharedManager] post:requestURL refreshToken:refreshToken parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
                
            } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
                if(![TAPDataManager isResponseSuccess:responseObject]) {
                    NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
                    NSString *errorMessage = [errorDictionary objectForKey:@"message"];
                    errorMessage = [TAPUtil nullToEmptyString:errorMessage];
                    
                    NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
                    
                    if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                        errorCode = 999;
                    }
                    
                    if(errorCode >= 40103 && errorCode <= 40106) {
                        //Refresh token is invalid, ask business side to refresh auth ticket
                        [[TapTalk sharedInstance] shouldRefreshAuthTicket];
                    }
                    
                    _isShouldRefreshToken = NO;
                    [self.refreshTokenLock unlock];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
                        failure(error);
                    });
                    
                    return;
                }
                
                if([TAPDataManager isDataEmpty:responseObject]) {
                    _isShouldRefreshToken = NO;
                    [self.refreshTokenLock unlock];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success();
                    });
                    
                    return;
                }
                
                NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
                dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
                
                NSString *accessToken = [dataDictionary objectForKey:@"accessToken"];
                accessToken = [TAPUtil nullToEmptyString:accessToken];
                
                NSTimeInterval accessTokenExpiry = [[dataDictionary objectForKey:@"accessToken"] longLongValue];
                
                NSTimeInterval refreshTokenExpiry = [[dataDictionary objectForKey:@"refreshTokenExpiry"] longLongValue];
                
                NSString *refreshToken = [dataDictionary objectForKey:@"refreshToken"];
                refreshToken = [TAPUtil nullToEmptyString:refreshToken];
                
                NSDictionary *userDictionary = [dataDictionary objectForKey:@"user"];
                userDictionary = [TAPUtil nullToEmptyDictionary:userDictionary];
                
                TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:userDictionary error:nil];
                
                [TAPDataManager setAccessToken:accessToken expiryDate:accessTokenExpiry];
                [TAPDataManager setRefreshToken:refreshToken expiryDate:refreshTokenExpiry];
                [TAPDataManager setActiveUser:user];
                
                _isShouldRefreshToken = NO;
                [self.refreshTokenLock unlock];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    success();
                });
            } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                [TAPDataManager logErrorStringFromError:error];
                
#ifdef DEBUG
                NSString *errorDomain = error.domain;
                NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
                
                NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
                
                _isShouldRefreshToken = NO;
                [self.refreshTokenLock unlock];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(newError);
                });
#else
                NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
                
                _isShouldRefreshToken = NO;
                [self.refreshTokenLock unlock];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(localizedError);
                });
#endif
            }];
        }
        else {
            [self.refreshTokenLock unlock];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
    });
}

+ (void)callAPIValidateAccessTokenAndAutoRefreshSuccess:(void (^)(void))success
                                  failure:(void (^)(NSError *))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeValidateAccessToken];
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    
    [[TAPNetworkManager sharedManager] get:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                [TAPDataManager callAPIValidateAccessTokenAndAutoRefreshSuccess:success failure:failure];
            } failure:^(NSError *error) {
                [TAPDataManager logErrorStringFromError:error];
                failure(error);
                return;
            }];
            
            return;
        }
        
        success();
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        failure(error);
        return;
    }];
}

+ (void)callAPIGetMessageRoomListAndUnreadWithUserID:(NSString *)userID
                                             success:(void (^)(NSArray *messageArray))success
                                             failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetMessageRoomListAndUnread];
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:[NSNumber numberWithInteger:[userID integerValue]] forKey:@"userID"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetMessageRoomListAndUnreadWithUserID:userID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            success([NSArray array]);
            return;
        }
        
        NSArray *messageArray = [responseObject valueForKeyPath:@"data.messages"];
        messageArray = [TAPUtil nullToEmptyArray:messageArray];
    
        NSMutableArray *messageResultArray = [NSMutableArray array];
        for(NSDictionary *messageDictionary in messageArray) {
            TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:messageDictionary error:nil];
    
            //Decrypt message
            TAPMessageModel *decryptedMessage = [TAPEncryptorManager decryptMessage:message];
    
            [messageResultArray addObject:decryptedMessage];
        }
        
        success(messageResultArray);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}

+ (void)callAPIGetNewAndUpdatedMessageSuccess:(void (^)(NSArray *messageArray))success
                                      failure:(void (^)(NSError *error))failure {
    
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetPendingNewAndUpdatedMessages];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetNewAndUpdatedMessageSuccess:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            success([NSArray array]);
            return;
        }
        
        NSArray *messageArray = [responseObject valueForKeyPath:@"data.messages"];
        messageArray = [TAPUtil nullToEmptyArray:messageArray];
        
        NSMutableArray *messageResultArray = [NSMutableArray array];
        for(NSDictionary *messageDictionary in messageArray) {
            TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:messageDictionary error:nil];
            
            //Decrypt message
            TAPMessageModel *decryptedMessage = [TAPEncryptorManager decryptMessage:message];
            
            [messageResultArray addObject:decryptedMessage];
        }
        
        success(messageResultArray);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}

+ (void)callAPIGetMessageAfterWithRoomID:(NSString *)roomID
                              minCreated:(NSNumber *)minCreated
                                 success:(void (^)(NSArray *messageArray))success
                                 failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetMessageRoomListAfter];
    
    //Obtain Last Updated Value
    NSNumber *lastUpdated = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];

    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:minCreated forKey:@"minCreated"];
    [parameterDictionary setObject:lastUpdated forKey:@"lastUpdated"];

    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {

    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];

            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetMessageAfterWithRoomID:roomID minCreated:minCreated success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];

            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }

            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }

        if([self isDataEmpty:responseObject]) {
            success([NSArray array]);
            return;
        }

        NSArray *messageArray = [responseObject valueForKeyPath:@"data.messages"];
        messageArray = [TAPUtil nullToEmptyArray:messageArray];
        
        //Obtain latest updated value
        NSNumber *preferenceLastUpdated = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];
        
        NSMutableArray *messageResultArray = [NSMutableArray array];
        for(NSDictionary *messageDictionary in messageArray) {
            TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:messageDictionary error:nil];
            
            //Decrypt message
            TAPMessageModel *decryptedMessage = [TAPEncryptorManager decryptMessage:message];
            [messageResultArray addObject:decryptedMessage];
            
            if([preferenceLastUpdated longLongValue] < [message.updated longLongValue]) {
                preferenceLastUpdated = [NSNumber numberWithLongLong:[message.updated longLongValue]];
            }
        }
        
        //Set newest last updated to preference
        [TAPDataManager setMessageLastUpdatedWithRoomID:roomID lastUpdated:preferenceLastUpdated];
        
        //Insert To Database
        [TAPDataManager updateOrInsertDatabaseMessageWithData:messageResultArray tableName:kDatabaseTableMessage success:^{
            
        } failure:^(NSError *error) {
            
        }];
        
        success(messageResultArray);

    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];

#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];

        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];

        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];

        failure(localizedError);
#endif
    }];
}

+ (void)callAPIGetMessageBeforeWithRoomID:(NSString *)roomID
                               maxCreated:(NSNumber *)maxCreated
                                  success:(void (^)(NSArray *messageArray, BOOL hasMore))success
                                  failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetMessageRoomListBefore];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:maxCreated forKey:@"maxCreated"];

    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {

    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];

            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetMessageBeforeWithRoomID:roomID maxCreated:maxCreated success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];

            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }

            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }

        if([self isDataEmpty:responseObject]) {
            success([NSArray array], [NSDictionary dictionary]);
            return;
        }

        NSArray *messageArray = [responseObject valueForKeyPath:@"data.messages"];
        messageArray = [TAPUtil nullToEmptyArray:messageArray];

        NSMutableArray *messageResultArray = [NSMutableArray array];
        for(NSDictionary *messageDictionary in messageArray) {
            TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:messageDictionary error:nil];

            //Decrypt message
            TAPMessageModel *decryptedMessage = [TAPEncryptorManager decryptMessage:message];
            [messageResultArray addObject:decryptedMessage];
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        BOOL hasMore = [[dataDictionary objectForKey:@"hasMore"] boolValue];
 
        //Insert To Database
        [TAPDataManager updateOrInsertDatabaseMessageWithData:messageResultArray tableName:kDatabaseTableMessage success:^{
            
        } failure:^(NSError *error) {
            
        }];

        success(messageResultArray, hasMore);

    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];

#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];

        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];

        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];

        failure(localizedError);
#endif
    }];
}

+ (void)callAPIGetContactList:(void (^)(NSArray *userArray))success
                      failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetContactList];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetContactList:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            success([NSArray array]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSArray *userArray = [dataDictionary objectForKey:@"contacts"];
        userArray = [TAPUtil nullToEmptyArray:userArray];
        
        NSMutableArray *userResultArray = [NSMutableArray array];
        /* WK NOTE - UNCOMMENT THIS CODE TO REMOVE TEMPORARY ADD CONTACTS TO DATABASE
        for(NSDictionary *userDictionary in userArray) {
            TAPContactModel *contact = [TAPContactModel new];
            TAPUserModel *user = [TAPUserModel new];
            
            NSString *userID = [userDictionary objectForKey:@"userID"];
            userID = [TAPUtil nullToEmptyString:userID];
            user.userID = userID;
            
            NSString *xcUserID = [userDictionary objectForKey:@"xcUserID"];
            xcUserID = [TAPUtil nullToEmptyString:xcUserID];
            user.xcUserID = xcUserID;
            
            NSString *fullname = [userDictionary objectForKey:@"fullname"];
            fullname = [TAPUtil nullToEmptyString:fullname];
            user.fullname = fullname;
            
            NSString *email = [userDictionary objectForKey:@"email"];
            email = [TAPUtil nullToEmptyString:email];
            user.email = email;
            
            NSString *phone = [userDictionary objectForKey:@"phone"];
            phone = [TAPUtil nullToEmptyString:phone];
            user.phone = phone;
            
            NSString *username = [userDictionary objectForKey:@"username"];
            username = [TAPUtil nullToEmptyString:username];
            user.username = username;
            
            NSDictionary *imageURLDictionary = [userDictionary objectForKey:@"imageURL"];
            TAPImageURLModel *imageURL = [TAPImageURLModel new];
            NSString *thumbnail = [imageURLDictionary objectForKey:@"thumbnail"];
            thumbnail = [TAPUtil nullToEmptyString:thumbnail];
            imageURL.thumbnail = thumbnail;
            
            NSString *fullsize = [imageURLDictionary objectForKey:@"fullsize"];
            fullsize = [TAPUtil nullToEmptyString:fullsize];
            imageURL.fullsize = fullsize;
            user.imageURL = imageURL;
            
            NSDictionary *userRoleDictionary = [userDictionary objectForKey:@"userRole"];
            TAPUserRoleModel *userRole = [TAPUserRoleModel new];
            NSString *userRoleID = [userRoleDictionary objectForKey:@"userRoleID"];
            userRoleID = [TAPUtil nullToEmptyString:userRoleID];
            userRole.userRoleID = userRoleID;
            
            NSString *name = [userRoleDictionary objectForKey:@"name"];
            name = [TAPUtil nullToEmptyString:name];
            userRole.name = name;
            
            NSString *iconURL = [userRoleDictionary objectForKey:@"iconURL"];
            iconURL = [TAPUtil nullToEmptyString:iconURL];
            userRole.iconURL = iconURL;
            user.userRole = userRole;
            
            NSNumber *lastLogin = [userDictionary objectForKey:@"lastLogin"];
            lastLogin = [TAPUtil nullToEmptyNumber:lastLogin];
            user.lastLogin = lastLogin;
            
            NSNumber *lastActivity = [userDictionary objectForKey:@"lastActivity"];
            lastActivity = [TAPUtil nullToEmptyNumber:lastActivity];
            user.lastActivity = lastActivity;
            
            NSNumber *created = [userDictionary objectForKey:@"created"];
            created = [TAPUtil nullToEmptyNumber:created];
            user.created = created;
            
            NSNumber *updated = [userDictionary objectForKey:@"updated"];
            updated = [TAPUtil nullToEmptyNumber:updated];
            user.updated = updated;
            contact.user = user;
            
            BOOL isRequestPending = [[userDictionary objectForKey:@"isRequestPending"] boolValue];
            contact.isRequestPending = isRequestPending;
            
            BOOL isRequestAccepted = [[userDictionary objectForKey:@"isRequestAccepted"] boolValue];
            contact.isRequestAccepted = isRequestAccepted;
        }
        WK NOTE - UNCOMMENT THIS CODE TO REMOVE TEMPORARY ADD CONTACTS TO DATABASE
        */
        //WK Temp - add contacts to database

        TAPUserModel *firstUser = [TAPUserModel new];
        firstUser.userID = @"1";
        firstUser.xcUserID = @"1";
        firstUser.fullname = @"Ritchie Nathaniel";
        firstUser.email = @"ritchie@moselo.com";
        firstUser.phone = @"08979809026";
        firstUser.username = @"ritchie";
        firstUser.isRequestPending = NO;
        firstUser.isRequestAccepted = YES;
        
        TAPUserModel *secondUser = [TAPUserModel new];
        secondUser.userID = @"2";
        secondUser.xcUserID = @"2";
        secondUser.fullname = @"Dominic Vedericho";
        secondUser.email = @"dominic@moselo.com";
        secondUser.phone = @"08979809026";
        secondUser.username = @"dominic";
        secondUser.isRequestPending = NO;
        secondUser.isRequestAccepted = YES;
        
        TAPUserModel *thirdUser = [TAPUserModel new];
        thirdUser.userID = @"3";
        thirdUser.xcUserID = @"3";
        thirdUser.fullname = @"Rionaldo Linggautama";
        thirdUser.email = @"rionaldo@moselo.com";
        thirdUser.phone = @"08979809026";
        thirdUser.username = @"rionaldo";
        thirdUser.isRequestPending = NO;
        thirdUser.isRequestAccepted = YES;
        
        TAPUserModel *fourthUser = [TAPUserModel new];
        fourthUser.userID = @"4";
        fourthUser.xcUserID = @"4";
        fourthUser.fullname = @"Kevin Reynaldo";
        fourthUser.email = @"kevin@moselo.com";
        fourthUser.phone = @"08979809026";
        fourthUser.username = @"kevin";
        fourthUser.isRequestPending = NO;
        fourthUser.isRequestAccepted = YES;
        
        TAPUserModel *fifthUser = [TAPUserModel new];
        fifthUser.userID = @"5";
        fifthUser.xcUserID = @"5";
        fifthUser.fullname = @"Welly Kencana";
        fifthUser.email = @"welly@moselo.com";
        fifthUser.phone = @"08979809026";
        fifthUser.username = @"welly";
        fifthUser.isRequestPending = NO;
        fifthUser.isRequestAccepted = YES;
        
        TAPUserModel *sixthUser = [TAPUserModel new];
        sixthUser.userID = @"6";
        sixthUser.xcUserID = @"6";
        sixthUser.fullname = @"Jony Lim";
        sixthUser.email = @"jony@moselo.com";
        sixthUser.phone = @"08979809026";
        sixthUser.username = @"jony";
        sixthUser.isRequestPending = NO;
        sixthUser.isRequestAccepted = YES;
        
        TAPUserModel *seventhUser = [TAPUserModel new];
        seventhUser.userID = @"7";
        seventhUser.xcUserID = @"7";
        seventhUser.fullname = @"Michael Tansy";
        seventhUser.email = @"michael@moselo.com";
        seventhUser.phone = @"08979809026";
        seventhUser.username = @"michael";
        seventhUser.isRequestPending = NO;
        seventhUser.isRequestAccepted = YES;
        
        TAPUserModel *eighthUser = [TAPUserModel new];
        eighthUser.userID = @"8";
        eighthUser.xcUserID = @"8";
        eighthUser.fullname = @"Richard Fang";
        eighthUser.email = @"richard@moselo.com";
        eighthUser.phone = @"08979809026";
        eighthUser.username = @"richard";
        eighthUser.isRequestPending = NO;
        eighthUser.isRequestAccepted = YES;
        
        TAPUserModel *ninthUser = [TAPUserModel new];
        ninthUser.userID = @"9";
        ninthUser.xcUserID = @"9";
        ninthUser.fullname = @"Erwin Andreas";
        ninthUser.email = @"erwin@moselo.com";
        ninthUser.phone = @"08979809026";
        ninthUser.username = @"erwin";
        ninthUser.isRequestPending = NO;
        ninthUser.isRequestAccepted = YES;
        
        TAPUserModel *tenthUser = [TAPUserModel new];
        tenthUser.userID = @"10";
        tenthUser.xcUserID = @"10";
        tenthUser.fullname = @"Jefry Lorentono";
        tenthUser.email = @"jefry@moselo.com";
        tenthUser.phone = @"08979809026";
        tenthUser.username = @"jefry";
        tenthUser.isRequestPending = NO;
        tenthUser.isRequestAccepted = YES;
        
        TAPUserModel *eleventhUser = [TAPUserModel new];
        eleventhUser.userID = @"11";
        eleventhUser.xcUserID = @"11";
        eleventhUser.fullname = @"Cundy Sunardy";
        eleventhUser.email = @"cundy@moselo.com";
        eleventhUser.phone = @"08979809026";
        eleventhUser.username = @"cundy";
        eleventhUser.isRequestPending = NO;
        eleventhUser.isRequestAccepted = YES;
        
        TAPUserModel *twelfthUser = [TAPUserModel new];
        twelfthUser.userID = @"12";
        twelfthUser.xcUserID = @"12";
        twelfthUser.fullname = @"Rizka Fatmawati";
        twelfthUser.email = @"rizka@moselo.com";
        twelfthUser.phone = @"08979809026";
        twelfthUser.username = @"rizka";
        twelfthUser.isRequestPending = NO;
        twelfthUser.isRequestAccepted = YES;
        
        TAPUserModel *thirteenthUser = [TAPUserModel new];
        thirteenthUser.userID = @"13";
        thirteenthUser.xcUserID = @"13";
        thirteenthUser.fullname = @"Test 1";
        thirteenthUser.email = @"test1@moselo.com";
        thirteenthUser.phone = @"08979809026";
        thirteenthUser.username = @"test1";
        thirteenthUser.isRequestPending = NO;
        thirteenthUser.isRequestAccepted = YES;
        
        TAPUserModel *fourteenthUser = [TAPUserModel new];
        fourteenthUser.userID = @"14";
        fourteenthUser.xcUserID = @"14";
        fourteenthUser.fullname = @"Test 2";
        fourteenthUser.email = @"test2@moselo.com";
        fourteenthUser.phone = @"08979809026";
        fourteenthUser.username = @"test2";
        fourteenthUser.isRequestPending = NO;
        fourteenthUser.isRequestAccepted = YES;
        
        TAPUserModel *fifteenthUser = [TAPUserModel new];
        fifteenthUser.userID = @"15";
        fifteenthUser.xcUserID = @"15";
        fifteenthUser.fullname = @"Test 3";
        fifteenthUser.email = @"test3@moselo.com";
        fifteenthUser.phone = @"08979809026";
        fifteenthUser.username = @"test3";
        fifteenthUser.isRequestPending = NO;
        fifteenthUser.isRequestAccepted = YES;
        
        TAPUserModel *sixteenthUser = [TAPUserModel new];
        sixteenthUser.userID = @"17";
        sixteenthUser.xcUserID = @"16";
        sixteenthUser.fullname = @"Santo";
        sixteenthUser.email = @"santo@moselo.com";
        sixteenthUser.phone = @"08979809026";
        sixteenthUser.username = @"santo";
        sixteenthUser.isRequestPending = NO;
        sixteenthUser.isRequestAccepted = YES;
        
        [userResultArray addObject:firstUser];
        [userResultArray addObject:secondUser];
        [userResultArray addObject:thirdUser];
        [userResultArray addObject:fourthUser];
        [userResultArray addObject:fifthUser];
        [userResultArray addObject:sixthUser];
        [userResultArray addObject:seventhUser];
        [userResultArray addObject:eighthUser];
        [userResultArray addObject:ninthUser];
        [userResultArray addObject:tenthUser];
        [userResultArray addObject:eleventhUser];
        [userResultArray addObject:twelfthUser];
        [userResultArray addObject:thirteenthUser];
        [userResultArray addObject:fourteenthUser];
        [userResultArray addObject:fifteenthUser];
        [userResultArray addObject:sixteenthUser];
        //End Temp
        
        //Insert To Database
        [TAPDataManager updateOrInsertDatabaseContactWithData:userResultArray tableName:kDatabaseTableContact success:^{
            
        } failure:^(NSError *error) {
            
        }];
        
        success(userResultArray);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}

+ (void)callAPIAddContactWithUserID:(NSString *)userID
                            success:(void (^)(NSString *message))success
                            failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeAddContact];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:userID forKey:@"userID"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIAddContactWithUserID:userID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            success(@"");
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSString *successString = [NSString stringWithFormat:@"%ld", [[dataDictionary objectForKey:@"success"] integerValue]];
        successString = [TAPUtil nullToEmptyString:successString];
        NSString *message = [dataDictionary objectForKey:@"message"];
        message = [TAPUtil nullToEmptyString:message];
        
        success(message);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}

+ (void)callAPIRemoveContactWithUserID:(NSString *)userID
                               success:(void (^)(NSString *message))success
                               failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeRemoveContact];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:userID forKey:@"userID"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIRemoveContactWithUserID:userID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            success(@"");
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSString *successString = [NSString stringWithFormat:@"%ld", [[dataDictionary objectForKey:@"success"] integerValue]];
        successString = [TAPUtil nullToEmptyString:successString];
        NSString *message = [dataDictionary objectForKey:@"message"];
        message = [TAPUtil nullToEmptyString:message];
        
        success(message);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}

+ (void)callAPIGetUserByUserID:(NSString *)userID
                       success:(void (^)(TAPUserModel *user))success
                       failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetUserByUserID];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:userID forKey:@"id"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetUserByUserID:userID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            TAPUserModel *user = [TAPUserModel new];
            success(user);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSDictionary *userDictionary = [dataDictionary objectForKey:@"user"];
        userDictionary = [TAPUtil nullToEmptyDictionary:userDictionary];
        
        TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:userDictionary error:nil];
        
        success(user);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}

+ (void)callAPIGetUserByXCUserID:(NSString *)XCuserID
                         success:(void (^)(TAPUserModel *user))success
                         failure:(void (^)(NSError *error))failure; {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetUserByXCUserID];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:XCuserID forKey:@"xcUserID"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetUserByXCUserID:XCuserID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            TAPUserModel *user = [TAPUserModel new];
            success(user);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSDictionary *userDictionary = [dataDictionary objectForKey:@"user"];
        userDictionary = [TAPUtil nullToEmptyDictionary:userDictionary];
        
        TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:userDictionary error:nil];
        
        success(user);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}

+ (void)callAPIGetUserByUsername:(NSString *)username
                         success:(void (^)(TAPUserModel *user))success
                         failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetUserByUsername];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:username forKey:@"username"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetUserByUsername:username success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            TAPUserModel *user = [TAPUserModel new];
            success(user);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSDictionary *userDictionary = [dataDictionary objectForKey:@"user"];
        userDictionary = [TAPUtil nullToEmptyDictionary:userDictionary];
        
        TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:userDictionary error:nil];
        
        success(user);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}

+ (void)callAPIUpdatePushNotificationWithToken:(NSString *)token
                                       isDebug:(BOOL)isDebug
                                       success:(void (^)(void))success
                                       failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeUpdatePushNotification];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:@"" forKey:@"fcmToken"];
    [parameterDictionary setObject:token forKey:@"apnToken"];
    
    NSInteger isDebugInteger = 0;
    if(isDebug) {
        isDebugInteger = 1;
    }
    
    [parameterDictionary setObject:[NSNumber numberWithInteger:isDebugInteger] forKey:@"isDebug"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if(![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIUpdatePushNotificationWithToken:token isDebug:isDebug success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if(errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if([self isDataEmpty:responseObject]) {
            success();
            return;
        }
        
        success();
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError);
#endif
    }];
}


//DV Temp
+ (void)callAPIUpdateMessageDeliverStatusWithArray:(NSArray *)messageArray
                                           success:(void (^)(void))success
                                           failure:(void (^)(NSError *error))failure {
    //DV Note
    //TODO - wait until API Ready
}

+ (void)callAPIUpdateMessageReadStatusWithArray:(NSArray *)messageArray
                                        success:(void (^)(void))success
                                        failure:(void (^)(NSError *error))failure {
    //DV Note
    //TODO - wait until API Ready
}

//END DV Temp

@end
