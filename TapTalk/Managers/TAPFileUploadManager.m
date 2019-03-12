//
//  TAPFileUploadManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 05/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPFileUploadManager.h"
#import "TAPDataImageModel.h"
#import "TAPDataFileModel.h"
#import <TapTalk/Base64.h>
@import AFNetworking;

#define kMaxImageSize 2000.0f
#define kMaxThumbnailImageSize 20.0f

@interface TAPFileUploadManager ()

@property (strong, nonatomic) NSMutableDictionary *uploadQueueDictionary;
@property (strong, nonatomic) NSMutableDictionary *uploadProgressDictionary;

- (void)runUploadImageWithRoomID:(NSString *)roomID;
- (void)runUploadFileWithRoomID:(NSString *)roomID;

- (TAPDataImageModel *)convertDictionaryToDataImageModel:(NSDictionary *)dictionary;
- (NSDictionary *)convertDataImageModelToDictionary:(TAPDataImageModel *)dataImage;
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

- (void)runUploadImageWithRoomID:(NSString *)roomID {
    
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
    TAPDataImageModel *dataImage = [TAPDataImageModel new];
    dataImage = [self convertDictionaryToDataImageModel:dataDictionary];
    
    //Get dummy image from cache
    [TAPImageView imageFromCacheWithKey:currentMessage.localID message:currentMessage success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
        
        //Resize image
        [self resizeImage:savedImage message:resultMessage maxImageSize:kMaxImageSize success:^(UIImage *resizedImage, TAPMessageModel *resultMessage) {
                
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
            
            NSURLSessionUploadTask *uploadTask = [TAPDataManager callAPIUploadFileWithFileData:imageData roomID:currentMessage.room.roomID fileType:@"image" mimeType:@"image/jpeg" caption:captionString completionBlock:^(NSDictionary *responseObject) {
                
                //resize to 20x20 for thumbnail
                [self resizeImage:savedImage message:resultMessage maxImageSize:kMaxThumbnailImageSize success:^(UIImage *resizedImage, TAPMessageModel *resultMessage) {
                        
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
                        [self runUploadImageWithRoomID:nextRoomID];
                    }
                }];
                
            } progressBlock:^(CGFloat progress, CGFloat total) {
                NSMutableDictionary *obtainedDictionary = [self.uploadProgressDictionary objectForKey:currentMessage.localID];
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
                    [TAPDataManager updateMessageToFailedWithLocalID:currentMessage.localID];
                    
                    //Remove from waiting upload dictionary
                    [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:currentMessage];
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
    }];
}

- (TAPDataImageModel *)convertDictionaryToDataImageModel:(NSDictionary *)dictionary {
    TAPDataImageModel *dataImage = [TAPDataImageModel new];
    
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
    
    dataImage.fileID = fileID;
    dataImage.imageWidth = imageWidth;
    dataImage.imageHeight = imageHeight;
    dataImage.size = size;
    dataImage.mediaType = mediaType;
    dataImage.caption = caption;
    
    return dataImage;
}

- (NSDictionary *)convertDataImageModelToDictionary:(TAPDataImageModel *)dataImage {
    NSMutableDictionary *dataDictionary = [NSMutableDictionary new];
    
    NSString *fileID = dataImage.fileID;
    fileID = [TAPUtil nullToEmptyString:fileID];
    
    NSString *mediaType = dataImage.mediaType;
    mediaType = [TAPUtil nullToEmptyString:mediaType];
    
    NSString *caption = dataImage.caption;
    caption = [TAPUtil nullToEmptyString:caption];
    
    NSNumber *imageHeight = [NSNumber numberWithFloat:dataImage.imageHeight];
    
    NSString *imageWidth = [NSNumber numberWithFloat:dataImage.imageWidth];
    
    NSString *size = [NSNumber numberWithFloat:dataImage.size];
    
    [dataDictionary setObject:fileID forKey:@"fileID"];
    [dataDictionary setObject:mediaType forKey:@"mediaType"];
    [dataDictionary setObject:caption forKey:@"caption"];
    [dataDictionary setObject:imageHeight forKey:@"imageHeight"];
    [dataDictionary setObject:imageWidth forKey:@"imageWidth"];
    [dataDictionary setObject:size forKey:@"size"];
    
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
    
    NSNumber *sizeRaw = [dictionary objectForKey:@"size"];
    CGFloat size = [sizeRaw floatValue];
    
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
    
    NSString *size = [NSNumber numberWithFloat:dataFile.size];
    
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

- (NSInteger)obtainImageUploadStatusWithMessage:(TAPMessageModel *)message {
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

- (void)cancelUploadingImageWithMessage:(TAPMessageModel *)message {
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
    NSMutableDictionary *progressDictionary = [self.uploadProgressDictionary objectForKey:message.localID];
    NSURLSessionUploadTask *currentUploadTask = [progressDictionary objectForKey:@"uploadTask"];
    [currentUploadTask cancel];
    
    //Remove from queue array
    [uploadQueueRoomArray removeObjectAtIndex:currentUploadedIndex];
    [self.uploadQueueDictionary setObject:uploadQueueRoomArray forKey:currentRoomID];
    
    if (currentUploadedIndex == 0) {
        //Run next upload image when deleted image is still uploading
        [self runUploadImageWithRoomID:currentRoomID];
    }
}

@end
