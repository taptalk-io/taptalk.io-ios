//
//  TAPCoreMessageManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 25/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCoreMessageManager.h"

@interface TAPCoreMessageManager () <TAPChatManagerDelegate>

#define ITEM_LOAD_LIMIT 500

@property (strong, nonatomic) NSMutableDictionary *blockDictionary;
@property (strong, nonatomic) NSMutableArray<TAPMessageModel *> *pendingCallbackNewMessages;
@property (strong, nonatomic) NSMutableArray<TAPMessageModel *> *pendingCallbackUpdatedMessages;
@property (strong, nonatomic) NSMutableArray<TAPMessageModel *> *pendingCallbackDeletedMessages;
@property (strong, nonatomic) NSTimer *messageListenerBulkCallbackTimer;
@property (strong, nonatomic) NSTimer *updatedMessageListenerBulkCallbackTimer;
@property (strong, nonatomic) NSTimer *deletedMessageListenerBulkCallbackTimer;

- (void)fileUploadManagerProgressNotification:(NSNotification *)notification;
- (void)fileUploadManagerStartNotification:(NSNotification *)notification;
- (void)fileUploadManagerFinishNotification:(NSNotification *)notification;
- (void)fileUploadManagerFailureNotification:(NSNotification *)notification;

@end

@implementation TAPCoreMessageManager
#pragma mark - Lifecycle
+ (TAPCoreMessageManager *)sharedManager {
    
    //Check if only implement TAPUI, don't init the core manager
    TapTalkImplentationType implementationType = [[TapTalk sharedInstance] getTapTalkImplementationType];
    if (implementationType == TapTalkImplentationTypeUI) {
        return nil;
    }
    
    static TAPCoreMessageManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        //Add chat manager delegate
        [[TAPChatManager sharedManager] addDelegate:self];
        
        _blockDictionary = [[NSMutableDictionary alloc] init];
        _pendingCallbackNewMessages = [[NSMutableArray alloc] init];
        _pendingCallbackUpdatedMessages = [[NSMutableArray alloc] init];
        _pendingCallbackDeletedMessages = [[NSMutableArray alloc] init];
        _messageDelegateBulkCallbackDelay = 0.0f;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerProgressNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerStartNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_START object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerFinishNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerFailureNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:nil];
    }
    
    return self;
}

- (void)dealloc {
    //Remove chat manager delegate
    [[TAPChatManager sharedManager] removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:nil];
}

#pragma mark - Delegate
#pragma mark TAPChatManager
- (void)chatManagerDidReceiveNewMessageInActiveRoom:(TAPMessageModel *)message {
    if (self.messageDelegateBulkCallbackDelay == 0.0f) {
        if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveNewMessage:)]) {
            [self.delegate tapTalkDidReceiveNewMessage:message];
        }
    }
    else {
        [self.pendingCallbackNewMessages addObject:message];
        [self startNewMessageDelegateBulkCallbackTimer];
    }
}

- (void)chatManagerDidReceiveNewMessageOnOtherRoom:(TAPMessageModel *)message {
    [self chatManagerDidReceiveNewMessageInActiveRoom:message];
}

- (void)chatManagerDidReceiveUpdateMessageInActiveRoom:(TAPMessageModel *)message {
    if (message.isDeleted) {
        if (self.messageDelegateBulkCallbackDelay == 0.0f) {
            if ([self.delegate respondsToSelector:@selector(tapTalkDidDeleteMessage:)]) {
                [self.delegate tapTalkDidDeleteMessage:message];
            }
        }
        else {
            [self.pendingCallbackDeletedMessages addObject:message];
            [self startDeletedMessageDelegateBulkCallbackTimer];
        }
    }
    else {
        if (self.messageDelegateBulkCallbackDelay == 0.0f) {
            if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveUpdatedMessage:)]) {
                [self.delegate tapTalkDidReceiveUpdatedMessage:message];
            }
        }
        else {
            [self.pendingCallbackUpdatedMessages addObject:message];
            [self startUpdatedMessageDelegateBulkCallbackTimer];
        }
    }
}

- (void)chatManagerDidReceiveUpdateMessageOnOtherRoom:(TAPMessageModel *)message {
    [self chatManagerDidReceiveUpdateMessageInActiveRoom:message];
}

- (void)chatManagerDidFinishSendEmitMessage:(TAPMessageModel *)message {
    if ([self.blockDictionary objectForKey:message.localID]) {
        NSDictionary *blockTypeDictionary = [self.blockDictionary objectForKey:message.localID];
        
         if (blockTypeDictionary == nil || [blockTypeDictionary count] == 0) {
            return;
        }
        
        void (^handler)(TAPMessageModel *) = [blockTypeDictionary objectForKey:@"successBlock"];
        handler(message);
    }
}

#pragma mark - Notification Handler
- (void)fileUploadManagerProgressNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
    
    NSString *progressString = [notificationParameterDictionary objectForKey:@"progress"];
    CGFloat progress = [progressString floatValue];
    
    NSString *totalString = [notificationParameterDictionary objectForKey:@"total"];
    CGFloat total = [totalString floatValue];
    
    NSDictionary *blockTypeDictionary = [self.blockDictionary objectForKey:obtainedMessage.localID];
    if (blockTypeDictionary == nil || [blockTypeDictionary count] == 0) {
        return;
    }
    
    void (^handler)(TAPMessageModel *, CGFloat, CGFloat) = [blockTypeDictionary objectForKey:@"progressBlock"];
    handler(obtainedMessage, progress, total);
}

- (void)fileUploadManagerFailureNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];

    NSError *obtainedError = [notificationParameterDictionary objectForKey:@"error"];
    NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:obtainedError];
    
    NSDictionary *blockTypeDictionary = [self.blockDictionary objectForKey:obtainedMessage.localID];
    if (blockTypeDictionary == nil || [blockTypeDictionary count] == 0) {
        return;
    }
    void (^handler)(TAPMessageModel * _Nullable, NSError *) = [blockTypeDictionary objectForKey:@"failureBlock"];
    handler(obtainedMessage, localizedError);
}

- (void)fileUploadManagerStartNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    if (notificationParameterDictionary == nil || [notificationParameterDictionary count] == 0) {
        return;
    }
    
    TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
}

- (void)fileUploadManagerFinishNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    if (notificationParameterDictionary == nil || [notificationParameterDictionary count] == 0) {
        return;
    }
    
    TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
}

#pragma mark - Custom Method
- (void)sendTextMessage:(NSString *)message
                   room:(TAPRoomModel *)room
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] sendTextMessage:message room:room successGenerateMessage:^(TAPMessageModel *message) {
        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
        [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
        start(message);
    }];
}

- (void)sendTextMessage:(NSString *)message
          quotedMessage:(TAPMessageModel *)quotedMessage
                   room:(TAPRoomModel *)room
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendTextMessage:message room:room start:start success:success failure:failure];
}

- (void)sendLocationMessageWithLatitude:(CGFloat)latitude
                              longitude:(CGFloat)longitude
                                address:(nullable NSString *)address
                                   room:(TAPRoomModel *)room
                                  start:(void (^)(TAPMessageModel *message))start
                                success:(void (^)(TAPMessageModel *message))success
                                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    NSString *addressString = @"";
    if (address != nil) {
        addressString = address;
    }
    
    [[TAPChatManager sharedManager] sendLocationMessage:latitude longitude:longitude address:address room:room successGenerateMessage:^(TAPMessageModel *message) {
        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
        [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
        
        start(message);
    }];
}

- (void)sendLocationMessageWithLatitude:(CGFloat)latitude
                              longitude:(CGFloat)longitude
                          quotedMessage:(TAPMessageModel *)quotedMessage
                                address:(nullable NSString *)address
                                   room:(TAPRoomModel *)room
                                  start:(void (^)(TAPMessageModel *message))start
                                success:(void (^)(TAPMessageModel *message))success
                                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendLocationMessageWithLatitude:latitude longitude:longitude address:address room:room start:start success:success failure:failure];
}

- (void)sendImageMessage:(UIImage *)image
                 caption:(nullable NSString *)caption
                    room:(TAPRoomModel *)room
                   start:(void (^)(TAPMessageModel *message))start
                progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                 success:(void (^)(TAPMessageModel *message))success
                 failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    NSString *captionString = @"";
    if (caption != nil) {
        captionString = caption;                        
    }
    
    // Check if caption is longer than allowed max length
    NSInteger maxCaptionCharacterLength = [[TapTalk sharedInstance] getMaxCaptionLength];
    if ([captionString length] > maxCaptionCharacterLength) {
        NSString *errorMessage = [NSString stringWithFormat:@"Media caption exceeds the %ld character limit", (long)maxCaptionCharacterLength];
        NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90306 errorMessage:errorMessage];
        failure(nil, error);
        return;
    }
    
    [[TAPChatManager sharedManager] sendImageMessage:image caption:captionString room:room successGenerateMessage:^(TAPMessageModel *message) {
        //Handle block to dictionary
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
        
        void (^handlerProgress)(TAPMessageModel *, CGFloat, CGFloat) = [progress copy];
        [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
        
        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
        
        void (^handlerFailure)(TAPMessageModel * _Nullable, NSError *) = [failure copy];
        [blockTypeDictionary setObject:handlerFailure forKey:@"failureBlock"];
        
        [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
        
        start(message);
    }];
}

- (void)sendImageMessage:(UIImage *)image
           quotedMessage:(TAPMessageModel *)quotedMessage
                 caption:(nullable NSString *)caption
                    room:(TAPRoomModel *)room
                   start:(void (^)(TAPMessageModel *message))start
                progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                 success:(void (^)(TAPMessageModel *message))success
                 failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendImageMessage:image caption:caption room:room start:start progress:progress success:success failure:failure];
}

- (void)sendImageMessageWithAsset:(PHAsset *)asset
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    NSString *captionString = @"";
    if (caption != nil) {
        captionString = caption;
    }
    
    // Check if caption is longer than allowed max length
    NSInteger maxCaptionCharacterLength = [[TapTalk sharedInstance] getMaxCaptionLength];
    if ([captionString length] > maxCaptionCharacterLength) {
        NSString *errorMessage = [NSString stringWithFormat:@"Media caption exceeds the %ld character limit", (long)maxCaptionCharacterLength];
        NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90306 errorMessage:errorMessage];
        failure(nil, error);
        return;
    }
    
    [[TAPChatManager sharedManager] sendImageMessageWithPHAsset:asset caption:caption room:room successGenerateMessage:^(TAPMessageModel *message) {
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
        
        void (^handlerProgress)(TAPMessageModel *, CGFloat, CGFloat) = [progress copy];
        [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
        
        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
        
        void (^handlerFailure)(TAPMessageModel * _Nullable, NSError *) = [failure copy];
        [blockTypeDictionary setObject:handlerFailure forKey:@"failureBlock"];
        
        [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
        
        start(message);
    }];
}

- (void)sendImageMessageWithAsset:(PHAsset *)asset
                    quotedMessage:(TAPMessageModel *)quotedMessage
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendImageMessageWithAsset:asset caption:caption room:room start:start progress:progress success:success failure:failure];
}

- (void)sendImageMessageWithURL:(NSURL *)imageURL
                        caption:(nullable NSString *)caption
                           room:(TAPRoomModel *)room
                          start:(void (^)(TAPMessageModel *message))start
                       progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                        success:(void (^)(TAPMessageModel *message))success
                        failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    [self sendImageMessage:image caption:caption room:room start:start progress:progress success:success failure:failure];
}

- (void)sendImageMessageWithURL:(NSURL *)imageURL
                  quotedMessage:(TAPMessageModel *)quotedMessage
                        caption:(nullable NSString *)caption
                           room:(TAPRoomModel *)room
                          start:(void (^)(TAPMessageModel *message))start
                       progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                        success:(void (^)(TAPMessageModel *message))success
                        failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    [self sendImageMessage:image caption:caption room:room start:start progress:progress success:success failure:failure];
}

- (void)sendVideoMessageWithAsset:(PHAsset *)asset
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    NSString *captionString = @"";
    if (caption != nil) {
        captionString = caption;
    }
    
    // Check if caption is longer than allowed max length
    NSInteger maxCaptionCharacterLength = [[TapTalk sharedInstance] getMaxCaptionLength];
    if ([captionString length] > maxCaptionCharacterLength) {
        NSString *errorMessage = [NSString stringWithFormat:@"Media caption exceeds the %ld character limit", (long)maxCaptionCharacterLength];
        NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90306 errorMessage:errorMessage];
        failure(nil, error);
        return;
    }
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = NO;
    requestOptions.networkAccessAllowed = YES;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset targetSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2, CGRectGetWidth([UIScreen mainScreen].bounds)/2) contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                NSError *error = [info objectForKey:PHImageErrorKey];
                if (error) {
#ifdef DEBUG
                    NSLog(@"[CameraRoll] Image request error: %@",error);
#endif
                } else {
                    if (result != nil) {
                        NSData *thumbnailImageData = UIImageJPEGRepresentation(result, 1.0f);
                        [[TAPChatManager sharedManager] sendVideoMessageWithPHAsset:asset caption:caption thumbnailImageData:thumbnailImageData room:room successGenerateMessage:^(TAPMessageModel *message) {
                            //Handle block to dictionary
                            NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
                            
                            void (^handlerProgress)(TAPMessageModel *, CGFloat, CGFloat) = [progress copy];
                            [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
                            
                            void (^handlerSuccess)(TAPMessageModel *) = [success copy];
                            [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
                            
                            void (^handlerFailure)(TAPMessageModel * _Nullable, NSError *) = [failure copy];
                            [blockTypeDictionary setObject:handlerFailure forKey:@"failureBlock"];
                            
                            [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
                            
                            start(message);
                        }];
                    }
                }
            }
        });
    }];
}

- (void)sendVideoMessageWithAsset:(PHAsset *)asset
                    quotedMessage:(TAPMessageModel *)quotedMessage
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendVideoMessageWithAsset:asset caption:caption room:room start:start progress:progress success:success failure:failure];
}

- (void)sendVideoMessageWithVideoAssetURL:(NSURL *)videoAssetURL
                                  caption:(nullable NSString *)caption
                                     room:(TAPRoomModel *)room
                                    start:(void (^)(TAPMessageModel *message))start
                                 progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                                  success:(void (^)(TAPMessageModel *message))success
                                  failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    NSString *captionString = @"";
    if (caption != nil) {
        captionString = caption;
    }
    
    // Check if caption is longer than allowed max length
    NSInteger maxCaptionCharacterLength = [[TapTalk sharedInstance] getMaxCaptionLength];
    if ([captionString length] > maxCaptionCharacterLength) {
        NSString *errorMessage = [NSString stringWithFormat:@"Media caption exceeds the %ld character limit", (long)maxCaptionCharacterLength];
        NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90306 errorMessage:errorMessage];
        failure(nil, error);
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //Retrieve the video frame at 1 sec to define the video thumbnail
//        AVURLAsset *urlVideoAsset = [[AVURLAsset alloc] initWithURL:videoAssetURL options:nil];
//        AVAssetImageGenerator *assetImageVideoGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlVideoAsset];
//        assetImageVideoGenerator.appliesPreferredTrackTransform = YES;
//        CMTime time = CMTimeMake(1, 1);
//        CGImageRef imageRef = [assetImageVideoGenerator copyCGImageAtTime:time actualTime:NULL error:nil];
        
        //Finalize video attachment
//        UIImage *videoThumbnailImage = [[UIImage alloc] initWithCGImage:imageRef];
//        CGImageRelease(imageRef); //AS NOTE - ADDED FOR RELEASE UNUSED MEMORY
        
//        NSData *videoThumbnailImageData = UIImageJPEGRepresentation(videoThumbnailImage, 1.0f);
        
        //END - Retrieve the video frame at 1 sec to define the video thumbnail
        
        AVAsset *videoAsset = [AVAsset assetWithURL:videoAssetURL];
        
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
        generator.appliesPreferredTrackTransform = YES;
        CMTime thumbTime = CMTimeMake(1, 1);
//        CGFloat videoLength = ((float) videoAsset.duration.value) / ((float) videoAsset.duration.timescale);
//        CMTime thumbTime = CMTimeMakeWithSeconds(videoLength, 2.0);
        
        //Handle block to dictionary
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];

        void (^handlerProgress)(TAPMessageModel *, CGFloat, CGFloat) = [progress copy];
        [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];

        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];

        void (^handlerFailure)(TAPMessageModel * _Nullable, NSError *) = [failure copy];
        [blockTypeDictionary setObject:handlerFailure forKey:@"failureBlock"];

        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
            if (result != AVAssetImageGeneratorSucceeded) {
                // Error when generating thumbnail
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TAPChatManager sharedManager] sendVideoMessageWithVideoAssetURL:videoAssetURL
                                                                              caption:caption
                                                                   thumbnailImageData:nil
                                                                                 room:room
                                                               successGenerateMessage:^(TAPMessageModel *message) {
                        
                        [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
                        start(message);
                    }];
                });
            }
            else {
                // Thumbnail generated
                UIImage *videoThumbnailImage = [[UIImage alloc] initWithCGImage:imageRef];
                NSData *videoThumbnailImageData = UIImageJPEGRepresentation(videoThumbnailImage, 1.0f);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TAPChatManager sharedManager] sendVideoMessageWithVideoAssetURL:videoAssetURL
                                                                              caption:caption
                                                                   thumbnailImageData:videoThumbnailImageData
                                                                                 room:room
                                                               successGenerateMessage:^(TAPMessageModel *message) {
                        
                        [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
                        start(message);
                    }];
                });
            }
        };

        [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    });
}

- (void)sendVideoMessageWithVideoAssetURL:(NSURL *)videoAssetURL
                            quotedMessage:(TAPMessageModel *)quotedMessage
                                  caption:(nullable NSString *)caption
                                     room:(TAPRoomModel *)room
                                    start:(void (^)(TAPMessageModel *message))start
                                 progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                                  success:(void (^)(TAPMessageModel *message))success
                                  failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendVideoMessageWithVideoAssetURL:videoAssetURL caption:caption room:room start:start progress:progress success:success failure:failure];
}

- (void)sendFileMessageWithFileURI:(NSURL *)fileURI
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    NSError *error = nil;
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    [coordinator coordinateReadingItemAtURL:fileURI options:NSFileCoordinatorReadingImmediatelyAvailableMetadataOnly error:&error byAccessor:^(NSURL *newURL) {
        NSError *err = nil;
        NSNumber *fileSize;
        if(![fileURI getPromisedItemResourceValue:&fileSize forKey:NSURLFileSizeKey error:&err]) {
            NSString *errorMessage = NSLocalizedStringFromTableInBundle(@"Unable to get file data from URI", nil, [TAPUtil currentBundle], @"");
            NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90301 errorMessage:errorMessage];
            failure(nil, error);
            return;
        } else {
            TAPCoreConfigsModel *coreConfigs = [TAPDataManager getCoreConfigs];
            NSNumber *maxFileSize = coreConfigs.chatMediaMaxFileSize;
            NSInteger maxFileSizeInMB = [maxFileSize integerValue] / 1024 / 1024;
            if ([fileSize doubleValue] > [maxFileSize doubleValue]) {
                //File size is larger than max file size
                NSString *errorMessage = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Selected file exceeded %ld MB maximum", nil, [TAPUtil currentBundle], @""), (long)maxFileSizeInMB];
                NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90302 errorMessage:errorMessage];
                failure(nil, error);
                return;
            }
            
            NSString *filePath = [fileURI absoluteString];
            NSString *encodedFileName = [filePath lastPathComponent];
            NSString *decodedFileName = [encodedFileName stringByRemovingPercentEncoding];
            NSString *fileExtension = [fileURI pathExtension];
            NSString *mimeType = [TAPUtil mimeTypeForFileWithExtension:fileExtension];
            NSData *fileData = [NSData dataWithContentsOfURL:fileURI];
            
            TAPDataFileModel *dataFile = [TAPDataFileModel new];
            dataFile.fileName = decodedFileName;
            dataFile.mediaType = mimeType;
            dataFile.size = fileSize;
            dataFile.fileData = fileData;
            
            [[TAPChatManager sharedManager] sendFileMessage:dataFile filePath:filePath room:room successGenerateMessage:^(TAPMessageModel *message) {
                NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
                
                void (^handlerProgress)(TAPMessageModel *, CGFloat, CGFloat) = [progress copy];
                [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
                
                void (^handlerSuccess)(TAPMessageModel *) = [success copy];
                [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
                
                void (^handlerFailure)(TAPMessageModel * _Nullable, NSError *) = [failure copy];
                [blockTypeDictionary setObject:handlerFailure forKey:@"failureBlock"];
                
                [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
                
                start(message);
            }];
        }
    }];
}

- (void)sendFileMessageWithFileURI:(NSURL *)fileURI
                     quotedMessage:(TAPMessageModel *)quotedMessage
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendFileMessageWithFileURI:fileURI room:room start:start progress:progress success:success failure:failure];
}

- (void)sendForwardedMessage:(TAPMessageModel *)messageToForward
                        room:(TAPRoomModel *)room
                       start:(void (^)(TAPMessageModel *message))start
                    progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                     success:(void (^)(TAPMessageModel *message))success
                     failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    if (messageToForward.type == TAPChatMessageTypeFile || messageToForward.type == TAPChatMessageTypeVideo) {
        NSDictionary *dataDictionary = messageToForward.data;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:messageToForward.room.roomID fileID:fileID];
        filePath = [TAPUtil nullToEmptyString:filePath];
        
        if (![filePath isEqualToString:@""]) {
            [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToDictionaryWithFilePath:filePath roomID:messageToForward.room.roomID fileID:fileID];
        }
    }
    
    TAPMessageModel *message = [TAPMessageModel createMessageWithUser:[TAPChatManager sharedManager].activeUser
                                                                 room:room
                                                                 body:messageToForward.body
                                                                 type:messageToForward.type
                                                          messageData:nil];
    
    message.data = messageToForward.data;
    message.quote = messageToForward.quote;
    message.replyTo = messageToForward.replyTo;
    
    if (messageToForward.forwardFrom.localID != nil && ![messageToForward.forwardFrom.localID isEqualToString:@""]) {
        //Obtain existing forward from model
        message.forwardFrom = messageToForward.forwardFrom;
    }
    else {
        //Create forward from model
        TAPForwardFromModel *forwardFrom = [TAPForwardFromModel new];
        forwardFrom.userID = messageToForward.user.userID;
        forwardFrom.xcUserID = messageToForward.user.xcUserID;
        forwardFrom.fullname = messageToForward.user.fullname;
        forwardFrom.messageID = messageToForward.messageID;
        forwardFrom.localID = messageToForward.localID;
        message.forwardFrom = forwardFrom;
    }
    
    [self sendCustomMessageWithMessageModel:message
    start:^(TAPMessageModel * _Nonnull message) {
        start(message);
    }
    success:^(TAPMessageModel * _Nonnull message) {
        success(message);
    }
    failure:^(TAPMessageModel *message, NSError * _Nonnull error) {
        failure(message, error);
    }];
    
//    [[TAPChatManager sharedManager] saveToQuoteActionWithType:TAPChatManagerQuoteActionTypeForward roomID:room.roomID];
//    [[TAPChatManager sharedManager] saveToQuotedMessage:messageToForward userInfo:[NSDictionary dictionary] roomID:room.roomID];
//    [[TAPChatManager sharedManager] checkAndSendForwardedMessageWithRoom:room];
}

- (TAPMessageModel *)constructTapTalkMessageModelWithRoom:(TAPRoomModel *)room
                                              messageBody:(NSString *)messageBody
                                              messageType:(NSInteger)messageType
                                              messageData:(NSDictionary * _Nullable)messageData {
    TAPMessageModel *constructedMessage = [TAPMessageModel createMessageWithUser:[TAPChatManager sharedManager].activeUser room:room body:messageBody type:messageType messageData:messageData];
    return constructedMessage;
}

- (TAPMessageModel *)constructTapTalkMessageModelWithRoom:(TAPRoomModel *)room
                                            quotedMessage:(TAPMessageModel *)quotedMessage
                                              messageBody:(NSString *)messageBody
                                              messageType:(NSInteger)messageType
                                              messageData:(NSDictionary * _Nullable)messageData {
    TAPMessageModel *constructedMessage = [self constructTapTalkMessageModelWithRoom:room messageBody:messageBody messageType:messageType messageData:messageData];
    
    //if message quoted from message model then should construct quote and reply to model
    NSString *quoteImageUrl = [TAPUtil nullToEmptyString:quotedMessage.quote.imageURL];
    NSString *quoteFileID = [TAPUtil nullToEmptyString:quotedMessage.quote.fileID];
    
    if (![quoteImageUrl isEqualToString:@""] || ![quoteFileID isEqualToString:@""]) {
        constructedMessage.quote = [quotedMessage.quote copy];
    }
    else {
        TAPQuoteModel *quote = [TAPQuoteModel new];
        quote.title = quotedMessage.user.fullname;
        quote.content = quotedMessage.body;
        constructedMessage.quote = [quote copy];
    }
    
    TAPReplyToModel *replyTo = [TAPReplyToModel new];
    replyTo.messageID = quotedMessage.messageID;
    replyTo.localID = quotedMessage.localID;
    replyTo.messageType = quotedMessage.type;
    replyTo.fullname = quotedMessage.user.fullname;
    replyTo.xcUserID = quotedMessage.user.xcUserID;
    replyTo.userID = quotedMessage.user.userID;
    constructedMessage.replyTo = replyTo;
    
    return constructedMessage;
}

- (NSDictionary *)constructTapTalkProductModelWithProductID:(NSString *)productID
                                                productName:(NSString *)productName
                                            productCurrency:(NSString *)productCurrency
                                               productPrice:(NSString *)productPrice
                                              productRating:(NSString *)productRating
                                              productWeight:(NSString *)productWeight
                                         productDescription:(NSString *)productDescription
                                            productImageURL:(NSString *)productImageURL
                               leftOrSingleButtonOptionText:(NSString *)leftOrSingleButtonOptionText
                                      rightButtonOptionText:(NSString *)rightButtonOptionText
                              leftOrSingleButtonOptionColor:(NSString *)leftOrSingleButtonOptionColor
                                     rightButtonOptionColor:(NSString *)rightButtonOptionColor {
    
    productID = [TAPUtil nullToEmptyString:productID];
    productName = [TAPUtil nullToEmptyString:productName];
    productCurrency = [TAPUtil nullToEmptyString:productCurrency];
    productPrice = [TAPUtil nullToEmptyString:productPrice];
    productRating = [TAPUtil nullToEmptyString:productRating];
    productWeight = [TAPUtil nullToEmptyString:productWeight];
    productDescription = [TAPUtil nullToEmptyString:productDescription];
    productImageURL = [TAPUtil nullToEmptyString:productImageURL];
    leftOrSingleButtonOptionText = [TAPUtil nullToEmptyString:leftOrSingleButtonOptionText];
    rightButtonOptionText = [TAPUtil nullToEmptyString:rightButtonOptionText];
    leftOrSingleButtonOptionColor = [TAPUtil nullToEmptyString:leftOrSingleButtonOptionColor];
    rightButtonOptionColor = [TAPUtil nullToEmptyString:rightButtonOptionColor];
    
    NSMutableDictionary *productDictionary = [NSMutableDictionary dictionary];
    [productDictionary setObject:productID forKey:@"id"];
    [productDictionary setObject:productName forKey:@"name"];
    [productDictionary setObject:productCurrency forKey:@"currency"];
    [productDictionary setObject:productPrice forKey:@"price"];
    [productDictionary setObject:productRating forKey:@"rating"];
    [productDictionary setObject:productWeight forKey:@"weight"];
    [productDictionary setObject:productDescription forKey:@"description"];
    [productDictionary setObject:productImageURL forKey:@"imageURL"];
    [productDictionary setObject:leftOrSingleButtonOptionText forKey:@"buttonOption1Text"];
    [productDictionary setObject:rightButtonOptionText forKey:@"buttonOption2Text"];
    [productDictionary setObject:leftOrSingleButtonOptionColor forKey:@"buttonOption1Color"];
    [productDictionary setObject:rightButtonOptionColor forKey:@"buttonOption2Color"];
    return [productDictionary copy];
}

- (void)sendCustomMessageWithMessageModel:(TAPMessageModel *)customMessage
                                    start:(void (^)(TAPMessageModel *message))start
                                  success:(void (^)(TAPMessageModel *message))success
                                  failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    void (^handlerSuccess)(TAPMessageModel *) = [success copy];
    NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
    [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
    [self.blockDictionary setObject:blockTypeDictionary forKey:customMessage.localID];
    start(customMessage);
    [[TAPChatManager sharedManager] sendCustomMessage:customMessage];
}

- (void)sendProductMessageWithProductArray:(NSArray <NSDictionary*> *)productArray
                                      room:(TAPRoomModel *)room
                                     start:(void (^)(TAPMessageModel *message))start
                                   success:(void (^)(TAPMessageModel *message))success
                                   failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    [dataDictionary setObject:productArray forKey:@"items"];
    
    TAPMessageModel *constructedMessage = [self constructTapTalkMessageModelWithRoom:room messageBody:@"Product List" messageType:TAPChatMessageTypeProduct messageData:dataDictionary];
    
    void (^handlerSuccess)(TAPMessageModel *) = [success copy];
    NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
    [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
    [self.blockDictionary setObject:blockTypeDictionary forKey:constructedMessage.localID];
    start(constructedMessage);
    [[TAPChatManager sharedManager] sendProductMessage:constructedMessage];
}

- (void)deleteMessage:(TAPMessageModel *)message
              success:(void (^)(void))success
              failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    [TAPDataManager callAPIDeleteMessageWithMessageIDs:@[message.messageID]
                                                roomID:message.room.roomID
                                  isDeletedForEveryone:YES
    success:^(NSArray *deletedMessageIDArray) {
        success();
    }
    failure:^(NSError *error) {
        failure(message, error);
    }];
}

- (void)deleteLocalMessageWithLocalID:(NSString *)localID
                              success:(void (^)(void))success
                              failure:(void (^)(NSString *localID, NSError *error))failure {
    TAPMessageModel *message = [TAPMessageModel new];
    message.localID = localID;
    
    [TAPDataManager deleteDatabaseMessageWithData:@[message] success:^{
        success();
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localID, localizedError);
    }];
}

- (void)uploadImage:(UIImage *)image
            success:(void (^)(NSString *fileID, NSString *fileURL))success
            failure:(void (^)(NSError *error))failure {
    
    [[TAPFileUploadManager sharedManager]uploadImage:image success:^(NSString * _Nonnull fileID, NSString * _Nonnull fileURL) {
        success(fileID, fileURL);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)cancelMessageFileUpload:(TAPMessageModel *)message
                        success:(void (^)(void))success
                        failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    if (message.type != TAPChatMessageTypeFile && message.type != TAPChatMessageTypeImage && message.type != TAPChatMessageTypeVideo) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90305 errorMessage:@"Invalid message type. Allowed types are image (1002), video (1003), or file (1004)"];
        failure(message, localizedError);
    }
    
    //Cancel uploading task
    [[TAPFileUploadManager sharedManager] cancelUploadingOperationWithMessage:message];
    
    //Remove from WaitingUploadDictionary in ChatManager
    [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:message];
    
    //Remove message from database
    [TAPDataManager deleteDatabaseMessageWithData:@[message] success:^{
        success();
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(message, localizedError);
    }];
}

- (void)downloadMessageFile:(TAPMessageModel *)message
                      start:(void (^)(void))startBlock
                   progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progressBlock
                    success:(void (^)(TAPMessageModel *message, NSData *fileData, NSString *filePath))successBlock
                    failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failureBlock {
    if (message.type == TAPChatMessageTypeFile) {
        [[TAPFileDownloadManager sharedManager] receiveFileDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
            startBlock();
        } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
            progressBlock(receivedMessage, progress, total);
        } success:^(NSData * _Nonnull fileData, TAPMessageModel * _Nonnull receivedMessage, NSString * _Nonnull filePath) {
            successBlock(receivedMessage, fileData, filePath);
        } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failureBlock(receivedMessage, localizedError);
        }];
    }
    else {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90305 errorMessage:@"Invalid message type. Allowed type is file (1004)"];
        failureBlock(message, localizedError);
    }
}

- (void)downloadMessageImage:(TAPMessageModel *)message
                      start:(void (^)(void))startBlock
                   progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progressBlock
                    success:(void (^)(TAPMessageModel *message, UIImage *fullImage, NSString * _Nullable filePath))successBlock
                    failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failureBlock {
    if (message.type == TAPChatMessageTypeImage) {
        [[TAPFileDownloadManager sharedManager] receiveImageDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
            startBlock();
        } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
            progressBlock(receivedMessage, progress, total);
        } success:^(UIImage * _Nonnull fullImage, TAPMessageModel * _Nonnull receivedMessage, NSString * _Nullable filePath) {
            successBlock(receivedMessage, fullImage, filePath);
        } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failureBlock(receivedMessage, localizedError);
        }];
    }
    else {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90305 errorMessage:@"Invalid message type. Allowed type is image (1002)"];
        failureBlock(message, localizedError);
    }
}

- (void)downloadMessageVideo:(TAPMessageModel *)message
                       start:(void (^)(void))startBlock
                    progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progressBlock
                     success:(void (^)(TAPMessageModel *message, NSData *fileData, NSString *filePath))successBlock
                     failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failureBlock {
    if (message.type == TAPChatMessageTypeVideo) {
        [[TAPFileDownloadManager sharedManager] receiveVideoDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
            startBlock();
        } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
            progressBlock(receivedMessage, progress, total);
        } success:^(NSData * _Nonnull fileData, TAPMessageModel * _Nonnull receivedMessage, NSString * _Nonnull filePath) {
            successBlock(receivedMessage, fileData, filePath);
        } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failureBlock(receivedMessage, localizedError);
        }];
    }
    else {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90305 errorMessage:@"Invalid message type. Allowed type is video (1003)"];
        failureBlock(message, localizedError);
    }
}

- (void)cancelMessageFileDownload:(TAPMessageModel *)message
                          success:(void (^)(void))success
                          failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    if (message.type != TAPChatMessageTypeFile && message.type != TAPChatMessageTypeImage && message.type != TAPChatMessageTypeVideo) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90305 errorMessage:@"Invalid message type. Allowed types are image (1002), video (1003), or file (1004)"];
        failure(message, localizedError);
    }
    
    [[TAPFileDownloadManager sharedManager] cancelDownloadWithMessage:message];
    success;
}

- (void)markMessageAsDelivered:(TAPMessageModel *)message {
    if (message.isDelivered) {
        return;
    }

    message.isDelivered = YES;
    [[TAPMessageStatusManager sharedManager] markMessageAsDeliveredWithMessage:message];
}

- (void)markMessagesAsDelivered:(NSArray<TAPMessageModel *> *)messageArray {
    for (TAPMessageModel *message in messageArray) {
        [self markMessageAsDelivered:message];
    }
}

- (void)markMessageAsRead:(TAPMessageModel *)message {
    if (message.isRead) {
        return;
    }
    message.isRead = YES;
    [[TAPMessageStatusManager sharedManager] markMessageAsReadWithMessage:message];
}

- (void)markMessagesAsRead:(NSArray<TAPMessageModel *> *)messageArray {
    for (TAPMessageModel *message in messageArray) {
        [self markMessageAsRead:message];
    }
}

- (void)markMessagesAsRead:(NSArray<TAPMessageModel *> *)messageArray
                   success:(void (^)(NSArray <NSString *> *updatedMessageIDs))success
                   failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIUpdateMessageReadStatusWithArray:messageArray
    success:^(NSArray *updatedMessageIDsArray, NSArray *originMessageArray) {
        [[TAPChatManager sharedManager] updateReadMessageToDatabaseQueueWithArray:originMessageArray];
        success(updatedMessageIDsArray);
    }
    failure:^(NSError *error, NSArray *messageArray) {
        failure(error);
    }];
}

- (void)markAllMessagesInRoomAsReadWithRoomID:(NSString *)roomID {
    [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:roomID
                                                 activeUserID:[TAPChatManager sharedManager].activeUser.userID
    success:^(NSArray *unreadMessages) {
        [self markMessagesAsRead:unreadMessages];
    }
    failure:^(NSError *error) {
        
    }];
}

- (void)markAllMessagesInRoomAsReadWithRoomID:(NSString *)roomID
                                      success:(void (^)(NSArray <NSString *> *updatedMessageIDs))success
                                      failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:roomID
                                                 activeUserID:[TAPChatManager sharedManager].activeUser.userID
    success:^(NSArray *unreadMessages) {
        [self markMessagesAsRead:unreadMessages success:success failure:failure];
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getLocalMessagesWithRoomID:(NSString *)roomID
                           success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                           failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager getAllMessageWithRoomID:roomID
                                  sortByKey:@"created"
                                  ascending:NO
    success:^(NSArray<TAPMessageModel *> *messageArray) {
        success(messageArray);
    }
    failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
        }];
    }

- (void)getOlderMessagesBeforeTimestamp:(NSNumber *)timestamp
                                 roomID:(NSString *)roomID
                          numberOfItems:(NSNumber *)numberOfItems
                                success:(void (^)(NSArray <TAPMessageModel *> *messageArray, BOOL hasMoreData))success
                                failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetMessageBeforeWithRoomID:roomID maxCreated:timestamp numberOfItems:numberOfItems success:^(NSArray *messageArray, BOOL hasMore) {
        success(messageArray, hasMore);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getNewerMessagesAfterTimestamp:(NSNumber *)minCreatedTimestamp
                  lastUpdatedTimestamp:(NSNumber *)lastUpdatedTimestamp
                                roomID:(NSString *)roomID
                               success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                               failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetMessageAfterWithRoomID:roomID minCreated:minCreatedTimestamp lastUpdated:lastUpdatedTimestamp needToSaveLastUpdatedTimestamp:NO success:^(NSArray *messageArray) {
        success(messageArray);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getNewerMessagesWithRoomID:(NSString *)roomID
                           success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                           failure:(void (^)(NSError *error))failure {
    [TAPDataManager getAllMessageWithRoomID:roomID sortByKey:@"created" ascending:YES success:^(NSArray<TAPMessageModel *> *messageArray) {
        NSNumber *minCreated;
        if ([messageArray count] != 0) {
            TAPMessageModel *earliestMessage = [messageArray firstObject];
            minCreated = earliestMessage.created;
        }
        else {
            minCreated = [NSNumber numberWithInteger:0];
        }
        
        NSNumber *lastUpdatedFromPreference = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];
        [TAPDataManager callAPIGetMessageAfterWithRoomID:roomID minCreated:minCreated lastUpdated:lastUpdatedFromPreference needToSaveLastUpdatedTimestamp:YES success:^(NSArray *messageArray) {
            success(messageArray);
        } failure:^(NSError *error) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failure(localizedError);
        }];
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getAllOlderMessagesBeforeTimestamp:(NSNumber *)timestamp
                                    roomID:(NSString *)roomID
                         olderMessageArray:(NSMutableArray<TAPMessageModel *> *)olderMessages
                                   success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                                   failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIGetMessageBeforeWithRoomID:roomID
                                           maxCreated:timestamp
                                        numberOfItems:[NSNumber numberWithInt:ITEM_LOAD_LIMIT]
    success:^(NSArray *messageArray, BOOL hasMore) {
        [olderMessages addObjectsFromArray:messageArray];
        if (hasMore) {
            // Fetch more older messages
            TAPMessageModel *oldestMessage = [messageArray objectAtIndex:[messageArray count] - 1];
            [self getAllOlderMessagesBeforeTimestamp:oldestMessage.created
                                              roomID:roomID
                                   olderMessageArray:olderMessages
                                             success:success
                                             failure:failure];
        }
        else {
            // Return all older messages
            success(olderMessages);
        }
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getMessagesFromServerWithRoomID:(NSString *)roomID
                                success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                                failure:(void (^)(NSError *error))failure {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TAPDataManager getDatabaseOldestCreatedTimeFromRoom:roomID success:^(NSNumber *createdTime) {
            [self getAllOlderMessagesBeforeTimestamp:createdTime
                                              roomID:roomID
                                   olderMessageArray:[NSMutableArray array]
            success:^(NSArray<TAPMessageModel *> *messageArray) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    success(messageArray);
                });
            }
            failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    failure(error);
                });
            }];
        }
        failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                failure(error);
            });
        }];
    });
}

- (void)getAllMessagesWithRoomID:(NSString *)roomID
            successLocalMessages:(void (^)(NSArray <TAPMessageModel *> *messageArray))successLocalMessages
              successAllMessages:(void (^)(NSArray <TAPMessageModel *> *allMessagesArray,
                                           NSArray <TAPMessageModel *> *olderMessagesArray,
                                           NSArray <TAPMessageModel *> *newerMessagesArray))successAllMessages
                         failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary<NSString*, TAPMessageModel *> *messageDictionary = [NSMutableDictionary dictionary];
    NSMutableArray<TAPMessageModel *> *allMessages = [NSMutableArray array];
    NSMutableArray<TAPMessageModel *> *olderMessages = [NSMutableArray array];
    NSMutableArray<TAPMessageModel *> *newerMessages = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Get messages from database
        [self getLocalMessagesWithRoomID:roomID success:^(NSArray<TAPMessageModel *> *messageArray) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                successLocalMessages(messageArray);
            });
            
            [allMessages addObjectsFromArray:messageArray];
            for (TAPMessageModel *message in messageArray) {
                [messageDictionary setObject:message forKey:message.localID];
            }
            
            long lastTimestamp;
            if ([allMessages count] > 0) {
                lastTimestamp = [allMessages objectAtIndex:[allMessages count] - 1].created;
            }
            else {
                lastTimestamp = [[NSDate date] timeIntervalSince1970];
            }
            
            // Fetch older messages from API
            [self getAllOlderMessagesBeforeTimestamp:[NSNumber numberWithLong:lastTimestamp]
                                              roomID:roomID
                                   olderMessageArray:[NSMutableArray array]
            success:^(NSArray<TAPMessageModel *> * _Nonnull messageArray) {
                NSMutableArray<TAPMessageModel *> *filteredMessages = [NSMutableArray array];
                for (TAPMessageModel *message in messageArray) {
                    if ([messageDictionary objectForKey:message.localID] == nil) {
                        [filteredMessages addObject:message];
                    }
                    [messageDictionary setObject:message forKey:message.localID];
                }
                [allMessages addObjectsFromArray:filteredMessages];
                [olderMessages addObjectsFromArray:filteredMessages];
                
                // Fetch newer messages from API
                long lastUpdateTimestamp = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];
                long minCreatedTimestamp = 0L;
                if ([allMessages count] > 0) {
                    minCreatedTimestamp = [allMessages objectAtIndex:0].created;
                }
                [self getNewerMessagesAfterTimestamp:[NSNumber numberWithLong:minCreatedTimestamp]
                                lastUpdatedTimestamp:[NSNumber numberWithLong:lastUpdateTimestamp]
                                              roomID:roomID
                success:^(NSArray<TAPMessageModel *> * _Nonnull messageArray) {
                    NSMutableArray<TAPMessageModel *> *filteredMessages = [NSMutableArray array];
                    for (TAPMessageModel *message in messageArray) {
                        if ([messageDictionary objectForKey:message.localID] == nil) {
                            [filteredMessages addObject:message];
                        }
                        [messageDictionary setObject:message forKey:message.localID];
                    }
                    [allMessages addObjectsFromArray:filteredMessages];
                    [newerMessages addObjectsFromArray:filteredMessages];
                    
                    successAllMessages(allMessages, olderMessages, newerMessages);
                    
//                    [self getLocalMessagesWithRoomID:roomID success:^(NSArray<TAPMessageModel *> * _Nonnull messageArray) {
//                        dispatch_async(dispatch_get_main_queue(), ^(void) {
//                            successAllMessages(messageArray, olderMessages, newerMessages);
//                        });
//                    } failure:^(NSError * _Nonnull error) {
//                        // Sort message array
//                        NSMutableArray *currentMessageArray = [NSMutableArray arrayWithArray:allMessages];
//                        NSMutableArray *sortedArray;
//
//                        sortedArray = [currentMessageArray sortedArrayUsingComparator:^NSComparisonResult(id message1, id message2) {
//                            TAPMessageModel *messageModel1 = (TAPMessageModel *)message1;
//                            TAPMessageModel *messageModel2 = (TAPMessageModel *)message2;
//
//                            NSNumber *message1CreatedDate = messageModel1.created;
//                            NSNumber *message2CreatedDate = messageModel2.created;
//
//                            return [message2CreatedDate compare:message1CreatedDate];
//                        }];
//
//                        dispatch_async(dispatch_get_main_queue(), ^(void) {
//                            successAllMessages(sortedArray, olderMessages, newerMessages);
//                        });
//                    }];
                } failure:^(NSError * _Nonnull error) {
                    NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        failure(localizedError);
                    });
                }];
            }
            failure:^(NSError * _Nonnull error) {
                NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    failure(localizedError);
                });
            }];
        }
        failure:^(NSError *error) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                failure(localizedError);
            });
        }];
    });
}

- (void)getUnreadMessagesFromRoom:(NSString *)roomID
                          success:(void (^)(NSArray<TAPMessageModel *> *unreadMessageArray))success
                          failure:(void (^)(NSError *error))failure {

    [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:roomID
                                                 activeUserID:[[TapTalk sharedInstance] getTapTalkActiveUser].userID
    success:^(NSArray *unreadMessages) {
        success(unreadMessages);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getMediaMessagesFromRoom:(NSString *)roomID
                   lastTimestamp:(NSNumber *)lastTimestamp
                    numberOfItem:(NSInteger)numberOfItem
                         success:(void (^)(NSArray<TAPMessageModel *> *mediaMessageArray))success
                         failure:(void (^)(NSError *error))failure {
    
    NSString *lastTimestampString;
    if ([lastTimestamp longValue] <= 0L) {
        lastTimestampString = @"";
    }
    else {
        lastTimestampString = [lastTimestamp stringValue];
    }
    [TAPDataManager getDatabaseMediaMessagesInRoomWithRoomID:roomID
                                               lastTimestamp:lastTimestampString
                                                numberOfItem:numberOfItem
    success:^(NSArray *mediaMessages) {
        success(mediaMessages);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)searchLocalMessageWithKeyword:(NSString *)keyword
                              success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                              failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager searchMessageWithString:keyword sortBy:@"created" success:^(NSArray *resultArray) {
        success(resultArray);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)searchLocalRoomMessageWithKeyword:(NSString *)keyword
                                   roomID:(NSString *)roomID
                                  success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                                  failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager searchMessageWithString:keyword roomID:roomID sortBy:@"created" success:^(NSArray *resultArray) {
        success(resultArray);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)startNewMessageDelegateBulkCallbackTimer {
    if (self.messageListenerBulkCallbackTimer != nil) {
        [self.messageListenerBulkCallbackTimer invalidate];
    }
    self.messageListenerBulkCallbackTimer = [NSTimer scheduledTimerWithTimeInterval:self.messageDelegateBulkCallbackDelay target:self selector:@selector(newMessageDelegateBulkCallbackTimerFired) userInfo:nil repeats:NO];
}

- (void)newMessageDelegateBulkCallbackTimerFired {
    if ([self.pendingCallbackNewMessages count] > 1) {
        if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveNewMessages:)]) {
            [self.delegate tapTalkDidReceiveNewMessages:self.pendingCallbackNewMessages];
        }
    }
    else if ([self.pendingCallbackNewMessages count] == 1) {
        if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveNewMessage:)]) {
            [self.delegate tapTalkDidReceiveNewMessage:[self.pendingCallbackNewMessages firstObject]];
        }
    }
    [self.pendingCallbackNewMessages removeAllObjects];
    [self.messageListenerBulkCallbackTimer invalidate];
}

- (void)startUpdatedMessageDelegateBulkCallbackTimer {
    if (self.updatedMessageListenerBulkCallbackTimer != nil) {
        [self.updatedMessageListenerBulkCallbackTimer invalidate];
    }
    self.updatedMessageListenerBulkCallbackTimer = [NSTimer scheduledTimerWithTimeInterval:self.messageDelegateBulkCallbackDelay target:self selector:@selector(updatedMessageDelegateBulkCallbackTimerFired) userInfo:nil repeats:NO];
}

- (void)updatedMessageDelegateBulkCallbackTimerFired {
    if ([self.pendingCallbackUpdatedMessages count] > 1) {
        if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveUpdatedMessages:)]) {
            [self.delegate tapTalkDidReceiveUpdatedMessages:self.pendingCallbackUpdatedMessages];
        }
    }
    else if ([self.pendingCallbackUpdatedMessages count] == 1) {
        if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveUpdatedMessage:)]) {
            [self.delegate tapTalkDidReceiveUpdatedMessage:[self.pendingCallbackUpdatedMessages firstObject]];
        }
    }
    [self.pendingCallbackUpdatedMessages removeAllObjects];
    [self.updatedMessageListenerBulkCallbackTimer invalidate];
}

- (void)startDeletedMessageDelegateBulkCallbackTimer {
    if (self.deletedMessageListenerBulkCallbackTimer != nil) {
        [self.deletedMessageListenerBulkCallbackTimer invalidate];
        //self.deletedMessageListenerBulkCallbackTimer = nil;
    }
    self.deletedMessageListenerBulkCallbackTimer = [NSTimer scheduledTimerWithTimeInterval:self.messageDelegateBulkCallbackDelay target:self selector:@selector(deletedMessageDelegateBulkCallbackTimerFired) userInfo:nil repeats:NO];
}

- (void)deletedMessageDelegateBulkCallbackTimerFired {
    if ([self.pendingCallbackDeletedMessages count] > 1) {
        if ([self.delegate respondsToSelector:@selector(tapTalkDidDeleteMessages:)]) {
            [self.delegate tapTalkDidDeleteMessages:self.pendingCallbackDeletedMessages];
        }
    }
    else if ([self.pendingCallbackDeletedMessages count] == 1) {
        if ([self.delegate respondsToSelector:@selector(tapTalkDidDeleteMessage:)]) {
            [self.delegate tapTalkDidDeleteMessage:[self.pendingCallbackDeletedMessages firstObject]];
        }
    }
    [self.pendingCallbackDeletedMessages removeAllObjects];
    [self.deletedMessageListenerBulkCallbackTimer invalidate];
}

@end
