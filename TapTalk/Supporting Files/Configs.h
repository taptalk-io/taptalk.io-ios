// Configs.h

//Application
//#define APP_STORE_URL @"https://itunes.apple.com/us/app/moselo-chat-buy-services-from-local-experts/id1257677004?ls=1&mt=8"
//#define SHORTENED_APP_STORE_URL @"http://bit.ly/MoseloiOS"
//#define APP_STORE_ID @"1257677004"
//#define TAP_SECURE_KEY_NSUSERDEFAULTS @"h0m1ngp1g30n-m0s3l0-81191E@c"
#define TAP_SECURE_KEY_NSUSERDEFAULTS @"e0f31146225f4d56758e549fcd98d227ec3a02fdMoselo"
#define TAP_NUMBER_OF_ITEMS_CHAT 50
#define TAP_LIMIT_OF_CAPTION_CHARACTER 100

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
#define TAP_PREFS_IS_DONE_FIRST_SETUP @"Prefs.TapTalkIsDoneFirstSetup"
#define TAP_PREFS_LAST_UPDATED_CHAT_ROOM @"Prefs.TapTalkLastUpdatedChatRoom"
#define TAP_PREFS_LAST_DELETED_OLD_MESSAGE_TIMESTAMP @"Prefs.TapTalkLastDeletedOldMessageTimestamp"

//DV Temp
//DV Note - 14 Sept Temporary added for checking 1 on 1 chat
#define TAP_PREFS_OTHER_USER_ID @"Prefs.TapTalkOtherUserID"
#define TAP_PREFS_INCOMING_PUSH_NOTIFICATION @"Prefs.TapTalkIncomingPushNotification"
//END DV Temp

//User Customized Prefs
#define TAP_PREFS_USER_AGENT @"Prefs.TapTalkUserAgent"
#define TAP_PREFS_APP_KEY_ID @"Prefs.TapTalkAppKeyID"
#define TAP_PREFS_APP_KEY_SECRET @"Prefs.TapTalkAppKeySecret"

//Color
#define TAP_COLOR_MOSELO_GREEN @"2ECCAD"
#define TAP_COLOR_MOSELO_PURPLE @"784198"
#define TAP_COLOR_BLACK_44 @"444444"
#define TAP_COLOR_WHITE_F3 @"F3F3F3"
#define TAP_COLOR_GREY_9B @"9B9B9B"
#define TAP_COLOR_GREY_EA @"EAEAEA"
#define TAP_COLOR_GREY_AA @"AAAAAA"
#define TAP_COLOR_GREY_E4 @"E4E4E4"
#define TAP_COLOR_GREY_ED @"EDEDED"
#define TAP_COLOR_BLACK_2C @"2C2C2C"
#define TAP_COLOR_GREENBLUE_93 @"00B793"
#define TAP_COLOR_AQUAMARINE_C1 @"3DE1C1"
#define TAP_COLOR_CORALPINK_6A @"FF566A"
#define TAP_COLOR_BUTTERSCOTCH_38 @"FFB438"

//Font
#define TAP_FONT_NAME_REGULAR @"NeueEinstellung-Regular"
#define TAP_FONT_NAME_THIN @"NeueEinstellung-Thin"
#define TAP_FONT_NAME_NORMAL @"NeueEinstellung-Normal"
#define TAP_FONT_NAME_LIGHT @"NeueEinstellung-Light"
#define TAP_FONT_NAME_MEDIUM @"NeueEinstellung-Medium"
#define TAP_FONT_NAME_SEMIBOLD @"NeueEinstellung-SemiBold"
#define TAP_FONT_NAME_BOLD @"NeueEinstellung-Bold"
#define TAP_FONT_NAME_EXTRABOLD @"NeueEinstellung-ExtraBold"
#define TAP_FONT_NAME_BLACK @"NeueEinstellung-Black"

#define TAP_FONT_LATO_REGULAR @"Lato-Regular"
#define TAP_FONT_LATO_HAIRLINE @"Lato-Hairline"
#define TAP_FONT_LATO_LIGHT_ITALIC @"Lato-LightItalic"
#define TAP_FONT_LATO_ITALIC @"Lato-Italic"
#define TAP_FONT_LATO_BOLD @"Lato-Bold"
#define TAP_FONT_LATO_BOLD_ITALIC @"Lato-BoldItalic"
#define TAP_FONT_LATO_BLACK @"Lato-Black"
#define TAP_FONT_LATO_LIGHT @"Lato-Light"
#define TAP_FONT_LATO_BLACK_ITALIC @"Lato-BlackItalic"

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

typedef NS_ENUM(NSInteger, TAPChatMessageType) {
    //First Digit
    //1 for Standard Chat Bubble
    //2 for Commerce Chat Bubble
    //3 for User Customized Chat Bubble
    
    TAPChatMessageTypeText = 1001,
    TAPChatMessageTypeImage = 1002,
    TAPChatMessageTypeVideo = 1003,
    TAPChatMessageTypeFile = 1004,
    TAPChatMessageTypeLocation = 1005,
    TAPChatMessageTypeContact = 1006,
    TAPChatMessageTypeSticker = 1007,
    
    TAPChatMessageTypeProduct = 2001,
    TAPChatMessageTypeCategory = 2002,
    TAPChatMessageTypeOrderCard = 2003,
    TAPChatMessageTypePaymentConfirmation = 2004
};
