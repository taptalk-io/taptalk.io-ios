//
//  TAPOldDataManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 06/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPOldDataManager.h"


#define kExecuteCountdown 7*24*60*60*1000.0f //7 days in miliseconds
#define kDeleteCountdown 30*24*60*60*1000.0f //30 days in miliseconds

@implementation TAPOldDataManager

#pragma mark - Lifecycle
+ (TAPOldDataManager *)sharedManager {
    static TAPOldDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if(self) {

    }
    
    return self;
}

#pragma mark - Custom Method
+ (void)runCleaningOldDataSequence {
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970] * 1000.0f;
    
    NSNumber *savedTimeIntervalNumber = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_LAST_DELETED_OLD_MESSAGE_TIMESTAMP valid:nil];
    NSTimeInterval savedTimeInterval = [savedTimeIntervalNumber doubleValue];
    
    if(savedTimeIntervalNumber == nil) {
        NSNumber *savedTime = [[NSNumber alloc] initWithDouble:currentTimeInterval];
        [[NSUserDefaults standardUserDefaults] setSecureObject:savedTime forKey:TAP_PREFS_LAST_DELETED_OLD_MESSAGE_TIMESTAMP];
    }
    else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            if(currentTimeInterval - savedTimeInterval > kExecuteCountdown) {
                //Last execution has been more than 7 days
                //Get all last message
                __block NSArray *lastMessagesArray = [NSArray array];
                [TAPDataManager getRoomListSuccess:^(NSArray *resultArray) {
                    lastMessagesArray = resultArray;
                    
                    [TAPOldDataManager generatePredicateStringWithArray:lastMessagesArray currentTimeInterval:currentTimeInterval success:^(NSString *predicateString) {
                        [TAPDataManager deleteDatabaseMessageWithPredicateString:predicateString success:^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //Save current time stamp to preference for next countdown execution.
                                NSDate *currentDate = [NSDate date];
                                NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970] * 1000.0f;
                                NSNumber *savedTime = [[NSNumber alloc] initWithDouble:currentTimeInterval];
                                [[NSUserDefaults standardUserDefaults] setSecureObject:savedTime forKey:TAP_PREFS_LAST_DELETED_OLD_MESSAGE_TIMESTAMP];
                            });
                        } failure:^(NSError *error) {
                            
                        }];
                    } failure:^(NSError *error) {
                        
                    }];
                    
                } failure:^(NSError *error) {
                    
                }];
            }
        });
    }
}

+ (void)generatePredicateStringWithArray:(NSArray *)lastMessagesArray
                     currentTimeInterval:(NSTimeInterval)currentTimeInterval
                                 success:(void (^)(NSString *predicateString))success
                                 failure:(void (^)(NSError *error))failure {
    __block NSString *predicateString = @"";
    
    for (TAPMessageModel *lastMessage in lastMessagesArray) {
        TAPRoomModel *room = lastMessage.room;
        [TAPDataManager getAllMessageWithRoomID:room.roomID sortByKey:@"created" ascending:YES success:^(NSArray<TAPMessageModel *> *messageArray) {
            NSArray *allMessageArray = [NSArray array];
            allMessageArray = messageArray;
            
            if ([allMessageArray count] > 50) {
                //Message has more than 1 page.
                for (NSInteger counter = 0; counter < [allMessageArray count] - 50; counter++) {
                    TAPMessageModel *currentMessage = [allMessageArray objectAtIndex:counter];
                    if (currentTimeInterval - [currentMessage.created doubleValue] > kDeleteCountdown) {
                        //Current message is more than 1 month old to be deleted.
                        if ([predicateString isEqualToString:@""]) {
                            predicateString = [NSString stringWithFormat:@"localID LIKE '%@'", currentMessage.localID]; //salah
                        }
                        else {
                            predicateString = [NSString stringWithFormat:@"%@ OR localID LIKE '%@'", predicateString, currentMessage.localID];
                        }
                        
                        if (currentMessage.type == TAPChatMessageTypeImage || currentMessage.type == TAPChatMessageTypeVideo || currentMessage.type == TAPChatMessageTypeFile) {
                            //Delete physical file.
                        }
                    }
                    else {
                        //Stop for loop when message.created less than 1 month.
                        break;
                    }
                }
            }
        } failure:^(NSError *error) {
            failure(error);
        }];
        
        continue;
    }
    
    success(predicateString);
}

@end
