//
//  TAPChatManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 15/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TAPMessageModel.h"
#import "TAPUserModel.h"
#import "TAPRoomModel.h"
#import "TAPOnlineStatusModel.h"
#import "TAPTypingModel.h"
#import "TAPQuoteModel.h"

typedef NS_ENUM(NSInteger, TAPChatManagerQuoteActionType) {
    TAPChatManagerQuoteActionTypeReply = 0,
    TAPChatManagerQuoteActionTypeForward = 1
};

@protocol TAPChatManagerDelegate <NSObject>

@optional

- (void)chatManagerDidSendNewMessage:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveNewMessageInActiveRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveNewMessageOnOtherRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveUpdateMessageInActiveRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveUpdateMessageOnOtherRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveDeleteMessageInActiveRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveDeleteMessageOnOtherRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveOnlineStatus:(TAPOnlineStatusModel *)onlineStatus;
- (void)chatManagerDidReceiveStartTyping:(TAPTypingModel *)typing;
- (void)chatManagerDidReceiveStopTyping:(TAPTypingModel *)typing;

@end

@interface TAPChatManager : NSObject

@property (strong, nonatomic) TAPUserModel *activeUser;
@property (strong, nonatomic) TAPRoomModel *activeRoom;
@property (strong, nonatomic) NSMutableDictionary *messageDraftDictionary;
@property (strong, nonatomic) NSMutableDictionary *quotedMessageDictionary;
@property (strong, nonatomic) NSMutableDictionary *quoteActionTypeDictionary;
@property (strong, nonatomic) NSMutableDictionary *userInfoDictionary; //contains user info from custom quote
@property (nonatomic) TAPChatManagerQuoteActionType chatManagerQuoteActionType;
@property (nonatomic) BOOL isTyping;

+ (TAPChatManager *)sharedManager;

#warning Do not forget to remove the delegate object, since an object can't weak retained in an array, also please remove this delegate before dealloc or the delegate will always retained
- (void)addDelegate:(id <TAPChatManagerDelegate>)delegate;
- (void)removeDelegate:(id <TAPChatManagerDelegate>)delegate;

- (void)connect;
- (void)disconnect;
- (void)openRoom:(TAPRoomModel *)room;
- (void)closeActiveRoom;
- (void)startTyping;
- (void)stopTyping;

- (void)notifySendMessageToDelegate:(TAPMessageModel *)message;

- (void)sendTextMessage:(NSString *)textMessage;
- (void)sendTextMessage:(NSString *)textMessage room:(TAPRoomModel *)room;
- (void)sendImageMessage:(UIImage *)image caption:(NSString *)caption;
- (void)sendImageMessage:(UIImage *)image caption:(NSString *)caption room:(TAPRoomModel *)room;
- (void)sendEmitFileMessage:(TAPMessageModel *)message;
- (void)sendProductMessage:(TAPMessageModel *)message;
- (void)sendLocationMessage:(CGFloat)latitude longitude:(CGFloat)longitude address:(NSString *)address;
- (void)sendLocationMessage:(CGFloat)latitude longitude:(CGFloat)longitude address:(NSString *)address room:(TAPRoomModel *)room;
- (void)sendFileMessage:(NSData *)data;
- (void)sendFileMessage:(NSData *)data room:(TAPRoomModel *)room;

- (void)saveMessageToDraftWithMessage:(NSString *)message roomID:(NSString *)roomID;
- (NSString *)getMessageFromDraftWithRoomID:(NSString *)roomID;
- (void)saveToQuotedMessage:(id)quotedMessageObject userInfo:(NSDictionary *)userInfo roomID:(NSString *)roomID; //Object could be TAPMessageModel or TAPQuoteModel
- (void)saveToQuoteActionWithType:(TAPChatManagerQuoteActionType)type roomID:(NSString *)roomID;//save to quoteActionTypeDictionary to identify whether it is reply or forward

- (id)getQuotedMessageObjectWithRoomID:(NSString *)roomID; //Object could be TAPMessageModel or TAPQuoteModel
- (TAPChatManagerQuoteActionType)getQuoteActionTypeWithRoomID:(NSString *)roomID;
- (void)removeQuotedMessageObjectWithRoomID:(NSString *)roomID;

- (void)runEnterBackgroundSequenceWithApplication:(UIApplication *)application;
- (void)removeAllBackgroundSequenceTaskWithApplication:(UIApplication *)application;
- (void)updateSendingMessageToFailed;
- (void)saveNewMessageToDatabase;
- (void)saveAllUnsentMessage;
- (void)saveAllUnsentMessageInMainThread;
- (void)saveIncomingMessageAndDisconnect;
- (void)saveUnsentMessageAndDisconnect;
- (void)triggerSaveNewMessage;
- (BOOL)checkIsTypingWithRoomID:(NSString *)roomID;
- (BOOL)checkShouldRefreshOnlineStatus;
- (void)refreshShouldRefreshOnlineStatus;
- (void)addToWaitingUploadFileMessage:(TAPMessageModel *)message;
- (void)removeFromWaitingUploadFileMessage:(TAPMessageModel *)message;
- (TAPMessageModel *)getMessageFromWaitingUploadDictionaryWithKey:(NSString *)localID;
- (NSString *)getOtherUserIDWithRoomID:(NSString *)roomID;
- (void)checkAndSendForwardedMessageWithRoom:(TAPRoomModel *)room;

@end
