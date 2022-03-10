//
//  TAPMyAccountView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 04/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPMyAccountView.h"

@interface TAPMyAccountView ()

@property (strong, nonatomic) UILabel *changeLabel;
@property (strong, nonatomic) UILabel *loadingLabel;
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIImageView *changeIconImageView;
@property (strong, nonatomic) UIImageView *loadingImageView;
@property (strong, nonatomic) UIView *loadingBackgroundView;

@property (strong, nonatomic) UILabel *logoutLabel;
@property (strong, nonatomic) UIView *logoutSeparatorView;
@property (strong, nonatomic) UIImageView *logoutIconImageView;

@property (strong, nonatomic) UIView *halfRoundWhiteBackgroundView;

@property (strong, nonatomic) UIView *logoutLoadingBackgroundView;
@property (strong, nonatomic) UIView *logoutLoadingView;
@property (strong, nonatomic) UIImageView *logoutLoadingImageView;
@property (strong, nonatomic) UILabel *logoutLoadingLabel;
@property (strong, nonatomic) UIButton *logoutLoadingButton;

@property (strong, nonatomic) UIView *progressBarBackgroundView;
@property (strong, nonatomic) UIView *progressBarView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) CGFloat lastProgress;
@property (nonatomic) CGFloat newProgress;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) NSInteger updateInterval;
@property (strong, nonatomic) UIView *bioView;
@property (strong, nonatomic) UIView *bioContainerView;

//View Container
@property (strong, nonatomic) UIView *accountDetailViewContainer;

@property (strong, nonatomic) UILabel *versionLabel;

- (void)setChangeImageButtonAsEnabled:(BOOL)enabled;
- (void)animateFinishedUploadingImage;

@end

@implementation TAPMyAccountView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetMaxY(self.scrollView.frame));
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        [self addSubview:self.scrollView];
        
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
        //[self.scrollView addSubview:self.halfRoundWhiteBackgroundView];
        
        _additionalWhiteBounceView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 0.0f)];
        self.additionalWhiteBounceView.backgroundColor = [UIColor whiteColor];
        //[self.scrollView addSubview:self.additionalWhiteBounceView];
        
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO])];
        self.shadowView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.3f];
        self.shadowView.layer.shadowRadius = 2.0f;
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.shadowView.layer.shadowOpacity = 1.0f;
        self.shadowView.layer.masksToBounds = NO;
        self.shadowView.alpha = 0.0f;
        //[self addSubview:self.shadowView];
        
        _navigationHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO])];
        self.navigationHeaderView.backgroundColor = [UIColor whiteColor];
        //[self addSubview:self.navigationHeaderView];
        
        _navigationSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.navigationHeaderView.frame) - 1.0f, CGRectGetWidth(self.navigationHeaderView.frame), 1.0f)];
        self.navigationSeparatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        self.navigationSeparatorView.alpha = 0.0f;
        [self.navigationHeaderView addSubview:self.navigationSeparatorView];
        
        //12.0f = nav bar height (44.0f) - height / 2
        _cancelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, [TAPUtil currentDeviceStatusBarHeight] + 10.0f, 24.0f, 24.0f)];
        UIImage *closeImage = [UIImage imageNamed:@"TAPIconClose" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        closeImage = [closeImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarCloseButton]];
        self.cancelImageView.image = closeImage;
        //[self addSubview:self.cancelImageView];

        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.cancelImageView.frame) - 8.0f, CGRectGetMinY(self.cancelImageView.frame) - 8.0f, 40.0f, 40.0f)];
        //[self addSubview:self.cancelButton];
        
        UIFont *navigationBarTitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarTitleLabel];
        UIColor *navigationBarTitleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarTitleLabel];
        CGFloat leftGap = CGRectGetMaxX(self.cancelButton.frame) + 32.0f;
        _navigationHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftGap, [TAPUtil currentDeviceStatusBarHeight] + 9.0f, CGRectGetWidth(self.navigationHeaderView.frame) - leftGap - leftGap, 25.0f)];
        self.navigationHeaderLabel.textColor = navigationBarTitleLabelColor;
        self.navigationHeaderLabel.font = navigationBarTitleLabelFont;
        self.navigationHeaderLabel.textAlignment = NSTextAlignmentCenter;
        self.navigationHeaderLabel.text = NSLocalizedStringFromTableInBundle(@"My Account", nil, [TAPUtil currentBundle], @"");
        [self.navigationHeaderView addSubview:self.navigationHeaderLabel];
        
        _initialNameView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f,  CGRectGetWidth(self.frame), 360.0f)];
        self.initialNameView.alpha = 0.0f;
        //self.initialNameView.layer.cornerRadius = CGRectGetHeight(self.initialNameView.frame) / 2.0f;
        self.initialNameView.clipsToBounds = YES;
        [self.scrollView addSubview:self.initialNameView];
        
        UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarExtraLargeLabel];
        UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarExtraLargeLabel];
        _initialNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.initialNameView.frame), CGRectGetHeight(self.initialNameView.frame))];
        self.initialNameLabel.font = initialNameLabelFont;
        self.initialNameLabel.textColor = initialNameLabelColor;
        self.initialNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.initialNameView addSubview:self.initialNameLabel];
        
        _profileImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,  CGRectGetWidth(self.frame), 360.0f)];
        //self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2.0f;
        self.profileImageView.alpha = 0.0f;
        self.profileImageView.layer.masksToBounds = YES;
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.scrollView addSubview:self.profileImageView];

        //profile image collectionview
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _profilImageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 360.0f) collectionViewLayout:collectionLayout];
        self.profilImageCollectionView.backgroundColor = [UIColor clearColor];
        self.profilImageCollectionView.pagingEnabled = YES;
        self.profilImageCollectionView.showsVerticalScrollIndicator = NO;
        self.profilImageCollectionView.showsHorizontalScrollIndicator = NO;
        self.profilImageCollectionView.alpha = 0.0f;
        [self.scrollView addSubview:self.profilImageCollectionView];
        
        UICollectionViewFlowLayout *collectionLayout2 = [[UICollectionViewFlowLayout alloc] init];
        collectionLayout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _pageIndicatorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, CGRectGetWidth(self.frame), 3.0f) collectionViewLayout:collectionLayout2];
        self.pageIndicatorCollectionView.backgroundColor = [UIColor clearColor];
        self.pageIndicatorCollectionView.pagingEnabled = YES;
        self.pageIndicatorCollectionView.showsVerticalScrollIndicator = NO;
        self.pageIndicatorCollectionView.showsHorizontalScrollIndicator = NO;
        self.pageIndicatorCollectionView.alpha = 0.0f;
        [self.scrollView addSubview:self.pageIndicatorCollectionView];
        
        _progressBarBackgroundView = [[UIView alloc] initWithFrame:self.profileImageView.frame];
        self.progressBarBackgroundView.layer.cornerRadius = CGRectGetWidth(self.progressBarBackgroundView.frame) / 2.0f;
        self.progressBarBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        self.progressBarBackgroundView.alpha = 0.0f;
        //[self.scrollView addSubview:self.progressBarBackgroundView];

        _progressBarView = [[UIView alloc] initWithFrame:CGRectMake(12.0f, 12.0f, CGRectGetWidth(self.progressBarBackgroundView.frame) - 12.0f - 12.0f, CGRectGetWidth(self.progressBarBackgroundView.frame) - 12.0f - 12.0f)];
        self.progressBarView.backgroundColor = [UIColor clearColor];
        [self.progressBarBackgroundView addSubview:self.progressBarView];

        //CS TEMP - hide remove profilebutton temporaryly
//        _removeProfilePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) - 24.0f, CGRectGetMinY(self.profileImageView.frame), 24.0f, 24.0f)];
//        [self.removeProfilePictureButton setImage:[UIImage imageNamed: @"TAPIconRemoveSharedMedia"] forState:UIControlStateNormal];
//        self.removeProfilePictureButton.alpha = 0.0f;
//        [self.scrollView addSubview:self.removeProfilePictureButton];
        
        UIFont *clickableLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableLabel];
        UIColor *clickableLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableLabel];
        _changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.profileImageView.frame) + 8.0f, 100.0f, 22.0f)];
        self.changeLabel.font = clickableLabelFont;
        self.changeLabel.text = NSLocalizedStringFromTableInBundle(@"Set New Profile Picture", nil, [TAPUtil currentBundle], @"");
        self.changeLabel.textColor = clickableLabelColor;
        CGSize changeLabelSize = [self.changeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 22.0f)];
        self.changeLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - changeLabelSize.width - 4.0f - 14.0f) / 2, CGRectGetMinY(self.changeLabel.frame), changeLabelSize.width, 22.0f);
        [self.scrollView addSubview:self.changeLabel];


        _changeIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.changeLabel.frame) + 4.0f, CGRectGetMinY(self.changeLabel.frame), 20.0f, 20.0f)];
        self.changeIconImageView.image = [UIImage imageNamed:@"TAPIconEditPicture" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.changeIconImageView.image = [self.changeIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChangePicture]];

        //[self.scrollView addSubview:self.changeIconImageView];

        _changeProfilePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.changeLabel.frame), CGRectGetMinY(self.changeLabel.frame) - 8.0f, CGRectGetWidth(self.changeLabel.frame) + 4.0f + CGRectGetWidth(self.changeIconImageView.frame), 40.0f)];
        [self.scrollView addSubview:self.changeProfilePictureButton];
        
        //Account Detail
        _accountDetailViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.changeLabel.frame), CGRectGetWidth(self.frame), 400.0f)];
        [self.scrollView addSubview:self.accountDetailViewContainer];
        
        //Bio Field
        _bioLabelField = [[TAPCustomLabelView alloc] initWithFrame:CGRectMake(0.0f, 24.0f, CGRectGetWidth(self.frame), 62.0f)];
        [self.bioLabelField setAccountDetailFieldString: NSLocalizedStringFromTableInBundle(@"BIO", nil, [TAPUtil currentBundle], @"") description: NSLocalizedStringFromTableInBundle(@"ssssss", nil, [TAPUtil currentBundle], @"")];
        [self.accountDetailViewContainer addSubview:self.bioLabelField];

        //Username Field
        _usernameLabelField = [[TAPCustomLabelView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bioLabelField.frame), CGRectGetWidth(self.frame), 62.0f)];
        [self.accountDetailViewContainer addSubview:self.usernameLabelField];
        
        //Mobile Number Field
        _mobileNumberLabelField = [[TAPCustomLabelView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.usernameLabelField.frame), CGRectGetWidth(self.frame), 62.0f)];
        [self.accountDetailViewContainer addSubview:self.mobileNumberLabelField];
        
        //Email Address Field
        _emailLabelField = [[TAPCustomLabelView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.mobileNumberLabelField.frame), CGRectGetWidth(self.frame), 62.0f)];
        [self.emailLabelField  setAccountDetailFieldString: NSLocalizedStringFromTableInBundle(@"EMAIL ADDRESS", nil, [TAPUtil currentBundle], @"") description: NSLocalizedStringFromTableInBundle(@"aaaa", nil, [TAPUtil currentBundle], @"")];
        [self.emailLabelField showSeparatorView:NO];
        [self.accountDetailViewContainer addSubview:self.emailLabelField];
        
        self.accountDetailViewContainer.frame = CGRectMake(0.0f, CGRectGetMaxY(self.changeLabel.frame), CGRectGetWidth(self.frame), CGRectGetMaxY(self.emailLabelField.frame));
         
        //Edit View
        _editViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.changeLabel.frame), CGRectGetWidth(self.frame), 900.0f)];
        [self.scrollView addSubview:self.editViewContainer];
        
        self.editViewContainer.alpha = 0.0f;
        
        _fullNameTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, 24.0f, CGRectGetWidth(self.frame), 0.0f)];
        [self.fullNameTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypeFullName];
        self.fullNameTextField.frame = CGRectMake(CGRectGetMinX(self.fullNameTextField.frame), CGRectGetMinY(self.fullNameTextField.frame), CGRectGetWidth(self.fullNameTextField.frame), [self.fullNameTextField getTextFieldHeight]);
        [self.editViewContainer addSubview:self.fullNameTextField];
        
        _bioView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.fullNameTextField.frame) + 24.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, 0.0f)];
        [self.editViewContainer addSubview:self.bioView];
        
        UIFont *formLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontFormLabel];
        UIColor *formLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorFormLabel];
        
        UILabel *bioTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 21.0f)];
        bioTitleLabel.text = @"Bio";
        bioTitleLabel.font = formLabelFont;
        bioTitleLabel.textColor = formLabelColor;
        [self.bioView addSubview:bioTitleLabel];
        
        UIFont *counterLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontAlbumCountLabel];
        UIColor *counterLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorAlbumCountLabel];
        
        _bioWordCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bioView.frame) - 80.0f, 0.0f, 80.0f, 21.0f)];
        self.bioWordCounterLabel.text = @"0/100";
        self.bioWordCounterLabel.font = counterLabelFont;
        self.bioWordCounterLabel.textColor = counterLabelColor;
        self.bioWordCounterLabel.textAlignment = NSTextAlignmentRight;
        [self.bioView addSubview:self.bioWordCounterLabel];
        
        UIFont *bioTextViewFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontFormTextField];
        UIColor *bioTextViewColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorFormTextField];
        UIColor *bioPlaceholderTextViewColor = [[[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorFormTextFieldPlaceholder] colorWithAlphaComponent:0.4f];
        
        self.bioContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bioTitleLabel.frame) + 8.0f, CGRectGetWidth(self.bioView.frame), 50.0f)];
        self.bioContainerView.backgroundColor = [UIColor whiteColor];
        self.bioContainerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive].CGColor;
        self.bioContainerView.layer.cornerRadius = 8.0f;
        self.bioContainerView.layer.borderWidth = 1.0f;
        [self.bioView addSubview:self.bioContainerView];
        
        _bioTextView = [[TAPCustomGrowingTextView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bioContainerView.frame) + 16.0f, CGRectGetMinY(self.bioContainerView.frame) + 12.0f, CGRectGetWidth(self.bioContainerView.frame) - 16.0f - 16.0f, 24.0f)];
        [self.bioTextView setCharacterCountLimit:[[TapTalk sharedInstance] getMaxCaptionLength]];
        self.bioTextView.minimumHeight = 24.0f;
        [self.bioTextView setFont:bioTextViewFont];
        [self.bioTextView setTextColor:[UIColor blackColor]];
        [self.bioTextView setPlaceholderColor:bioPlaceholderTextViewColor];
        self.bioTextView.tintColor = bioTextViewColor;
        [self.bioView addSubview:self.bioTextView];
        
        self.bioView.frame = CGRectMake(16.0f, CGRectGetMaxY(self.fullNameTextField.frame) + 24.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, CGRectGetMaxY(self.bioContainerView.frame));

        _usernameTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bioView.frame) + 24.0f, CGRectGetWidth(self.frame), 0.0f)];
        [self.usernameTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypeUsernameWithoutDescription];
        self.usernameTextField.frame = CGRectMake(CGRectGetMinX(self.usernameTextField.frame), CGRectGetMinY(self.usernameTextField.frame), CGRectGetWidth(self.usernameTextField.frame), [self.usernameTextField getTextFieldHeight]);
        [self.editViewContainer addSubview:self.usernameTextField];

        _mobileNumberTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.usernameTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 0.0f)];
        [self.mobileNumberTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypeMobileNumber];
        self.mobileNumberTextField.frame = CGRectMake(CGRectGetMinX(self.mobileNumberTextField.frame), CGRectGetMinY(self.mobileNumberTextField.frame), CGRectGetWidth(self.mobileNumberTextField.frame), [self.mobileNumberTextField getTextFieldHeight]);
        [self.editViewContainer addSubview:self.mobileNumberTextField];

        _emailTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.mobileNumberTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 0.0f)];
        [self.emailTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypeEmailOptional];
        self.emailTextField.frame = CGRectMake(CGRectGetMinX(self.emailTextField.frame), CGRectGetMinY(self.emailTextField.frame), CGRectGetWidth(self.emailTextField.frame), [self.emailTextField getTextFieldHeight]);
        [self.editViewContainer addSubview:self.emailTextField];

        if (![[TapUI sharedInstance] getChangeProfilePictureButtonVisibleState]) {
            self.changeIconImageView.alpha = 0.0f;
            self.changeLabel.alpha = 0.0f;
            self.changeProfilePictureButton.alpha = 0.0f;
            self.removeProfilePictureButton.alpha = 0.0f;
        }

        if ([[TapUI sharedInstance] getLogoutButtonVisibleState]) {
            _logoutView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.emailTextField.frame) + 24.0f, CGRectGetWidth(self.frame) - 32.0f, 50.0f)];
            self.logoutView.alpha = 1.0f;
        }
        else {
            _logoutView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.emailTextField.frame), CGRectGetWidth(self.frame) - 32.0f, 0.0f)];
            self.logoutView.alpha = 0.0f;
        }
        
        self.logoutView.backgroundColor = [TAPUtil getColor:@"EF5060"];
        self.logoutView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREY_DC].CGColor;
        self.logoutView.layer.borderWidth = 1.0f;
        self.logoutView.layer.cornerRadius = 8.0f;
        [self.editViewContainer addSubview:self.logoutView];

        _logoutSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.logoutView.frame) - 50.0f - 1.0f, 0.0f, 1.0f, CGRectGetHeight(self.logoutView.frame))];
        self.logoutSeparatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        //[self.logoutView addSubview:self.logoutSeparatorView];
        
        UIFont *clickableDestructiveFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableDestructiveLabel];
        UIColor *colorButtonLabel = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorButtonLabel];
        CGFloat logoutLabelWidth = CGRectGetWidth(self.logoutView.frame) - 50.0f - 1.0f - 15.0f - 15.0f;
        _logoutLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.logoutView.frame) / 2.0f) - 20.0f, 0.0f, logoutLabelWidth, CGRectGetHeight(self.logoutView.frame))];
        self.logoutLabel.text = NSLocalizedStringFromTableInBundle(@"Logout", nil, [TAPUtil currentBundle], @"");
        self.logoutLabel.textColor = colorButtonLabel;
        self.logoutLabel.font = clickableDestructiveFont;
        [self.logoutView addSubview:self.logoutLabel];
        
        _logoutIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.logoutLabel.frame) - 20.0f - 10.0f, (CGRectGetHeight(self.logoutView.frame) - 20.0f) / 2.0f, 20.0f, 20.0f)];
        self.logoutIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.logoutIconImageView.image = [UIImage imageNamed:@"TAPIconLogoutWhite" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.logoutIconImageView.tintColor = [UIColor whiteColor];
        [self.logoutView addSubview:self.logoutIconImageView];

        _logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.logoutView.frame), CGRectGetHeight(self.logoutView.frame))];
        [self.logoutView addSubview:self.logoutButton];
        
        self.editViewContainer.frame = CGRectMake(0.0f, CGRectGetMaxY(self.changeLabel.frame), CGRectGetWidth(self.frame), CGRectGetMaxY(self.logoutView.frame));

        _continueButtonView = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.logoutView.frame) + 24.0f, CGRectGetWidth(self.frame), 50.0f)];
        [self.continueButtonView setCustomButtonViewType:TAPCustomButtonViewTypeInactive];
        [self.continueButtonView setButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Continue", nil, [TAPUtil currentBundle], @"")];
//        [self.scrollView addSubview:self.continueButtonView]; //CS TEMP - hide continue button
        
        //Logout Loading View
        _logoutLoadingBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.logoutLoadingBackgroundView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        self.logoutLoadingBackgroundView.alpha = 0.0;
        [self addSubview:self.logoutLoadingBackgroundView];
        
        _logoutLoadingView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 150.0f) / 2.0f, (CGRectGetHeight(self.frame) - 150.0f) / 2.0f, 160.0f, 160.0f)];
        self.logoutLoadingView.backgroundColor = [UIColor whiteColor];
        self.logoutLoadingView.layer.shadowRadius = 5.0f;
        self.logoutLoadingView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f].CGColor;
        self.logoutLoadingView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.logoutLoadingView.layer.shadowOpacity = 1.0f;
        self.logoutLoadingView.layer.masksToBounds = NO;
        self.logoutLoadingView.layer.cornerRadius = 6.0f;
        self.logoutLoadingView.clipsToBounds = YES;
        [self.logoutLoadingBackgroundView addSubview:self.logoutLoadingView];
        
        _logoutLoadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.logoutLoadingView.frame) - 60.0f) / 2.0f, 28.0f, 60.0f, 60.0f)];
        [self.logoutLoadingView addSubview:self.logoutLoadingImageView];
        
        UIFont *popupLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupLoadingLabel];
        UIColor *popupLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupLoadingLabel];
        _logoutLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, CGRectGetMaxY(self.logoutLoadingImageView.frame) + 16.0f, CGRectGetWidth(self.logoutLoadingView.frame) - 8.0f - 8.0f, 20.0f)];
        self.logoutLoadingLabel.font = popupLabelFont;
        self.logoutLoadingLabel.textColor = popupLabelColor;
        self.logoutLoadingLabel.textAlignment = NSTextAlignmentCenter;
        [self.logoutLoadingView addSubview:self.logoutLoadingLabel];
        
        _logoutLoadingButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.logoutLoadingBackgroundView.frame), CGRectGetHeight(self.logoutLoadingBackgroundView.frame))];
        self.logoutLoadingButton.alpha = 0.0f;
        self.logoutLoadingButton.userInteractionEnabled = NO;
        [self.logoutLoadingBackgroundView addSubview:self.logoutLoadingButton];
        
        _loadingBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.loadingBackgroundView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        self.loadingBackgroundView.alpha = 0.0;
        [self addSubview:self.loadingBackgroundView];
        
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 150.0f) / 2.0f, (CGRectGetHeight(self.frame) - 150.0f) / 2.0f, 160.0f, 160.0f)];
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
        
        
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, CGRectGetMaxY(self.loadingImageView.frame) + 16.0f, CGRectGetWidth(self.loadingView.frame) - 8.0f - 8.0f, 20.0f)];
        self.loadingLabel.font = popupLabelFont;
        self.loadingLabel.textColor = popupLabelColor;
        self.loadingLabel.textAlignment = NSTextAlignmentCenter;
        [self.loadingView addSubview:self.loadingLabel];
        
        //VERSION SECTION
        NSString *appVersion = @"";
        appVersion =  [appVersion stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
#ifdef DEBUG
        appVersion = [NSString stringWithFormat:@"%@-DEBUG(%@)", appVersion, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]; //DEBUG
#else
        appVersion = [NSString stringWithFormat:@"%@(%@)", appVersion, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]; //RELEASE
#endif
        
        //AS NOTE - ADDED VERSION LABEL
        CGFloat padding = 16.0f;
        UIFont *versionLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontVersionCode];
        UIColor *versionLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorVersionCode];
        _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(self.editViewContainer.frame) + 24.0f, CGRectGetWidth(self.frame) - padding - padding, 16.0f)];
        self.versionLabel.text = [NSString stringWithFormat:@"V %@", appVersion];
        self.versionLabel.textColor = [[TAPUtil getColor:TAP_COLOR_TEXT_DARK] colorWithAlphaComponent:0.4f];
        self.versionLabel.font = versionLabelFont;
        [self.scrollView addSubview:self.versionLabel];
        //END AS NOTE - ADDED VERSION LABEL
        
        CGFloat bottomGap = 24.0f;
        if (IS_IPHONE_X_FAMILY) {
            bottomGap = [TAPUtil safeAreaBottomPadding] + 24.0f;
        }

        if (IS_IOS_13_OR_ABOVE) {
//            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.logoutView.frame) + bottomGap + [TAPUtil topGapPresentingViewController]); //AS NOTE - OLD VALUE
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.versionLabel.frame) + bottomGap + [TAPUtil topGapPresentingViewController]);
        }
        else {
//            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.logoutView.frame) + bottomGap); //AS NOTE - OLD VALUE
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.versionLabel.frame) + bottomGap);
        }
        
//        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.continueButtonView.frame) + bottomGap); //CS TEMP - hide continue button

        _startAngle = M_PI * 1.5;
        _endAngle = self.startAngle + (M_PI * 2);
        _newProgress = 0.0f;
        _updateInterval = 1;
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)updateGrowingTextViewPosition:(CGFloat)textViewHeight {
    CGFloat updatedTextViewGap = textViewHeight - self.bioTextView.minimumHeight;
    self.bioContainerView.frame = CGRectMake(0.0f, CGRectGetMinY(self.bioContainerView.frame), CGRectGetWidth(self.bioView.frame), 25.0+textViewHeight);
    self.bioView.frame = CGRectMake(16.0f, CGRectGetMaxY(self.fullNameTextField.frame) + 24.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, CGRectGetMaxY(self.bioContainerView.frame));
    [self refreshViewPosition];
}

- (void)setCurrentWordCountWithCurrentCharCount:(NSInteger)charCount {
    NSString *wordCountString = [NSString stringWithFormat:@"%ld/%ld", charCount, [[TapTalk sharedInstance] getMaxCaptionLength]];
    self.bioWordCounterLabel.text = wordCountString;
}

- (void)refreshViewPosition {
    [UIView animateWithDuration:0.2f animations:^{
        self.fullNameTextField.frame = CGRectMake(CGRectGetMinX(self.fullNameTextField.frame), CGRectGetMinY(self.fullNameTextField.frame), CGRectGetWidth(self.fullNameTextField.frame), [self.fullNameTextField getTextFieldHeight]);
        self.usernameTextField.frame = CGRectMake(CGRectGetMinX(self.usernameTextField.frame), CGRectGetMaxY(self.bioView.frame) + 24.0f, CGRectGetWidth(self.usernameTextField.frame), [self.usernameTextField getTextFieldHeight]);
        self.mobileNumberTextField.frame = CGRectMake(CGRectGetMinX(self.mobileNumberTextField.frame), CGRectGetMaxY(self.usernameTextField.frame) + 24.0f, CGRectGetWidth(self.mobileNumberTextField.frame), [self.mobileNumberTextField getTextFieldHeight]);
        self.emailTextField.frame = CGRectMake(CGRectGetMinX(self.emailTextField.frame), CGRectGetMaxY(self.mobileNumberTextField.frame) + 24.0f, CGRectGetWidth(self.emailTextField.frame), [self.emailTextField getTextFieldHeight]);
        
        if ([[TapUI sharedInstance] getLogoutButtonVisibleState]) {
            self.logoutView.frame = CGRectMake(CGRectGetMinX(self.logoutView.frame), CGRectGetMaxY(self.emailTextField.frame) + 24.0f, CGRectGetWidth(self.logoutView.frame), CGRectGetHeight(self.logoutView.frame));
        }
        else {
            self.logoutView.frame = CGRectMake(CGRectGetMinX(self.logoutView.frame), CGRectGetMaxY(self.emailTextField.frame), CGRectGetWidth(self.logoutView.frame), 0.0f);
        }
        
        self.usernameLabelField.frame = CGRectMake(0.0f, CGRectGetMaxY(self.bioLabelField.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.usernameLabelField.frame));
        self.bioLabelField.frame = CGRectMake(0.0f, 24.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.bioLabelField.frame));
        self.mobileNumberLabelField.frame = CGRectMake(0.0f, CGRectGetMaxY(self.usernameLabelField.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.mobileNumberLabelField.frame));
        self.emailLabelField.frame = CGRectMake(0.0f, CGRectGetMaxY(self.mobileNumberLabelField.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.emailLabelField.frame));
        
        if(self.editViewContainer.alpha == 1.0f){
            self.editViewContainer.frame = CGRectMake(0.0f, CGRectGetMaxY(self.changeLabel.frame), CGRectGetWidth(self.frame), CGRectGetMaxY(self.logoutView.frame));
            self.versionLabel.frame = CGRectMake(self.versionLabel.frame.origin.x, CGRectGetMaxY(self.editViewContainer.frame) + 24.0f, CGRectGetWidth(self.versionLabel.frame), 16.0f);
        }
        else{
            self.accountDetailViewContainer.frame = CGRectMake(0.0f, CGRectGetMaxY(self.changeLabel.frame), CGRectGetWidth(self.frame), CGRectGetMaxY(self.emailLabelField.frame));
            self.versionLabel.frame = CGRectMake(self.versionLabel.frame.origin.x, CGRectGetMaxY(self.accountDetailViewContainer.frame) + 24.0f, CGRectGetWidth(self.versionLabel.frame), 16.0f);
        }
        
        //CS TEMP - uncomment below code to show password
        //        self.passwordTextField.frame = CGRectMake(CGRectGetMinX(self.passwordTextField.frame), CGRectGetMaxY(self.emailTextField.frame) + 24.0f, CGRectGetWidth(self.passwordTextField.frame), [self.passwordTextField getTextFieldHeight]);
        //        self.retypePasswordTextField.frame = CGRectMake(CGRectGetMinX(self.retypePasswordTextField.frame), CGRectGetMaxY(self.passwordTextField.frame) + 24.0f, CGRectGetWidth(self.retypePasswordTextField.frame), [self.retypePasswordTextField getTextFieldHeight]);
        //        self.continueButtonView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.retypePasswordTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 50.0f);
        //END CS TEMP
        self.continueButtonView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.logoutView.frame) + 24.0f, CGRectGetWidth(self.frame), 50.0f); // CS TEMP - remove this line of code to show password
        
        CGFloat bottomGap = 24.0f;
        if (IS_IPHONE_X_FAMILY) {
            bottomGap = [TAPUtil safeAreaBottomPadding] + 24.0f;
        }
        
        if (IS_IOS_13_OR_ABOVE) {
//            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.continueButtonView.frame) + bottomGap + [TAPUtil topGapPresentingViewController]); //AS NOTE - OLD VALUE
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.versionLabel.frame) + bottomGap + [TAPUtil topGapPresentingViewController]); //AS NOTE - NEW VALUE
        }
        else {
//            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.continueButtonView.frame) + bottomGap); //AS NOTE - OLD VALUE
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.versionLabel.frame) + bottomGap); //AS NOTE - NEW VALUE
        }
    }];
}

- (void)showAccountDetailView{
    self.editViewContainer.alpha = 0.0f;
    self.accountDetailViewContainer.alpha = 1.0f;
    self.changeLabel.text = NSLocalizedStringFromTableInBundle(@"Set New Profile Picture", nil, [TAPUtil currentBundle], @"");
    
    CGSize changeLabelSize = [self.changeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 22.0f)];
    self.changeLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - changeLabelSize.width - 4.0f - 14.0f) / 2, CGRectGetMinY(self.changeLabel.frame), changeLabelSize.width, 22.0f);
    self.changeProfilePictureButton.frame = CGRectMake(CGRectGetMinX(self.changeLabel.frame), CGRectGetMinY(self.changeLabel.frame) - 8.0f, CGRectGetWidth(self.changeLabel.frame) + 4.0f + CGRectGetWidth(self.changeIconImageView.frame), 40.0f);
    [self setEditPorfilPictureButtonVisible:YES];
    
    self.accountDetailViewContainer.frame = CGRectMake(0.0f, CGRectGetMaxY(self.changeLabel.frame), CGRectGetWidth(self.frame), CGRectGetMaxY(self.emailLabelField.frame));
    
    self.versionLabel.frame = CGRectMake(self.versionLabel.frame.origin.x, CGRectGetMaxY(self.accountDetailViewContainer.frame) + 24.0f, CGRectGetWidth(self.versionLabel.frame), 16.0f);
    [self refreshViewPosition];
}

- (void)showEditAccountView{
    self.editViewContainer.alpha = 1.0f;
    self.accountDetailViewContainer.alpha = 0.0f;
    self.changeLabel.text = NSLocalizedStringFromTableInBundle(@"Edit Profile Picture", nil, [TAPUtil currentBundle], @"");
    
    CGSize changeLabelSize = [self.changeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 22.0f)];
    self.changeLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - changeLabelSize.width - 4.0f - 14.0f) / 2, CGRectGetMinY(self.changeLabel.frame), changeLabelSize.width, 22.0f);
    self.changeProfilePictureButton.frame = CGRectMake(CGRectGetMinX(self.changeLabel.frame), CGRectGetMinY(self.changeLabel.frame) - 8.0f, CGRectGetWidth(self.changeLabel.frame) + 4.0f + CGRectGetWidth(self.changeIconImageView.frame), 40.0f);
    
    self.versionLabel.frame = CGRectMake(self.versionLabel.frame.origin.x, CGRectGetMaxY(self.editViewContainer.frame) + 24.0f, CGRectGetWidth(self.versionLabel.frame), 16.0f);
    [self refreshViewPosition];
}

- (void)setEditPorfilPictureButtonVisible:(BOOL) isVisible{
    if(isVisible){
        if(self.editViewContainer.alpha == 1){
            self.changeLabel.text = NSLocalizedStringFromTableInBundle(@"Edit Profile Picture", nil, [TAPUtil currentBundle], @"");
        }
        else{
            self.changeLabel.text = NSLocalizedStringFromTableInBundle(@"Set New Profile Picture", nil, [TAPUtil currentBundle], @"");
        }
        
        self.changeProfilePictureButton.alpha = 1.0f;
    }
    else{
        self.changeLabel.text = @"";
        self.changeProfilePictureButton.alpha = 0.0f;
    }
}

- (void)showMultipleProfilePicture{
    self.profilImageCollectionView.alpha = 1.0f;
    self.pageIndicatorCollectionView.alpha = 1.0f;
    self.profileImageView.alpha = 0.0f;
}

- (void)setContinueButtonEnabled:(BOOL)enable {
    [self.continueButtonView setAsActiveState:enable animated:NO];
}

- (void)setChangeImageButtonAsEnabled:(BOOL)enabled {
    if (enabled) {
        self.changeProfilePictureButton.enabled = YES;
        self.changeIconImageView.alpha = 1.0f;
        self.changeLabel.alpha = 1.0f;
    }
    else {
        self.changeProfilePictureButton.enabled = NO;
        self.changeIconImageView.alpha = 0.0f;
        self.changeLabel.alpha = 0.0f;
    }
}

- (void)setContentEditable:(BOOL)editable {
    if (editable) {
        [self.fullNameTextField setAsEnabled:YES];
        [self.usernameTextField setAsEnabled:YES];
        [self.emailTextField setAsEnabled:YES];
    }
    else {
        [self.fullNameTextField setAsEnabled:NO];
        [self.usernameTextField setAsEnabled:NO];
        [self.emailTextField setAsEnabled:NO];
    }
}

//DV Note
//UserFullName used to show initials when image is null or not found
//END DV Note
- (void)setProfilePictureWithImage:(UIImage *)image userFullName:(NSString *)userFullName{
    if (image ==  nil) {
        self.profileImageView.alpha = 0.0f;
        self.initialNameView.alpha = 1.0f;
        self.removeProfilePictureButton.alpha = 0.0f;
        self.initialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:userFullName];
        self.initialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:userFullName isGroup:NO];
    }
    else {
        self.profileImageView.alpha = 1.0f;
        self.initialNameView.alpha = 0.0f;
        self.profileImageView.image = image;
        self.removeProfilePictureButton.alpha = 1.0f;
    }
}

- (void)setProfilePictureWithImageURL:(NSString *)imageURL userFullName:(NSString *)userFullName{
    if (imageURL ==  nil || [imageURL isEqualToString:@""]) {
        self.profileImageView.alpha = 0.0f;
        self.initialNameView.alpha = 1.0f;
        self.removeProfilePictureButton.alpha = 0.0f;
        self.initialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:userFullName];
        self.initialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:userFullName isGroup:NO];
        self.profilImageCollectionView.alpha = 0.0f;
        self.pageIndicatorCollectionView.alpha = 0.0f;
    }
    else {
        self.profileImageView.alpha = 1.0f;
        self.initialNameView.alpha = 0.0f;
        [self.profileImageView setImageWithURLString:imageURL];
        self.removeProfilePictureButton.alpha = 1.0f;
        self.profilImageCollectionView.alpha = 1.0f;
        self.pageIndicatorCollectionView.alpha = 1.0f;
    }
}

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

- (void)setAsLoadingState:(BOOL)isLoading withType:(TAPMyAccountLoadingType)type {
    [self showLoadingView:isLoading];
    NSString *loadingString;
    NSString *doneLoadingString;

    switch (type) {
        case TAPMyAccountLoadingTypeSetProfilPicture:
        {
            loadingString = NSLocalizedStringFromTableInBundle(@"Uploading...", nil, [TAPUtil currentBundle], @"");
            doneLoadingString = NSLocalizedStringFromTableInBundle(@"Success", nil, [TAPUtil currentBundle], @"");
            break;
        }
            
        case TAPMyAccountLoadingTypeUpadating:
        {
            loadingString = NSLocalizedStringFromTableInBundle(@"Updating...", nil, [TAPUtil currentBundle], @"");
            doneLoadingString = NSLocalizedStringFromTableInBundle(@"Success", nil, [TAPUtil currentBundle], @"");
            break;
        }
        case TAPMyAccountLoadingTypeSaveImage:
        {
            loadingString = NSLocalizedStringFromTableInBundle(@"Saving...", nil, [TAPUtil currentBundle], @"");
            doneLoadingString = NSLocalizedStringFromTableInBundle(@"Done", nil, [TAPUtil currentBundle], @"");
            break;
        }
        default:
        {
            loadingString = NSLocalizedStringFromTableInBundle(@"Updating...", nil, [TAPUtil currentBundle], @"");
            doneLoadingString = NSLocalizedStringFromTableInBundle(@"Success", nil, [TAPUtil currentBundle], @"");
            break;
        }
            
    }
    
    if (isLoading) {
        [self animateSaveLoading:YES];
        self.loadingImageView.image = [UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.loadingImageView.image = [self.loadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
        self.loadingLabel.text = loadingString;
        //self.loadingButton.alpha = 1.0f;
        //self.loadingButton.userInteractionEnabled = YES;
    }
    else {
        [self animateSaveLoading:NO];
        self.loadingImageView.image = [UIImage imageNamed:@"TAPIconImageSaved" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.loadingImageView.image = [self.loadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingPopupSuccess]];
        self.loadingLabel.text = doneLoadingString;
        //self.loadingButton.alpha = 1.0f;
        //self.loadingButton.userInteractionEnabled = YES;
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

- (void)setAsLoading:(BOOL)loading {
    //set navigation view & image upload loading
    if (loading) {
        [self setChangeImageButtonAsEnabled:NO];
        self.cancelButton.enabled = NO;
        self.loadingImageView.alpha = 1.0f;
        self.cancelImageView.alpha = 0.0f;
        self.loadingLabel.alpha = 1.0f;
        self.progressBarBackgroundView.alpha = 1.0f;
        
        //ADD ANIMATION
        if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] == nil) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.cumulative = YES;
            animation.removedOnCompletion = NO;
            [self.loadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
    }
    else {
        [self setChangeImageButtonAsEnabled:YES];
        self.cancelButton.enabled = YES;
        self.loadingImageView.alpha = 0.0f;
        self.cancelImageView.alpha = 1.0f;
        self.loadingLabel.alpha = 0.0f;

        //REMOVE ANIMATION
        if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
            [self.loadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
        }
        
        [self animateFinishedUploadingImage];
    }
}

- (void)animateProgressUploadingImageWithProgress:(CGFloat)progress total:(CGFloat)total {
    CGFloat lastProgress = self.lastProgress;
    _newProgress = progress/total;
    
    self.progressBarBackgroundView.alpha = 1.0f;
    
    NSInteger lastPercentage = (NSInteger)floorf((100.0f * lastProgress));
    
    //Circular Progress Bar using CAShapeLayer and UIBezierPath
    _progressLayer = [CAShapeLayer layer];
    [self.progressLayer setFrame:self.progressBarView.bounds];
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.progressBarView.bounds), CGRectGetMidY(self.progressBarView.bounds)) radius:(self.progressBarView.bounds.size.height) / 2 startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    
    self.progressLayer.lineCap = kCALineCapSquare;
    self.progressLayer.strokeColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorFileProgressBackgroundWhite].CGColor;
    self.progressLayer.lineWidth = 6.0f;
    self.progressLayer.path = progressPath.CGPath;
    self.progressLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.position = CGPointMake(self.progressBarView.layer.frame.size.width / 2 , self.progressBarView.layer.frame.size.height / 2 );
    [self.progressLayer setStrokeEnd:0.0f];
    [self.progressBarView.layer addSublayer:self.progressLayer];
    
    [self.progressLayer setStrokeEnd:self.newProgress];
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.duration = self.updateInterval;
    [strokeEndAnimation setFillMode:kCAFillModeForwards];
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    strokeEndAnimation.removedOnCompletion = NO;
    strokeEndAnimation.fromValue = [NSNumber numberWithFloat:self.lastProgress];
    strokeEndAnimation.toValue = [NSNumber numberWithFloat:self.newProgress];
    _lastProgress = self.newProgress;
    [self.progressLayer addAnimation:strokeEndAnimation forKey:@"progressStatus"];
}

- (void)animateFinishedUploadingImage {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    _progressLayer = nil;
    
    self.progressBarBackgroundView.alpha = 0.0f;
}

- (void)showLogoutLoadingView:(BOOL)isShow {
    if (isShow) {
        [self animateLogoutLoading:YES];
        [UIView animateWithDuration:0.2f animations:^{
            self.logoutLoadingBackgroundView.alpha = 1.0f;
        }];
    }
    else {
        [self animateLogoutLoading:NO];
        [UIView animateWithDuration:0.2f animations:^{
            self.logoutLoadingBackgroundView.alpha = 0.0f;
        }];
    }
}

- (void)animateLogoutLoading:(BOOL)isAnimate {
    if (isAnimate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.duration = 1.5f;
        animation.repeatCount = INFINITY;
        animation.removedOnCompletion = NO;
        [self.logoutLoadingImageView.layer addAnimation:animation forKey:@"FirstLoadSpinAnimation"];
        
        self.logoutLoadingImageView.image = [UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.logoutLoadingImageView.image = [self.logoutLoadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
        self.logoutLoadingLabel.text = NSLocalizedStringFromTableInBundle(@"Logging out...", nil, [TAPUtil currentBundle], @"");
        self.logoutLoadingButton.alpha = 1.0f;
        self.logoutLoadingButton.userInteractionEnabled = YES;

    }
    else {
        [self.logoutLoadingImageView.layer removeAnimationForKey:@"FirstLoadSpinAnimation"];
    }
}

@end
