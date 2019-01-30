//
//  TAPImageDetailViewController.h
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import <TapTalk/TapTalk.h>

@class TAPImageDetailView;

@protocol TAPImageDetailViewControllerDelegate <NSObject>

@optional

- (void)imageDetailViewControllerWillChangeToPage:(NSInteger)pageIndex;
- (void)imageDetailViewControllerWillStartOpeningAnimation;
- (void)imageDetailViewControllerWillStartClosingAnimation;
- (void)imageDetailViewControllerDidFinishOpeningAnimation;
- (void)imageDetailViewControllerDidFinishClosingAnimation;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TAPImageDetailViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPImageDetailViewControllerDelegate> delegate;

@property (nonatomic) UIViewContentMode contentMode;

@property (strong, nonatomic) TAPImageDetailView *imageDetailView;

@property (strong, nonatomic) NSArray *imageLocalNameArray;
@property (strong, nonatomic) NSArray *imageArray;
@property (strong, nonatomic) NSArray *thumbnailImageArray;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

- (void)showToViewController:(UIViewController *)viewController
              thumbnailImage:(UIImage *)thumbnailImage
              thumbnailFrame:(CGRect)thumbnailFrame;
- (void)setActiveIndex:(NSInteger)activeIndex;

@end

NS_ASSUME_NONNULL_END
