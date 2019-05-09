//
//  TAPImagePreviewView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImagePreviewView.h"

@interface TAPImagePreviewView ()

@property (strong, nonatomic) UIView *contentBackgroundView;
@property (strong, nonatomic) UIView *thumbnailBackgroundGradientView;
@property (strong, nonatomic) UIView *topMenuView;
@property (strong, nonatomic) UILabel *numberOfImageInfoLabel;
@property (strong, nonatomic) UIImageView *morePictureImageView;

@property (strong, nonatomic) UIView *alertView;
@property (strong, nonatomic) UILabel *alertTitleLabel;
@property (strong, nonatomic) UILabel *alertDetailLabel;
@property (strong, nonatomic) UIImageView *alertImageView;

@end

@implementation TAPImagePreviewView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _contentBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.contentBackgroundView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.contentBackgroundView];
        
        CGFloat topMenuYPosition = 0.0f;
        CGFloat topMenuViewHeight = 44.0f;
        CGFloat bottomMenuViewHeight = 48.0f;
        CGFloat bottomMenuYPosition = CGRectGetHeight(self.frame) - bottomMenuViewHeight;
        CGFloat imagePreviewCollectionViewHeight = CGRectGetHeight(self.frame) - topMenuViewHeight - bottomMenuViewHeight;
        
        if (IS_IPHONE_X_FAMILY) {
            topMenuYPosition = [TAPUtil safeAreaTopPadding];
            bottomMenuYPosition = bottomMenuYPosition - [TAPUtil safeAreaBottomPadding];
            imagePreviewCollectionViewHeight = imagePreviewCollectionViewHeight - [TAPUtil safeAreaTopPadding] - [TAPUtil safeAreaBottomPadding];
        }
        
        //Top Menu View
        _topMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, topMenuYPosition, CGRectGetWidth(self.frame), topMenuViewHeight)];
        self.topMenuView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.topMenuView];
        
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _imagePreviewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.topMenuView.frame), CGRectGetWidth(self.frame), imagePreviewCollectionViewHeight) collectionViewLayout:collectionLayout];
        self.imagePreviewCollectionView.backgroundColor = [UIColor clearColor];
        self.imagePreviewCollectionView.pagingEnabled = YES;
        self.imagePreviewCollectionView.showsVerticalScrollIndicator = NO;
        self.imagePreviewCollectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.imagePreviewCollectionView];
        
        _numberOfImageInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 32.0f - 50.0f, (CGRectGetHeight(self.topMenuView.frame) - 21.0f) / 2.0f, 50.0f, 21.0f)];
        self.numberOfImageInfoLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:17.0f];
        self.numberOfImageInfoLabel.textColor = [UIColor whiteColor];
        self.numberOfImageInfoLabel.textAlignment = NSTextAlignmentCenter;
        [self.topMenuView addSubview:self.numberOfImageInfoLabel];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, (CGRectGetHeight(self.topMenuView.frame) - 21.0f) / 2.0f, 60.0f, 21.0f)];
        [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
        self.cancelButton.backgroundColor = [UIColor clearColor];
        self.cancelButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:17.0f];
        [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.topMenuView addSubview:self.cancelButton];
        
        _thumbnailBackgroundGradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.topMenuView.frame), CGRectGetWidth(self.frame), 56.0f)];
        CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];
        backgroundGradientLayer.frame = self.thumbnailBackgroundGradientView.bounds;
        backgroundGradientLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor, (id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor, (id)[[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor, (id)[[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor, (id)[UIColor clearColor].CGColor];
        [self.thumbnailBackgroundGradientView.layer insertSublayer:backgroundGradientLayer atIndex:0];
        [self addSubview:self.thumbnailBackgroundGradientView];
        
        UICollectionViewFlowLayout *thumbnailCollectionLayout = [[UICollectionViewFlowLayout alloc] init];
        thumbnailCollectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _thumbnailCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.topMenuView.frame), CGRectGetWidth(self.frame), 58.0f) collectionViewLayout:thumbnailCollectionLayout];
        self.thumbnailCollectionView.backgroundColor = [UIColor clearColor];
        self.thumbnailCollectionView.showsVerticalScrollIndicator = NO;
        self.thumbnailCollectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.thumbnailCollectionView];
        
        //Bottom Menu View
        _bottomMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, bottomMenuYPosition, CGRectGetWidth(self.frame), bottomMenuViewHeight)];
        self.bottomMenuView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.bottomMenuView];
        
        _morePictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, (CGRectGetHeight(self.bottomMenuView.frame) - 24.0f) / 2.0f, 24.0f, 24.0f)];
        self.morePictureImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.morePictureImageView.image = [UIImage imageNamed:@"TAPIconAddImage" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bottomMenuView addSubview:self.morePictureImageView];
        
        _morePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.morePictureImageView.frame) - 8.0f, CGRectGetMinY(self.morePictureImageView.frame) - 8.0f, CGRectGetWidth(self.morePictureImageView.frame) + 16.0f, CGRectGetHeight(self.morePictureImageView.frame) + 16.0f)];
        [self.bottomMenuView addSubview:self.morePictureButton];
        
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bottomMenuView.frame) - 40.0f - 16.0f, (CGRectGetHeight(self.bottomMenuView.frame) - 21.0f) / 2.0f, 40.0f, 21.0f)];
        [self.sendButton setTitle:NSLocalizedString(@"Send", @"") forState:UIControlStateNormal];
        self.sendButton.backgroundColor = [UIColor clearColor];
        self.sendButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:17.0f];
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.sendButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [self.bottomMenuView addSubview:self.sendButton];
        
        //Caption View
        //top gap + textview height + textview bottom gap + separator height + bottom gap
        CGFloat captionViewInitialHeight = 12.0f + 22.0f + 12.0f + 1.0f + 10.0f;
        _captionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.bottomMenuView.frame) - captionViewInitialHeight, CGRectGetWidth(self.frame), captionViewInitialHeight)];
        self.captionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
        [self addSubview:self.captionView];
        
        CGFloat wordCountLabelWidth = 50.0f;
        CGFloat captionTextViewWidth = CGRectGetWidth(self.captionView.frame) - 16.0f - 16.0f - 8.0f - wordCountLabelWidth;
        _captionTextView = [[TAPCustomGrowingTextView alloc] initWithFrame:CGRectMake(16.0f, 12.0f, captionTextViewWidth, 22.0f)];
        [self.captionTextView setCharacterCountLimit:TAP_LIMIT_OF_CAPTION_CHARACTER];
        [self.captionView addSubview:self.captionTextView];
        
        _captionSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.captionTextView.frame) + 12.0f, CGRectGetWidth(self.frame) - 32.0f, 1.0f)];
        self.captionSeparatorView.backgroundColor = [UIColor whiteColor];
        [self.captionView addSubview:self.captionSeparatorView];
        
        _wordCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - wordCountLabelWidth - 16.0f, CGRectGetMinY(self.captionSeparatorView.frame) - 15.0f - 13.0f, wordCountLabelWidth, 13.0f)];
        self.wordCountLabel.textAlignment = NSTextAlignmentRight;
        self.wordCountLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:11.0f];
        self.wordCountLabel.textColor = [UIColor whiteColor];
        [self.captionView addSubview:self.wordCountLabel];
        
        //Alert View
        _alertContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.bottomMenuView.frame) - 92.0f, CGRectGetWidth(self.frame), 92.0f)];
        self.alertContainerView.alpha = 0.0f;
        self.alertContainerView.backgroundColor = [UIColor clearColor];
        self.alertContainerView.clipsToBounds = YES;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.alertContainerView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, [[TAPUtil getColor:@"040404"] colorWithAlphaComponent:0.4f].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.alertContainerView.layer insertSublayer:gradient atIndex:0];
        [self addSubview:self.alertContainerView];
        
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 20.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 20.0f, 62.0f)];
        self.alertView.backgroundColor = [TAPUtil getColor:@"FDF1F2"];
        self.alertView.layer.borderWidth = 1.0f;
        self.alertView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_CORALPINK_6A].CGColor;
        self.alertView.layer.cornerRadius = 8.0f;
        [self.alertContainerView addSubview:self.alertView];
        
        _alertImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0f, 14.0f, 16.0f, 16.0f)];
        self.alertImageView.image = [UIImage imageNamed:@"TAPIconWarning" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.alertImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.alertImageView.clipsToBounds = YES;
        self.alertImageView.layer.cornerRadius = CGRectGetHeight(self.alertImageView.frame) / 2.0f;
        [self.alertView addSubview:self.alertImageView];
        
        _alertTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.alertImageView.frame) + 6.0f, 12.0f, CGRectGetWidth(self.alertView.frame) - CGRectGetWidth(self.alertImageView.frame) - 6.0f - 10.0f - 10.0f, 20.0f)];
        self.alertTitleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_MEDIUM size:14.0f];
        self.alertTitleLabel.textColor = [TAPUtil getColor:TAP_COLOR_CORALPINK_6A];
        self.alertTitleLabel.text = [NSString stringWithFormat:@"Exceeded %ldMB upload limit", TAP_MAX_VIDEO_SIZE];
        [self.alertView addSubview:self.alertTitleLabel];
        
        _alertDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.alertTitleLabel.frame), CGRectGetMaxY(self.alertTitleLabel.frame), CGRectGetWidth(self.alertTitleLabel.frame), 16.0f)];
        self.alertDetailLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:12.0f];
        self.alertDetailLabel.textColor = [TAPUtil getColor:TAP_COLOR_CORALPINK_6A];
        self.alertDetailLabel.text = NSLocalizedString(@"Please remove this video to continue", @"");
        [self.alertView addSubview:self.alertDetailLabel];
    }
    
    return self;
}

#pragma mark - Lifecycle
- (void)setItemNumberWithCurrentNumber:(NSInteger)current ofTotalNumber:(NSInteger)total {
    NSString *formattedTotalString = [NSString stringWithFormat:@"%ld of %ld", current, total];
    self.numberOfImageInfoLabel.text = formattedTotalString;
    
    //resize label
    CGSize contentSize = [self.numberOfImageInfoLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.numberOfImageInfoLabel.frame))];
    self.numberOfImageInfoLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - 32.0f - contentSize.width, CGRectGetMinY(self.numberOfImageInfoLabel.frame), contentSize.width, CGRectGetHeight(self.numberOfImageInfoLabel.frame));
}

- (void)setCurrentWordCountWithCurrentCharCount:(NSInteger)charCount {
    NSString *wordCountString = [NSString stringWithFormat:@"%ld/100", charCount];
    self.wordCountLabel.text = wordCountString;
}

- (void)isShowCounterCharCount:(BOOL)isShow {
    if (isShow) {
        self.wordCountLabel.alpha = 1.0f;
    }
    else {
        self.wordCountLabel.alpha = 0.0f;
    }
}

- (void)isShowAsSingleImagePreview:(BOOL)isShow animated:(BOOL)animated {
    if (animated) {
        if (isShow) {
            [UIView animateWithDuration:0.2f animations:^{
                self.numberOfImageInfoLabel.alpha = 0.0f;
                self.thumbnailCollectionView.alpha = 0.0f;
                self.thumbnailCollectionView.userInteractionEnabled = NO;
                self.thumbnailBackgroundGradientView.alpha = 0.0f;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.numberOfImageInfoLabel.alpha = 1.0f;
                self.thumbnailCollectionView.alpha = 1.0f;
                self.thumbnailCollectionView.userInteractionEnabled = YES;
                self.thumbnailBackgroundGradientView.alpha = 1.0f;
            }];
        }
    }
    else {
        if (isShow) {
            self.numberOfImageInfoLabel.alpha = 0.0f;
            self.thumbnailCollectionView.alpha = 0.0f;
            self.thumbnailCollectionView.userInteractionEnabled = NO;
            self.thumbnailBackgroundGradientView.alpha = 0.0f;
        }
        else {
            self.numberOfImageInfoLabel.alpha = 1.0f;
            self.thumbnailCollectionView.alpha = 1.0f;
            self.thumbnailCollectionView.userInteractionEnabled = YES;
            self.thumbnailBackgroundGradientView.alpha = 1.0f;
        }
    }
}

- (void)showExcedeedFileSizeAlertView:(BOOL)isShow animated:(BOOL)animated {
    if (animated) {
        if (isShow) {
            [UIView animateWithDuration:0.2f animations:^{
                self.alertContainerView.alpha = 1.0f;
                self.captionView.alpha = 0.0f;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.alertContainerView.alpha = 0.0f;
                self.captionView.alpha = 1.0f;
            }];
        }
    }
    else {
        if (isShow) {
            self.alertContainerView.alpha = 1.0f;
            self.captionView.alpha = 0.0f;
        }
        else {
            self.alertContainerView.alpha = 0.0f;
            self.captionView.alpha = 1.0f;
        }
    }
}

- (void)enableSendButton:(BOOL)isEnable {
    if (isEnable) {
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.sendButton.userInteractionEnabled = YES;
    }
    else {
        [self.sendButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f] forState:UIControlStateNormal];
        self.sendButton.userInteractionEnabled = NO;
    }
}

@end
