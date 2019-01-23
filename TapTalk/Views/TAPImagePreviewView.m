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
        self.numberOfImageInfoLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:17.0f];
        self.numberOfImageInfoLabel.textColor = [UIColor whiteColor];
        self.numberOfImageInfoLabel.textAlignment = NSTextAlignmentCenter;
        [self.topMenuView addSubview:self.numberOfImageInfoLabel];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, (CGRectGetHeight(self.topMenuView.frame) - 21.0f) / 2.0f, 60.0f, 21.0f)];
        [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
        self.cancelButton.backgroundColor = [UIColor clearColor];
        self.cancelButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:17.0f];
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
        
        _morePictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, (CGRectGetHeight(self.bottomMenuView.frame) - 30.0f) / 2.0f, 30.0f, 30.0f)];
        self.morePictureImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.morePictureImageView.image = [UIImage imageNamed:@"TAPIconAddImage" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bottomMenuView addSubview:self.morePictureImageView];
        
        _morePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.morePictureImageView.frame) - 8.0f, CGRectGetMinY(self.morePictureImageView.frame) - 8.0f, CGRectGetWidth(self.morePictureImageView.frame) + 16.0f, CGRectGetHeight(self.morePictureImageView.frame) + 16.0f)];
        [self.bottomMenuView addSubview:self.morePictureButton];
        
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bottomMenuView.frame) - 40.0f - 16.0f, (CGRectGetHeight(self.bottomMenuView.frame) - 21.0f) / 2.0f, 40.0f, 21.0f)];
        [self.sendButton setTitle:NSLocalizedString(@"Send", @"") forState:UIControlStateNormal];
        self.sendButton.backgroundColor = [UIColor clearColor];
        self.sendButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:17.0f];
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.sendButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [self.bottomMenuView addSubview:self.sendButton];
        
        //Caption View
        //top gap + textview height + textview bottom gap + separator height + bottom gap
        CGFloat captionViewInitialHeight = 12.0f + 22.0f + 12.0f + 1.0f + 10.0f;
        _captionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.bottomMenuView.frame) - captionViewInitialHeight, CGRectGetWidth(self.frame), captionViewInitialHeight)];
        self.captionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
        [self addSubview:self.captionView];
        
        CGFloat wordLeftLabelWidth = 50.0f;
        CGFloat captionTextViewWidth = CGRectGetWidth(self.captionView.frame) - 16.0f - 16.0f - 8.0f - wordLeftLabelWidth;
        _captionTextView = [[TAPCustomGrowingTextView alloc] initWithFrame:CGRectMake(16.0f, 12.0f, captionTextViewWidth, 22.0f)];
        [self.captionView addSubview:self.captionTextView];
        
        _captionSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.captionTextView.frame) + 12.0f, CGRectGetWidth(self.frame) - 32.0f, 1.0f)];
        self.captionSeparatorView.backgroundColor = [UIColor whiteColor];
        [self.captionView addSubview:self.captionSeparatorView];
        
        _wordLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - wordLeftLabelWidth - 16.0f, CGRectGetMinY(self.captionSeparatorView.frame) - 15.0f - 13.0f, wordLeftLabelWidth, 13.0f)];
        self.wordLeftLabel.textAlignment = NSTextAlignmentRight;
        self.wordLeftLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
        self.wordLeftLabel.textColor = [UIColor whiteColor];
        
        [self.captionView addSubview:self.wordLeftLabel];
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

- (void)setCurrentWordLeftWithCurrentCharCount:(NSInteger)charCount {
    NSString *wordLeft = [NSString stringWithFormat:@"%ld/100", charCount];
    self.wordLeftLabel.text = wordLeft;
}

- (void)isShowCounterCharLeft:(BOOL)isShow {
    if (isShow) {
        self.wordLeftLabel.alpha = 1.0f;
    }
    else {
        self.wordLeftLabel.alpha = 0.0f;
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

@end
