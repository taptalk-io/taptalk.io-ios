//
//  TAPImageDetailView.m
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import "TAPImageDetailView.h"

@implementation TAPImageDetailView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.0f;
        [self addSubview:self.backgroundView];
        
        _movementView = [[UIView alloc] initWithFrame:self.bounds];
        self.movementView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.movementView];
        
        _thumbnailImage = [[TAPImageView alloc] initWithFrame:CGRectZero];
        self.thumbnailImage.contentMode = self.contentMode;
        self.thumbnailImage.clipsToBounds = YES;
        self.thumbnailImage.backgroundColor = [UIColor clearColor];
        [self addSubview:self.thumbnailImage];
        
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        self.pageViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.pageViewController.view.alpha = 0.0f;
        self.pageViewController.view.backgroundColor = [UIColor clearColor];
        [self.movementView addSubview:self.pageViewController.view];
        
        UIVisualEffectView *statusBarHeaderView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), [TAPUtil currentDeviceStatusBarHeight])];
        UIBlurEffect *statusBarBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        statusBarHeaderView.effect = statusBarBlurEffect;
        statusBarHeaderView.clipsToBounds = YES;
        [self addSubview:statusBarHeaderView];
        
        self.thumbnailImage.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)animateOpeningWithThumbnailFrame:(CGRect)thumbnailFrame thumbnailImage:(UIImage *)thumbnailImage {
    if(thumbnailImage == nil) {
        thumbnailImage = [UIImage imageNamed:@"blank-image"];
    }
    
    if([self.delegate respondsToSelector:@selector(imageDetailViewWillStartOpeningAnimation)]) {
        [self.delegate imageDetailViewWillStartOpeningAnimation];
    }
    
    self.thumbnailImage.image = thumbnailImage;
    self.thumbnailImage.frame = thumbnailFrame;
    
    CGFloat scaleWidth = CGRectGetWidth(self.frame) / thumbnailImage.size.width;
    CGFloat scaleHeight = CGRectGetWidth(self.frame) / thumbnailImage.size.height;
    
    BOOL isPortrait = NO;
    
    if(thumbnailImage.size.height > thumbnailImage.size.width) {
        isPortrait = YES;
    }
    
    CGFloat minimumZoomScale = MIN(scaleWidth, scaleHeight);
    
    if(isPortrait) {
        minimumZoomScale = MAX(scaleWidth, scaleHeight);
    }
    
    CGFloat imageWidth = thumbnailImage.size.width * minimumZoomScale;
    CGFloat imageHeight = thumbnailImage.size.height * minimumZoomScale;
    
    if(isPortrait) {
        if(imageHeight > CGRectGetHeight(self.frame)) {
            imageWidth = (CGRectGetHeight(self.frame)/imageHeight) * imageWidth;
            imageHeight = CGRectGetHeight(self.frame);
        }
    }
    else {
        if(imageWidth > CGRectGetWidth(self.frame)) {
            imageHeight = (CGRectGetWidth(self.frame)/imageWidth) * imageHeight;
            imageWidth = CGRectGetWidth(self.frame);
        }
    }
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backgroundView.alpha = 1.0f;
                         self.thumbnailImage.frame = CGRectMake((CGRectGetWidth(self.frame) - imageWidth)/2.0f, (CGRectGetHeight(self.frame) - imageHeight)/2.0f, imageWidth, imageHeight);
                     } completion:^(BOOL finished) {
                         self.pageViewController.view.alpha = 1.0f;
                         self.thumbnailImage.alpha = 0.0f;
                         
                         if([self.delegate respondsToSelector:@selector(imageDetailViewDidFinishOpeningAnimation)]) {
                             [self.delegate imageDetailViewDidFinishOpeningAnimation];
                         }
                     }];
}

- (void)animateClosingWithThumbnailFrame:(CGRect)thumbnailFrame thumbnailImage:(UIImage *)thumbnailImage {
    if(thumbnailImage == nil) {
        thumbnailImage = [UIImage imageNamed:@"blank-image"];
    }
    
    if([self.delegate respondsToSelector:@selector(imageDetailViewWillStartClosingAnimation)]) {
        [self.delegate imageDetailViewWillStartClosingAnimation];
    }
    
    self.thumbnailImage.image = thumbnailImage;
    self.thumbnailImage.frame = thumbnailFrame;
    
    CGFloat scaleWidth = CGRectGetWidth(self.frame) / thumbnailImage.size.width;
    CGFloat scaleHeight = CGRectGetWidth(self.frame) / thumbnailImage.size.height;
    
    BOOL isPortrait = NO;
    
    if(thumbnailImage.size.height > thumbnailImage.size.width) {
        isPortrait = YES;
    }
    
    CGFloat minimumZoomScale = MIN(scaleWidth, scaleHeight);
    
    if(isPortrait) {
        minimumZoomScale = MAX(scaleWidth, scaleHeight);
    }
    
    CGFloat imageWidth = thumbnailImage.size.width * minimumZoomScale;
    CGFloat imageHeight = thumbnailImage.size.height * minimumZoomScale;
    
    self.thumbnailImage.frame = CGRectMake(((CGRectGetWidth(self.frame) - imageWidth)/2.0f) + CGRectGetMinX(self.movementView.frame), ((CGRectGetHeight(self.frame) - imageHeight)/2.0f) + CGRectGetMinY(self.movementView.frame), imageWidth, imageHeight);
    
    self.pageViewController.view.alpha = 0.0f;
    self.thumbnailImage.alpha = 1.0f;
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backgroundView.alpha = 0.0f;
                         self.thumbnailImage.frame = thumbnailFrame;
                         self.backgroundView.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         if([self.delegate respondsToSelector:@selector(imageDetailViewDidFinishClosingAnimation)]) {
                             [self.delegate imageDetailViewDidFinishClosingAnimation];
                         }
                     }];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    _contentMode = contentMode;
    self.thumbnailImage.contentMode = contentMode;
}

@end
