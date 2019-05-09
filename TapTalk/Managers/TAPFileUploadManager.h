//
//  TAPFileUploadManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 05/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPFileUploadManager : NSObject

+ (TAPFileUploadManager *)sharedManager;

- (NSInteger)obtainUploadStatusWithMessage:(TAPMessageModel *)message;
- (void)sendFileWithData:(TAPMessageModel *)message;
- (void)sendFileAsAssetWithData:(TAPMessageModel *)message;
- (NSDictionary *)getUploadProgressWithLocalID:(NSString *)localID;
- (void)cancelUploadingOperationWithMessage:(TAPMessageModel *)message;
- (void)resizeImage:(UIImage *)image maxImageSize:(CGFloat)maxImageSize success:(void (^)(UIImage *resizedImage))success;
- (void)saveToPendingUploadAssetDictionaryWithAsset:(PHAsset *)asset;
- (PHAsset *)getAssetFromPendingUploadAssetDictionaryWithAssetIdentifier:(NSString *)assetIdentifier;

@end

NS_ASSUME_NONNULL_END
