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

@property (strong, nonatomic) UIView *searchExpertView;
@property (strong, nonatomic) TAPImageView *coverImageView;
@property (strong, nonatomic) UIView *expertImageContainerView;
@property (strong, nonatomic) TAPImageView *expertImageView;
@property (strong, nonatomic) TAPImageView *expertVerifiedImageView;
@property (strong, nonatomic) UILabel *expertNameLabel;
@property (strong, nonatomic) UILabel *expertCategoryLabel;
@property (strong, nonatomic) UIView *addExpertToContactButtonView;
@property (strong, nonatomic) UILabel *addExpertToContactLabel;
@property (strong, nonatomic) UIView *expertChatNowButtonView;
@property (strong, nonatomic) UIImageView *expertChatNowLogoImageView;
@property (strong, nonatomic) UILabel *expertChatNowLabel;

@property (strong, nonatomic) UIView *searchUserView;
@property (strong, nonatomic) TAPImageView *userImageView;
@property (strong, nonatomic) UILabel *userFullNameLabel;
@property (strong, nonatomic) UIView *addUserToContactButtonView;
@property (strong, nonatomic) UILabel *addUserToContactLabel;
@property (strong, nonatomic) UIView *userChatNowButtonView;
@property (strong, nonatomic) UIImageView *userChatNowLogoImageView;
@property (strong, nonatomic) UILabel *userChatNowLabel;

@property (strong, nonatomic) UIView *emptyStateView;
@property (strong, nonatomic) UIImageView *emptyStateImageView;
@property (strong, nonatomic) UILabel *emptyStateLabel;

@property (strong, nonatomic) UIImageView *loadingImageView;

@property (strong, nonatomic) UIView *noInternetView;
@property (strong, nonatomic) UIImageView *noInternetImageView;
@property (strong, nonatomic) UILabel *noInternetTitleLabel;
@property (strong, nonatomic) UILabel *noInternetDescriptionLabel;

@end

@implementation TAPAddNewContactView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        
        _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 30.0f)];
        self.searchBarView.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.searchBarView.customPlaceHolderString = NSLocalizedString(@"Search by Username", @"");
        [self addSubview:self.searchBarView];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 30.0f)];
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 8.0f, 14.0f, 14.0f)];
        [self.loadingImageView setImage:[UIImage imageNamed:@"TAPIconLoadingSearching" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        [rightView addSubview:self.loadingImageView];
        self.searchBarView.searchTextField.rightView = rightView;
        
        //Default Label
        _defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.searchBarView.frame) + 23.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 40.0f)];
        self.backgroundColor = [UIColor clearColor];
        self.defaultLabel.text = NSLocalizedString(@"Usernames are case sensitive, so make sure you input correctly", @"");
        self.defaultLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.defaultLabel.font = [UIFont fontWithName:TAP_FONT_NAME_NORMAL size:15.0f];
        self.defaultLabel.textAlignment = NSTextAlignmentCenter;
        self.defaultLabel.numberOfLines = 0;

        NSMutableAttributedString *defaultLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:self.defaultLabel.text];
        
        [defaultLabelAttributedString addAttribute:NSKernAttributeName
                                             value:@-0.2f
                                             range:NSMakeRange(0, [self.defaultLabel.text length])];
        
        [defaultLabelAttributedString addAttribute:NSFontAttributeName
                                               value:[UIFont fontWithName:TAP_FONT_NAME_BOLD size:14.0f]
                                               range:[self.defaultLabel.text rangeOfString:NSLocalizedString(@"case sensitive", @"")]];

        self.defaultLabel.attributedText = defaultLabelAttributedString;
        
        CGSize defaultLabelSize = [self.defaultLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.defaultLabel.frame), CGFLOAT_MAX)];
        self.defaultLabel.frame = CGRectMake(CGRectGetMinX(self.defaultLabel.frame), CGRectGetMinY(self.defaultLabel.frame), CGRectGetWidth(self.defaultLabel.frame), ceil(defaultLabelSize.height));
        
        [self addSubview:self.defaultLabel];
        
        //Search Expert View
        _searchExpertView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.searchBarView.frame) + 12.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 244.0f)];
        self.searchExpertView.clipsToBounds = YES;
        self.searchExpertView.layer.cornerRadius = 8.0f;
        self.searchExpertView.backgroundColor = [UIColor whiteColor];
        self.searchExpertView.layer.shadowColor = [TAPUtil getColor:@"D9D9D9"].CGColor;
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
        
        _expertNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, CGRectGetMaxY(self.expertImageView.frame) + 9.0f, CGRectGetWidth(self.searchExpertView.frame) - 16.0f, 20.0f)];
        self.expertNameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:14.0f];
        self.expertNameLabel.textAlignment = NSTextAlignmentCenter;
        self.expertNameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        [self.searchExpertView addSubview:self.expertNameLabel];
        
        _expertCategoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.expertNameLabel.frame), CGRectGetMaxY(self.expertNameLabel.frame) + 3.0f, CGRectGetWidth(self.expertNameLabel.frame), 16.0f)];
        self.expertCategoryLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
        self.expertCategoryLabel.textAlignment = NSTextAlignmentCenter;
        self.expertCategoryLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_9B];
        [self.searchExpertView addSubview:self.expertCategoryLabel];
        
        _addExpertToContactButtonView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.expertNameLabel.frame), CGRectGetMaxY(self.expertCategoryLabel.frame) + 26.0f, CGRectGetWidth(self.expertNameLabel.frame), 44.0f)];
        self.addExpertToContactButtonView.alpha = 0.0f;
        self.addExpertToContactButtonView.layer.borderWidth = 1.0f;
        self.addExpertToContactButtonView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93].CGColor;
        self.addExpertToContactButtonView.layer.cornerRadius = 6.0f;
        
        CAGradientLayer *addExpertToContactButtonViewGradient = [CAGradientLayer layer];
        addExpertToContactButtonViewGradient.frame = self.addExpertToContactButtonView.bounds;
        addExpertToContactButtonViewGradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor, nil];
        addExpertToContactButtonViewGradient.startPoint = CGPointMake(0.0f, 0.0f);
        addExpertToContactButtonViewGradient.endPoint = CGPointMake(0.0f, 1.0f);
        addExpertToContactButtonViewGradient.cornerRadius = 6.0f;
        [self.addExpertToContactButtonView.layer insertSublayer:addExpertToContactButtonViewGradient atIndex:0];
        
        [self.searchExpertView addSubview:self.addExpertToContactButtonView];
        
        _addExpertToContactLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.addExpertToContactButtonView.frame), CGRectGetHeight(self.addExpertToContactButtonView.frame))];
        self.addExpertToContactLabel.text = NSLocalizedString(@"Add to Contacts", @"");
        self.addExpertToContactLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:17.0f];
        self.addExpertToContactLabel.textColor = [UIColor whiteColor];
        self.addExpertToContactLabel.textAlignment = NSTextAlignmentCenter;
        [self.addExpertToContactButtonView addSubview:self.addExpertToContactLabel];
        
        _addExpertToContactButton = [[UIButton alloc] initWithFrame:self.addExpertToContactButtonView.frame];
        self.addExpertToContactButtonView.alpha = 0.0f;
        self.addExpertToContactButtonView.userInteractionEnabled = NO;
        [self.searchExpertView addSubview:self.addExpertToContactButton];
        
        _expertChatNowButtonView = [[UIView alloc] initWithFrame:self.addExpertToContactButtonView.frame];
        self.expertChatNowButtonView.alpha = 0.0f;
        self.expertChatNowButtonView.layer.borderWidth = 1.0f;
        self.expertChatNowButtonView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93].CGColor;
        self.expertChatNowButtonView.layer.cornerRadius = 6.0f;
        
        CAGradientLayer *expertChatNowGradient = [CAGradientLayer layer];
        expertChatNowGradient.frame = self.expertChatNowButtonView.bounds;
        expertChatNowGradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor, nil];
        expertChatNowGradient.startPoint = CGPointMake(0.0f, 0.0f);
        expertChatNowGradient.endPoint = CGPointMake(0.0f, 1.0f);
        expertChatNowGradient.cornerRadius = 6.0f;
        [self.expertChatNowButtonView.layer insertSublayer:expertChatNowGradient atIndex:0];
        [self.searchExpertView addSubview:self.expertChatNowButtonView];
        
        _expertChatNowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.addExpertToContactButtonView.frame), CGRectGetHeight(self.addExpertToContactButtonView.frame))];
        self.expertChatNowLabel.text = NSLocalizedString(@"Chat Now", @"");
        self.expertChatNowLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:17.0f];
        self.expertChatNowLabel.textColor = [UIColor whiteColor];
        self.expertChatNowLabel.textAlignment = NSTextAlignmentCenter;
        
        CGSize expertChatNowLabelSize = [self.expertChatNowLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.expertChatNowLabel.frame))];
        // 16.0f is the chat image logo and 8.0f is the gap between text and image
        CGFloat expertChatNowLabelMinX = (CGRectGetWidth(self.expertChatNowButtonView.frame) - expertChatNowLabelSize.width - 8.0f - 16.0f) / 2.0f;
        self.expertChatNowLabel.frame = CGRectMake(expertChatNowLabelMinX, CGRectGetMinY(self.expertChatNowLabel.frame), expertChatNowLabelSize.width, CGRectGetHeight(self.expertChatNowLabel.frame));
        [self.expertChatNowButtonView addSubview:self.expertChatNowLabel];
        
        _expertChatNowLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.expertChatNowLabel.frame) + 8.0f, ((CGRectGetHeight(self.addExpertToContactButtonView.frame) - 16.0f) / 2.0f) + 2.0f, 16.0f, 16.0f)];
        self.expertChatNowLogoImageView.image = [UIImage imageNamed:@"TAPIconChatNow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.expertChatNowLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.expertChatNowButtonView addSubview:self.expertChatNowLogoImageView];
        
        _expertChatNowButton = [[UIButton alloc] initWithFrame:self.expertChatNowButtonView.frame];
        self.expertChatNowButton.backgroundColor = [UIColor clearColor];
        self.expertChatNowButton.alpha = 0.0f;
        self.expertChatNowButton.userInteractionEnabled = NO;
        [self.searchExpertView addSubview:self.expertChatNowButton];
        
        //Search User View
        _searchUserView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.searchExpertView.frame), CGRectGetMinY(self.searchExpertView.frame), CGRectGetWidth(self.searchExpertView.frame), 160.0f)];
        self.searchUserView.clipsToBounds = YES;
        self.searchUserView.layer.cornerRadius = 8.0f;
        self.searchUserView.backgroundColor = [UIColor whiteColor];
        self.searchUserView.layer.shadowColor = [TAPUtil getColor:@"D9D9D9"].CGColor;
        self.searchUserView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.searchUserView.layer.shadowOpacity = 0.4f;
        self.searchUserView.layer.shadowRadius = 4.0f;
        self.searchUserView.alpha = 0.0f;
        [self addSubview:self.searchUserView];

        _userImageView = [[TAPImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.searchUserView.frame) - 52.0f) / 2.0f, 8.0f, 52.0f, 52.0f)];
        self.userImageView.clipsToBounds = YES;
        self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.userImageView.layer.cornerRadius = CGRectGetHeight(self.userImageView.frame) / 2.0f;
        [self.searchUserView addSubview:self.userImageView];
        
        _userFullNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, CGRectGetMaxY(self.userImageView.frame) + 9.0f, CGRectGetWidth(self.searchUserView.frame) - 16.0f, 20.0f)];
        self.userFullNameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:14.0f];
        self.userFullNameLabel.textAlignment = NSTextAlignmentCenter;
        self.userFullNameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        [self.searchUserView addSubview:self.userFullNameLabel];
        
        _addUserToContactButtonView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.userFullNameLabel.frame), CGRectGetMaxY(self.userFullNameLabel.frame) + 19.0f, CGRectGetWidth(self.userFullNameLabel.frame), 44.0f)];
        self.addUserToContactButtonView.alpha = 0.0f;
        self.addUserToContactButtonView.layer.borderWidth = 1.0f;
        self.addUserToContactButtonView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93].CGColor;
        self.addUserToContactButtonView.layer.cornerRadius = 6.0f;
        
        CAGradientLayer *addUserToContactButtonViewGradient = [CAGradientLayer layer];
        addUserToContactButtonViewGradient.frame = self.addUserToContactButtonView.bounds;
        addUserToContactButtonViewGradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor, nil];
        addUserToContactButtonViewGradient.startPoint = CGPointMake(0.0f, 0.0f);
        addUserToContactButtonViewGradient.endPoint = CGPointMake(0.0f, 1.0f);
        addUserToContactButtonViewGradient.cornerRadius = 6.0f;
        [self.addUserToContactButtonView.layer insertSublayer:addUserToContactButtonViewGradient atIndex:0];
        
        [self.searchUserView addSubview:self.addUserToContactButtonView];
        
        _addUserToContactLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.addUserToContactButtonView.frame), CGRectGetHeight(self.addUserToContactButtonView.frame))];
        self.addUserToContactLabel.text = NSLocalizedString(@"Add to Contacts", @"");
        self.addUserToContactLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:17.0f];
        self.addUserToContactLabel.textColor = [UIColor whiteColor];
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
        self.userChatNowButtonView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93].CGColor;
        self.userChatNowButtonView.layer.cornerRadius = 6.0f;
        
        CAGradientLayer *userChatNowGradient = [CAGradientLayer layer];
        userChatNowGradient.frame = self.userChatNowButtonView.bounds;
        userChatNowGradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor, nil];
        userChatNowGradient.startPoint = CGPointMake(0.0f, 0.0f);
        userChatNowGradient.endPoint = CGPointMake(0.0f, 1.0f);
        userChatNowGradient.cornerRadius = 6.0f;
        [self.userChatNowButtonView.layer insertSublayer:userChatNowGradient atIndex:0];
        [self.searchUserView addSubview:self.userChatNowButtonView];
        
        _userChatNowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.addUserToContactButtonView.frame), CGRectGetHeight(self.addUserToContactButtonView.frame))];
        self.userChatNowLabel.text = NSLocalizedString(@"Chat Now", @"");
        self.userChatNowLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:17.0f];
        self.userChatNowLabel.textColor = [UIColor whiteColor];
        self.userChatNowLabel.textAlignment = NSTextAlignmentCenter;
        
        CGSize userChatNowLabelSize = [self.userChatNowLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.userChatNowLabel.frame))];
        // 16.0f is the chat image logo and 8.0f is the gap between text and image
        CGFloat userChatNowLabelMinX = (CGRectGetWidth(self.userChatNowButtonView.frame) - userChatNowLabelSize.width - 8.0f - 16.0f) / 2.0f;
        self.userChatNowLabel.frame = CGRectMake(userChatNowLabelMinX, CGRectGetMinY(self.userChatNowLabel.frame), userChatNowLabelSize.width, CGRectGetHeight(self.userChatNowLabel.frame));
        [self.userChatNowButtonView addSubview:self.userChatNowLabel];
        
        _userChatNowLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userChatNowLabel.frame) + 8.0f, ((CGRectGetHeight(self.addUserToContactButtonView.frame) - 16.0f) / 2.0f) + 2.0f, 16.0f, 16.0f)];
        self.userChatNowLogoImageView.image = [UIImage imageNamed:@"TAPIconChatNow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.userChatNowLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.userChatNowButtonView addSubview:self.userChatNowLogoImageView];
        
        _userChatNowButton = [[UIButton alloc] initWithFrame:self.userChatNowButtonView.frame];
        self.userChatNowButton.backgroundColor = [UIColor clearColor];
        self.userChatNowButton.alpha = 0.0f;
        self.userChatNowButton.userInteractionEnabled = NO;
        [self.searchUserView addSubview:self.userChatNowButton];
        
        _emptyStateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarView.frame) + 8.0f, CGRectGetWidth(frame), CGRectGetHeight(frame) - CGRectGetMaxY(self.searchBarView.frame))];
        self.emptyStateView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        self.emptyStateView.alpha = 0.0f;
        [self addSubview:self.emptyStateView];
        
        _emptyStateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.emptyStateView.frame) - 170.0f) / 2.0f, 35.0f, 170.0f, 170.0f)];
        self.emptyStateImageView.image = [UIImage imageNamed:@"TAPIconEmptySearch" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.emptyStateView addSubview:self.emptyStateImageView];
        
        _emptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.emptyStateImageView.frame) + 10.0f, CGRectGetWidth(self.emptyStateView.frame) - 16.0f - 16.0f, 36.0f)];
        self.emptyStateLabel.text = NSLocalizedString(@"Oops…\nCould not find any results", @"");
        self.emptyStateLabel.font = [UIFont fontWithName:TAP_FONT_NAME_NORMAL size:15.0f];
        NSRange range = [self.emptyStateLabel.text rangeOfString:@"Oops…"];
        //set attribute
        NSMutableAttributedString *emptyAttribuetdString = [[NSMutableAttributedString alloc] initWithString:self.emptyStateLabel.text];
        [emptyAttribuetdString addAttribute:NSFontAttributeName
                                      value:[UIFont fontWithName:TAP_FONT_NAME_BOLD size:15.0f]
                                      range:range];
        self.emptyStateLabel.attributedText = emptyAttribuetdString;
        self.emptyStateLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.emptyStateLabel.numberOfLines = 2;
        self.emptyStateLabel.textAlignment = NSTextAlignmentCenter;
        [self.emptyStateView addSubview:self.emptyStateLabel];
        
        _noInternetView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarView.frame) + 8.0f, CGRectGetWidth(self.frame), 68.0f)];
        self.noInternetView.backgroundColor = [TAPUtil getColor:@"FFFDEA"];
        self.noInternetView.alpha = 0.0f;
        [self addSubview:self.noInternetView];
        
        _noInternetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 10.0f, 48.0f, 48.0f)];
        self.noInternetImageView.image = [UIImage imageNamed:@"TAPIconConnectionLost" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.noInternetView addSubview:self.noInternetImageView];
        
        _noInternetTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.noInternetImageView.frame) + 8.0f, 10.0f, CGRectGetWidth(self.frame) - 16.0f - (CGRectGetMaxX(self.noInternetImageView.frame) + 8.0f), 24.0f)];
        self.noInternetTitleLabel.text = @"Internet Connection Lost";
        self.noInternetTitleLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.noInternetTitleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:15.0f];
        [self.noInternetView addSubview:self.noInternetTitleLabel];
        
        _noInternetDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.noInternetTitleLabel.frame), CGRectGetMaxY(self.noInternetTitleLabel.frame), CGRectGetWidth(self.noInternetTitleLabel.frame), 24.0f)];
        self.noInternetDescriptionLabel.text = @"Please check your connection";
        self.noInternetDescriptionLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.noInternetDescriptionLabel.font = [UIFont fontWithName:TAP_FONT_NAME_NORMAL size:15.0f];
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
        }];
    }
    else if (type == LayoutTypeUser) {
        //User View
        [UIView animateWithDuration:0.2f animations:^{
            self.defaultLabel.alpha = 0.0f;
            self.searchExpertView.alpha = 0.0f;
            self.searchUserView.alpha = 1.0f;
        }];
    }
    else if (type == LayoutTypeExpert) {
        //Expert View
        [UIView animateWithDuration:0.2f animations:^{
            self.defaultLabel.alpha = 0.0f;
            self.searchUserView.alpha = 0.0f;
            self.searchExpertView.alpha = 1.0f;
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
    
    NSString *fullName = user.fullname;
    fullName = [TAPUtil nullToEmptyString:fullName];
    
    NSString *userRoleCode = userRole.code;
    userRoleCode = [TAPUtil nullToEmptyString:userRoleCode];
    
    NSString *userRoleName = userRole.name;
    userRoleName = [TAPUtil nullToEmptyString:userRoleName];
    
    NSString *userRoleIcon = userRole.iconURL;
    userRoleIcon = [TAPUtil nullToEmptyString:userRoleIcon];
    
    TAPImageURLModel *imageURL = user.imageURL;
    NSString *imageURLString = imageURL.thumbnail;
    
    if ([userRole.code isEqualToString:@"expert"]) {
        self.expertNameLabel.text = fullName;
        
        if (imageURLString == nil || [imageURLString isEqualToString:@""]) {
            self.expertImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }
        else {
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
    else {
        self.userFullNameLabel.text = fullName;

        if (imageURLString == nil || [imageURLString isEqualToString:@""]) {
            self.userImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }
        else {
            [self.userImageView setImageWithURLString:imageURLString];
        }
        
        [self setSearchViewLayoutWithType:LayoutTypeUser];
        
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

@end
