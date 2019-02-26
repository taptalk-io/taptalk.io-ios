//
//  TAPImageDetailView.m
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import "TAPImageDetailView.h"

#define kMaxCaptionHeight 190.0f
#define kMinCaptionHeight 58.0f

@interface TAPImageDetailView ()

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *headerTitleLabel;
@property (strong, nonatomic) UILabel *headerSubtitleLabel;
@property (strong, nonatomic) UIView *footerGradientView;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIScrollView *footerScrollView;
@property (strong, nonatomic) UILabel *footerCaptionLabel;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *saveButton;

@property (strong, nonatomic) UIView *saveLoadingBackgroundView;
@property (strong, nonatomic) UIView *saveLoadingView;
@property (strong, nonatomic) UIImageView *saveLoadingImageView;
@property (strong, nonatomic) UILabel *saveLoadingLabel;
@property (strong, nonatomic) UIButton *saveLoadingButton;

- (void)backButtonDidTapped;
- (void)saveButtonDidTapped;
- (void)saveLoadingButtonDidTapped;
- (void)animateSaveLoading:(BOOL)isAnimate;
- (NSString *)convertIntoFormattedDateWithTime:(NSNumber *)time;

@end

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
        
        //Header View
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO])];
        self.headerView.backgroundColor = [[TAPUtil getColor:@"040404"] colorWithAlphaComponent:0.4f];
        [self addSubview:self.headerView];
        
        CGFloat additionalTopSpacing = [TAPUtil currentDeviceStatusBarHeight];

        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(6.0f, additionalTopSpacing + 4.0f, 40.0f, 40.0f)];
        [self.backButton setImage:[UIImage imageNamed:@"TAPIconBackArrowWhite" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:self.backButton];
        
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 40.0f - 6.0f, additionalTopSpacing + 4.0f, 40.0f, 40.0f)];
        [self.saveButton setImage:[UIImage imageNamed:@"TAPIconSave" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.saveButton addTarget:self action:@selector(saveButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:self.saveButton];
        
        CGFloat headerTitleWidth = CGRectGetWidth(self.frame) - CGRectGetMaxX(self.backButton.frame) - 10.0f - 10.0f - CGRectGetWidth(self.saveButton.frame) - 6.0f;
        
        _headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.backButton.frame) + 10.0f, [TAPUtil currentDeviceStatusBarHeight] + 6.0f, headerTitleWidth, 16.0f)];
        self.headerTitleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:15.0f];
        self.headerTitleLabel.textColor = [UIColor whiteColor];
        [self.headerView addSubview:self.headerTitleLabel];
        
        _headerSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.backButton.frame) + 10.0f, CGRectGetMaxY(self.headerTitleLabel.frame), headerTitleWidth, 16.0f)];
        self.headerSubtitleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
        self.headerSubtitleLabel.textColor = [UIColor whiteColor];
        [self.headerView addSubview:self.headerSubtitleLabel];
        
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 16.0f - 16.0f - 16.0f, CGRectGetWidth(self.frame), 16.0f + 16.0f + 16.0f)];
        self.footerView.backgroundColor = [[TAPUtil getColor:@"040404"] colorWithAlphaComponent:0.4f];
        [self addSubview:self.footerView];
        
        _footerGradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.footerView.frame) - 16.0f, CGRectGetWidth(self.footerView.frame), 16.0f)];
        self.footerGradientView.backgroundColor = [UIColor clearColor];
        self.footerGradientView.clipsToBounds = YES;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.footerGradientView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, [[TAPUtil getColor:@"040404"] colorWithAlphaComponent:0.4f].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.footerGradientView.layer insertSublayer:gradient atIndex:0];
        [self addSubview:self.footerGradientView];
        
        _footerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 16.0f, CGRectGetWidth(self.footerView.frame), CGRectGetHeight(self.footerView.frame) - 16.0f - 16.0f)];
        self.footerScrollView.backgroundColor = [UIColor clearColor];
        self.footerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.footerScrollView.frame), CGRectGetMaxY(self.footerScrollView.frame));
        self.footerScrollView.showsVerticalScrollIndicator = NO;
        self.footerScrollView.showsHorizontalScrollIndicator = NO;
        [self.footerView addSubview:self.footerScrollView];

        _footerCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetHeight(self.frame) - 16.0f - 16.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 16.0f)];
        self.footerCaptionLabel.numberOfLines = 0;
        self.footerCaptionLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:15.0f];
        self.footerCaptionLabel.textColor = [UIColor whiteColor];
        [self.footerScrollView addSubview:self.footerCaptionLabel];
        
        //Save Loading View
        _saveLoadingBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.saveLoadingBackgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.saveLoadingBackgroundView];
        
        _saveLoadingView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 128.0f) / 2.0f, (CGRectGetHeight(self.frame) - 128.0f) / 2.0f, 128.0f, 128.0f)];
        self.saveLoadingView.backgroundColor = [UIColor whiteColor];
        self.saveLoadingView.layer.cornerRadius = 6.0f;
        self.saveLoadingView.clipsToBounds = YES;
        [self.saveLoadingBackgroundView addSubview:self.saveLoadingView];
        
        _saveLoadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.saveLoadingView.frame) - 60.0f) / 2.0f, 28.0f, 60.0f, 60.0f)];
        [self.saveLoadingView addSubview:self.saveLoadingImageView];
        
        _saveLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, CGRectGetMaxY(self.saveLoadingImageView.frame) + 8.0f, CGRectGetWidth(self.saveLoadingView.frame) - 8.0f - 8.0f, 20.0f)];
        self.saveLoadingLabel.font = [UIFont fontWithName:TAP_FONT_NAME_SEMIBOLD size:14.0f];
        self.saveLoadingLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93];
        self.saveLoadingLabel.textAlignment = NSTextAlignmentCenter;
        [self.saveLoadingView addSubview:self.saveLoadingLabel];
        
        _saveLoadingButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.saveLoadingBackgroundView.frame), CGRectGetHeight(self.saveLoadingBackgroundView.frame))];
        [self.saveLoadingButton addTarget:self action:@selector(saveLoadingButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        self.saveLoadingButton.alpha = 0.0f;
        self.saveLoadingButton.userInteractionEnabled = NO;
        [self.saveLoadingBackgroundView addSubview:self.saveLoadingButton];
        
        self.thumbnailImage.backgroundColor = [UIColor clearColor];
        self.saveLoadingBackgroundView.alpha = 0.0f;
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

- (void)backButtonDidTapped {
    if ([self.delegate respondsToSelector:@selector(imageDetailViewDidTappedBackButton)]) {
        [self.delegate imageDetailViewDidTappedBackButton];
    }
}

- (void)saveButtonDidTapped {
    if ([self.delegate respondsToSelector:@selector(imageDetailViewDidTappedSaveButton)]) {
        [self.delegate imageDetailViewDidTappedSaveButton];
    }
}

- (void)showHeaderAndCaptionView:(BOOL)isShow animated:(BOOL)animated {
    if (animated) {
        if (isShow) {
            [UIView animateWithDuration:0.2f animations:^{
                self.headerView.alpha = 1.0f;
                self.footerView.alpha = 1.0f;
                self.footerGradientView.alpha = 1.0f;
                self.backButton.userInteractionEnabled = YES;
                self.saveButton.userInteractionEnabled = YES;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.headerView.alpha = 0.0f;
                self.footerView.alpha = 0.0f;
                self.footerGradientView.alpha = 0.0f;
                self.backButton.userInteractionEnabled = NO;
                self.saveButton.userInteractionEnabled = NO;
            }];
        }
    }
    else {
        if (isShow) {
            self.headerView.alpha = 1.0f;
            self.footerView.alpha = 1.0f;
            self.footerGradientView.alpha = 1.0f;
            self.backButton.userInteractionEnabled = YES;
            self.saveButton.userInteractionEnabled = YES;
        }
        else {
            self.headerView.alpha = 0.0f;
            self.footerView.alpha = 0.0f;
            self.footerGradientView.alpha = 0.0f;
            self.backButton.userInteractionEnabled = NO;
            self.saveButton.userInteractionEnabled = NO;
        }
    }
}

- (void)setImageDetailInfoWithMessage:(TAPMessageModel *)message {
    
    NSString *dateString = [self convertIntoFormattedDateWithTime:message.created];
    
    NSDictionary *dataDictionary = message.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
    
    NSString *captionString = [message.data objectForKey:@"caption"];
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    NSString *nameString = message.user.fullname;
    nameString = [TAPUtil nullToEmptyString:nameString];
    
    self.headerTitleLabel.text = nameString;
    self.headerSubtitleLabel.text = dateString;
    self.footerCaptionLabel.text = captionString;
    
    if (![captionString isEqualToString:@""]) {
        self.footerView.alpha = 1.0f;
        self.footerGradientView.alpha = 1.0f;
        CGFloat bottomAditionalSpacing = 0.0f;
        if (IS_IPHONE_X_FAMILY) {
            bottomAditionalSpacing += [TAPUtil safeAreaBottomPadding];
        }
        
        CGSize footerSize = [self.footerCaptionLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.footerCaptionLabel.frame), CGFLOAT_MAX)];
        CGFloat captionHeight = footerSize.height;
        
        if (captionHeight < kMinCaptionHeight) {
            captionHeight = kMinCaptionHeight;
        }
        
//        CGFloat scrollViewHeight = 16.0f + captionHeight + 16.0f;
        self.footerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.footerScrollView.frame), captionHeight);
        self.footerCaptionLabel.frame = CGRectMake(CGRectGetMinX(self.footerCaptionLabel.frame), 0.0f, CGRectGetWidth(self.footerCaptionLabel.frame), captionHeight);
        
        if (captionHeight > kMaxCaptionHeight) {
            captionHeight = kMaxCaptionHeight;
        }
        
        CGFloat footerViewHeight = 16.0f + captionHeight + 16.0f + bottomAditionalSpacing;
        CGFloat footerViewMinY = CGRectGetHeight(self.frame) - footerViewHeight;
    
        self.footerScrollView.frame = CGRectMake(CGRectGetMinX(self.footerScrollView.frame), CGRectGetMinY(self.footerScrollView.frame), CGRectGetWidth(self.footerScrollView.frame), captionHeight);
        self.footerView.frame = CGRectMake(CGRectGetMinX(self.footerView.frame), footerViewMinY, CGRectGetWidth(self.footerView.frame), footerViewHeight);
        self.footerGradientView.frame = CGRectMake(CGRectGetMinX(self.footerGradientView.frame), CGRectGetMinY(self.footerView.frame) - 16.0f, CGRectGetWidth(self.footerGradientView.frame), CGRectGetHeight(self.footerGradientView.frame));
        
        if (self.footerScrollView.contentSize.height < CGRectGetHeight(self.footerScrollView.frame)) {
            self.footerScrollView.scrollEnabled = NO;
        }
        else {
            self.footerScrollView.scrollEnabled = YES;
        }
    }
    else {
        self.footerView.alpha = 0.0f;
        self.footerGradientView.alpha = 0.0f;
    }
}

- (void)saveLoadingButtonDidTapped {
    [self showSaveLoadingView:NO];
}

- (void)showSaveLoadingView:(BOOL)isShow {
    if (isShow) {
        [UIView animateWithDuration:0.2f animations:^{
            self.saveLoadingBackgroundView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.saveLoadingBackgroundView.alpha = 0.0f;
        }];
    }
}

- (void)setSaveLoadingAsFinishedState:(BOOL)isFinished {
    if (isFinished) {
        //Done save image
        [self animateSaveLoading:NO];
        self.saveLoadingImageView.image = [UIImage imageNamed:@"TAPIconImageSaved" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.saveLoadingLabel.text = NSLocalizedString(@"Image Saved", @"");
        self.saveLoadingButton.alpha = 1.0f;
        self.saveLoadingButton.userInteractionEnabled = YES;
    }
    else {
        //Saving Image
        [self animateSaveLoading:YES];
        self.saveLoadingImageView.image = [UIImage imageNamed:@"TAPIconImageSaving" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.saveLoadingLabel.text = NSLocalizedString(@"Saving…", @"");
        self.saveLoadingButton.alpha = 1.0f;
        self.saveLoadingButton.userInteractionEnabled = YES;
    }
}

- (void)animateSaveLoading:(BOOL)isAnimate {
    if (isAnimate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.duration = 1.5f;
        animation.repeatCount = INFINITY;
        animation.removedOnCompletion = NO;
        [self.saveLoadingImageView.layer addAnimation:animation forKey:@"FirstLoadSpinAnimation"];
    }
    else {
        [self.saveLoadingImageView.layer removeAnimationForKey:@"FirstLoadSpinAnimation"];
    }
}

- (NSString *)convertIntoFormattedDateWithTime:(NSNumber *)time {
    NSTimeInterval lastMessageTimeInterval = [time doubleValue] / 1000.0f; //change to second from milisecond
    NSDate *currentDate = [NSDate date];
    NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
    
    NSTimeInterval timeGap = currentTimeInterval - lastMessageTimeInterval;
    NSDateFormatter *midnightDateFormatter = [[NSDateFormatter alloc] init];
    [midnightDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]]; // POSIX to avoid weird issues
    midnightDateFormatter.dateFormat = @"dd-MMM-yyyy";
    NSString *midnightFormattedCreatedDate = [midnightDateFormatter stringFromDate:currentDate];
    
    NSDate *todayMidnightDate = [midnightDateFormatter dateFromString:midnightFormattedCreatedDate];
    NSTimeInterval midnightTimeInterval = [todayMidnightDate timeIntervalSince1970];
    
    NSTimeInterval midnightTimeGap = currentTimeInterval - midnightTimeInterval;
    
    NSDate *lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastMessageTimeInterval];
    NSString *lastMessageDateString = @"";
    if (timeGap <= midnightTimeGap) {
        //Today
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm";
        NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
        lastMessageDateString = [NSString stringWithFormat:NSLocalizedString(@"at %@", @""), dateString];
    }
    else if (timeGap <= 86400.0f + midnightTimeGap) {
        //Yesterday
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm";
        NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
        lastMessageDateString = [NSString stringWithFormat:NSLocalizedString(@"yesterday at %@", @""), dateString];
    }
    else {
        //Set date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
        
        NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
        lastMessageDateString = [NSString stringWithFormat:NSLocalizedString(@"at %@", @""), dateString];
    }
    
    NSString *statusString = [NSString stringWithFormat:NSLocalizedString(@"Sent %@", @""), lastMessageDateString];
    return statusString;
}


@end
