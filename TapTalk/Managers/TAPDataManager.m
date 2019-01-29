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
    
    if (self) {
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
    if ([roomImageString isEqualToString:@""] || roomImageString == nil) {
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
    if ([userImageString isEqualToString:@""] || userImageString == nil) {
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
    if ([userRoleString isEqualToString:@""] || userRoleString == nil) {
        userRole.userRoleCode = @"";
        userRole.name = @"";
        userRole.iconURL = @"";
    }
    else {
        NSDictionary *userRoleJSONDictionary = [TAPUtil jsonObjectFromString:userRoleString];
        NSString *userRoleCode = [userRoleJSONDictionary objectForKey:@"userRoleCode"];
        userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
        userRole.userRoleCode = userRoleCode;
        
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
    
    TAPQuoteModel *quote = [TAPQuoteModel new];
    NSString *title = [dictionary objectForKey:@"quoteTitle"];
    title = [TAPUtil nullToEmptyString:title];
    quote.title = title;
    
    NSString *content = [dictionary objectForKey:@"quoteContent"];
    content = [TAPUtil nullToEmptyString:content];
    quote.content = content;
    
    NSString *fileID = [dictionary objectForKey:@"quoteFileID"];
    fileID = [TAPUtil nullToEmptyString:fileID];
    quote.fileID = fileID;
    
    NSString *imageURLString = [dictionary objectForKey:@"quoteImageURL"];
    imageURLString = [TAPUtil nullToEmptyString:imageURLString];
    quote.imageURL = imageURLString;
    
    message.quote = quote;
    
    TAPReplyToModel *replyTo = [TAPReplyToModel new];
    NSString *replyToMessageID = [dictionary objectForKey:@"replyToMessageID"];
    replyToMessageID = [TAPUtil nullToEmptyString:replyToMessageID];
    replyTo.messageID = replyToMessageID;
    
    NSString *replyToLocalID = [dictionary objectForKey:@"replyToLocalID"];
    replyToLocalID = [TAPUtil nullToEmptyString:replyToLocalID];
    replyTo.localID = replyToLocalID;
    
    NSInteger replyMessageType = [[dictionary objectForKey:@"replyMessageType"] integerValue];
    replyTo.messageType = replyMessageType;
    message.replyTo = replyTo;
    
    TAPForwardFromModel *forwardFrom = [TAPForwardFromModel new];
    NSString *forwardFromUserID = [dictionary objectForKey:@"forwardFromUserID"];
    forwardFromUserID = [TAPUtil nullToEmptyString:forwardFromUserID];
    forwardFrom.userID = forwardFromUserID;
    
    NSString *forwardFromXcUserID = [dictionary objectForKey:@"forwardFromXcUserID"];
    forwardFromXcUserID = [TAPUtil nullToEmptyString:forwardFromXcUserID];
    forwardFrom.xcUserID = forwardFromXcUserID;
    
    NSString *forwardFromFullname = [dictionary objectForKey:@"forwardFromFullname"];
    forwardFromFullname = [TAPUtil nullToEmptyString:forwardFromFullname];
    forwardFrom.fullname = forwardFromFullname;
    
    NSString *forwardFromMessageID = [dictionary objectForKey:@"forwardFromMessageID"];
    forwardFromMessageID = [TAPUtil nullToEmptyString:forwardFromMessageID];
    forwardFrom.messageID = forwardFromMessageID;
    
    NSString *forwardFromLocalID = [dictionary objectForKey:@"forwardFromLocalID"];
    forwardFromLocalID = [TAPUtil nullToEmptyString:forwardFromLocalID];
    forwardFrom.localID = forwardFromLocalID;
    message.forwardFrom = forwardFrom;
    
    return message;
}

+ (TAPMessageModel *)messageModelFromPayloadWithUserInfo:(NSDictionary *)dictionary {
    dictionary = [TAPUtil nullToEmptyDictionary:dictionary];
    
//    TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:dictionary error:nil];
    
    TAPMessageModel *message = [TAPEncryptorManager decryptToMessageModelFromDictionary:dictionary];
    
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
    NSString *userRoleCode = [userRoleDictionary objectForKey:@"userRoleCode"];
    userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
    userRole.userRoleCode = userRoleCode;
    
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
    
    NSDictionary *quoteDictionary = [dictionary objectForKey:@"quote"];
    TAPQuoteModel *quote = [TAPQuoteModel new];
    NSString *title = [quoteDictionary objectForKey:@"title"];
    title = [TAPUtil nullToEmptyString:title];
    quote.title = title;
    
    NSString *content = [quoteDictionary objectForKey:@"content"];
    content = [TAPUtil nullToEmptyString:content];
    quote.content = content;
    
    NSString *fileID = [quoteDictionary objectForKey:@"fileID"];
    fileID = [TAPUtil nullToEmptyString:fileID];
    quote.fileID = fileID;
    
    NSString *imageURL = [quoteDictionary objectForKey:@"imageURL"];
    imageURL = [TAPUtil nullToEmptyString:imageURL];
    quote.imageURL = imageURL;
    message.quote = quote;
    
    NSDictionary *replyToDictionary = [dictionary objectForKey:@"replyTo"];
    TAPReplyToModel *replyTo = [TAPReplyToModel new];
    NSString *replyToMessageID = [replyToDictionary objectForKey:@"messageID"];
    replyToMessageID = [TAPUtil nullToEmptyString:replyToMessageID];
    replyTo.messageID = replyToMessageID;
    
    NSString *replyToLocalID = [replyToDictionary objectForKey:@"localID"];
    replyToLocalID = [TAPUtil nullToEmptyString:replyToLocalID];
    replyTo.localID = replyToLocalID;
    
    NSInteger replyMessageType = [[replyToDictionary objectForKey:@"messageType"] integerValue];
    replyTo.messageType = replyMessageType;
    message.replyTo = replyTo;
    
    NSDictionary *forwardFromDictionary = [dictionary objectForKey:@"forwardFrom"];
    TAPForwardFromModel *forwardFrom = [TAPForwardFromModel new];
    NSString *forwardFromUserID = [forwardFromDictionary objectForKey:@"userID"];
    forwardFromUserID = [TAPUtil nullToEmptyString:forwardFromUserID];
    forwardFrom.userID = forwardFromUserID;
    
    NSString *forwardFromXcUserID = [forwardFromDictionary objectForKey:@"xcUserID"];
    forwardFromXcUserID = [TAPUtil nullToEmptyString:forwardFromXcUserID];
    forwardFrom.xcUserID = forwardFromXcUserID;
    
    NSString *forwardFromFullname = [forwardFromDictionary objectForKey:@"fullname"];
    forwardFromFullname = [TAPUtil nullToEmptyString:forwardFromFullname];
    forwardFrom.fullname = forwardFromFullname;
    
    NSString *forwardFromMessageID = [forwardFromDictionary objectForKey:@"messageID"];
    forwardFromMessageID = [TAPUtil nullToEmptyString:forwardFromMessageID];
    forwardFrom.messageID = forwardFromMessageID;
    
    NSString *forwardFromLocalID = [forwardFromDictionary objectForKey:@"localID"];
    forwardFromLocalID = [TAPUtil nullToEmptyString:forwardFromLocalID];
    forwardFrom.localID = forwardFromLocalID;
    message.forwardFrom = forwardFrom;
    
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
    if ([imageURLString isEqualToString:@""] || imageURLString == nil) {
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
    NSString *userRoleCode = [dictionary objectForKey:@"userRoleCode"];
    userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
    userRole.userRoleCode = userRoleCode;
    
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
    if ([imageURLString isEqualToString:@""] || imageURLString == nil) {
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
    
    NSDictionary *quoteDictionary = [messageMutableDictionary objectForKey:@"quote"];
    NSString *title = [quoteDictionary objectForKey:@"title"];
    title = [TAPUtil nullToEmptyString:title];
    [messageMutableDictionary setValue:title forKey:@"quoteTitle"];
    
    NSString *content = [quoteDictionary objectForKey:@"content"];
    content = [TAPUtil nullToEmptyString:content];
    [messageMutableDictionary setValue:content forKey:@"quoteContent"];
    
    NSString *fileID = [quoteDictionary objectForKey:@"fileID"];
    fileID = [TAPUtil nullToEmptyString:fileID];
    [messageMutableDictionary setValue:fileID forKey:@"quoteFileID"];
    
    NSString *imageURL = [quoteDictionary objectForKey:@"imageURL"];
    imageURL = [TAPUtil nullToEmptyString:imageURL];
    [messageMutableDictionary setValue:imageURL forKey:@"quoteImageURL"];
    
    [messageMutableDictionary removeObjectForKey:@"quote"];
    
    NSDictionary *replyToDictionary = [messageMutableDictionary objectForKey:@"replyTo"];
    NSString *messageID = [replyToDictionary objectForKey:@"messageID"];
    messageID = [TAPUtil nullToEmptyString:messageID];
    [messageMutableDictionary setValue:messageID forKey:@"replyToMessageID"];
    
    NSString *localID = [replyToDictionary objectForKey:@"localID"];
    localID = [TAPUtil nullToEmptyString:localID];
    [messageMutableDictionary setValue:localID forKey:@"replyToLocalID"];
    
    NSNumber *messageType = [replyToDictionary objectForKey:@"messageType"];
    messageType = [TAPUtil nullToEmptyNumber:messageType];
    [messageMutableDictionary setValue:messageType forKey:@"replyMessageType"];
    
    [messageMutableDictionary removeObjectForKey:@"replyTo"];
    
    NSDictionary *forwardFromDictionary = [messageMutableDictionary objectForKey:@"forwardFrom"];
    NSString *forwardFromUserID = [forwardFromDictionary objectForKey:@"userID"];
    forwardFromUserID = [TAPUtil nullToEmptyString:forwardFromUserID];
    [messageMutableDictionary setValue:forwardFromUserID forKey:@"forwardFromUserID"];
   
    NSString *forwardFromXcUserID = [forwardFromDictionary objectForKey:@"xcUserID"];
    forwardFromXcUserID = [TAPUtil nullToEmptyString:forwardFromXcUserID];
    [messageMutableDictionary setValue:forwardFromXcUserID forKey:@"forwardFromXcUserID"];
    
    NSString *forwardFromFullname = [forwardFromDictionary objectForKey:@"fullname"];
    forwardFromFullname = [TAPUtil nullToEmptyString:forwardFromFullname];
    [messageMutableDictionary setValue:forwardFromFullname forKey:@"forwardFromFullname"];
    
    NSString *forwardFromMessageID = [forwardFromDictionary objectForKey:@"messageID"];
    forwardFromMessageID = [TAPUtil nullToEmptyString:forwardFromMessageID];
    [messageMutableDictionary setValue:forwardFromMessageID forKey:@"forwardFromMessageID"];
    
    NSString *forwardFromLocalID = [forwardFromDictionary objectForKey:@"localID"];
    forwardFromLocalID = [TAPUtil nullToEmptyString:forwardFromLocalID];
    [messageMutableDictionary setValue:forwardFromLocalID forKey:@"forwardFromLocalID"];
    
    [messageMutableDictionary removeObjectForKey:@"forwardFrom"];
    
    NSDictionary *dataDictionary = [messageMutableDictionary objectForKey:@"data"];
    [messageMutableDictionary setValue:[TAPUtil jsonStringFromObject:dataDictionary] forKey:@"data"];
    
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
    
    NSDictionary *imageURLDictionary = [userDictionary objectForKey:@"imageURL"];
    imageURLDictionary = [TAPUtil nullToEmptyDictionary:imageURLDictionary];
    NSString *imageURL = [TAPUtil jsonStringFromObject:imageURLDictionary];
    imageURL = [TAPUtil nullToEmptyString:imageURL];
    [userMutableDictionary setValue:imageURL forKey:@"imageURL"];
    
    NSDictionary *userRole = [userDictionary objectForKey:@"userRole"];
    userRole = [TAPUtil nullToEmptyDictionary:userRole];
    NSString *userRoleCode = [userRole objectForKey:@"userRoleCode"];
    userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
    [userMutableDictionary setValue:userRoleCode forKey:@"userRoleCode"];
    
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
    
    if (dataDictionary == nil || [dataDictionary allKeys].count == 0) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isResponseSuccess:(NSDictionary *)responseDictionary {
    NSDictionary *errorDictionary = [responseDictionary objectForKey:@"error"];
    
    if (errorDictionary == nil || [errorDictionary allKeys].count == 0) {
        return YES;
    }
    
    NSInteger httpStatusCode = [[responseDictionary valueForKeyPath:@"status"] integerValue];
    
//    if (errorCode == 299 || errorCode == 499) {
//        //Success but need to refresh token = 299
//        //Failed but need to refresh token = 499 - if errorCode == 499 need to reload API
//
//        if (errorCode == 299) {
//            BOOL isCallingAPIRefreshToken = [[NSUserDefaults standardUserDefaults] secretBoolForKey:PREFS_IS_CALLING_API_REFRESH_TOKEN];
//            if (!isCallingAPIRefreshToken) {
//                [TAPDataManager performSelector:@selector(callAPIRefreshToken) withObject:nil afterDelay:1.0f];
//            }
//        }
//
//        return YES;
//    }
    if ([[NSString stringWithFormat:@"%li", (long)httpStatusCode] hasPrefix:@"2"]) {
        return YES;
    }
    
    return NO;
}


+ (void)setActiveUser:(TAPUserModel *)user {
    if (user != nil) {
        NSDictionary *userDictionary = [user toDictionary];
        
        //Update user in chat manager
        [TAPChatManager sharedManager].activeUser = user;
        
        [[NSUserDefaults standardUserDefaults] setSecureObject:userDictionary forKey:TAP_PREFS_ACTIVE_USER];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (TAPUserModel *)getActiveUser {
    NSDictionary *userDictionary = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_ACTIVE_USER valid:nil];
    
    if (userDictionary == nil) {
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

+ (void)updateMessageToFailedWithLocalID:(NSString *)localID {
    [[TAPDatabaseManager sharedManager] updateMessageToFailedWithColumnName:@"localID" value:localID];
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
        for (NSInteger count = 0; count < [resultArray count]; count++) {
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
        
        if ([messageArray count] == 0) {
            success([NSArray array]);
        }
        else {
            NSMutableArray *modelArray = [NSMutableArray array];
            for (NSInteger count = 0; count < [messageArray count]; count++) {
                NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[messageArray objectAtIndex:count]];

                TAPMessageModel *messageModel = [TAPDataManager messageModelFromDictionary:databaseDictionary];
                [modelArray addObject:messageModel];
                
                NSError *error;
                
                if (error) {
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
        
        if ([messageArray count] == 0) {
            success([NSArray array]);
        }
        else {
            NSMutableArray *modelArray = [NSMutableArray array];
            for (NSInteger count = 0; count < [messageArray count]; count++) {
                NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[messageArray objectAtIndex:count]];
                
                TAPMessageModel *messageModel = [TAPDataManager messageModelFromDictionary:databaseDictionary];
                [modelArray addObject:messageModel];
                
                NSError *error;
                
                if (error) {
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
        for (NSInteger count = 0; count < [messageArray count]; count++) {
            NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[messageArray objectAtIndex:count]];
            
            TAPMessageModel *messageModel = [TAPDataManager messageModelFromDictionary:databaseDictionary];
            [modelArray addObject:messageModel];
            
            NSError *error;
            
            if (error) {
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
        for (NSDictionary *databaseDictionary in resultArray) {
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
        for (NSDictionary *databaseDictionary in resultArray) {
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
        for (NSDictionary *databaseDictionary in resultArray) {
            TAPMessageModel *message = [TAPDataManager messageModelFromDictionary:databaseDictionary];
            [obtainedArray addObject:message];
        }
        
        success(resultArray);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)getDatabaseUnreadRoomCountWithActiveUserID:(NSString *)activeUserID
                                           success:(void (^)(NSInteger))success
                                           failure:(void (^)(NSError *))failure {
    NSString *queryString = [NSString stringWithFormat:@"isRead == 0 && !(userID LIKE '%@')", activeUserID];
    
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableMessage whereClauseQuery:queryString sortByColumnName:@"" isAscending:NO distinctBy:@"roomID" success:^(NSArray *resultArray) {
        
        resultArray = [TAPUtil nullToEmptyArray:resultArray];
        
        success([resultArray count]);
        
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
        for (NSInteger count = 0; count < [databaseArray count]; count++) {
            NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[databaseArray objectAtIndex:count]];
            
            TAPMessageModel *messageModel = [TAPDataManager messageModelFromDictionary:databaseDictionary];
            TAPRoomModel *room = messageModel.room;
            [modelDictionary setObject:room forKey:room.roomID];
        }
        
        queryClause = [NSString stringWithFormat:@"fullname CONTAINS[c] \'%@\'", alphaNumericSearchString];
        [TAPDatabaseManager loadDataFromTableName:kDatabaseTableContact whereClauseQuery:queryClause sortByColumnName:@"fullname" isAscending:YES success:^(NSArray *resultArray) {
            for (NSInteger count = 0; count < [resultArray count]; count++) {
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
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseWithData:messageDictionaryArray tableName:kDatabaseTableMessage success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)updateOrInsertDatabaseMessageInMainThreadWithData:(NSArray *)dataArray
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
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseInMainThreadWithData:messageDictionaryArray tableName:kDatabaseTableMessage success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)updateOrInsertDatabaseRecentSearchWithData:(NSArray *)dataArray
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
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseWithData:recentSearchDictionaryArray tableName:kDatabaseTableRecentSearch success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)updateOrInsertDatabaseContactWithData:(NSArray *)dataArray
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
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseWithData:userDictionaryArray tableName:kDatabaseTableContact success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)updateMessageReadStatusToDatabaseWithData:(NSArray *)dataArray
                                          success:(void (^)(void))success
                                          failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    
    NSMutableArray *messageDictionaryArray = [NSMutableArray array];
    for (TAPMessageModel *message in dataArray) {

        //Changing isRead & isDelivered to true
        message.isRead = YES;
        message.isDelivered = YES;
        
        NSDictionary *messageDictionary = [TAPDataManager dictionaryFromMessageModel:message];
        messageDictionary = [TAPUtil nullToEmptyDictionary:messageDictionary];
        
        [messageDictionaryArray addObject:messageDictionary];
    }
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseWithData:messageDictionaryArray tableName:kDatabaseTableMessage success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)updateMessageDeliveryStatusToDatabaseWithData:(NSArray *)dataArray
                                              success:(void (^)(void))success
                                              failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    
    NSMutableArray *messageDictionaryArray = [NSMutableArray array];
    for (TAPMessageModel *message in dataArray) {
        
        //Changing isDelivered to true
        message.isDelivered = YES;
        
        NSDictionary *messageDictionary = [TAPDataManager dictionaryFromMessageModel:message];
        messageDictionary = [TAPUtil nullToEmptyDictionary:messageDictionary];
        
        [messageDictionaryArray addObject:messageDictionary];
    }
    
    [TAPDatabaseManager updateOrInsertDataToDatabaseWithData:messageDictionaryArray tableName:kDatabaseTableMessage success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)deleteDatabaseMessageWithData:(NSArray *)dataArray
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
    
    [TAPDatabaseManager deleteDataInDatabaseWithData:messageDictionaryArray tableName:kDatabaseTableMessage success:^{
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

+ (void)deleteDatabaseAllRecentSearchSuccess:(void (^)(void))success
                                     failure:(void (^)(NSError *error))failure {
    [TAPDatabaseManager deleteAllDataFromTableName:kDatabaseTableRecentSearch success:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
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

+ (void)getDatabaseAllUserSortBy:(NSString *)columnName
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

+ (void)getDatabaseAllContactSortBy:(NSString *)columnName
                            success:(void (^)(NSArray *resultArray))success
                            failure:(void (^)(NSError *error))failure {
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableContact 
                            whereClauseQuery:@"isContact = true"
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
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
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
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
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
        
        if (self.isShouldRefreshToken) {
            NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeRefreshAccessToken];
            NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
            NSString *refreshToken = [TAPDataManager getRefreshToken];
            
            [[TAPNetworkManager sharedManager] post:requestURL refreshToken:refreshToken parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
                
            } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
                if (![TAPDataManager isResponseSuccess:responseObject]) {
                    NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
                    NSString *errorMessage = [errorDictionary objectForKey:@"message"];
                    errorMessage = [TAPUtil nullToEmptyString:errorMessage];
                    
                    NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
                    
                    if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                        errorCode = 999;
                    }
                    
                    if (errorCode >= 40103 && errorCode <= 40106) {
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
                
                if ([TAPDataManager isDataEmpty:responseObject]) {
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
        if (![self isResponseSuccess:responseObject]) {
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
        if (![self isResponseSuccess:responseObject]) {
            
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetMessageRoomListAndUnreadWithUserID:userID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
            success([NSArray array]);
            return;
        }
        
        NSArray *messageArray = [responseObject valueForKeyPath:@"data.messages"];
        messageArray = [TAPUtil nullToEmptyArray:messageArray];
        
        NSMutableArray *tempRecipientIDArray = [NSMutableArray array];
    
        NSMutableArray *messageResultArray = [NSMutableArray array];
        for (NSDictionary *messageDictionary in messageArray) {
            
//            TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:messageDictionary error:nil];
            
            //Decrypt message
            TAPMessageModel *decryptedMessage = [TAPEncryptorManager decryptToMessageModelFromDictionary:messageDictionary];
            
            if([decryptedMessage.user.userID isEqualToString:[self getActiveUser].userID]) {
                NSString *currentOtherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:decryptedMessage.room.roomID];
                [tempRecipientIDArray addObject:currentOtherUserID];
            }
            else {
                //Add User to Contact Manager
                [[TAPContactManager sharedManager] addContactWithUserModel:decryptedMessage.user saveToDatabase:NO];
            }
    
            [messageResultArray addObject:decryptedMessage];
            
        }
        
        if([tempRecipientIDArray count] > 0) {
            //call get multiple user API to populate contact
            [TAPDataManager callAPIGetBulkUserByUserID:tempRecipientIDArray success:^(NSArray *userModelArray) {
            } failure:^(NSError *error) {
            }];
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
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetNewAndUpdatedMessageSuccess:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
            success([NSArray array]);
            return;
        }
        
        NSArray *messageArray = [responseObject valueForKeyPath:@"data.messages"];
        messageArray = [TAPUtil nullToEmptyArray:messageArray];
        
        NSMutableArray *messageResultArray = [NSMutableArray array];
        for (NSDictionary *messageDictionary in messageArray) {
            
            //Decrypt message
            TAPMessageModel *decryptedMessage = [TAPEncryptorManager decryptToMessageModelFromDictionary:messageDictionary];
            
            //Add User to Contact Manager
            [[TAPContactManager sharedManager] addContactWithUserModel:decryptedMessage.user saveToDatabase:NO];
            
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
    if(roomID == nil || [roomID isEqualToString:@""]) {
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"Input Error", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Room not found", @"")}];
        failure(localizedError);
        return;
    }
    
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetMessageRoomListAfter];
    
    //Obtain Last Updated Value
    NSNumber *lastUpdated = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];

    NSInteger formattedMinCreated = [minCreated integerValue];
    NSNumber *formattedMinCreatedNum;
    if (formattedMinCreated < 0) {
        formattedMinCreatedNum = [NSNumber numberWithInteger:0];
    }
    else {
        formattedMinCreatedNum = minCreated;
    }
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:formattedMinCreatedNum forKey:@"minCreated"];
    [parameterDictionary setObject:lastUpdated forKey:@"lastUpdated"];

    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {

    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];

            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetMessageAfterWithRoomID:roomID minCreated:minCreated success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];

            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }

            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }

        if ([self isDataEmpty:responseObject]) {
            success([NSArray array]);
            return;
        }

        NSArray *messageArray = [responseObject valueForKeyPath:@"data.messages"];
        messageArray = [TAPUtil nullToEmptyArray:messageArray];
        
        //Obtain latest updated value
        NSNumber *preferenceLastUpdated = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];
        
        NSMutableArray *messageResultArray = [NSMutableArray array];
        for (NSDictionary *messageDictionary in messageArray) {
            //Decrypt message
            TAPMessageModel *decryptedMessage = [TAPEncryptorManager decryptToMessageModelFromDictionary:messageDictionary];
            [messageResultArray addObject:decryptedMessage];
            
            if ([preferenceLastUpdated longLongValue] < [decryptedMessage.updated longLongValue]) {
                preferenceLastUpdated = [NSNumber numberWithLongLong:[decryptedMessage.updated longLongValue]];
            }
        }
        
        //Set newest last updated to preference
        [TAPDataManager setMessageLastUpdatedWithRoomID:roomID lastUpdated:preferenceLastUpdated];
        
        //Insert To Database
        [TAPDataManager updateOrInsertDatabaseMessageWithData:messageResultArray success:^{
            
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
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];

            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetMessageBeforeWithRoomID:roomID maxCreated:maxCreated success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];

            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }

            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }

        if ([self isDataEmpty:responseObject]) {
            success([NSArray array], [NSDictionary dictionary]);
            return;
        }

        NSArray *messageArray = [responseObject valueForKeyPath:@"data.messages"];
        messageArray = [TAPUtil nullToEmptyArray:messageArray];

        NSMutableArray *messageResultArray = [NSMutableArray array];
        for (NSDictionary *messageDictionary in messageArray) {
            //Decrypt message
            TAPMessageModel *decryptedMessage = [TAPEncryptorManager decryptToMessageModelFromDictionary:messageDictionary];
            [messageResultArray addObject:decryptedMessage];
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        BOOL hasMore = [[dataDictionary objectForKey:@"hasMore"] boolValue];
 
        //Insert To Database
        [TAPDataManager updateOrInsertDatabaseMessageWithData:messageResultArray success:^{
            
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
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetContactList:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
            success([NSArray array]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSArray *userArray = [dataDictionary objectForKey:@"contacts"];
        userArray = [TAPUtil nullToEmptyArray:userArray];
        
        NSMutableArray *userResultArray = [NSMutableArray array];
        // WK NOTE - UNCOMMENT THIS CODE TO REMOVE TEMPORARY ADD CONTACTS TO DATABASE
        for (NSDictionary *userDictionary in userArray) {
//            TAPContactModel *contact = [TAPContactModel new];
            NSDictionary *obtainedUserDictionary = [userDictionary objectForKey:@"user"];
            obtainedUserDictionary = [TAPUtil nullToEmptyDictionary:obtainedUserDictionary];
            
            TAPUserModel *user = [TAPUserModel new];
         
            NSString *userID = [obtainedUserDictionary objectForKey:@"userID"];
            userID = [TAPUtil nullToEmptyString:userID];
            user.userID = userID;
         
            NSString *xcUserID = [obtainedUserDictionary objectForKey:@"xcUserID"];
            xcUserID = [TAPUtil nullToEmptyString:xcUserID];
            user.xcUserID = xcUserID;
         
            NSString *fullname = [obtainedUserDictionary objectForKey:@"fullname"];
            fullname = [TAPUtil nullToEmptyString:fullname];
            user.fullname = fullname;
         
            NSString *email = [obtainedUserDictionary objectForKey:@"email"];
            email = [TAPUtil nullToEmptyString:email];
            user.email = email;
         
            NSString *phone = [obtainedUserDictionary objectForKey:@"phone"];
            phone = [TAPUtil nullToEmptyString:phone];
            user.phone = phone;
         
            NSString *username = [obtainedUserDictionary objectForKey:@"username"];
            username = [TAPUtil nullToEmptyString:username];
            user.username = username;
         
            NSDictionary *imageURLDictionary = [obtainedUserDictionary objectForKey:@"imageURL"];
            TAPImageURLModel *imageURL = [TAPImageURLModel new];
            NSString *thumbnail = [imageURLDictionary objectForKey:@"thumbnail"];
            thumbnail = [TAPUtil nullToEmptyString:thumbnail];
            imageURL.thumbnail = thumbnail;
            
            NSString *fullsize = [imageURLDictionary objectForKey:@"fullsize"];
            fullsize = [TAPUtil nullToEmptyString:fullsize];
            imageURL.fullsize = fullsize;
            user.imageURL = imageURL;
            
            NSDictionary *userRoleDictionary = [obtainedUserDictionary objectForKey:@"userRole"];
            TAPUserRoleModel *userRole = [TAPUserRoleModel new];
            NSString *userRoleCode = [userRoleDictionary objectForKey:@"userRoleCode"];
            userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
            userRole.userRoleCode = userRoleCode;
         
            NSString *name = [userRoleDictionary objectForKey:@"name"];
            name = [TAPUtil nullToEmptyString:name];
            userRole.name = name;
         
            NSString *iconURL = [userRoleDictionary objectForKey:@"iconURL"];
            iconURL = [TAPUtil nullToEmptyString:iconURL];
            userRole.iconURL = iconURL;
            user.userRole = userRole;
         
            NSNumber *lastLogin = [obtainedUserDictionary objectForKey:@"lastLogin"];
            lastLogin = [TAPUtil nullToEmptyNumber:lastLogin];
            user.lastLogin = lastLogin;
         
            NSNumber *lastActivity = [obtainedUserDictionary objectForKey:@"lastActivity"];
            lastActivity = [TAPUtil nullToEmptyNumber:lastActivity];
            user.lastActivity = lastActivity;
         
            NSNumber *created = [obtainedUserDictionary objectForKey:@"created"];
            created = [TAPUtil nullToEmptyNumber:created];
            user.created = created;
         
            NSNumber *updated = [obtainedUserDictionary objectForKey:@"updated"];
            updated = [TAPUtil nullToEmptyNumber:updated];
            user.updated = updated;
//            contact.user = user;
//
            BOOL isRequestPending = [[userDictionary objectForKey:@"isRequestPending"] boolValue];
            user.isRequestPending = isRequestPending;

            BOOL isRequestAccepted = [[userDictionary objectForKey:@"isRequestAccepted"] boolValue];
            user.isRequestAccepted = isRequestAccepted;
            
            user.isContact = YES;
            
            //Add User to Contact Manager
            [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO];
            
            [userResultArray addObject:user];
        }
        
        //Insert To Database
        [TAPDataManager updateOrInsertDatabaseContactWithData:userResultArray success:^{
            
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
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIAddContactWithUserID:userID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
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
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIRemoveContactWithUserID:userID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
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
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetUserByUserID:userID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
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

+ (void)callAPIGetUserByXCUserID:(NSString *)XCUserID
                         success:(void (^)(TAPUserModel *user))success
                         failure:(void (^)(NSError *error))failure; {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetUserByXCUserID];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:XCUserID forKey:@"xcUserID"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetUserByXCUserID:XCUserID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
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
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetUserByUsername:username success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
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
    if (isDebug) {
        isDebugInteger = 1;
    }
    
    [parameterDictionary setObject:[NSNumber numberWithInteger:isDebugInteger] forKey:@"isDebug"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIUpdatePushNotificationWithToken:token isDebug:isDebug success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
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

+ (void)callAPIUpdateMessageDeliverStatusWithArray:(NSArray *)messageArray
                                           success:(void (^)(NSArray *updatedMessageIDsArray))success
                                           failure:(void (^)(NSError *error, NSArray *messageArray))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeUpdateMessageDeliveryStatus];
    
    NSMutableArray *messageIDsArray = [NSMutableArray array];
    NSArray *tempMessageArray = [messageArray copy];
    
    for (TAPMessageModel *message in tempMessageArray) {
        [messageIDsArray addObject:message.messageID];
    }
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:messageIDsArray forKey:@"messageIDs"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIUpdateMessageDeliverStatusWithArray:tempMessageArray success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error, messageArray);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error, messageArray);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
            success([NSArray array]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        
        NSArray *updatedMessageIDsArray = [dataDictionary objectForKey:@"updatedMessageIDs"];
        updatedMessageIDsArray = [TAPUtil nullToEmptyArray:updatedMessageIDsArray];
        
        success(updatedMessageIDsArray);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError, messageIDsArray);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError, messageIDsArray);
#endif
    }];
}

+ (void)callAPIUpdateMessageReadStatusWithArray:(NSArray *)messageArray
                                        success:(void (^)(NSArray *updatedMessageIDsArray))success
                                        failure:(void (^)(NSError *error, NSArray *messageArray))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeUpdateMessageReadStatus];
    
    NSMutableArray *messageIDsArray = [NSMutableArray array];
    NSArray *tempMessageArray = [messageArray copy];
    
    for (TAPMessageModel *message in tempMessageArray) {
        [messageIDsArray addObject:message.messageID];
    }
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:messageIDsArray forKey:@"messageIDs"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if(errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIUpdateMessageReadStatusWithArray:tempMessageArray success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error, messageArray);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error, messageArray);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
            success([NSArray array]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        
        NSArray *updatedMessageIDsArray = [dataDictionary objectForKey:@"updatedMessageIDs"];
        updatedMessageIDsArray = [TAPUtil nullToEmptyArray:updatedMessageIDsArray];
        
        success(updatedMessageIDsArray);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [TAPDataManager logErrorStringFromError:error];
        
#ifdef DEBUG
        NSString *errorDomain = error.domain;
        NSString *newDomain = [NSString stringWithFormat:@"%@ ~ %@", requestURL, errorDomain];
        
        NSError *newError = [NSError errorWithDomain:newDomain code:error.code userInfo:error.userInfo];
        
        failure(newError, messageIDsArray);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError, messageIDsArray);
#endif
    }];
}

+ (NSURLSessionUploadTask *)callAPIUploadFileWithFileData:(NSData *)fileData
                               roomID:(NSString *)roomID
                             fileType:(NSString *)fileType
                             mimeType:(NSString *)mimeType
                              caption:(NSString *)caption
                      completionBlock:(void (^)(NSDictionary *responseObject))successBlock
                        progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
                         failureBlock:(void(^)(NSError *error))failureBlock {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeUploadFile];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:fileType forKey:@"fileType"];
    
    if (caption != nil && ![caption isEqualToString:@""]) {
        [parameterDictionary setObject:caption forKey:@"caption"];
    }
    
    NSURLSessionUploadTask *uploadTask = [[TAPNetworkManager sharedManager] upload:requestURL fileData:fileData mimeType:mimeType parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        CGFloat progress = uploadProgress.fractionCompleted;
        progressBlock(progress, 1.0f);
    } success:^(NSDictionary *responseObject) {
        successBlock(responseObject);
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
    
    return uploadTask;
}

+ (void)callAPIDownloadFileWithFileID:(NSString *)fileID
                               roomID:(NSString *)roomID
                          isThumbnail:(BOOL)isThumbnail
                      completionBlock:(void (^)(UIImage *downloadedImage))successBlock
                        progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
                         failureBlock:(void(^)(NSError *error))failureBlock {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeDownloadFile];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:fileID forKey:@"fileID"];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:[NSNumber numberWithBool:isThumbnail] forKey:@"isThumbnail"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        CGFloat progress = uploadProgress.fractionCompleted;
        progressBlock(progress, 1.0f);
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        
        //DV Note
        /*
        This API is different from others in response format.
        If other APIs return response in JSON format, this API returns response based on the download file's content type.
        So success block in use to handle fail response and failure block is use to handle success response
        Because AFNetworking check whether response is in json format or not, since failure response is in json format
        so it will be handled in success block, and success response will return the data file,
        hence it will be handled in failure block.
        */
        //END DV Note
        
        NSString *errorCode = [responseObject valueForKeyPath:@"error.code"];
        NSString *errorMessage = [responseObject valueForKeyPath:@"error.message"];
        NSString *errorStatus = [responseObject objectForKey:@"status"];
    
        NSMutableDictionary *errorDictionary = [NSMutableDictionary dictionary];
        [errorDictionary setObject:errorCode forKey:@"errorCode"];
        [errorDictionary setObject:errorMessage forKey:@"errorMessage"];
        [errorDictionary setObject:errorStatus forKey:@"errorStatus"];
        
        NSError *error = [NSError errorWithDomain:@"Error" code:errorCode userInfo:errorDictionary];
        failureBlock(error);
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        //DV Note
        /*
         This API is different from others in response format.
         If other APIs return response in JSON format, this API returns response based on the download file's content type.
         So success block in use to handle fail response and failure block is use to handle success response
         Because AFNetworking check whether response is in json format or not, since failure response is in json format
         so it will be handled in success block, and success response will return the data file,
         hence it will be handled in failure block.
         */
        //END DV Note
        
        //DV Temp
#ifdef DEBUG
        isThumbnail ? NSLog(@"THUMBNAIL") : NSLog(@"NO THUMBNAIL");
#endif
        //END DV Temp
        
        NSDictionary *responseObjectDictionary = error.userInfo;
        NSData *imageData = [responseObjectDictionary objectForKey:@"com.alamofire.serialization.response.error.data"];
        UIImage *downloadedImage = [UIImage imageWithData:imageData];
        successBlock(downloadedImage);
    }];

}

+ (void)callAPIGetBulkUserByUserID:(NSArray *)userIDArray
                           success:(void (^)(NSArray *userModelArray))success
                           failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetBulkUserByID];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:userIDArray forKey:@"ids"];
    
    [[TAPNetworkManager sharedManager] post:requestURL parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *dataTask, NSDictionary *responseObject) {
        if (![self isResponseSuccess:responseObject]) {
            NSDictionary *errorDictionary = [responseObject objectForKey:@"error"];
            NSString *errorMessage = [errorDictionary objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            
            NSString *errorStatusCodeString = [responseObject objectForKey:@"status"];
            errorStatusCodeString = [TAPUtil nullToEmptyString:errorStatusCodeString];
            NSInteger errorStatusCode = [errorStatusCodeString integerValue];
            
            if (errorStatusCode == 401) {
                //Call refresh token
                [[TAPDataManager sharedManager] callAPIRefreshAccessTokenSuccess:^{
                    [TAPDataManager callAPIGetBulkUserByUserID:userIDArray success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:errorMessage code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
            TAPUserModel *user = [TAPUserModel new];
            success(user);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSArray *userArray = [dataDictionary objectForKey:@"users"];
        userArray = [TAPUtil nullToEmptyArray:userArray];
        
        NSMutableArray *userModelArray = [NSMutableArray new];
        
        for (NSDictionary *userDictionary in userArray) {
             TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:userDictionary error:nil];
            
            //Add User to Contact Manager
            [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO];
            
            [userModelArray addObject:user];
        }
        
        success(userModelArray);
        
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

@end
