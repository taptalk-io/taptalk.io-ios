//
//  TAPCreateGroupSubjectView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 19/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCreateGroupSubjectView.h"

@interface TAPCreateGroupSubjectView()

@property (strong, nonatomic) UIView *groupPictureNameView;

@property (strong, nonatomic) UIView *selectedContactsShadowView;

@property (strong, nonatomic) UIView *halfRoundWhiteBackgroundView;

@property (strong, nonatomic) UIImageView *cancelImageView;
@property (strong, nonatomic) UIImageView *backImageView;
@property (strong, nonatomic) UILabel *navigationHeaderLabel;
@property (strong, nonatomic) UIView *navigationHeaderView;

@property (strong, nonatomic) UILabel *groupPictureTitleLabel;
@property (strong, nonatomic) UIView *groupPictureView;

@property (strong, nonatomic) UILabel *changeLabel;
@property (strong, nonatomic) UILabel *loadingLabel;
@property (strong, nonatomic) UIImageView *changeIconImageView;
@property (strong, nonatomic) UIImageView *loadingImageView;

@property (strong, nonatomic) UILabel *groupNameTitleLabel;

@property (strong, nonatomic) UIView *progressBarBackgroundView;
@property (strong, nonatomic) UIView *progressBarView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) CGFloat lastProgress;
@property (nonatomic) CGFloat newProgress;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) NSInteger updateInterval;

@end

@implementation TAPCreateGroupSubjectView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        
        _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame) - [TAPUtil safeAreaBottomPadding] - 190.0f)];
        self.bgScrollView.backgroundColor = [UIColor whiteColor];
        self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.frame), CGRectGetMaxY(self.bgScrollView.frame));
        self.bgScrollView.showsVerticalScrollIndicator = NO;
        self.bgScrollView.showsHorizontalScrollIndicator = NO;
        self.bgScrollView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        [self addSubview:self.bgScrollView];
        
        CGFloat profilePictureTopGap = 26.0f;
        if (!IS_IPHONE_X_FAMILY) {
            profilePictureTopGap = 6.0f; //-20.0f for navigation bar height different from iphone 8 and below
        }
        
        //Min Y profile image view + profile image view height + gap with change label + change label height + bottom gap
        CGFloat halfRoundWhiteBackgroundViewHeight = [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO] + profilePictureTopGap + 96.0f + 8.0f + 22.0f + 24.0f;
        _halfRoundWhiteBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(- 4.0f, -halfRoundWhiteBackgroundViewHeight, CGRectGetWidth(self.frame) + 8.0f, halfRoundWhiteBackgroundViewHeight * 2)];
        self.halfRoundWhiteBackgroundView.layer.cornerRadius = CGRectGetWidth(self.halfRoundWhiteBackgroundView.frame) / 2.0f;
        self.halfRoundWhiteBackgroundView.layer.borderWidth = 1.0f;
        self.halfRoundWhiteBackgroundView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREY_DC].CGColor;
        self.halfRoundWhiteBackgroundView.backgroundColor = [UIColor whiteColor];
        
        UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.halfRoundWhiteBackgroundView.frame) / 2.0f, CGRectGetWidth(self.halfRoundWhiteBackgroundView.frame), CGRectGetHeight(self.halfRoundWhiteBackgroundView.frame) / 2.0f)];
        mask.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        self.halfRoundWhiteBackgroundView.layer.mask = mask.layer;
        [self.bgScrollView addSubview:self.halfRoundWhiteBackgroundView];
        
        _additionalWhiteBounceView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 0.0f)];
        self.additionalWhiteBounceView.backgroundColor = [UIColor whiteColor];
        [self.bgScrollView addSubview:self.additionalWhiteBounceView];
        
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO])];
        self.shadowView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.3f];
        self.shadowView.layer.shadowRadius = 2.0f;
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.shadowView.layer.shadowOpacity = 1.0f;
        self.shadowView.layer.masksToBounds = NO;
        self.shadowView.alpha = 0.0f;
        [self addSubview:self.shadowView];
        
        _navigationHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO])];
        self.navigationHeaderView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.navigationHeaderView];
        
        _navigationSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.navigationHeaderView.frame) - 1.0f, CGRectGetWidth(self.navigationHeaderView.frame), 1.0f)];
        self.navigationSeparatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        self.navigationSeparatorView.alpha = 0.0f;
        [self.navigationHeaderView addSubview:self.navigationSeparatorView];
        
        //12.0f = nav bar height (44.0f) - height / 2
        _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, [TAPUtil currentDeviceStatusBarHeight] + 10.0f, 24.0f, 24.0f)];
        self.backImageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
        self.backImageView.image = buttonImage;
        self.backImageView.alpha = 1.0f;
        [self addSubview:self.backImageView];
        
        //12.0f = nav bar height (44.0f) - height / 2
        _cancelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 16.0f - 24.0f, [TAPUtil currentDeviceStatusBarHeight] + 10.0f, 24.0f, 24.0f)];
        self.cancelImageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *closeImage = [UIImage imageNamed:@"TAPIconClose" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        closeImage = [closeImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarCloseButton]];
        self.cancelImageView.image = closeImage;
        self.cancelImageView.alpha = 0.0f;
        [self addSubview:self.cancelImageView];
        
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, [TAPUtil currentDeviceStatusBarHeight] + 10.0f, 24.0f, 24.0f)];
        self.loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.loadingImageView.image = [UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.loadingImageView.image = [self.loadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
        self.loadingImageView.alpha = 0.0f;
        [self addSubview:self.loadingImageView];
        
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.backImageView.frame) - 8.0f, CGRectGetMinY(self.backImageView.frame) - 8.0f, 40.0f, 40.0f)];
        self.backButton.alpha = 1.0f;
        [self addSubview:self.backButton];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.cancelImageView.frame) - 8.0f, CGRectGetMinY(self.cancelImageView.frame) - 8.0f, 40.0f, 40.0f)];
        self.cancelButton.alpha = 0.0f;
        [self addSubview:self.cancelButton];

        UIFont *navigationHeaderLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarTitleLabel];
        UIColor *navigationHeaderLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarTitleLabel];
        CGFloat leftGap = CGRectGetMaxX(self.backButton.frame) + 32.0f;
        _navigationHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftGap, [TAPUtil currentDeviceStatusBarHeight] + 9.0f, CGRectGetWidth(self.navigationHeaderView.frame) - leftGap - leftGap, 25.0f)];
        self.navigationHeaderLabel.textColor = navigationHeaderLabelColor;
        self.navigationHeaderLabel.font = navigationHeaderLabelFont;
        self.navigationHeaderLabel.textAlignment = NSTextAlignmentCenter;
        self.navigationHeaderLabel.text = NSLocalizedString(@"Group Subject", @"");
        [self.navigationHeaderView addSubview:self.navigationHeaderLabel];
        
        _groupPictureImageView = [[TAPImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 96.0f) / 2,CGRectGetMaxY(self.navigationHeaderView.frame) + profilePictureTopGap,  96.0f, 96.0f)];
        self.groupPictureImageView.layer.cornerRadius = CGRectGetWidth(self.groupPictureImageView.frame) / 2.0f;
        self.groupPictureImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.groupPictureImageView.layer.masksToBounds = YES;
        self.groupPictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.bgScrollView addSubview:self.groupPictureImageView];
        
        _progressBarBackgroundView = [[UIView alloc] initWithFrame:self.groupPictureView.frame];
        self.progressBarBackgroundView.layer.cornerRadius = CGRectGetWidth(self.progressBarBackgroundView.frame) / 2.0f;
        self.progressBarBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        self.progressBarBackgroundView.alpha = 0.0f;
        [self.bgScrollView addSubview:self.progressBarBackgroundView];
        
        _progressBarView = [[UIView alloc] initWithFrame:CGRectMake(12.0f, 12.0f, CGRectGetWidth(self.progressBarBackgroundView.frame) - 12.0f - 12.0f, CGRectGetWidth(self.progressBarBackgroundView.frame) - 12.0f - 12.0f)];
        self.progressBarView.backgroundColor = [UIColor clearColor];
        [self.progressBarBackgroundView addSubview:self.progressBarView];
        
        _removePictureView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.groupPictureImageView.frame) - 24.0f, CGRectGetMinY(self.groupPictureImageView.frame), 24.0f, 24.0f)];
        self.removePictureView.alpha = 0.0f;
        self.removePictureView.layer.cornerRadius = CGRectGetHeight(self.removePictureView.frame) / 2.0f;
        self.removePictureView.clipsToBounds = YES;
        self.removePictureView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRemoveItem];
        [self.bgScrollView addSubview:self.removePictureView];
        
        _removePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.removePictureView.frame), CGRectGetHeight(self.removePictureView.frame))];
        UIImage *removeImage = [UIImage imageNamed:@"TAPIconRemoveMedia" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        removeImage = [removeImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRemoveItemBackground]];
        [self.removePictureButton setImage:removeImage forState:UIControlStateNormal];
        [self.removePictureView addSubview:self.removePictureButton];
        
        UIFont *clickableLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableLabel];
        UIColor *clickableLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableLabel];
        _changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.groupPictureImageView.frame) + 8.0f, 100.0f, 22.0f)];
        self.changeLabel.font = clickableLabelFont;
        self.changeLabel.text = NSLocalizedString(@"Change", @"");
        self.changeLabel.textColor = clickableLabelColor;
        CGSize changeLabelSize = [self.changeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 22.0f)];
        self.changeLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - changeLabelSize.width - 4.0f - 14.0f) / 2, CGRectGetMinY(self.changeLabel.frame), changeLabelSize.width, 22.0f);
        [self.bgScrollView addSubview:self.changeLabel];
        
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.groupPictureImageView.frame) + 8.0f, CGRectGetWidth(self.frame), 22.0f)];
        self.loadingLabel.font = clickableLabelFont;
        self.loadingLabel.textColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorCreateGroupSubjectLoadingLabel];
        self.loadingLabel.text = NSLocalizedString(@"Uploading", @"");
        self.loadingLabel.alpha = 0.0f;
        self.loadingLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgScrollView addSubview:self.loadingLabel];
        
        _changeIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.changeLabel.frame) + 4.0f, CGRectGetMinY(self.changeLabel.frame) + 4.0f, 14.0f, 14.0f)];
        self.changeIconImageView.image = [UIImage imageNamed:@"TAPIconAddEditItem" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.changeIconImageView.image = [self.changeIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChangePicture]];

        [self.bgScrollView addSubview:self.changeIconImageView];
        
        _changePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.changeLabel.frame), CGRectGetMinY(self.changeLabel.frame) - 8.0f, CGRectGetWidth(self.changeLabel.frame) + 4.0f + CGRectGetWidth(self.changeIconImageView.frame), 40.0f)];
        [self.bgScrollView addSubview:self.changePictureButton];
        
        _groupNameTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.changeLabel.frame) + 48.0f, CGRectGetWidth(self.frame), 0.0f)];
        [self.groupNameTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypeGroupName];
        self.groupNameTextField.frame = CGRectMake(CGRectGetMinX(self.groupNameTextField.frame), CGRectGetMinY(self.groupNameTextField.frame), CGRectGetWidth(self.groupNameTextField.frame), [self.groupNameTextField getTextFieldHeight]);
        [self.bgScrollView addSubview:self.groupNameTextField];
        
        _selectedContactsShadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.frame) - 190.0f - [TAPUtil safeAreaBottomPadding], CGRectGetWidth(self.frame), 190.0f)];
        self.selectedContactsShadowView.backgroundColor = [[TAPUtil getColor:@"191919"]colorWithAlphaComponent:0.1f];
        self.selectedContactsShadowView.layer.shadowOffset = CGSizeMake(0.0f, -1.0f);
        self.selectedContactsShadowView.layer.shadowOpacity = 1.0f;
        self.selectedContactsShadowView.layer.masksToBounds = NO;
        [self addSubview:self.selectedContactsShadowView];
        
        _selectedContactsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 190.0f - [TAPUtil safeAreaBottomPadding], CGRectGetWidth(self.bgScrollView.frame), 190.0f + [TAPUtil safeAreaBottomPadding])];
        self.selectedContactsView.backgroundColor = [UIColor whiteColor];
        self.selectedContactsView.layer.shadowColor = [TAPUtil getColor:TAP_COLOR_GREY_DC].CGColor;
        self.selectedContactsView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.selectedContactsView.layer.shadowOpacity = 0.4f;
        self.selectedContactsView.layer.shadowRadius = 4.0f;
        [self addSubview:self.selectedContactsView];
        
        UIFont *sectionHeaderLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
        UIColor *sectionHeaderColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTableViewSectionHeaderLabel];
        _selectedContactsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.bgScrollView.frame) - 16.0f - 16.0f, 13.0f)];
        self.selectedContactsTitleLabel.font = sectionHeaderLabelFont;
        self.selectedContactsTitleLabel.textColor = sectionHeaderColor;
        [self.selectedContactsView addSubview:self.selectedContactsTitleLabel];
        
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _selectedContactsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.selectedContactsTitleLabel.frame) + 10.0f, CGRectGetWidth(self.selectedContactsView.frame), 74.0f) collectionViewLayout:collectionLayout];
        self.selectedContactsCollectionView.backgroundColor = [UIColor whiteColor];
        self.selectedContactsCollectionView.showsVerticalScrollIndicator = NO;
        self.selectedContactsCollectionView.showsHorizontalScrollIndicator = NO;
        [self.selectedContactsView addSubview:self.selectedContactsCollectionView];
        
        _createButtonView = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.selectedContactsCollectionView.frame) + 16.0f, CGRectGetWidth(self.selectedContactsView.frame), 44.0f)];
        [self.createButtonView setCustomButtonViewType:TAPCustomButtonViewTypeActive];
        [self.createButtonView setCustomButtonViewStyleType:TAPCustomButtonViewStyleTypePlain];
        [self.createButtonView setButtonWithTitle:NSLocalizedString(@"Continue", @"")];
        [self.selectedContactsView addSubview:self.createButtonView];
        
//        TAPStyleModel *buttonLabelStyle = [[TAPStyleManager sharedManager] getComponentStyleForType:TAPComponentStyleButtonLabel];
//        _createButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.selectedContactsCollectionView.frame) + 16.0f, CGRectGetWidth(self.selectedContactsView.frame) - 16.0f - 16.0f , 44.0f)];
//        NSString *createString = NSLocalizedString(@"Create Group", @"");
//        NSMutableDictionary *createAttributesDictionary = [NSMutableDictionary dictionary];
//        CGFloat createLetterSpacing = -0.2f;
//        [createAttributesDictionary setObject:@(createLetterSpacing) forKey:NSKernAttributeName];
//        [createAttributesDictionary setObject:[TAPUtil getColor:buttonLabelStyle.colorCode] forKey:NSForegroundColorAttributeName];
//        NSMutableAttributedString *createAttributedString = [[NSMutableAttributedString alloc] initWithString:createString];
//        [createAttributedString setAttributes:createAttributesDictionary
//                                        range:NSMakeRange(0, [createString length])];
//        [self.createButton setAttributedTitle:createAttributedString forState:UIControlStateNormal];
//        self.createButton.titleLabel.font = [UIFont fontWithName:buttonLabelStyle.fontName size:buttonLabelStyle.fontSize];
//        self.createButton.layer.borderWidth = 1.0f;
//        self.createButton.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentButtonActiveBorderColor].CGColor;
//        self.createButton.layer.cornerRadius = 6.0f;
//        self.createButton.clipsToBounds = YES;
//        CAGradientLayer *gradient = [CAGradientLayer layer];
//        gradient.frame = self.createButton.bounds;
//        gradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentButtonActiveBackgroundGradientLightColor].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentButtonActiveBackgroundGradientDarkColor].CGColor, nil];
//        gradient.startPoint = CGPointMake(0.0f, 0.0f);
//        gradient.endPoint = CGPointMake(0.0f, 1.0f);
//        gradient.cornerRadius = 6.0f;
//        [self.createButton.layer insertSublayer:gradient atIndex:0];
//        self.createButton.userInteractionEnabled = NO;
//        [self.selectedContactsView addSubview:self.createButton];
        
        _startAngle = M_PI * 1.5;
        _endAngle = self.startAngle + (M_PI * 2);
        _newProgress = 0.0f;
        _updateInterval = 1;
        
    }
    
    return self;
}
#pragma mark - Custom Method
- (void)setGroupPictureImageViewWithImage:(UIImage *)image {
    if (image ==  nil) {
        self.groupPictureImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.removePictureView.alpha = 0.0f;
    }
    else {
        self.groupPictureImageView.image = image;
        if (self.tapCreateGroupSubjectType == TAPCreateGroupSubjectViewTypeUpdate) {
            self.removePictureView.alpha = 0.0f;
        }
        else {
            self.removePictureView.alpha = 1.0f;
        }
    }
}

- (void)setTapCreateGroupSubjectType:(TAPCreateGroupSubjectViewType)tapCreateGroupSubjectType {
    _tapCreateGroupSubjectType = tapCreateGroupSubjectType;
    
    if (tapCreateGroupSubjectType == TAPCreateGroupSubjectViewTypeUpdate) {
        self.cancelButton.alpha = 1.0f;
        self.cancelImageView.alpha = 1.0f;
        self.backButton.alpha = 0.0f;
        self.backImageView.alpha = 0.0f;
        self.selectedContactsCollectionView.alpha = 0.0f;
        self.selectedContactsShadowView.alpha = 0.0f;
        self.selectedContactsView.backgroundColor = [UIColor clearColor];
        self.selectedContactsTitleLabel.alpha = 0.0f;
        [self.createButtonView setButtonWithTitle:NSLocalizedString(@"Update", @"")];
    }
}

- (void)setGroupPictureWithImageURL:(NSString *)urlString {
    if ([TAPUtil isEmptyString:urlString]) {
        self.groupPictureImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.removePictureView.alpha = 0.0f;
    }
    else {
        if (self.tapCreateGroupSubjectType == TAPCreateGroupSubjectViewTypeUpdate) {
            self.removePictureView.alpha = 0.0f;
        }
        else {
            self.removePictureView.alpha = 1.0f;
        }
        
        [self.groupPictureImageView setImageWithURLString:urlString];
    }
}
@end
