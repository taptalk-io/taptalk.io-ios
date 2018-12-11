//
//  RNImageView.h
//  Version 1.1
//
//  Created by Ritchie Nathaniel on 11/23/15.
//  Last updated by Ritchie Nathaniel on 08/02/16
//

#import <UIKit/UIKit.h>
//#import "UIImage+WebP.h"

//#define RNIMAGE_LOG

static const NSInteger kMaxCacheAge = 60 * 60 * 24 * 7; // 1 Week in Seconds
static const NSInteger kMaxDiskCountLimit = 1048576000; // 1GB in B

@class RNImageView;

@protocol RNImageViewDelegate <NSObject>

@optional

- (void)RNImageViewDidFinishLoadImage:(RNImageView *)imageView;

@end

@interface RNImageView : UIImageView

@property (weak, nonatomic) id<RNImageViewDelegate> delegate;

@property (strong, nonatomic) NSString *imageURLString;

+ (void)saveImageToCache:(UIImage *)image withKey:(NSString *)key;
+ (UIImage *)imageFromCacheWithKey:(NSString *)key;
+ (void)removeImageFromCacheWithKey:(NSString *)key;

- (void)setImageWithURLString:(NSString *)urlString;

@end
