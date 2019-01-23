//
//  TAPFileDownloadManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 17/01/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPFileDownloadManager.h"
#import <TapTalk/Base64.h>

@interface TAPFileDownloadManager ()

@property (strong, nonatomic) NSMutableDictionary *thumbnailDictionary;
//@property (strong, nonatomic) NSMutableDictionary *downloadQueueDictionary;
@property (strong, nonatomic) NSMutableDictionary *downloadProgressDictionary;
@property (strong, nonatomic) NSMutableDictionary *currentDownloadingDictionary;

- (void)runDownloadImageWithRoomID:(NSString *)roomID
                           message:(TAPMessageModel *)message
                          progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *currentDownloadMessage))progressBlock
                           success:(void (^)(UIImage *fullImage, TAPMessageModel *currentDownloadMessage))success
                           failure:(void(^)(NSError *error, TAPMessageModel *currentDownloadMessage))failure;

// DV NOTE - Uncomment this function to use API Thumbnail image
//- (void)runDownloadImageWithRoomID:(NSString *)roomID
//                           message:(TAPMessageModel *)message
//                          progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *currentDownloadMessage))progressBlock
//             successThumbnailImage:(void (^)(UIImage *thumbnailImage, TAPMessageModel *currentDownloadMessage))successThumbnail
//                  successFullImage:(void (^)(UIImage *fullImage, TAPMessageModel *currentDownloadMessage))success
//             failureThumbnailImage:(void(^)(NSError *error, TAPMessageModel *currentDownloadMessage))failureThumbnail
//                  failureFullImage:(void(^)(NSError *error, TAPMessageModel *currentDownloadMessage))failure;
//END DV NOTE

@end

@implementation TAPFileDownloadManager
#pragma mark - Lifecycle
+ (TAPFileDownloadManager *)sharedManager {
    static TAPFileDownloadManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _thumbnailDictionary = [[NSMutableDictionary alloc] init];
//        _downloadQueueDictionary = [[NSMutableDictionary alloc] init];
        _downloadProgressDictionary = [[NSMutableDictionary alloc] init];
        _currentDownloadingDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Custom Method
- (void)receiveImageFileWithMessage:(TAPMessageModel *)message
                              start:(void(^)(TAPMessageModel *receivedMessage))startProgress
                           progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
                            success:(void (^)(UIImage *fullImage,TAPMessageModel *receivedMessage))success
                            failure:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure {
    
    NSString *roomID = message.room.roomID;
    NSDictionary *dataDictionary = message.data;
    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
    fileID = [TAPUtil nullToEmptyString:fileID];
    
    if (roomID == nil || [roomID isEqualToString:@""] || fileID == nil || [fileID isEqualToString:@""]) {
        return;
    }
    
    [TAPImageView imageFromCacheWithKey:fileID message:message success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
        NSString *currentRoomID = resultMessage.room.roomID;
        NSString *currentLocalID = resultMessage.localID;
        NSDictionary *currentDataDictionary = resultMessage.data;
        NSString *currentFileID = [currentDataDictionary objectForKey:@"fileID"];
        currentFileID = [TAPUtil nullToEmptyString:currentFileID];
        
        //Check image exist in cache
        if (savedImage != nil) {
            //Image exist
            success(savedImage, resultMessage);
        }
        else {
            //Image not exist in cache
            if ([self.currentDownloadingDictionary objectForKey:currentFileID]) {
                return;
            }
            
            //add to temp processing dictionary
            [self.currentDownloadingDictionary setObject:[NSNumber numberWithInteger:1] forKey:currentFileID];
            
            //Notify start downloading
            startProgress(resultMessage);
            
            [self runDownloadImageWithRoomID:currentRoomID message:resultMessage progress:^(CGFloat progress, CGFloat total, TAPMessageModel *currentDownloadMessage) {
                
                NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                [objectDictionary setObject:currentDownloadMessage forKey:@"message"];
                [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
                [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                
                [self.downloadProgressDictionary setObject:objectDictionary forKey:currentDownloadMessage.localID];
                
                progressBlock(progress, total, resultMessage);
            } success:^(UIImage *fullImage, TAPMessageModel *currentDownloadMessage) {
                NSString *roomID = currentDownloadMessage.room.roomID;
                NSString *localID = currentDownloadMessage.localID;
                NSDictionary *dataDictionary = currentDownloadMessage.data;
                NSString *fileID = [dataDictionary objectForKey:@"fileID"];
                fileID = [TAPUtil nullToEmptyString:fileID];
                
                NSInteger currentProcessingCounter = [[self.currentDownloadingDictionary objectForKey:fileID] integerValue];
                if (currentProcessingCounter == 1) {
                    //done processing
                    [self.currentDownloadingDictionary removeObjectForKey:fileID];
                }
                
                [self.downloadProgressDictionary removeObjectForKey:currentDownloadMessage.localID];
                
                success(fullImage, currentDownloadMessage);
            } failure:^(NSError *error, TAPMessageModel *currentDownloadMessage) {
                NSString *roomID = currentDownloadMessage.room.roomID;
                NSString *localID = currentDownloadMessage.localID;
                NSDictionary *dataDictionary = currentDownloadMessage.data;
                NSString *fileID = [dataDictionary objectForKey:@"fileID"];
                fileID = [TAPUtil nullToEmptyString:fileID];
                
                NSInteger currentProcessingCounter = [[self.currentDownloadingDictionary objectForKey:fileID] integerValue];
                if (currentProcessingCounter == 1) {
                    //done processing
                    [self.currentDownloadingDictionary removeObjectForKey:fileID];
                }
                
                failure(error, currentDownloadMessage);
            }];
        }
    }];
}

- (void)runDownloadImageWithRoomID:(NSString *)roomID
                           message:(TAPMessageModel *)message
                          progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *currentDownloadMessage))progressBlock
                           success:(void (^)(UIImage *fullImage, TAPMessageModel *currentDownloadMessage))success
                           failure:(void(^)(NSError *error, TAPMessageModel *currentDownloadMessage))failure {
    
    NSDictionary *currentDataDictionary = message.data;
    NSString *currentFileID = [currentDataDictionary objectForKey:@"fileID"];
    
    //Call API Download Full Image
    [TAPDataManager callAPIDownloadFileWithFileID:currentFileID roomID:roomID isThumbnail:NO completionBlock:^(UIImage *downloadedImage) {
        
        //Save image to cache
        [TAPImageView saveImageToCache:downloadedImage withKey:currentFileID];
        
        //Send back success download image
        success(downloadedImage, message);
        
    } progressBlock:^(CGFloat progress, CGFloat total) {
        progressBlock(progress, total, message);
    } failureBlock:^(NSError *error) {
        failure(error, message);
    }];
}

- (NSDictionary *)getDownloadProgressWithLocalID:(NSString *)localID {
    NSDictionary *progressDictionary = [self.downloadProgressDictionary objectForKey:localID];
    return progressDictionary;
}

// DV NOTE - Uncomment this function to use API Thumbnail image
//- (void)receiveImageFileWithMessage:(TAPMessageModel *)message
//                           progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
//              successThumbnailImage:(void (^)(UIImage *thumbnailImage, TAPMessageModel *receivedMessage))successThumbnail
//                   successFullImage:(void (^)(UIImage *fullImage,TAPMessageModel *receivedMessage))success
//              failureThumbnailImage:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failureThumbnail
//                   failureFullImage:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure {
//
//    NSString *roomID = message.room.roomID;
//    NSDictionary *dataDictionary = message.data;
//    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
//    fileID = [TAPUtil nullToEmptyString:fileID];
//
//    if (roomID == nil || [roomID isEqualToString:@""] || fileID == nil || [fileID isEqualToString:@""]) {
//        return;
//    }
//
//    [TAPImageView imageFromCacheWithKey:fileID message:message success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
//        NSString *currentRoomID = resultMessage.room.roomID;
//        NSString *currentLocalID = resultMessage.localID;
//        NSDictionary *currentDataDictionary = resultMessage.data;
//        NSString *currentFileID = [currentDataDictionary objectForKey:@"fileID"];
//        currentFileID = [TAPUtil nullToEmptyString:currentFileID];
//
//        //Check image exist in cache
//        if (savedImage != nil) {
//            //Image exist
//            success(savedImage, resultMessage);
//        }
//        else {
//            //Image not exist in cache
//            if ([self.currentDownloadingDictionary objectForKey:currentFileID]) {
//                return;
//            }
//
//            //check thumbnail image
//            if ([self.thumbnailDictionary objectForKey:currentFileID]) {
//                UIImage *thumbnailImage = [self.thumbnailDictionary objectForKey:currentFileID];
//                successThumbnail(thumbnailImage, resultMessage);
//                return;
//            }
//// DV NOTE - Uncomment to use queue in download
////            //run download flow
////            NSMutableArray *downloadQueueRoomArray = [self.downloadQueueDictionary objectForKey:currentRoomID];
////            if (downloadQueueRoomArray == nil) {
////                downloadQueueRoomArray = [NSMutableArray array];
////            }
////
////            if ([downloadQueueRoomArray count] > 0 && downloadQueueRoomArray != nil) {
////                //downloading in progress
////                [downloadQueueRoomArray addObject:resultMessage];
////
////               // add to temp processing dictionary
////               // set 2 for processing thumbnail and full image
////                [self.currentDownloadingDictionary setObject:[NSNumber numberWithInteger:2] forKey:currentFileID];
////
////                [self.downloadQueueDictionary setObject:downloadQueueRoomArray forKey:currentRoomID];
////            }
////            else {
////                [downloadQueueRoomArray addObject:resultMessage];
//
//                //add to temp processing dictionary
//                //set 2 for processing thumbnail and full image
//                [self.currentDownloadingDictionary setObject:[NSNumber numberWithInteger:2] forKey:currentFileID];
//
////                [self.downloadQueueDictionary setObject:downloadQueueRoomArray forKey:currentRoomID];
//
//                [self runDownloadImageWithRoomID:currentRoomID message:resultMessage progress:^(CGFloat progress, CGFloat total, TAPMessageModel *currentDownloadMessage) {
//                    progressBlock(progress, total, resultMessage);
//                } successThumbnailImage:^(UIImage *thumbnailImage, TAPMessageModel *currentDownloadMessage) {
//                    NSString *roomID = currentDownloadMessage.room.roomID;
//                    NSString *localID = currentDownloadMessage.localID;
//                    NSDictionary *dataDictionary = currentDownloadMessage.data;
//                    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
//                    fileID = [TAPUtil nullToEmptyString:fileID];
//
//                    NSLog(@"SUCCESS THUMBNAIL CALL API LOCAL ID: %@, FILE ID: %@", localID, fileID); //DV Temp
//
//                    NSInteger currentProcessingCounter = [[self.currentDownloadingDictionary objectForKey:fileID] integerValue];
//                    currentProcessingCounter -= 1;
//
//                    [self.currentDownloadingDictionary setObject:[NSNumber numberWithInteger:currentProcessingCounter] forKey:fileID];
//
//                    if (currentProcessingCounter == 0) {
//                        //done processing thumbnail and full image
//                        [self.currentDownloadingDictionary removeObjectForKey:fileID];
//                    }
//
//                    successThumbnail(thumbnailImage, currentDownloadMessage);
//                } successFullImage:^(UIImage *fullImage, TAPMessageModel *currentDownloadMessage) {
//                    NSString *roomID = currentDownloadMessage.room.roomID;
//                    NSString *localID = currentDownloadMessage.localID;
//                    NSDictionary *dataDictionary = currentDownloadMessage.data;
//                    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
//                    fileID = [TAPUtil nullToEmptyString:fileID];
//
//                    NSLog(@"SUCCESS FULL IMAGE CALL API LOCAL ID: %@, FILE ID: %@", localID, fileID); //DV Temp
//
//                    NSInteger currentProcessingCounter = [[self.currentDownloadingDictionary objectForKey:fileID] integerValue];
//                    currentProcessingCounter -= 1;
//
//                    [self.currentDownloadingDictionary setObject:[NSNumber numberWithInteger:currentProcessingCounter] forKey:fileID];
//
//                    if (currentProcessingCounter == 0) {
//                        //done processing thumbnail and full image
//                        [self.currentDownloadingDictionary removeObjectForKey:fileID];
//                    }
//
//                    success(fullImage, currentDownloadMessage);
//                } failureThumbnailImage:^(NSError *error, TAPMessageModel *currentDownloadMessage) {
//                    NSString *roomID = currentDownloadMessage.room.roomID;
//                    NSString *localID = currentDownloadMessage.localID;
//                    NSDictionary *dataDictionary = currentDownloadMessage.data;
//                    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
//                    fileID = [TAPUtil nullToEmptyString:fileID];
//
//                    NSInteger currentProcessingCounter = [[self.currentDownloadingDictionary objectForKey:fileID] integerValue];
//                    currentProcessingCounter -= 1;
//
//                    [self.currentDownloadingDictionary setObject:[NSNumber numberWithInteger:currentProcessingCounter] forKey:fileID];
//
//                    if (currentProcessingCounter == 0) {
//                        //done processing thumbnail and full image
//                        [self.currentDownloadingDictionary removeObjectForKey:fileID];
//                    }
//
//                    failureThumbnail(error, currentDownloadMessage);
//
//                } failureFullImage:^(NSError *error, TAPMessageModel *currentDownloadMessage) {
//                    NSString *roomID = currentDownloadMessage.room.roomID;
//                    NSString *localID = currentDownloadMessage.localID;
//                    NSDictionary *dataDictionary = currentDownloadMessage.data;
//                    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
//                    fileID = [TAPUtil nullToEmptyString:fileID];
//
//                    NSInteger currentProcessingCounter = [[self.currentDownloadingDictionary objectForKey:fileID] integerValue];
//                    currentProcessingCounter -= 1;
//
//                    [self.currentDownloadingDictionary setObject:[NSNumber numberWithInteger:currentProcessingCounter] forKey:fileID];
//
//                    if (currentProcessingCounter == 0) {
//                        //done processing thumbnail and full image
//                        [self.currentDownloadingDictionary removeObjectForKey:fileID];
//                    }
//
//                    failure(error, currentDownloadMessage);
//                }];
////            }
//        }
//    }];
//}
//
//- (void)runDownloadImageWithRoomID:(NSString *)roomID
//                           message:(TAPMessageModel *)message
//                          progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *currentDownloadMessage))progressBlock
//             successThumbnailImage:(void (^)(UIImage *thumbnailImage, TAPMessageModel *currentDownloadMessage))successThumbnail
//                  successFullImage:(void (^)(UIImage *fullImage, TAPMessageModel *currentDownloadMessage))success
//             failureThumbnailImage:(void(^)(NSError *error, TAPMessageModel *currentDownloadMessage))failureThumbnail
//                  failureFullImage:(void(^)(NSError *error, TAPMessageModel *currentDownloadMessage))failure {
//
//    //    NSMutableArray *downloadQueueRoomArray = [self.downloadQueueDictionary objectForKey:roomID];
//    //    if ([downloadQueueRoomArray count] == 0 || downloadQueueRoomArray == nil) {
//    //        return;
//    //    }
//
//    //Obtain first object from queue array
//    //    TAPMessageModel *currentMessage = [downloadQueueRoomArray firstObject];
//    NSDictionary *currentDataDictionary = message.data;
//    NSString *currentFileID = [currentDataDictionary objectForKey:@"fileID"];
//
//    //Call API Download Thumbnail
//    //     [TAPDataManager callAPIDownloadFileWithFileID:currentFileID roomID:roomID isThumbnail:YES completionBlock:^(UIImage *downloadedImage) {
//    //
//    //         NSData *imageData = UIImageJPEGRepresentation(downloadedImage, 1.0f);
//    //
//    //         if (downloadedImage != nil) {
//    //            [self.thumbnailDictionary setObject:downloadedImage forKey:currentFileID];
//    //         }
//    //         successThumbnail(downloadedImage, message);
//    //     } progressBlock:^(CGFloat progress, CGFloat total) {
//    //
//    //     } failureBlock:^(NSError *error) {
//    //         failureThumbnail(error, message);
//    //     }];
//
//    //Call API Download Full Image
//    //    [TAPDataManager callAPIDownloadFileWithFileID:currentFileID roomID:roomID isThumbnail:NO completionBlock:^(UIImage *downloadedImage) {
//    //
//    //        //Save image to cache
//    //        [TAPImageView saveImageToCache:downloadedImage withKey:currentFileID];
//
//    //        //Remove first object
//    //        [downloadQueueRoomArray removeObjectAtIndex:0];
//    //
//    //        if ([downloadQueueRoomArray count] == 0) {
//    //            [self.downloadQueueDictionary removeObjectForKey:roomID];
//    //        }
//    //        else {
//    //            [self.downloadQueueDictionary setObject:downloadQueueRoomArray forKey:roomID];
//    //        }
//
//    //Send back success download image
//    //        success(downloadedImage, message);
//
//    // Check if queue array is exist, run upload again
//    //        if ([downloadQueueRoomArray count] > 0) {
//    //            TAPMessageModel *nextMessage = [downloadQueueRoomArray firstObject];
//    //            NSDictionary *nextDataDictionary = nextMessage.data;
//    //            NSString *nextFileID = [nextDataDictionary objectForKey:@"fileID"];
//    //
//    //            [self runDownloadImageWithRoomID:roomID message:nextMessage progress:progressBlock successThumbnailImage:successThumbnail successFullImage:success failureThumbnailImage:failureThumbnail failureFullImage:failure];
//    //        }
//
//    //    } progressBlock:^(CGFloat progress, CGFloat total) {
//    //        progressBlock(progress, total, message);
//    //    } failureBlock:^(NSError *error) {
//    //        failure(error, message);
//    //    }];
//
//}
//
//END DV NOTE

@end
