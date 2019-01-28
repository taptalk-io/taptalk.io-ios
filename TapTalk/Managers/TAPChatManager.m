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

- (void)sendMessage:(TAPMessageModel *)message notifyDelegate:(BOOL)notifyDelegate;
- (void)checkAndSendPendingMessage;
- (void)checkPendingBackgroundTask;
- (void)receiveMessageFromSocketWithEvent:(NSString *)eventName dataDictionary:(NSDictionary *)dataDictionary;
- (void)receiveOnlineStatusFromSocketWithDataDictionary:(NSDictionary *)dataDictionary;
- (void)receiveOfflineStatusFromSocketWithDataDictionary:(NSDictionary *)dataDictionary;
- (void)receiveContactUpdatedFromSocketWithDataDictionary:(NSDictionary *)dataDictionary;
- (void)receiveStartTypingFromSocketWithDataDictionary:(NSDictionary *)dataDictionary;
- (void)receiveStopTypingFromSocketWithDataDictionary:(NSDictionary *)dataDictionary;
- (void)stopTimerSaveNewMessage;
- (void)runSendMessageSequenceWithMessage:(TAPMessageModel *)message;
- (void)processMessageAsDelivered:(TAPMessageModel *)message;
- (void)setIsWaitingTypingNo;

@property (strong, nonatomic) NSMutableArray *delegatesArray;
@property (strong, nonatomic) NSMutableArray *pendingMessageArray;
@property (strong, nonatomic) NSMutableArray *incomingMessageArray;
@property (strong, nonatomic) NSMutableDictionary *waitingResponseDictionary;
@property (strong, nonatomic) NSMutableDictionary *waitingUploadDictionary;
@property (strong, nonatomic) NSMutableDictionary *typingDictionary;
@property (strong, nonatomic) NSTimer *saveNewMessageTimer;
@property (strong, nonatomic) __block NSTimer *backgroundSequenceTimer;
@property (nonatomic) NSInteger checkPendingBackgroundTaskRetryAttempt;
@property (nonatomic) BOOL isEnterBackgroundSequenceActive;
@property (nonatomic) BOOL isShouldRefreshOnlineStatus;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) BOOL isWaitingSendTyping;

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
        _waitingUploadDictionary = [[NSMutableDictionary alloc] init];
        _messageDraftDictionary = [[NSMutableDictionary alloc] init];
        _quotedMessageDictionary = [[NSMutableDictionary alloc] init];
        _userInfoDictionary = [[NSMutableDictionary alloc] init];
        _activeUser = [TAPDataManager getActiveUser];
        _checkPendingBackgroundTaskRetryAttempt = 0;
        _isEnterBackgroundSequenceActive = NO;
        _isShouldRefreshOnlineStatus = YES;
        _typingDictionary = [[NSMutableDictionary alloc] init];
        [[TAPConnectionManager sharedManager] addDelegate:self];
    }
    
    return self;
}

- (void)dealloc {
    //Remove Connection Manager delegate
    [[TAPConnectionManager sharedManager] removeDelegate:self];
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
        [self receiveStartTypingFromSocketWithDataDictionary:dataDictionary];
    }
    else if ([eventName isEqualToString:kTAPEventStopTyping]) {
        [self receiveStopTypingFromSocketWithDataDictionary:dataDictionary];
    }
    else if ([eventName isEqualToString:kTAPEventAuthentication]) {
        
    }
    else if ([eventName isEqualToString:kTAPEventUserOnline]) {
        [self receiveOnlineStatusFromSocketWithDataDictionary:dataDictionary];
    }
    else if ([eventName isEqualToString:kTAPEventUserUpdated]) {
        [self receiveContactUpdatedFromSocketWithDataDictionary:dataDictionary];
    }
}

- (void)connectionManagerDidConnected {
    //Send pending queue array
    [self checkAndSendPendingMessage];
}

- (void)connectionManagerDidReceiveError:(NSError *)error {
    _isTyping = NO;
    _isWaitingSendTyping = NO;
    _isShouldRefreshOnlineStatus = YES;
    _typingDictionary = [NSMutableDictionary dictionary];
}

- (void)connectionManagerDidDisconnectedWithCode:(NSInteger)code reason:(NSString *)reason cleanClose:(BOOL)clean {
    _isTyping = NO;
    _isWaitingSendTyping = NO;
    _isShouldRefreshOnlineStatus = YES;
    _typingDictionary = [NSMutableDictionary dictionary];
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
    
    if (!self.isWaitingSendTyping) {
        _isTyping = NO;
    }
    
    if (self.isTyping || self.isWaitingSendTyping) {
        return;
    }
    
    _isTyping = YES;
    
    NSString *roomID = [TAPUtil nullToEmptyString:self.activeRoom.roomID];
    NSDictionary *parameterDictionary = @{@"roomID" : roomID};
    [[TAPConnectionManager sharedManager] sendEmit:kTAPEventStartTyping parameters:parameterDictionary];
    _isWaitingSendTyping = YES;
    [self performSelector:@selector(setIsWaitingTypingNo) withObject:nil afterDelay:10.0f];
}

- (void)stopTyping {
    if(!self.isTyping) {
        return;
    }
    
    _isTyping = NO;
    _isWaitingSendTyping = NO;
    
    NSString *roomID = [TAPUtil nullToEmptyString:self.activeRoom.roomID];
    NSDictionary *parameterDictionary = @{@"roomID" : roomID};
    [[TAPConnectionManager sharedManager] sendEmit:kTAPEventStopTyping parameters:parameterDictionary];
}

- (void)sendMessage:(TAPMessageModel *)message notifyDelegate:(BOOL)notifyDelegate {
//    Check if socket is connected
//    ConnectionManagerStatusTypeDisconnected = 0
//    ConnectionManagerStatusTypeConnecting = 1
//    ConnectionManagerStatusTypeConnected = 2
    
    if (notifyDelegate) {
        [self notifySendMessageToDelegate:message];
    }
    
    [self runSendMessageSequenceWithMessage:message];
}

- (void)notifySendMessageToDelegate:(TAPMessageModel *)message {
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(chatManagerDidSendNewMessage:)]) {
            [delegate chatManagerDidSendNewMessage:[message copyMessageModel]];
        }
    }
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
        
//        //Encrypt message
//        message.body = [TAPEncryptorManager encryptString:message.body key:message.localID];
//        message.quote.content = [TAPEncryptorManager encryptString:message.quote.content key:message.localID];
//
//        NSMutableDictionary *parametersDictionary = [NSMutableDictionary dictionary];
//        parametersDictionary = [[message toDictionary] mutableCopy];
//
//        NSDictionary *dataDictionary = [parametersDictionary objectForKey:@"data"];
//        NSString *dataJSONString = [TAPUtil jsonStringFromObject:dataDictionary];
//        NSString *encryptedDataJSONString = [TAPEncryptorManager encryptString:dataJSONString key:message.localID];
        
//        [parametersDictionary setObject:encryptedDataJSONString forKey:@"data"];
        
        NSDictionary *encryptedParametersDictionary = [TAPEncryptorManager encryptToDictionaryFromMessageModel:message];
        
        [[TAPConnectionManager sharedManager] sendEmit:kTAPEventNewMessage parameters:encryptedParametersDictionary];
    }
}

- (void)sendFileMessage:(TAPMessageModel *)message {
    [self sendMessage:message notifyDelegate:NO];
}

- (void)sendTextMessage:(NSString *)textMessage {
    [[TAPChatManager sharedManager] sendTextMessage:textMessage room:[TAPChatManager sharedManager].activeRoom];
}

- (void)sendTextMessage:(NSString *)textMessage room:(TAPRoomModel *)room {
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
            TAPMessageModel *message = [TAPMessageModel createMessageWithUser:[TAPChatManager sharedManager].activeUser room:room body:substringMessage type:TAPChatMessageTypeText];
            
            //Check if quote message available
            id quotedMessageObject = [[TAPChatManager sharedManager].quotedMessageDictionary objectForKey:room.roomID];
            if (quotedMessageObject != nil) {
                if ([quotedMessageObject isKindOfClass:[TAPMessageModel class]]) {
                    //if message quoted from message model then should construct quote and reply to model
                    TAPMessageModel *quotedMessage = (TAPMessageModel *)quotedMessageObject;
                    
                    TAPQuoteModel *quote = [TAPQuoteModel new];
                    quote.title = quotedMessage.user.fullname;
                    quote.content = quotedMessage.body;
                    message.quote = [quote copy];
                    
                    TAPReplyToModel *replyTo = [TAPReplyToModel new];
                    replyTo.messageID = quotedMessage.messageID;
                    replyTo.localID = quotedMessage.localID;
                    replyTo.messageType = quotedMessage.type;
                    message.replyTo = [replyTo copy];
                }
                else if ([quotedMessageObject isKindOfClass:[TAPQuoteModel class]]) {
                     //if message quoted from quote model then should just construct quote model
                    TAPQuoteModel *quotedMessage = (TAPQuoteModel *)quotedMessageObject;
                    message.quote = [quotedMessage copy];
                }
            }
            
            //check if userInfo is available, if available add to data in message model
            //userInfo custom user information from client, used for custom quote click action
            id userInfo = [[TAPChatManager sharedManager].userInfoDictionary objectForKey:room.roomID];
            if (userInfo != nil) {
                message.data = userInfo;
            }
            
            [self sendMessage:message notifyDelegate:YES];
            
            [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:room.roomID];
        }
    }
    else {
        TAPMessageModel *message = [TAPMessageModel createMessageWithUser:[TAPChatManager sharedManager].activeUser room:room body:textMessage type:TAPChatMessageTypeText];
        
        //Check if quote message available
        id quotedMessageObject = [self.quotedMessageDictionary objectForKey:room.roomID];
        if (quotedMessageObject != nil) {
            if ([quotedMessageObject isKindOfClass:[TAPMessageModel class]]) {
                //if message quoted from message model then should construct quote and reply to model
                TAPMessageModel *quotedMessage = (TAPMessageModel *)quotedMessageObject;
                
                TAPQuoteModel *quote = [TAPQuoteModel new];
                quote.title = quotedMessage.user.fullname;
                quote.content = quotedMessage.body;
                message.quote = quote;
                
                TAPReplyToModel *replyTo = [TAPReplyToModel new];
                replyTo.messageID = quotedMessage.messageID;
                replyTo.localID = quotedMessage.localID;
                replyTo.messageType = quotedMessage.type;
                message.replyTo = replyTo;
            }
            else if ([quotedMessageObject isKindOfClass:[TAPQuoteModel class]]) {
                //if message quoted from quote model then should just construct quote model
                TAPQuoteModel *quotedMessage = (TAPQuoteModel *)quotedMessageObject;
                message.quote = quotedMessage;
            }
        }
        
        //check if userInfo is available, if available add to data in message model
        //userInfo custom user information from client, used for custom quote click action
        id userInfo = [[TAPChatManager sharedManager].userInfoDictionary objectForKey:room.roomID];
        if (userInfo != nil) {
            message.data = userInfo;
        }
        
        [self sendMessage:message notifyDelegate:YES];
        
        [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:room.roomID];
    }
}

- (void)sendImageMessage:(UIImage *)image caption:(NSString *)caption {

    caption = [TAPUtil nullToEmptyString:caption];
    
    NSString *messageBodyCaption = [NSString string];
    //Check contain caption or not
    if ([caption isEqualToString:@""]) {
        messageBodyCaption = NSLocalizedString(@"🖼 Photo", @"");
    }
    else {
        messageBodyCaption = [NSString stringWithFormat:@"🖼 %@", caption];
    }
    
    TAPMessageModel *message = [TAPMessageModel createMessageWithUser:[TAPChatManager sharedManager].activeUser room:[TAPChatManager sharedManager].activeRoom body:messageBodyCaption type:TAPChatMessageTypeImage];
    
    NSMutableDictionary *dataDictionary = message.data;
    if (dataDictionary == nil) {
        dataDictionary = [[NSMutableDictionary alloc] init];
    }
#ifdef DEBUG
    NSLog(@"IMAGE BEFORE CACHE SIZE HEIGHT: %f, WIDTH: %f", image.size.height, image.size.width);
#endif
    
    NSNumber *imageHeight = [NSNumber numberWithFloat:image.size.height];
    NSNumber *imageWidth = [NSNumber numberWithFloat:image.size.width];
    
//    [dataDictionary setObject:image forKey:@"dummyImage"];
    [dataDictionary setObject:imageHeight forKey:@"height"];
    [dataDictionary setObject:imageWidth forKey:@"width"];
    [dataDictionary setObject:caption forKey:@"caption"];
    message.data = [dataDictionary copy];
    
    //Save image to cache with localID key
    [TAPImageView saveImageToCache:image withKey:message.localID];
    
    //Add message to waiting upload file dictionary in ChatManager to prepare save to database
    [[TAPChatManager sharedManager] addToWaitingUploadFileMessage:message];
    
    [[TAPFileUploadManager sharedManager] sendFileWithData:message];
    [[TAPChatManager sharedManager] notifySendMessageToDelegate:message];
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
    
    //Decrypt message
    TAPMessageModel *decryptedMessage = [TAPEncryptorManager decryptToMessageModelFromDictionary:dataDictionary];
    
    //Add User to Contact Manager
    [[TAPContactManager sharedManager] addContactWithUserModel:decryptedMessage.user saveToDatabase:NO];
    
    decryptedMessage.isSending = NO; //DV TEMP - Temporary set isSending to NO waiting for server
    
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
    _isShouldRefreshOnlineStatus = NO;
    TAPOnlineStatusModel *onlineStatus = [[TAPOnlineStatusModel alloc] initWithDictionary:dataDictionary error:nil];

    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(chatManagerDidReceiveOnlineStatus:)]) {
            [delegate chatManagerDidReceiveOnlineStatus:onlineStatus];
        }
    }
}

- (void)receiveStartTypingFromSocketWithDataDictionary:(NSDictionary *)dataDictionary {
    
    TAPTypingModel *typing = [[TAPTypingModel alloc] initWithDictionary:dataDictionary error:nil];
    [self.typingDictionary setObject:typing forKey:typing.roomID];
    
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(chatManagerDidReceiveStartTyping:)]) {
            [delegate chatManagerDidReceiveStartTyping:typing];
        }
    }
}

- (void)receiveStopTypingFromSocketWithDataDictionary:(NSDictionary *)dataDictionary {
    TAPTypingModel *typing = [[TAPTypingModel alloc] initWithDictionary:dataDictionary error:nil];
    [self.typingDictionary removeObjectForKey:typing.roomID];
    
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(chatManagerDidReceiveStopTyping:)]) {
            [delegate chatManagerDidReceiveStopTyping:typing];
        }
    }
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
        [TAPDataManager updateOrInsertDatabaseMessageWithData:self.incomingMessageArray success:^{
            //Clear incoming message array
            [self.incomingMessageArray removeAllObjects];

            [[TAPMessageStatusManager sharedManager] triggerUpdateMessageStatus];
        } failure:^(NSError *error) {

        }];
    }
    else {
        //Call to check if there are read message when there are no new incoming message
        [[TAPMessageStatusManager sharedManager] triggerUpdateMessageStatus];
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
    
    //Save waiting upload file messages to database
    NSArray *waitingUploadArray = [NSArray array];
    waitingUploadArray = [self.waitingUploadDictionary allValues];
    if ([waitingUploadArray count] != 0) {
        [groupedMessageArray addObjectsFromArray:waitingUploadArray];
    }
    
    if ([groupedMessageArray count] != 0) {
        [TAPDataManager updateOrInsertDatabaseMessageWithData:groupedMessageArray success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
    
    //Clear array incoming and waiting response dictionary
    [self.incomingMessageArray removeAllObjects];
    [self.waitingResponseDictionary removeAllObjects];
    [self.waitingUploadDictionary removeAllObjects];
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
    
    //Save waiting response messages to database
    NSArray *waitingResponseArray = [NSArray array];
    waitingResponseArray = [self.waitingResponseDictionary allValues];
    if ([waitingResponseArray count] != 0) {
        [groupedMessageArray addObjectsFromArray:waitingResponseArray];
    }
    
    //Save waiting upload file messages to database
    NSArray *waitingUploadArray = [NSArray array];
    waitingUploadArray = [self.waitingUploadDictionary allValues];
    if ([waitingUploadArray count] != 0) {
        [groupedMessageArray addObjectsFromArray:waitingUploadArray];
    }
    
    if ([groupedMessageArray count] != 0) {
        [TAPDataManager updateOrInsertDatabaseMessageInMainThreadWithData:groupedMessageArray success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
    
    //Clear array incoming and waiting response dictionary
    [self.incomingMessageArray removeAllObjects];
    [self.waitingResponseDictionary removeAllObjects];
    [self.waitingUploadDictionary removeAllObjects];
}

- (void)saveIncomingMessageAndDisconnect {
    //Save new messages to database
    if ([self.incomingMessageArray count] != 0) {
        [TAPDataManager updateOrInsertDatabaseMessageInMainThreadWithData:self.incomingMessageArray success:^{
            
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

- (void)saveToQuotedMessage:(id)quotedMessageObject userInfo:(NSDictionary *)userInfo roomID:(NSString *)roomID { //Object could be TAPMessageModel or TAPQuoteModel
    if(quotedMessageObject != nil) {
        [[TAPChatManager sharedManager].quotedMessageDictionary setObject:quotedMessageObject forKey:roomID];
    }
    
    if(userInfo != nil) {
        [[TAPChatManager sharedManager].userInfoDictionary setObject:userInfo forKey:roomID];
    }
}

- (id)getQuotedMessageObjectWithRoomID:(NSString *)roomID { //Object could be TAPMessageModel or TAPQuoteModel
     roomID = [TAPUtil nullToEmptyString:roomID];
    id object =  [[TAPChatManager sharedManager].quotedMessageDictionary objectForKey:roomID];
    return object;
}

- (void)removeQuotedMessageObjectWithRoomID:(NSString *)roomID {
    roomID = [TAPUtil nullToEmptyString:roomID];
    [[TAPChatManager sharedManager].quotedMessageDictionary removeObjectForKey:roomID];
    [[TAPChatManager sharedManager].userInfoDictionary removeObjectForKey:roomID];
}

- (void)processMessageAsDelivered:(TAPMessageModel *)message {
    BOOL isDelivered = message.isDelivered;
    if (!isDelivered) {
        //Send delivered status to server
        [[TAPMessageStatusManager sharedManager] markMessageAsDeliveredWithMessage:message];
    }
}

- (BOOL)checkIsTypingWithRoomID:(NSString *)roomID {
    if([self.typingDictionary objectForKey:roomID] != nil) {
        return YES;
    }
    return NO;
}

- (void)setIsWaitingTypingNo {
    _isWaitingSendTyping = NO;
}

- (BOOL)checkShouldRefreshOnlineStatus {
    return self.isShouldRefreshOnlineStatus;
}

- (void)refreshShouldRefreshOnlineStatus {
    _isShouldRefreshOnlineStatus = YES;
}

- (void)addToWaitingUploadFileMessage:(TAPMessageModel *)message {
    [self.waitingUploadDictionary setObject:message forKey:message.localID];
}

- (void)removeFromWaitingUploadFileMessage:(TAPMessageModel *)message {
    [self.waitingUploadDictionary removeObjectForKey:message.localID];
}

- (TAPMessageModel *)getMessageFromWaitingUploadDictionaryWithKey:(NSString *)localID {
   TAPMessageModel *message = [self.waitingResponseDictionary objectForKey:localID];
    return message;
}

@end
