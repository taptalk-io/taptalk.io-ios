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
@property (strong, nonatomic) NSMutableDictionary *downloadProgressDictionary;
@property (strong, nonatomic) NSMutableDictionary *currentDownloadingDictionary;
@property (strong, nonatomic) NSMutableDictionary *downloadedFilePathDictionary;
@property (strong, nonatomic) NSMutableDictionary *failedDownloadDictionary;

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
        _downloadProgressDictionary = [[NSMutableDictionary alloc] init];
        _currentDownloadingDictionary = [[NSMutableDictionary alloc] init];
        _downloadedFilePathDictionary = [[NSMutableDictionary alloc] init];
        _failedDownloadDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Custom Method
- (void)receiveImageDataWithMessage:(TAPMessageModel *)message
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
            
            CGFloat progress = 1.0f;
            CGFloat total = 1.0f;
            NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
            [objectDictionary setObject:resultMessage forKey:@"message"];
            [objectDictionary setObject:savedImage forKey:@"fullImage"];
            [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
            [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:objectDictionary];
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
            
            NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
            [objectDictionary setObject:resultMessage forKey:@"message"];
            [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:objectDictionary];
            
            [self runDownloadImageWithRoomID:currentRoomID message:resultMessage progress:^(CGFloat progress, CGFloat total, TAPMessageModel *currentDownloadMessage) {
                
                NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                [objectDictionary setObject:resultMessage forKey:@"message"];
                [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
                [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                
                [self.downloadProgressDictionary setObject:objectDictionary forKey:currentDownloadMessage.localID];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:objectDictionary];
                
                progressBlock(progress, total, resultMessage);
            } success:^(UIImage *fullImage, TAPMessageModel *currentDownloadMessage) {
                dispatch_async(dispatch_get_main_queue(), ^{
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
                    
                    if (fullImage != nil) {
                        CGFloat progress = 1.0f;
                        CGFloat total = 1.0f;
                        NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                        [objectDictionary setObject:currentDownloadMessage forKey:@"message"];
                        [objectDictionary setObject:fullImage forKey:@"fullImage"];
                        [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
                        [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:objectDictionary];
                        
                        success(fullImage, currentDownloadMessage);
                    }
                });
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
                
                [self.downloadProgressDictionary removeObjectForKey:currentDownloadMessage.localID];
                
                NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                [objectDictionary setObject:currentDownloadMessage forKey:@"message"];
                [objectDictionary setObject:error forKey:@"error"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:objectDictionary];

                failure(error, currentDownloadMessage);
            }];
        }
    }];
}

- (void)receiveFileDataWithMessage:(TAPMessageModel *)message
                             start:(void(^)(TAPMessageModel *receivedMessage))startProgress
                          progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
                           success:(void (^)(NSData *fileData, TAPMessageModel *receivedMessage))success
                           failure:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure {
    NSDictionary *currentDataDictionary = message.data;
    NSString *currentFileID = [currentDataDictionary objectForKey:@"fileID"];
    
    //Call API Download File
    startProgress(message);
    
    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
    [objectDictionary setObject:message forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:objectDictionary];
    
    [TAPDataManager callAPIDownloadFileWithFileID:currentFileID
                                           roomID:message.room.roomID completionBlock:^(NSData *downloadedData) {
                                               //CS Note
                                               //Store downloaded data to local storage
                                               
                                               NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                               NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
                                               
                                               NSString *destinationFilePath =  [documentsDirectory stringByAppendingPathComponent:@"/Files"];
                                               
                                               if (![[NSFileManager defaultManager] fileExistsAtPath:destinationFilePath]) {
                                                   [[NSFileManager defaultManager] createDirectoryAtPath:destinationFilePath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
                                               }
                                               
                                               NSString *fileName = [message.data objectForKey:@"fileName"];
                                               fileName = [TAPUtil nullToEmptyString:fileName];
                                               
                                               if ([fileName isEqualToString:@""]) {
                                                   
                                                   NSDate *currentDate = [NSDate date];
                                                   NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
                                                   NSString *timestamp = [NSString stringWithFormat:@"%f", currentTimeInterval];
                                                   
                                                   NSString *fileExtension = @"";
                                                   if ([fileExtension isEqualToString:@""]) {
                                                       fileExtension = [message.data objectForKey:@"mediaType"];
                                                       fileExtension = [TAPUtil nullToEmptyString:fileExtension];
                                                       fileExtension = [fileExtension lastPathComponent];
                                                   }

                                                   fileName = [NSString stringWithFormat:@"%@.%@", timestamp, fileExtension];
                                               }
                                               
                                               destinationFilePath = [destinationFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
                                               
                                               NSString *destinationFileString = [TAPUtil getNewFileAndCheckExistingFilePath:destinationFilePath
                                                                                                     fileNameCounterStart:0];
                                               
                                               [downloadedData writeToFile:destinationFileString atomically:YES];

                                               [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToDictionaryWithFilePath:destinationFileString roomID:message.room.roomID fileID:currentFileID];
                                                [self.failedDownloadDictionary removeObjectForKey:message.localID];
                                               
                                               [self.downloadProgressDictionary removeObjectForKey:message.localID];
                                               
                                               CGFloat progress = 1.0f;
                                               CGFloat total = 1.0f;
                                               NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                                               [objectDictionary setObject:message forKey:@"message"];
                                               [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
                                               [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                                               
                                               [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:objectDictionary];
                                               
                                               success(downloadedData, message);
                                           } progressBlock:^(CGFloat progress, CGFloat total) {
                                               
                                               NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                                               [objectDictionary setObject:message forKey:@"message"];
                                               [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
                                               [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                                               [self.downloadProgressDictionary setObject:objectDictionary forKey:message.localID];
                                               
                                               [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:objectDictionary];
                                               
                                               progressBlock(progress, total, message);
                                           } failureBlock:^(NSError *error) {
                                               failure(error, message);
                                               [self.failedDownloadDictionary setObject:message forKey:message.localID];
                                               
                                               [self.downloadProgressDictionary removeObjectForKey:message.localID];
                                               
                                               NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                                               [objectDictionary setObject:message forKey:@"message"];
                                               [objectDictionary setObject:error forKey:@"error"];
                                               
                                               [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:objectDictionary];
                                           }];
}

- (void)receiveVideoDataWithMessage:(TAPMessageModel *)message
                              start:(void(^)(TAPMessageModel *receivedMessage))startProgress
                           progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
                            success:(void (^)(NSData *fileData, TAPMessageModel *receivedMessage))success
                            failure:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure {
    NSDictionary *currentDataDictionary = message.data;
    NSString *currentFileID = [currentDataDictionary objectForKey:@"fileID"];
    
    //Call API Download File
    startProgress(message);
    
    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
    [objectDictionary setObject:message forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:objectDictionary];
    
    [TAPDataManager callAPIDownloadFileWithFileID:currentFileID roomID:message.room.roomID completionBlock:^(NSData *downloadedData) {
        //CS Note
        //Store downloaded data to local storage
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        
        NSString *destinationFilePath =  [documentsDirectory stringByAppendingPathComponent:@"/Videos"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:destinationFilePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:destinationFilePath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
        }
        
        NSString *fileName = [message.data objectForKey:@"fileName"];
        fileName = [TAPUtil nullToEmptyString:fileName];
        
        if ([fileName isEqualToString:@""]) {
            
            NSDate *currentDate = [NSDate date];
            NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
            NSString *timestamp = [NSString stringWithFormat:@"%f", currentTimeInterval];
            
            NSString *fileExtension = @"";
            if ([fileExtension isEqualToString:@""]) {
                fileExtension = [message.data objectForKey:@"mediaType"];
                fileExtension = [TAPUtil nullToEmptyString:fileExtension];
                fileExtension = [fileExtension lastPathComponent];
            }
            
            fileName = [NSString stringWithFormat:@"%@.%@", timestamp, fileExtension];
        }
        
        destinationFilePath = [destinationFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
        
        NSString *destinationFileString = [TAPUtil getNewFileAndCheckExistingFilePath:destinationFilePath
                                                                 fileNameCounterStart:0];
        
        [downloadedData writeToFile:destinationFileString atomically:YES];
        
        [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToDictionaryWithFilePath:destinationFileString roomID:message.room.roomID fileID:currentFileID];
        [self.failedDownloadDictionary removeObjectForKey:message.localID];
        
        //Get thumbnail image for video
        [TAPImageView imageFromCacheWithKey:currentFileID success:^(UIImage *savedImage) {
           if (savedImage == nil) {
               NSURL *url = [NSURL fileURLWithPath:destinationFilePath];
               AVAsset *asset = [AVAsset assetWithURL:url];
               UIImage *thumbnailVideoImage = [[TAPFetchMediaManager sharedManager] generateThumbnailImageFromFilePathString:destinationFilePath];
               [TAPImageView saveImageToCache:thumbnailVideoImage withKey:currentFileID];
           }

           success(downloadedData, message);
            
            [self.downloadProgressDictionary removeObjectForKey:message.localID];
            
            CGFloat progress = 1.0f;
            CGFloat total = 1.0f;
            NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
            [objectDictionary setObject:message forKey:@"message"];
            [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
            [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:objectDictionary];
        }];
        
    } progressBlock:^(CGFloat progress, CGFloat total) {
        
        NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
        [objectDictionary setObject:message forKey:@"message"];
        [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
        [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
        
        [self.downloadProgressDictionary setObject:objectDictionary forKey:message.localID];
        
         [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:objectDictionary];
        
        progressBlock(progress, total, message);
    } failureBlock:^(NSError *error) {
        failure(error, message);
        [self.failedDownloadDictionary setObject:message forKey:message.localID];
        
        NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
        [objectDictionary setObject:message forKey:@"message"];
        [objectDictionary setObject:error forKey:@"error"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:objectDictionary];
        
        [self.downloadProgressDictionary removeObjectForKey:message.localID];

    }];
};

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

- (void)saveDownloadedFilePathToDictionaryWithFilePath:(NSString *)filePath roomID:(NSString *)roomID fileID:(NSString *)fileID {
    if (self.downloadedFilePathDictionary == nil) {
        self.downloadedFilePathDictionary = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary *downloadedFilePathPerRoomDictionary = [[self.downloadedFilePathDictionary objectForKey:roomID] mutableCopy];
    
    if (downloadedFilePathPerRoomDictionary == nil || [downloadedFilePathPerRoomDictionary count] == 0) {
        downloadedFilePathPerRoomDictionary = [[NSMutableDictionary alloc] init];
    }
    
    [downloadedFilePathPerRoomDictionary setObject:filePath forKey:fileID];
    [self.downloadedFilePathDictionary setObject:downloadedFilePathPerRoomDictionary forKey:roomID];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        //save directly to DB when in background
        [self saveDownloadedFilePathToPreference];
    }
}

- (NSString *)getDownloadedFilePathWithRoomID:(NSString *)roomID fileID:(NSString *)fileID {
    NSDictionary *downloadedFilePathPerRoomDictionary = [self.downloadedFilePathDictionary objectForKey:roomID];
    downloadedFilePathPerRoomDictionary = [TAPUtil nullToEmptyDictionary:downloadedFilePathPerRoomDictionary];
    
    NSString *filePath = @"";
    if ([downloadedFilePathPerRoomDictionary count] != 0) {
        filePath = [downloadedFilePathPerRoomDictionary objectForKey:fileID];
    }
    
    return filePath;
}

- (void)fetchDownloadedFilePathFromPreference {
    NSDictionary *savedDictionary = [[NSUserDefaults standardUserDefaults] secureDictionaryForKey:TAP_PREFS_FILE_PATH_DICTIONARY valid:nil];
    
    if (self.downloadedFilePathDictionary == nil) {
        _downloadedFilePathDictionary = [[NSMutableDictionary alloc] init];
    }
    
    _downloadedFilePathDictionary = [savedDictionary mutableCopy];
}

- (void)saveDownloadedFilePathToPreference {
    NSDictionary *savedDictionary = [self.downloadedFilePathDictionary copy];
    
    [[NSUserDefaults standardUserDefaults] setSecureObject:savedDictionary forKey:TAP_PREFS_FILE_PATH_DICTIONARY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)cancelDownloadWithMessage:(TAPMessageModel *)message {
    NSString *fileID = [message.data objectForKey:@"fileID"];
    fileID = [TAPUtil nullToEmptyString:fileID];
    [[TAPNetworkManager sharedManager] cancelDownloadWithFileID:fileID];
}

- (BOOL)checkFailedDownloadWithLocalID:(NSString *)localID {
    if ([self.failedDownloadDictionary objectForKey:localID]) {
        return YES;
    }
    return NO;
}

- (void)saveVideoToLocalDirectoryWithAsset:(AVAsset *)videoAsset message:(TAPMessageModel *)message {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    NSString *destinationFilePath =  [documentsDirectory stringByAppendingPathComponent:@"/Videos"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationFilePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:destinationFilePath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    }
    
    NSString *fileName = [message.data objectForKey:@"fileName"];
    fileName = [TAPUtil nullToEmptyString:fileName];
    
    if ([fileName isEqualToString:@""]) {
        NSDate *currentDate = [NSDate date];
        NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
        NSString *timestamp = [NSString stringWithFormat:@"%f", currentTimeInterval];
        
        NSString *fileExtension = @"";
        if ([fileExtension isEqualToString:@""]) {
            fileExtension = [message.data objectForKey:@"mediaType"];
            fileExtension = [TAPUtil nullToEmptyString:fileExtension];
            fileExtension = [fileExtension lastPathComponent];
        }
        
        fileName = [NSString stringWithFormat:@"%@.%@", timestamp, fileExtension];
    }
    
    destinationFilePath = [destinationFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
    
    NSString *destinationFileString = [TAPUtil getNewFileAndCheckExistingFilePath:destinationFilePath
                                                             fileNameCounterStart:0];
    
    NSURL *fileURL = nil;
    __block NSData *assetData = nil;
    
    // asset is you AVAsset object
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = fileURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        assetData = [NSData dataWithContentsOfURL:fileURL];
        [assetData writeToFile:destinationFileString atomically:YES];
//        [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToDictionaryWithFilePath:destinationFileString roomID:message.room.roomID localID:message.localID];
    }];
}

- (void)clearFileDownloadManagerData {
    [self.thumbnailDictionary removeAllObjects];
    [self.downloadProgressDictionary removeAllObjects];
    [self.currentDownloadingDictionary removeAllObjects];
    [self.downloadedFilePathDictionary removeAllObjects];
    [self.failedDownloadDictionary removeAllObjects];
}

// DV NOTE - Uncomment this function to use API Thumbnail image
//- (void)receiveImageDataWithMessage:(TAPMessageModel *)message
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
