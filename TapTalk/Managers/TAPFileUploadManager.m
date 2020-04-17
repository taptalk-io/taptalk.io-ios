//
//  TAPFileUploadManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 05/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPFileUploadManager.h"
#import "TAPFetchMediaManager.h"
#import "TAPDataMediaModel.h"
#import "TAPDataFileModel.h"

#import <TapTalk/Base64.h>
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import <CoreServices/UTType.h>

@import AFNetworking;

@interface TAPFileUploadManager ()

@property (strong, nonatomic) NSMutableDictionary *uploadQueueDictionary;
@property (strong, nonatomic) NSMutableDictionary *uploadProgressDictionary;
@property (strong, nonatomic) NSMutableDictionary *pendingUploadAssetDictionary;

- (void)runUploadImageWithRoomID:(NSString *)roomID;
- (void)runUploadFileWithRoomID:(NSString *)roomID;
- (void)runUploadImageAsAssetWithRoomID:(NSString *)roomID;
- (void)runUploadVideoAsAssetWithRoomID:(NSString *)roomID;

- (TAPDataMediaModel *)convertDictionaryToDataMediaModel:(NSDictionary *)dictionary;
- (NSDictionary *)convertDataMediaModelToDictionary:(TAPDataMediaModel *)dataImage;
- (TAPDataFileModel *)convertDictionaryToDataFileModel:(NSDictionary *)dictionary;
- (NSDictionary *)convertDataFileModelToDictionary:(TAPDataFileModel *)dataFile;

- (void)resizeImage:(UIImage *)image message:(TAPMessageModel *)message maxImageSize:(CGFloat)maxImageSize success:(void (^)(UIImage *resizedImage, TAPMessageModel *resultMessage))success;
@end

@implementation TAPFileUploadManager
#pragma mark - Lifecycle
+ (TAPFileUploadManager *)sharedManager {
    static TAPFileUploadManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _uploadQueueDictionary = [[NSMutableDictionary alloc] init];
        _uploadProgressDictionary = [[NSMutableDictionary alloc] init];
        _pendingUploadAssetDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Custom Method
- (void)sendFileWithData:(TAPMessageModel *)message {
    
    NSString *roomID = message.room.roomID;
    if (roomID == nil || [roomID isEqualToString:@""]) {
        return;
    }
    
    NSMutableArray *uploadQueueRoomArray = [self.uploadQueueDictionary objectForKey:roomID];
    if (uploadQueueRoomArray == nil) {
        uploadQueueRoomArray = [NSMutableArray array];
    }
    
    if ([uploadQueueRoomArray count] > 0 && uploadQueueRoomArray != nil) {
        //uploading in progress
        [uploadQueueRoomArray addObject:message];
        [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:roomID];
    }
    else {
        [uploadQueueRoomArray addObject:message];
        [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:roomID];
        
        if (message.type == TAPChatMessageTypeImage) {
            //Upload image
            [self runUploadImageWithRoomID:message.room.roomID];
        }
        else if (message.type == TAPChatMessageTypeFile) {
            //Upload File
            [self runUploadFileWithRoomID:message.room.roomID];
        }
    }
}

- (void)sendFileAsAssetWithData:(TAPMessageModel *)message {
    
    NSString *roomID = message.room.roomID;
    if (roomID == nil || [roomID isEqualToString:@""]) {
        return;
    }
    
    NSMutableArray *uploadQueueRoomArray = [self.uploadQueueDictionary objectForKey:roomID];
    if (uploadQueueRoomArray == nil) {
        uploadQueueRoomArray = [NSMutableArray array];
    }
    
    if ([uploadQueueRoomArray count] > 0 && uploadQueueRoomArray != nil) {
        //uploading in progress
        [uploadQueueRoomArray addObject:message];
        [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:roomID];
    }
    else {
        [uploadQueueRoomArray addObject:message];
        [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:roomID];
        
        if (message.type == TAPChatMessageTypeImage) {
            //Upload image
            [self runUploadImageAsAssetWithRoomID:message.room.roomID];
        }
        else if (message.type == TAPChatMessageTypeVideo) {
            //Upload Video
            [self runUploadVideoAsAssetWithRoomID:message.room.roomID];
        }
    }
}

- (void)runUploadImageWithRoomID:(NSString *)roomID {
    //Function for upload image from UIImage source, use runUploadImageAsAssetWithRoomID if source is PHAsset
    
    NSMutableArray *uploadQueueRoomArray = [self.uploadQueueDictionary objectForKey:roomID];
    if ([uploadQueueRoomArray count] == 0 || uploadQueueRoomArray == nil) {
        return;
    }
    
    //Obtain first object from queue array
    TAPMessageModel *currentMessage = [uploadQueueRoomArray firstObject];
    NSDictionary *dataDictionary = [NSDictionary dictionary];
    dataDictionary = currentMessage.data;

    NSString *captionString = [dataDictionary objectForKey:@"caption"];
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    //Convert data dictionary to model
    TAPDataMediaModel *dataImage = [TAPDataMediaModel new];
    dataImage = [self convertDictionaryToDataMediaModel:dataDictionary];
    
    //Get dummy image from cache
    [TAPImageView imageFromCacheWithKey:currentMessage.localID message:currentMessage success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
        
        //Resize image
        [self resizeImage:savedImage message:resultMessage maxImageSize:TAP_MAX_IMAGE_LARGE_SIZE success:^(UIImage *resizedImage, TAPMessageModel *resultMessage) {
            
//            dataImage.dummyImage = resizedImage;
            
            __block UIImage *resultImage = resizedImage;
            
            //Save resized dummy image to localID cache
            [TAPImageView saveImageToCache:resizedImage withKey:resultMessage.localID];
            
            //Convert dummy image to image data
            NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.6f);
            
            //Call API Upload File
            NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
            [objectDictionary setObject:currentMessage forKey:@"message"];
            [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_START object:objectDictionary];

            NSURLSessionUploadTask *uploadTask = [TAPDataManager callAPIUploadFileWithFileData:imageData roomID:currentMessage.room.roomID fileName:@"images.png" fileType:@"image" mimeType:@"image/jpeg" caption:captionString completionBlock:^(NSDictionary *responseObject) {
                
                //resize to 20x20 for thumbnail
                [self resizeImage:savedImage message:resultMessage maxImageSize:TAP_MAX_THUMBNAIL_IMAGE_SIZE success:^(UIImage *resizedImage, TAPMessageModel *resultMessage) {
                        
                    NSData *thumbnailImageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
                    NSString *thumbnailImageBase64String = [thumbnailImageData base64EncodedString];
                    
                    NSDictionary *responseDataDictionary = [responseObject objectForKey:@"data"];
                    
                    NSMutableDictionary *resultDataDictionary = [NSMutableDictionary dictionary];
                    
                    NSString *mediaType = [responseDataDictionary objectForKey:@"mediaType"];
                    mediaType = [TAPUtil nullToEmptyString:mediaType];
                    
                    NSString *fileID = [responseDataDictionary objectForKey:@"id"];
                    fileID = [TAPUtil nullToEmptyString:fileID];
                    
                    if ([mediaType hasPrefix:@"image"]) {
                        NSString *caption = [responseDataDictionary objectForKey:@"caption"];
                        caption = [TAPUtil nullToEmptyString:caption];
                        
                        NSString *sizeRaw = [responseDataDictionary objectForKey:@"size"];
                        sizeRaw = [TAPUtil nullToEmptyString:sizeRaw];
                        NSString *sizeString = [NSString stringWithFormat:@"%f", [sizeRaw floatValue]];
                        NSNumber *sizeNumber = [NSNumber numberWithFloat:[sizeString floatValue]];
                        
                        NSString *heightRaw = [responseDataDictionary objectForKey:@"height"];
                        heightRaw = [TAPUtil nullToEmptyString:heightRaw];
                        NSString *heightString = [NSString stringWithFormat:@"%f", [heightRaw floatValue]];
                        NSNumber *heightNumber = [NSNumber numberWithFloat:[heightString floatValue]];
                        
                        NSString *widthRaw = [responseDataDictionary objectForKey:@"width"];
                        widthRaw = [TAPUtil nullToEmptyString:widthRaw];
                        NSString *widthString = [NSString stringWithFormat:@"%f", [widthRaw floatValue]];
                        NSNumber *widthNumber = [NSNumber numberWithFloat:[widthString floatValue]];
                        
                        [resultDataDictionary setObject:caption forKey:@"caption"];
                        [resultDataDictionary setObject:sizeNumber forKey:@"size"];
                        [resultDataDictionary setObject:heightNumber forKey:@"height"];
                        [resultDataDictionary setObject:widthNumber forKey:@"width"];
                    }
                    
                    [resultDataDictionary setObject:mediaType forKey:@"mediaType"];
                    [resultDataDictionary setObject:fileID forKey:@"fileID"];
                    [resultDataDictionary setObject:thumbnailImageBase64String forKey:@"thumbnail"];
                    resultMessage.data = resultDataDictionary;
                    
                    //Remove from waiting upload dictionary in ChatManager
                    [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:resultMessage];
                    
                    //Save image to cache
                    [TAPImageView saveImageToCache:resultImage withKey:fileID];
                    
                    //Remove dummy image with localID key from cache
                    [TAPImageView removeImageFromCacheWithKey:resultMessage.localID];
                    
                    //Send emit
                    [[TAPChatManager sharedManager] sendEmitFileMessage:resultMessage];
                    
                    //Remove first object
                    [uploadQueueRoomArray removeObjectAtIndex:0];
                    
                    if ([uploadQueueRoomArray count] == 0) {
                        [self.uploadQueueDictionary removeObjectForKey:resultMessage.room.roomID];
                    }
                    else {
                        [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:resultMessage.room.roomID];
                    }
                    
                    CGFloat progress = 1.0f;
                    CGFloat total = 1.0f;
                    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                    [objectDictionary setObject:resultMessage forKey:@"message"];
                    [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
                    [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                    
                    [self.uploadProgressDictionary removeObjectForKey:currentMessage.localID];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:objectDictionary];
                    
                    // Check if queue array is exist, run upload again
                    if ([uploadQueueRoomArray count] > 0) {
                        TAPMessageModel *nextUploadMessage = [uploadQueueRoomArray firstObject];
                        NSString *nextRoomID = nextUploadMessage.room.roomID;
                        
                        if (nextUploadMessage.type == TAPChatMessageTypeImage) {
                            NSDictionary *dataDictionary = [NSDictionary dictionary];
                            dataDictionary = nextUploadMessage.data;
                            
                            //Convert data dictionary to model
                            TAPDataMediaModel *mediaData = [TAPDataMediaModel new];
                            mediaData = [self convertDictionaryToDataMediaModel:dataDictionary];
                            
                            if (mediaData.asset == nil) {
                                //upload UIImage
                                [self runUploadImageWithRoomID:nextRoomID];
                            }
                            else {
                                //Upload PHAsset
                                [self runUploadImageAsAssetWithRoomID:nextRoomID];
                            }
                        }
                        else if (nextUploadMessage.type == TAPChatMessageTypeVideo) {
                            [self runUploadVideoAsAssetWithRoomID:nextRoomID];
                        }
                        else if (nextUploadMessage.type == TAPChatMessageTypeFile) {
                            [self runUploadFileWithRoomID:nextRoomID];
                        }

                    }
                }];
                
            } progressBlock:^(CGFloat progress, CGFloat total) {
                NSMutableDictionary *obtainedDictionary = [NSMutableDictionary dictionary];
                obtainedDictionary = [self.uploadProgressDictionary objectForKey:currentMessage.localID];
                if (obtainedDictionary == nil) {
                    obtainedDictionary = [NSMutableDictionary dictionary];
                }
                
                [obtainedDictionary setObject:currentMessage forKey:@"message"];
                [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
                [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                
                [self.uploadProgressDictionary setObject:obtainedDictionary forKey:currentMessage.localID];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:obtainedDictionary];
                
            } failureBlock:^(NSError *error) {
                
                NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                [objectDictionary setObject:currentMessage forKey:@"message"];
                [objectDictionary setObject:error forKey:@"error"];
                
                TAPMessageModel *obtainedMesage = [[TAPChatManager sharedManager] getMessageFromWaitingUploadDictionaryWithKey:currentMessage.localID];
                if (obtainedMesage != nil) {
                    
                    //Update isFailedSend to 1 and isSending to 0
                    [[TAPChatManager sharedManager] updateMessageToFailedWithLocalID:currentMessage.localID];
                    
                    //Remove first object
                    if ([uploadQueueRoomArray count] > 0) {
                        
                        [uploadQueueRoomArray removeObjectAtIndex:0];
                        
                        if ([uploadQueueRoomArray count] == 0) {
                            [self.uploadQueueDictionary removeObjectForKey:currentMessage.room.roomID];
                        }
                        else {
                            [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:currentMessage.room.roomID];
                        }
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:objectDictionary];
                
                [self.uploadProgressDictionary removeObjectForKey:currentMessage.localID];
            }];
            

            NSMutableDictionary *obtainedDictionary = [NSMutableDictionary dictionary];
            obtainedDictionary = [self.uploadProgressDictionary objectForKey:currentMessage.localID];
            if (obtainedDictionary == nil) {
                obtainedDictionary = [NSMutableDictionary dictionary];
            }
            [obtainedDictionary setObject:uploadTask forKey:@"uploadTask"];
            [self.uploadProgressDictionary setObject:obtainedDictionary forKey:currentMessage.localID];
            
        }];
    }];
}

- (void)runUploadFileWithRoomID:(NSString *)roomID {
    
    NSMutableArray *uploadQueueRoomArray = [self.uploadQueueDictionary objectForKey:roomID];
    if ([uploadQueueRoomArray count] == 0 || uploadQueueRoomArray == nil) {
        return;
    }
    
    //Obtain first object from queue array
    TAPMessageModel *currentMessage = [uploadQueueRoomArray firstObject];
    NSDictionary *dataDictionary = [NSDictionary dictionary];
    dataDictionary = currentMessage.data;
    
    //Convert data dictionary to model
    TAPDataFileModel *dataFile = [TAPDataFileModel new];
    dataFile = [self convertDictionaryToDataFileModel:dataDictionary];
    
    NSString *filePath = [dataDictionary objectForKey:@"filePath"];
    NSURL *fileUrl = [NSURL URLWithString:filePath];
    NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
    
    //Call API Upload File
    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
    [objectDictionary setObject:currentMessage forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_START object:objectDictionary];

    NSURLSessionUploadTask *uploadTask = [TAPDataManager callAPIUploadFileWithFileData:fileData roomID:currentMessage.room.roomID fileName:dataFile.fileName fileType:@"file" mimeType:dataFile.mediaType caption:@"" completionBlock:^(NSDictionary *responseObject) {
        
        NSDictionary *responseDataDictionary = [responseObject objectForKey:@"data"];
        
        NSMutableDictionary *resultDataDictionary = [NSMutableDictionary dictionary];
        
        NSString *mediaType = [responseDataDictionary objectForKey:@"mediaType"];
        mediaType = [TAPUtil nullToEmptyString:mediaType];
        
        NSString *fileID = [responseDataDictionary objectForKey:@"id"];
        fileID = [TAPUtil nullToEmptyString:fileID];
        
        NSString *fileName = dataFile.fileName;
        
        NSString *sizeRaw = [responseDataDictionary objectForKey:@"size"];
        sizeRaw = [TAPUtil nullToEmptyString:sizeRaw];
        CGFloat size = [sizeRaw doubleValue];
        NSNumber *sizeNum = [NSNumber numberWithDouble:size];
        
        [resultDataDictionary setObject:mediaType forKey:@"mediaType"];
        [resultDataDictionary setObject:fileID forKey:@"fileID"];
        [resultDataDictionary setObject:fileName forKey:@"fileName"];
        [resultDataDictionary setObject:sizeNum forKey:@"size"];
        currentMessage.data = resultDataDictionary;

        //Remove from waiting upload dictionary in ChatManager
        [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:currentMessage];

        //Save file path to cache
        [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToDictionaryWithFilePath:fileUrl.path roomID:currentMessage.room.roomID fileID:fileID];
        
        //Send emit
        [[TAPChatManager sharedManager] sendEmitFileMessage:currentMessage];

        //Remove first object
        [uploadQueueRoomArray removeObjectAtIndex:0];

        if ([uploadQueueRoomArray count] == 0) {
            [self.uploadQueueDictionary removeObjectForKey:currentMessage.room.roomID];
        }
        else {
            [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:currentMessage.room.roomID];
        }

        CGFloat progress = 1.0f;
        CGFloat total = 1.0f;
        NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
        [objectDictionary setObject:currentMessage forKey:@"message"];
        [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
        [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];

        [self.uploadProgressDictionary removeObjectForKey:currentMessage.localID];

        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:objectDictionary];

        // Check if queue array is exist, run upload again
        if ([uploadQueueRoomArray count] > 0) {
            TAPMessageModel *nextUploadMessage = [uploadQueueRoomArray firstObject];
            NSString *nextRoomID = nextUploadMessage.room.roomID;
            
            if (nextUploadMessage.type == TAPChatMessageTypeImage) {
                NSDictionary *dataDictionary = [NSDictionary dictionary];
                dataDictionary = nextUploadMessage.data;
                
                //Convert data dictionary to model
                TAPDataMediaModel *mediaData = [TAPDataMediaModel new];
                mediaData = [self convertDictionaryToDataMediaModel:dataDictionary];
                
                if (mediaData.asset == nil) {
                    //upload UIImage
                    [self runUploadImageWithRoomID:nextRoomID];
                }
                else {
                    //Upload PHAsset
                    [self runUploadImageAsAssetWithRoomID:nextRoomID];
                }
            }
            else if (nextUploadMessage.type == TAPChatMessageTypeVideo) {
                [self runUploadVideoAsAssetWithRoomID:nextRoomID];
            }
            else if (nextUploadMessage.type == TAPChatMessageTypeFile) {
                [self runUploadFileWithRoomID:nextRoomID];
            }

        }
        
    } progressBlock:^(CGFloat progress, CGFloat total) {
        NSMutableDictionary *obtainedDictionary = [NSMutableDictionary dictionary];
        obtainedDictionary = [self.uploadProgressDictionary objectForKey:currentMessage.localID];
        if (obtainedDictionary == nil) {
            obtainedDictionary = [NSMutableDictionary dictionary];
        }
        
        [obtainedDictionary setObject:currentMessage forKey:@"message"];
        [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
        [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
        
        [self.uploadProgressDictionary setObject:obtainedDictionary forKey:currentMessage.localID];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:obtainedDictionary];
        
    } failureBlock:^(NSError *error) {
        
        NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
        [objectDictionary setObject:currentMessage forKey:@"message"];
        [objectDictionary setObject:error forKey:@"error"];
        
        TAPMessageModel *obtainedMesage = [[TAPChatManager sharedManager] getMessageFromWaitingUploadDictionaryWithKey:currentMessage.localID];
        if (obtainedMesage != nil) {
            
            //Update isFailedSend to 1 and isSending to 0
            [[TAPChatManager sharedManager] updateMessageToFailedWithLocalID:currentMessage.localID];
            
            //Remove first object
            if ([uploadQueueRoomArray count] > 0) {
                [uploadQueueRoomArray removeObjectAtIndex:0];
                
                if ([uploadQueueRoomArray count] == 0) {
                    [self.uploadQueueDictionary removeObjectForKey:currentMessage.room.roomID];
                }
                else {
                    [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:currentMessage.room.roomID];
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:objectDictionary];
        
        [self.uploadProgressDictionary removeObjectForKey:currentMessage.localID];
    }];
    
    NSMutableDictionary *obtainedDictionary = [NSMutableDictionary dictionary];
    obtainedDictionary = [self.uploadProgressDictionary objectForKey:currentMessage.localID];
    if (obtainedDictionary == nil) {
        obtainedDictionary = [NSMutableDictionary dictionary];
    }
    [obtainedDictionary setObject:uploadTask forKey:@"uploadTask"];
    [self.uploadProgressDictionary setObject:obtainedDictionary forKey:currentMessage.localID];
}

- (void)runUploadImageAsAssetWithRoomID:(NSString *)roomID {
    //Function for upload image from PHAsset source, use runUploadImageWithRoomID if source is UIImage
    
    NSMutableArray *uploadQueueRoomArray = [self.uploadQueueDictionary objectForKey:roomID];
    if ([uploadQueueRoomArray count] == 0 || uploadQueueRoomArray == nil) {
        return;
    }
    
    //Obtain first object from queue array
    TAPMessageModel *currentMessage = [uploadQueueRoomArray firstObject];
    NSDictionary *dataDictionary = [NSDictionary dictionary];
    dataDictionary = currentMessage.data;
    
    NSString *captionString = [dataDictionary objectForKey:@"caption"];
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    //Convert data dictionary to model
    TAPDataMediaModel *mediaData = [TAPDataMediaModel new];
    mediaData = [self convertDictionaryToDataMediaModel:dataDictionary];
    
    //Notify start upload flow
    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
    [objectDictionary setObject:currentMessage forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_START object:objectDictionary];
    
    //Fetch image from PHAsset
    [[TAPFetchMediaManager sharedManager] fetchImageDataForAsset:mediaData.asset progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull dictionary) {
        
#ifdef DEBUG
        NSLog(@"====== PROGRESS DOWNLOAD IMAGE %f", progress);
#endif
        
        //fetch image for asset is max 20% of total progress (80% for upload)
        CGFloat fetchDataProgress = (CGFloat)progress * 20 / 100;
        CGFloat totalProgress = 1.0f;
        
        NSMutableDictionary *obtainedDictionary = [NSMutableDictionary dictionary];
        obtainedDictionary = [self.uploadProgressDictionary objectForKey:currentMessage.localID];
        if (obtainedDictionary == nil) {
            obtainedDictionary = [NSMutableDictionary dictionary];
        }
        
        [obtainedDictionary setObject:currentMessage forKey:@"message"];
        [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", fetchDataProgress] forKey:@"progress"];
        [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", totalProgress] forKey:@"total"];

        [self.uploadProgressDictionary setObject:obtainedDictionary forKey:currentMessage.localID];
        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:obtainedDictionary];
        
    }resultHandler:^(UIImage * _Nonnull resultImage) {
        
        //Set 20% of total progress when finish fetch data
        CGFloat progress = 0.2f;
        CGFloat total = 1.0f;
        NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
        [objectDictionary setObject:currentMessage forKey:@"message"];
        [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
        [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
        
        [self.uploadProgressDictionary setObject:objectDictionary forKey:currentMessage.localID];
        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:objectDictionary];

        //Save image to cache with localID key
        [TAPImageView saveImageToCache:resultImage withKey:currentMessage.localID];
        
        //Resize image
        [self resizeImage:resultImage message:currentMessage maxImageSize:TAP_MAX_IMAGE_LARGE_SIZE success:^(UIImage *resizedImage, TAPMessageModel *resultMessage) {
            
            __block UIImage *resultImage = resizedImage;
            
            //Save resized dummy image to localID cache
            [TAPImageView saveImageToCache:resizedImage withKey:resultMessage.localID];
            
            //Convert dummy image to image data
            NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.6f);
            
            //Call API Upload File
            NSURLSessionUploadTask *uploadTask = [TAPDataManager callAPIUploadFileWithFileData:imageData roomID:currentMessage.room.roomID fileName:@"images.png" fileType:@"image" mimeType:@"image/jpeg" caption:captionString completionBlock:^(NSDictionary *responseObject) {
                
                //resize to 20x20 for thumbnail
                [self resizeImage:resultImage message:resultMessage maxImageSize:TAP_MAX_THUMBNAIL_IMAGE_SIZE success:^(UIImage *resizedImage, TAPMessageModel *resultMessage) {
                    
                    NSData *thumbnailImageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
                    NSString *thumbnailImageBase64String = [thumbnailImageData base64EncodedString];
                    
                    NSDictionary *responseDataDictionary = [responseObject objectForKey:@"data"];
                    
                    NSMutableDictionary *resultDataDictionary = [NSMutableDictionary dictionary];
                    
                    NSString *mediaType = [responseDataDictionary objectForKey:@"mediaType"];
                    mediaType = [TAPUtil nullToEmptyString:mediaType];
                    
                    NSString *fileID = [responseDataDictionary objectForKey:@"id"];
                    fileID = [TAPUtil nullToEmptyString:fileID];
                    
                    if ([mediaType hasPrefix:@"image"]) {
                        NSString *caption = [responseDataDictionary objectForKey:@"caption"];
                        caption = [TAPUtil nullToEmptyString:caption];
                        
                        NSString *sizeRaw = [responseDataDictionary objectForKey:@"size"];
                        sizeRaw = [TAPUtil nullToEmptyString:sizeRaw];
                        NSString *sizeString = [NSString stringWithFormat:@"%f", [sizeRaw floatValue]];
                        NSNumber *sizeNumber = [NSNumber numberWithFloat:[sizeString floatValue]];
                        
                        NSString *heightRaw = [responseDataDictionary objectForKey:@"height"];
                        heightRaw = [TAPUtil nullToEmptyString:heightRaw];
                        NSString *heightString = [NSString stringWithFormat:@"%f", [heightRaw floatValue]];
                        NSNumber *heightNumber = [NSNumber numberWithFloat:[heightString floatValue]];
                        
                        NSString *widthRaw = [responseDataDictionary objectForKey:@"width"];
                        widthRaw = [TAPUtil nullToEmptyString:widthRaw];
                        NSString *widthString = [NSString stringWithFormat:@"%f", [widthRaw floatValue]];
                        NSNumber *widthNumber = [NSNumber numberWithFloat:[widthString floatValue]];
                        
                        [resultDataDictionary setObject:caption forKey:@"caption"];
                        [resultDataDictionary setObject:sizeNumber forKey:@"size"];
                        [resultDataDictionary setObject:heightNumber forKey:@"height"];
                        [resultDataDictionary setObject:widthNumber forKey:@"width"];
                    }
                    
                    [resultDataDictionary setObject:mediaType forKey:@"mediaType"];
                    [resultDataDictionary setObject:fileID forKey:@"fileID"];
                    [resultDataDictionary setObject:thumbnailImageBase64String forKey:@"thumbnail"];
                    resultMessage.data = resultDataDictionary;
                    
                    //Remove from waiting upload dictionary in ChatManager
                    [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:resultMessage];
                    
                    //Save image to cache
                    [TAPImageView saveImageToCache:resultImage withKey:fileID];
                    
                    //Remove dummy image with localID key from cache
                    [TAPImageView removeImageFromCacheWithKey:resultMessage.localID];
                    
                    //Send emit
                    [[TAPChatManager sharedManager] sendEmitFileMessage:resultMessage];
                    
                    //Remove first object
                    [uploadQueueRoomArray removeObjectAtIndex:0];
                    
                    if ([uploadQueueRoomArray count] == 0) {
                        [self.uploadQueueDictionary removeObjectForKey:resultMessage.room.roomID];
                    }
                    else {
                        [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:resultMessage.room.roomID];
                    }
                    
                    CGFloat progress = 1.0f;
                    CGFloat total = 1.0f;
                    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                    [objectDictionary setObject:resultMessage forKey:@"message"];
                    [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
                    [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                    
                    [self.uploadProgressDictionary removeObjectForKey:currentMessage.localID];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:objectDictionary];
                    
                    // Check if queue array is exist, run upload again
                    if ([uploadQueueRoomArray count] > 0) {
                        TAPMessageModel *nextUploadMessage = [uploadQueueRoomArray firstObject];
                        NSString *nextRoomID = nextUploadMessage.room.roomID;

                        if (nextUploadMessage.type == TAPChatMessageTypeImage) {
                            NSDictionary *dataDictionary = [NSDictionary dictionary];
                            dataDictionary = nextUploadMessage.data;
        
                            //Convert data dictionary to model
                            TAPDataMediaModel *mediaData = [TAPDataMediaModel new];
                            mediaData = [self convertDictionaryToDataMediaModel:dataDictionary];
                            
                            if (mediaData.asset == nil) {
                                //upload UIImage
                                [self runUploadImageWithRoomID:nextRoomID];
                            }
                            else {
                                //Upload PHAsset
                                [self runUploadImageAsAssetWithRoomID:nextRoomID];
                            }
                        }
                        else if (nextUploadMessage.type == TAPChatMessageTypeVideo) {
                            [self runUploadVideoAsAssetWithRoomID:nextRoomID];
                        }
                        else if (nextUploadMessage.type == TAPChatMessageTypeFile) {
                            [self runUploadFileWithRoomID:nextRoomID];
                        }
                    }
                }];
                
            } progressBlock:^(CGFloat progress, CGFloat total) {
                
                //upload image progress is max 80% of total progress (20% for fetch asset)
                CGFloat uploadDataProgress = 0.2f + (CGFloat)(progress * 80 / 100);
                
                NSMutableDictionary *obtainedDictionary = [NSMutableDictionary dictionary];
                obtainedDictionary = [self.uploadProgressDictionary objectForKey:currentMessage.localID];
                if (obtainedDictionary == nil) {
                    obtainedDictionary = [NSMutableDictionary dictionary];
                    
                    if ([uploadQueueRoomArray count] > 0) {
                        //Remove first object
                        [uploadQueueRoomArray removeObjectAtIndex:0];
                        
                        if ([uploadQueueRoomArray count] == 0) {
                            [self.uploadQueueDictionary removeObjectForKey:resultMessage.room.roomID];
                        }
                        else {
                            [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:resultMessage.room.roomID];
                        }
                    }
                }
                
                [obtainedDictionary setObject:currentMessage forKey:@"message"];
                [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", uploadDataProgress] forKey:@"progress"];
                [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                
                [self.uploadProgressDictionary setObject:obtainedDictionary forKey:currentMessage.localID];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:obtainedDictionary];
                
            } failureBlock:^(NSError *error) {
                
                NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                [objectDictionary setObject:currentMessage forKey:@"message"];
                [objectDictionary setObject:error forKey:@"error"];
                
                TAPMessageModel *obtainedMesage = [[TAPChatManager sharedManager] getMessageFromWaitingUploadDictionaryWithKey:currentMessage.localID];
                if (obtainedMesage != nil) {
                    //Update isFailedSend to 1 and isSending to 0
                    [[TAPChatManager sharedManager] updateMessageToFailedWithLocalID:currentMessage.localID];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:objectDictionary];
                
                [self.uploadProgressDictionary removeObjectForKey:currentMessage.localID];
            }];
            
            NSMutableDictionary *obtainedDictionary = [self.uploadProgressDictionary objectForKey:currentMessage.localID];
            if (obtainedDictionary == nil) {
                obtainedDictionary = [NSMutableDictionary dictionary];
            }
            [obtainedDictionary setObject:uploadTask forKey:@"uploadTask"];
            [self.uploadProgressDictionary setObject:obtainedDictionary forKey:currentMessage.localID];
        }];
    } failureHandler:^{
        NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
        [objectDictionary setObject:currentMessage forKey:@"message"];
        
        TAPMessageModel *obtainedMesage = [[TAPChatManager sharedManager] getMessageFromWaitingUploadDictionaryWithKey:currentMessage.localID];
        if (obtainedMesage != nil) {
            //Update isFailedSend to 1 and isSending to 0
            [[TAPChatManager sharedManager] updateMessageToFailedWithLocalID:currentMessage.localID];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:objectDictionary];
        
        [self.uploadProgressDictionary removeObjectForKey:currentMessage.localID];
    }];
}

- (void)runUploadVideoAsAssetWithRoomID:(NSString *)roomID {
    //Function for upload video from PHAsset source
    
    NSMutableArray *uploadQueueRoomArray = [self.uploadQueueDictionary objectForKey:roomID];
    if ([uploadQueueRoomArray count] == 0 || uploadQueueRoomArray == nil) {
        return;
    }
    
    //Obtain first object from queue array
    TAPMessageModel *currentMessage = [uploadQueueRoomArray firstObject];
    NSDictionary *dataDictionary = [NSDictionary dictionary];
    dataDictionary = currentMessage.data;
    
    //Notify start upload flow
    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
    [objectDictionary setObject:currentMessage forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_START object:objectDictionary];
    
    NSString *thumbnailImageBase64String = [dataDictionary objectForKey:@"thumbnail"];
    NSData *thumbnailImageData = [[NSData alloc] initWithBase64EncodedString:thumbnailImageBase64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *videoThumbnailImage = [UIImage imageWithData:thumbnailImageData];

    //resize to 20x20 for thumbnail
    [self resizeImage:videoThumbnailImage message:currentMessage maxImageSize:TAP_MAX_THUMBNAIL_IMAGE_SIZE success:^(UIImage *resizedImage, TAPMessageModel *resultMessage) {
        
        NSMutableDictionary *obtainedDataDictionary = [NSMutableDictionary dictionary];
        obtainedDataDictionary = [resultMessage.data mutableCopy];
        
        NSString *captionString = [obtainedDataDictionary objectForKey:@"caption"];
        captionString = [TAPUtil nullToEmptyString:captionString];
        
        //Convert data dictionary to model
        TAPDataMediaModel *mediaData = [TAPDataMediaModel new];
        mediaData = [self convertDictionaryToDataMediaModel:obtainedDataDictionary];
        
        //Notify start upload flow
        NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
        [objectDictionary setObject:resultMessage forKey:@"message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_START object:objectDictionary];
        
        //Fetch video from PHAsset
        [[TAPFetchMediaManager sharedManager] fetchVideoDataForAsset:mediaData.asset progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull dictionary) {
            
#ifdef DEBUG
            NSLog(@"====== PROGRESS DOWNLOAD IMAGE %f", progress);
#endif
            
            //fetch image for asset is max 20% of total progress (80% for upload)
            CGFloat fetchDataProgress = (CGFloat)progress * 20 / 100;
            CGFloat totalProgress = 1.0f;

            NSMutableDictionary *obtainedDictionary = [NSMutableDictionary dictionary];
            obtainedDictionary = [self.uploadProgressDictionary objectForKey:resultMessage.localID];
            if (obtainedDictionary == nil) {
                obtainedDictionary = [NSMutableDictionary dictionary];
            }

            [obtainedDictionary setObject:resultMessage forKey:@"message"];
            [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", fetchDataProgress] forKey:@"progress"];
            [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", totalProgress] forKey:@"total"];

            [self.uploadProgressDictionary setObject:obtainedDictionary forKey:resultMessage.localID];
            [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:obtainedDictionary];
            
        } resultHandler:^(AVAsset * _Nonnull resultVideoAsset) {
            
            //Set 20% of total progress when finish fetch data
            CGFloat progress = 0.2f;
            CGFloat total = 1.0f;
            NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
            [objectDictionary setObject:resultMessage forKey:@"message"];
            [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
            [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
            
            [self.uploadProgressDictionary setObject:objectDictionary forKey:resultMessage.localID];
            [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:objectDictionary];
            
            //Get mimeType
            NSString *mimeType = @"video/quicktime"; //default mimeType
            NSString *UTI = [PHAssetResource assetResourcesForAsset:mediaData.asset].firstObject.uniformTypeIdentifier;
            if (UTI) {
                NSString *tagMimeType = (__bridge NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
                if (tagMimeType)
                    mimeType = tagMimeType;
            }
            
            //Convert AVAsset to NSData
            NSURL *fileURL = [(AVURLAsset *)resultVideoAsset URL];
            NSString *filePathString = [fileURL absoluteString];
            NSString *fileName = [filePathString lastPathComponent];
            
            __block NSData *assetData = nil;
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:resultVideoAsset presetName:AVAssetExportPresetHighestQuality];
            exportSession.outputURL = fileURL;
            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                assetData = [NSData dataWithContentsOfURL:fileURL];
                
                //Call API Upload File
                NSURLSessionUploadTask *uploadTask = [TAPDataManager callAPIUploadFileWithFileData:assetData roomID:resultMessage.room.roomID fileName:fileName fileType:@"video" mimeType:mimeType caption:captionString completionBlock:^(NSDictionary *responseObject) {
                    
                    NSDictionary *responseDataDictionary = [responseObject objectForKey:@"data"];
                    
                    NSString *fileNameString = fileName;
                
                    NSString *caption = [responseDataDictionary objectForKey:@"caption"];
                    caption = [TAPUtil nullToEmptyString:caption];
                    
                    NSString *mediaType = [responseDataDictionary objectForKey:@"mediaType"];
                    mediaType = [TAPUtil nullToEmptyString:mediaType];
                    
                    NSString *fileID = [responseDataDictionary objectForKey:@"id"];
                    fileID = [TAPUtil nullToEmptyString:fileID];
                    
                    NSString *sizeRaw = [responseDataDictionary objectForKey:@"size"];
                    sizeRaw = [TAPUtil nullToEmptyString:sizeRaw];
                    NSString *sizeString = [NSString stringWithFormat:@"%f", [sizeRaw floatValue]];
                    NSNumber *sizeNumber = [NSNumber numberWithFloat:[sizeString floatValue]];
                    
                    NSMutableDictionary *appendedDataDictionary = [[NSMutableDictionary alloc] init];
                    appendedDataDictionary = [resultMessage.data mutableCopy];
                    
                    NSData *thumbnailImageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
                    NSString *thumbnailImageBase64String = [thumbnailImageData base64EncodedString];
                    
                    [appendedDataDictionary setObject:fileNameString forKey:@"fileName"];
                    [appendedDataDictionary setObject:fileID forKey:@"fileID"];
                    [appendedDataDictionary setObject:mediaType forKey:@"mediaType"];
                    [appendedDataDictionary setObject:thumbnailImageBase64String forKey:@"thumbnail"];
                    [appendedDataDictionary setObject:sizeNumber forKey:@"size"];
                    [appendedDataDictionary setObject:caption forKey:@"caption"];
                    
//                    [appendedDataDictionary removeObjectForKey:@"asset"];
                    resultMessage.data = [appendedDataDictionary copy];
                    
                    //Remove from waiting upload dictionary in ChatManager
                    [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:resultMessage];

                    //Save video file path to cache
                    [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToDictionaryWithFilePath:filePathString roomID:resultMessage.room.roomID fileID:fileID];
                    
                    //Save video thumbnail image to cache
                    UIImage *thumbnailVideoImage = [[TAPFetchMediaManager sharedManager] generateThumbnailImageFromFilePathString:filePathString];
                    [TAPImageView saveImageToCache:thumbnailVideoImage withKey:fileID];
                    
                    //Send emit
                    [[TAPChatManager sharedManager] sendEmitFileMessage:resultMessage];
                    
                    //Remove first object
                    [uploadQueueRoomArray removeObjectAtIndex:0];
        
                    if ([uploadQueueRoomArray count] == 0) {
                        [self.uploadQueueDictionary removeObjectForKey:resultMessage.room.roomID];
                    }
                    else {
                        [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:resultMessage.room.roomID];
                    }
        
                    CGFloat progress = 1.0f;
                    CGFloat total = 1.0f;
                    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                    [objectDictionary setObject:resultMessage forKey:@"message"];
                    [objectDictionary setObject:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
                    [objectDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                    
                    [self.uploadProgressDictionary removeObjectForKey:resultMessage.localID];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:objectDictionary];
                    
                    // Check if queue array is exist, run upload again
                    if ([uploadQueueRoomArray count] > 0) {
                        TAPMessageModel *nextUploadMessage = [uploadQueueRoomArray firstObject];
                        NSString *nextRoomID = nextUploadMessage.room.roomID;
                        
                        if (nextUploadMessage.type == TAPChatMessageTypeImage) {
                            NSDictionary *dataDictionary = [NSDictionary dictionary];
                            dataDictionary = nextUploadMessage.data;
                            
                            //Convert data dictionary to model
                            TAPDataMediaModel *mediaData = [TAPDataMediaModel new];
                            mediaData = [self convertDictionaryToDataMediaModel:dataDictionary];
                            
                            if (mediaData.asset == nil) {
                                //upload UIImage
                                [self runUploadImageWithRoomID:nextRoomID];
                            }
                            else {
                                //Upload PHAsset
                                [self runUploadImageAsAssetWithRoomID:nextRoomID];
                            }
                        }
                        else if (nextUploadMessage.type == TAPChatMessageTypeVideo) {
                            [self runUploadVideoAsAssetWithRoomID:nextRoomID];
                        }
                        else if (nextUploadMessage.type == TAPChatMessageTypeFile) {
                            [self runUploadFileWithRoomID:nextRoomID];
                        }
                    }
                } progressBlock:^(CGFloat progress, CGFloat total) {
                    
                    //upload image progress is max 80% of total progress (20% for fetch asset)
                    CGFloat uploadDataProgress = 0.2f + (CGFloat)(progress * 80 / 100);
                    
                    NSMutableDictionary *obtainedDictionary = [NSMutableDictionary dictionary];
                    obtainedDictionary = [self.uploadProgressDictionary objectForKey:resultMessage.localID];
                    if (obtainedDictionary == nil) {
                        obtainedDictionary = [NSMutableDictionary dictionary];
                    }
                    
                    [obtainedDictionary setObject:resultMessage forKey:@"message"];
                    [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", uploadDataProgress] forKey:@"progress"];
                    [obtainedDictionary setObject:[NSString stringWithFormat:@"%f", total] forKey:@"total"];
                    
                    [self.uploadProgressDictionary setObject:obtainedDictionary forKey:resultMessage.localID];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:obtainedDictionary];
                    
                } failureBlock:^(NSError *error) {
                    
                    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
                    [objectDictionary setObject:resultMessage forKey:@"message"];
                    [objectDictionary setObject:error forKey:@"error"];
                    
                    TAPMessageModel *obtainedMesage = [[TAPChatManager sharedManager] getMessageFromWaitingUploadDictionaryWithKey:resultMessage.localID];
                    if (obtainedMesage != nil) {
                        
                        //Update isFailedSend to 1 and isSending to 0
                        [[TAPChatManager sharedManager] updateMessageToFailedWithLocalID:currentMessage.localID];
                        
                        if ([uploadQueueRoomArray count] > 0) {
                            //Remove first object
                            [uploadQueueRoomArray removeObjectAtIndex:0];
                            
                            if ([uploadQueueRoomArray count] == 0) {
                                [self.uploadQueueDictionary removeObjectForKey:resultMessage.room.roomID];
                            }
                            else {
                                [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:resultMessage.room.roomID];
                            }
                        }
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:objectDictionary];
                    
                    [self.uploadProgressDictionary removeObjectForKey:resultMessage.localID];
                }];
                
                NSMutableDictionary *obtainedDictionary = [NSMutableDictionary dictionary];
                if (obtainedDictionary == nil) {
                    obtainedDictionary = [NSMutableDictionary dictionary];
                }
                [obtainedDictionary setObject:uploadTask forKey:@"uploadTask"];
                [self.uploadProgressDictionary setObject:obtainedDictionary forKey:resultMessage.localID];
            }];
        } failureHandler:^{
            NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
            [objectDictionary setObject:currentMessage forKey:@"message"];
            
            TAPMessageModel *obtainedMesage = [[TAPChatManager sharedManager] getMessageFromWaitingUploadDictionaryWithKey:resultMessage.localID];
            if (obtainedMesage != nil) {
                
                //Update isFailedSend to 1 and isSending to 0
                [[TAPChatManager sharedManager] updateMessageToFailedWithLocalID:currentMessage.localID];
                
                if ([uploadQueueRoomArray count] > 0) {
                    //Remove first object
                    [uploadQueueRoomArray removeObjectAtIndex:0];
                    
                    if ([uploadQueueRoomArray count] == 0) {
                        [self.uploadQueueDictionary removeObjectForKey:resultMessage.room.roomID];
                    }
                    else {
                        [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:resultMessage.room.roomID];
                    }
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:objectDictionary];
            
            [self.uploadProgressDictionary removeObjectForKey:resultMessage.localID];
        }];
    }];
}

- (TAPDataMediaModel *)convertDictionaryToDataMediaModel:(NSDictionary *)dictionary {
    TAPDataMediaModel *dataMedia = [TAPDataMediaModel new];
    
    NSString *fileID = [dictionary objectForKey:@"fileID"];
    fileID = [TAPUtil nullToEmptyString:fileID];
    
    NSString *mediaType = [dictionary objectForKey:@"mediaType"];
    mediaType = [TAPUtil nullToEmptyString:mediaType];
    
    NSString *caption = [dictionary objectForKey:@"caption"];
    caption = [TAPUtil nullToEmptyString:caption];
    
    NSNumber *imageHeightRaw = [dictionary objectForKey:@"imageHeight"];
    CGFloat imageHeight = [imageHeightRaw floatValue];
    
    NSNumber *imageWidthRaw = [dictionary objectForKey:@"imageWidth"];
    CGFloat imageWidth = [imageWidthRaw floatValue];
    
    NSNumber *sizeRaw = [dictionary objectForKey:@"size"];
    CGFloat size = [sizeRaw floatValue];
    
    NSString *assetIdentifier = [dictionary objectForKey:@"assetIdentifier"];
    assetIdentifier = [TAPUtil nullToEmptyString:assetIdentifier];
    
    PHAsset *asset = [[TAPFileUploadManager sharedManager] getAssetFromPendingUploadAssetDictionaryWithAssetIdentifier:assetIdentifier];
    
    dataMedia.fileID = fileID;
    dataMedia.imageWidth = imageWidth;
    dataMedia.imageHeight = imageHeight;
    dataMedia.size = size;
    dataMedia.mediaType = mediaType;
    dataMedia.caption = caption;
    dataMedia.asset = asset;
    dataMedia.assetIdentifier = assetIdentifier;
    
    return dataMedia;
}

- (NSDictionary *)convertDataMediaModelToDictionary:(TAPDataMediaModel *)dataMedia {
    NSMutableDictionary *dataDictionary = [NSMutableDictionary new];
    
    NSString *fileID = dataMedia.fileID;
    fileID = [TAPUtil nullToEmptyString:fileID];
    
    NSString *mediaType = dataMedia.mediaType;
    mediaType = [TAPUtil nullToEmptyString:mediaType];
    
    NSString *caption = dataMedia.caption;
    caption = [TAPUtil nullToEmptyString:caption];
    
    NSNumber *imageHeight = [NSNumber numberWithFloat:dataMedia.imageHeight];
    
    NSString *imageWidth = [NSNumber numberWithFloat:dataMedia.imageWidth];
    
    NSString *size = [NSNumber numberWithFloat:dataMedia.size];
    
    PHAsset *asset = dataMedia.asset;
    
    [dataDictionary setObject:fileID forKey:@"fileID"];
    [dataDictionary setObject:mediaType forKey:@"mediaType"];
    [dataDictionary setObject:caption forKey:@"caption"];
    [dataDictionary setObject:imageHeight forKey:@"imageHeight"];
    [dataDictionary setObject:imageWidth forKey:@"imageWidth"];
    [dataDictionary setObject:size forKey:@"size"];
    [dataDictionary setObject:asset forKey:@"asset"];
    
    return dataDictionary;
}

- (TAPDataFileModel *)convertDictionaryToDataFileModel:(NSDictionary *)dictionary {
    TAPDataFileModel *dataFile = [TAPDataFileModel new];
    
    NSString *fileID = [dictionary objectForKey:@"fileID"];
    fileID = [TAPUtil nullToEmptyString:fileID];
    
    NSString *fileName = [dictionary objectForKey:@"fileName"];
    fileName = [TAPUtil nullToEmptyString:fileName];
    
    NSString *mediaType = [dictionary objectForKey:@"mediaType"];
    mediaType = [TAPUtil nullToEmptyString:mediaType];
    
    NSNumber *size = [dictionary objectForKey:@"size"];
    
    dataFile.fileID = fileID;
    dataFile.fileName = fileName;
    dataFile.mediaType = mediaType;
    dataFile.size = size;
    
    return dataFile;
}

- (NSDictionary *)convertDataFileModelToDictionary:(TAPDataFileModel *)dataFile {
    NSMutableDictionary *dataDictionary = [NSMutableDictionary new];
    
    NSString *fileID = dataFile.fileID;
    fileID = [TAPUtil nullToEmptyString:fileID];
    
    NSString *fileName = dataFile.fileName;
    fileName = [TAPUtil nullToEmptyString:fileName];
    
    NSString *mediaType = dataFile.mediaType;
    mediaType = [TAPUtil nullToEmptyString:mediaType];
    
    NSNumber *size = dataFile.size;
    
    [dataDictionary setObject:fileID forKey:@"fileID"];
    [dataDictionary setObject:fileName forKey:@"fileName"];
    [dataDictionary setObject:mediaType forKey:@"mediaType"];
    [dataDictionary setObject:size forKey:@"size"];
    
    return dataDictionary;
}

- (void)resizeImage:(UIImage *)image message:(TAPMessageModel *)message maxImageSize:(CGFloat)maxImageSize success:(void (^)(UIImage *resizedImage, TAPMessageModel *resultMessage))success {
    __block UIImage *resizedImage;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        
        if (imageWidth > imageHeight) {
            if (imageWidth > maxImageSize) {
                imageWidth = maxImageSize;
                
                imageHeight = (imageWidth / image.size.width) * image.size.height;
                if (imageHeight > maxImageSize) {
                    imageHeight = maxImageSize;
                }
            }
        }
        else {
            if (imageHeight > maxImageSize) {
                imageHeight = maxImageSize;

                imageWidth = (imageHeight / image.size.height) * image.size.width;
                if (imageWidth > maxImageSize) {
                    imageWidth = maxImageSize;
                }
            }
        }
        
        resizedImage = [TAPUtil resizedImage:image frame:CGRectMake(0.0f, 0.0f, roundf(imageWidth), roundf(imageHeight))];

        dispatch_async(dispatch_get_main_queue(), ^{
            success(resizedImage, message);
        });
        
    });
}

- (void)resizeImage:(UIImage *)image maxImageSize:(CGFloat)maxImageSize success:(void (^)(UIImage *resizedImage))success {
    __block UIImage *resizedImage;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        
        if (imageWidth > imageHeight) {
            if (imageWidth > maxImageSize) {
                imageWidth = maxImageSize;
                
                imageHeight = (imageWidth / image.size.width) * image.size.height;
                if (imageHeight > maxImageSize) {
                    imageHeight = maxImageSize;
                }
            }
        }
        else {
            if (imageHeight > maxImageSize) {
                imageHeight = maxImageSize;
                
                imageWidth = (imageHeight / image.size.height) * image.size.width;
                if (imageWidth > maxImageSize) {
                    imageWidth = maxImageSize;
                }
            }
        }
        
        resizedImage = [TAPUtil resizedImage:image frame:CGRectMake(0.0f, 0.0f, roundf(imageWidth), roundf(imageHeight))];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(resizedImage);
        });
    });
}

- (NSInteger)obtainUploadStatusWithMessage:(TAPMessageModel *)message {
    // 0 is not found
    // 1 is uploading
    // 2 is waiting for upload
    
    NSInteger status;
    NSInteger rowInArray;
    BOOL isFound = NO;
    
    NSMutableArray *uploadQueueRoomArray = [self.uploadQueueDictionary objectForKey:message.room.roomID];
    for (NSInteger counter = 0; counter < [uploadQueueRoomArray count]; counter++) {
        TAPMessageModel *uploadedMessage = [uploadQueueRoomArray objectAtIndex:counter];
        if ([uploadedMessage.localID isEqualToString:message.localID]) {
            rowInArray = counter;
            isFound = YES;
            break;
        }
    }
    
    if (!isFound) {
        status = 0;
    }
    else {
        if (rowInArray == 0) {
            status = 1;
        }
        else {
            status = 2;
        }
    }
    
    return status;
}

- (NSDictionary *)getUploadProgressWithLocalID:(NSString *)localID {
    NSDictionary *progressDictionary = [self.uploadProgressDictionary objectForKey:localID];
    return progressDictionary;
}

- (void)cancelUploadingOperationWithMessage:(TAPMessageModel *)message {
    NSString *currentRoomID = message.room.roomID;
    NSString *currentLocalID = message.localID;
    NSInteger currentUploadedIndex = 0;
    
    //Obtain current uploading message index
    NSMutableArray *uploadQueueRoomArray = [self.uploadQueueDictionary objectForKey:currentRoomID];
    for (NSInteger counter = 0; counter < [uploadQueueRoomArray count]; counter++) {
        TAPMessageModel *loopedMessage = [uploadQueueRoomArray objectAtIndex:counter];
        if ([currentLocalID isEqualToString:loopedMessage.localID]) {
            currentUploadedIndex = counter;
            break;
        }
        
    }
    
    //Cancel current task
    NSMutableDictionary *progressDictionary = [NSMutableDictionary dictionary];
    progressDictionary = [self.uploadProgressDictionary objectForKey:message.localID];
    NSURLSessionUploadTask *currentUploadTask = [progressDictionary objectForKey:@"uploadTask"];
    [currentUploadTask cancel];
    
    //Remove from queue array
    [uploadQueueRoomArray removeObjectAtIndex:currentUploadedIndex];
    [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:currentRoomID];
    
    if (currentUploadedIndex == 0) {
        //Run next upload image when deleted image is still uploading
        
        if ([uploadQueueRoomArray count] > 0) {
            TAPMessageModel *toBeUploadedMessage = (TAPMessageModel *)[uploadQueueRoomArray firstObject];
            if (message.type == TAPChatMessageTypeImage) {
                //Upload image
                [self runUploadImageWithRoomID:currentRoomID];
            }
            else if (message.type == TAPChatMessageTypeFile) {
                //Upload File
                [self runUploadFileWithRoomID:currentRoomID];
            }
            else if (message.type == TAPChatMessageTypeVideo) {
                //Upload File
                [self runUploadVideoAsAssetWithRoomID:currentRoomID];
            }
        }
    }
}

- (void)saveToPendingUploadAssetDictionaryWithAsset:(PHAsset *)asset {
    [self.pendingUploadAssetDictionary setObject:asset forKey:asset.localIdentifier];
}

- (PHAsset *)getAssetFromPendingUploadAssetDictionaryWithAssetIdentifier:(NSString *)assetIdentifier {
    PHAsset *obtainedAsset = [self.pendingUploadAssetDictionary objectForKey:assetIdentifier];
    return obtainedAsset;
}

- (void)clearFileUploadManagerData {
    [self.uploadQueueDictionary removeAllObjects];
    [self.uploadProgressDictionary removeAllObjects];
    [self.pendingUploadAssetDictionary removeAllObjects];
}

- (BOOL)isUploadingFile {
    if ([self.pendingUploadAssetDictionary count] > 0 || [self.uploadQueueDictionary count] > 0 || [self.uploadProgressDictionary count] > 0) {
        return YES;
    }
    return NO;
}

@end
