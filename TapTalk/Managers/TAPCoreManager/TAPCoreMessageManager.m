//
//  TAPCoreMessageManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 25/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCoreMessageManager.h"
#import <TapTalk/Base64.h>

@interface TAPCoreMessageManager () <TAPChatManagerDelegate>

#define ITEM_LOAD_LIMIT 500

@property (strong, nonatomic) NSMutableDictionary *blockDictionary;
@property (strong, nonatomic) NSMutableArray<TAPMessageModel *> *pendingCallbackNewMessages;
@property (strong, nonatomic) NSMutableArray<TAPMessageModel *> *pendingCallbackUpdatedMessages;
@property (strong, nonatomic) NSMutableArray<TAPMessageModel *> *pendingCallbackDeletedMessages;
@property (strong, nonatomic) NSTimer *messageListenerBulkCallbackTimer;
@property (strong, nonatomic) NSTimer *updatedMessageListenerBulkCallbackTimer;
@property (strong, nonatomic) NSTimer *deletedMessageListenerBulkCallbackTimer;
@property (strong, nonatomic) NSNumber *imageHeight;
@property (strong, nonatomic) NSNumber *imageWidth;
@property (strong, nonatomic) NSNumber *fileSize;


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

- (void)sendLinkMessage:(NSString *)message
                   room:(TAPRoomModel *)room
                   urls:(NSArray<NSString *> *)urls
                   title:(NSString *)title
                   description:(NSString *)description
                  image:(NSString *_Nullable)image
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    NSString *firstUrl = [urls objectAtIndex:0];
    NSDictionary *messageData = @{@"url":firstUrl, @"urls":urls, @"title":title, @"description":description, @"image":image};
    [[TAPChatManager sharedManager] sendLinkMessage:message messageData:messageData room:room success:^(TAPMessageModel *message) {
        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
        [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
        start(message);
    }];
}

- (void)sendLinkMessage:(NSString *)message
                   room:(TAPRoomModel *)room
                   urls:(NSArray<NSString *> *)urls
                   title:(NSString *)title
                   description:(NSString *)description
                  image:(NSString *_Nullable)image
                  siteName:(NSString *_Nullable)siteName
                  type:(NSString *_Nullable)type
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    NSString *firstUrl = [urls objectAtIndex:0];
    NSDictionary *messageData = @{@"url":firstUrl, @"urls":urls, @"title":title, @"description":description, @"image":image, @"siteName":siteName, @"type":type};
    [[TAPChatManager sharedManager] sendLinkMessage:message messageData:messageData room:room success:^(TAPMessageModel *message) {
        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
        [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
        start(message);
    }];
}

- (void)sendLinkMessage:(NSString *)message
          quotedMessage:(TAPMessageModel *)quotedMessage
                   room:(TAPRoomModel *)room
                   urls:(NSArray<NSString *> *)urls
                   title:(NSString *)title
                   description:(NSString *)description
                  image:(NSString *_Nullable)image
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendLinkMessage:message room:room urls:urls title:title description:description image:image start:start success:success failure:failure];
}

- (void)sendLinkMessage:(NSString *)message
          quotedMessage:(TAPMessageModel *)quotedMessage
                   room:(TAPRoomModel *)room
                   urls:(NSArray<NSString *> *)urls
                   title:(NSString *)title
                   description:(NSString *)description
                  image:(NSString *_Nullable)image
                  siteName:(NSString *_Nullable)siteName
                  type:(NSString *_Nullable)type
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendLinkMessage:message room:room urls:urls title:title description:description image:image siteName:siteName type:type start:start success:success failure:failure];
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
    
   // [self sendCustomMessageWithMessageModel:message start:start success:success failure:failure];
}

- (void)sendImageMessageWithRemoteUrl:(NSString *)imageUrl
                              caption:(NSString *_Nullable)caption
                                 room:(TAPRoomModel *)room
                        fetchMetadata:(BOOL)fetchMetadata
              temporaryMessageCreated:(void (^)(TAPMessageModel *message))temporaryMessageCreated
                                start:(void (^)(TAPMessageModel *message))start
                              success:(void (^)(TAPMessageModel *message))success
                              failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    caption = [TAPUtil nullToEmptyString:caption];

    // Check if caption is longer than allowed max length
    NSInteger maxCaptionCharacterLength = [[TapTalk sharedInstance] getMaxCaptionLength];
    if ([caption length] > maxCaptionCharacterLength) {
        NSString *errorMessage = [NSString stringWithFormat:@"Media caption exceeds the %ld character limit", (long)maxCaptionCharacterLength];
        NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90306 errorMessage:errorMessage];
        failure(nil, error);
        return;
    }
    
    TAPMessageModel *quotedMessage = nil;
    id quote = [[TAPChatManager sharedManager] getQuotedMessageObjectWithRoomID:room.roomID];
    if ([quote isKindOfClass:[TAPMessageModel class]]) {
        quotedMessage = quote;
    }
    [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:room.roomID];
    
    TAPMessageModel *temporaryMessage = [self createTemporaryMediaMessageWithUrl:imageUrl type:TAPChatMessageTypeImage caption:caption room:room quotedMessage:quotedMessage];

    if (!fetchMetadata) {
        // Send message without metadata
        [self sendCustomMessageWithMessageModel:temporaryMessage start:start success:success failure:failure];
        return;
    }
    temporaryMessageCreated(temporaryMessage);
    NSMutableString *imageURL = [NSMutableString stringWithFormat:imageUrl];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:imageUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)[NSURL URLWithString:imageUrl], NULL);
                NSDictionary* imageHeader = (__bridge NSDictionary*) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
                NSLog(@"Image header %@",imageHeader);
                NSLog(@"PixelHeight %@",[imageHeader objectForKey:@"PixelHeight"]);

                NSNumber *height = [imageHeader objectForKey:@"PixelHeight"];
                NSNumber *width = [imageHeader objectForKey:@"PixelWidth"];
                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                _imageWidth = width;
                _imageHeight = height;

                NSURL *URL = [NSURL URLWithString:imageUrl];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                [request setHTTPMethod:@"HEAD"];
                NSHTTPURLResponse *response;
                [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: nil];
                long long size = [response expectedContentLength];
                _fileSize = @(size);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *data = [temporaryMessage.data mutableCopy];
                    [TAPUtil getImageFromRemoteUrl:imageUrl success:^(UIImage *image) {
                        [self resizeImage:image message:nil maxImageSize:TAP_MAX_THUMBNAIL_IMAGE_SIZE success:^(UIImage *resizedImage, TAPMessageModel *resultMessage) {
                            NSData *thumbnailImageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
                            NSString *thumbnailImageBase64String = [thumbnailImageData base64EncodedString];
                            [data setObject:thumbnailImageBase64String forKey:@"thumbnail"];
                            [data setObject:@(size) forKey:@"size"];
                            [data setObject:width forKey:@"width"];
                            [data setObject:height forKey:@"height"];
                            [data setObject:@"" forKey:@"fileID"];
                            temporaryMessage.data = [data copy];
                            [self sendCustomMessageWithMessageModel:temporaryMessage start:start success:success failure:failure];
                        }];
                    } failure:^(NSError *error) {
                        [self sendCustomMessageWithMessageModel:temporaryMessage start:start success:success failure:failure];
                    }];
                });
            }
        }];
    [task resume];
}

- (void)sendImageMessageWithRemoteUrl:(NSString *)imageUrl
                              caption:(NSString *_Nullable)caption
                                 room:(TAPRoomModel *)room
                        quotedMessage:(TAPMessageModel *)quotedMessage
                        fetchMetadata:(BOOL)fetchMetadata
              temporaryMessageCreated:(void (^)(TAPMessageModel *message))temporaryMessageCreated
                                start:(void (^)(TAPMessageModel *message))start
                              success:(void (^)(TAPMessageModel *message))success
                              failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendImageMessageWithRemoteUrl:imageUrl caption:caption room:room fetchMetadata:fetchMetadata temporaryMessageCreated:temporaryMessageCreated start:start success:success failure:failure];
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

- (void)sendVideoMessageWithRemoteUrl:(NSString *)videoUrl
                              caption:(nullable NSString *)caption
                                 room:(TAPRoomModel *)room
                        fetchMetaData:(BOOL)fetchMetaData
              temporaryMessageCreated:(void (^)(TAPMessageModel *message))temporaryMessageCreated
                                start:(void (^)(TAPMessageModel *message))start
                              success:(void (^)(TAPMessageModel *message))success
                              failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    caption = [TAPUtil nullToEmptyString:caption];
    NSURL *videoAssetURL = [NSURL URLWithString:videoUrl];
    
    // Check if caption is longer than allowed max length
    NSInteger maxCaptionCharacterLength = [[TapTalk sharedInstance] getMaxCaptionLength];
    if ([caption length] > maxCaptionCharacterLength) {
        NSString *errorMessage = [NSString stringWithFormat:@"Media caption exceeds the %ld character limit", (long)maxCaptionCharacterLength];
        NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90306 errorMessage:errorMessage];
        return;
    }
    
    NSArray *componentsArray = [videoUrl componentsSeparatedByString:@"."];
    NSString *fileExtension = [componentsArray lastObject];
    
    TAPMessageModel *quotedMessage = nil;
    id quote = [[TAPChatManager sharedManager] getQuotedMessageObjectWithRoomID:room.roomID];
    if ([quote isKindOfClass:[TAPMessageModel class]]) {
        quotedMessage = quote;
    }
    [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:room.roomID];
    
    TAPMessageModel *temporaryMessage = [self createTemporaryMediaMessageWithUrl:videoUrl type:TAPChatMessageTypeVideo caption:caption room:room quotedMessage:quotedMessage];
    
    if (!fetchMetaData) {
        [self sendCustomMessageWithMessageModel:temporaryMessage start:start success:success failure:failure];
        return;
    }
    
    temporaryMessageCreated(temporaryMessage);
    
    [TAPUtil fetchVideoMetadataWithRemoteURL:videoUrl success:^(UIImage * _Nullable thumbnail, NSNumber * _Nonnull size, NSNumber * _Nonnull width, NSNumber * _Nonnull height, NSNumber * _Nonnull duration) {
        
        NSMutableDictionary *data = [temporaryMessage.data mutableCopy];
        
       // [data setObject:thumbnailImageBase64String forKey:@"thumbnail"];
        [data setObject:size forKey:@"size"];
        [data setObject:width forKey:@"width"];
        [data setObject:height forKey:@"height"];
        [data setObject:duration forKey:@"duration"];
        [data setObject:@"" forKey:@"fileID"];
        if (thumbnail != nil) {
            [self resizeImage:thumbnail message:nil maxImageSize:TAP_MAX_THUMBNAIL_IMAGE_SIZE success:^(UIImage *resizedImage, TAPMessageModel *resultMessage) {
                NSData *thumbnailImageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
                NSString *thumbnailImageBase64String = [thumbnailImageData base64EncodedString];
                [data setObject:thumbnailImageBase64String forKey:@"thumbnail"];
                temporaryMessage.data = [data copy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendCustomMessageWithMessageModel:temporaryMessage start:start success:success failure:failure];
                });
            }];
        }
        else {
            temporaryMessage.data = [data copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendCustomMessageWithMessageModel:temporaryMessage start:start success:success failure:failure];
            });
        }
    }];
}

- (void)sendVideoMessageWithRemoteUrl:(NSString *)videoUrl
                              caption:(nullable NSString *)caption
                                 room:(TAPRoomModel *)room
                        quotedMessage:(TAPMessageModel *)quotedMessage
                        fetchMetaData:(BOOL)fetchMetaData
              temporaryMessageCreated:(void (^)(TAPMessageModel *message))temporaryMessageCreated
                                start:(void (^)(TAPMessageModel *message))start
                              success:(void (^)(TAPMessageModel *message))success
                              failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendVideoMessageWithRemoteUrl:videoUrl caption:caption room:room fetchMetaData:fetchMetaData temporaryMessageCreated:temporaryMessageCreated start:start success:success failure:failure];
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

- (void)sendFileMessageWithRemoteUrl:(NSString *)fileUrl
                             caption:(nullable NSString *)caption
                                room:(TAPRoomModel *)room
                       fetchMetadata:(BOOL)fetchMetadata
             temporaryMessageCreated:(void (^)(TAPMessageModel *message))temporaryMessageCreated
                               start:(void (^)(TAPMessageModel *message))start
                             success:(void (^)(TAPMessageModel *message))success
                             failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    [self sendFileMessageWithRemoteUrl:fileUrl caption:caption room:room fileName:@"" mimeType:@"" fetchMetadata:fetchMetadata temporaryMessageCreated:temporaryMessageCreated start:start success:success failure:failure];
}

- (void)sendFileMessageWithRemoteUrl:(NSString *)fileUrl
                             caption:(nullable NSString *)caption
                                room:(TAPRoomModel *)room
                       quotedMessage:(TAPMessageModel *)quotedMessage
                       fetchMetadata:(BOOL)fetchMetadata
             temporaryMessageCreated:(void (^)(TAPMessageModel *message))temporaryMessageCreated
                               start:(void (^)(TAPMessageModel *message))start
                             success:(void (^)(TAPMessageModel *message))success
                             failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendFileMessageWithRemoteUrl:fileUrl caption:caption room:room fetchMetadata:fetchMetadata temporaryMessageCreated:temporaryMessageCreated start:start success:success failure:failure];
}

- (void)sendFileMessageWithRemoteUrl:(NSString *)fileUrl
                             caption:(nullable NSString *)caption
                                room:(TAPRoomModel *)room
                            fileName:(NSString *)fileName
                            mimeType:(NSString *)mimeType
                       fetchMetadata:(BOOL)fetchMetadata
             temporaryMessageCreated:(void (^)(TAPMessageModel *message))temporaryMessageCreated
                               start:(void (^)(TAPMessageModel *message))start
                             success:(void (^)(TAPMessageModel *message))success
                             failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    caption = [TAPUtil nullToEmptyString:caption];
    
    // Check if caption is longer than allowed max length
    NSInteger maxCaptionCharacterLength = [[TapTalk sharedInstance] getMaxCaptionLength];
    if ([caption length] > maxCaptionCharacterLength) {
        NSString *errorMessage = [NSString stringWithFormat:@"Media caption exceeds the %ld character limit", (long)maxCaptionCharacterLength];
        NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90306 errorMessage:errorMessage];
        failure(nil, error);
        return;
    }
    
    TAPMessageModel *quotedMessage = nil;
    id quote = [[TAPChatManager sharedManager] getQuotedMessageObjectWithRoomID:room.roomID];
    if ([quote isKindOfClass:[TAPMessageModel class]]) {
        quotedMessage = quote;
    }
    [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:room.roomID];

    TAPMessageModel *temporaryMessage = [self createTemporaryMediaMessageWithUrl:fileUrl type:TAPChatMessageTypeFile caption:caption fileName:fileName mimeType:mimeType room:room quotedMessage:quotedMessage];

    if (!fetchMetadata) {
        // Send message without metadata
        [self sendCustomMessageWithMessageModel:temporaryMessage start:start success:success failure:failure];
        return;
    }
    temporaryMessageCreated(temporaryMessage);

    NSURL *url = [NSURL URLWithString:fileUrl];
    NSString *filenameWithExtension = [url lastPathComponent];
    NSMutableDictionary *data = [temporaryMessage.data mutableCopy];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:fileUrl] completionHandler:^(NSData * _Nullable fileData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (fileData) {
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPMethod:@"HEAD"];
                NSHTTPURLResponse *response;
                [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: nil];
                long long size = [response expectedContentLength];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [data setObject:@(size) forKey:@"size"];
                    if ([TAPUtil isEmptyString:fileName]) {
                        [data setObject:filenameWithExtension forKey:@"fileName"];
                    }
                    else {
                        [data setObject:fileName forKey:@"fileName"];
                    }
                    if (![TAPUtil isEmptyString:mimeType]) {
                        [data setObject:mimeType forKey:@"mediaType"];
                    }
                    [data setObject:@"" forKey:@"fileID"];
                    temporaryMessage.data = [data copy];
                    [self sendCustomMessageWithMessageModel:temporaryMessage start:start success:success failure:failure];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendCustomMessageWithMessageModel:temporaryMessage start:start success:success failure:failure];
                });
            }
        }];

    [task resume];
}

- (void)sendFileMessageWithRemoteUrl:(NSString *)fileUrl
                             caption:(nullable NSString *)caption
                                room:(TAPRoomModel *)room
                       quotedMessage:(TAPMessageModel *)quotedMessage
                            fileName:(NSString *)fileName
                            mimeType:(NSString *)mimeType
                       fetchMetadata:(BOOL)fetchMetadata
             temporaryMessageCreated:(void (^)(TAPMessageModel *message))temporaryMessageCreated
                               start:(void (^)(TAPMessageModel *message))start
                             success:(void (^)(TAPMessageModel *message))success
                             failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendFileMessageWithRemoteUrl:fileUrl caption:caption room:room fileName:fileName mimeType:mimeType fetchMetadata:fetchMetadata temporaryMessageCreated:temporaryMessageCreated start:start success:success failure:failure];
}

- (void)sendVoiceMessageWithFileURI:(NSURL *)fileURI
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
            
            [[TAPChatManager sharedManager] sendVoiceMessageWithVoiceAssetURL:dataFile filePath:filePath fileURL:fileURI room:room successGenerateMessage:^(TAPMessageModel *message) {
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

- (void)sendVoiceMessageWithFileURI:(NSURL *)fileURI
                     quotedMessage:(TAPMessageModel *)quotedMessage
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessage userInfo:nil roomID:room.roomID];
    [self sendVoiceMessageWithFileURI:fileURI room:room start:start progress:progress success:success failure:failure];
}

- (void)sendForwardedMessage:(TAPMessageModel *)messageToForward
                        room:(TAPRoomModel *)room
                       start:(void (^)(TAPMessageModel *message))start
                    progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                     success:(void (^)(TAPMessageModel *message))success
                     failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    if (messageToForward.type == TAPChatMessageTypeFile || messageToForward.type == TAPChatMessageTypeVideo || messageToForward.type == TAPChatMessageTypeVideo) {
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

- (void)sendForwardedMessageWithMessageArray:(NSArray<TAPMessageModel*> *)messageArray
                                        room:(TAPRoomModel *)room
                                       start:(void (^)(TAPMessageModel *message))start
                                    progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                                     success:(void (^)(TAPMessageModel *message))success
                                     failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    for (TAPMessageModel *messageToForward in messageArray) {
        [self sendForwardedMessage:messageToForward room:room start:start progress:progress success:success failure:failure];
    }
}

- (void)sendForwardedMessage:(TAPMessageModel *)messageToForward
             toMultipleRooms:(NSArray<TAPRoomModel*> *)rooms
                       start:(void (^)(TAPMessageModel *message))start
                    progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                     success:(void (^)(TAPMessageModel *message))success
                     failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {

    for (TAPRoomModel *room in rooms) {
        [self sendForwardedMessage:messageToForward room:room start:start progress:progress success:success failure:failure];
    }
}

- (void)sendForwardedMessageWithMessageArray:(NSArray<TAPMessageModel*> *)messageArray
                             toMultipleRooms:(NSArray<TAPRoomModel*> *)rooms
                                       start:(void (^)(TAPMessageModel *message))start
                                    progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                                     success:(void (^)(TAPMessageModel *message))success
                                     failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    for (TAPRoomModel *room in rooms) {
        [self sendForwardedMessageWithMessageArray:messageArray room:room start:start progress:progress success:success failure:failure];
    }
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
           progress:(void (^)(CGFloat progress, CGFloat total))progress
            success:(void (^)(NSString *fileID, NSString *fileURL))success
            failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
    void (^handlerProgress)(CGFloat, CGFloat) = [progress copy];
    [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
    [self.blockDictionary setObject:blockTypeDictionary forKey:@"uploadImage"];
    
    [[TAPFileUploadManager sharedManager]uploadImage:image success:^(NSString * _Nonnull fileID, NSString * _Nonnull fileURL) {
        success(fileID, fileURL);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)uploadFile:(NSURL *)url
            progress:(void (^)(CGFloat progress, CGFloat total))progress
            success:(void (^)(NSString *fileID, NSString *fileURL))success
            failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
    void (^handlerProgress)(CGFloat, CGFloat) = [progress copy];
    [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
    [self.blockDictionary setObject:blockTypeDictionary forKey:@"uploadFie"];
    
    [[TAPFileUploadManager sharedManager]uploadFile:url success:^(NSString * _Nonnull fileID, NSString * _Nonnull fileURL) {
        success(fileID, fileURL);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)uploadVideo:(NSURL *)url
           progress:(void (^)(CGFloat progress, CGFloat total))progress
            success:(void (^)(NSString *fileID, NSString *fileURL))success
            failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
    void (^handlerProgress)(CGFloat, CGFloat) = [progress copy];
    [blockTypeDictionary setObject:handlerProgress forKey:@"progressBlock"];
    [self.blockDictionary setObject:blockTypeDictionary forKey:@"uploadVideo"];
    
    [[TAPFileUploadManager sharedManager]uploadVideo:url success:^(NSString * _Nonnull fileID, NSString * _Nonnull fileURL) {
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
    [[TAPMessageStatusManager sharedManager] markMessageAsDeliveredWithMessage:message];
    message.isDelivered = YES;
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
    [[TAPMessageStatusManager sharedManager] markMessageAsReadWithMessage:message];
    message.isRead = YES;
}

- (void)markMessagesAsRead:(NSArray<TAPMessageModel *> *)messageArray {
    for (TAPMessageModel *message in messageArray) {
        [self markMessageAsRead:message];
    }
}

- (void)markMessagesAsRead:(NSArray<TAPMessageModel *> *)messageArray
                   success:(void (^)(NSArray <NSString *> *updatedMessageIDs))success
                   failure:(void (^)(NSError *error))failure {
    
    NSMutableArray *filteredMessageArray = [NSMutableArray array];
    TAPUserModel *activeUser = [[TAPChatManager sharedManager] activeUser];
    for (TAPMessageModel *message in messageArray) {
        if (activeUser != nil &&
            message.user != nil &&
            ![TAPUtil isEmptyString:activeUser.userID] &&
            ![TAPUtil isEmptyString:message.user.userID] &&
            ![message.user.userID isEqualToString:activeUser.userID]
        ) {
            [filteredMessageArray addObject:message];
        }
    }
    
    if ([filteredMessageArray count] == 0) {
        return;
    }
    
    [TAPDataManager callAPIUpdateMessageReadStatusWithArray:filteredMessageArray
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
    [[TAPCoreRoomListManager sharedManager] removeUnreadMarkFromChatRoom:roomID success:^{
        
    }
    failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)markAllMessagesInRoomAsReadWithRoomID:(NSString *)roomID
                                      success:(void (^)(NSArray <NSString *> *updatedMessageIDs))success
                                      failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:roomID
                                                 activeUserID:[TAPChatManager sharedManager].activeUser.userID
    success:^(NSArray *unreadMessages) {
        if ([unreadMessages count] == 0) {
            success([NSArray array]);
        }
        else {
            [self markMessagesAsRead:unreadMessages success:success failure:failure];
        }
    }
    failure:^(NSError *error) {
        failure(error);
    }];
    [[TAPCoreRoomListManager sharedManager] removeUnreadMarkFromChatRoom:roomID success:^{
        
    }
    failure:^(NSError * _Nonnull error) {
        
    }];
}

//- (void)markLastMessageInRoomAsReadWithRoomID:(NSString *)roomID {
//    NSMutableArray *unreadRoomIDs = [[TAPDataManager getUnreadRoomIDs] mutableCopy];
//    if ([unreadRoomIDs containsObject:roomID]) {
//        [TAPDataManager getMessageWithRoomID:roomID lastMessageTimeStamp:[TAPUtil currentTimeInMillis] limitData:1 success:^(NSArray<TAPMessageModel *> *obtainedMessageArray) {
//
//            if ([obtainedMessageArray count] > 0) {
//                NSArray<TAPMessageModel *> *selectedMessageArray = @[[obtainedMessageArray objectAtIndex:0]];
//                [[TAPCoreMessageManager sharedManager] markMessagesAsRead:selectedMessageArray success:^(NSArray<NSString *> *updatedMessageIDs){
//
//                 } failure:^(NSError *error) {
//
//                 }];
//                [unreadRoomIDs removeObject:roomID];
//                [TAPDataManager setUnreadRoomIDs:unreadRoomIDs];
//            }
//        } failure:^(NSError *error) {
//
//        }];
//    }
//}

- (void)getLocalMessagesWithRoomID:(NSString *)roomID
                           success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                           failure:(void (^)(NSError *error))failure {

    [self getLocalMessagesWithRoomID:roomID excludeHidden:NO success:success failure:failure];
}

- (void)getLocalMessagesWithRoomID:(NSString *)roomID
                     excludeHidden:(BOOL)excludeHidden
                           success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                           failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager getAllMessageWithRoomID:roomID
                                  sortByKey:@"created"
                                  ascending:NO
                              excludeHidden:excludeHidden
    success:^(NSArray<TAPMessageModel *> *messageArray) {
        success(messageArray);
    }
    failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getLocalMessagesWithRoomID:(NSString *)roomID
               maxCreatedTimestamp:(NSNumber *)maxCreatedTimestamp
                     numberOfItems:(NSInteger)numberOfItems
                           success:(void (^)(NSArray<TAPMessageModel *> *obtainedMessageArray))success
                           failure:(void (^)(NSError *error))failure {

    [self getLocalMessagesWithRoomID:roomID maxCreatedTimestamp:maxCreatedTimestamp numberOfItems:numberOfItems excludeHidden:NO success:success failure:failure];
}

- (void)getLocalMessageWithLocalID:(NSString *)localID
                           success:(void (^)(NSArray<TAPMessageModel *> *obtainedMessageArray))success
                           failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager getMessageFromDatabaseWithLocalID:localID
    success:^(NSArray<TAPMessageModel *> *resultArray) {
        success(resultArray);
    }
    failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getLocalMessageWithLocalIDs:(NSArray<NSString *> *)localIDs
                            success:(void (^)(NSArray<TAPMessageModel *> *obtainedMessageArray))success
                            failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager getMessageFromDatabaseWithLocalIDs:localIDs
    success:^(NSArray<TAPMessageModel *> *resultArray) {
        success(resultArray);
    }
    failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)getLocalMessagesWithRoomID:(NSString *)roomID
               maxCreatedTimestamp:(NSNumber *)maxCreatedTimestamp
                     numberOfItems:(NSInteger)numberOfItems
                     excludeHidden:(BOOL)excludeHidden
                           success:(void (^)(NSArray<TAPMessageModel *> *obtainedMessageArray))success
                           failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager getMessageWithRoomID:roomID
                    lastMessageTimeStamp:maxCreatedTimestamp
                               limitData:numberOfItems
                           excludeHidden:excludeHidden
    success:^(NSArray<TAPMessageModel *> *obtainedMessageArray) {
        success(obtainedMessageArray);
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
        NSNumber *lastUpdated = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];
        if ([lastUpdated longValue] == 0L) {
            lastUpdated = minCreated;
        }
        [TAPDataManager callAPIGetMessageAfterWithRoomID:roomID minCreated:minCreated lastUpdated:lastUpdated needToSaveLastUpdatedTimestamp:YES success:^(NSArray *messageArray) {
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

- (void)getStarredMessagesWithRoomID:(NSString *)roomID
                          pageNumber:(NSInteger)pageNumber
                       numberOfItems:(NSInteger)numberOfItems
                         success:(void (^)(NSArray<TAPMessageModel *> *starredMessagesArray,BOOL hasMoreData))success
                         failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIGetStarredMessages:roomID pageNumber:pageNumber numberOfItems:numberOfItems
    success:^(NSArray *starredMessagesArray,BOOL hasMore) {
        success(starredMessagesArray,hasMore);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getStarredMessageIDsWithRoomID:(NSString *)roomID
                         success:(void (^)(NSArray<NSString *> *starredMessagesIDs))success
                         failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIGetStarredMessageIDs:roomID
    success:^(NSArray *starredMessagesIDs) {
        success(starredMessagesIDs);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)starMessageWithMessageID:(NSString *)messageID roomID:(NSString *)roomID{
    [self starMessageWithMessageID:messageID roomID:roomID
    success:^(NSArray<NSString *> *starredMessagesIDs) {
        
    }
    failure:^(NSError *error) {
        
    }];
}

- (void)starMessageWithMessageID:(NSString *)messageID
                          roomID:(NSString *)roomID
                         success:(void (^)(NSArray<NSString *> *starredMessagesIDs))success
                         failure:(void (^)(NSError *error))failure {
    NSArray<NSString *> *messageIDs = @[messageID];
    [self starMessagesWithMessageIDs:messageIDs roomID:roomID success:success failure:failure];
}

- (void)starMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs roomID:(NSString *)roomID {
    [self starMessagesWithMessageIDs:messageIDs roomID:roomID
    success:^(NSArray<NSString *> *starredMessagesIDs) {
        
    }
    failure:^(NSError *error) {
        
    }];
}

- (void)starMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs
                            roomID:(NSString *)roomID
                           success:(void (^)(NSArray<NSString *> *starredMessagesIDs))success
                           failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIStarMessage:roomID messageID:messageIDs
    success:^(NSArray *starredMessageIDs) {
        success(starredMessageIDs);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)unstarMessageWithMessageID:(NSString *)messageID roomID:(NSString *)roomID{
    [self unstarMessageWithMessageID:messageID roomID:roomID
    success:^(NSArray<NSString *> *starredMessagesIDs) {
        
    }
    failure:^(NSError *error) {
        
    }];
}

- (void)unstarMessageWithMessageID:(NSString *)messageID
                            roomID:(NSString *)roomID
                           success:(void (^)(NSArray<NSString *> *starredMessagesIDs))success
                           failure:(void (^)(NSError *error))failure {
    NSArray<NSString *> *messageIDs = @[messageID];
    [self unstarMessagesWithMessageIDs:messageIDs roomID:roomID success:success failure:failure];
}

- (void)unstarMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs roomID:(NSString *)roomID {
    [self unstarMessagesWithMessageIDs:messageIDs roomID:roomID
    success:^(NSArray<NSString *> *starredMessagesIDs) {
        
    }
    failure:^(NSError *error) {
        
    }];
}

- (void)unstarMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs
                              roomID:(NSString *)roomID
                             success:(void (^)(NSArray<NSString *> *unstarredMessagesIDs))success
                             failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIUnStarMessage:roomID messageID:messageIDs
    success:^(NSArray *starredMessageIDs) {
        success(starredMessageIDs);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)editMessage:(TAPMessageModel *)previousMessage
        updatedText:(NSString *)updatedMessage
            start:(void (^)(TAPMessageModel *message))start
            success:(void (^)(TAPMessageModel *message))success
            failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    [[TAPChatManager sharedManager] editMessage:previousMessage
                                           updatedText:updatedMessage isMessageTypeChange:NO
    start:^(TAPMessageModel * _Nonnull message) {
        start(message);
    }
    success:^(TAPMessageModel * _Nonnull message) {
        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
        [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
    }
    failure:^(TAPMessageModel * _Nullable message, NSError *error) {
        failure(message,error);
    }];
    
   
}

- (void)editMessage:(TAPMessageModel *)updatedMessage
            start:(void (^)(TAPMessageModel *message))start
            success:(void (^)(TAPMessageModel *message))success
            failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure {
    
    [[TAPChatManager sharedManager] editMessage:updatedMessage
    start:^(TAPMessageModel * _Nonnull message) {
        start(message);
    }
    success:^(TAPMessageModel * _Nonnull message) {
        void (^handlerSuccess)(TAPMessageModel *) = [success copy];
        NSMutableDictionary *blockTypeDictionary = [[NSMutableDictionary alloc] init];
        [blockTypeDictionary setObject:handlerSuccess forKey:@"successBlock"];
        [self.blockDictionary setObject:blockTypeDictionary forKey:message.localID];
    }
    failure:^(TAPMessageModel * _Nullable message, NSError *error) {
        failure(message,error);
    }];
    
   
}

- (void)pinMessageWithMessageID:(NSString *)messageID roomID:(NSString *)roomID{
    [self pinMessagesWithMessageIDs:@[messageID] roomID:roomID
    success:^(NSArray<NSString *> *pinnedMessagesIDs) {
        
    }
    failure:^(NSError *error) {
        
    }];
}

- (void)pinMessageWithMessageID:(NSString *)messageID
                          roomID:(NSString *)roomID
                         success:(void (^)(NSArray<NSString *> *pinnedMessagesIDs))success
                         failure:(void (^)(NSError *error))failure {
    NSArray<NSString *> *messageIDs = @[messageID];
    [self pinMessagesWithMessageIDs:messageIDs roomID:roomID success:success failure:failure];
}

- (void)pinMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs roomID:(NSString *)roomID {
    [self pinMessagesWithMessageIDs:messageIDs roomID:roomID
    success:^(NSArray<NSString *> *pinnedMessagesIDs) {
        
    }
    failure:^(NSError *error) {
        
    }];
}

- (void)pinMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs
                            roomID:(NSString *)roomID
                           success:(void (^)(NSArray<NSString *> *pinnedMessagesIDs))success
                           failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIPinMessage:roomID messageID:messageIDs
    success:^(NSArray *pinnedMessageIDs) {
        success(pinnedMessageIDs);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)unpinMessageWithMessageID:(NSString *)messageID roomID:(NSString *)roomID{
    [self unpinMessageWithMessageID:messageID roomID:roomID
    success:^(NSArray<NSString *> *unpinnedMessageIDs) {
        
    }
    failure:^(NSError *error) {
        
    }];
}

- (void)unpinMessageWithMessageID:(NSString *)messageID
                            roomID:(NSString *)roomID
                           success:(void (^)(NSArray<NSString *> *unpinnedMessageIDs))success
                           failure:(void (^)(NSError *error))failure {
    NSArray<NSString *> *messageIDs = @[messageID];
    [self unpinMessagesWithMessageIDs:messageIDs roomID:roomID success:success failure:failure];
}

- (void)unpinMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs roomID:(NSString *)roomID {
    [self unpinMessagesWithMessageIDs:messageIDs roomID:roomID
    success:^(NSArray<NSString *> *unpinnedMessageIDs) {
        
    }
    failure:^(NSError *error) {
        
    }];
}

- (void)unpinMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs
                              roomID:(NSString *)roomID
                             success:(void (^)(NSArray<NSString *> *unpinnedMessageIDs))success
                             failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIUnPinMessage:roomID messageID:messageIDs
    success:^(NSArray *unpinnedMessageIDs) {
        success(unpinnedMessageIDs);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getPinnedMessagesWithRoomID:(NSString *)roomID
                          pageNumber:(NSInteger)pageNumber
                       numberOfItems:(NSInteger)numberOfItems
                         success:(void (^)(NSArray<TAPMessageModel *> *pinnedMessagesArray,BOOL hasMoreData))success
                         failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIGetPinnedMessages:roomID pageNumber:pageNumber numberOfItems:numberOfItems
    success:^(NSArray *pinnedMessagesArray,BOOL hasMore) {
        success(pinnedMessagesArray,hasMore);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getPinnedMessageIDsWithRoomID:(NSString *)roomID
                         success:(void (^)(NSArray<NSString *> *pinnedMessagesIDs))success
                         failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIGetPinnedMessageIDs:roomID
    success:^(NSArray *pinnedMessagesIDs) {
        success(pinnedMessagesIDs);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)createScheduleMessage:(TAPMessageModel *)message scheduleTime:(NSNumber *)scheduleTime success:(void (^)(TAPMessageModel *message))success failure:(void (^)(NSError *error))failure {
    NSDictionary *encryptedMessageDictionary = [TAPEncryptorManager encryptToDictionaryFromMessageModelForAPI:message];
    [TAPDataManager callAPICreateScheduleMessage:encryptedMessageDictionary scheduledTime:scheduleTime success:^(TAPMessageModel *scheduledMessage) {
        success(scheduledMessage);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (void)getScheduledMessagesWithRoomID:(NSString *)roomID
                         success:(void (^)(NSArray<TAPScheduledMessageModel *> *scheduleMessageArray))success
                         failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIGetScheduleMessage:roomID
    success:^(NSArray<TAPScheduledMessageModel *> *scheduleMessageArray) {
        success(scheduleMessageArray);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)sendScheduledMessagesNow:(NSArray<NSNumber *> *)scheduleIDs roomID:(NSString *)roomID
                         success:(void (^)(NSArray<NSNumber *> *sentIDs))success
                         failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIScheduleMessageSendNow:scheduleIDs roomID:roomID
    success:^(NSArray<NSNumber *> *sentIDs) {
        success(sentIDs);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)sendScheduledMessageNow:(NSNumber *)scheduleID roomID:(NSString *)roomID
                         success:(void (^)(NSArray<NSNumber *> *sentIDs))success
                         failure:(void (^)(NSError *error))failure {
    [self sendScheduledMessagesNow:@[scheduleID] roomID:roomID success:^(NSArray<NSNumber *> *sentIDs) {
        success(sentIDs);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)editScheduledMessageTime:(NSNumber *)scheduleID scheduledTime:(NSNumber *)scheduledTime
                         success:(void (^)(BOOL isEditTimeSuccess))success
                         failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIEditScheduleMessageTime:scheduleID scheduledTime:scheduledTime success:^(BOOL isEditTimeSuccess) {
        success(isEditTimeSuccess);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)editScheduledMessageContent:(NSNumber *)scheduleID updatedMessage:(TAPMessageModel *)updatedMessage
                         success:(void (^)(BOOL isEditContentSuccess))success
                         failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIEditScheduleMessageContent:scheduleID updatedMessage:updatedMessage success:^(BOOL isEditContentSuccess) {
        success(isEditContentSuccess);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)deleteScheduledMessages:(NSArray<NSNumber *> *)scheduleIDs roomID:(NSString *)roomID
                         success:(void (^)(NSArray<NSNumber *> *deletedIDs))success
                         failure:(void (^)(NSError *error))failure {
    
    [TAPDataManager callAPIDeleteScheduleMessage:scheduleIDs roomID:roomID
    success:^(NSArray<NSNumber *> *deletedIDs) {
        success(deletedIDs);
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)deleteScheduledMessage:(NSNumber *)scheduleID roomID:(NSString *)roomID
                                    success:(void (^)(NSArray<NSNumber *> *deletedIDs))success
                                    failure:(void (^)(NSError *error))failure {
    [self deleteScheduledMessages:@[scheduleID] roomID:roomID success:^(NSArray<NSNumber *> *deletedIDs) {
        success(deletedIDs);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (void)getSharedContentMessagesWithRoomID:(NSString *)roomID maxCreated:(long)maxCreated minCreated:(long)minCreated
                           success:(void (^)(NSArray <TAPMessageModel *> *mediaMessagesArray, NSArray <TAPMessageModel *> *fileMessagesArray, NSArray <TAPMessageModel *> *linkMessagesArray))success
                           failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetSharedContent:roomID maxCreated:maxCreated  minCreated:minCreated success:^(NSArray <TAPMessageModel *> *mediaMessagesArray, NSArray <TAPMessageModel *> *linkMessagesArray, NSArray <TAPMessageModel *> *fileMessagesArray) {
        success(mediaMessagesArray, fileMessagesArray, linkMessagesArray);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (void)getMessageDetails:(NSString *)messageID
                  success:(void (^)(TAPMessageModel *message, NSArray <TapMessageRecipientModel *> *deliveredTo, NSArray <TapMessageRecipientModel *> *readBy))success
                  failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetMessageDetails:messageID success:^(TAPMessageModel *message, NSArray<TapMessageRecipientModel *> *deliveredTo, NSArray<TapMessageRecipientModel *> *readBy) {
        success(message, deliveredTo, readBy);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getMessageTotalRead:(NSString *)messageID
                  success:(void (^)(NSInteger readCount))success
                  failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetMessageTotalRead:messageID success:^(NSInteger readCount) {
        success(readCount);
    } failure:^(NSError *error) {
        failure(error);
    }];
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

- (TAPMessageModel *)createTemporaryMediaMessageWithUrl:(NSString *)url
                                                   type:(NSInteger)type
                                                caption:(NSString *)caption
                                                   room:(TAPRoomModel *)room
                                          quotedMessage:(TAPMessageModel *_Nullable)quotedMessage {
    
    return [self createTemporaryMediaMessageWithUrl:url type:type caption:caption fileName:@"" mimeType:@"" room:room quotedMessage:quotedMessage];
}

- (TAPMessageModel *)createTemporaryMediaMessageWithUrl:(NSString *)url
                                                   type:(NSInteger)type
                                                caption:(NSString *)caption
                                               fileName:(NSString *)fileName
                                               mimeType:(NSString *)mimeType
                                                   room:(TAPRoomModel *)room
                                          quotedMessage:(TAPMessageModel *_Nullable)quotedMessage {
    
    NSString *body = @"";
    if (type == TAPChatMessageTypeImage) {
        if ([TAPUtil isEmptyString:caption]) {
            body = @"🖼 Photo";
        }
        else {
            body = [NSString stringWithFormat:@"🖼 %@", caption];
        }
    }
    else if (type == TAPChatMessageTypeVideo) {
        if ([TAPUtil isEmptyString:caption]) {
            body = @"🎥 Video";
        }
        else {
            body = [NSString stringWithFormat:@"🎥 %@", caption];
        }
    }
    else if (type == TAPChatMessageTypeFile) {
        if ([TAPUtil isEmptyString:caption]) {
            body = @"📎 File";
        }
        else {
            body = [NSString stringWithFormat:@"📎 %@", caption];
        }
    }
    else if (type == TAPChatMessageTypeVoice) {
        if ([TAPUtil isEmptyString:caption]) {
            body = @"🎤 Voice";
        }
        else {
            body = [NSString stringWithFormat:@"🎤 %@", caption];
        }
    }
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:url forKey:@"url"];
    [data setObject:@"" forKey:@"fileID"];
    caption = [TAPUtil nullToEmptyString:caption];
    [data setObject:caption forKey:@"caption"];
    if (![TAPUtil isEmptyString:fileName]) {
        [data setObject:fileName forKey:@"fileName"];
    }
    if (![TAPUtil isEmptyString:mimeType]) {
        [data setObject:mimeType forKey:@"mediaType"];
    }
    else {
        NSString *mediaType = [TAPUtil mimeTypeForFileWithExtension:[url pathExtension]];
        
        if ([TAPUtil isEmptyString:mediaType]) {
            if (type == TAPChatMessageTypeImage) {
                mediaType = @"image/jpeg";
            }
            else if(type == TAPChatMessageTypeVideo) {
                mediaType = @"video/mp4";
            }
            else if(type == TAPChatMessageTypeVoice) {
                mediaType = @"audio/mp3";
            }
            else {
                mediaType = @"application/octet-stream";
            }
        }
        [data setObject:mediaType forKey:@"mediaType"];
    }
    
    id userInfo = [[TAPChatManager sharedManager].userInfoDictionary objectForKey:room.roomID];
    if (userInfo != nil) {
        [data setObject:userInfo forKey:@"userInfo"];
    }
    
    if (quotedMessage != nil) {
        TAPMessageModel *message = [self constructTapTalkMessageModelWithRoom:room quotedMessage:quotedMessage messageBody:body messageType:type messageData:data];
        return message;
    }
    else {
        TAPMessageModel *message = [self constructTapTalkMessageModelWithRoom:room messageBody:body messageType:type messageData:data];
        return message;
    }
}

@end
