//
//  TAPProfileView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPProfileView.h"

@interface TAPProfileView ()

@property (strong, nonatomic) UIView *gradientImageView;

@property (nonatomic) CGFloat profileImageHeight;

@property (strong, nonatomic) UIView *loadingBackgroundView;
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIImageView *loadingImageView;
@property (strong, nonatomic) UILabel *loadingLabel;
@property (strong, nonatomic) UIButton *loadingButton;

- (void)animateSaveLoading:(BOOL)isAnimate;

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
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.clipsToBounds = YES;
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
        
        
        UIFont *chatProfileRoomNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileRoomNameLabel];
        UIColor *chatProfileRoomNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatProfileRoomNameLabel];
        _nameLabelHeight = 22.0f;
        _nameLabelBottomPadding = 8.0f;
        _nameLabelYPosition = CGRectGetMaxY(self.profileImageView.frame) - self.nameLabelBottomPadding - self.nameLabelHeight;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, self.nameLabelYPosition, CGRectGetWidth(self.frame) - 16.0f - 16.0f, self.nameLabelHeight)];
        self.nameLabel.textColor = chatProfileRoomNameLabelColor;
        self.nameLabel.font = chatProfileRoomNameLabelFont;
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
        navigationBackButtonImage = [navigationBackButtonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
        [self.navigationBackButton setImage:navigationBackButtonImage forState:UIControlStateNormal];
        self.navigationBackButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 18.0f);
        self.navigationBackButton.alpha = 0.0f;
        [self.navigationBarView addSubview:self.navigationBackButton];
        
        _navigationEditButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 40.0f - 16.0f, CGRectGetHeight(self.navigationBarView.frame) - navigationBackButtonBottomGap - 40.0f, 40.0f, 40.0f)];
        UIImage *navigationEditButtonImage = [UIImage imageNamed:@"TAPIconEditOrange" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.navigationEditButton setImage:navigationEditButtonImage forState:UIControlStateNormal];
        self.navigationEditButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
        self.navigationEditButton.alpha = 0.0f;
        [self.navigationBarView addSubview:self.navigationEditButton];
        
        _navigationNameLabelHeight = 19.0f;
        _navigationNameLabelBottomPadding = 12.0f;
        _navigationNameLabelYPosition = CGRectGetMaxY(self.profileImageView.frame) - topPadding + CGRectGetHeight(self.navigationBarView.frame) - self.navigationNameLabelBottomPadding - self.navigationNameLabelHeight;
        
        UIFont *navigationBarTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarTitleLabel];
        UIColor *navigationBarTitleColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarTitleLabel];
        _navigationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0f, self.navigationNameLabelYPosition, CGRectGetWidth([UIScreen mainScreen].bounds) - 73.0f - 73.0f, 19.0f)];
        self.navigationNameLabel.textColor = navigationBarTitleColor;
        self.navigationNameLabel.font = navigationBarTitleFont;
        self.navigationNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationBarView addSubview:self.navigationNameLabel];
        
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, self.navigationBarHeight - navigationBackButtonBottomGap - 40.0f, 40.0f, 40.0f)];
        UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconTransparentBackgroundBackButton]];
        [self.backButton setImage:buttonImage forState:UIControlStateNormal];
        self.backButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 18.0f);
        [self addSubview:self.backButton];
        
        _editButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 40.0f - 16.0f, self.navigationBarHeight - navigationBackButtonBottomGap - 40.0f, 40.0f, 40.0f)];
        UIImage *editButtonImage = [UIImage imageNamed:@"TAPIconEdit" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.editButton setImage:editButtonImage forState:UIControlStateNormal];
        self.editButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
        [self addSubview:self.editButton];
        
        //Save Loading View
        _loadingBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.loadingBackgroundView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        self.loadingBackgroundView.alpha = 0.0;
        [self addSubview:self.loadingBackgroundView];
        
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 150.0f) / 2.0f, (CGRectGetHeight(self.frame) - 150.0f) / 2.0f, 150.0f, 150.0f)];
        self.loadingView.backgroundColor = [UIColor whiteColor];
        self.loadingView.layer.shadowRadius = 5.0f;
        self.loadingView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f].CGColor;
        self.loadingView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.loadingView.layer.shadowOpacity = 1.0f;
        self.loadingView.layer.masksToBounds = NO;
        self.loadingView.layer.cornerRadius = 6.0f;
        self.loadingView.clipsToBounds = YES;
        [self.loadingBackgroundView addSubview:self.loadingView];
        
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.loadingView.frame) - 60.0f) / 2.0f, 28.0f, 60.0f, 60.0f)];
        [self.loadingView addSubview:self.loadingImageView];
        
        UIFont *popupLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupLoadingLabel];
        UIColor *popupLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupLoadingLabel];
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, CGRectGetMaxY(self.loadingImageView.frame) + 8.0f, CGRectGetWidth(self.loadingView.frame) - 8.0f - 8.0f, 20.0f)];
        self.loadingLabel.font = popupLabelFont;
        self.loadingLabel.textColor = popupLabelColor;
        self.loadingLabel.textAlignment = NSTextAlignmentCenter;
        [self.loadingView addSubview:self.loadingLabel];
        
        _loadingButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.loadingBackgroundView.frame), CGRectGetHeight(self.loadingBackgroundView.frame))];
        self.loadingButton.alpha = 0.0f;
        self.loadingButton.userInteractionEnabled = NO;
        [self.loadingBackgroundView addSubview:self.loadingButton];

    }
    
    return self;
}

#pragma mark - Custom Method
- (void)showLoadingView:(BOOL)isShow {
    if (isShow) {
        [UIView animateWithDuration:0.2f animations:^{
            self.loadingBackgroundView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.loadingBackgroundView.alpha = 0.0f;
        }];
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
        [self.loadingImageView.layer addAnimation:animation forKey:@"FirstLoadSpinAnimation"];
    }
    else {
        [self.loadingImageView.layer removeAnimationForKey:@"FirstLoadSpinAnimation"];
    }
}

- (void)setAsLoadingState:(BOOL)isLoading withType:(TAPProfileLoadingType)type {
    
    NSString *loadingString;
    NSString *doneLoadingString;
    
    switch (type) {
        case TAPProfileLoadingTypeAppointAdmin:
        {
            loadingString = @"Updating...";
            doneLoadingString = @"Admin Promoted";
             break;
        }
        case TAPProfileLoadingTypeRemoveAdmin:
        {
            loadingString = @"Updating...";
            doneLoadingString = @"Admin Demoted";
            break;
        }
        case TAPProfileLoadingTypeRemoveMember:
        {
            loadingString = @"Removing...";
            doneLoadingString = @"Member Removed";
            break;
        }
        case TAPProfileLoadingTypeAddToContact:
        {
            loadingString = @"Adding...";
            doneLoadingString = @"Contact Added";
            break;
        }
        case TAPProfileLoadingTypeLeaveGroup:
        {
            loadingString = @"Removing...";
            doneLoadingString = @"Group Removed";
            break;
        }
        case TAPProfileLoadingTypeDoneLoading:
        {
            loadingString = @"";
            doneLoadingString = @"";
            break;
        }
        default:
        {
            loadingString = @"Updating...";
            doneLoadingString = @"Success";
            break;
        }
    }
    
    if (isLoading) {
        [self animateSaveLoading:YES];
        self.loadingImageView.image = [UIImage imageNamed:@"TAPIconImageSaving" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.loadingLabel.text = NSLocalizedString(loadingString, @"");
        self.loadingButton.alpha = 1.0f;
        self.loadingButton.userInteractionEnabled = YES;
    }
    else {
        [self animateSaveLoading:NO];
        self.loadingImageView.image = [UIImage imageNamed:@"TAPIconImageSaved" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.loadingLabel.text = NSLocalizedString(doneLoadingString, @"");
        self.loadingButton.alpha = 1.0f;
        self.loadingButton.userInteractionEnabled = YES;
    }
}

@end
