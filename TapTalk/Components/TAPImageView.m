//
//  TAPImageView.m
//
//  Created by Ritchie Nathaniel on 11/23/15.
//

#import "TAPImageView.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"

@interface TAPImageView ()

- (void)initialization;

@end

@implementation TAPImageView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (void)initialization {
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    imageCache.config.maxDiskAge = kMaxCacheAge;
    imageCache.config.maxDiskSize = kMaxDiskCountLimit;
//    imageCache.maxCacheSize = kMaxDiskCountLimit;
//    imageCache.maxCacheAge = kMaxCacheAge;
    
    self.backgroundColor = [TAPUtil getColor:@"E4E4E4"];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - Custom Method
+ (void)saveImageToCache:(UIImage *)image withKey:(NSString *)key {
    [[SDImageCache sharedImageCache] storeImage:image forKey:key
                                     completion:^{
                                         
                                     }];
}

+ (void)imageFromCacheWithKey:(NSString *)key success:(void (^)(UIImage *savedImage))success {
    //Run in background thread, async
    [[SDImageCache sharedImageCache] queryCacheOperationForKey:key done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        dispatch_async(dispatch_get_main_queue(), ^{
            success(image);
        });
    }];
}

+ (UIImage *)imageFromCacheWithKey:(NSString *)key {
    //Run in main thread
    UIImage *savedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    return savedImage;
}

+ (void)removeImageFromCacheWithKey:(NSString *)key {
    [[SDImageCache sharedImageCache] removeImageForKey:key withCompletion:^{
        
    }];
}

- (void)setImageWithURLString:(NSString *)urlString {
    if (urlString == nil) {
        urlString = @"";
    }
    
    _imageURLString = urlString;
    NSString *key = urlString;
    if ([urlString hasPrefix:@"http"]) {
        key = [[key componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache diskImageExistsWithKey:key completion:^(BOOL isInCache) {
        if (isInCache) {
            //Image exist in disk, load from disk
            UIImage *savedImage = [imageCache imageFromDiskCacheForKey:key];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = savedImage;
                
                if ([self.delegate respondsToSelector:@selector(imageViewDidFinishLoadImage:)]) {
                    [self.delegate imageViewDidFinishLoadImage:self];
                }
            });
        }
        else {
            if (![urlString hasPrefix:@"http"]) {
                //Do not load url when url is fileID type
                if ([self.delegate respondsToSelector:@selector(imageViewDidFinishLoadImage:)]) {
                    [self.delegate imageViewDidFinishLoadImage:self];
                }
                return;
            }
            NSURL *imageURL = [NSURL URLWithString:urlString];
            
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            [imageDownloader downloadImageWithURL:imageURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//#ifdef DEBUG
//                NSLog(@"Image Download: %ld of %ld", (long)receivedSize, (long)expectedSize);
//#endif
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (finished && image != nil) {
//#ifdef DEBUG
//                    NSLog(@"Image Download Completed");
//#endif
                    //            [imageCache storeImage:image forKey:urlString];
                    [imageCache storeImage:image forKey:urlString completion:^{
                    }];
                    if ([self.imageURLString isEqualToString:[imageURL absoluteString]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.image = image;
                            
                            if ([self.delegate respondsToSelector:@selector(imageViewDidFinishLoadImage:)]) {
                                [self.delegate imageViewDidFinishLoadImage:self];
                            }
                        });
                    }
                }
                else {
//#ifdef DEBUG
//                    NSLog(@"Image Download Failed: %@", [error description]);
//#endif
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image = nil;
                        if ([self.delegate respondsToSelector:@selector(imageViewDidFinishLoadImage:)]) {
                            [self.delegate imageViewDidFinishLoadImage:self];
                        }
                    });
                }
            }];
        }
    }];
}

- (void)setAsTintedWithColor:(UIColor *)color {
    self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.tintColor = color;
}

#pragma mark - TapTalk
+ (void)imageFromCacheWithKey:(NSString *)key
                      message:(TAPMessageModel *)receivedMessage
                      success:(void (^)(UIImage * _Nullable savedImage, TAPMessageModel *resultMessage))success {
    
    if (key == nil || [key isEqual:@""]) {
        return;
    }
    
    // Run in background thread, async
    [[SDImageCache sharedImageCache] queryCacheOperationForKey:key done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if (image == nil) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            success(image, receivedMessage);
        });
    }];
}

+ (void)imageFromCacheWithKey:(NSString *)key
                      message:(TAPMessageModel *)receivedMessage
                      success:(void (^)(UIImage * _Nullable savedImage, TAPMessageModel *resultMessage))success
                      failure:(void (^)(TAPMessageModel *resultMessage))failure {
    
    if (key == nil || [key isEqual:@""]) {
        failure(receivedMessage);
    }
    
    @try {
        // Run in background thread, async
        [[SDImageCache sharedImageCache] queryCacheOperationForKey:key done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image == nil) {
                    [[SDImageCache sharedImageCache] queryImageForKey:key options:nil context:nil cacheType:cacheType completion:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
                            if (image == nil) {
                                failure(receivedMessage);
                            }
                            else {
                                success(image, receivedMessage);
                            }
                    }];
                }
                else {
                    success(image, receivedMessage);
                }
            });
        }];
    }
    @catch (NSException *exception) {
        return;
    }
}

+ (void)imageFromCacheWithMessage:(TAPMessageModel *)message
                          success:(void (^)(UIImage *fullImage,TAPMessageModel *receivedMessage))success
                          failure:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure {
    
    [self imageFromCacheWithMessage:message
    start:^(TAPMessageModel *receivedMessage) {
        
    }
    progress:^(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage) {
        
    }
    success:success
    failure:failure];
}

+ (void)imageFromCacheWithMessage:(TAPMessageModel *)message
                            start:(void(^)(TAPMessageModel *receivedMessage))startProgress
                         progress:(void (^)(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage))progressBlock
                          success:(void (^)(UIImage *fullImage,TAPMessageModel *receivedMessage))success
                          failure:(void(^)(NSError *error, TAPMessageModel *receivedMessage))failure {
    
    startProgress(message);
    [TAPImageView imageFromCacheWithKey:message.localID message:message
    success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
        success(savedImage, resultMessage);
    }
    failure:^(TAPMessageModel *resultMessage) {
        NSDictionary *dataDictionary = message.data;
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        
        NSString *urlKey = [dataDictionary objectForKey:@"url"];
        if (urlKey == nil || [urlKey isEqualToString:@""]) {
            urlKey = [dataDictionary objectForKey:@"fileURL"];
        }
        urlKey = [[urlKey componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
        urlKey = [TAPUtil nullToEmptyString:urlKey];
        
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        fileID = [TAPUtil nullToEmptyString:fileID];
        
        if (![urlKey isEqualToString:@""]) {
            [TAPImageView imageFromCacheWithKey:urlKey message:message
            success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
                //Image exist
                success(savedImage, resultMessage);
                // Replace key with local ID
                [TAPImageView saveImageToCache:savedImage withKey:resultMessage.localID];
                [TAPImageView removeImageFromCacheWithKey:urlKey];
            }
            failure:^(TAPMessageModel *resultMessage) {
                if (![fileID isEqualToString:@""]) {
                    [TAPImageView imageFromCacheWithKey:fileID message:message
                    success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
                        //Image exist
                        success(savedImage, resultMessage);
                        // Replace key with local ID
                        [TAPImageView saveImageToCache:savedImage withKey:resultMessage.localID];
                        [TAPImageView removeImageFromCacheWithKey:fileID];
                    }
                    failure:^(TAPMessageModel *resultMessage) {
                        failure([NSError errorWithDomain:@"Image not found in cache." code:99999 userInfo:nil], resultMessage);
                    }];
                }
                else {
                    failure([NSError errorWithDomain:@"Image not found in cache." code:99999 userInfo:nil], resultMessage);
                }
            }];
        }
        else if (![fileID isEqualToString:@""]) {
            [TAPImageView imageFromCacheWithKey:fileID message:message
            success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
                //Image exist
                success(savedImage, resultMessage);
                // Replace key with local ID
                [TAPImageView saveImageToCache:savedImage withKey:resultMessage.localID];
                [TAPImageView removeImageFromCacheWithKey:fileID];
            }
            failure:^(TAPMessageModel *resultMessage) {
                failure([NSError errorWithDomain:@"Image not found in cache." code:99999 userInfo:nil], resultMessage);
            }];
        }
        else {
            failure([NSError errorWithDomain:@"Image not found in cache." code:99999 userInfo:nil], resultMessage);
        }
    }];
}

@end
