//
//  TAPCoreMessageManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 25/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAPCoreMessageManagerDelegate <NSObject>

- (void)tapTalkDidReceiveNewMessageInActiveRoom:(TAPMessageModel *)message;
- (void)tapTalkDidReceiveNewMessageInOtherRoom:(TAPMessageModel *)message;
- (void)tapTalkDidReceiveUpdateMessageInActiveRoom:(TAPMessageModel *)message;
- (void)tapTalkDidReceiveUpdateMessageInOtherRoom:(TAPMessageModel *)message;

@end

@interface TAPCoreMessageManager : NSObject

@property (weak, nonatomic) id<TAPCoreMessageManagerDelegate> delegate;

+ (TAPCoreMessageManager *)sharedManager;

- (void)sendTextMessage:(NSString *)message
                   room:(TAPRoomModel *)room
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(NSError *error))failure;
- (void)sendTextMessage:(NSString *)message
          quotedMessage:(TAPMessageModel *)quotedMessage
                   room:(TAPRoomModel *)room
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(NSError *error))failure;
- (void)sendLocationMessageWithLatitude:(CGFloat)latitude
                              longitude:(CGFloat)longitude
                                address:(nullable NSString *)address
                                   room:(TAPRoomModel *)room
                                  start:(void (^)(TAPMessageModel *message))start
                                success:(void (^)(TAPMessageModel *message))success
                                failure:(void (^)(NSError *error))failure;
- (void)sendLocationMessageWithLatitude:(CGFloat)latitude
                              longitude:(CGFloat)longitude
                           quotedMessage:(TAPMessageModel *)quotedMessage
                                address:(nullable NSString *)address
                                   room:(TAPRoomModel *)room
                                  start:(void (^)(TAPMessageModel *message))start
                                success:(void (^)(TAPMessageModel *message))success
                                failure:(void (^)(NSError *error))failure;
- (void)sendImageMessage:(UIImage *)image
                 caption:(nullable NSString *)caption
                    room:(TAPRoomModel *)room
                   start:(void (^)(TAPMessageModel *message))start
                progress:(void (^)(CGFloat progress, CGFloat total))progress
                 success:(void (^)(TAPMessageModel *message))success
                 failure:(void (^)(NSError *error))failure;
- (void)sendImageMessage:(UIImage *)image
           quotedMessage:(TAPMessageModel *)quotedMessage
                 caption:(nullable NSString *)caption
                    room:(TAPRoomModel *)room
                   start:(void (^)(TAPMessageModel *message))start
                progress:(void (^)(CGFloat progress, CGFloat total))progress
                 success:(void (^)(TAPMessageModel *message))success
                 failure:(void (^)(NSError *error))failure;
- (void)sendImageMessageWithAsset:(PHAsset *)asset
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(NSError *error))failure;
- (void)sendImageMessageWithAsset:(PHAsset *)asset
                    quotedMessage:(TAPMessageModel *)quotedMessage
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(NSError *error))failure;
- (void)sendVideoMessageWithAsset:(PHAsset *)asset
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(NSError *error))failure;
- (void)sendVideoMessageWithAsset:(PHAsset *)asset
                    quotedMessage:(TAPMessageModel *)quotedMessage
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(NSError *error))failure;
- (void)sendFileMessageWithFileURI:(NSURL *)fileURI
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(NSError *error))failure;
- (void)sendFileMessageWithFileURI:(NSURL *)fileURI
                     quotedMessage:(TAPMessageModel *)quotedMessage
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(NSError *error))failure;
- (void)sendForwardedMessage:(TAPMessageModel *)messageToForward
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(NSError *error))failure;
- (void)deleteLocalMessageWithLocalID:(NSString *)localID
              success:(void (^)(void))success
              failure:(void (^)(NSError *error))failure;
- (void)cancelMessageFileUpload:(TAPMessageModel *)message
                        success:(void (^)(void))success
                        failure:(void (^)(NSError *error))failure;
- (void)downloadMessageFile:(TAPMessageModel *)message
                      start:(void (^)(void))startBlock
                   progress:(void (^)(CGFloat progress, CGFloat total))progressBlock
                    success:(void (^)(NSData *fileData))successBlock
                    failure:(void (^)(NSError *error))failureBlock;
- (void)downloadMessageImage:(TAPMessageModel *)message
                       start:(void (^)(void))startBlock
                    progress:(void (^)(CGFloat progress, CGFloat total))progressBlock
                     success:(void (^)(UIImage *fullImage))successBlock
                     failure:(void (^)(NSError *error))failureBlock;
- (void)downloadMessageVideo:(TAPMessageModel *)message
                       start:(void (^)(void))startBlock
                    progress:(void (^)(CGFloat progress, CGFloat total))progressBlock
                     success:(void (^)(NSData *fileData))successBlock
                     failure:(void (^)(NSError *error))failureBlock;
- (void)cancelMessageFileDownload:(TAPMessageModel *)message
                          success:(void (^)(void))success
                          failure:(void (^)(NSError *error))failure;
- (void)markMessageAsRead:(TAPMessageModel *)message;
- (void)getOlderMessagesBeforeTimestamp:(NSNumber *)timestamp
                                 roomID:(NSString *)roomID
                          numberOfItems:(NSNumber *)numberOfItems
                                success:(void (^)(NSArray <TAPMessageModel *> *messageArray, BOOL hasMoreData))success
                                failure:(void (^)(NSError *error))failure;
- (void)getNewerMessagesAfterTimestamp:(NSNumber *)minCreatedTimestamp
                  lastUpdatedTimestamp:(NSNumber *)lastUpdatedTimestamp
                                roomID:(NSString *)roomID
                               success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                               failure:(void (^)(NSError *error))failure;
- (void)getNewerMessagesWithRoomID:(NSString *)roomID
                           success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                           failure:(void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
