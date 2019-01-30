//
//  TAPImageDetailView.h
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import <TapTalk/TapTalk.h>

@protocol TAPImageDetailViewDelegate <NSObject>

- (void)imageDetailViewWillStartOpeningAnimation;
- (void)imageDetailViewWillStartClosingAnimation;

- (void)imageDetailViewDidFinishOpeningAnimation;
- (void)imageDetailViewDidFinishClosingAnimation;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TAPImageDetailView : TAPBaseView

@property (weak, nonatomic) id<TAPImageDetailViewDelegate> delegate;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *movementView;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) TAPImageView *thumbnailImage;
@property (nonatomic) UIViewContentMode contentMode;

- (void)animateOpeningWithThumbnailFrame:(CGRect)thumbnailFrame thumbnailImage:(UIImage *)thumbnailImage;
- (void)animateClosingWithThumbnailFrame:(CGRect)thumbnailFrame thumbnailImage:(UIImage *)thumbnailImage;

@end

NS_ASSUME_NONNULL_END
