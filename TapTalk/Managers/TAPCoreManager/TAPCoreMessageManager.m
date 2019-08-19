//
//  TAPCoreMessageManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 25/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCoreMessageManager.h"

@interface TAPCoreMessageManager () <TAPChatManagerDelegate>

@property (strong, nonatomic) NSMutableDictionary *blockDictionary;

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
    if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveNewMessageInActiveRoom:)]) {
        [self.delegate tapTalkDidReceiveNewMessageInActiveRoom:message];
    }
}

- (void)chatManagerDidReceiveNewMessageOnOtherRoom:(TAPMessageModel *)message {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveNewMessageInOtherRoom:)]) {
        [self.delegate tapTalkDidReceiveNewMessageInOtherRoom:message];
    }
}

- (void)chatManagerDidReceiveUpdateMessageInActiveRoom:(TAPMessageModel *)message {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveNewMessageInOtherRoom:)]) {
        [self.delegate tapTalkDidReceiveNewMessageInOtherRoom:message];
    }
}

- (void)chatManagerDidReceiveUpdateMessageOnOtherRoom:(TAPMessageModel *)message {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveNewMessageInOtherRoom:)]) {
        [self.delegate tapTalkDidReceiveNewMessageInOtherRoom:message];
    }
}

- (void)chatManagerDidReceiveOnlineStatus:(TAPOnlineStatusModel *)onlineStatus {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveOnlineStatus:)]) {
        [self.delegate tapTalkDidReceiveOnlineStatus:onlineStatus];
    }
}

- (void)chatManagerDidReceiveStartTyping:(TAPTypingModel *)typing {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidStartTyping:)]) {
        [self.delegate tapTalkDidStartTyping:typing];
    }
}

- (void)chatManagerDidReceiveStopTyping:(TAPTypingModel *)typing {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidStopTyping:)]) {
        [self.delegate tapTalkDidStopTyping:typing];
    }
}

- (void)chatManagerDidFinishSendEmitMessage:(TAPMessageModel *)message {
    if ([self.blockDictionary objectForKey:message.localID]) {
        NSDictionary *blockTypeDictionary = [self.blockDictionary objectForKey:message.localID];
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
    void (^handler)(CGFloat, CGFloat) = [blockTypeDictionary objectForKey:@"progressBlock"];
    handler(progress, total);
}

- (void)fileUploadManagerFailureNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];

    NSError *obtainedError = [notificationParameterDictionary objectForKey:@"error"];
    NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:obtainedError];
    
    NSDictionary *blockTypeDictionary = [self.blockDictionary objectForKey:obtainedMessage.localID];
    void (^handler)(NSError *) = [blockTypeDictionary objectForKey:@"failureBlock"];
    handler(localizedError);
}

- (void)fileUploadManagerStartNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
}

- (void)fileUploadManagerFinishNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
}

#pragma mark - Custom Method
- (void)sendTextMessage:(NSString *)message
                   room:(TAPRoomModel *)room
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(NSError *error))failure {
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
                failure:(void (^)(NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendTextMessage:message room:room start:start success:success failure:failure];
}

- (void)sendLocationMessageWithLatitude:(CGFloat)latitude
                              longitude:(CGFloat)longitude
                                address:(nullable NSString *)address
                                   room:(TAPRoomModel *)room
                                  start:(void (^)(TAPMessageModel *message))start
                                success:(void (^)(TAPMessageModel *message))success
                                failure:(void (^)(NSError *error))failure {
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
                                failure:(void (^)(NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendLocationMessageWithLatitude:latitude longitude:longitude address:address room:room start:start success:success failure:failure];
}

- (void)sendImageMessage:(UIImage *)image
                 caption:(nullable NSString *)caption
                    room:(TAPRoomModel *)room
                   start:(void (^)(TAPMessageModel *message))start
                progress:(void (^)(CGFloat progress, CGFloat total))progress
                 success:(void (^)(TAPMessageModel *message))success
                 failure:(void (^)(NSError *error))failure {
    NSString *captionString = @"";
    if (caption != nil) {
        captionString = caption;                        
    }
    
    [[TAPChatManager sharedManager] sendImageMessage:image caption:captionString room:room successGenerateMessage:^(TAPMessageModel *message) {
        //Handle block to dictionary
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
        
        void (^handlerProgress)(CGFloat, CGFloat) = [progress copy];
        [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
        
        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
        
        void (^handlerFailure)(NSError *) = [failure copy];
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
                progress:(void (^)(CGFloat progress, CGFloat total))progress
                 success:(void (^)(TAPMessageModel *message))success
                 failure:(void (^)(NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendImageMessage:image caption:caption room:room start:start progress:progress success:success failure:failure];
}

- (void)sendImageMessageWithAsset:(PHAsset *)asset
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(NSError *error))failure {
    NSString *captionString = @"";
    if (caption != nil) {
        captionString = caption;
    }
    
    [[TAPChatManager sharedManager] sendImageMessageWithPHAsset:asset caption:caption room:room successGenerateMessage:^(TAPMessageModel *message) {
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
        
        void (^handlerProgress)(CGFloat, CGFloat) = [progress copy];
        [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
        
        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
        
        void (^handlerFailure)(NSError *) = [failure copy];
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
                         progress:(void (^)(CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendImageMessageWithAsset:asset caption:caption room:room start:start progress:progress success:success failure:failure];
}

- (void)sendVideoMessageWithAsset:(PHAsset *)asset
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(NSError *error))failure {
    NSString *captionString = @"";
    if (caption != nil) {
        captionString = caption;
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
                            
                            void (^handlerProgress)(CGFloat, CGFloat) = [progress copy];
                            [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
                            
                            void (^handlerSuccess)(TAPMessageModel *) = [success copy];
                            [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
                            
                            void (^handlerFailure)(NSError *) = [failure copy];
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
                         progress:(void (^)(CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendVideoMessageWithAsset:asset caption:caption room:room start:start progress:progress success:success failure:failure];
}

- (void)sendFileMessageWithFileURI:(NSURL *)fileURI
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(NSError *error))failure {
    NSError *error = nil;
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    [coordinator coordinateReadingItemAtURL:fileURI options:NSFileCoordinatorReadingImmediatelyAvailableMetadataOnly error:&error byAccessor:^(NSURL *newURL) {
        NSError *err = nil;
        NSNumber *fileSize;
        if(![fileURI getPromisedItemResourceValue:&fileSize forKey:NSURLFileSizeKey error:&err]) {
            NSString *errorMessage = @"Unable to get file data from URI";
            NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90301 errorMessage:errorMessage];
            failure(error);
            return;
        } else {
            
            TAPCoreConfigsModel *coreConfigs = [TAPDataManager getCoreConfigs];
            NSNumber *maxFileSize = coreConfigs.chatMediaMaxFileSize;
            NSInteger maxFileSizeInMB = [maxFileSize integerValue] / 1024 / 1024;
            if ([fileSize doubleValue] > [maxFileSize doubleValue]) {
                //File size is larger than max file size
                NSString *errorMessage = [NSString stringWithFormat:@"Selected file exceeded %ld MB maximum", (long)maxFileSizeInMB];
                NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90302 errorMessage:errorMessage];
                failure(error);
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
            
            [[TAPChatManager sharedManager] sentFileMessage:dataFile filePath:filePath room:room successGenerateMessage:^(TAPMessageModel *message) {
                NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
                
                void (^handlerProgress)(CGFloat, CGFloat) = [progress copy];
                [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
                
                void (^handlerSuccess)(TAPMessageModel *) = [success copy];
                [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
                
                void (^handlerFailure)(NSError *) = [failure copy];
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
                          progress:(void (^)(CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendFileMessageWithFileURI:fileURI room:room start:start progress:progress success:success failure:failure];
}

- (void)sendForwardedMessage:(TAPMessageModel *)messageToForward
                        room:(TAPRoomModel *)room
                       start:(void (^)(TAPMessageModel *message))start
                    progress:(void (^)(CGFloat progress, CGFloat total))progress
                     success:(void (^)(TAPMessageModel *message))success
                     failure:(void (^)(NSError *error))failure {
    if (messageToForward.type == TAPChatMessageTypeFile || messageToForward.type == TAPChatMessageTypeVideo) {
        NSDictionary *dataDictionary = messageToForward.data;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:messageToForward.room.roomID fileID:fileID];
        filePath = [TAPUtil nullToEmptyString:filePath];
        
        if (![filePath isEqualToString:@""]) {
            [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToDictionaryWithFilePath:filePath roomID:messageToForward.room.roomID fileID:fileID];
        }
    }
    
    [[TAPChatManager sharedManager] saveToQuoteActionWithType:TAPChatManagerQuoteActionTypeForward roomID:room.roomID];
    [[TAPChatManager sharedManager] saveToQuotedMessage:messageToForward userInfo:[NSDictionary dictionary] roomID:room.roomID];
    [[TAPChatManager sharedManager] checkAndSendForwardedMessageWithRoom:room];
}

- (void)deleteLocalMessageWithLocalID:(NSString *)localID
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure {
    TAPMessageModel *message = [TAPMessageModel new];
    message.localID = localID;
    
    [TAPDataManager deleteDatabaseMessageWithData:@[message] success:^{
        success();
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)cancelMessageFileUpload:(TAPMessageModel *)message
                        success:(void (^)(void))success
                        failure:(void (^)(NSError *error))failure {
    if (message.type != TAPChatMessageTypeFile && message.type != TAPChatMessageTypeImage && message.type != TAPChatMessageTypeVideo) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90305 errorMessage:@"Invalid message type. Allowed types are image (1002), video (1003), or file (1004)"];
        failure(localizedError);
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
        failure(localizedError);
    }];
}

- (void)downloadMessageFile:(TAPMessageModel *)message
                      start:(void (^)(void))startBlock
                   progress:(void (^)(CGFloat progress, CGFloat total))progressBlock
                    success:(void (^)(NSData *fileData))successBlock
                    failure:(void (^)(NSError *error))failureBlock {
    if (message.type == TAPChatMessageTypeFile) {
        [[TAPFileDownloadManager sharedManager] receiveFileDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
            startBlock();
        } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
            progressBlock(progress, total);
        } success:^(NSData * _Nonnull fileData, TAPMessageModel * _Nonnull receivedMessage) {
            successBlock(fileData);
        } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failureBlock(localizedError);
        }];
    }
    else {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90305 errorMessage:@"Invalid message type. Allowed type is file (1004)"];
        failureBlock(localizedError);
    }
}

- (void)downloadMessageImage:(TAPMessageModel *)message
                      start:(void (^)(void))startBlock
                   progress:(void (^)(CGFloat progress, CGFloat total))progressBlock
                    success:(void (^)(NSData *fileData))successBlock
                    failure:(void (^)(NSError *error))failureBlock {
    if (message.type == TAPChatMessageTypeImage) {
        [[TAPFileDownloadManager sharedManager] receiveImageDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
            startBlock();
        } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
            progressBlock(progress, total);
        } success:^(UIImage * _Nonnull fullImage, TAPMessageModel * _Nonnull receivedMessage) {
            successBlock(fullImage);
        } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failureBlock(localizedError);
        }];
    }
    else {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90305 errorMessage:@"Invalid message type. Allowed type is image (1002)"];
        failureBlock(localizedError);
    }
}

- (void)downloadMessageVideo:(TAPMessageModel *)message
                       start:(void (^)(void))startBlock
                    progress:(void (^)(CGFloat progress, CGFloat total))progressBlock
                     success:(void (^)(NSData *fileData))successBlock
                     failure:(void (^)(NSError *error))failureBlock {
    if (message.type == TAPChatMessageTypeVideo) {
        [[TAPFileDownloadManager sharedManager] receiveVideoDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
            startBlock();
        } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
            progressBlock(progress, total);
        } success:^(NSData * _Nonnull fileData, TAPMessageModel * _Nonnull receivedMessage) {
            successBlock(fileData);
        } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failureBlock(localizedError);
        }];
    }
    else {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90305 errorMessage:@"Invalid message type. Allowed type is video (1003)"];
        failureBlock(localizedError);
    }
}

- (void)cancelMessageFileDownload:(TAPMessageModel *)message
                          success:(void (^)(void))success
                          failure:(void (^)(NSError *error))failure {
    if (message.type != TAPChatMessageTypeFile && message.type != TAPChatMessageTypeImage && message.type != TAPChatMessageTypeVideo) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90305 errorMessage:@"Invalid message type. Allowed types are image (1002), video (1003), or file (1004)"];
        failure(localizedError);
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
        failure(localizedError);
    }];
}

- (void)markMessageAsRead:(TAPMessageModel *)message {
    BOOL isRead = message.isRead;
    if(isRead) {
        return;
    }

     message.isRead = YES;
    [[TAPMessageStatusManager sharedManager] markMessageAsReadWithMessage:message];
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
            
        } failure:^(NSError *error) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failure(localizedError);
        }];
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

@end
