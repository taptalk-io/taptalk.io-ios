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

+ (TAPCoreConfigsModel *)coreConfigsModelFromDictionary:(NSDictionary *)dictionary;
+ (TAPProjectConfigsModel *)projectConfigsModelFromDictionary:(NSDictionary *)dictionary;

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
 DV NOTE - THESE METHODS ARE CONVERTION FROM MODEL TO REALMMODEL
 FOR EXAMPLE:
 -> FROM messageRealmDictionary TO messageModel
 -> FROM messageModel TO messageRealmDictionary
 END NOTE
 */
#pragma mark From Dictionary
+ (TAPMessageModel *)messageModelFromDictionary:(NSDictionary *)dictionary {
    dictionary = [TAPUtil nullToEmptyDictionary:dictionary];
    
    TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:dictionary error:nil];
    
    message.body = [TAPDataManager normalizedDatabaseStringFromString:message.body];
    
    TAPRoomModel *room = [TAPRoomModel new];
    NSString *roomID = [dictionary objectForKey:@"roomID"];
    roomID = [TAPUtil nullToEmptyString:roomID];
    room.roomID = roomID;
    
    NSString *roomName = [dictionary objectForKey:@"roomName"];
    roomName = [TAPUtil nullToEmptyString:roomName];
    roomName = [TAPDataManager normalizedDatabaseStringFromString:roomName];
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
    
    BOOL roomIsDeleted = [[dictionary objectForKey:@"roomIsDeleted"] boolValue];
    room.isDeleted = roomIsDeleted;
    
    NSInteger roomDeleted = [[dictionary objectForKey:@"roomDeleted"] integerValue];
    room.deleted = [NSNumber numberWithInteger:roomDeleted];
    
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
    
    NSString *phoneWithCode = [dictionary objectForKey:@"phoneWithCode"];
    phoneWithCode = [TAPUtil nullToEmptyString:phoneWithCode];
    user.phoneWithCode = phoneWithCode;
    
    NSString *countryCallingCode = [dictionary objectForKey:@"countryCallingCode"];
    countryCallingCode = [TAPUtil nullToEmptyString:countryCallingCode];
    user.countryCallingCode = countryCallingCode;
    
    NSString *countryID = [dictionary objectForKey:@"countryID"];
    countryID = [TAPUtil nullToEmptyString:countryID];
    user.countryID = countryID;
    
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
        userRole.code = @"";
        userRole.name = @"";
        userRole.iconURL = @"";
    }
    else {
        NSDictionary *userRoleJSONDictionary = [TAPUtil jsonObjectFromString:userRoleString];
        NSString *userRoleCode = [userRoleJSONDictionary objectForKey:@"code"];
        userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
        userRole.code = userRoleCode;
        
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
    
    NSNumber *userDeleted = [dictionary objectForKey:@"userDeleted"];
    userDeleted = [TAPUtil nullToEmptyNumber:userDeleted];
    user.deleted = userDeleted;
    
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
    
    NSString *fileType = [dictionary objectForKey:@"quoteFileType"];
    fileType = [TAPUtil nullToEmptyString:fileType];
    quote.fileType = fileType;
    
    message.quote = quote;
    
    TAPReplyToModel *replyTo = [TAPReplyToModel new];
    NSString *replyToMessageID = [dictionary objectForKey:@"replyToMessageID"];
    replyToMessageID = [TAPUtil nullToEmptyString:replyToMessageID];
    replyTo.messageID = replyToMessageID;
    
    NSString *replyToLocalID = [dictionary objectForKey:@"replyToLocalID"];
    replyToLocalID = [TAPUtil nullToEmptyString:replyToLocalID];
    replyTo.localID = replyToLocalID;
    
    NSString *replyToUserID = [dictionary objectForKey:@"replyToUserID"];
    replyToUserID = [TAPUtil nullToEmptyString:replyToUserID];
    replyTo.userID = replyToUserID;
    
    NSString *replyToXcUserID = [dictionary objectForKey:@"replyToXcUserID"];
    replyToXcUserID = [TAPUtil nullToEmptyString:replyToXcUserID];
    replyTo.xcUserID = replyToXcUserID;
    
    NSString *replyToFullname = [dictionary objectForKey:@"replyToFullname"];
    replyToFullname = [TAPUtil nullToEmptyString:replyToFullname];
    replyTo.fullname = replyToFullname;
    
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
    
    //Group Target User
    NSString *targetAction = [dictionary objectForKey:@"action"];
    targetAction = [TAPUtil nullToEmptyString:targetAction];
    message.action = targetAction;
    
    TAPGroupTargetModel *groupTarget = [TAPGroupTargetModel new];
    NSString *groupTargetType = [dictionary objectForKey:@"groupTargetType"];
    groupTargetType = [TAPUtil nullToEmptyString:groupTargetType];
    groupTarget.targetType = groupTargetType;
    
    NSString *groupTargetID = [dictionary objectForKey:@"groupTargetID"];
    groupTargetID = [TAPUtil nullToEmptyString:groupTargetID];
    groupTarget.targetID = groupTargetID;
    
    NSString *groupTargetXCID = [dictionary objectForKey:@"groupTargetXCID"];
    groupTargetXCID = [TAPUtil nullToEmptyString:groupTargetXCID];
    groupTarget.targetXCID = groupTargetXCID;
    
    NSString *groupTargetName = [dictionary objectForKey:@"groupTargetName"];
    groupTargetName = [TAPUtil nullToEmptyString:groupTargetName];
    groupTarget.targetName = groupTargetName;
    message.target = groupTarget;

    
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
    
    NSString *phoneWithCode = [dictionary objectForKey:@"phoneWithCode"];
    phoneWithCode = [TAPUtil nullToEmptyString:phoneWithCode];
    user.phoneWithCode = phoneWithCode;
    
    NSString *countryCallingCode = [dictionary objectForKey:@"countryCallingCode"];
    countryCallingCode = [TAPUtil nullToEmptyString:countryCallingCode];
    user.countryCallingCode = countryCallingCode;
    
    NSString *countryID = [dictionary objectForKey:@"countryID"];
    countryID = [TAPUtil nullToEmptyString:countryID];
    user.countryID = countryID;
    
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
    NSString *userRoleCode = [userRoleDictionary objectForKey:@"code"];
    userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
    userRole.code = userRoleCode;
    
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
    
    NSNumber *userDeleted = [dictionary objectForKey:@"deleted"];
    userDeleted = [TAPUtil nullToEmptyNumber:userDeleted];
    user.deleted = userDeleted;
    
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
    
    NSString *fileType = [quoteDictionary objectForKey:@"fileType"];
    fileType = [TAPUtil nullToEmptyString:fileType];
    quote.fileType = fileType;
    
    message.quote = quote;
    
    NSDictionary *replyToDictionary = [dictionary objectForKey:@"replyTo"];
    TAPReplyToModel *replyTo = [TAPReplyToModel new];
    NSString *replyToMessageID = [replyToDictionary objectForKey:@"messageID"];
    replyToMessageID = [TAPUtil nullToEmptyString:replyToMessageID];
    replyTo.messageID = replyToMessageID;
    
    NSString *replyToLocalID = [replyToDictionary objectForKey:@"localID"];
    replyToLocalID = [TAPUtil nullToEmptyString:replyToLocalID];
    replyTo.localID = replyToLocalID;
    
    NSString *replyToUserID = [replyToDictionary objectForKey:@"userID"];
    replyToUserID = [TAPUtil nullToEmptyString:replyToUserID];
    replyTo.userID = replyToUserID;
    
    NSString *replyToXcUserID = [dictionary objectForKey:@"xcUserID"];
    replyToXcUserID = [TAPUtil nullToEmptyString:replyToXcUserID];
    replyTo.xcUserID = replyToXcUserID;
    
    NSString *replyToFullName = [dictionary objectForKey:@"fullname"];
    replyToFullName = [TAPUtil nullToEmptyString:replyToFullName];
    replyTo.fullname = replyToFullName;
    
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
    
    //Group Target
    NSString *targetAction = [dictionary objectForKey:@"action"];
    targetAction = [TAPUtil nullToEmptyString:targetAction];
    message.action = targetAction;
    
    NSDictionary *groupTargetDictionary = [dictionary objectForKey:@"target"];
    TAPGroupTargetModel *groupTarget = [TAPGroupTargetModel new];
    
    NSString *groupTargetType = [dictionary objectForKey:@"targetType"];
    groupTargetType = [TAPUtil nullToEmptyString:groupTargetType];
    groupTarget.targetType = groupTargetType;
    
    NSString *groupTargetID = [dictionary objectForKey:@"targetID"];
    groupTargetID = [TAPUtil nullToEmptyString:groupTargetID];
    groupTarget.targetID = groupTargetID;
    
    NSString *groupTargetXCUserID = [dictionary objectForKey:@"targetXCID"];
    groupTargetXCUserID = [TAPUtil nullToEmptyString:groupTargetXCUserID];
    groupTarget.targetXCID = groupTargetXCUserID;
    
    NSString *groupTargetName = [dictionary objectForKey:@"targetName"];
    groupTargetName = [TAPUtil nullToEmptyString:groupTargetName];
    groupTarget.targetName = groupTargetName;
    message.target = groupTarget;
    
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
    fullname = [TAPDataManager normalizedDatabaseStringFromString:fullname];
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
    if ([[dictionary objectForKey:@"imageURL"] isKindOfClass:[NSString class]]) {
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
    }
    else if ([[dictionary objectForKey:@"imageURL"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *imageURLDictionary = [dictionary objectForKey:@"imageURL"];
        imageURL.fullsize = [imageURLDictionary objectForKey:@"fullsize"];
        imageURL.fullsize = [TAPUtil nullToEmptyString:imageURL.fullsize];
        imageURL.thumbnail = [imageURLDictionary objectForKey:@"thumbnail"];
        imageURL.thumbnail = [TAPUtil nullToEmptyString:imageURL.thumbnail];
    }
    user.imageURL = imageURL;
    
    TAPUserRoleModel *userRole = [TAPUserRoleModel new];
    NSString *userRoleCode = [dictionary objectForKey:@"userRoleCode"];
    userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
    userRole.code = userRoleCode;
    
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
    
    NSNumber *deleted = [dictionary objectForKey:@"deleted"];
    deleted = [TAPUtil nullToEmptyNumber:deleted];
    user.deleted = deleted;
    
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
    NSString *imageURLString = [dictionary objectForKey:@"roomImage"];
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

+ (TAPCountryModel *)countryModelFromDictionary:(NSDictionary *)dictionary {
    dictionary = [TAPUtil nullToEmptyDictionary:dictionary];
    TAPCountryModel *country = [[TAPCountryModel alloc] initWithDictionary:dictionary error:nil];
    return country;
}

+ (TAPRoomModel *)roomModelFromDictionary:(NSDictionary *)dictionary {
    dictionary = [TAPUtil nullToEmptyDictionary:dictionary];
    TAPRoomModel *room = [[TAPRoomModel alloc] initWithDictionary:dictionary error:nil];
    NSString *roomID = [dictionary objectForKey:@"roomID"];
    roomID = [TAPUtil nullToEmptyString:roomID];
    room.roomID = roomID;
    
    NSString *name = [dictionary objectForKey:@"name"];
    name = [TAPUtil nullToEmptyString:name];
    room.name = name;
    
    NSString *color = [dictionary objectForKey:@"color"];
    color = [TAPUtil nullToEmptyString:color];
    room.color = color;
    
    TAPImageURLModel *imageURL = [TAPImageURLModel new];
    if ([[dictionary objectForKey:@"imageURL"] isKindOfClass:[NSString class]]) {
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
    }
    else if ([[dictionary objectForKey:@"imageURL"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *imageURLDictionary = [dictionary objectForKey:@"imageURL"];
        imageURL.fullsize = [imageURLDictionary objectForKey:@"fullsize"];
        imageURL.fullsize = [TAPUtil nullToEmptyString:imageURL.fullsize];
        imageURL.thumbnail = [imageURLDictionary objectForKey:@"thumbnail"];
        imageURL.thumbnail = [TAPUtil nullToEmptyString:imageURL.thumbnail];
    }
    room.imageURL = imageURL;
    
    NSInteger type = [[dictionary objectForKey:@"type"] integerValue];
    room.type = type;
    
    NSNumber *deleted = [dictionary objectForKey:@"deleted"];
    deleted = [TAPUtil nullToEmptyNumber:deleted];
    room.deleted = deleted;
    
    NSNumber *isDeleted = [dictionary objectForKey:@"isDeleted"];
    room.isDeleted = [isDeleted boolValue];
    
    return room;
}

+ (TAPProductModel *)productModelFromDictionary:(NSDictionary *)dictionary {
    NSDictionary *productDictionary = [TAPUtil nullToEmptyDictionary:dictionary];
    
    NSString *productID = [productDictionary objectForKey:@"id"];
    productID = [TAPUtil nullToEmptyString:productID];
    
    NSString *productNameString = [productDictionary objectForKey:@"name"];
    productNameString = [TAPUtil nullToEmptyString:productNameString];
    
    NSString *currencyString = [productDictionary objectForKey:@"currency"];
    currencyString = [TAPUtil nullToEmptyString:currencyString];
    
    NSString *priceString = [productDictionary objectForKey:@"price"];
    priceString = [TAPUtil nullToEmptyString:priceString];
    
    NSString *ratingString = [productDictionary objectForKey:@"rating"];
    ratingString = [TAPUtil nullToEmptyString:ratingString];
    
    NSString *weightString = [productDictionary objectForKey:@"weight"];
    weightString = [TAPUtil nullToEmptyString:weightString];
    
    NSString *productDescriptionString = [productDictionary objectForKey:@"description"];
    productDescriptionString = [TAPUtil nullToEmptyString:productDescriptionString];
    
    NSString *productImageURLString = [productDictionary objectForKey:@"imageURL"];
    productImageURLString = [TAPUtil nullToEmptyString:productImageURLString];
    
    NSString *leftOptionTextString = [productDictionary objectForKey:@"buttonOption1Text"];
    leftOptionTextString = [TAPUtil nullToEmptyString:leftOptionTextString];
    
    NSString *rightOptionTextString = [productDictionary objectForKey:@"buttonOption2Text"];
    rightOptionTextString = [TAPUtil nullToEmptyString:rightOptionTextString];
    
    NSString *leftOptionColorString = [productDictionary objectForKey:@"buttonOption1Color"];
    leftOptionColorString = [TAPUtil nullToEmptyString:leftOptionColorString];
    
    NSString *rightOptionColorString = [productDictionary objectForKey:@"buttonOption2Color"];
    rightOptionColorString = [TAPUtil nullToEmptyString:rightOptionColorString];
    
    TAPProductModel *product = [TAPProductModel new];
    product.productDataID = productID;
    product.productName = productNameString;
    product.productCurrency = currencyString;
    product.productPrice = priceString;
    product.productRating = ratingString;
    product.productWeight = weightString;
    product.productDescription = productDescriptionString;
    product.productImageURL = productImageURLString;
    product.buttonOption1Text = leftOptionTextString;
    product.buttonOption2Text = rightOptionTextString;
    product.buttonOption1Color = leftOptionColorString;
    product.buttonOption2Color = rightOptionColorString;

    return product;
}

+ (TAPCoreConfigsModel *)coreConfigsModelFromDictionary:(NSDictionary *)dictionary {
    NSString *chatMediaMaxFileSizeString = [dictionary objectForKey:@"chatMediaMaxFileSize"];
    chatMediaMaxFileSizeString = [TAPUtil nullToEmptyString:chatMediaMaxFileSizeString];
    NSNumber *chatMediaMaxFileSizeNumber;
    
    if ([chatMediaMaxFileSizeString isEqualToString:@""]) {
        //not obtain default data
        chatMediaMaxFileSizeNumber = [NSNumber numberWithLong:TAP_DEFAULT_MAX_FILE_SIZE];
    }
    else {
        chatMediaMaxFileSizeNumber = [NSNumber numberWithLong:[chatMediaMaxFileSizeString longLongValue]];
    }

    NSString *roomPhotoMaxFileSizeString = [dictionary objectForKey:@"roomPhotoMaxFileSize"];
    roomPhotoMaxFileSizeString = [TAPUtil nullToEmptyString:roomPhotoMaxFileSizeString];
    NSNumber *roomPhotoMaxFileSizeNumber;
    
    if ([roomPhotoMaxFileSizeString isEqualToString:@""]) {
        //not obtain default data
        roomPhotoMaxFileSizeNumber = [NSNumber numberWithLong:TAP_DEFAULT_MAX_FILE_SIZE];
    }
    else {
        roomPhotoMaxFileSizeNumber = [NSNumber numberWithLong:[roomPhotoMaxFileSizeString longLongValue]];
    }
    
    NSString *userPhotoMaxFileSizeString = [dictionary objectForKey:@"userPhotoMaxFileSize"];
    userPhotoMaxFileSizeString = [TAPUtil nullToEmptyString:userPhotoMaxFileSizeString];
    NSNumber *userPhotoMaxFileSizeNumber;
    
    if ([userPhotoMaxFileSizeString isEqualToString:@""]) {
        //not obtain default data
        userPhotoMaxFileSizeNumber = [NSNumber numberWithLong:TAP_DEFAULT_MAX_FILE_SIZE];
    }
    else {
        userPhotoMaxFileSizeNumber = [NSNumber numberWithLong:[userPhotoMaxFileSizeString longLongValue]];
    }
    
    NSString *groupMaxParticipantsString = [dictionary objectForKey:@"groupMaxParticipants"];
    groupMaxParticipantsString = [TAPUtil nullToEmptyString:groupMaxParticipantsString];
    NSNumber *groupMaxParticipantsNumber;
    
    if ([groupMaxParticipantsString isEqualToString:@""]) {
        //not obtain default data
        groupMaxParticipantsNumber = [NSNumber numberWithLong:TAP_DEFAULT_MAX_GROUP_PARTICIPANTS];
    }
    else {
        groupMaxParticipantsNumber = [NSNumber numberWithLong:[groupMaxParticipantsString longLongValue]];
    }
    
    NSString *channelMaxParticipantsString = [dictionary objectForKey:@"channelMaxParticipants"];
    channelMaxParticipantsString = [TAPUtil nullToEmptyString:channelMaxParticipantsString];
    NSNumber *channelMaxParticipantsNumber;
    
    if ([channelMaxParticipantsString isEqualToString:@""]) {
        //not obtain default data
        channelMaxParticipantsNumber = [NSNumber numberWithLong:TAP_DEFAULT_MAX_CHANNEL_PARTICIPANTS];
    }
    else {
        channelMaxParticipantsNumber = [NSNumber numberWithLong:[channelMaxParticipantsString longLongValue]];
    }
    
    
    TAPCoreConfigsModel *coreConfigs = [TAPCoreConfigsModel new];
    coreConfigs.chatMediaMaxFileSize = chatMediaMaxFileSizeNumber;
    coreConfigs.roomPhotoMaxFileSize = roomPhotoMaxFileSizeNumber;
    coreConfigs.userPhotoMaxFileSize = userPhotoMaxFileSizeNumber;
    coreConfigs.groupMaxParticipants = groupMaxParticipantsNumber;
    coreConfigs.channelMaxParticipants = channelMaxParticipantsNumber;
    return coreConfigs;
}

+ (TAPProjectConfigsModel *)projectConfigsModelFromDictionary:(NSDictionary *)dictionary {
    NSString *usernameIgnoreCaseString = [dictionary objectForKey:@"usernameIgnoreCase"];
    usernameIgnoreCaseString = [TAPUtil nullToEmptyString:usernameIgnoreCaseString];

    BOOL usernameIgnoreCase = YES;
    if ([usernameIgnoreCaseString isEqualToString:@"0"]) {
        usernameIgnoreCase = NO;
    }
    
    TAPProjectConfigsModel *projectConfigs = [TAPProjectConfigsModel new];
    projectConfigs.usernameIgnoreCase = usernameIgnoreCase;
    
    return projectConfigs;
}

#pragma mark From Model
+ (NSDictionary *)dictionaryFromMessageModel:(TAPMessageModel *)message {
    
    NSDictionary *messageDictionary = [message toDictionary];
    messageDictionary = [TAPUtil nullToEmptyDictionary:messageDictionary];
    
    NSMutableDictionary *messageMutableDictionary = [messageDictionary mutableCopy];
    
    NSString *body = [messageMutableDictionary objectForKey:@"body"];
    body = [TAPDataManager escapedDatabaseStringFromString:message.body];
    [messageMutableDictionary setValue:body forKey:@"body"];

    NSMutableDictionary *roomDicitonary = [messageMutableDictionary objectForKey:@"room"];
    NSString *roomID = [roomDicitonary objectForKey:@"roomID"];
    roomID = [TAPUtil nullToEmptyString:roomID];
    [messageMutableDictionary setValue:roomID forKey:@"roomID"];
    
    NSString *roomName = [roomDicitonary objectForKey:@"name"];
    roomName = [TAPUtil nullToEmptyString:roomName];
    roomName = [TAPDataManager escapedDatabaseStringFromString:roomName];
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
    
    NSNumber *roomIsDeleted = [roomDicitonary objectForKey:@"isDeleted"];
    roomIsDeleted = [TAPUtil nullToEmptyNumber:roomIsDeleted];
    [messageMutableDictionary setValue:roomIsDeleted forKey:@"roomIsDeleted"];
    
    NSNumber *roomDeleted = [roomDicitonary objectForKey:@"deleted"];
    roomDeleted = [TAPUtil nullToEmptyNumber:roomDeleted];
    [messageMutableDictionary setValue:roomDeleted forKey:@"roomDeleted"];
    
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
    
    NSString *fileType = [quoteDictionary objectForKey:@"fileType"];
    fileType = [TAPUtil nullToEmptyString:fileType];
    [messageMutableDictionary setValue:fileType forKey:@"quoteFileType"];
    
    [messageMutableDictionary removeObjectForKey:@"quote"];
    
    NSDictionary *replyToDictionary = [messageMutableDictionary objectForKey:@"replyTo"];
    NSString *messageID = [replyToDictionary objectForKey:@"messageID"];
    messageID = [TAPUtil nullToEmptyString:messageID];
    [messageMutableDictionary setValue:messageID forKey:@"replyToMessageID"];
    
    NSString *localID = [replyToDictionary objectForKey:@"localID"];
    localID = [TAPUtil nullToEmptyString:localID];
    [messageMutableDictionary setValue:localID forKey:@"replyToLocalID"];
    
    NSString *replyToUserID = [replyToDictionary objectForKey:@"userID"];
    replyToUserID = [TAPUtil nullToEmptyString:replyToUserID];
    [messageMutableDictionary setValue:replyToUserID forKey:@"replyToUserID"];
    
    NSString *replyToXcUserID = [replyToDictionary objectForKey:@"xcUserID"];
    replyToXcUserID = [TAPUtil nullToEmptyString:replyToXcUserID];
    [messageMutableDictionary setValue:replyToXcUserID forKey:@"replyToXcUserID"];
    
    NSString *fullname = [replyToDictionary objectForKey:@"fullname"];
    fullname = [TAPUtil nullToEmptyString:fullname];
    [messageMutableDictionary setValue:fullname forKey:@"replyToFullname"];
    
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
    
    NSDictionary *groupTargetDictionary = [messageMutableDictionary objectForKey:@"target"];
    NSString *targetType = [groupTargetDictionary objectForKey:@"targetType"];
    targetType = [TAPUtil nullToEmptyString:targetType];
    [messageMutableDictionary setValue:targetType forKey:@"groupTargetType"];
    
    NSString *targetID = [groupTargetDictionary objectForKey:@"targetID"];
    targetID = [TAPUtil nullToEmptyString:targetID];
    [messageMutableDictionary setValue:targetID forKey:@"groupTargetID"];
    
    NSString *targetXCID = [groupTargetDictionary objectForKey:@"targetXCID"];
    targetXCID = [TAPUtil nullToEmptyString:targetXCID];
    [messageMutableDictionary setValue:targetXCID forKey:@"groupTargetXCID"];
    
    NSString *targetName = [groupTargetDictionary objectForKey:@"targetName"];
    targetName = [TAPUtil nullToEmptyString:targetName];
    [messageMutableDictionary setValue:targetName forKey:@"groupTargetName"];
    
    [messageMutableDictionary removeObjectForKey:@"target"];
    
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
    fullname = [TAPDataManager escapedDatabaseStringFromString:fullname];
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
    
    NSString *phoneWithCode = [userDictionary objectForKey:@"phoneWithCode"];
    phoneWithCode = [TAPUtil nullToEmptyString:phoneWithCode];
    [userMutableDictionary setValue:phoneWithCode forKey:@"phoneWithCode"];
    
    NSString *countryCallingCode = [userDictionary objectForKey:@"countryCallingCode"];
    countryCallingCode = [TAPUtil nullToEmptyString:countryCallingCode];
    [userMutableDictionary setValue:countryCallingCode forKey:@"countryCallingCode"];
    
    NSString *countryID = [userDictionary objectForKey:@"countryID"];
    countryID = [TAPUtil nullToEmptyString:countryID];
    [userMutableDictionary setValue:countryID forKey:@"countryID"];
    
    NSDictionary *imageURLDictionary = [userDictionary objectForKey:@"imageURL"];
    imageURLDictionary = [TAPUtil nullToEmptyDictionary:imageURLDictionary];
    NSString *imageURL = [TAPUtil jsonStringFromObject:imageURLDictionary];
    imageURL = [TAPUtil nullToEmptyString:imageURL];
    [userMutableDictionary setValue:imageURL forKey:@"imageURL"];
    
    NSDictionary *userRole = [userDictionary objectForKey:@"userRole"];
    userRole = [TAPUtil nullToEmptyDictionary:userRole];
    NSString *userRoleCode = [userRole objectForKey:@"code"];
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
    
    NSNumber *deleted = [userDictionary objectForKey:@"deleted"];
    deleted = [TAPUtil nullToEmptyNumber:deleted];
    [userMutableDictionary setValue:deleted forKey:@"deleted"];
    
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

+ (NSDictionary *)dictionaryFromCountryModel:(TAPCountryModel *)country {
    NSDictionary *countryDictionary = [country toDictionary];
    countryDictionary = [TAPUtil nullToEmptyDictionary:countryDictionary];
    
    return countryDictionary;
}

+ (NSDictionary *)dictionaryFromProductModel:(TAPProductModel *)product {
    
    NSString *productID = product.productDataID;
    productID = [TAPUtil nullToEmptyString:productID];
    
    NSString *productNameString = product.productName;
    productNameString = [TAPUtil nullToEmptyString:productNameString];
    
    NSString *currencyString = product.productCurrency;
    currencyString = [TAPUtil nullToEmptyString:currencyString];
    
    NSString *priceString = product.productPrice;
    priceString = [TAPUtil nullToEmptyString:priceString];
    
    NSString *ratingString = product.productRating;
    ratingString = [TAPUtil nullToEmptyString:ratingString];
    
    NSString *weightString = product.productWeight;
    weightString = [TAPUtil nullToEmptyString:weightString];
    
    NSString *productDescriptionString = product.productDescription;
    productDescriptionString = [TAPUtil nullToEmptyString:productDescriptionString];
    
    NSString *productImageURLString = product.productImageURL;
    productImageURLString = [TAPUtil nullToEmptyString:productImageURLString];
    
    NSString *leftOptionTextString = product.buttonOption1Text;
    leftOptionTextString = [TAPUtil nullToEmptyString:leftOptionTextString];
    
    NSString *rightOptionTextString = product.buttonOption2Text;
    rightOptionTextString = [TAPUtil nullToEmptyString:rightOptionTextString];
    
    NSString *leftOptionColorString = product.buttonOption1Color;
    leftOptionColorString = [TAPUtil nullToEmptyString:leftOptionColorString];
    
    NSString *rightOptionColorString = product.buttonOption2Color;
    rightOptionColorString = [TAPUtil nullToEmptyString:rightOptionColorString];
    
    NSMutableDictionary *productDictionary = [[NSMutableDictionary alloc] init];
    [productDictionary setObject:productID forKey:@"id"];
    [productDictionary setObject:productNameString forKey:@"name"];
    [productDictionary setObject:currencyString forKey:@"currency"];
    [productDictionary setObject:priceString forKey:@"price"];
    [productDictionary setObject:ratingString forKey:@"rating"];
    [productDictionary setObject:weightString forKey:@"weight"];
    [productDictionary setObject:productDescriptionString forKey:@"description"];
    [productDictionary setObject:productImageURLString forKey:@"imageURL"];
    [productDictionary setObject:leftOptionTextString forKey:@"buttonOption1Text"];
    [productDictionary setObject:rightOptionTextString forKey:@"buttonOption2Text"];
    [productDictionary setObject:leftOptionColorString forKey:@"buttonOption1Color"];
    [productDictionary setObject:rightOptionColorString forKey:@"buttonOption2Color"];
    
    return productDictionary;
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

+ (NSTimeInterval)getAccessTokenExpiryTime {
    NSTimeInterval expiryTime = [[NSUserDefaults standardUserDefaults] secureDoubleForKey:TAP_PREFS_ACCESS_TOKEN_EXPIRED_TIME valid:nil];
    return expiryTime;
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

+ (TAPProjectConfigsModel *)getProjectConfigs {
    NSDictionary *projectConfigsDictionary = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_PROJECT_CONFIGS_DICTIONARY valid:nil];
    NSDictionary *projectDictionary = [projectConfigsDictionary objectForKey:@"project"];
    projectDictionary = [TAPUtil nullToEmptyDictionary:projectDictionary];
    
    TAPProjectConfigsModel *projectConfigs = [self projectConfigsModelFromDictionary:projectDictionary];
    return projectConfigs;
}

+ (TAPCoreConfigsModel *)getCoreConfigs {
    NSDictionary *projectConfigsDictionary = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_PROJECT_CONFIGS_DICTIONARY valid:nil];
    NSDictionary *coreDictionary = [projectConfigsDictionary objectForKey:@"core"];
    coreDictionary = [TAPUtil nullToEmptyDictionary:coreDictionary];
    
    TAPProjectConfigsModel *coreConfigs = [self coreConfigsModelFromDictionary:coreDictionary];
    return coreConfigs;
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

+ (void)deletePhysicalFilesWithMessage:(TAPMessageModel *)message
                               success:(void (^)(void))success
                               failure:(void (^)(NSError *error))failure {
    if (message.type == TAPChatMessageTypeImage) {
        NSDictionary *dataDictionary = message.data;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        
        //Remove image
        [TAPImageView removeImageFromCacheWithKey:fileID];
        
        success();
    }
    else if (message.type == TAPChatMessageTypeVideo) {
        NSDictionary *dataDictionary = message.data;
        NSString *roomID = message.room.roomID;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        
        //Remove thumbnail image
        [TAPImageView removeImageFromCacheWithKey:fileID];
        
        //Remove video
        NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:fileID];
        if (![filePath isEqualToString:@""]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        success();
    }
    else if (message.type == TAPChatMessageTypeFile) {
        NSDictionary *dataDictionary = message.data;
        NSString *roomID = message.room.roomID;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        
        //Remove file
        NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:fileID];
        if (![filePath isEqualToString:@""]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        success();
    }
}

+ (void)deletePhysicalFilesInBackgroundWithMessage:(TAPMessageModel *)message
                                           success:(void (^)(void))success
                                           failure:(void (^)(NSError *error))failure {
    if (message.type == TAPChatMessageTypeImage) {
        NSDictionary *dataDictionary = message.data;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        
        //Remove image
        [TAPImageView removeImageFromCacheWithKey:fileID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success();
        });
    }
    else if (message.type == TAPChatMessageTypeVideo) {
        NSDictionary *dataDictionary = message.data;
        NSString *roomID = message.room.roomID;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        
        //Remove thumbnail image
        [TAPImageView removeImageFromCacheWithKey:fileID];
        
        //Remove video
        NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:fileID];
        if (![filePath isEqualToString:@""]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success();
        });
    }
    else if (message.type == TAPChatMessageTypeFile) {
        NSDictionary *dataDictionary = message.data;
        NSString *roomID = message.room.roomID;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        
        //Remove file
        NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:fileID];
        if (![filePath isEqualToString:@""]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success();
        });
    }
}

+ (void)deletePhysicalFileAndMessageSequenceWithMessageArray:(NSArray *)messageArray
                                                     success:(void (^)(void))success
                                                     failure:(void (^)(NSError *error))failure {
    
    if ([messageArray count] == 0 || messageArray == nil) {
        success();
    }
    else {
        NSInteger totalCount = 0;
        //Delete physical file & message (type image, video, files)
        for (TAPMessageModel *currentMessage in messageArray) {
            totalCount++;
            if (currentMessage.type == TAPChatMessageTypeImage || currentMessage.type == TAPChatMessageTypeVideo || currentMessage.type == TAPChatMessageTypeFile) {
                //Delete physical file
                [TAPDataManager deletePhysicalFilesWithMessage:currentMessage success:^{
                    //Delete message
                    [TAPDataManager deleteDatabaseMessageWithData:@[currentMessage] success:^{
                        if (totalCount == [messageArray count]) {
                            success();
                            return;
                        }
                    } failure:^(NSError *error) {
                        //failure delete database message
                        failure(error);
                    }];
                } failure:^(NSError *error) {
                    //failure delete physical file data
                    failure(error);
                }];
            }
        }
        
        if (totalCount == [messageArray count]) {
            success();
            return;
        }
    }
}

+ (void)deleteAllMessageAndPhysicalFilesInRoomWithRoomID:(NSString *)roomID
                                                 success:(void (^)(void))success
                                                 failure:(void (^)(NSError *error))failure {
    //Get All Message
    [TAPDataManager getAllMessageWithRoomID:roomID messageTypes:[NSArray array] sortByKey:@"created" ascending:NO success:^(NSArray<TAPMessageModel *> *messageArray) {
        NSArray *allMessageArray = messageArray;
        //Delete message & physical data of image/video/file
        [TAPDataManager deletePhysicalFileAndMessageSequenceWithMessageArray:messageArray success:^{
            //Delete all message
            [TAPDataManager deleteDatabaseMessageWithData:allMessageArray success:^{
                success();
            } failure:^(NSError *error) {
                //failure delete message from database
                failure(error);
            }];
        } failure:^(NSError *error) {
            //failure run delete physical file data and message
            failure(error);
        }];
    } failure:^(NSError *error) {
        //failure get all message in room
        failure(error);
    }];
}

+ (NSString *)escapedDatabaseStringFromString:(NSString *)string {
    //Use to handle escaped character in database when running query
    if(string == nil) {
        return @"";
    }
    
    NSString *newString = string;
    
    newString = [newString stringByReplacingOccurrencesOfString:@"'" withString:@"[--0001--]"];
    newString = [newString stringByReplacingOccurrencesOfString:@"\\" withString:@"[--0002--]"];
    newString = [newString stringByReplacingOccurrencesOfString:@";" withString:@"[--0003--]"];
    newString = [newString stringByReplacingOccurrencesOfString:@"‘" withString:@"[--0004--]"];
    newString = [newString stringByReplacingOccurrencesOfString:@"’" withString:@"[--0005--]"];
    newString = [newString stringByReplacingOccurrencesOfString:@"“" withString:@"[--0006--]"];
    
    return newString;
}

+ (NSString *)normalizedDatabaseStringFromString:(NSString *)string {
//Use to handle escaped character in database when running query
    if(string == nil) {
        return @"";
    }
    
    NSString *newString = string;
    
    newString = [newString stringByReplacingOccurrencesOfString:@"[--0001--]" withString:@"'"];
    newString = [newString stringByReplacingOccurrencesOfString:@"[--0002--]" withString:@"\\"];
    newString = [newString stringByReplacingOccurrencesOfString:@"[--0003--]" withString:@";"];
    newString = [newString stringByReplacingOccurrencesOfString:@"[--0004--]" withString:@"‘"];
    newString = [newString stringByReplacingOccurrencesOfString:@"[--0005--]" withString:@"’"];
    newString = [newString stringByReplacingOccurrencesOfString:@"[--0006--]" withString:@"“"];
    
    return newString;
}

+ (NSString *)generateChecksumWithRoomID:(NSString *)roomID
                                roomType:(NSInteger)roomType
                                  userID:(NSString *)userID
                       accessTokenExpiry:(NSTimeInterval)accessTokenExpiry {
    NSString *appendedString = [NSString stringWithFormat:@"%@:%ld:%@:%ld", roomID, (long)roomType, userID, (long)accessTokenExpiry];
    NSString *md5HashString = [TAPUtil md5:appendedString];
    md5HashString = [TAPUtil nullToEmptyString:md5HashString];
    
    return md5HashString;
}

#pragma mark - Database Call
+ (void)searchMessageWithString:(NSString *)searchString
                         sortBy:(NSString *)columnName
                        success:(void (^)(NSArray *resultArray))success
                        failure:(void (^)(NSError *error))failure {
    //CS NOTE - uncomment to use trimmed string
//    //WK Note - Create nonAlphaNumericCharacters
//    NSMutableCharacterSet *nonAlphaNumericCharacters = [[NSMutableCharacterSet alloc] init];
//    [nonAlphaNumericCharacters formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
//    [nonAlphaNumericCharacters removeCharactersInString:@" "]; //Remove space from nonAlphaNumericCharacters
//
//    NSString *alphaNumericSearchString = [[searchString componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""]; //Remove all string that is nonAlphaNumericCharacters
//    //End Note
    
    searchString = [TAPDataManager escapedDatabaseStringFromString:searchString];
    
    NSString *queryClause = [NSString stringWithFormat:@"body CONTAINS[c] \'%@\' AND type != 9001", searchString];
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
            return;
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
    [TAPDataManager getAllMessageWithRoomID:roomID query:query sortByKey:columnName ascending:isAscending success:^(NSArray<TAPMessageModel *> *messageArray) {
        success(messageArray);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)getAllMessageWithRoomID:(NSString *)roomID
                          query:(NSString *)query
                      sortByKey:(NSString *)columnName
                      ascending:(BOOL)isAscending
                        success:(void (^)(NSArray<TAPMessageModel *> *messageArray))success
                        failure:(void (^)(NSError *error))failure {
    [TAPDatabaseManager loadAllDataFromDatabaseWithQuery:query tableName:kDatabaseTableMessage sortByKey:columnName ascending:isAscending success:^(NSArray *resultArray) {
        NSArray *messageArray = [TAPUtil nullToEmptyArray:resultArray];
        
        if ([messageArray count] == 0) {
            success([NSArray array]);
            return;
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
        failure(error);
    }];
}

+ (void)getAllMessageWithRoomID:(NSString *)roomID
                   messageTypes:(NSArray *)messageTypeArray
             minimumDateCreated:(NSTimeInterval)minCreated
                      sortByKey:(NSString *)columnName
                      ascending:(BOOL)isAscending
                        success:(void (^)(NSArray<TAPMessageModel *> *messageArray))success
                        failure:(void (^)(NSError *error))failure {
    
    //Generate message type query string
    NSString *subQueryTypeString = @"";
    if ([messageTypeArray count] == 1) {
        TAPChatMessageType messageType = [[messageTypeArray firstObject] integerValue];
        subQueryTypeString = [subQueryTypeString stringByAppendingString:[NSString stringWithFormat:@"type == %ld", messageType]];
    }
    else if ([messageTypeArray count] > 1) {
        subQueryTypeString = @"(";
        for (NSInteger counter = 0; counter < [messageTypeArray count]; counter++) {
            TAPChatMessageType messageType = [[messageTypeArray objectAtIndex:counter] integerValue];
            if (counter == [messageTypeArray count] - 1) {
                subQueryTypeString = [subQueryTypeString stringByAppendingString:[NSString stringWithFormat:@"type == %ld", messageType]];
            }
            else {
                subQueryTypeString = [subQueryTypeString stringByAppendingString:[NSString stringWithFormat:@"type == %ld || ", messageType]];
            }
        }
        subQueryTypeString = [subQueryTypeString stringByAppendingString:@")"];
    }
    
    NSNumber *minCreatedNumber = [NSNumber numberWithDouble:minCreated];
    NSInteger minCreatedInteger = [minCreatedNumber integerValue];
    
    NSString *queryString = [NSString stringWithFormat:@"isHidden == 0 && isDeleted == 0 && roomID LIKE '%@' && created < %ld && %@", roomID, (long)minCreatedInteger, subQueryTypeString];
    
    [TAPDatabaseManager loadAllDataFromDatabaseWithQuery:queryString tableName:kDatabaseTableMessage sortByKey:columnName ascending:isAscending success:^(NSArray *resultArray) {
        NSArray *messageArray = [TAPUtil nullToEmptyArray:resultArray];
        
        if ([messageArray count] == 0) {
            success([NSArray array]);
            return;
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
        failure(error);
    }];
}

+ (void)getAllMessageWithRoomID:(NSString *)roomID
                   messageTypes:(NSArray *)messageTypeArray
                      sortByKey:(NSString *)columnName
                      ascending:(BOOL)isAscending
                        success:(void (^)(NSArray<TAPMessageModel *> *messageArray))success
                        failure:(void (^)(NSError *error))failure {
    
    //Generate message type query string
    NSString *subQueryTypeString = @"";
    if ([messageTypeArray count] == 1) {
        TAPChatMessageType messageType = [[messageTypeArray firstObject] integerValue];
        subQueryTypeString = [subQueryTypeString stringByAppendingString:[NSString stringWithFormat:@"type == %ld", messageType]];
    }
    else if ([messageTypeArray count] > 1) {
        subQueryTypeString = @"(";
        for (NSInteger counter = 0; counter < [messageTypeArray count]; counter++) {
            TAPChatMessageType messageType = [[messageTypeArray objectAtIndex:counter] integerValue];
            if (counter == [messageTypeArray count] - 1) {
                subQueryTypeString = [subQueryTypeString stringByAppendingString:[NSString stringWithFormat:@"type == %ld", messageType]];
            }
            else {
                subQueryTypeString = [subQueryTypeString stringByAppendingString:[NSString stringWithFormat:@"type == %ld || ", messageType]];
            }
        }
        subQueryTypeString = [subQueryTypeString stringByAppendingString:@")"];
    }
    
    NSString *queryString;
    if ([messageTypeArray count] != 0) {
        queryString = [NSString stringWithFormat:@"isHidden == 0 && isDeleted == 0 && roomID LIKE '%@' && %@", roomID, subQueryTypeString];
    }
    else {
        queryString = [NSString stringWithFormat:@"isHidden == 0 && isDeleted == 0 && roomID LIKE '%@'", roomID];
    }
    
    [TAPDatabaseManager loadAllDataFromDatabaseWithQuery:queryString tableName:kDatabaseTableMessage sortByKey:columnName ascending:isAscending success:^(NSArray *resultArray) {
        NSArray *messageArray = [TAPUtil nullToEmptyArray:resultArray];
        
        if ([messageArray count] == 0) {
            success([NSArray array]);
            return;
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
        failure(error);
    }];
}

+ (void)getRoomListSuccess:(void (^)(NSArray *resultArray))success
                   failure:(void (^)(NSError *error))failure {
    [TAPDatabaseManager loadRoomListSuccess:^(NSArray *resultArray) {
        NSArray *messageArray = [TAPUtil nullToEmptyArray:resultArray];
        NSMutableArray *modelArray = [NSMutableArray array];
        NSMutableArray *tempRecipientIDArray = [NSMutableArray array];
    
        for (NSInteger count = 0; count < [messageArray count]; count++) {
            NSDictionary *databaseDictionary = [NSDictionary dictionaryWithDictionary:[messageArray objectAtIndex:count]];
            
            TAPMessageModel *messageModel = [TAPDataManager messageModelFromDictionary:databaseDictionary];
            [modelArray addObject:messageModel];
            
            if([messageModel.user.userID isEqualToString:[self getActiveUser].userID]) {
                NSString *currentOtherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:messageModel.room.roomID];
                [tempRecipientIDArray addObject:currentOtherUserID];
            }
            else {
                //Add User to Contact Manager
                [[TAPContactManager sharedManager] addContactWithUserModel:messageModel.user saveToDatabase:NO];
            }
            
            NSError *error;
            
            if (error) {
                failure(error);
                return;
            }
        }
        
        if([tempRecipientIDArray count] > 0) {
            //call get multiple user API to populate contact
            [TAPDataManager callAPIGetBulkUserByUserID:tempRecipientIDArray success:^(NSArray *userModelArray) {
            } failure:^(NSError *error) {
            }];
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
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableMessage whereClauseQuery:@"isRead == 0 && isHidden == 0 && isDeleted == 0" sortByColumnName:@"created" isAscending:YES success:^(NSArray *resultArray) {
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
    
    NSString *queryString = [NSString stringWithFormat:@"isRead == 0 && isHidden == 0 && isDeleted == 0 && roomID LIKE '%@' && !(userID LIKE '%@')", roomID, activeUserID];
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableMessage whereClauseQuery:queryString sortByColumnName:@"created" isAscending:YES success:^(NSArray *resultArray) {
        
        resultArray = [TAPUtil nullToEmptyArray:resultArray];
        
        NSMutableArray *obtainedArray = [NSMutableArray array];
        for (NSDictionary *databaseDictionary in resultArray) {
            TAPMessageModel *message = [TAPDataManager messageModelFromDictionary:databaseDictionary];
            [obtainedArray addObject:message];
        }
        
        success(obtainedArray);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)getDatabaseMediaMessagesInRoomWithRoomID:(NSString *)roomID
                                   lastTimestamp:(NSString *)lastTimestamp
                                    numberOfItem:(NSInteger)numberOfItem
                                         success:(void (^)(NSArray *mediaMessages))success
                                         failure:(void (^)(NSError *error))failure {
    
    NSString *queryString = [NSString stringWithFormat:@"isHidden == 0 && isDeleted == 0 && isFailedSend != 1 && isSending != 1 && roomID LIKE '%@' && created < %lf && (type == %ld || type == %ld)", roomID, [lastTimestamp doubleValue], TAPChatMessageTypeImage, TAPChatMessageTypeVideo];
    
    if ([lastTimestamp isEqualToString:@""]) {
        queryString = [NSString stringWithFormat:@"isHidden == 0 && isDeleted == 0 && isFailedSend != 1 && isSending != 1 && roomID LIKE '%@' && (type == %ld || type == %ld)", roomID, TAPChatMessageTypeImage, TAPChatMessageTypeVideo];
    }
    
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableMessage whereClauseQuery:queryString sortByColumnName:@"created" isAscending:NO success:^(NSArray *resultArray) {
        
        resultArray = [TAPUtil nullToEmptyArray:resultArray];
        
        NSMutableArray *obtainedArray = [NSMutableArray array];
        for (NSDictionary *databaseDictionary in resultArray) {
            TAPMessageModel *message = [TAPDataManager messageModelFromDictionary:databaseDictionary];
            [obtainedArray addObject:message];
            if ([obtainedArray count] == numberOfItem) {
                break;
            }
        }
        
        success(obtainedArray);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)getDatabaseUnreadRoomCountWithActiveUserID:(NSString *)activeUserID
                                           success:(void (^)(NSInteger))success
                                           failure:(void (^)(NSError *))failure {
    NSString *queryString = [NSString stringWithFormat:@"isRead == 0 && isHidden == 0 && isDeleted == 0 && !(userID LIKE '%@')", activeUserID];
    
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableMessage whereClauseQuery:queryString sortByColumnName:@"created" isAscending:YES distinctBy:@"roomID" success:^(NSArray *resultArray) {
        
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
    //CS NOTE - uncomment to use trimmed string
//    //WK Note - Create nonAlphaNumericCharacters
//    NSMutableCharacterSet *nonAlphaNumericCharacters = [[NSMutableCharacterSet alloc] init];
//    [nonAlphaNumericCharacters formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
//    [nonAlphaNumericCharacters removeCharactersInString:@" "]; //Remove space from nonAlphaNumericCharacters
//
//    NSString *alphaNumericSearchString = [[searchString componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""]; //Remove all string that is nonAlphaNumericCharacters
//    //End Note
    
    searchString = [TAPDataManager escapedDatabaseStringFromString:searchString];
    
    NSString __block *queryClause = [NSString stringWithFormat:@"roomName CONTAINS[c] \'%@\'", searchString];
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
        
        queryClause = [NSString stringWithFormat:@"fullname CONTAINS[c] \'%@\'", searchString];
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
        return;
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
        return;
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
        return;
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
        return;
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
        return;
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
        return;
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
        return;
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
        return;
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
        return;
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
    //CS NOTE - uncomment to use trimmed string
//  //  WK Note - Create nonAlphaNumericCharacters
//    NSMutableCharacterSet *nonAlphaNumericCharacters = [[NSMutableCharacterSet alloc] init];
//    [nonAlphaNumericCharacters formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
//    [nonAlphaNumericCharacters removeCharactersInString:@" "]; //Remove space from nonAlphaNumericCharacters
//
//    NSString *alphaNumericSearchString = [[keyword componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""]; //Remove all string that is nonAlphaNumericCharacters
//    //End Note
    
    keyword = [TAPDataManager escapedDatabaseStringFromString:keyword];
    
    NSString *queryClause = [NSString stringWithFormat:@"fullname CONTAINS[c] \'%@\' AND isContact = true", keyword];
    
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
                             whereClauseQuery:@"isContact = true AND (deleted = 0 OR deleted = null)"
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
                           success:(void (^)(BOOL isContact, TAPUserModel *obtainedUser))success
                           failure:(void (^)(NSError *error))failure {
    userID = [TAPUtil nullToEmptyString:userID];
    NSString *queryClause = [NSString stringWithFormat:@"userID == \'%@\' AND isContact = true", userID];
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableContact
                             whereClauseQuery:queryClause
                             sortByColumnName:@""
                                  isAscending:NO
                                      success:^(NSArray *resultArray) {
                                          if ([resultArray count] > 0) {
                                              TAPUserModel *obtainedUser = [resultArray firstObject];
                                              success(YES, obtainedUser);
                                          }
                                          else {
                                              TAPUserModel *obtainedUser = nil;
                                              success(NO, obtainedUser);
                                          }
                                      } failure:^(NSError *error) {
                                          failure(error);
                                      }];
}

+ (void)getDatabaseContactByXCUserID:(NSString *)XCUserID
                             success:(void (^)(BOOL isContact, TAPUserModel *obtainedUser))success
                             failure:(void (^)(NSError *error))failure {
    XCUserID = [TAPUtil nullToEmptyString:XCUserID];
    NSString *queryClause = [NSString stringWithFormat:@"xcUserID == \'%@\' AND isContact = true", XCUserID];
    [TAPDatabaseManager loadDataFromTableName:kDatabaseTableContact
                             whereClauseQuery:queryClause
                             sortByColumnName:@""
                                  isAscending:NO
                                      success:^(NSArray *resultArray) {
                                          if ([resultArray count] > 0) {
                                              NSDictionary *dataDictionary = [resultArray firstObject];
                                              TAPUserModel *obtainedUser = [self userModelFromDictionary:dataDictionary];
                                              success(YES, obtainedUser);
                                          }
                                          else {
                                              TAPUserModel *obtainedUser = nil;
                                              success(NO, obtainedUser);
                                          }
                                      } failure:^(NSError *error) {
                                          failure(error);
                                      }];
}

#pragma mark - API Call
+ (void)callAPILogoutWithSuccess:(void (^)(void))success
                         failure:(void (^)(NSError *error))failure {

    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeLogout];
    
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
                    [TAPDataManager callAPILogoutWithSuccess:success failure:failure];
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
        
        NSTimeInterval accessTokenExpiry = [[dataDictionary objectForKey:@"accessTokenExpiry"] longLongValue];
        
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
                        [[TAPChatManager sharedManager] disconnect];
                        
                        id<TapTalkDelegate> tapTalkDelegate = [TapTalk sharedInstance].delegate;
                        if ([tapTalkDelegate respondsToSelector:@selector(tapTalkShouldResetAuthTicket)]) {
                            [tapTalkDelegate tapTalkShouldResetAuthTicket];
                        }
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
                
                NSTimeInterval accessTokenExpiry = [[dataDictionary objectForKey:@"accessTokenExpiry"] longLongValue];
                
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
        
        NSMutableArray *tempRecipientIDArray = [NSMutableArray array];
        NSMutableArray *messageResultArray = [NSMutableArray array];
        
        for (NSDictionary *messageDictionary in messageArray) {
            
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

+ (void)callAPIGetMessageAfterWithRoomID:(NSString *)roomID
                              minCreated:(NSNumber *)minCreated
                             lastUpdated:(NSNumber *)lastUpdated
          needToSaveLastUpdatedTimestamp:(BOOL)needToSaveLastUpdatedTimestamp
                                 success:(void (^)(NSArray *messageArray))success
                                 failure:(void (^)(NSError *error))failure {
    if(roomID == nil || [roomID isEqualToString:@""]) {
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"Input Error", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Room not found", @"")}];
        failure(localizedError);
        return;
    }
    
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetMessageRoomListAfter];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:minCreated forKey:@"minCreated"];
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
                    [TAPDataManager callAPIGetMessageAfterWithRoomID:roomID minCreated:minCreated lastUpdated:lastUpdated needToSaveLastUpdatedTimestamp:needToSaveLastUpdatedTimestamp success:success failure:failure];
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
        
        if (needToSaveLastUpdatedTimestamp) {
            //Set newest last updated to preference
            [TAPDataManager setMessageLastUpdatedWithRoomID:roomID lastUpdated:preferenceLastUpdated];
        }
        
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
                            numberOfItems:(NSNumber *)numberOfItems
                                  success:(void (^)(NSArray *messageArray, BOOL hasMore))success
                                  failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetMessageRoomListBefore];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:maxCreated forKey:@"maxCreated"];
    [parameterDictionary setObject:numberOfItems forKey:@"limit"];
    
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
                    [TAPDataManager callAPIGetMessageBeforeWithRoomID:roomID maxCreated:maxCreated numberOfItems:numberOfItems  success:success failure:failure];
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

+ (void)callAPIDeleteMessageWithMessageIDs:(NSArray *)messageIDArray
                                    roomID:(NSString *)roomID
                      isDeletedForEveryone:(BOOL)isDeletedForEveryone
                                   success:(void (^)(NSArray *deletedMessageIDArray))success
                                   failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeDeleteMessage];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:messageIDArray forKey:@"messageIDs"];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:[NSNumber numberWithBool:isDeletedForEveryone] forKey:@"forEveryone"];
    
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
                    [TAPDataManager callAPIDeleteMessageWithMessageIDs:messageIDArray roomID:roomID isDeletedForEveryone:isDeletedForEveryone success:success failure:failure];
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
        
        NSArray *deletedMessageIDArray = [responseObject valueForKeyPath:@"data.deletedMessageIDs"];
        deletedMessageIDArray = [TAPUtil nullToEmptyArray:deletedMessageIDArray];
        success(deletedMessageIDArray);
        
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
        for (NSDictionary *userDictionary in userArray) {
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
            
            NSString *phoneWithCode = [obtainedUserDictionary objectForKey:@"phoneWithCode"];
            phoneWithCode = [TAPUtil nullToEmptyString:phoneWithCode];
            user.phoneWithCode = phoneWithCode;
            
            NSString *countryCallingCode = [obtainedUserDictionary objectForKey:@"countryCallingCode"];
            countryCallingCode = [TAPUtil nullToEmptyString:countryCallingCode];
            user.countryCallingCode = countryCallingCode;
            
            NSString *countryID = [NSString stringWithFormat:@"%ld", [[obtainedUserDictionary objectForKey:@"countryID"] integerValue]];
            countryID = [TAPUtil nullToEmptyString:countryID];
            user.countryID = countryID;
            
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
            NSString *userRoleCode = [userRoleDictionary objectForKey:@"code"];
            userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
            userRole.code = userRoleCode;
            
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
            
            NSNumber *deleted = [obtainedUserDictionary objectForKey:@"deleted"];
            deleted = [TAPUtil nullToEmptyNumber:deleted];
            user.deleted = deleted;
  
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
            success(userResultArray);
        } failure:^(NSError *error) {
            
        }];
        
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
                            success:(void (^)(NSString *message, TAPUserModel *user))success
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
            success(@"", [TAPUserModel new]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSString *successString = [NSString stringWithFormat:@"%ld", [[dataDictionary objectForKey:@"success"] integerValue]];
        successString = [TAPUtil nullToEmptyString:successString];
        NSString *message = [dataDictionary objectForKey:@"message"];
        message = [TAPUtil nullToEmptyString:message];
        
        NSDictionary *userDictionary = [dataDictionary objectForKey:@"user"];
        userDictionary = [TAPUtil nullToEmptyDictionary:userDictionary];
        
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
        
        NSString *phoneWithCode = [userDictionary objectForKey:@"phoneWithCode"];
        phoneWithCode = [TAPUtil nullToEmptyString:phoneWithCode];
        user.phoneWithCode = phoneWithCode;
        
        NSString *countryCallingCode = [userDictionary objectForKey:@"countryCallingCode"];
        countryCallingCode = [TAPUtil nullToEmptyString:countryCallingCode];
        user.countryCallingCode = countryCallingCode;
        
        NSString *countryID = [NSString stringWithFormat:@"%ld", [[userDictionary objectForKey:@"countryID"] integerValue]];
        countryID = [TAPUtil nullToEmptyString:countryID];
        user.countryID = countryID;
        
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
        NSString *userRoleCode = [userRoleDictionary objectForKey:@"code"];
        userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
        userRole.code = userRoleCode;
        
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
        
        NSNumber *deleted = [userDictionary objectForKey:@"deleted"];
        deleted = [TAPUtil nullToEmptyNumber:deleted];
        user.deleted = deleted;
        
        BOOL isRequestPending = [[userDictionary objectForKey:@"isRequestPending"] boolValue];
        user.isRequestPending = isRequestPending;
        
        BOOL isRequestAccepted = [[userDictionary objectForKey:@"isRequestAccepted"] boolValue];
        user.isRequestAccepted = isRequestAccepted;
        
        user.isContact = YES;
        
        //Add User to Contact Manager
        [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:YES];
        
        //Insert To Database
        [TAPDataManager updateOrInsertDatabaseContactWithData:@[user] success:^{
            success(message, user);
            
        } failure:^(NSError *error) {
            
        }];
        
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
    TAPProjectConfigsModel *projectConfigs = [self getProjectConfigs];
    BOOL isIgnoreCase = projectConfigs.usernameIgnoreCase;
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:username forKey:@"username"];
    [parameterDictionary setObject:[NSNumber numberWithBool:isIgnoreCase] forKey:@"ignoreCase"];
    
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
        
        failure(newError, messageArray);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError, messageArray);
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
        
        failure(newError, messageArray);
#else
        NSError *localizedError = [NSError errorWithDomain:NSLocalizedString(@"We are experiencing problem to connect to our server, please try again later...", @"") code:999 userInfo:@{@"message": NSLocalizedString(@"Failed to connect to our server, please try again later...", @"")}];
        
        failure(localizedError, messageArray);
#endif
    }];
}

+ (NSURLSessionUploadTask *)callAPIUploadFileWithFileData:(NSData *)fileData
                                                   roomID:(NSString *)roomID
                                                 fileName:(NSString *)fileName
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

    NSURLSessionUploadTask *uploadTask = [[TAPNetworkManager sharedManager] upload:requestURL fileData:fileData fileName:fileName fileType:fileType mimeType:mimeType parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        CGFloat progress = uploadProgress.fractionCompleted;
        progressBlock(progress, 1.0f);
    } success:^(NSDictionary *responseObject) {
        successBlock(responseObject);
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
    
    return uploadTask;
}

+ (NSURLSessionUploadTask *)callAPIUploadUserImageWithImageData:(NSData *)imageData
                                                completionBlock:(void (^)(TAPUserModel *user))successBlock
                                                  progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
                                                   failureBlock:(void(^)(NSError *error))failureBlock {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeUploadUserPhoto];
    
    NSURLSessionUploadTask *uploadTask = [[TAPNetworkManager sharedManager] upload:requestURL fileData:imageData parameters:[NSDictionary dictionary] progress:^(NSProgress *uploadProgress) {
        CGFloat progress = uploadProgress.fractionCompleted;
        progressBlock(progress, 1.0f);
    } success:^(NSDictionary *responseObject) {
        
        NSDictionary *userDictionary = [responseObject valueForKeyPath:@"data.user"];
        
        TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:userDictionary error:nil];
        
        [TAPDataManager setActiveUser:user];
        
        successBlock(user);
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
    
    [[TAPNetworkManager sharedManager] download:requestURL parameters:parameterDictionary progress:^(NSProgress *downloadProgress) {
        CGFloat progress = downloadProgress.completedUnitCount;
        progressBlock(progress, downloadProgress.totalUnitCount);
    } success:^(NSData *downloadedData) {
        UIImage *downloadedImage = [UIImage imageWithData:downloadedData];
        successBlock(downloadedImage);
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

+ (void)callAPIDownloadFileWithFileID:(NSString *)fileID
                               roomID:(NSString *)roomID
                      completionBlock:(void (^)(NSData *downloadedData))successBlock
                        progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
                         failureBlock:(void(^)(NSError *error))failureBlock {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeDownloadFile];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:fileID forKey:@"fileID"];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    
    [[TAPNetworkManager sharedManager] download:requestURL parameters:parameterDictionary progress:^(NSProgress *downloadProgress) {
        CGFloat progress = downloadProgress.completedUnitCount;
        progressBlock(progress, downloadProgress.totalUnitCount);
    } success:^(NSData *downloadedData) {
        successBlock(downloadedData);
    } failure:^(NSError *error) {
        failureBlock(error);
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

+ (void)callAPIGetCountryListWithCurrentCountryCode:(NSString *)countryCode
                                            success:(void (^)(NSArray *countryModelArray, NSArray *countryDictionaryArray, NSDictionary *countryListDictionary, TAPCountryModel *defaultLocaleCountry))success
                                            failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetCountry];
    
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
                    [TAPDataManager callAPIGetCountryListWithCurrentCountryCode:countryCode success:success failure:failure];
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
            success([NSArray array], [NSArray array], [NSDictionary dictionary], [TAPCountryModel new]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSArray *countryArray = [dataDictionary objectForKey:@"countries"];
        countryArray = [TAPUtil nullToEmptyArray:countryArray];
        

        TAPCountryModel *currentLocaleCountry = [TAPCountryModel new];
        
        NSMutableArray *countryModelResultArray = [NSMutableArray array];
        NSMutableArray *countryDictionaryResultArray = [NSMutableArray array];
        NSMutableDictionary *countryResultDictionary = [NSMutableDictionary dictionary];
        for (NSDictionary *countryDictionary in countryArray) {
            TAPCountryModel *country = [TAPCountryModel new];
            
            NSString *countryIDRaw = [countryDictionary objectForKey:@"id"];
            countryIDRaw = [TAPUtil nullToEmptyString:countryIDRaw];
            NSString *countryID = [NSString stringWithFormat:@"%ld", (long)[countryIDRaw integerValue]];
            country.countryID = countryID;
            
            NSString *commonName = [countryDictionary objectForKey:@"commonName"];
            commonName = [TAPUtil nullToEmptyString:commonName];
            country.countryCommonName = commonName;
            
            NSString *officialName = [countryDictionary objectForKey:@"officialName"];
            officialName = [TAPUtil nullToEmptyString:officialName];
            country.countryOfficialName = officialName;
            
            NSString *iso2Code = [countryDictionary objectForKey:@"iso2Code"];
            iso2Code = [TAPUtil nullToEmptyString:iso2Code];
            country.countryISO2Code = iso2Code;
            
            NSString *iso3Code = [countryDictionary objectForKey:@"iso3Code"];
            iso3Code = [TAPUtil nullToEmptyString:iso3Code];
            country.countryISO3Code = iso3Code;
            
            NSString *callingCode = [countryDictionary objectForKey:@"callingCode"];
            callingCode = [TAPUtil nullToEmptyString:callingCode];
            country.countryCallingCode = callingCode;
            
            NSString *flagIconURL = [countryDictionary objectForKey:@"flagIconURL"];
            flagIconURL = [TAPUtil nullToEmptyString:flagIconURL];
            country.flagIconURL = flagIconURL;
            
            NSString *currencyCode = [countryDictionary objectForKey:@"currencyCode"];
            currencyCode = [TAPUtil nullToEmptyString:currencyCode];
            country.countryCurrencyCode = currencyCode;
            
            NSNumber *isEnabled = [countryDictionary objectForKey:@"isEnabled"];
            country.isEnabled = [isEnabled boolValue];
            
            NSNumber *isHidden = [countryDictionary objectForKey:@"isHidden"];
            country.isHidden = [isHidden boolValue];
            
            NSDictionary *countryDataDictionary = [TAPDataManager dictionaryFromCountryModel:country];

            [countryModelResultArray addObject:country];
            [countryDictionaryResultArray addObject:countryDataDictionary];
            [countryResultDictionary setObject:countryDataDictionary forKey:countryID];
            
            if ([country.countryISO2Code isEqualToString:countryCode]) {
                currentLocaleCountry = country;
            }
        }
        
        success(countryModelResultArray, countryDictionaryResultArray, countryResultDictionary, currentLocaleCountry);
        
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

+ (void)callAPIRequestVerificationCodeWithPhoneNumber:(NSString *)phoneNumber
                                            countryID:(NSString *)countryID
                                               method:(NSString *)method
                                              success:(void (^)(NSString *OTPKey, NSString *OTPID, NSString *successMessage))success
                                              failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeRequestOTP];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:phoneNumber forKey:@"phone"];
    [parameterDictionary setObject:[NSNumber numberWithInteger:[countryID integerValue]] forKey:@"countryID"];
    [parameterDictionary setObject:method forKey:@"method"]; //method should be phone or email
    
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
                    [TAPDataManager callAPIRequestVerificationCodeWithPhoneNumber:phoneNumber countryID:countryID method:method success:success failure:failure];
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
            success([NSString string], [NSString string], [NSString string]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSString *OTPKey = [dataDictionary objectForKey:@"otpKey"];
        OTPKey = [TAPUtil nullToEmptyString:OTPKey];
        
        NSString *OTPID = [dataDictionary objectForKey:@"otpID"];
        OTPID = [TAPUtil nullToEmptyString:OTPID];
        
        NSString *successMessage = [dataDictionary objectForKey:@"message"];
        successMessage = [TAPUtil nullToEmptyString:successMessage];
        
        success(OTPKey, OTPID, successMessage);
        
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

+ (void)callAPIVerifyOTPWithCode:(NSString *)OTPcode
                           OTPID:(NSString *)OTPID
                          OTPKey:(NSString *)OTPKey
                         success:(void (^)(BOOL isRegistered, NSString *userID, NSString *ticket))success
                         failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeVerifyOTP];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:[NSNumber numberWithInteger:[OTPID integerValue]] forKey:@"otpID"];
    [parameterDictionary setObject:OTPKey forKey:@"otpKey"];
    [parameterDictionary setObject:OTPcode forKey:@"otpCode"];
    
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
                    [TAPDataManager callAPIVerifyOTPWithCode:OTPcode OTPID:OTPID OTPKey:OTPKey success:success failure:failure];
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
            success([NSString string], [NSString string], [NSString string]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSString *isRegisteredRaw = [dataDictionary objectForKey:@"isRegistered"];
        isRegisteredRaw = [TAPUtil nullToEmptyString:isRegisteredRaw];
        BOOL isRegistered = [isRegisteredRaw boolValue];
        
        NSString *userID = [dataDictionary objectForKey:@"userID"];
        userID = [TAPUtil nullToEmptyString:userID];
        
        NSString *ticket = [dataDictionary objectForKey:@"ticket"];
        ticket = [TAPUtil nullToEmptyString:ticket];
        
        success(isRegistered, userID, ticket);
        
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

+ (void)callAPICheckUsername:(NSString *)username
                     success:(void (^)(BOOL isExists, NSString *checkedUsername))success
                     failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeCheckUsername];
    
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
                    [TAPDataManager callAPICheckUsername:username success:success failure:failure];
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
            success([NSString string], [NSString string]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSString *isExistsRaw = [dataDictionary objectForKey:@"exists"];
        isExistsRaw = [TAPUtil nullToEmptyString:isExistsRaw];
        BOOL isExists = [isExistsRaw boolValue];
        
        success(isExists, username);
        
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

+ (void)callAPIRegisterWithFullName:(NSString *)fullName
                          countryID:(NSString *)countryID
                              phone:(NSString *)phone
                           username:(NSString *)username
                              email:(NSString *)email
                           password:(NSString *)password
                            success:(void (^)(NSString *userID, NSString *ticket))success
                            failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeRegister];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:fullName forKey:@"fullname"];
    [parameterDictionary setObject:[NSNumber numberWithInteger:[countryID integerValue]] forKey:@"countryID"];
    [parameterDictionary setObject:phone forKey:@"phone"];
    [parameterDictionary setObject:username forKey:@"username"];
    
    if (![TAPUtil isEmptyString:email]) {
        [parameterDictionary setObject:email forKey:@"email"];
    }
    
    if (![TAPUtil isEmptyString:password]) {
        [parameterDictionary setObject:password forKey:@"password"];
    }
    
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
                    [TAPDataManager callAPIRegisterWithFullName:fullName countryID:countryID phone:phone username:username email:email password:password success:success failure:failure];
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
            success([NSString string], [NSString string]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSString *isRegisteredRaw = [dataDictionary objectForKey:@"isRegistered"];
        isRegisteredRaw = [TAPUtil nullToEmptyString:isRegisteredRaw];
        BOOL isRegistered = [isRegisteredRaw boolValue];
        
        NSString *userID = [dataDictionary objectForKey:@"userID"];
        userID = [TAPUtil nullToEmptyString:userID];
        
        NSString *ticket = [dataDictionary objectForKey:@"ticket"];
        ticket = [TAPUtil nullToEmptyString:ticket];
        
        success(userID, ticket);
        
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

+ (void)callAPIAddContactWithPhones:(NSArray *)phoneNumbers
                            success:(void (^)(NSArray *users))success
                            failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeAddContactByPhones];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:phoneNumbers forKey:@"phones"];
    
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
                    [TAPDataManager callAPIAddContactWithPhones:phoneNumbers success:success failure:failure];
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
        NSArray *userArray = [dataDictionary objectForKey:@"users"];
        userArray = [TAPUtil nullToEmptyArray:userArray];
        
        NSMutableArray *userResultArray = [NSMutableArray array];
        for (NSDictionary *userDictionary in userArray) {
            NSDictionary *obtainedUserDictionary = userDictionary;
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
            
            NSString *phoneWithCode = [obtainedUserDictionary objectForKey:@"phoneWithCode"];
            phoneWithCode = [TAPUtil nullToEmptyString:phoneWithCode];
            user.phoneWithCode = phoneWithCode;
            
            NSString *countryCallingCode = [obtainedUserDictionary objectForKey:@"countryCallingCode"];
            countryCallingCode = [TAPUtil nullToEmptyString:countryCallingCode];
            user.countryCallingCode = countryCallingCode;
            
            NSString *countryID = [NSString stringWithFormat:@"%ld", [[obtainedUserDictionary objectForKey:@"countryID"] integerValue]];
            countryID = [TAPUtil nullToEmptyString:countryID];
            user.countryID = countryID;
            
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
            NSString *userRoleCode = [userRoleDictionary objectForKey:@"code"];
            userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
            userRole.code = userRoleCode;
            
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
            
            NSNumber *deleted = [obtainedUserDictionary objectForKey:@"deleted"];
            deleted = [TAPUtil nullToEmptyNumber:deleted];
            user.deleted = deleted;
            
            BOOL isRequestPending = [[userDictionary objectForKey:@"isRequestPending"] boolValue];
            user.isRequestPending = isRequestPending;
            
            BOOL isRequestAccepted = [[userDictionary objectForKey:@"isRequestAccepted"] boolValue];
            user.isRequestAccepted = isRequestAccepted;
            
            user.isContact = YES;
            
            //Add User to Contact Manager
            [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:YES];
            
            [userResultArray addObject:user];
        }
        
        //Insert To Database
        [TAPDataManager updateOrInsertDatabaseContactWithData:userResultArray success:^{
            success(userResultArray);

        } failure:^(NSError *error) {
            
        }];
        
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

+ (void)callAPICreateRoomWithName:(NSString *)roomName
                             type:(NSInteger)roomType
                      userIDArray:(NSArray *)userIDArray
                          success:(void (^)(TAPRoomModel *room))success
                          failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeCreateRoom];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomName forKey:@"name"];
    [parameterDictionary setObject:[NSNumber numberWithInteger:roomType] forKey:@"type"];
    [parameterDictionary setObject:userIDArray forKey:@"userIDs"];
    
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
                    [TAPDataManager callAPICreateRoomWithName:roomName type:roomType userIDArray:userIDArray success:success failure:failure];
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
            success([TAPRoomModel new]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSArray *participantsArray = [dataDictionary objectForKey:@"participants"];
        NSArray *adminUserIDArray = [dataDictionary objectForKey:@"adminUserIDs"];
        NSDictionary *roomDictionary = [dataDictionary objectForKey:@"room"];
        
        TAPRoomModel *room = [self roomModelFromDictionary:roomDictionary];

        NSMutableArray *participantsModelArray = [NSMutableArray array];
        for (NSDictionary *userDictionary  in participantsArray) {
            [participantsModelArray addObject:[self userModelFromDictionary:userDictionary]];
        }
        
        room.admins = adminUserIDArray;
        room.participants = participantsModelArray;

        [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:room];
        
        success(room);
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

+ (NSURLSessionUploadTask *)callAPIUploadRoomImageWithImageData:(NSData *)imageData
                                                         roomID:(NSString *)roomID
                                                completionBlock:(void (^)(TAPRoomModel *room))successBlock
                                                  progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
                                                   failureBlock:(void(^)(NSError *error))failureBlock {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeUploadRoomPhoto];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    
    NSURLSessionUploadTask *uploadTask = [[TAPNetworkManager sharedManager] upload:requestURL fileData:imageData parameters:parameterDictionary progress:^(NSProgress *uploadProgress) {
        CGFloat progress = uploadProgress.fractionCompleted;
        progressBlock(progress, 1.0f);
    } success:^(NSDictionary *responseObject) {
        
        NSDictionary *roomDictionary = [responseObject valueForKeyPath:@"data.room"];
        
        TAPRoomModel *room = [self roomModelFromDictionary:roomDictionary];
        
        successBlock(room);
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
    
    return uploadTask;
}

+ (void)callAPIUpdateRoomWithRoomID:(NSString *)roomID
                           roomName:(NSString *)roomName
                            success:(void (^)(TAPRoomModel *room))success
                            failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeUpdateRoom];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomName forKey:@"name"];
    [parameterDictionary setObject:roomID forKey:@"roomID"];

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
                    [TAPDataManager callAPIUpdateRoomWithRoomID:roomID roomName:roomName success:success failure:failure];
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
            success([TAPRoomModel new]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSDictionary *roomDictionary = [dataDictionary objectForKey:@"room"];
        
        TAPRoomModel *room = [self roomModelFromDictionary:roomDictionary];
        
        success(room);
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

+ (void)callAPIGetRoomWithRoomID:(NSString *)roomID
                         success:(void (^)(TAPRoomModel *room))success
                         failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetRoom];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    
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
                    [TAPDataManager callAPIGetRoomWithRoomID:roomID success:success failure:failure];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                return;
            }
            
            NSInteger errorCode = [[responseObject valueForKeyPath:@"error.code"] integerValue];
            
            if (errorMessage == nil || [errorMessage isEqualToString:@""]) {
                errorCode = 999;
            }
            
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:errorCode userInfo:@{@"message": errorMessage}];
            failure(error);
            return;
        }
        
        if ([self isDataEmpty:responseObject]) {
            success([TAPRoomModel new]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSArray *participantsArray = [dataDictionary objectForKey:@"participants"];
        NSArray *adminUserIDArray = [dataDictionary objectForKey:@"adminUserIDs"];
        NSDictionary *roomDictionary = [dataDictionary objectForKey:@"room"];
        
        TAPRoomModel *room = [self roomModelFromDictionary:roomDictionary];
        
        NSMutableArray *participantsModelArray = [NSMutableArray array];
        for (NSDictionary *userDictionary  in participantsArray) {
            [participantsModelArray addObject:[self userModelFromDictionary:userDictionary]];
        }
        
        room.admins = adminUserIDArray;
        room.participants = participantsModelArray;
        
        [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:room];
        
        success(room);

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

+ (void)callAPIAddRoomParticipantsWithRoomID:(NSString *)roomID
                                 userIDArray:(NSArray *)userIDArray
                                     success:(void (^)(TAPRoomModel *room))success
                                     failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeAddRoomParticipants];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:userIDArray forKey:@"userIDs"];
    
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
                    [TAPDataManager callAPIAddRoomParticipantsWithRoomID:roomID userIDArray:userIDArray success:success failure:failure];
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
            success([TAPRoomModel new]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSArray *participantsArray = [dataDictionary objectForKey:@"participants"];
        NSArray *adminUserIDArray = [dataDictionary objectForKey:@"adminUserIDs"];
        NSDictionary *roomDictionary = [dataDictionary objectForKey:@"room"];
        
        TAPRoomModel *room = [self roomModelFromDictionary:roomDictionary];
        
        NSMutableArray *participantsModelArray = [NSMutableArray array];
        for (NSDictionary *userDictionary  in participantsArray) {
            [participantsModelArray addObject:[self userModelFromDictionary:userDictionary]];
        }
        
        room.admins = adminUserIDArray;
        room.participants = participantsModelArray;
        
        [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:room];
        
        success(room);
        
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

+ (void)callAPIRemoveRoomParticipantsWithRoomID:(NSString *)roomID
                                    userIDArray:(NSArray *)userIDArray
                                        success:(void (^)(TAPRoomModel *room))success
                                        failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeRemoveRoomParticipants];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:userIDArray forKey:@"userIDs"];
    
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
                    [TAPDataManager callAPIRemoveRoomParticipantsWithRoomID:roomID userIDArray:userIDArray success:success failure:failure];
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
            success([TAPRoomModel new]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSArray *participantsArray = [dataDictionary objectForKey:@"participants"];
        NSArray *adminUserIDArray = [dataDictionary objectForKey:@"adminUserIDs"];
        NSDictionary *roomDictionary = [dataDictionary objectForKey:@"room"];
        
        TAPRoomModel *room = [self roomModelFromDictionary:roomDictionary];
        
        NSMutableArray *participantsModelArray = [NSMutableArray array];
        for (NSDictionary *userDictionary  in participantsArray) {
            [participantsModelArray addObject:[self userModelFromDictionary:userDictionary]];
        }
        
        room.admins = adminUserIDArray;
        room.participants = participantsModelArray;
        
        [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:room];
        
        success(room);
        
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

+ (void)callAPIPromoteRoomAdminsWithRoomID:(NSString *)roomID
                               userIDArray:(NSArray *)userIDArray
                                   success:(void (^)(TAPRoomModel *room))success
                                   failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypePromoteRoomAdmins];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:userIDArray forKey:@"userIDs"];
    
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
                    [TAPDataManager callAPIPromoteRoomAdminsWithRoomID:roomID userIDArray:userIDArray success:success failure:failure];
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
            success([TAPRoomModel new]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSArray *participantsArray = [dataDictionary objectForKey:@"participants"];
        NSArray *adminUserIDArray = [dataDictionary objectForKey:@"adminUserIDs"];
        NSDictionary *roomDictionary = [dataDictionary objectForKey:@"room"];
        
        TAPRoomModel *room = [self roomModelFromDictionary:roomDictionary];
        
        NSMutableArray *participantsModelArray = [NSMutableArray array];
        for (NSDictionary *userDictionary  in participantsArray) {
            [participantsModelArray addObject:[self userModelFromDictionary:userDictionary]];
        }
        
        room.admins = adminUserIDArray;
        room.participants = participantsModelArray;
        
        [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:room];
        
        success(room);
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

+ (void)callAPIDemoteRoomAdminsWithRoomID:(NSString *)roomID
                              userIDArray:(NSArray *)userIDArray
                                  success:(void (^)(TAPRoomModel *room))success
                                  failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeDemoteRoomAdmins];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    [parameterDictionary setObject:userIDArray forKey:@"userIDs"];
    
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
                    [TAPDataManager callAPIDemoteRoomAdminsWithRoomID:roomID userIDArray:userIDArray success:success failure:failure];
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
            success([TAPRoomModel new]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        NSArray *participantsArray = [dataDictionary objectForKey:@"participants"];
        NSArray *adminUserIDArray = [dataDictionary objectForKey:@"adminUserIDs"];
        NSDictionary *roomDictionary = [dataDictionary objectForKey:@"room"];
        
        TAPRoomModel *room = [self roomModelFromDictionary:roomDictionary];
        
        NSMutableArray *participantsModelArray = [NSMutableArray array];
        for (NSDictionary *userDictionary  in participantsArray) {
            [participantsModelArray addObject:[self userModelFromDictionary:userDictionary]];
        }
        room.admins = adminUserIDArray;
        room.participants = participantsModelArray;
        
        [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:room];
        
        success(room);
        
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

+ (void)callAPILeaveRoomWithRoomID:(NSString *)roomID
                           success:(void (^)(void))success
                           failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeLeaveRoom];
    
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:roomID forKey:@"roomID"];
    
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
                    [TAPDataManager callAPILeaveRoomWithRoomID:roomID success:success failure:failure];
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
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSNumber *successNumber = [dataDictionary objectForKey:@"success"];
        BOOL successBool = [successNumber boolValue];
        
        if (successBool) {
            success();
        }
        else {
            NSString *errorMessage = [dataDictionary objectForKey:@"message"];
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:90102 userInfo:@{@"message": errorMessage}];
            failure(error);
        }
        
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

+ (void)callAPIDeleteRoomWithRoom:(TAPRoomModel *)room
                          success:(void (^)(void))success
                          failure:(void (^)(NSError *error))failure {
    
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    NSTimeInterval getAccessTokenExpiryTime = [TAPDataManager getAccessTokenExpiryTime];
    NSString *generatedMD5String = [TAPDataManager generateChecksumWithRoomID:room.roomID roomType:room.type userID:currentUser.userID accessTokenExpiry:getAccessTokenExpiryTime];
    
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeDeleteRoom];
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    [parameterDictionary setObject:room.roomID forKey:@"roomID"];
    [parameterDictionary setObject:generatedMD5String forKey:@"checksum"];
    
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
                    [TAPDataManager callAPIDeleteRoomWithRoom:room success:success failure:failure];
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
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        
        NSNumber *successNumber = [dataDictionary objectForKey:@"success"];
        BOOL successBool = [successNumber boolValue];
        
        if (successBool) {
            success();
        }
        else {
            NSString *errorMessage = [dataDictionary objectForKey:@"message"];
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:90101 userInfo:@{@"message": errorMessage}];
            failure(error);
        }
        
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

+ (void)callAPIGetProjectConfigsWithSuccess:(void (^)(NSDictionary *projectConfigsDictionary))success
                                    failure:(void (^)(NSError *error))failure {
    NSString *requestURL = [[TAPAPIManager sharedManager] urlForType:TAPAPIManagerTypeGetProjectConfigs];
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
                    [TAPDataManager callAPIGetProjectConfigsWithSuccess:success failure:failure];
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
            success([NSDictionary dictionary]);
            return;
        }
        
        NSDictionary *dataDictionary = [responseObject objectForKey:@"data"];
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        
        NSDictionary *coreDictionary = [dataDictionary objectForKey:@"core"];
        coreDictionary = [TAPUtil nullToEmptyDictionary:coreDictionary];
        
        NSDictionary *projectDictionary = [dataDictionary objectForKey:@"project"];
        projectDictionary = [TAPUtil nullToEmptyDictionary:projectDictionary];
        
        NSDictionary *customDictionary = [dataDictionary objectForKey:@"custom"];
        customDictionary = [TAPUtil nullToEmptyDictionary:customDictionary];
        
        NSMutableDictionary *projectConfigsDictionary = [NSMutableDictionary dictionary];
        [projectConfigsDictionary setObject:coreDictionary forKey:@"core"];
        [projectConfigsDictionary setObject:projectDictionary forKey:@"project"];
        [projectConfigsDictionary setObject:customDictionary forKey:@"custom"];
        
        [[NSUserDefaults standardUserDefaults] setSecureObject:projectConfigsDictionary forKey:TAP_PREFS_PROJECT_CONFIGS_DICTIONARY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        success(projectConfigsDictionary);
        
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
