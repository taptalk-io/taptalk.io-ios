//
//  TAPMessageStatusManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPMessageStatusManager.h"

@interface TAPMessageStatusManager ()

@property (strong, nonatomic) NSMutableArray *delegatesArray;
@property (strong, nonatomic) NSMutableArray *readMessageQueueArray;
@property (strong, nonatomic) NSMutableArray *deliveryMessageQueueArray;
@property (strong, nonatomic) NSMutableDictionary *APIRequestDictionary;
@property (strong, nonatomic) NSTimer *updateReadStatusTimer;

@property (nonatomic) NSInteger requestID;

- (void)markMessageAsReadWithMessage:(TAPMessageModel *)message;
- (void)triggerUpdateReadStatus;
- (void)stopTimerUpdateReadStatus;

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
        _delegatesArray = [[NSMutableArray alloc] init];
        _readMessageQueueArray = [[NSMutableArray alloc] init];
        _deliveryMessageQueueArray = [[NSMutableArray alloc] init];
        _APIRequestDictionary = [[NSMutableDictionary alloc] init];
        _requestID = 1;
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)triggerUpdateReadStatus {
    //Check timer is already running or not
    if([self.updateReadStatusTimer isValid]) {
        return;
    }
    
    CGFloat timerInterval = 0.5f;
    _updateReadStatusTimer = [NSTimer timerWithTimeInterval:timerInterval
                                                   target:self
                                                 selector:@selector(runChangingReadStatusFlow)
                                                 userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.updateReadStatusTimer forMode:NSRunLoopCommonModes];
    //    [[NSRunLoop mainRunLoop] addTimer:repeatingTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopTimerUpdateReadStatus {
    [self.updateReadStatusTimer invalidate];
    _updateReadStatusTimer = nil;
}


- (void)markMessageAsReadWithMessage:(TAPMessageModel *)message {
    [self.readMessageQueueArray addObject:message.messageID];
}

- (void)runChangingReadStatusFlow {
    //Get array of message
    
    if([self.readMessageQueueArray count] == 0) {
        return;
    }
    
    //Passing to delegate update read message
    for(id delegate in self.delegatesArray) {
        if([delegate respondsToSelector:@selector(messageStatusManagerDidUpdateReadMessageWithData:)]) {
            [delegate messageStatusManagerDidUpdateReadMessageWithData:self.readMessageQueueArray];
        }
    }
    
    //Clear read message queue
    NSArray *tempMessageArray = [NSArray array];
    tempMessageArray = self.readMessageQueueArray;
    
    for(TAPMessageModel *message in tempMessageArray) {
        [self.readMessageQueueArray removeObject:message];
    }
    
    //Call API send read status
    [TAPDataManager callAPIUpdateMessageReadStatusWithArray:tempMessageArray success:^{

        //Remove from dictionary
        NSArray *obtainedMessageIDsArray = [self.APIRequestDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)self.requestID]];
        if([obtainedMessageIDsArray count] != 0 && obtainedMessageIDsArray != nil) {
            //Contain in dictionary, remove from dictionary
            [self.APIRequestDictionary removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)self.requestID]];
            _requestID++;
        }

        //Update to database
        [TAPDataManager updateMessageReadStatusToDatabaseWithData:self.readMessageQueueArray tableName:@"TAPMessageRealmModel" success:^{
    
        } failure:^(NSError *error) {
    
        }];
    } failure:^(NSError *error) {
        //Save failed request array to dictionary
        [self.APIRequestDictionary setObject:tempMessageArray forKey:[NSString stringWithFormat:@"%ld", (long)self.requestID]];
        _requestID++;
    }];
}

@end
