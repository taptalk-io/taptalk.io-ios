//
//  TAPFetchMediaManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 20/03/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPFetchMediaManager : NSObject

+ (TAPFetchMediaManager *)sharedManager;

- (void)fetchImageDataForAsset:(PHAsset *)asset
               progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *dictionary))progressHandler
                 resultHandler:(void(^)(UIImage *resultImage))resultHandler;
- (void)fetchVideoDataForAsset:(PHAsset *)asset
               progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *dictionary))progressHandler
                 resultHandler:(void (^)(AVAsset *resultVideoAsset))resultHandler;
- (void)removeFetchAssetFromDictionaryForAsset:(PHAsset *)asset;
- (NSNumber *)getFetchProgressWithAsset:(PHAsset *)asset;
- (UIImage *)generateThumbnailImageFromFilePathString:(NSString *)filePathString;

@end

NS_ASSUME_NONNULL_END
