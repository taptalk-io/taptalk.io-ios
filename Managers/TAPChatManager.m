//
//  TAPChatManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 15/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPChatManager.h"
#import "TAPConnectionManager.h"

#define kCharacterLimit 1000
#define kMaximumRetryAttempt 10
#define kDelayTime 60.0f

@interface TAPChatManager () <TAPConnectionManagerDelegate>

- (void)sendMessage:(TAPMessageModel *)message;
- (void)checkAndSendPendingMessage;
- (void)checkPendingBackgroundTask;
- (void)receiveMessageFromSocketWithEvent:(NSString *)eventName dataDictionary:(NSDictionary *)dataDictionary;
- (void)receiveOnlineStatusFromSocketWithDataDictionary:(NSDictionary *)dataDictionary;
- (void)receiveOfflineStatusFromSocketWithDataDictionary:(NSDictionary *)dataDictionary;
- (void)receiveContactUpdatedFromSocketWithDataDictionary:(NSDictionary *)dataDictionary;
- (void)stopTimerSaveNewMessage;
- (void)runSendMessageSequenceWithMessage:(TAPMessageModel *)message;
- (void)processMessageAsDelivered:(TAPMessageModel *)message;

@property (strong, nonatomic) NSMutableArray *delegatesArray;
@property (strong, nonatomic) NSMutableArray *pendingMessageArray;
@property (strong, nonatomic) NSMutableArray *incomingMessageArray;
@property (strong, nonatomic) NSMutableDictionary *waitingResponseDictionary;
@property (strong, nonatomic) NSTimer *saveNewMessageTimer;
@property (strong, nonatomic) __block NSTimer *backgroundSequenceTimer;
@property (nonatomic) NSInteger checkPendingBackgroundTaskRetryAttempt;
@property (nonatomic) BOOL isEnterBackgroundSequenceActive;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation TAPChatManager

#pragma mark - Lifecycle
+ (TAPConnectionManager *)sharedManager {
    static TAPConnectionManager *sharedManager = nil;
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
        _delegatesArray = [[NSMutableArray alloc] init];
        _pendingMessageArray = [[NSMutableArray alloc] init];
        _incomingMessageArray = [[NSMutableArray alloc] init];
        _waitingResponseDictionary = [[NSMutableDictionary alloc] init];
        _messageDraftDictionary = [[NSMutableDictionary alloc] init];
        _activeUser = [TAPDataManager getActiveUser];
        _checkPendingBackgroundTaskRetryAttempt = 0;
        _isEnterBackgroundSequenceActive = NO;
        
        [TAPConnectionManager sharedManager].delegate = self;
    }
    
    return self;
}

- (void)dealloc {
    //Remove Connection Manager delegate
    [TAPConnectionManager sharedManager].delegate = nil;
}

#pragma mark - Delegate
#pragma mark TAPConnectionManager
- (void)connectionManagerDidReceiveNewEmit:(NSString *)eventName parameter:(NSDictionary *)dataDictionary {
    if ([eventName isEqualToString:kTAPEventOpenRoom]) {
        
    }
    else if ([eventName isEqualToString:kTAPEventCloseRoom]) {
        
    }
    else if ([eventName isEqualToString:kTAPEventNewMessage]) {
        [self receiveMessageFromSocketWithEvent:eventName dataDictionary:dataDictionary];
    }
    else if ([eventName isEqualToString:kTAPEventUpdateMessage]) {
        [self receiveMessageFromSocketWithEvent:eventName dataDictionary:dataDictionary];
    }
    else if ([eventName isEqualToString:kTAPEventDeleteMessage]) {
        [self receiveMessageFromSocketWithEvent:eventName dataDictionary:dataDictionary];
    }
    else if ([eventName isEqualToString:kTAPEventOpenMessage]) {
        
    }
    else if ([eventName isEqualToString:kTAPEventStartTyping]) {
        
    }
    else if ([eventName isEqualToString:kTAPEventStopTyping]) {
        
    }
    else if ([eventName isEqualToString:kTAPEventAuthentication]) {
        
    }
    else if ([eventName isEqualToString:kTAPEventUserOnline]) {
        [self receiveOnlineStatusFromSocketWithDataDictionary:dataDictionary];
    }
    else if ([eventName isEqualToString:kTAPEventUserOffline]) {
        [self receiveOfflineStatusFromSocketWithDataDictionary:dataDictionary];
    }
    else if ([eventName isEqualToString:kTAPEventUserUpdated]) {
        [self receiveContactUpdatedFromSocketWithDataDictionary:dataDictionary];
    }
}

- (void)connectionManagerDidConnected {
    //Send pending queue array
    [self checkAndSendPendingMessage];
}

#pragma mark - Custom Method
- (void)connect {
    [[TAPConnectionManager sharedManager] connect];
}

- (void)disconnect {
    [[TAPConnectionManager sharedManager] disconnect];
}

- (void)openRoom:(TAPRoomModel *)room {
    _activeRoom = room;
}

- (void)closeActiveRoom {
    _activeRoom = nil;
}

- (void)startTyping {
    if(self.isTyping) {
        return;
    }
    
    _isTyping = YES;
    
    NSString *roomID = [TAPUtil nullToEmptyString:self.activeRoom.roomID];
    NSString *userID = [TAPUtil nullToEmptyString:self.activeUser.userID];
    
//    NSDictionary *parameterDictionary = @{@"roomID" : roomID,
//                                          @"userID" : userID,
//                                          @"type" : [NSString stringWithFormat:@"%li", (long)ChatTypingTypeOn]};
//
//    NSArray *parameterArray = @[parameterDictionary];
//    [[SocketManager sharedManager] emit:kAppSocketSendTyping args:parameterArray];
}

- (void)stopTyping {
    if(!self.isTyping) {
        return;
    }
    
    _isTyping = NO;
    
    NSString *roomID = [TAPUtil nullToEmptyString:self.activeRoom.roomID];
    NSString *userID = [TAPUtil nullToEmptyString:self.activeUser.userID];
    
//    NSDictionary *parameterDictionary = @{@"roomID" : roomID,
//                                          @"userID" : userID,
//                                          @"type" : [NSString stringWithFormat:@"%li", (long)ChatTypingTypeOff]};
//
//    NSArray *parameterArray = @[parameterDictionary];
//    [[SocketManager sharedManager] emit:kAppSocketSendTyping args:parameterArray];
}

- (void)sendMessage:(TAPMessageModel *)message {
//    Check if socket is connected
//    ConnectionManagerStatusTypeDisconnected = 0
//    ConnectionManagerStatusTypeConnecting = 1
//    ConnectionManagerStatusTypeConnected = 2
    
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(chatManagerDidSendNewMessage:)]) {
            [delegate chatManagerDidSendNewMessage:[message copyMessageModel]];
        }
    }
    
    [self runSendMessageSequenceWithMessage:message];
}

- (void)runSendMessageSequenceWithMessage:(TAPMessageModel *)message {
    TAPConnectionManagerStatusType statusType = [[TAPConnectionManager sharedManager] getSocketConnectionStatus];
    if (statusType != TAPConnectionManagerStatusTypeConnected) {
        //When socket is not connected
        [self.pendingMessageArray addObject:message];
        return;
    }
    else {
        //When socket is connected
        
        //Add message to waiting response array
        [self.waitingResponseDictionary setObject:message forKey:message.localID];
        
        //Encrypt message
        TAPMessageModel *encryptedMessage = [TAPEncryptorManager encryptMessage:message];
        
        NSMutableDictionary *parametersDictionary = [NSMutableDictionary dictionary];
        parametersDictionary = [[encryptedMessage toDictionary] mutableCopy];
        
        [[TAPConnectionManager sharedManager] sendEmit:kTAPEventNewMessage parameters:parametersDictionary];
    }
}

- (void)sendTextMessage:(NSString *)textMessage {
    //Divide message if length more than character limit
    NSInteger characterLimit = kCharacterLimit;
    
    if ([textMessage length] > characterLimit) {
        NSInteger messageLength = [textMessage length];
        
        for (NSInteger startIndex = 0; startIndex < messageLength; startIndex += characterLimit) {
            //Copy current message model
            NSInteger substringLength = messageLength - startIndex;
            if (substringLength > characterLimit) {
                substringLength = characterLimit;
            }
            
            NSString *substringMessage = [textMessage substringWithRange:NSMakeRange(startIndex, substringLength)];
            TAPMessageModel *message = [TAPMessageModel createMessageWithUser:[TAPChatManager sharedManager].activeUser room:[TAPChatManager sharedManager].activeRoom body:substringMessage type:TAPChatMessageTypeText];
            
            [self sendMessage:message];
        }
    }
    else {
        TAPMessageModel *message = [TAPMessageModel createMessageWithUser:[TAPChatManager sharedManager].activeUser room:[TAPChatManager sharedManager].activeRoom body:textMessage type:TAPChatMessageTypeText];
        
        [self sendMessage:message];
    }
}

- (void)setActiveUser:(TAPUserModel *)activeUser {
    _activeUser = activeUser;
    
    //Update data in preference (for TAPDataManager)
    NSDictionary *userDictionary = [activeUser toDictionary];
    [[NSUserDefaults standardUserDefaults] setSecureObject:userDictionary forKey:TAP_PREFS_ACTIVE_USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addDelegate:(id)delegate {
    if ([self.delegatesArray containsObject:delegate]) {
        return;
    }
    
    NSLog(@"[WARNING] ChatManager - Do not forget to remove the delegate object, since an object can't weak retained in an array, also please remove this delegate before dealloc or the delegate will always retained");
    
    [self.delegatesArray addObject:delegate];
}

- (void)removeDelegate:(id)delegate {
    [self.delegatesArray removeObject:delegate];
}

- (void)checkAndSendPendingMessage {
    if ([self.pendingMessageArray count] == 0) {
        return;
    }
    
    TAPMessageModel *messageToBeSend = [self.pendingMessageArray objectAtIndex:0];
    [self runSendMessageSequenceWithMessage:messageToBeSend];
    [self.pendingMessageArray removeObjectAtIndex:0];
    
    [self performSelector:@selector(checkAndSendPendingMessage) withObject:nil afterDelay:0.05f];
}

- (void)updateSendingMessageToFailed {
    [TAPDataManager updateMessageToFailedWhenClosedInDatabase];
}

- (void)checkPendingBackgroundTask {
    BOOL isPendingMessageExist = NO;
    BOOL isFileUploadProgressExist = NO;
    
    if ([self.pendingMessageArray count] > 0) {
        //Pending message exist
        isPendingMessageExist = YES;
    }
    
    //RN To Do - Check file upload progress
    
    
    if ((isPendingMessageExist || isFileUploadProgressExist || [[TAPMessageStatusManager sharedManager] hasPendingProcess]) && self.checkPendingBackgroundTaskRetryAttempt < kMaximumRetryAttempt) {
        _checkPendingBackgroundTaskRetryAttempt++;
    }
    else {
        [self saveIncomingMessageAndDisconnect];
        
        //Stop timer save new message
        [self stopTimerSaveNewMessage];

        //Stop timer update read and delivered message status
        [[TAPMessageStatusManager sharedManager] stopTimerUpdateStatus];

        [TapTalk sharedInstance].instanceState = TapTalkInstanceStateInactive;
        
        //End background task
        [self removeAllBackgroundSequenceTaskWithApplication:[UIApplication sharedApplication]];
    }
}

- (void)runEnterBackgroundSequenceWithApplication:(UIApplication *)application {
    _checkPendingBackgroundTaskRetryAttempt = 0;
    [self saveAllUnsentMessageInMainThread];
    
    _backgroundTask = [application beginBackgroundTaskWithName:@"backgroundSequence" expirationHandler:^{
        [self removeAllBackgroundSequenceTaskWithApplication:application];
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Do the work associated with the task, preferably in chunks.
        if (self.isEnterBackgroundSequenceActive == NO) {
            self.isEnterBackgroundSequenceActive = YES;
            [self checkPendingBackgroundTask];
            
            self->_backgroundSequenceTimer = [NSTimer scheduledTimerWithTimeInterval:kDelayTime
                                                          target:self
                                                        selector:@selector(checkPendingBackgroundTask)
                                                        userInfo:nil
                                                         repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.backgroundSequenceTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        }
    });
}

- (void)removeAllBackgroundSequenceTaskWithApplication:(UIApplication *)application {
    [[TAPNotificationManager sharedManager] updateApplicationBadgeCount];
    _isEnterBackgroundSequenceActive = NO;
    [self.backgroundSequenceTimer invalidate];
    _backgroundSequenceTimer = nil;
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
}

- (void)receiveMessageFromSocketWithEvent:(NSString *)eventName dataDictionary:(NSDictionary *)dataDictionary {
    TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:dataDictionary error:nil];
    
    message.isSending = NO; //DV TEMP - Temporary set isSending to NO waiting for server
    
    //Decrypt message
    TAPMessageModel *decryptedMessage = [TAPEncryptorManager decryptMessage:message];
    
#ifdef DEBUG
    NSLog(@"Receive Message: %@", decryptedMessage.body);
#endif
    
    if ([eventName isEqualToString:kTAPEventNewMessage]) {
        //Remove message from waiting response dictionary
        if ([self.waitingResponseDictionary count] != 0) {
            [self.waitingResponseDictionary removeObjectForKey:decryptedMessage.localID];
        }
        
        NSString *senderUserID = decryptedMessage.user.userID;
        senderUserID = [TAPUtil nullToEmptyString:senderUserID];
        
        NSString *currentUserID = [TAPDataManager getActiveUser].userID;
        currentUserID = [TAPUtil nullToEmptyString:currentUserID];
        
        //Check if message is send by other user, update delivery status
        if (![senderUserID isEqualToString:currentUserID]) {
            //Call API send delivery status to server (Update delivery status)
            [self processMessageAsDelivered:decryptedMessage];
        }
    }
    
    //Add new message to incoming array
    [self.incomingMessageArray addObject:decryptedMessage];
    
    //Check is in foreground or not
    if ([TapTalk sharedInstance].instanceState == TapTalkInstanceStateActive) {
        //In foreground state or in background sequence mode
        if ([decryptedMessage.room.roomID isEqualToString:self.activeRoom.roomID]) {
            //Message from current active room
            for (id delegate in self.delegatesArray) {
                if ([eventName isEqualToString:kTAPEventNewMessage]) {
                    if ([delegate respondsToSelector:@selector(chatManagerDidReceiveNewMessageInActiveRoom:)]) {
                        [delegate chatManagerDidReceiveNewMessageInActiveRoom:[decryptedMessage copyMessageModel]];
                    }
                }
                else if ([eventName isEqualToString:kTAPEventUpdateMessage]) {
                    if ([delegate respondsToSelector:@selector(chatManagerDidReceiveUpdateMessageInActiveRoom:)]) {
                        [delegate chatManagerDidReceiveUpdateMessageInActiveRoom:[decryptedMessage copyMessageModel]];
                    }
                }
                else if ([eventName isEqualToString:kTAPEventDeleteMessage]) {
                    if ([delegate respondsToSelector:@selector(chatManagerDidReceiveDeleteMessageInActiveRoom:)]) {
                        [delegate chatManagerDidReceiveDeleteMessageInActiveRoom:[decryptedMessage copyMessageModel]];
                    }
                }
            }
        }
        else {
            //Message not from current active room
            for (id delegate in self.delegatesArray) {
                if ([eventName isEqualToString:kTAPEventNewMessage]) {
                    if ([delegate respondsToSelector:@selector(chatManagerDidReceiveNewMessageOnOtherRoom:)]) {
                        [delegate chatManagerDidReceiveNewMessageOnOtherRoom:[decryptedMessage copyMessageModel]];
                    }
                }
                else if ([eventName isEqualToString:kTAPEventUpdateMessage]) {
                    if ([delegate respondsToSelector:@selector(chatManagerDidReceiveUpdateMessageOnOtherRoom:)]) {
                        [delegate chatManagerDidReceiveUpdateMessageOnOtherRoom:[decryptedMessage copyMessageModel]];
                    }
                }
                else if ([eventName isEqualToString:kTAPEventDeleteMessage]) {
                    if ([delegate respondsToSelector:@selector(chatManagerDidReceiveDeleteMessageOnOtherRoom:)]) {
                        [delegate chatManagerDidReceiveDeleteMessageOnOtherRoom:[decryptedMessage copyMessageModel]];
                    }
                }
            }
        }
    }
    else {
        //In background state
        //DV Temp
        //TODO Notification Manager Handle New Message
    }
}

- (void)receiveContactUpdatedFromSocketWithDataDictionary:(NSDictionary *)dataDictionary {
    TAPUserModel *user = [[TAPUserModel alloc] initWithDictionary:dataDictionary error:nil];
    [[TAPContactCacheManager sharedManager] shouldUpdateUserWithData:user];
}

- (void)receiveOnlineStatusFromSocketWithDataDictionary:(NSDictionary *)dataDictionary {
//    for (id delegate in self.delegatesArray) {
//        if ([delegate respondsToSelector:@selector(chatManagerDidReceiveOnlineStatus:)]) {
//            [delegate chatManagerDidReceiveOnlineStatus:[decryptedMessage copyMessageModel]];
//        }
//    }
}
- (void)receiveOfflineStatusFromSocketWithDataDictionary:(NSDictionary *)dataDictionary {
//    for (id delegate in self.delegatesArray) {
//        if ([delegate respondsToSelector:@selector(chatManagerDidReceiveOfflineStatus:)]) {
//            [delegate chatManagerDidReceiveOfflineStatus:[decryptedMessage copyMessageModel]];
//        }
//    }
}

- (void)triggerSaveNewMessage {
    //Check timer is already running or not
    if ([self.saveNewMessageTimer isValid]) {
        return;
    }

    CGFloat timerInterval = 1.0f;
    _saveNewMessageTimer = [NSTimer timerWithTimeInterval:timerInterval
                                                   target:self
                                                 selector:@selector(saveNewMessageToDatabase)
                                                 userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.saveNewMessageTimer forMode:NSRunLoopCommonModes];
//    [[NSRunLoop mainRunLoop] addTimer:repeatingTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopTimerSaveNewMessage {
    [self.saveNewMessageTimer invalidate];
    _saveNewMessageTimer = nil;
}

- (void)saveNewMessageToDatabase {
    if ([self.incomingMessageArray count] != 0) {
        //Insert to database
        [TAPDataManager updateOrInsertDatabaseMessageWithData:self.incomingMessageArray tableName:@"TAPMessageRealmModel" success:^{
            //Clear incoming message array
            [self.incomingMessageArray removeAllObjects];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)saveAllUnsentMessage {
    NSMutableArray *groupedMessageArray = [NSMutableArray array];
    
    //Save new messages to database
    if ([self.incomingMessageArray count] != 0) {
        [groupedMessageArray addObjectsFromArray:self.incomingMessageArray];
    }
    
    //Save pending messages to database
    if ([self.pendingMessageArray count] != 0) {
        [groupedMessageArray addObjectsFromArray:self.pendingMessageArray];
    }
    
    //Save waitingResponse messages to database
    NSArray *waitingResponseArray = [NSArray array];
    waitingResponseArray = [self.waitingResponseDictionary allValues];
    if ([waitingResponseArray count] != 0) {
        [groupedMessageArray addObjectsFromArray:waitingResponseArray];
    }
    
    if ([groupedMessageArray count] != 0) {
        [TAPDataManager updateOrInsertDatabaseMessageWithData:groupedMessageArray tableName:@"TAPMessageRealmModel" success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
    
    //Clear array incoming and waiting response dictionary
    [self.incomingMessageArray removeAllObjects];
    [self.waitingResponseDictionary removeAllObjects];
}

- (void)saveAllUnsentMessageInMainThread {
    NSMutableArray *groupedMessageArray = [NSMutableArray array];
    
    //Save new messages to database
    if ([self.incomingMessageArray count] != 0) {
        [groupedMessageArray addObjectsFromArray:self.incomingMessageArray];
    }
    
    //Save pending messages to database
    if ([self.pendingMessageArray count] != 0) {
        [groupedMessageArray addObjectsFromArray:self.pendingMessageArray];
    }
    
    //Save waitingResponse messages to database
    NSArray *waitingResponseArray = [NSArray array];
    waitingResponseArray = [self.waitingResponseDictionary allValues];
    if ([waitingResponseArray count] != 0) {
        [groupedMessageArray addObjectsFromArray:waitingResponseArray];
    }
    
    if ([groupedMessageArray count] != 0) {
        [TAPDataManager updateOrInsertDatabaseMessageInMainThreadWithData:groupedMessageArray tableName:@"TAPMessageRealmModel" success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
    
    //Clear array incoming and waiting response dictionary
    [self.incomingMessageArray removeAllObjects];
    [self.waitingResponseDictionary removeAllObjects];
}

- (void)saveIncomingMessageAndDisconnect {
    //Save new messages to database
    if ([self.incomingMessageArray count] != 0) {
        [TAPDataManager updateOrInsertDatabaseMessageInMainThreadWithData:self.incomingMessageArray tableName:@"TAPMessageRealmModel" success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
    
    [self disconnect];
}

- (void)saveUnsentMessageAndDisconnect {
    //Save all messages array to database
    [self saveAllUnsentMessage];
    [self disconnect];
}

- (void)saveMessageToDraftWithMessage:(NSString *)message roomID:(NSString *)roomID {
    roomID = [TAPUtil nullToEmptyString:roomID];
    
    if ([message isEqualToString:@""] || message.length == 0) {
        [[TAPChatManager sharedManager].messageDraftDictionary removeObjectForKey:roomID];
    }
    else {
        [[TAPChatManager sharedManager].messageDraftDictionary setObject:message forKey:roomID];
    }
}

- (NSString *)getMessageFromDraftWithRoomID:(NSString *)roomID {
    roomID = [TAPUtil nullToEmptyString:roomID];
    NSString *draftMessage = [[TAPChatManager sharedManager].messageDraftDictionary objectForKey:roomID];
    draftMessage = [TAPUtil nullToEmptyString:draftMessage];
    
    return draftMessage;
}

- (void)processMessageAsDelivered:(TAPMessageModel *)message {
    BOOL isDelivered = message.isDelivered;
    if (!isDelivered) {
        //Send delivered status to server
        [[TAPMessageStatusManager sharedManager] markMessageAsDeliveredWithMessage:message];
    }
}

- (void)decreaseUnreadMessageForRoomID:(NSString *)roomID {
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(chatManagerShouldDecreaseUnreadBubbleForRoomID:)]) {
            [delegate chatManagerShouldDecreaseUnreadBubbleForRoomID:roomID];
        }
    }
}

@end
