//
//  TAPFileDownloadManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 17/01/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPFileDownloadManager : NSObject

+ (TAPFileDownloadManager *)sharedManager;

- (void)receiveImageFileWithMessage:(TAPMessageModel *)message
                              start:(void(^)(TAPMessageModel *receivedMessage))startProgress
                           progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
                            success:(void (^)(UIImage *fullImage,TAPMessageModel *receivedMessage))success
                            failure:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure;

- (NSDictionary *)getDownloadProgressWithLocalID:(NSString *)localID;

// DV NOTE - Uncomment this function to use API Thumbnail image
//- (void)receiveImageFileWithMessage:(TAPMessageModel *)message
//                           progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
//              successThumbnailImage:(void (^)(UIImage *thumbnailImage, TAPMessageModel *receivedMessage))successThumbnail
//                   successFullImage:(void (^)(UIImage *fullImage,TAPMessageModel *receivedMessage))success
//              failureThumbnailImage:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failureThumbnail
//                   failureFullImage:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure;
@end

NS_ASSUME_NONNULL_END
