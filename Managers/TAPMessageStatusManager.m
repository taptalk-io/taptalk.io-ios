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

@property (strong, nonatomic) NSMutableDictionary *readMessageAPIRequestDictionary;
@property (strong, nonatomic) NSMutableDictionary *deliveredMessageAPIRequestDictionary;
@property (strong, nonatomic) NSMutableDictionary *filteredBulkDeliveryMessageAPIRequestDictionary;

@property (strong, nonatomic) NSTimer *updateStatusTimer;

@property (nonatomic) NSInteger deliveredRequestID;
@property (nonatomic) NSInteger deliveredBulkRequestID;
@property (nonatomic) NSInteger readRequestID;

@property (nonatomic) BOOL isProcessingUpdateDeliveredStatus;
@property (nonatomic) BOOL isProcessingUpdateReadStatus;

- (void)updateMessageStatus;
- (void)changingDeliveredStatusFlow;
- (void)changingBulkFilteredDeliveredStatusFlow;
- (void)changingReadStatusFlow;

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
        _readMessageAPIRequestDictionary = [[NSMutableDictionary alloc] init];
        _deliveredMessageAPIRequestDictionary = [[NSMutableDictionary alloc] init];
        _filteredBulkDeliveryMessageAPIRequestDictionary = [[NSMutableDictionary alloc] init];
        _readRequestID = 1;
        _deliveredRequestID = 1;
        _deliveredBulkRequestID = 1;
        _isProcessingUpdateDeliveredStatus = NO;
        _isProcessingUpdateReadStatus = NO;
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)triggerUpdateStatus {
    //Check timer is already running or not
    if ([self.updateStatusTimer isValid]) {
        return;
    }
    
    CGFloat timerInterval = 0.5f;
    _updateStatusTimer = [NSTimer timerWithTimeInterval:timerInterval
                                                   target:self
                                                 selector:@selector(updateMessageStatus)
                                                 userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.updateStatusTimer forMode:NSRunLoopCommonModes];
    //    [[NSRunLoop mainRunLoop] addTimer:repeatingTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopTimerUpdateStatus {
    [self.updateStatusTimer invalidate];
    _updateStatusTimer = nil;
}

- (void)markMessageAsReadWithMessage:(TAPMessageModel *)message {
    [self.readMessageQueueArray addObject:message];
}

- (void)markMessageAsDeliveredWithMessage:(TAPMessageModel *)message {
    [self.deliveryMessageQueueArray addObject:message];
}

- (void)updateMessageStatus {
    //Call API to update delivery status
    [self changingDeliveredStatusFlow];
    
    //Update leftover bulk delivery status that has not been called
    [self changingBulkFilteredDeliveredStatusFlow];
    
    //Call API to update read status
    [self changingReadStatusFlow];
}

- (void)changingReadStatusFlow {
    //Get array of message
    if ([self.readMessageQueueArray count] == 0 || self.isProcessingUpdateReadStatus) {
        return;
    }
    
    _isProcessingUpdateReadStatus = YES;
    
    //Clear read message queue
    NSMutableArray *parameterMessageIDsArray = [NSMutableArray array];
    NSArray *tempMessageArray = [self.readMessageQueueArray copy];
    
    for (TAPMessageModel *message in tempMessageArray) {
        [parameterMessageIDsArray addObject:message.messageID];
        [self.readMessageQueueArray removeObject:message];
    }
    
    //Call API send read status
    [TAPDataManager callAPIUpdateMessageReadStatusWithArray:parameterMessageIDsArray success:^(NSArray *updatedMessageIDsArray) {
        
        //Remove from dictionary
        NSArray *obtainedMessageIDsArray = [self.readMessageAPIRequestDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)self.readRequestID]];
        if ([obtainedMessageIDsArray count] != 0 && obtainedMessageIDsArray != nil) {
            //Contain in dictionary, remove from dictionary
            [self.readMessageAPIRequestDictionary removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)self.readRequestID]];
            _readRequestID++;
        }
        
        _isProcessingUpdateReadStatus = NO;

        //Update to database
        [TAPDataManager updateMessageReadStatusToDatabaseWithData:tempMessageArray tableName:@"TAPMessageRealmModel" success:^{
    
        } failure:^(NSError *error) {
    
        }];
    } failure:^(NSError *error) {
        //Save failed request array to dictionary
        [self.readMessageAPIRequestDictionary setObject:parameterMessageIDsArray forKey:[NSString stringWithFormat:@"%ld", (long)self.readRequestID]];
        _readRequestID++;
        _isProcessingUpdateReadStatus = NO;
    }];
}

- (void)changingDeliveredStatusFlow {
    //Get array of message
    if ([self.deliveryMessageQueueArray count] == 0 || self.isProcessingUpdateDeliveredStatus) {
        return;
    }

   _isProcessingUpdateDeliveredStatus = YES;

    //Clear delivery message queue
    NSMutableArray *parameterMessageIDsArray = [NSMutableArray array];
    NSArray *tempMessageArray = [self.deliveryMessageQueueArray copy];

    for (TAPMessageModel *message in tempMessageArray) {
        [parameterMessageIDsArray addObject:message.messageID];
        [self.deliveryMessageQueueArray removeObject:message];
    }

    //Call API send delivery status
    [TAPDataManager callAPIUpdateMessageDeliverStatusWithArray:parameterMessageIDsArray success:^(NSArray *updatedMessageIDsArray) {
    
        //Remove from dictionary
        NSArray *obtainedMessageIDsArray = [self.deliveredMessageAPIRequestDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)self.deliveredRequestID]];
        if ([obtainedMessageIDsArray count] != 0 && obtainedMessageIDsArray != nil) {
            //Contain in dictionary, remove from dictionary
            [self.deliveredMessageAPIRequestDictionary removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)self.deliveredRequestID]];
            _deliveredRequestID++;
        }

       _isProcessingUpdateDeliveredStatus = NO;
        
        //Update to database
        [TAPDataManager updateMessageDeliveryStatusToDatabaseWithData:tempMessageArray tableName:@"TAPMessageRealmModel" success:^{

        } failure:^(NSError *error) {

        }];
        
    } failure:^(NSError *error) {
        //Save failed request array to dictionary
        [self.deliveredMessageAPIRequestDictionary setObject:parameterMessageIDsArray forKey:[NSString stringWithFormat:@"%ld", (long)self.deliveredRequestID]];
        _deliveredRequestID++;
       _isProcessingUpdateDeliveredStatus = NO;
    }];
}

- (void)changingBulkFilteredDeliveredStatusFlow {
    //Update to deliver from bulk of message where isSending = 0 && isDelivered == 0 && isRead == 0
    //Get array of message
    if ([self.filteredBulkDeliveryMessageArray count] == 0 || self.isProcessingUpdateDeliveredStatus) {
        return;
    }
    
    _isProcessingUpdateDeliveredStatus = YES;
    
    //Clear delivery message queue
    NSMutableArray *parameterMessageIDsArray = [NSMutableArray array];
    NSArray *tempMessageArray = [self.filteredBulkDeliveryMessageArray copy];
    
    for (TAPMessageModel *message in tempMessageArray) {
        [parameterMessageIDsArray addObject:message.messageID];
        [self.filteredBulkDeliveryMessageArray removeObject:message];
    }
    
    //Call API send delivery status
    [TAPDataManager callAPIUpdateMessageDeliverStatusWithArray:parameterMessageIDsArray success:^(NSArray *updatedMessageIDsArray) {
        
        //Remove from dictionary
        NSArray *obtainedMessageIDsArray = [self.filteredBulkDeliveryMessageAPIRequestDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)self.deliveredBulkRequestID]];
        if ([obtainedMessageIDsArray count] != 0 && obtainedMessageIDsArray != nil) {
            //Contain in dictionary, remove from dictionary
            [self.filteredBulkDeliveryMessageAPIRequestDictionary removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)self.deliveredBulkRequestID]];
            _deliveredBulkRequestID++;
        }
        
        _isProcessingUpdateDeliveredStatus = NO;
        
        //Update to database
        [TAPDataManager updateMessageDeliveryStatusToDatabaseWithData:tempMessageArray tableName:@"TAPMessageRealmModel" success:^{
            
        } failure:^(NSError *error) {
            
        }];
        
    } failure:^(NSError *error) {
        //Save failed request array to dictionary
        [self.filteredBulkDeliveryMessageAPIRequestDictionary setObject:parameterMessageIDsArray forKey:[NSString stringWithFormat:@"%ld", (long)self.deliveredBulkRequestID]];
        _deliveredBulkRequestID++;
        _isProcessingUpdateDeliveredStatus = NO;
    }];
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
    NSString *messageIDString = message.messageID;
    NSArray *parameterMessageIDsArray = @[messageIDString];
    
    //Call API send delivery status
    [TAPDataManager callAPIUpdateMessageDeliverStatusWithArray:parameterMessageIDsArray success:^(NSArray *updatedMessageIDsArray) {
        
        //Update to database
        [TAPDataManager updateMessageDeliveryStatusToDatabaseWithData:@[message] tableName:@"TAPMessageRealmModel" success:^{
            
        } failure:^(NSError *error) {
            
        }];
        
    } failure:^(NSError *error) {
 
    }];
}

- (BOOL)hasPendingProcess {
    if([self.readMessageQueueArray count] == 0 && [self.deliveryMessageQueueArray count] == 0 && [[self.readMessageAPIRequestDictionary allKeys] count] == 0 && [[self.deliveredMessageAPIRequestDictionary allKeys] count] == 0) {
        return NO;
    }
    
    return YES;
}

@end
