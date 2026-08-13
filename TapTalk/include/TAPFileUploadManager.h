//
//  TAPFileUploadManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 05/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import "TAPMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPFileUploadManager : NSObject

+ (TAPFileUploadManager *)sharedManager;
- (NSInteger)obtainUploadStatusWithMessage:(TAPMessageModel *)message;
- (void)sendFileWithData:(TAPMessageModel *)message scheduleTime:(NSNumber *)scheduleTime;
- (void)sendFileAsAssetWithData:(TAPMessageModel *)message scheduleTime:(NSNumber *)scheduleTime ;
- (NSDictionary *)getUploadProgressWithLocalID:(NSString *)localID;
- (void)cancelUploadingOperationWithMessage:(TAPMessageModel *)message;
- (void)resizeImage:(UIImage *)image maxImageSize:(CGFloat)maxImageSize success:(void (^)(UIImage *resizedImage))success;
- (void)saveToPendingUploadAssetDictionaryWithAsset:(PHAsset *)asset;
- (void)saveToPendingUploadAssetDictionaryWithAVAsset:(AVAsset *)asset;
- (PHAsset *)getAssetFromPendingUploadAssetDictionaryWithAssetIdentifier:(NSString *)assetIdentifier;
- (AVAsset *)getAssetFromPendingUploadAVAssetDictionaryWithAssetIdentifier:(NSString *)assetIdentifier;
- (void)clearFileUploadManagerData;
- (BOOL)isUploadingFile;

- (void)uploadImage:(UIImage *)image
            success:(void (^)(NSString *fileID, NSString *fileURL))success
            failure:(void (^)(NSError *error))failure;
- (void)uploadFile:(NSURL *)url
            success:(void (^)(NSString *fileID, NSString *fileURL))success
           failure:(void (^)(NSError *error))failure;
- (void)uploadVideo:(NSURL *)url
            success:(void (^)(NSString *fileID, NSString *fileURL))success
            failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
