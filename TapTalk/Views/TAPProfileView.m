//
//  TAPProfileView.m
//  TapTalk
//
//  Created by Welly Kencana on 30/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPProfileView.h"

@interface TAPProfileView ()

@property (strong, nonatomic) UIView *gradientImageView;

@property (nonatomic) CGFloat profileImageHeight;

@end

@implementation TAPProfileView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _profileImageHeight = CGRectGetWidth(self.frame) / 375.0f * 347.0f; //375.0f and 347.0f are width and height on design.
        CGFloat topPadding = 0.0f;
        if (IS_IPHONE_X_FAMILY) {
            topPadding = [TAPUtil currentDeviceStatusBarHeight];
        }
        
        _profileImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(0.0f, topPadding, CGRectGetWidth(self.frame), self.profileImageHeight)];
        [self addSubview:self.profileImageView];
        
        _gradientImageView = [[UIView alloc] initWithFrame:self.profileImageView.frame];
        self.gradientImageView.backgroundColor = [UIColor clearColor];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.gradientImageView.bounds;
        gradient.colors = [NSArray arrayWithObjects:[[UIColor blackColor] colorWithAlphaComponent:0.4f].CGColor, [[UIColor blackColor] colorWithAlphaComponent:0.18f].CGColor, [[UIColor blackColor] colorWithAlphaComponent:0.0f].CGColor, [[UIColor blackColor] colorWithAlphaComponent:0.4f].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.gradientImageView.layer insertSublayer:gradient atIndex:0];
        [self addSubview:self.gradientImageView];
        
        _nameLabelHeight = 22.0f;
        _nameLabelBottomPadding = 8.0f;
        _nameLabelYPosition = CGRectGetMaxY(self.profileImageView.frame) - self.nameLabelBottomPadding - self.nameLabelHeight;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, self.nameLabelYPosition, CGRectGetWidth(self.frame) - 16.0f - 16.0f, self.nameLabelHeight)];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:20.0f];
        [self addSubview:self.nameLabel];
        
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, topPadding, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - [TAPUtil safeAreaBottomPadding]) collectionViewLayout:collectionLayout];
        self.collectionView.contentInset = UIEdgeInsetsMake(self.profileImageHeight - [TAPUtil currentDeviceStatusBarHeight] + topPadding, 0.0f, 8.0f, 0.0f); //-statusBarHeight because the inset start after status bar.
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.bounces = NO;
        [self addSubview:self.collectionView];
        
        _navigationBarHeight = 44.0f + [TAPUtil currentDeviceStatusBarHeight];
        _navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -self.navigationBarHeight + topPadding, CGRectGetWidth([UIScreen mainScreen].bounds), self.navigationBarHeight)];
        self.navigationBarView.clipsToBounds = YES;
        self.navigationBarView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.navigationBarView];
        
        CGFloat navigationBackButtonBottomGap = 2.0f;
        _navigationBackButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, CGRectGetHeight(self.navigationBarView.frame) - navigationBackButtonBottomGap - 40.0f, 40.0f, 40.0f)];
        UIImage *navigationBackButtonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.navigationBackButton setImage:navigationBackButtonImage forState:UIControlStateNormal];
        self.navigationBackButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 18.0f);
        self.navigationBackButton.alpha = 0.0f;
        [self.navigationBarView addSubview:self.navigationBackButton];
        
        _navigationNameLabelHeight = 19.0f;
        _navigationNameLabelBottomPadding = 12.0f;
        _navigationNameLabelYPosition = CGRectGetMaxY(self.profileImageView.frame) - topPadding + CGRectGetHeight(self.navigationBarView.frame) - self.navigationNameLabelBottomPadding - self.navigationNameLabelHeight;
        _navigationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0f, self.navigationNameLabelYPosition, CGRectGetWidth([UIScreen mainScreen].bounds) - 73.0f - 73.0f, 19.0f)];
        self.navigationNameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.navigationNameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:17.0f];
        self.navigationNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationBarView addSubview:self.navigationNameLabel];
        
        
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, self.navigationBarHeight - navigationBackButtonBottomGap - 40.0f, 40.0f, 40.0f)];
        UIImage *backButtonImage = [UIImage imageNamed:@"TAPIconBackArrowWhite" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.backButton setImage:backButtonImage forState:UIControlStateNormal];
        self.backButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 18.0f);
        [self addSubview:self.backButton];
    }
    
    return self;
}

#pragma mark - Custom Method


@end
