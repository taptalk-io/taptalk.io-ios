//
//  TAPOldDataManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 06/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPOldDataManager.h"
#import "TAPFileDownloadManager.h"


#define kExecuteCountdown 7*24*60*60*1000.0f //7 days in miliseconds
#define kDeleteCountdown 30*24*60*60*1000.0f //30 days in miliseconds

#define kOneMonthTimeIntervalInMilliseconds 30*24*60*60*1000.0f //30 days in miliseconds

@interface TAPOldDataManager ()

+ (void)fetchSmallestCreatedUnreadMessageWithRoomID:(NSString *)roomID
                                            success:(void (^)(NSTimeInterval smallestUnreadMessageCreated))success
                                            failure:(void (^)(NSError *error))failure;
+ (void)runDeletePhysicalFileAndMessageSequenceWithMessageArray:(NSArray *)messageArray
                                                        success:(void (^)())success
                                                        failure:(void (^)(NSError *error))failure;
+ (void)deletePhysicalFilesWithMessage:(TAPMessageModel *)message
                               success:(void (^)())success
                               failure:(void (^)(NSError *error))failure;

@end

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
    
    if (self) {

    }
    
    return self;
}

#pragma mark - Custom Method
+ (void)runCleaningOldDataSequence {
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970] * 1000.0f;
    NSTimeInterval oneMonthBeforeTimeInterval = currentTimeInterval - kOneMonthTimeIntervalInMilliseconds;
    
    NSNumber *savedTimeIntervalNumber = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_LAST_DELETED_OLD_MESSAGE_TIMESTAMP valid:nil];
    NSTimeInterval savedTimeInterval = [savedTimeIntervalNumber doubleValue];
    
    if (savedTimeIntervalNumber == nil) {
        NSNumber *savedTime = [[NSNumber alloc] initWithDouble:currentTimeInterval];
        [[NSUserDefaults standardUserDefaults] setSecureObject:savedTime forKey:TAP_PREFS_LAST_DELETED_OLD_MESSAGE_TIMESTAMP];
    }
    else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            if (currentTimeInterval - savedTimeInterval > kExecuteCountdown) {
                //Last execution has been more than 7 days
                //Get all last message in room list
                __block NSArray *lastMessagesArray = [NSArray array];
                [TAPDataManager getRoomListSuccess:^(NSArray *resultArray) {
                    lastMessagesArray = resultArray;
                    
                    for (TAPMessageModel *lastMessage in lastMessagesArray) {
                        TAPRoomModel *room = lastMessage.room;
                        
                        __block NSTimeInterval minUnreadCreated;
                        __block NSTimeInterval nextPageFirstMessageCreated;
                        //Obtain smallest created of unread messages
                        [TAPOldDataManager fetchSmallestCreatedUnreadMessageWithRoomID:room.roomID success:^(NSTimeInterval smallestUnreadMessageCreated) {
                            minUnreadCreated = smallestUnreadMessageCreated;
                            
                            //Get All message of selected room
                            [TAPDataManager getAllMessageWithRoomID:room.roomID sortByKey:@"created" ascending:NO success:^(NSArray<TAPMessageModel *> *messageArray) {
#ifdef DEBUG
                                NSLog(@"MESSAGE COUNT: %ld ROOM NAME: %@", [messageArray count], room.name);
#endif
                                if ([messageArray count] > TAP_NUMBER_OF_ITEMS_CHAT) {
#ifdef DEBUG
                                    NSLog(@"Message more than one page with room name: %@", room.name);
#endif
                                    //get created message index number of items per page + 1
                                    TAPMessageModel *nextPageFirstMessage = [messageArray objectAtIndex:TAP_NUMBER_OF_ITEMS_CHAT + 1];
                                    nextPageFirstMessageCreated = [nextPageFirstMessage.created doubleValue];
                                    
                                    //compare H-1 month, smallest unread message created, created first item of next page (index: number of items per page + 1)
                                    NSTimeInterval minimumCreatedData;
                                    if (minUnreadCreated >= 0) {
                                        //unread found
                                        if (oneMonthBeforeTimeInterval < minUnreadCreated) {
                                            minimumCreatedData = oneMonthBeforeTimeInterval;
                                        }
                                        else {
                                            minimumCreatedData = minUnreadCreated;
                                        }
                                    }
                                    else {
                                        //unread not found
                                        minimumCreatedData = oneMonthBeforeTimeInterval;
                                    }
                                    
                                    if (nextPageFirstMessageCreated < minimumCreatedData) {
                                        minimumCreatedData = nextPageFirstMessageCreated;
                                    }
                                    
                                    NSMutableArray *messageTypeArray = [NSMutableArray array];
                                    [messageTypeArray addObject:[NSNumber numberWithInteger:TAPChatMessageTypeImage]];
                                    [messageTypeArray addObject:[NSNumber numberWithInteger:TAPChatMessageTypeVideo]];
                                    [messageTypeArray addObject:[NSNumber numberWithInteger:TAPChatMessageTypeFile]];

                                    [TAPDataManager getAllMessageWithRoomID:room.roomID messageTypes:messageTypeArray minimumDateCreated:minimumCreatedData sortByKey:@"created" ascending:NO success:^(NSArray<TAPMessageModel *> *messageArray) {
            
                                        //Delete message & physical data of image/video/file
                                        [TAPOldDataManager runDeletePhysicalFileAndMessageSequenceWithMessageArray:messageArray success:^{
                                            
                                            //Get all message other than media type
                                            NSNumber *minCreatedNumber = [NSNumber numberWithDouble:minimumCreatedData];
                                            NSString *queryString = [NSString stringWithFormat:@"created < %ld", [minCreatedNumber integerValue]];
                                            [TAPDataManager getAllMessageWithRoomID:room.roomID query:queryString sortByKey:@"created" ascending:NO success:^(NSArray<TAPMessageModel *> *messageArray) {
                                                
                                                //Delete other type of message
                                                [TAPDataManager deleteDatabaseMessageWithData:messageArray success:^{
                                                    
                                                } failure:^(NSError *error) {
                                                    //failure delete message from database
                                                }];
                                                
                                                //Save current time stamp to preference for next countdown execution.
                                                NSDate *currentDate = [NSDate date];
                                                NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970] * 1000.0f;
                                                NSNumber *savedTime = [[NSNumber alloc] initWithDouble:currentTimeInterval];
                                                [[NSUserDefaults standardUserDefaults] setSecureObject:savedTime forKey:TAP_PREFS_LAST_DELETED_OLD_MESSAGE_TIMESTAMP];
                                                
                                            } failure:^(NSError *error) {
                                                //failure get other message than media type
                                            }];
                                        } failure:^(NSError *error) {
                                            //failure run delete physical file data and message
                                        }];
                                    } failure:^(NSError *error) {
                                        //failure get all message in room
                                    }];
                                }
                            } failure:^(NSError *error) {
                                //failure get all message in room
                            }];
                        } failure:^(NSError *error) {
                            //failure get smallest created unread message
                        }];
                    }
                } failure:^(NSError *error) {
                    //failure get room list
                }];
            }
        });
    }
}

+ (void)runDeletePhysicalFileAndMessageSequenceWithMessageArray:(NSArray *)messageArray
                                                        success:(void (^)())success
                                                        failure:(void (^)(NSError *error))failure {

    if ([messageArray count] == 0 || messageArray == nil) {
        success();
    }
    else {
        //Delete physical file & message (type image, video, files)
        for (TAPMessageModel *currentMessage in messageArray) {
            //Delete physical file
            [TAPOldDataManager deletePhysicalFilesWithMessage:currentMessage success:^{
                //Delete message
                [TAPDataManager deleteDatabaseMessageWithData:@[currentMessage] success:^{
                    success();
                } failure:^(NSError *error) {
                    //failure delete database message
                    failure(error);
                }];
            } failure:^(NSError *error) {
                //failure delete physical file data
                failure(error);
            }];
        }
    }
}

+ (void)deletePhysicalFilesWithMessage:(TAPMessageModel *)message
                               success:(void (^)())success
                               failure:(void (^)(NSError *error))failure {
    if (message.type == TAPChatMessageTypeImage) {
        NSDictionary *dataDictionary = message.data;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        
        //Remove image
        [TAPImageView removeImageFromCacheWithKey:fileID];

        success();
    }
    else if (message.type == TAPChatMessageTypeVideo) {
        NSDictionary *dataDictionary = message.data;
        NSString *roomID = message.room.roomID;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        
        //Remove thumbnail image
        [TAPImageView removeImageFromCacheWithKey:fileID];
        
        //Remove video
        NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:fileID];
        if (![filePath isEqualToString:@""]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        success();
    }
    else if (message.type == TAPChatMessageTypeFile) {
        NSDictionary *dataDictionary = message.data;
        NSString *roomID = message.room.roomID;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];

        //Remove file
        NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:fileID];
        if (![filePath isEqualToString:@""]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        success();
    }
}

+ (void)fetchSmallestCreatedUnreadMessageWithRoomID:(NSString *)roomID
                                            success:(void (^)(NSTimeInterval smallestUnreadMessageCreated))success
                                            failure:(void (^)(NSError *error))failure {
    [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:roomID
                                                 activeUserID:[TAPChatManager sharedManager].activeUser.userID
                                                      success:^(NSArray *unreadMessages) {
                                                          if ([unreadMessages count] == 0 || unreadMessages == nil) {
                                                              //Not found
                                                              success(-1);
                                                          }
                                                          else {
                                                              //Obtain earliest unread message index
                                                              TAPMessageModel *earliestUnreadMessage = [unreadMessages firstObject];
                                                              NSTimeInterval smallestUnreadMessageCreated = [earliestUnreadMessage.created doubleValue];
                                                              success(smallestUnreadMessageCreated);
                                                          }
                                                      } failure:^(NSError *error) {
                                                          failure(error);
                                                      }];
}

@end
