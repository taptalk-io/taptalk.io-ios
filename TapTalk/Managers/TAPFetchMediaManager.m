//
//  TAPFetchMediaManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 20/03/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPFetchMediaManager.h"

@interface TAPFetchMediaManager()

@property (strong, nonatomic) NSMutableDictionary *imageFetchResultDictionary;
@property (strong, nonatomic) NSMutableDictionary *videoFetchResultDictionary;
@property (strong, nonatomic) NSMutableDictionary *fetchProgressDictionary;

- (void)requestAssetForImage:(PHAsset *)asset
             progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *dictionary))progressHandler
               resultHandler:(void(^)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))resultHandler;
- (void)requestAssetForVideo:(PHAsset *)asset
             progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *dictionary))progressHandler
               resultHandler:(void (^)(AVAsset *__nullable videoAsset, AVAudioMix *__nullable audioMix, NSDictionary *__nullable info))resultHandler;
- (id)getAssetDataFromDictionaryWithKey:(NSString *)assetKey mediaType:(PHAssetMediaType)mediaType;

@end

@implementation TAPFetchMediaManager

#pragma mark - Lifecycle
+ (TAPFetchMediaManager *)sharedManager {
    static TAPFetchMediaManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _imageFetchResultDictionary = [[NSMutableDictionary alloc] init];
        _videoFetchResultDictionary = [[NSMutableDictionary alloc] init];
        _fetchProgressDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Custom Method
//- (NSString *)getDictionaryKeyForAsset:(PHAsset *)asset {
//
//    NSInteger mediaType = asset.mediaType;
//    NSInteger mediaSubtypes = asset.mediaSubtypes;
//    NSTimeInterval creationDate = [asset.creationDate timeIntervalSince1970];
//    NSTimeInterval modificationDate = [asset.modificationDate timeIntervalSince1970];
//
//    NSString *generatedKey = [NSString stringWithFormat:@"ASSET-%ld-%ld-%ld-%ld", mediaType, mediaSubtypes, creationDate, modificationDate];
//
//    return generatedKey;
//}

- (id)getAssetDataFromDictionaryWithKey:(NSString *)assetKey mediaType:(PHAssetMediaType)mediaType {
    
    id asset = nil;
    if (mediaType == PHAssetMediaTypeImage) {
        asset = [self.imageFetchResultDictionary objectForKey:assetKey];
    }
    else if (mediaType == PHAssetMediaTypeVideo) {
        asset = [self.videoFetchResultDictionary objectForKey:assetKey];
    }
    
    return asset;
}

- (void)removeFetchAssetFromDictionaryForAsset:(PHAsset *)asset {
    
//    NSString *assetKey = [[TAPFetchMediaManager sharedManager] getDictionaryKeyForAsset:asset];
    NSString *assetKey = asset.localIdentifier;
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        [self.imageFetchResultDictionary removeObjectForKey:assetKey];
    }
    else if (asset.mediaType == PHAssetMediaTypeVideo) {
        [self.videoFetchResultDictionary removeObjectForKey:assetKey];
    }
}

- (void)requestAssetForImage:(PHAsset *)asset
             progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *dictionary))progressHandler
               resultHandler:(void(^)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))resultHandler {
    
//    NSString *generatedAssetKey = [[TAPFetchMediaManager sharedManager] getDictionaryKeyForAsset:asset];
    NSString *generatedAssetKey = asset.localIdentifier;

    PHImageManager *manager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = NO;
    requestOptions.networkAccessAllowed = YES;
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeNone;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fetchProgressDictionary setObject:[NSNumber numberWithDouble:progress] forKey:generatedAssetKey];
            progressHandler(progress, error, stop, info);
        });
    };
    
    [manager requestImageDataForAsset:asset
                              options:requestOptions
                        resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             //Done download
             [self.fetchProgressDictionary removeObjectForKey:generatedAssetKey];
             resultHandler(imageData, dataUTI, orientation, info);
         });
     }];
}

- (void)requestAssetForVideo:(PHAsset *)asset
             progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *dictionary))progressHandler
               resultHandler:(void (^)(AVAsset *__nullable videoAsset, AVAudioMix *__nullable audioMix, NSDictionary *__nullable info))resultHandler {

    //    NSString *generatedAssetKey = [[TAPFetchMediaManager sharedManager] getDictionaryKeyForAsset:asset];
    NSString *generatedAssetKey = asset.localIdentifier;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fetchProgressDictionary setObject:[NSNumber numberWithDouble:progress] forKey:generatedAssetKey];
            progressHandler(progress, error, stop, info);
        });
    };
    
    [manager requestAVAssetForVideo:asset
                            options:options
                      resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Done download
            [self.fetchProgressDictionary removeObjectForKey:generatedAssetKey];
            resultHandler(asset, audioMix, info);
        });
    }];
}

- (void)fetchImageDataForAsset:(PHAsset *)asset
               progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *dictionary))progressHandler
                 resultHandler:(void(^)(UIImage *image))resultHandler
                failureHandler:(nonnull void (^)())failureHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //    NSString *assetKey = [[TAPFetchMediaManager sharedManager] getDictionaryKeyForAsset:asset];
        NSString *assetKey = asset.localIdentifier;
        
        UIImage *savedImage = [self.imageFetchResultDictionary objectForKey:assetKey];
        
        if (savedImage == nil) {
            //Asset not found, fetch request
            [[TAPFetchMediaManager sharedManager] requestAssetForImage:asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *dictionary) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressHandler(progress, error, stop, dictionary);
                });
            } resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (imageData == nil) {
                        failureHandler();
                    }
                    else {
                        UIImage *resultImage = [UIImage imageWithData:imageData];
                        [self.imageFetchResultDictionary setObject:resultImage forKey:assetKey];
                        resultHandler(resultImage);
                    }
                });
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultHandler(savedImage);
            });
        }
    });
}

- (void)fetchVideoDataForAsset:(PHAsset *)asset
               progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *dictionary))progressHandler
                 resultHandler:(void (^)(AVAsset *resultVideoAsset))resultHandler
                failureHandler:(void (^)())failureHandler {
    
    //    NSString *assetKey = [[TAPFetchMediaManager sharedManager] getDictionaryKeyForAsset:asset];
    NSString *assetKey = asset.localIdentifier;
    AVAsset *videoAsset = [self.videoFetchResultDictionary objectForKey:assetKey];
    
    if (videoAsset == nil) {
        //Asset not found, fetch request
        [[TAPFetchMediaManager sharedManager] requestAssetForVideo:asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *dictionary) {
            progressHandler(progress, error, stop, dictionary);
        } resultHandler:^(AVAsset * _Nullable videoAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (videoAsset == nil) {
                failureHandler();
            }
            else {
                [self.videoFetchResultDictionary setObject:videoAsset forKey:assetKey];
                resultHandler(videoAsset);
            }
        }];
    }
    else {
        resultHandler(videoAsset);
    }
}

- (NSNumber *)getFetchProgressWithAsset:(PHAsset *)asset {
    NSNumber *progressResultNumber = nil;
    //    NSString *generatedAssetKey = [[TAPFetchMediaManager sharedManager] getDictionaryKeyForAsset:asset];
    NSString *generatedAssetKey = asset.localIdentifier;
    progressResultNumber = [self.fetchProgressDictionary objectForKey:generatedAssetKey];
    return progressResultNumber;
}

- (UIImage *)generateThumbnailImageFromFilePathString:(NSString *)filePathString {
    NSError *err = NULL;
    
    NSURL *url = [NSURL fileURLWithPath:filePathString];
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset]; // Create object of Video.
    imageGenerator.appliesPreferredTrackTransform = YES;

    CMTime time = CMTimeMakeWithSeconds(0, 30);
    CGImageRef imgRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&err]; // Get Image on that time frame.
    // Convert Image from CGImage to UIImage so you can display it easily in a image view.
    UIImage *resultImage = [[UIImage alloc] initWithCGImage:imgRef];

    return resultImage;
}

- (void)clearFetchMediaManagerData {
    [self.imageFetchResultDictionary removeAllObjects];
    [self.videoFetchResultDictionary removeAllObjects];
    [self.fetchProgressDictionary removeAllObjects];
}

@end
