//
//  TAPMediaDetailView.h
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import <TapTalk/TapTalk.h>

typedef NS_ENUM(NSInteger, TAPMediaDetailViewType) {
    TAPMediaDetailViewTypeImage = 0,
    TAPMediaDetailViewTypeVideo = 1
};

@protocol TAPMediaDetailViewDelegate <NSObject>

- (void)mediaDetailViewWillStartOpeningAnimation;
- (void)mediaDetailViewWillStartClosingAnimation;
- (void)mediaDetailViewDidFinishOpeningAnimation;
- (void)mediaDetailViewDidFinishClosingAnimation;
- (void)mediaDetailViewDidTappedBackButton;
- (void)mediaDetailViewDidTappedSaveImageButton;
- (void)mediaDetailViewDidTappedSaveVideoButton;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TAPMediaDetailView : TAPBaseView

@property (weak, nonatomic) id<TAPMediaDetailViewDelegate> delegate;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *movementView;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) TAPImageView *thumbnailImage;
@property (nonatomic) UIViewContentMode contentMode;
@property (nonatomic) TAPMediaDetailViewType mediaDetailViewType;

- (void)animateOpeningWithThumbnailFrame:(CGRect)thumbnailFrame thumbnailImage:(UIImage *)thumbnailImage;
- (void)animateClosingWithThumbnailFrame:(CGRect)thumbnailFrame thumbnailImage:(UIImage *)thumbnailImage;
- (void)showHeaderAndCaptionView:(BOOL)isShow animated:(BOOL)animated;
- (void)setSaveLoadingAsFinishedState:(BOOL)isFinished;
- (void)showSaveLoadingView:(BOOL)isShow;
- (void)setMediaDetailInfoWithMessage:(TAPMessageModel *)message;
- (void)setMediaDetailViewType:(TAPMediaDetailViewType)mediaDetailViewType;

@end

NS_ASSUME_NONNULL_END
