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

@protocol TAPChatManagerDelegate <NSObject>

@optional

- (void)chatManagerDidSendNewMessage:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveNewMessageInActiveRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveNewMessageOnOtherRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveUpdateMessageInActiveRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveUpdateMessageOnOtherRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveDeleteMessageInActiveRoom:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveDeleteMessageOnOtherRoom:(TAPMessageModel *)message;

- (void)chatManagerShouldDecreaseUnreadBubbleForRoomID:(NSString *)roomID;

//DV Temp
- (void)chatManagerDidReceiveOnlineStatus:(TAPMessageModel *)message;
- (void)chatManagerDidReceiveOfflineStatus:(TAPMessageModel *)message;
//DV Temp

@end

@interface TAPChatManager : NSObject

@property (strong, nonatomic) TAPUserModel *activeUser;
@property (strong, nonatomic) TAPRoomModel *activeRoom;
@property (strong, nonatomic) NSMutableDictionary *messageDraftDictionary;
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

- (void)sendTextMessage:(NSString *)textMessage;

- (void)saveMessageToDraftWithMessage:(NSString *)message roomID:(NSString *)roomID;
- (NSString *)getMessageFromDraftWithRoomID:(NSString *)roomID;

- (void)startTyping;
- (void)stopTyping;
- (void)runEnterBackgroundSequenceWithApplication:(UIApplication *)application;
- (void)removeAllBackgroundSequenceTaskWithApplication:(UIApplication *)application;
- (void)updateSendingMessageToFailed;
- (void)saveNewMessageToDatabase;
- (void)saveAllUnsentMessage;
- (void)saveAllUnsentMessageInMainThread;
- (void)saveIncomingMessageAndDisconnect;
- (void)saveUnsentMessageAndDisconnect;
- (void)triggerSaveNewMessage;
- (void)decreaseUnreadMessageForRoomID:(NSString *)roomID;

@end
