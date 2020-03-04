//
//  TAPAddNewContactView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 17/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPAddNewContactView.h"

@interface TAPAddNewContactView ()

@property (strong, nonatomic) UILabel *defaultLabel;
@property (strong, nonatomic) UIView *shadowView;

@property (strong, nonatomic) UIView *searchExpertView;
@property (strong, nonatomic) TAPImageView *coverImageView;
@property (strong, nonatomic) UIView *expertImageContainerView;
@property (strong, nonatomic) UIView *expertInitialView;
@property (strong, nonatomic) UILabel *expertInitialLabel;
@property (strong, nonatomic) TAPImageView *expertImageView;
@property (strong, nonatomic) TAPImageView *expertVerifiedImageView;
@property (strong, nonatomic) UILabel *expertNameLabel;
@property (strong, nonatomic) UILabel *expertCategoryLabel;
@property (strong, nonatomic) UIView *addExpertToContactButtonView;
@property (strong, nonatomic) UILabel *addExpertToContactLabel;
@property (strong, nonatomic) UIView *expertChatNowButtonView;
@property (strong, nonatomic) UIImageView *expertChatNowLogoImageView;
@property (strong, nonatomic) UILabel *expertChatNowLabel;
@property (strong, nonatomic) UIView *searchSelfExpertView;
@property (strong, nonatomic) UILabel *searchSelfExpertLabel;

@property (strong, nonatomic) UIView *searchUserView;
@property (strong, nonatomic) UIView *searchUserShadowView;
@property (strong, nonatomic) UIView *userInitialView;
@property (strong, nonatomic) UILabel *userInitialLabel;
@property (strong, nonatomic) TAPImageView *userImageView;
@property (strong, nonatomic) UILabel *userFullNameLabel;
@property (strong, nonatomic) UILabel *userUsernameLabel;
@property (strong, nonatomic) UIView *addUserToContactButtonView;
@property (strong, nonatomic) UILabel *addUserToContactLabel;
@property (strong, nonatomic) UIView *userChatNowButtonView;
@property (strong, nonatomic) UIImageView *userChatNowLogoImageView;
@property (strong, nonatomic) UILabel *userChatNowLabel;
@property (strong, nonatomic) UIView *searchSelfUserView;
@property (strong, nonatomic) UILabel *searchSelfUserLabel;

@property (strong, nonatomic) UIView *emptyStateView;
@property (strong, nonatomic) UIImageView *emptyStateImageView;
@property (strong, nonatomic) UILabel *emptyStateLabel;

@property (strong, nonatomic) UIImageView *loadingImageView;

@property (strong, nonatomic) UIView *noInternetView;
@property (strong, nonatomic) UIImageView *noInternetImageView;
@property (strong, nonatomic) UILabel *noInternetTitleLabel;
@property (strong, nonatomic) UILabel *noInternetDescriptionLabel;

- (void)showAsSelfSearchWithUserRole:(NSString *)userRole;

@end

@implementation TAPAddNewContactView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 46.0f)];
        self.shadowView.backgroundColor = [UIColor whiteColor];
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.shadowView.layer.shadowOpacity = 1.0f;
        self.shadowView.layer.shadowColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.2f].CGColor;
        self.shadowView.layer.masksToBounds = NO;
        [self addSubview:self.shadowView];
        
        _searchBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 46.0f)];
        self.searchBarBackgroundView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.searchBarBackgroundView];
        
        _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.searchBarBackgroundView.frame) - 16.0f - 16.0f, 30.0f)];
        self.searchBarView.customPlaceHolderString = NSLocalizedStringFromTableInBundle(@"Search by username", nil, [TAPUtil currentBundle], @"");
        [self.searchBarBackgroundView addSubview:self.searchBarView];
        
        UIFont *searchBarCancelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchBarTextCancelButton];
        UIColor *searchBarCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarTextCancelButton];
        _searchBarCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.searchBarView.frame) + 8.0f, 0.0f, 0.0f, CGRectGetHeight(self.searchBarBackgroundView.frame))];
        NSString *searchBarCancelString = NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"");
        NSMutableAttributedString *searchBarCancelAttributedString = [[NSMutableAttributedString alloc] initWithString:searchBarCancelString];
        NSMutableDictionary *searchBarCancelAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat searchBarCancelLetterSpacing = -0.4f;
        [searchBarCancelAttributesDictionary setObject:@(searchBarCancelLetterSpacing) forKey:NSKernAttributeName];
        [searchBarCancelAttributesDictionary setObject:searchBarCancelFont forKey:NSFontAttributeName];
        [searchBarCancelAttributesDictionary setObject:searchBarCancelColor forKey:NSForegroundColorAttributeName];
        [searchBarCancelAttributedString addAttributes:searchBarCancelAttributesDictionary
                                                 range:NSMakeRange(0, [searchBarCancelString length])];
        [self.searchBarCancelButton setAttributedTitle:searchBarCancelAttributedString forState:UIControlStateNormal];
        self.searchBarCancelButton.clipsToBounds = YES;
        [self.searchBarCancelButton addTarget:self action:@selector(searchBarCancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.searchBarBackgroundView addSubview:self.searchBarCancelButton];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 30.0f)];
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 8.0f, 14.0f, 14.0f)];
        [self.loadingImageView setImage:[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        self.loadingImageView.image = [self.loadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];

        [rightView addSubview:self.loadingImageView];
        self.searchBarView.searchTextField.rightView = rightView;
        
        //Default Label
        UIFont *infoLabelBodyFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelBody];
        UIColor *infoLabelBodyColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelBody];
        UIFont *infoLabelBodyBoldFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelBodyBold];
        
        _defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.searchBarView.frame) + 23.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 40.0f)];
        self.backgroundColor = [UIColor clearColor];
        self.defaultLabel.text = NSLocalizedStringFromTableInBundle(@"Usernames are not case sensitive, but make sure you input the exact characters", nil, [TAPUtil currentBundle], @"");
        self.defaultLabel.textColor = infoLabelBodyColor;
        self.defaultLabel.font = infoLabelBodyFont;
        self.defaultLabel.textAlignment = NSTextAlignmentCenter;
        self.defaultLabel.numberOfLines = 0;

        NSMutableAttributedString *defaultLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:self.defaultLabel.text];
        
        [defaultLabelAttributedString addAttribute:NSKernAttributeName
                                             value:@-0.2f
                                             range:NSMakeRange(0, [self.defaultLabel.text length])];
    
        [defaultLabelAttributedString addAttribute:NSFontAttributeName
                                               value:infoLabelBodyBoldFont
                                               range:[self.defaultLabel.text rangeOfString:NSLocalizedStringFromTableInBundle(@"not case sensitive", nil, [TAPUtil currentBundle], @"")]];
        
        [defaultLabelAttributedString addAttribute:NSFontAttributeName
                                             value:infoLabelBodyBoldFont
                                             range:[self.defaultLabel.text rangeOfString:NSLocalizedStringFromTableInBundle(@"exact characters", nil, [TAPUtil currentBundle], @"")]];

        self.defaultLabel.attributedText = defaultLabelAttributedString;
        
        CGSize defaultLabelSize = [self.defaultLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.defaultLabel.frame), CGFLOAT_MAX)];
        self.defaultLabel.frame = CGRectMake(CGRectGetMinX(self.defaultLabel.frame), CGRectGetMinY(self.defaultLabel.frame), CGRectGetWidth(self.defaultLabel.frame), ceil(defaultLabelSize.height));
        
        [self addSubview:self.defaultLabel];
        
        //Search Expert View
        _searchExpertView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.searchBarView.frame) + 16.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 244.0f)];
        self.searchExpertView.clipsToBounds = YES;
        self.searchExpertView.layer.cornerRadius = 8.0f;
        self.searchExpertView.backgroundColor = [UIColor whiteColor];
        self.searchExpertView.layer.shadowColor = [TAPUtil getColor:TAP_COLOR_GREY_DC].CGColor;
        self.searchExpertView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.searchExpertView.layer.shadowOpacity = 0.4f;
        self.searchExpertView.layer.shadowRadius = 4.0f;
        self.searchExpertView.alpha = 0.0f;
        [self addSubview:self.searchExpertView];
        
        _coverImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.searchExpertView.frame), 93.0f)];
        UIBezierPath *maskPath = [UIBezierPath
                                  bezierPathWithRoundedRect:self.coverImageView.frame
                                  byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                  cornerRadii:CGSizeMake(8.0f, 8.0f)];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        
        self.coverImageView.layer.mask = maskLayer;
        
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.searchExpertView addSubview:self.coverImageView];
        
        _expertInitialView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.searchExpertView.frame) - 52.0f) / 2.0f, 66.0f, 52.0f, 52.0f)];
        self.expertInitialView.alpha = 0.0f;
        self.expertInitialView.layer.cornerRadius = CGRectGetHeight(self.expertInitialView.frame) / 2.0f;
        self.expertInitialView.clipsToBounds = YES;
        [self.searchExpertView addSubview:self.expertInitialView];
        
        UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarMediumLabel];
        UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarMediumLabel];
        _expertInitialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.expertInitialView.frame), CGRectGetHeight(self.expertInitialView.frame))];
        self.expertInitialLabel.font = initialNameLabelFont;
        self.expertInitialLabel.textColor = initialNameLabelColor;
        self.expertInitialLabel.textAlignment = NSTextAlignmentCenter;
        [self.expertInitialView addSubview:self.expertInitialLabel];
        
        _expertImageView = [[TAPImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.searchExpertView.frame) - 52.0f) / 2.0f, 66.0f, 52.0f, 52.0f)];
        self.expertImageView.clipsToBounds = YES;
        self.expertImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.expertImageView.layer.cornerRadius = CGRectGetHeight(self.expertImageView.frame) / 2.0f;
        self.expertImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.expertImageView.layer.borderWidth = 4.0f;
        [self.searchExpertView addSubview:self.expertImageView];
        
        _expertVerifiedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.expertImageView.frame) - 22.0f, CGRectGetMaxY(self.expertImageView.frame) - 22.0f, 22.0f, 22.0f)];
        self.expertVerifiedImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.searchExpertView addSubview:self.expertVerifiedImageView];
        
        UIFont *nameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchNewContactResultName];
        UIColor *nameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchNewContactResultName];
        _expertNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, CGRectGetMaxY(self.expertImageView.frame) + 9.0f, CGRectGetWidth(self.searchExpertView.frame) - 16.0f, 20.0f)];
        self.expertNameLabel.font = nameLabelFont;
        self.expertNameLabel.textAlignment = NSTextAlignmentCenter;
        self.expertNameLabel.textColor = nameLabelColor;
        [self.searchExpertView addSubview:self.expertNameLabel];
        
        UIFont *usernameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchNewContactResultUsername];
        UIColor *usernameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchNewContactResultUsername];
        _expertCategoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.expertNameLabel.frame), CGRectGetMaxY(self.expertNameLabel.frame) + 3.0f, CGRectGetWidth(self.expertNameLabel.frame), 16.0f)];
        self.expertCategoryLabel.font = usernameLabelFont;
        self.expertCategoryLabel.textAlignment = NSTextAlignmentCenter;
        self.expertCategoryLabel.textColor = usernameLabelColor;
        [self.searchExpertView addSubview:self.expertCategoryLabel];
        
        _addExpertToContactButtonView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.expertNameLabel.frame), CGRectGetMaxY(self.expertCategoryLabel.frame) + 26.0f, CGRectGetWidth(self.expertNameLabel.frame), 44.0f)];
        self.addExpertToContactButtonView.alpha = 0.0f;
        self.addExpertToContactButtonView.layer.borderWidth = 1.0f;
        self.addExpertToContactButtonView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBorder].CGColor;
        self.addExpertToContactButtonView.layer.cornerRadius = 6.0f;
        
        CAGradientLayer *addExpertToContactButtonViewGradient = [CAGradientLayer layer];
        addExpertToContactButtonViewGradient.frame = self.addExpertToContactButtonView.bounds;
        addExpertToContactButtonViewGradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientDark].CGColor, nil];
        
        addExpertToContactButtonViewGradient.startPoint = CGPointMake(0.0f, 0.0f);
        addExpertToContactButtonViewGradient.endPoint = CGPointMake(0.0f, 1.0f);
        addExpertToContactButtonViewGradient.cornerRadius = 6.0f;
        [self.addExpertToContactButtonView.layer insertSublayer:addExpertToContactButtonViewGradient atIndex:0];
        
        [self.searchExpertView addSubview:self.addExpertToContactButtonView];
        
        UIFont *buttonLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontButtonLabel];
        UIColor *buttonLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorButtonLabel];
        _addExpertToContactLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.addExpertToContactButtonView.frame), CGRectGetHeight(self.addExpertToContactButtonView.frame))];
        self.addExpertToContactLabel.text = NSLocalizedStringFromTableInBundle(@"Add to Contacts", nil, [TAPUtil currentBundle], @"");
        self.addExpertToContactLabel.font = buttonLabelFont;
        self.addExpertToContactLabel.textColor = buttonLabelColor;
        self.addExpertToContactLabel.textAlignment = NSTextAlignmentCenter;
        [self.addExpertToContactButtonView addSubview:self.addExpertToContactLabel];
        
        _addExpertToContactButton = [[UIButton alloc] initWithFrame:self.addExpertToContactButtonView.frame];
        self.addExpertToContactButtonView.alpha = 0.0f;
        self.addExpertToContactButtonView.userInteractionEnabled = NO;
        [self.searchExpertView addSubview:self.addExpertToContactButton];
        
        _expertChatNowButtonView = [[UIView alloc] initWithFrame:self.addExpertToContactButtonView.frame];
        self.expertChatNowButtonView.alpha = 0.0f;
        self.expertChatNowButtonView.layer.borderWidth = 1.0f;
        self.expertChatNowButtonView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBorder].CGColor;
        self.expertChatNowButtonView.layer.cornerRadius = 6.0f;
        
        CAGradientLayer *expertChatNowGradient = [CAGradientLayer layer];
        expertChatNowGradient.frame = self.expertChatNowButtonView.bounds;
        expertChatNowGradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientDark].CGColor, nil];
        expertChatNowGradient.startPoint = CGPointMake(0.0f, 0.0f);
        expertChatNowGradient.endPoint = CGPointMake(0.0f, 1.0f);
        expertChatNowGradient.cornerRadius = 6.0f;
        [self.expertChatNowButtonView.layer insertSublayer:expertChatNowGradient atIndex:0];
        [self.searchExpertView addSubview:self.expertChatNowButtonView];
        
        _expertChatNowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.addExpertToContactButtonView.frame), CGRectGetHeight(self.addExpertToContactButtonView.frame))];
        self.expertChatNowLabel.text = NSLocalizedStringFromTableInBundle(@"Chat Now", nil, [TAPUtil currentBundle], @"");
        self.expertChatNowLabel.font = buttonLabelFont;
        self.expertChatNowLabel.textColor = buttonLabelColor;
        self.expertChatNowLabel.textAlignment = NSTextAlignmentCenter;
        
        CGSize expertChatNowLabelSize = [self.expertChatNowLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.expertChatNowLabel.frame))];
        // 16.0f is the chat image logo and 8.0f is the gap between text and image
        CGFloat expertChatNowLabelMinX = (CGRectGetWidth(self.expertChatNowButtonView.frame) - expertChatNowLabelSize.width - 8.0f - 16.0f) / 2.0f;
        self.expertChatNowLabel.frame = CGRectMake(expertChatNowLabelMinX, CGRectGetMinY(self.expertChatNowLabel.frame), expertChatNowLabelSize.width, CGRectGetHeight(self.expertChatNowLabel.frame));
        [self.expertChatNowButtonView addSubview:self.expertChatNowLabel];
        
        _expertChatNowLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.expertChatNowLabel.frame) + 8.0f, ((CGRectGetHeight(self.addExpertToContactButtonView.frame) - 16.0f) / 2.0f) + 2.0f, 16.0f, 16.0f)];
        UIImage *expertChatNowLogoImage = [UIImage imageNamed:@"TAPIconChatNow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        expertChatNowLogoImage = [expertChatNowLogoImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIcon]];
        self.expertChatNowLogoImageView.image = expertChatNowLogoImage;
        self.expertChatNowLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.expertChatNowButtonView addSubview:self.expertChatNowLogoImageView];
        
        _expertChatNowButton = [[UIButton alloc] initWithFrame:self.expertChatNowButtonView.frame];
        self.expertChatNowButton.backgroundColor = [UIColor clearColor];
        self.expertChatNowButton.alpha = 0.0f;
        self.expertChatNowButton.userInteractionEnabled = NO;
        [self.searchExpertView addSubview:self.expertChatNowButton];
        
        _searchSelfExpertView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.expertNameLabel.frame), CGRectGetMaxY(self.expertCategoryLabel.frame) + 26.0f, CGRectGetWidth(self.expertNameLabel.frame), 44.0f)];
        self.searchSelfExpertView.alpha = 0.0f;
        [self.searchExpertView addSubview:self.searchSelfExpertView];
        
        UIFont *clickableLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableLabel];
        UIColor *clickableLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableLabel];
        _searchSelfExpertLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.searchSelfExpertView.frame), CGRectGetHeight(self.searchSelfExpertView.frame))];
        self.searchSelfExpertLabel.text = NSLocalizedStringFromTableInBundle(@"This is you", nil, [TAPUtil currentBundle], @"");
        self.searchSelfExpertLabel.font = clickableLabelFont;
        self.searchSelfExpertLabel.textColor = clickableLabelColor;
        self.searchSelfExpertLabel.textAlignment = NSTextAlignmentCenter;
        [self.searchSelfExpertView addSubview:self.searchSelfExpertLabel];
        
        //Search User View
        _searchUserShadowView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.searchExpertView.frame), CGRectGetMinY(self.searchExpertView.frame) + 16.0f, CGRectGetWidth(self.searchExpertView.frame), 209.0f)];
        self.searchUserShadowView.backgroundColor = [UIColor whiteColor];
        self.searchUserShadowView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        self.searchUserShadowView.layer.shadowOpacity = 1.0f;
        self.searchUserShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.searchUserShadowView.layer.shadowOpacity = 0.2f;
        self.searchUserShadowView.layer.shadowRadius = 2.0f;
        self.searchUserShadowView.layer.masksToBounds = NO;
        self.searchUserShadowView.alpha = 0.0f;
        self.searchUserShadowView.layer.cornerRadius = 8.0f;
        [self addSubview:self.searchUserShadowView];
        
        _searchUserView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.searchExpertView.frame), CGRectGetMinY(self.searchExpertView.frame) + 16.0f, CGRectGetWidth(self.searchExpertView.frame), 209.0f)];
        self.searchUserView.clipsToBounds = YES;
        self.searchUserView.layer.cornerRadius = 8.0f;
        self.searchUserView.backgroundColor = [UIColor whiteColor];
        self.searchUserView.layer.shadowColor = [TAPUtil getColor:TAP_COLOR_GREY_DC].CGColor;
        self.searchUserView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.searchUserView.layer.shadowOpacity = 0.4f;
        self.searchUserView.layer.shadowRadius = 4.0f;
        self.searchUserView.alpha = 0.0f;
        [self addSubview:self.searchUserView];
        
        _userInitialView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.searchUserView.frame) - 64.0f) / 2.0f, 16.0f, 64.0f, 64.0f)];
        self.userInitialView.alpha = 0.0f;
        self.userInitialView.layer.cornerRadius = CGRectGetHeight(self.userInitialView.frame) / 2.0f;
        self.userInitialView.clipsToBounds = YES;
        [self.searchUserView addSubview:self.userInitialView];
        
        _userInitialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.userInitialView.frame), CGRectGetHeight(self.userInitialView.frame))];
        self.userInitialLabel.font = initialNameLabelFont;
        self.userInitialLabel.textColor = initialNameLabelColor;
        self.userInitialLabel.textAlignment = NSTextAlignmentCenter;
        [self.userInitialView addSubview:self.userInitialLabel];

        _userImageView = [[TAPImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.searchUserView.frame) - 64.0f) / 2.0f, 16.0f, 64.0f, 64.0f)];
        self.userImageView.clipsToBounds = YES;
        self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.userImageView.layer.cornerRadius = CGRectGetHeight(self.userImageView.frame) / 2.0f;
        [self.searchUserView addSubview:self.userImageView];
        
        _userFullNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, CGRectGetMaxY(self.userImageView.frame) + 8.0f, CGRectGetWidth(self.searchUserView.frame) - 16.0f, 25.0f)];
        self.userFullNameLabel.font = nameLabelFont;
        self.userFullNameLabel.textAlignment = NSTextAlignmentCenter;
        self.userFullNameLabel.textColor = nameLabelColor;
        [self.searchUserView addSubview:self.userFullNameLabel];
        
        _userUsernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.userFullNameLabel.frame), CGRectGetMaxY(self.userFullNameLabel.frame), CGRectGetWidth(self.userFullNameLabel.frame), 20.0f)];
        self.userUsernameLabel.font = usernameLabelFont;
        self.userUsernameLabel.textAlignment = NSTextAlignmentCenter;
        self.userUsernameLabel.textColor = usernameLabelColor;
        [self.searchUserView addSubview:self.userUsernameLabel];
        
        _addUserToContactButtonView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.userUsernameLabel.frame) + 16.0f, CGRectGetWidth(self.userFullNameLabel.frame) - 16.0f, 44.0f)];
        self.addUserToContactButtonView.alpha = 0.0f;
        self.addUserToContactButtonView.layer.borderWidth = 1.0f;
        self.addUserToContactButtonView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBorder].CGColor;
        self.addUserToContactButtonView.layer.cornerRadius = 6.0f;
        
        CAGradientLayer *addUserToContactButtonViewGradient = [CAGradientLayer layer];
        addUserToContactButtonViewGradient.frame = self.addUserToContactButtonView.bounds;
        addUserToContactButtonViewGradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientDark].CGColor, nil];
        addUserToContactButtonViewGradient.startPoint = CGPointMake(0.0f, 0.0f);
        addUserToContactButtonViewGradient.endPoint = CGPointMake(0.0f, 1.0f);
        addUserToContactButtonViewGradient.cornerRadius = 6.0f;
        [self.addUserToContactButtonView.layer insertSublayer:addUserToContactButtonViewGradient atIndex:0];
        
        [self.searchUserView addSubview:self.addUserToContactButtonView];
        
        _addUserToContactLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.addUserToContactButtonView.frame), CGRectGetHeight(self.addUserToContactButtonView.frame))];
        self.addUserToContactLabel.text = NSLocalizedStringFromTableInBundle(@"Add to Contacts", nil, [TAPUtil currentBundle], @"");
        self.addUserToContactLabel.font = buttonLabelFont;
        self.addUserToContactLabel.textColor = buttonLabelColor;
        self.addUserToContactLabel.textAlignment = NSTextAlignmentCenter;
        [self.addUserToContactButtonView addSubview:self.addUserToContactLabel];
        
        _addUserToContactButton = [[UIButton alloc] initWithFrame:self.addUserToContactButtonView.frame];
        self.addUserToContactButtonView.backgroundColor = [UIColor clearColor];
        self.addUserToContactButton.alpha = 0.0f;
        self.addUserToContactButton.userInteractionEnabled = NO;
        [self.searchUserView addSubview:self.addUserToContactButton];
        
        _userChatNowButtonView = [[UIView alloc] initWithFrame:self.addUserToContactButtonView.frame];
        self.userChatNowButtonView.alpha = 0.0f;
        self.userChatNowButtonView.layer.borderWidth = 1.0f;
        self.userChatNowButtonView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBorder].CGColor;
        self.userChatNowButtonView.layer.cornerRadius = 6.0f;
        
        CAGradientLayer *userChatNowGradient = [CAGradientLayer layer];
        userChatNowGradient.frame = self.userChatNowButtonView.bounds;
        userChatNowGradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientDark].CGColor, nil];
        userChatNowGradient.startPoint = CGPointMake(0.0f, 0.0f);
        userChatNowGradient.endPoint = CGPointMake(0.0f, 1.0f);
        userChatNowGradient.cornerRadius = 6.0f;
        [self.userChatNowButtonView.layer insertSublayer:userChatNowGradient atIndex:0];
        [self.searchUserView addSubview:self.userChatNowButtonView];
        
        _userChatNowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.addUserToContactButtonView.frame), CGRectGetHeight(self.addUserToContactButtonView.frame))];
        self.userChatNowLabel.text = NSLocalizedStringFromTableInBundle(@"Chat Now", nil, [TAPUtil currentBundle], @"");
        self.userChatNowLabel.font = buttonLabelFont;
        self.userChatNowLabel.textColor = buttonLabelColor;
        self.userChatNowLabel.textAlignment = NSTextAlignmentCenter;
        
        CGSize userChatNowLabelSize = [self.userChatNowLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.userChatNowLabel.frame))];
        // 16.0f is the chat image logo and 8.0f is the gap between text and image
        CGFloat userChatNowLabelMinX = (CGRectGetWidth(self.userChatNowButtonView.frame) - userChatNowLabelSize.width - 8.0f - 16.0f) / 2.0f;
        self.userChatNowLabel.frame = CGRectMake(userChatNowLabelMinX, CGRectGetMinY(self.userChatNowLabel.frame), userChatNowLabelSize.width, CGRectGetHeight(self.userChatNowLabel.frame));
        [self.userChatNowButtonView addSubview:self.userChatNowLabel];
        
        _userChatNowLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userChatNowLabel.frame) + 8.0f, ((CGRectGetHeight(self.addUserToContactButtonView.frame) - 16.0f) / 2.0f) + 2.0f, 16.0f, 16.0f)];
        UIImage *userChatNowLogoImage = [UIImage imageNamed:@"TAPIconChatNow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        userChatNowLogoImage = [userChatNowLogoImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIcon]];
        self.userChatNowLogoImageView.image = userChatNowLogoImage;
        self.userChatNowLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.userChatNowButtonView addSubview:self.userChatNowLogoImageView];
        
        _userChatNowButton = [[UIButton alloc] initWithFrame:self.userChatNowButtonView.frame];
        self.userChatNowButton.backgroundColor = [UIColor clearColor];
        self.userChatNowButton.alpha = 0.0f;
        self.userChatNowButton.userInteractionEnabled = NO;
        [self.searchUserView addSubview:self.userChatNowButton];
        
        _searchSelfUserView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.userFullNameLabel.frame), CGRectGetMaxY(self.userUsernameLabel.frame) + 16.0f, CGRectGetWidth(self.userFullNameLabel.frame), 44.0f)];
        self.searchSelfUserView.alpha = 0.0f;
        [self.searchUserView addSubview:self.searchSelfUserView];
        
        _searchSelfUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.searchSelfUserView.frame), CGRectGetHeight(self.searchSelfUserView.frame))];
        self.searchSelfUserLabel.text = NSLocalizedStringFromTableInBundle(@"This is you", nil, [TAPUtil currentBundle], @"");
        self.searchSelfUserLabel.font = clickableLabelFont;
        self.searchSelfUserLabel.textColor = clickableLabelColor;
        self.searchSelfUserLabel.textAlignment = NSTextAlignmentCenter;
        [self.searchSelfUserView addSubview:self.searchSelfUserLabel];
        
        _emptyStateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarView.frame) + 8.0f, CGRectGetWidth(frame), CGRectGetHeight(frame) - CGRectGetMaxY(self.searchBarView.frame))];
        self.emptyStateView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.emptyStateView.alpha = 0.0f;
        [self addSubview:self.emptyStateView];
        
        //DV Note
        //Temporary remove asset to change not from moselo style
//        _emptyStateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.emptyStateView.frame) - 170.0f) / 2.0f, 35.0f, 170.0f, 170.0f)];
//        self.emptyStateImageView.image = [UIImage imageNamed:@"TAPIconEmptySearch" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
//        [self.emptyStateView addSubview:self.emptyStateImageView];
        
//        _emptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.emptyStateImageView.frame) + 10.0f, CGRectGetWidth(self.emptyStateView.frame) - 16.0f - 16.0f, 40.0f)];
//        self.emptyStateLabel.text = NSLocalizedStringFromTableInBundle(@"Oops…\nCould not find any results", nil, [TAPUtil currentBundle], @"");
//        self.emptyStateLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:15.0f];
//        NSRange range = [self.emptyStateLabel.text rangeOfString:@"Oops…"];
//        //set attribute
//        NSMutableAttributedString *emptyAttribuetdString = [[NSMutableAttributedString alloc] initWithString:self.emptyStateLabel.text];
//        [emptyAttribuetdString addAttribute:NSFontAttributeName
//                                      value:[UIFont fontWithName:TAP_FONT_NAME_BOLD size:15.0f]
//                                      range:range];
//        self.emptyStateLabel.attributedText = emptyAttribuetdString;
//        self.emptyStateLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
//        self.emptyStateLabel.numberOfLines = 2;
//        self.emptyStateLabel.textAlignment = NSTextAlignmentCenter;
//        [self.emptyStateView addSubview:self.emptyStateLabel];
        //END DV Note

        
        UIFont *infoLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelTitle];
        UIColor *infoLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelTitle];
        UIFont *bodyLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelBody];
        
        _emptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.emptyStateImageView.frame) + 10.0f, CGRectGetWidth(self.emptyStateView.frame) - 16.0f - 16.0f, 60.0f)];
        self.emptyStateLabel.text = NSLocalizedStringFromTableInBundle(@"Oops…\nCould not find any results", nil, [TAPUtil currentBundle], @"");
        self.emptyStateLabel.font = bodyLabelFont;
        NSRange range = [self.emptyStateLabel.text rangeOfString:@"Oops…"];
        //set attribute
        NSMutableAttributedString *emptyAttribuetdString = [[NSMutableAttributedString alloc] initWithString:self.emptyStateLabel.text];
        [emptyAttribuetdString addAttribute:NSFontAttributeName
                                      value:infoLabelFont
                                      range:range];
        self.emptyStateLabel.attributedText = emptyAttribuetdString;
        self.emptyStateLabel.textColor = infoLabelColor;
        self.emptyStateLabel.numberOfLines = 2;
        self.emptyStateLabel.textAlignment = NSTextAlignmentCenter;
        [self.emptyStateView addSubview:self.emptyStateLabel];
        
        _noInternetView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarView.frame) + 8.0f, CGRectGetWidth(self.frame), 68.0f)];
        self.noInternetView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchConnectionLostBackgroundColor];
        self.noInternetView.alpha = 0.0f;
        [self addSubview:self.noInternetView];
        
        _noInternetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18.0f, 12.0f, 44.0f, 44.0f)];
        self.noInternetImageView.image = [UIImage imageNamed:@"TAPIconConnectionLost" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.noInternetImageView.image = [self.noInternetImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconSearchConnectionLost]];
        [self.noInternetView addSubview:self.noInternetImageView];
        
        UIFont *noInternetTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchConnectionLostTitle];
        UIColor *noInternetTitleColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchConnectionLostTitle];
        UIFont *noInternetDescriptionFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchConnectionLostDescription];
        UIColor *noInternetDescriptionColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchConnectionLostDescription];

        _noInternetTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.noInternetImageView.frame) + 10.0f, 10.0f, CGRectGetWidth(self.frame) - 16.0f - (CGRectGetMaxX(self.noInternetImageView.frame) + 8.0f), 24.0f)];
        self.noInternetTitleLabel.text = @"Internet Connection Lost";
        self.noInternetTitleLabel.textColor = noInternetTitleColor;
        self.noInternetTitleLabel.font = noInternetTitleFont;
        [self.noInternetView addSubview:self.noInternetTitleLabel];
        
        _noInternetDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.noInternetTitleLabel.frame), CGRectGetMaxY(self.noInternetTitleLabel.frame), CGRectGetWidth(self.noInternetTitleLabel.frame), 24.0f)];
        self.noInternetDescriptionLabel.text = @"Please check your connection";
        self.noInternetDescriptionLabel.textColor = noInternetDescriptionColor;
        self.noInternetDescriptionLabel.font = noInternetDescriptionFont;
        [self.noInternetView addSubview:self.noInternetDescriptionLabel];
        
        [self setSearchViewLayoutWithType:LayoutTypeDefault];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)isShowDefaultLabel:(BOOL)isShow {
    if (isShow) {
        [UIView animateWithDuration:0.2f animations:^{
            self.defaultLabel.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.defaultLabel.alpha = 0.0f;
        }];
    }
}

- (void)isShowExpertVerifiedLogo:(BOOL)isShow {
    if (isShow) {
        self.expertVerifiedImageView.alpha = 1.0f;
    }
    else {
        self.expertVerifiedImageView.alpha = 0.0f;
    }
}

- (void)setSearchViewLayoutWithType:(LayoutType)type {
    if (type == LayoutTypeDefault) {
        //Default View
        [UIView animateWithDuration:0.2f animations:^{
            self.defaultLabel.alpha = 1.0f;
            self.searchExpertView.alpha = 0.0f;
            self.searchUserView.alpha = 0.0f;
            self.searchUserShadowView.alpha = 0.0f;
            self.searchSelfUserView.alpha = 0.0f;
            self.searchSelfExpertView.alpha = 0.0f;
        }];
    }
    else if (type == LayoutTypeUser) {
        //User View
        [UIView animateWithDuration:0.2f animations:^{
            self.defaultLabel.alpha = 0.0f;
            self.searchExpertView.alpha = 0.0f;
            self.searchUserView.alpha = 1.0f;
            self.searchUserShadowView.alpha = 1.0f;
            self.searchSelfUserView.alpha = 0.0f;
            self.searchSelfExpertView.alpha = 0.0f;
        }];
    }
    else if (type == LayoutTypeExpert) {
        //Expert View
        [UIView animateWithDuration:0.2f animations:^{
            self.defaultLabel.alpha = 0.0f;
            self.searchUserView.alpha = 0.0f;
            self.searchUserShadowView.alpha = 0.0f;
            self.searchExpertView.alpha = 1.0f;
            self.searchSelfUserView.alpha = 0.0f;
            self.searchSelfExpertView.alpha = 0.0f;
        }];
    }
}

- (void)setSearchExpertButtonWithType:(ButtonType)type {
    if (type == ButtonTypeAdd) {
        //Add to Contacts Button
        [UIView animateWithDuration:0.2f animations:^{
            self.expertChatNowButtonView.alpha = 0.0f;
            self.expertChatNowButton.alpha = 0.0f;
            self.expertChatNowButton.userInteractionEnabled = NO;
            
            self.addExpertToContactButtonView.alpha = 1.0f;
            self.addExpertToContactButton.alpha = 1.0f;
            self.addExpertToContactButton.userInteractionEnabled = YES;
        }];
    }
    else if (type == ButtonTypeChat) {
        //Chat Now Button
        [UIView animateWithDuration:0.2f animations:^{
            self.expertChatNowButtonView.alpha = 1.0f;
            self.expertChatNowButton.alpha = 1.0f;
            self.expertChatNowButton.userInteractionEnabled = YES;
            
            self.addExpertToContactButtonView.alpha = 0.0f;
            self.addExpertToContactButton.alpha = 0.0f;
            self.addExpertToContactButton.userInteractionEnabled = NO;
        }];
    }
}

- (void)setSearchUserButtonWithType:(ButtonType)type {
    if (type == ButtonTypeAdd) {
        //Add to Contacts Button
        [UIView animateWithDuration:0.2f animations:^{
            self.userChatNowButtonView.alpha = 0.0f;
            self.userChatNowButton.alpha = 0.0f;
            self.userChatNowButton.userInteractionEnabled = NO;
            
            self.addUserToContactButtonView.alpha = 1.0f;
            self.addUserToContactButton.alpha = 1.0f;
            self.addUserToContactButton.userInteractionEnabled = YES;
        }];
    }
    else if (type == ButtonTypeChat) {
        //Chat Now Button
        [UIView animateWithDuration:0.2f animations:^{
            self.userChatNowButtonView.alpha = 1.0f;
            self.userChatNowButton.alpha = 1.0f;
            self.userChatNowButton.userInteractionEnabled = YES;
            
            self.addUserToContactButtonView.alpha = 0.0f;
            self.addUserToContactButton.alpha = 0.0f;
            self.addUserToContactButton.userInteractionEnabled = NO;
        }];
    }
}

- (void)isShowEmptyState:(BOOL)isShow {
    if (isShow) {
        [UIView animateWithDuration:0.2f animations:^{
            self.emptyStateView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.emptyStateView.alpha = 0.0f;
        }];
    }
}

- (void)setContactWithUser:(TAPUserModel *)user {
    
    TAPUserRoleModel *userRole = user.userRole;
    
    NSString *userID = user.userID;
    
    NSString *fullName = user.fullname;
    fullName = [TAPUtil nullToEmptyString:fullName];
    
    NSString *username = user.username;
    username = [TAPUtil nullToEmptyString:username];
    
    NSString *userRoleCode = userRole.code;
    userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
    
    NSString *userRoleName = userRole.name;
    userRoleName = [TAPUtil nullToEmptyString:userRoleName];
    
    NSString *userRoleIcon = userRole.iconURL;
    userRoleIcon = [TAPUtil nullToEmptyString:userRoleIcon];
    
    TAPImageURLModel *imageURL = user.imageURL;
    NSString *imageURLString = imageURL.thumbnail;
    
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    NSString *activeUserID = currentUser.userID;
    

    if ([userRoleCode isEqualToString:@"expert"]) {
        self.expertNameLabel.text = fullName;
        
        if (imageURLString == nil || [imageURLString isEqualToString:@""]) {
            self.expertImageView.alpha = 0.0f;
            self.expertInitialView.alpha = 1.0f;
            self.expertInitialView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:fullName];
            self.expertInitialLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:fullName isGroup:NO];
        }
        else {
            self.expertImageView.alpha = 1.0f;
            self.expertInitialView.alpha = 0.0f;
            [self.expertImageView setImageWithURLString:imageURLString];
        }
        
        if ([userRoleIcon isEqualToString:@""]) {
            self.expertVerifiedImageView.alpha = 0.0f;
        }
        else {
            self.expertVerifiedImageView.alpha = 1.0f;
            [self.expertVerifiedImageView setImageURLString:userRoleIcon];
        }
        
        self.expertCategoryLabel.text = userRole.name; //DV Temp
        self.coverImageView.image = [UIImage imageNamed:@"TAPIconDefaultCover" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]; //DV Temp
        
        [self setSearchViewLayoutWithType:LayoutTypeExpert];
        
        if ([userID isEqualToString:activeUserID]) {
            [self showAsSelfSearchWithUserRole:userRoleCode];
        }
        else {
            [TAPDataManager getDatabaseContactByUserID:user.userID success:^(BOOL isContact, TAPUserModel *obtainedUser) {
                if (isContact) {
                    [self setSearchExpertButtonWithType:ButtonTypeChat];
                }
                else {
                    [self setSearchExpertButtonWithType:ButtonTypeAdd];
                }
            } failure:^(NSError *error) {
    #ifdef DEBUG
                NSLog(@"%@", error);
    #endif
            }];
        }
    }
    else {
        self.userFullNameLabel.text = fullName;
        self.userUsernameLabel.text = username;
        if (imageURLString == nil || [imageURLString isEqualToString:@""]) {
            self.userImageView.alpha = 0.0f;
            self.userInitialView.alpha = 1.0f;
            self.userInitialView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:fullName];
            self.userInitialLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:fullName isGroup:NO];
        }
        else {
            self.userImageView.alpha = 1.0f;
            self.userInitialView.alpha = 0.0f;
            [self.userImageView setImageWithURLString:imageURLString];
        }
        
        [self setSearchViewLayoutWithType:LayoutTypeUser];
        
        if ([userID isEqualToString:activeUserID]) {
            [self showAsSelfSearchWithUserRole:userRoleCode];
        }
        else {
            [TAPDataManager getDatabaseContactByUserID:user.userID success:^(BOOL isContact, TAPUserModel *obtainedUser) {
                if (isContact) {
                    [self setSearchUserButtonWithType:ButtonTypeChat];
                }
                else {
                    [self setSearchUserButtonWithType:ButtonTypeAdd];
                }
            } failure:^(NSError *error) {
    #ifdef DEBUG
                NSLog(@"%@", error);
    #endif
            }];
        }
    }
}

- (void)showLoading:(BOOL)isLoading {
    if (isLoading) {
        //ADD ANIMATION
        if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] == nil) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.cumulative = YES;
            animation.removedOnCompletion = NO;
            [self.loadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
        self.searchBarView.searchTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    else {
        self.searchBarView.searchTextField.rightViewMode = UITextFieldViewModeNever;
        //REMOVE ANIMATION
        if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
            [self.loadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
        }
    }
}

- (void)showAsSelfSearchWithUserRole:(NSString *)userRole {
    if ([userRole isEqualToString:@"expert"]) {
        self.addExpertToContactButtonView.alpha = 0.0f;
        self.expertChatNowButtonView.alpha = 0.0f;
        self.searchSelfExpertView.alpha = 1.0f;
    }
    else {
        self.addUserToContactButtonView.alpha = 0.0f;
        self.userChatNowButtonView.alpha = 0.0f;
        self.searchSelfUserView.alpha = 1.0f;
    }
}

- (void)showNoInternetView:(BOOL)isShowed {
    if (isShowed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.noInternetView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.noInternetView.alpha = 0.0f;
        }];
    }
}

- (void)searchBarCancelButtonDidTapped {
    [self.searchBarView handleCancelButtonTappedState];
    [UIView animateWithDuration:0.3f animations:^{
        CGRect searchBarViewFrame = self.searchBarView.frame;
        searchBarViewFrame.size.width = CGRectGetWidth(self.searchBarBackgroundView.frame) - 16.0f - 16.0f;
        self.searchBarView.frame = searchBarViewFrame;
        self.searchBarView.searchTextField.text = @"";
        [self.searchBarView.searchTextField endEditing:YES];
        
        CGRect searchBarCancelButtonFrame = self.searchBarCancelButton.frame;
        searchBarCancelButtonFrame.origin.x = CGRectGetMaxX(searchBarViewFrame) + 8.0f;
        searchBarCancelButtonFrame.size.width = 0.0f;
        self.searchBarCancelButton.frame = searchBarCancelButtonFrame;
    } completion:^(BOOL finished) {
        //completion
    }];
}

@end
