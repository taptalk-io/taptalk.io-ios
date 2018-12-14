//
//  TAPImageView.h
//  Version 1.1
//
//  Created by Ritchie Nathaniel on 11/23/15.
//  Last updated by Ritchie Nathaniel on 08/02/16
//

#import <UIKit/UIKit.h>

static const NSInteger kMaxCacheAge = 60 * 60 * 24 * 7; // 1 Week in Seconds
static const NSInteger kMaxDiskCountLimit = 1048576000; // 1GB in B

@class TAPImageView;

@protocol TAPImageViewDelegate <NSObject>

@optional

- (void)imageViewDidFinishLoadImage:(TAPImageView *)imageView;

@end

@interface TAPImageView : UIImageView

@property (weak, nonatomic) id<TAPImageViewDelegate> delegate;

@property (strong, nonatomic) NSString *imageURLString;

+ (void)saveImageToCache:(UIImage *)image withKey:(NSString *)key;
+ (UIImage *)imageFromCacheWithKey:(NSString *)key;
+ (void)removeImageFromCacheWithKey:(NSString *)key;

- (void)setImageWithURLString:(NSString *)urlString;

@end
