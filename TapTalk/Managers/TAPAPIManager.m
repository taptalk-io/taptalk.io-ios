//
//  TAPAPIManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 28/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPAPIManager.h"

static NSString * const kBaseURLProduction = @"https://hp.moselo.com:8080";
static NSString * const kBaseURLStaging = @"https://hp-staging.moselo.com:8080";
static NSString * const kBaseURLDevelopment = @"https://hp-dev.moselo.com:8080";

//static NSString * const kBaseURL = @"https://hp-staging.moselo.com:8080";
//static NSString * const kBaseURL = @"https://dev.taptalk.io:8080";
static NSString * const kAPIVersionString = @"v1";

@interface TAPAPIManager ()

@property (strong, nonatomic) NSString *APIBaseURL;

@end

@implementation TAPAPIManager

#pragma mark - Lifecycle
+ (TAPAPIManager *)sharedManager {
    static TAPAPIManager *sharedManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[TAPAPIManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
            TapTalkEnvironment environmentType = [TapTalk sharedInstance].environment;

            _APIBaseURL = [NSString string];
            if (environmentType == TapTalkEnvironmentDevelopment) {
                _APIBaseURL = [NSString stringWithFormat:@"%@/api", kBaseURLDevelopment];
            }
            else if (environmentType == TapTalkEnvironmentStaging) {
                _APIBaseURL = [NSString stringWithFormat:@"%@/api", kBaseURLStaging];
            }
            else {
                _APIBaseURL = [NSString stringWithFormat:@"%@/api", kBaseURLProduction];
            }
    }
    
    return self;
}

#pragma mark - Custom Method
- (NSString *)urlForType:(TAPAPIManagerType)type {
    if (type == TAPAPIManagerTypeGetAuthTicket) {
        NSString *apiPath = @"server/auth_ticket/request";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
        
    }
    else if (type == TAPAPIManagerTypeGetAccessToken) {
        NSString *apiPath = @"auth/access_token/request";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeRefreshAccessToken) {
        NSString *apiPath = @"auth/access_token/refresh";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeValidateAccessToken) {
        NSString *formattedAPIBaseURL = [self.APIBaseURL stringByReplacingOccurrencesOfString:@"api" withString:@""];
        NSString *apiPath = @"pigeon?check=1";
        return [NSString stringWithFormat:@"%@%@", formattedAPIBaseURL, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetMessageRoomListAndUnread) {
        NSString *apiPath = @"chat/message/room_list_and_unread";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetMessageRoomListAfter) {
        NSString *apiPath = @"chat/message/list_by_room/after";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetMessageRoomListBefore) {
        NSString *apiPath = @"chat/message/list_by_room/before";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetPendingNewAndUpdatedMessages) {
        NSString *apiPath = @"chat/message/new_and_updated";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetContactList) {
        NSString *apiPath = @"client/contact/list";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeAddContact) {
        NSString *apiPath = @"client/contact/add";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeRemoveContact) {
        NSString *apiPath = @"client/contact/remove";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetUserByUserID) {
        NSString *apiPath = @"client/user/get_by_id";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetUserByXCUserID) {
        NSString *apiPath = @"client/user/get_by_xcuserid";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetUserByUsername) {
        NSString *apiPath = @"client/user/get_by_username";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeUpdatePushNotification) {
        NSString *apiPath = @"client/push_notification/update";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeUpdateMessageDeliveryStatus) {
        NSString *apiPath = @"chat/message/feedback/delivered";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeUpdateMessageReadStatus) {
        NSString *apiPath = @"chat/message/feedback/read";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeUploadFile) {
        NSString *apiPath = @"chat/file/upload";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeDownloadFile) {
        NSString *apiPath = @"chat/file/download";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    
    return [NSString stringWithFormat:@"%@", self.APIBaseURL];
}

@end
