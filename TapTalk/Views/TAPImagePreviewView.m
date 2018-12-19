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

@property (strong, nonatomic) UIView *topMenuView;
@property (strong, nonatomic) UILabel *numberOfImageInfoLabel;
@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) UIView *captionView;

@property (strong, nonatomic) UIView *bottomMenuView;
@property (strong, nonatomic) UIImageView *morePictureImageView;
@property (strong, nonatomic) UIButton *morePictureButton;
@property (strong, nonatomic) UIButton *sendButton;

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
        CGFloat bottomMenuYPosition = CGRectGetHeight(self.frame) - 48.0f;
        CGFloat topMenuViewHeight = 44.0f;
        CGFloat bottomMenuViewHeight = 48.0f;
        CGFloat imagePreviewCollectionViewHeight = CGRectGetHeight(self.frame) - topMenuViewHeight - bottomMenuViewHeight;
        
        if (IS_IPHONE_X_FAMILY) {
            topMenuYPosition = [TAPUtil safeAreaTopPadding];
            bottomMenuYPosition = bottomMenuYPosition - [TAPUtil safeAreaBottomPadding];
            imagePreviewCollectionViewHeight = imagePreviewCollectionViewHeight - topMenuYPosition - [TAPUtil safeAreaBottomPadding];
        }
        
        //Top Menu View
        _topMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, topMenuYPosition, CGRectGetWidth(self.frame), topMenuViewHeight)];
        self.topMenuView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
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
        
        UICollectionViewFlowLayout *thumbnailCollectionLayout = [[UICollectionViewFlowLayout alloc] init];
        thumbnailCollectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _thumbnailCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.topMenuView.frame), CGRectGetWidth(self.frame), 60.0f) collectionViewLayout:thumbnailCollectionLayout];
        self.thumbnailCollectionView.backgroundColor = [UIColor clearColor];
        self.thumbnailCollectionView.showsVerticalScrollIndicator = NO;
        self.thumbnailCollectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.thumbnailCollectionView];
        
        //Bottom Menu View
        _bottomMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, bottomMenuYPosition, CGRectGetWidth(self.frame), bottomMenuViewHeight)];
        self.bottomMenuView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
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
        _captionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.bottomMenuView.frame) - 58.0f, CGRectGetWidth(self.frame), 58.0f)];
        self.captionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
        [self addSubview:self.captionView];
    }
    
    return self;
}

@end
