//
//  TAPMessageStatusManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPMessageStatusManager.h"

@interface TAPMessageStatusManager ()

@property (strong, nonatomic) NSMutableArray *readMessageQueueArray;
@property (strong, nonatomic) NSMutableArray *deliveryMessageQueueArray;
@property (strong, nonatomic) NSMutableArray *filteredBulkDeliveryMessageArray;

@property (strong, nonatomic) NSMutableDictionary *readCountDictionary;

@property (nonatomic) NSInteger apiRequestCount;

@property (nonatomic) BOOL isProcessingUpdateDeliveredStatus;
@property (nonatomic) BOOL isProcessingUpdateReadStatus;

- (void)changingDeliveredStatusFlowFinishUpdateDatabase:(void (^)())finish;
- (void)changingBulkFilteredDeliveredStatusFlowFinishUpdateDatabase:(void (^)())finish;
- (void)changingReadStatusFlow;
- (void)increaseReadCountDictionaryWithRoomID:(NSString *)roomID;

@end

@implementation TAPMessageStatusManager

#pragma mark - Lifecycle
+ (TAPMessageStatusManager *)sharedManager {
    static TAPMessageStatusManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _readMessageQueueArray = [[NSMutableArray alloc] init];
        _deliveryMessageQueueArray = [[NSMutableArray alloc] init];
        _filteredBulkDeliveryMessageArray = [[NSMutableArray alloc] init];
        _readCountDictionary = [[NSMutableDictionary alloc] init];
        _isProcessingUpdateDeliveredStatus = NO;
        _isProcessingUpdateReadStatus = NO;
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)markMessageAsReadWithMessage:(TAPMessageModel *)message {
    [self.readMessageQueueArray addObject:message];
    
    //Add to read count dictionary
    [self increaseReadCountDictionaryWithRoomID:message.room.roomID];
}

- (void)markMessageAsDeliveredWithMessage:(TAPMessageModel *)message {
    [self.deliveryMessageQueueArray addObject:message];
}

- (void)triggerUpdateMessageStatus {
    //Do update sequentialy to prevent data misplaced from delivered back to read
    
    //Call API to update delivery status
    [self changingDeliveredStatusFlowFinishUpdateDatabase:^{
        //Update leftover bulk delivery status that has not been called
        [self changingBulkFilteredDeliveredStatusFlowFinishUpdateDatabase:^{
            //Call API to update read status
            [self changingReadStatusFlow];
        }];
    }];
}

- (void)changingReadStatusFlow {
    //Get array of message
    if ([self.readMessageQueueArray count] == 0 || self.isProcessingUpdateReadStatus) {
        return;
    }
    
    _isProcessingUpdateReadStatus = YES;
    
    //Clear read message queue
    NSArray *tempMessageArray = [self.readMessageQueueArray copy];
    [self.readMessageQueueArray removeAllObjects];
    
    //DV Note - will be handled in receive emit read message
//    //Update to database
//    [TAPDataManager updateMessageReadStatusToDatabaseWithData:tempMessageArray success:^{
//        [self.readMessageQueueArray removeAllObjects];
//    } failure:^(NSError *error) {
//
//    }];
    //END DV Note
    
    //Call API send read status
    _apiRequestCount++;
            
    [TAPDataManager callAPIUpdateMessageReadStatusWithArray:tempMessageArray success:^(NSArray *updatedMessageIDsArray, NSArray *originMessageArray) {
        _isProcessingUpdateReadStatus = NO;
        _apiRequestCount--;
        
        //Update message array that mark as read to database with 1 second timer
        [[TAPChatManager sharedManager] updateReadMessageToDatabaseQueueWithArray:originMessageArray];
        
    } failure:^(NSError *error, NSArray *messageArray) {
        _isProcessingUpdateReadStatus = NO;
        _apiRequestCount--;
        
    //DV Note - will be handled in receive emit read message
//        //Save failed to preference
//        NSMutableArray *pendingReadDataArray = [NSMutableArray array];
//        pendingReadDataArray = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_PENDING_UPDATE_READ_MESSAGE valid:nil];
//        pendingReadDataArray = [TAPUtil nullToEmptyArray:pendingReadDataArray];
//
//        for(TAPMessageModel *message in messageArray) {
//            NSString *messageID = message.messageID;
//            [pendingReadDataArray addObject:messageID];
//        }
//
//        [[NSUserDefaults standardUserDefaults] setSecureObject:pendingReadDataArray forKey:TAP_PREFS_PENDING_UPDATE_READ_MESSAGE];
    //END DV Note
    }];
}

- (void)changingDeliveredStatusFlowFinishUpdateDatabase:(void (^)())finish {
    //Get array of message
    if ([self.deliveryMessageQueueArray count] == 0 || self.isProcessingUpdateDeliveredStatus) {
        finish();
        return;
    }

   _isProcessingUpdateDeliveredStatus = YES;

    NSArray *tempMessageArray = [self.deliveryMessageQueueArray copy];
    
    //Update to database
    [TAPDataManager updateMessageDeliveryStatusToDatabaseWithData:tempMessageArray success:^{
        [self.deliveryMessageQueueArray removeAllObjects];
        finish();
    } failure:^(NSError *error) {
        finish();
    }];

    //Call API send delivery status
    _apiRequestCount++;
    [TAPDataManager callAPIUpdateMessageDeliverStatusWithArray:tempMessageArray success:^(NSArray *updatedMessageIDsArray) {
       _isProcessingUpdateDeliveredStatus = NO;
        _apiRequestCount--;
    } failure:^(NSError *error, NSArray *messageArray) {
       _isProcessingUpdateDeliveredStatus = NO;
        _apiRequestCount--;
        
        //Put back failed response to array
        for(TAPMessageModel *message in messageArray) {
            [self markMessageAsDeliveredWithMessage:message];
        }
    }];
}

- (void)changingBulkFilteredDeliveredStatusFlowFinishUpdateDatabase:(void (^)())finish {
    //Update to deliver from bulk of message where isSending = 0 && isDelivered == 0 && isRead == 0
    //Get array of message
    if ([self.filteredBulkDeliveryMessageArray count] == 0 || self.isProcessingUpdateDeliveredStatus) {
        finish();
        return;
    }
    
    _isProcessingUpdateDeliveredStatus = YES;
    
    //Clear delivery message queue
    NSArray *tempMessageArray = [self.filteredBulkDeliveryMessageArray copy];
    
    //Update to database
    [TAPDataManager updateMessageDeliveryStatusToDatabaseWithData:tempMessageArray success:^{
        finish();
    } failure:^(NSError *error) {
        finish();
    }];
    
    //Call API send delivery status
    _apiRequestCount++;
    [TAPDataManager callAPIUpdateMessageDeliverStatusWithArray:tempMessageArray success:^(NSArray *updatedMessageIDsArray) {
        _isProcessingUpdateDeliveredStatus = NO;
        _apiRequestCount--;
    } failure:^(NSError *error, NSArray *messageArray) {
        _isProcessingUpdateDeliveredStatus = NO;
        _apiRequestCount--;
        
        //Put back failed response to array
        [self filterAndUpdateBulkMessageStatusToDeliveredWithArray:messageArray];
    }];
    
    [self.filteredBulkDeliveryMessageArray removeAllObjects];
}

- (void)filterAndUpdateBulkMessageStatusToDeliveredWithArray:(NSArray *)messageArray {
    for (TAPMessageModel *message in messageArray) {
        BOOL isSending = message.isSending;
        BOOL isRead = message.isRead;
        BOOL isDelivered = message.isDelivered;
        
        //Check if message is send by other user
        NSString *senderUserID = message.user.userID;
        senderUserID = [TAPUtil nullToEmptyString:senderUserID];
        
        NSString *currentUserID = [TAPDataManager getActiveUser].userID;
        currentUserID = [TAPUtil nullToEmptyString:currentUserID];
        
        if (isSending == NO && isDelivered == NO && isRead == NO && ![senderUserID isEqualToString:currentUserID]) {
            //Add to array, update to delivered
            [self.filteredBulkDeliveryMessageArray addObject:message];
        }
    }
}

- (void)markMessageAsDeliveredFromPushNotificationWithMessage:(TAPMessageModel *)message {
//    NSString *messageIDString = message.messageID;
//    NSArray *parameterMessageIDsArray = @[messageIDString];
    
    //Update to database
    [TAPDataManager updateMessageDeliveryStatusToDatabaseWithData:@[message] success:^{
        
    } failure:^(NSError *error) {
        
    }];
    
    //Call API send delivery status
    [TAPDataManager callAPIUpdateMessageDeliverStatusWithArray:@[message] success:^(NSArray *updatedMessageIDsArray) {
        
    } failure:^(NSError *error, NSArray *messageIDArray) {
 
    }];
}

- (BOOL)hasPendingProcess {
    if([self.readMessageQueueArray count] == 0 && [self.deliveryMessageQueueArray count] == 0 && self.apiRequestCount == 0) {
        return NO;
    }
    
    return YES;
}

- (void)increaseReadCountDictionaryWithRoomID:(NSString *)roomID {
    NSNumber *currentCount = [self.readCountDictionary objectForKey:roomID];
    
    if(currentCount == nil) {
        //Count is nil, create new object in dictionary
        [self.readCountDictionary setObject:[NSNumber numberWithInt:1] forKey:roomID];
        return;
    }
    
    //Count not nil, increase count
    NSInteger countInteger = [currentCount integerValue];
    countInteger++;
    
    [self.readCountDictionary setObject:[NSNumber numberWithInt:countInteger] forKey:roomID];
}

- (NSInteger)getReadCountAndClearDictionaryForRoomID:(NSString *)roomID {
    NSNumber *currentCount = [self.readCountDictionary objectForKey:roomID];
    
    if(currentCount == nil) {
        return 0;
    }
    
    NSInteger countInteger = [currentCount integerValue];
    [self.readCountDictionary removeObjectForKey:roomID];
    
    return countInteger;
}

- (void)clearReadCountDictionary {
    [self.readCountDictionary removeAllObjects];
}

- (void)clearMessageStatusManagerData {
    [self.readMessageQueueArray removeAllObjects];
    [self.deliveryMessageQueueArray removeAllObjects];
    [self.filteredBulkDeliveryMessageArray removeAllObjects];
    [self.readCountDictionary removeAllObjects];
}

@end
