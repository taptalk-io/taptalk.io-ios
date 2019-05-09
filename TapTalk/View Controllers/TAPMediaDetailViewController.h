//
//  TAPMediaDetailViewController.h
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import <TapTalk/TapTalk.h>

@class TAPMediaDetailView;

typedef NS_ENUM(NSInteger, TAPMediaDetailViewControllerType) {
    TAPMediaDetailViewControllerTypeImage = 0,
    TAPMediaDetailViewControllerTypeVideo = 1
};

@protocol TAPMediaDetailViewControllerDelegate <NSObject>

@optional

- (void)mediaDetailViewControllerWillChangeToPage:(NSInteger)pageIndex;
- (void)mediaDetailViewControllerWillStartOpeningAnimation;
- (void)mediaDetailViewControllerWillStartClosingAnimation;
- (void)mediaDetailViewControllerDidFinishOpeningAnimation;
- (void)mediaDetailViewControllerDidFinishClosingAnimation;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TAPMediaDetailViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPMediaDetailViewControllerDelegate> delegate;

@property (nonatomic) UIViewContentMode contentMode;

@property (strong, nonatomic) TAPMediaDetailView *mediaDetailView;
@property (strong, nonatomic) TAPMessageModel *message;

@property (strong, nonatomic) NSArray *imageLocalNameArray;
@property (strong, nonatomic) NSArray *imageArray;
@property (strong, nonatomic) NSArray *thumbnailImageArray;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) TAPMediaDetailViewControllerType mediaDetailViewControllerType;

- (void)setMediaDetailViewControllerType:(TAPMediaDetailViewControllerType)mediaDetailViewControllerType;
- (void)showToViewController:(UIViewController *)viewController
              thumbnailImage:(UIImage *)thumbnailImage
              thumbnailFrame:(CGRect)thumbnailFrame;
- (void)setActiveIndex:(NSInteger)activeIndex;

@end

NS_ASSUME_NONNULL_END
