//
//  TAPAPIManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 28/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPAPIManager.h"

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
        _APIBaseURL = [NSString string];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)setBaseAPIURLString:(NSString *)urlString {
    _APIBaseURL = urlString;
}

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
//        NSString *formattedAPIBaseURL = [self.APIBaseURL stringByReplacingOccurrencesOfString:@"api" withString:@""];
        NSString *formattedAPIBaseURL = self.APIBaseURL;
        NSString *apiPath = @"/connect?check=1";
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
    else if (type == TAPAPIManagerTypeLogout) {
        NSString *apiPath = @"client/logout";
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
    else if (type == TAPAPIManagerTypeGetBulkUserByID) {
        NSString *apiPath = @"client/user/get_all_by_ids";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetCountry) {
        NSString *apiPath = @"client/country/list";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeRequestOTP) {
        NSString *apiPath = @"client/login/request_otp/v1_6";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeVerifyOTP) {
        NSString *apiPath = @"client/login/verify_otp";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeCheckUsername) {
        NSString *apiPath = @"client/user/exists/username";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeRegister) {
        NSString *apiPath = @"client/register";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeAddContactByPhones) {
        NSString *apiPath = @"client/contact/add_by_phones";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeUploadUserPhoto) {
        NSString *apiPath = @"client/user/photo/upload";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeDeleteMessage) {
        NSString *apiPath = @"chat/message/delete";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeCreateRoom) {
        NSString *apiPath = @"client/room/create";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeUploadRoomPhoto) {
        NSString *apiPath = @"client/room/photo/upload";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeUpdateRoom) {
        NSString *apiPath = @"client/room/update";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetRoom) {
        NSString *apiPath = @"client/room/get";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetXCRoom) {
        NSString *apiPath = @"client/room/get_by_xc_room_id";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeAddRoomParticipants) {
        NSString *apiPath = @"client/room/participants/add";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeRemoveRoomParticipants) {
        NSString *apiPath = @"client/room/participants/remove";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypePromoteRoomAdmins) {
        NSString *apiPath = @"client/room/admins/promote";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeDemoteRoomAdmins) {
        NSString *apiPath = @"client/room/admins/demote";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeLeaveRoom) {
        NSString *apiPath = @"client/room/leave";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeDeleteRoom) {
        NSString *apiPath = @"client/room/delete";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetProjectConfigs) {
        NSString *apiPath = @"client/project_configs";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeUpdateBio) {
        NSString *apiPath = @"client/user/update_bio";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetPhotoList) {
        NSString *apiPath = @"client/user/photo/get_list";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeSetProfilePhotoAsMain) {
        NSString *apiPath = @"client/user/photo/set_main";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeRemoveProfilePhoto) {
        NSString *apiPath = @"client/user/photo/delete";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }

    else if (type == TAPAPIManagerTypeMarkAsUnread) {
        NSString *apiPath = @"client/room/mark_as_unread";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetUnreadRommIDs) {
        NSString *apiPath = @"client/room/get_unread_room_ids";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    
    else if (type == TAPAPIManagerTypeStarMessage) {
        NSString *apiPath = @"chat/message/star";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeUnStarMessage) {
        NSString *apiPath = @"chat/message/unstar";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeUnStarMessage) {
        NSString *apiPath = @"chat/message/unstar";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetStarredMessages) {
        NSString *apiPath = @"chat/message/get_starred_list";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }
    else if (type == TAPAPIManagerTypeGetStarredMessagesIDs) {
        NSString *apiPath = @"chat/message/get_starred_ids";
        return [NSString stringWithFormat:@"%@/%@/%@", self.APIBaseURL, kAPIVersionString, apiPath];
    }

    return [NSString stringWithFormat:@"%@", self.APIBaseURL];
}

@end
