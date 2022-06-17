// Configs.h

//Application
//#define TAP_SECURE_KEY_NSUSERDEFAULTS @"h0m1ngp1g30n-m0s3l0-81191E@c"
#define TAP_SECURE_KEY_NSUSERDEFAULTS @"e0f31146225f4d56758e549fcd98d227ec3a02fdMoselo"
#define TAP_NUMBER_OF_ITEMS_CHAT 50
#define TAP_LIMIT_OF_CAPTION_CHARACTER 100

#define TAP_MAX_IMAGE_LARGE_SIZE 2000.0f
#define TAP_MAX_THUMBNAIL_IMAGE_SIZE 20.0f
#define TAP_DEFAULT_MAX_FILE_SIZE 5 * 1024 * 1024 //5 MB
#define TAP_DEFAULT_IMAGE_COMPRESSION_QUALITY 0.5f
#define TAP_DEFAULT_MAX_GROUP_PARTICIPANTS 100
#define TAP_DEFAULT_MAX_CHANNEL_PARTICIPANTS 5000
#define TAP_UPDATED_TIME_LIMIT 24 * 60 * 60 //1 day (in seconds)
#define TAP_NUMBER_OF_ITEMS_API_MESSAGE_BEFORE 50
#define kCharacterLimit 4000

//Prefs Key
#define TAP_PREFS_ACTIVE_USER @"Prefs.TapTalkActiveUser"
#define TAP_PREFS_UNREAD_ROOMIDS @"Prefs.TapTalkUnreadRoomIDs"
#define TAP_PREFS_CURRENT_VOICE_MESSAGE_PLAYING @"Prefs.TapTalkCurrentVoiceNoteMessagePlaying"
#define TAP_PREFS_PUSH_TOKEN @"Prefs.TapTalkPushToken"
#define TAP_PREFS_ACCESS_TOKEN @"Prefs.TapTalkAccessToken"
#define TAP_PREFS_REFRESH_TOKEN @"Prefs.TapTalkRefreshToken"
#define TAP_PREFS_REFRESH_TOKEN_EXPIRED_TIME @"Prefs.TapTalkRefreshTokenExpiredTime"
#define TAP_PREFS_ACCESS_TOKEN_EXPIRED_TIME @"Prefs.TapTalkAccessTokenExpiredTime"
#define TAP_PREFS_IS_DONE_FIRST_SETUP @"Prefs.TapTalkIsDoneFirstSetup"
#define TAP_PREFS_LAST_UPDATED_CHAT_ROOM @"Prefs.TapTalkLastUpdatedChatRoom"
#define TAP_PREFS_LAST_DELETED_OLD_MESSAGE_TIMESTAMP @"Prefs.TapTalkLastDeletedOldMessageTimestamp"
#define TAP_PREFS_FILE_PATH_DICTIONARY @"Prefs.TapTalkFilePathDictionary"
#define TAP_PREFS_COUNTRY_LIST_ARRAY @"Prefs.TapTalkCountryListArray"
#define TAP_PREFS_COUNTRY_LIST_DICTIONARY @"Prefs.TapTalkCountryListDictionary"
#define TAP_PREFS_LAST_UPDATED_COUNTRY_LIST_TIMESTAMP @"Prefs.TapTalkLastUpdatedCountryListTimestamp"
#define TAP_PREFS_USER_LOGIN_PHONE_TEMP_DICTIONARY @"Prefs.TapTalkUserLoginPhoneTempDictionary"
#define TAP_PREFS_USER_COUNTRY_CODE @"Prefs.TapTalkUserCountryCode"
#define TAP_PREFS_CONTACT_PERMISSION_ASKED @"Prefs.TapTalkContactPermissionAsked"
#define TAP_PREFS_ROOM_MODEL_DICTIONARY @"Prefs.TapTalkRoomModelDictionary"
#define TAP_PREFS_PROJECT_CONFIGS_DICTIONARY @"Prefs.TapTalkProjectConfigsDictionary"
#define TAP_PREFS_AUTO_SYNC_CONTACT_DISABLED @"Prefs.TapTalkAutoSyncContactDisabled"
#define TAP_PREFS_IS_CONTACT_SYNC_ALLOWED_BY_USER @"Prefs.TapTalkIsContactSyncAllowedByUser"
#define TAP_PREFS_PENDING_UPDATE_READ_MESSAGE @"Prefs.TapTalkPendingUpdateReadMessage"
#define TAP_PREFS_USER_IGNORE_ADD_CONTACT_POPUP_DICTIONARY @"Prefs.TapTalkUserIgnoreAddContactPopupDictionary"
#define TAP_PREFS_GOOGLE_PLACES_TOKEN @"Prefs.TapTalkGooglePlacesToken"

//Color
#define TAP_COLOR_WHITE @"FFFFFF"
#define TAP_COLOR_GREY_DC @"DCDCDC"

//Notification
#define TAP_NOTIFICATION_SOCKET_CONNECTING @"Notification.TapTalkIsConnecting"
#define TAP_NOTIFICATION_SOCKET_CONNECTED @"Notification.TapTalkIsConnected"
#define TAP_NOTIFICATION_SOCKET_RECEIVE_ERROR @"Notification.TapTalkIsReceiveError"
#define TAP_NOTIFICATION_SOCKET_RECONNECTING @"Notification.TapTalkIsReconnecting"
#define TAP_NOTIFICATION_SOCKET_DISCONNECTED @"Notification.TapTalkIsDisonnected"
#define TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED @"Notification.TapTalkReachabilityStatusChanged"
#define TAP_NOTIFICATION_APPLICATION_DID_FINISH_LAUNCHING @"Notification.TapTalkApplicationDidFinishLaunching"
#define TAP_NOTIFICATION_APPLICATION_WILL_RESIGN_ACTIVE @"Notification.TapTalkApplicationWillResignActive"
#define TAP_NOTIFICATION_APPLICATION_DID_ENTER_BACKGROUND @"Notification.TapTalkApplicationDidEnterBackground"
#define TAP_NOTIFICATION_APPLICATION_WILL_ENTER_FOREGROUND @"Notification.TapTalkApplicationWillEnterForeground"
#define TAP_NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE @"Notification.TapTalkApplicationDidBecomeActive"
#define TAP_NOTIFICATION_APPLICATION_WILL_TERMINATE @"Notification.TapTalkApplicationWillTerminate"
#define TAP_NOTIFICATION_UPLOAD_FILE_START @"Notification.TapTalkUploadFileStart"
#define TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS @"Notification.TapTalkUploadFileProgress"
#define TAP_NOTIFICATION_UPLOAD_FILE_FINISH @"Notification.TapTalkUploadFileFinish"
#define TAP_NOTIFICATION_UPLOAD_FILE_FAILURE @"Notification.TapTalkUploadFileFailure"
#define TAP_NOTIFICATION_DOWNLOAD_FILE_START @"Notification.TapTalkDownloadFileStart"
#define TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS @"Notification.TapTalkDownloadFileProgress"
#define TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH @"Notification.TapTalkDownloadFileFinish"
#define TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE @"Notification.TapTalkDownloadFileFailure"
#define TAP_NOTIFICATION_USER_PROFILE_CHANGES @"Notification.TapTalkUserProfileChanges"

#define TAP_NOTIFICATION_USER_LEAVE_GROUP @"Notification.TapTalkUserLeaveGroup"

//Typedef
#define kTAPEventNewMessage @"chat/sendMessage"
#define kTAPEventUpdateMessage @"chat/updateMessage"
#define kTAPEventStartTyping @"chat/startTyping"
#define kTAPEventStopTyping @"chat/stopTyping"
#define kTAPEventEditMessage @"chat/editMessage"
#define kTAPEventUserOnline @"user/status"
#define kTAPEventUserUpdated @"user/updated"

//Domain
#define TAPErrorDomain @"user/updated"

//Login
#define API_REQUEST_OTP_TYPE_SMS @"sms"
#define API_REQUEST_OTP_TYPE_WHATSAPP @"whatsapp"
#define API_REQUEST_OTP_TYPE_WHATSAPP_INVALID_RECIPIENT @"invalid_recipient"

//AppGroupName
#define APP_GROUP_NAME_DEV @"group.io.taptalk.TapTalk-Dev"
#define APP_GROUP_NAME_STAGING @"group.io.taptalk.TapTalk-Staging"
#define APP_GROUP_NAME_RELEASE @"group.io.taptalk.TapTalk"
