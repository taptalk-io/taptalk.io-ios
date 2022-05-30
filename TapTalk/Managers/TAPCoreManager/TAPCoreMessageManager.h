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

- (void)tapTalkDidReceiveNewMessage:(TAPMessageModel *)message;
- (void)tapTalkDidReceiveNewMessages:(NSArray <TAPMessageModel *> *)messages;
- (void)tapTalkDidReceiveUpdatedMessage:(TAPMessageModel *)message;
- (void)tapTalkDidReceiveUpdatedMessages:(NSArray <TAPMessageModel *> *)messages;
- (void)tapTalkDidDeleteMessage:(TAPMessageModel *)message;
- (void)tapTalkDidDeleteMessages:(NSArray <TAPMessageModel *> *)messages;

@end

@interface TAPCoreMessageManager : NSObject

@property (weak, nonatomic) id<TAPCoreMessageManagerDelegate> delegate;

@property (nonatomic) CGFloat messageDelegateBulkCallbackDelay;

+ (TAPCoreMessageManager *)sharedManager;

- (void)sendTextMessage:(NSString *)message
                   room:(TAPRoomModel *)room
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendTextMessage:(NSString *)message
          quotedMessage:(TAPMessageModel *)quotedMessage
                   room:(TAPRoomModel *)room
                  start:(void (^)(TAPMessageModel *message))start
                success:(void (^)(TAPMessageModel *message))success
                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendLocationMessageWithLatitude:(CGFloat)latitude
                              longitude:(CGFloat)longitude
                                address:(nullable NSString *)address
                                   room:(TAPRoomModel *)room
                                  start:(void (^)(TAPMessageModel *message))start
                                success:(void (^)(TAPMessageModel *message))success
                                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendLocationMessageWithLatitude:(CGFloat)latitude
                              longitude:(CGFloat)longitude
                           quotedMessage:(TAPMessageModel *)quotedMessage
                                address:(nullable NSString *)address
                                   room:(TAPRoomModel *)room
                                  start:(void (^)(TAPMessageModel *message))start
                                success:(void (^)(TAPMessageModel *message))success
                                failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendImageMessage:(UIImage *)image
                 caption:(nullable NSString *)caption
                    room:(TAPRoomModel *)room
                   start:(void (^)(TAPMessageModel *message))start
                progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                 success:(void (^)(TAPMessageModel *message))success
                 failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendImageMessage:(UIImage *)image
           quotedMessage:(TAPMessageModel *)quotedMessage
                 caption:(nullable NSString *)caption
                    room:(TAPRoomModel *)room
                   start:(void (^)(TAPMessageModel *message))start
                progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                 success:(void (^)(TAPMessageModel *message))success
                 failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendImageMessageWithAsset:(PHAsset *)asset
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendImageMessageWithAsset:(PHAsset *)asset
                    quotedMessage:(TAPMessageModel *)quotedMessage
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendImageMessageWithURL:(NSURL *)imageURL
                        caption:(nullable NSString *)caption
                           room:(TAPRoomModel *)room
                          start:(void (^)(TAPMessageModel *message))start
                       progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                        success:(void (^)(TAPMessageModel *message))success
                        failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendImageMessageWithURL:(NSURL *)imageURL
                  quotedMessage:(TAPMessageModel *)quotedMessage
                        caption:(nullable NSString *)caption
                           room:(TAPRoomModel *)room
                          start:(void (^)(TAPMessageModel *message))start
                       progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                        success:(void (^)(TAPMessageModel *message))success
                        failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendVideoMessageWithAsset:(PHAsset *)asset
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendVideoMessageWithAsset:(PHAsset *)asset
                    quotedMessage:(TAPMessageModel *)quotedMessage
                          caption:(nullable NSString *)caption
                             room:(TAPRoomModel *)room
                            start:(void (^)(TAPMessageModel *message))start
                         progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                          success:(void (^)(TAPMessageModel *message))success
                          failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
/**
 * @param videoAssetURL this should be a file's path from local only (e.g: abcd/efgh/media/video.mov)
 *
 * return TAPMessageModel
 */
- (void)sendVideoMessageWithVideoAssetURL:(NSURL *)videoAssetURL
                                  caption:(nullable NSString *)caption
                                     room:(TAPRoomModel *)room
                                    start:(void (^)(TAPMessageModel *message))start
                                 progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                                  success:(void (^)(TAPMessageModel *message))success
                                  failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendVideoMessageWithVideoAssetURL:(NSURL *)videoAssetURL
                            quotedMessage:(TAPMessageModel *)quotedMessage
                                  caption:(nullable NSString *)caption
                                     room:(TAPRoomModel *)room
                                    start:(void (^)(TAPMessageModel *message))start
                                 progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                                  success:(void (^)(TAPMessageModel *message))success
                                  failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendFileMessageWithFileURI:(NSURL *)fileURI
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendFileMessageWithFileURI:(NSURL *)fileURI
                     quotedMessage:(TAPMessageModel *)quotedMessage
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendVoiceMessageWithFileURI:(NSURL *)fileURI
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendVoiceMessageWithFileURI:(NSURL *)fileURI
                     quotedMessage:(TAPMessageModel *)quotedMessage
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendForwardedMessage:(TAPMessageModel *)messageToForward
                              room:(TAPRoomModel *)room
                             start:(void (^)(TAPMessageModel *message))start
                          progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                           success:(void (^)(TAPMessageModel *message))success
                           failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendForwardedMessageWithMessageArray:(NSArray<TAPMessageModel*> *) messageArray
                        room:(TAPRoomModel *)room
                       start:(void (^)(TAPMessageModel *message))start
                    progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progress
                     success:(void (^)(TAPMessageModel *message))success
                                     failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (TAPMessageModel *)constructTapTalkMessageModelWithRoom:(TAPRoomModel *)room
                                 messageBody:(NSString *)messageBody
                                 messageType:(NSInteger)messageType
                                 messageData:(NSDictionary * _Nullable)messageData;
- (TAPMessageModel *)constructTapTalkMessageModelWithRoom:(TAPRoomModel *)room
                                            quotedMessage:(TAPMessageModel *)quotedMessage
                                              messageBody:(NSString *)messageBody
                                              messageType:(NSInteger)messageType
                                              messageData:(NSDictionary * _Nullable)messageData;
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
                                     rightButtonOptionColor:(NSString *)rightButtonOptionColor;
- (void)sendCustomMessageWithMessageModel:(TAPMessageModel *)customMessage
                                    start:(void (^)(TAPMessageModel *message))start
                                  success:(void (^)(TAPMessageModel *message))success
                                  failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)sendProductMessageWithProductArray:(NSArray <NSDictionary*> *)productArray
                                      room:(TAPRoomModel *)room
                                     start:(void (^)(TAPMessageModel *message))start
                                   success:(void (^)(TAPMessageModel *message))success
                                   failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)deleteMessage:(TAPMessageModel *)message
              success:(void (^)(void))success
              failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)deleteLocalMessageWithLocalID:(NSString *)localID
              success:(void (^)(void))success
              failure:(void (^)(NSString *localID, NSError *error))failure;
- (void)uploadImage:(UIImage *)image
            success:(void (^)(NSString *fileID, NSString *fileURL))success
            failure:(void (^)(NSError *error))failure;
- (void)cancelMessageFileUpload:(TAPMessageModel *)message
                        success:(void (^)(void))success
                        failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)downloadMessageFile:(TAPMessageModel *)message
                      start:(void (^)(void))startBlock
                   progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progressBlock
                    success:(void (^)(TAPMessageModel *message, NSData *fileData, NSString *filePath))successBlock
                    failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failureBlock;
- (void)downloadMessageImage:(TAPMessageModel *)message
                       start:(void (^)(void))startBlock
                    progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progressBlock
                     success:(void (^)(TAPMessageModel *message, UIImage *fullImage, NSString * _Nullable filePath))successBlock
                     failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failureBlock;
- (void)downloadMessageVideo:(TAPMessageModel *)message
                       start:(void (^)(void))startBlock
                    progress:(void (^)(TAPMessageModel *message, CGFloat progress, CGFloat total))progressBlock
                     success:(void (^)(TAPMessageModel *message, NSData *fileData, NSString *filePath))successBlock
                     failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failureBlock;
- (void)cancelMessageFileDownload:(TAPMessageModel *)message
                          success:(void (^)(void))success
                          failure:(void (^)(TAPMessageModel * _Nullable message, NSError *error))failure;
- (void)markMessageAsDelivered:(TAPMessageModel *)message;
- (void)markMessagesAsDelivered:(NSArray<TAPMessageModel *> *)messageArray;
- (void)markMessageAsRead:(TAPMessageModel *)message;
- (void)markMessagesAsRead:(NSArray<TAPMessageModel *> *)messageArray;
- (void)markMessagesAsRead:(NSArray<TAPMessageModel *> *)messageArray
                   success:(void (^)(NSArray <NSString *> *updatedMessageIDs))success
                   failure:(void (^)(NSError *error))failure;
- (void)markAllMessagesInRoomAsReadWithRoomID:(NSString *)roomID;
- (void)markAllMessagesInRoomAsReadWithRoomID:(NSString *)roomID
                                      success:(void (^)(NSArray <NSString *> *updatedMessageIDs))success
                                      failure:(void (^)(NSError *error))failure;
- (void)getLocalMessagesWithRoomID:(NSString *)roomID
                           success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                           failure:(void (^)(NSError *error))failure;
- (void)getLocalMessagesWithRoomID:(NSString *)roomID
                     excludeHidden:(BOOL)excludeHidden
                           success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                           failure:(void (^)(NSError *error))failure;
- (void)getLocalMessagesWithRoomID:(NSString *)roomID
               maxCreatedTimestamp:(NSNumber *)maxCreatedTimestamp
                     numberOfItems:(NSInteger)numberOfItems
                           success:(void (^)(NSArray<TAPMessageModel *> *obtainedMessageArray))success
                           failure:(void (^)(NSError *error))failure;
- (void)getLocalMessageWithLocalID:(NSString *)localID
                           success:(void (^)(NSArray<TAPMessageModel *> *obtainedMessageArray))success
                           failure:(void (^)(NSError *error))failure;
- (void)getLocalMessageWithLocalIDs:(NSArray<NSString *> *)localIDs
                            success:(void (^)(NSArray<TAPMessageModel *> *obtainedMessageArray))success
                            failure:(void (^)(NSError *error))failure;
- (void)getLocalMessagesWithRoomID:(NSString *)roomID
               maxCreatedTimestamp:(NSNumber *)maxCreatedTimestamp
                     numberOfItems:(NSInteger)numberOfItems
                     excludeHidden:(BOOL)excludeHidden
                           success:(void (^)(NSArray<TAPMessageModel *> *obtainedMessageArray))success
                           failure:(void (^)(NSError *error))failure;
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
- (void)getAllOlderMessagesBeforeTimestamp:(NSNumber *)timestamp
                                    roomID:(NSString *)roomID
                         olderMessageArray:(NSMutableArray<TAPMessageModel *> *)olderMessages
                                   success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                                   failure:(void (^)(NSError *error))failure;
- (void)getMessagesFromServerWithRoomID:(NSString *)roomID
                                success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                                failure:(void (^)(NSError *error))failure;
- (void)getAllMessagesWithRoomID:(NSString *)roomID
            successLocalMessages:(void (^)(NSArray <TAPMessageModel *> *messageArray))successLocalMessages
              successAllMessages:(void (^)(NSArray <TAPMessageModel *> *allMessagesArray,
                                           NSArray <TAPMessageModel *> *olderMessagesArray,
                                           NSArray <TAPMessageModel *> *newerMessagesArray))successAllMessages
                         failure:(void (^)(NSError *error))failure;
- (void)getUnreadMessagesFromRoom:(NSString *)roomID
                          success:(void (^)(NSArray<TAPMessageModel *> *unreadMessageArray))success
                          failure:(void (^)(NSError *error))failure;
- (void)getMediaMessagesFromRoom:(NSString *)roomID
                   lastTimestamp:(NSNumber *)lastTimestamp
                    numberOfItem:(NSInteger)numberOfItem
                         success:(void (^)(NSArray<TAPMessageModel *> *mediaMessageArray))success
                         failure:(void (^)(NSError *error))failure;
- (void)searchLocalMessageWithKeyword:(NSString *)keyword
                              success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                              failure:(void (^)(NSError *error))failure;
- (void)searchLocalRoomMessageWithKeyword:(NSString *)keyword
                                   roomID:(NSString *)roomID
                                  success:(void (^)(NSArray <TAPMessageModel *> *messageArray))success
                                  failure:(void (^)(NSError *error))failure;
- (void)getStarredMessagesWithRoomID:(NSString *)roomID
                          pageNumber:(NSInteger)pageNumber
                       numberOfItems:(NSInteger)numberOfItems
                         success:(void (^)(NSArray<TAPMessageModel *> *starredMessagesArray,BOOL hasMoreData))success
                             failure:(void (^)(NSError *error))failure;
- (void)getStarredMessageIDsWithRoomID:(NSString *)roomID
                         success:(void (^)(NSArray<NSString *> *starredMessagesIDs))success
                               failure:(void (^)(NSError *error))failure;
- (void)starMessageWithMessageID:(NSString *)messageID roomID:(NSString *)roomID;
- (void)starMessageWithMessageID:(NSString *)messageID
                          roomID:(NSString *)roomID
                         success:(void (^)(NSArray<NSString *> *starredMessagesIDs))success
                         failure:(void (^)(NSError *error))failure;
- (void)starMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs roomID:(NSString *)roomID;
- (void)starMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs
                            roomID:(NSString *)roomID
                           success:(void (^)(NSArray<NSString *> *starredMessagesIDs))success
                           failure:(void (^)(NSError *error))failure;
- (void)unstarMessageWithMessageID:(NSString *)messageID roomID:(NSString *)roomID;
- (void)unstarMessageWithMessageID:(NSString *)messageID
                            roomID:(NSString *)roomID
                           success:(void (^)(NSArray<NSString *> *starredMessagesIDs))success
                           failure:(void (^)(NSError *error))failure;
- (void)unstarMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs roomID:(NSString *)roomID;
- (void)unstarMessagesWithMessageIDs:(NSArray<NSString *> *)messageIDs
                              roomID:(NSString *)roomID
                             success:(void (^)(NSArray<NSString *> *unstarredMessagesIDs))success
                             failure:(void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
