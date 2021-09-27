//
//  TAPFileDownloadManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 17/01/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVKit/AVKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPFileDownloadManager : NSObject

+ (TAPFileDownloadManager *)sharedManager;

- (void)receiveImageDataWithMessage:(TAPMessageModel *)message
                              start:(void(^)(TAPMessageModel *receivedMessage))startProgress
                           progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
                            success:(void (^)(UIImage *fullImage,TAPMessageModel *receivedMessage))success
                            failure:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure;

- (void)receiveFileDataWithMessage:(TAPMessageModel *)message
                             start:(void(^)(TAPMessageModel *receivedMessage))startProgress
                          progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
                           success:(void (^)(NSData *fileData, TAPMessageModel *receivedMessage, NSString *filePath))success
                           failure:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure;

- (void)receiveVideoDataWithMessage:(TAPMessageModel *)message
                              start:(void(^)(TAPMessageModel *receivedMessage))startProgress
                           progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
                            success:(void (^)(NSData *fileData, TAPMessageModel *receivedMessage, NSString *filePath))success
                            failure:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure;

- (NSDictionary *)getDownloadProgressWithLocalID:(NSString *)localID;
- (void)saveDownloadedFilePathToDictionaryWithFilePath:(NSString *)filePath roomID:(NSString *)roomID fileID:(NSString *)fileID;
- (NSString *)getDownloadedFilePathWithRoomID:(NSString *)roomID fileID:(NSString *)fileID;
- (void)fetchDownloadedFilePathFromPreference;
- (void)saveDownloadedFilePathToPreference;
- (void)cancelDownloadWithMessage:(TAPMessageModel *)message;
- (BOOL)checkFailedDownloadWithLocalID:(NSString *)localID;
- (void)saveVideoToLocalDirectoryWithAsset:(AVAsset *)videoAsset message:(TAPMessageModel *)message;
- (void)clearFileDownloadManagerData;

// DV NOTE - Uncomment this function to use API Thumbnail image
//- (void)receiveImageDataWithMessage:(TAPMessageModel *)message
//                           progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
//              successThumbnailImage:(void (^)(UIImage *thumbnailImage, TAPMessageModel *receivedMessage))successThumbnail
//                   successFullImage:(void (^)(UIImage *fullImage,TAPMessageModel *receivedMessage))success
//              failureThumbnailImage:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failureThumbnail
//                   failureFullImage:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure;
@end

NS_ASSUME_NONNULL_END
