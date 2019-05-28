// Configs.h

//Application
//#define APP_STORE_URL @"https://itunes.apple.com/us/app/moselo-chat-buy-services-from-local-experts/id1257677004?ls=1&mt=8"
//#define SHORTENED_APP_STORE_URL @"http://bit.ly/MoseloiOS"
//#define APP_STORE_ID @"1257677004"

//#define TAP_SECURE_KEY_NSUSERDEFAULTS @"h0m1ngp1g30n-m0s3l0-81191E@c"
#define TAP_SECURE_KEY_NSUSERDEFAULTS @"e0f31146225f4d56758e549fcd98d227ec3a02fdMoselo"
#define TAP_NUMBER_OF_ITEMS_CHAT 50
#define TAP_LIMIT_OF_CAPTION_CHARACTER 100

#define TAP_MAX_IMAGE_SIZE 2000.0f
#define TAP_MAX_THUMBNAIL_IMAGE_SIZE 20.0f
#define TAP_MAX_FILE_SIZE 25 * 1024 * 1024 //25 MB
#define TAP_MAX_VIDEO_SIZE 25 //in MB
#define TAP_UPDATED_TIME_LIMIT 24 * 60 * 60 //1 day (in seconds)

#define TAP_DUMMY_IMAGE_URL @"https://instagram.fcgk6-1.fna.fbcdn.net/vp/a957263ad8322a1661f604e2942f1acc/5C5B8666/t51.2885-15/e35/41659851_331857600921431_1280889939227049984_n.jpg"//DV Temp

//Database
//#define DB_NAME @"moselo.sqlite"

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

//User Customized Prefs
#define TAP_PREFS_USER_AGENT @"Prefs.TapTalkUserAgent"
#define TAP_PREFS_APP_KEY_ID @"Prefs.TapTalkAppKeyID"
#define TAP_PREFS_APP_KEY_SECRET @"Prefs.TapTalkAppKeySecret"

//Color
#define TAP_COLOR_WHITE @"FFFFFF"
#define TAP_COLOR_GREEN_AD @"2ECCAD"
#define TAP_COLOR_GREEN_2A @"7EC82A"
#define TAP_COLOR_PURPLE_98 @"784198"
#define TAP_COLOR_BLACK_44 @"444444"
#define TAP_COLOR_BLACK_19 @"191919"
#define TAP_COLOR_BLACK_2C @"2C2C2C"
#define TAP_COLOR_WHITE_F3 @"F3F3F3"
#define TAP_COLOR_GREY_9B @"9B9B9B"
#define TAP_COLOR_GREY_EA @"EAEAEA"
#define TAP_COLOR_GREY_AA @"AAAAAA"
#define TAP_COLOR_GREY_E4 @"E4E4E4"
#define TAP_COLOR_GREY_ED @"EDEDED"
#define TAP_COLOR_GREY_DC @"DCDCDC"
#define TAP_COLOR_GREY_8C @"8C8C8C"
#define TAP_COLOR_GREY_CE @"CECECE"
#define TAP_COLOR_GREENBLUE_93 @"00B793"
#define TAP_COLOR_AQUAMARINE_C1 @"3DE1C1"
#define TAP_COLOR_CORALPINK_6A @"FF566A"
#define TAP_COLOR_REDPINK_57 @"FF3F57"
#define TAP_COLOR_BUTTERSCOTCH_38 @"FFB438"
#define TAP_COLOR_DODGERBLUE_FF @"48BEFF"
#define TAP_COLOR_BLURPLE_D7 @"362AD7"
#define TAP_COLOR_ORANGE_33 @"FF9833"
#define TAP_COLOR_ORANGE_00 @"FF7E00"
#define TAP_COLOR_ORANGE_200 @"E87200"
#define TAP_COLOR_ORANGE_45 @"FFA045"
#define TAP_COLOR_BLUE_FA @"5AC8FA"

//Component Color
#define TAP_COLOR_PRIMARY_COLOR_1 TAP_COLOR_ORANGE_00

#define TAP_COLOR_TEXT_FIELD_ACTIVE_BORDER_COLOR TAP_COLOR_PRIMARY_COLOR_1
#define TAP_COLOR_TEXT_FIELD_POINTER_COLOR TAP_COLOR_PRIMARY_COLOR_1
#define TAP_COLOR_TEXT_FIELD_CANCEL_BUTTON_COLOR TAP_COLOR_PRIMARY_COLOR_1
#define TAP_KEYBOARD_ACCESSORY_DONE_BUTTON_COLOR TAP_COLOR_PRIMARY_COLOR_1
#define TAP_TABLE_VIEW_SECTION_INDEX_COLOR TAP_COLOR_PRIMARY_COLOR_1
#define TAP_COLOR_LINK_BASE_COLOR TAP_COLOR_ORANGE_200
#define TAP_COLOR_LINK_HIGHLIGHTED_COLOR TAP_COLOR_BLUE_FA

#define TAP_BUTTON_BACKGROUND_TOP_GRADIENT_COLOR TAP_COLOR_ORANGE_33
#define TAP_BUTTON_BACKGROUND_BOTTOM_GRADIENT_COLOR TAP_COLOR_ORANGE_00

//Font
#define TAP_FONT_NAME_REGULAR @"PTRootUI-Regular"
#define TAP_FONT_NAME_LIGHT @"PTRootUI-Light"
#define TAP_FONT_NAME_MEDIUM @"PTRootUI-Medium"
#define TAP_FONT_NAME_BOLD @"PTRootUI-Bold"

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

//Typedef
#define kTAPEventOpenRoom @"chat/openRoom"
#define kTAPEventCloseRoom @"chat/closeRoom"
#define kTAPEventNewMessage @"chat/sendMessage"
#define kTAPEventUpdateMessage @"chat/updateMessage"
#define kTAPEventDeleteMessage @"chat/deleteMessage"
#define kTAPEventOpenMessage @"chat/openMessage"
#define kTAPEventStartTyping @"chat/startTyping"
#define kTAPEventStopTyping @"chat/stopTyping"
#define kTAPEventAuthentication @"user/authentication"
#define kTAPEventUserOnline @"user/status"
#define kTAPEventUserUpdated @"user/updated"
