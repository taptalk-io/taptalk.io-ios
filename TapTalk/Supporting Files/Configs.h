// Configs.h

//Application
//#define TAP_SECURE_KEY_NSUSERDEFAULTS @"h0m1ngp1g30n-m0s3l0-81191E@c"
#define TAP_SECURE_KEY_NSUSERDEFAULTS @"e0f31146225f4d56758e549fcd98d227ec3a02fdMoselo"
#define TAP_NUMBER_OF_ITEMS_CHAT 50
#define TAP_LIMIT_OF_CAPTION_CHARACTER 100

#define TAP_MAX_IMAGE_SIZE 2000.0f
#define TAP_MAX_THUMBNAIL_IMAGE_SIZE 20.0f
#define TAP_MAX_FILE_SIZE 25 * 1024 * 1024 //25 MB
#define TAP_MAX_VIDEO_SIZE 25 //in MB
#define TAP_UPDATED_TIME_LIMIT 24 * 60 * 60 //1 day (in seconds)

//Prefs Key
#define TAP_PREFS_ACTIVE_USER @"Prefs.TapTalkActiveUser"
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

//User Customized Prefs
#define TAP_PREFS_USER_AGENT @"Prefs.TapTalkUserAgent"
#define TAP_PREFS_APP_KEY_ID @"Prefs.TapTalkAppKeyID"
#define TAP_PREFS_APP_KEY_SECRET @"Prefs.TapTalkAppKeySecret"

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
#define kTAPEventUserOnline @"user/status"
#define kTAPEventUserUpdated @"user/updated"
