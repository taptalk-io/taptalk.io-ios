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
    imageCache.config.maxCacheSize = kMaxDiskCountLimit;
    imageCache.config.maxCacheAge = kMaxCacheAge;
//    imageCache.maxCacheSize = kMaxDiskCountLimit;
//    imageCache.maxCacheAge = kMaxCacheAge;
    
    self.backgroundColor = [TAPUtil randomPastelColor];
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
//    [[SDImageCache sharedImageCache] storeImage:image recalculateFromImage:NO imageData:nil forKey:key toDisk:YES];
    [[SDImageCache sharedImageCache] storeImage:image forKey:key
                                     completion:^{
                                         
                                     }];
}

+ (UIImage *)imageFromCacheWithKey:(NSString *)key {
    UIImage *savedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    return savedImage;
}

+ (void)removeImageFromCacheWithKey:(NSString *)key {
//    [[SDImageCache sharedImageCache] removeImageForKey:key];
    [[SDImageCache sharedImageCache] removeImageForKey:key withCompletion:^{
        
    }];
}

- (void)setImageWithURLString:(NSString *)urlString {
    if (urlString == nil) {
        urlString = @"";
    }
    
    _imageURLString = urlString;
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache diskImageExistsWithKey:urlString completion:^(BOOL isInCache) {
        if (isInCache) {
            //Image exist in disk, load from disk
            UIImage *savedImage = [imageCache imageFromDiskCacheForKey:urlString];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = savedImage;
                
                if ([self.delegate respondsToSelector:@selector(imageViewDidFinishLoadImage:)]) {
                    [self.delegate imageViewDidFinishLoadImage:self];
                }
            });
        }
        else {
            NSURL *imageURL = [NSURL URLWithString:urlString];
            
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            [imageDownloader downloadImageWithURL:imageURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
#ifdef RNIMAGE_LOG
                NSLog(@"Image Download: %ld of %ld", (long)receivedSize, (long)expectedSize);
#endif
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (finished && image != nil) {
#ifdef RNIMAGE_LOG
                    NSLog(@"Image Download Completed");
#endif
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
#ifdef RNIMAGE_LOG
                    NSLog(@"Image Download Failed: %@", [error description]);
#endif
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

@end
