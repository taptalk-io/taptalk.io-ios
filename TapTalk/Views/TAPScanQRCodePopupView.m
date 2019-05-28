//
//  TAPScanQRCodePopupView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 22/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPScanQRCodePopupView.h"

@interface TAPScanQRCodePopupView ()

//Base Popup View
@property (strong, nonatomic) UIVisualEffectView *visualEffectView;
@property (strong, nonatomic) UIView *backgroundGradientView;
@property (strong, nonatomic) UIView *whiteBaseView;
@property (strong, nonatomic) UIView *colorGradientView;
@property (strong, nonatomic) UIImageView *closePopupImageView;
@property (strong, nonatomic) TAPImageView *addedUserImageView;
@property (strong, nonatomic) UILabel *addedUserUsernameLabel;
@property (strong, nonatomic) UILabel *addedUserFullnameLabel;
@property (strong, nonatomic) UILabel *selfInformedLabel;

//Success Add Contact
@property (strong, nonatomic) TAPImageView *currentUserImageView;
@property (strong, nonatomic) UIImageView *successAddContactImageView;
@property (strong, nonatomic) UILabel *successAddContactLabel;

//Chat Now View
@property (strong, nonatomic) UIView *chatNowView;
@property (strong, nonatomic) UIImageView *chatNowLogoImageView;
@property (strong, nonatomic) UILabel *chatNowLabel;

//Add Contact View
@property (strong, nonatomic) UIView *addContactView;
@property (strong, nonatomic) UIImageView *addContactLogoImageView;
@property (strong, nonatomic) UILabel *addContactLabel;

@property (nonatomic) CGFloat leftRightGap;
@property (nonatomic) CGFloat profilePictureYPosition;
@property (nonatomic) CGFloat addedUserFullnameLabelBottomGap;
@property (nonatomic) CGFloat profilePictureBottomGap;
@property (nonatomic) CGFloat addedUserUsernameLabelBottomGap;
@property (nonatomic) CGFloat selfInformedLabelTopGap;

@property (nonatomic) CGFloat addedUserLogoTopGap;
@property (nonatomic) CGFloat successAddUserLabelTopGap;

- (void)setQRCodePopupViewDataWithType:(ScanQRCodePopupViewType)type userData:(TAPUserModel *)user;
- (void)animateBouncePopupViewWithType:(ScanQRCodePopupViewType)type;
- (void)resizeFriendListViewChangingHeightWithFirstTimeAdd:(BOOL)isFirstTime;
- (CGFloat)calculateFriendListViewChangingHeight;
- (void)resizeToSelfAddView;
- (void)resizeToStandardPopupView;

@end

@implementation TAPScanQRCodePopupView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        //Base Popup View
        if (IS_IPHONE_4_7_INCH_AND_ABOVE) {
            _leftRightGap = 42.0f;
            _addedUserUsernameLabelBottomGap = 4.0f;
            _addedUserFullnameLabelBottomGap = 63.0f;
            _profilePictureYPosition = 86.0f;
            _profilePictureBottomGap = 13.0f;
            _selfInformedLabelTopGap = 26.0f;
            
            _addedUserLogoTopGap = 40.0f;
            _successAddUserLabelTopGap = 8.0f;
        }
        else {
            _leftRightGap = 26.0f;
            _addedUserUsernameLabelBottomGap = 2.0f;
            _addedUserFullnameLabelBottomGap = 45.0f;
            _profilePictureYPosition = 68.0f;
            _profilePictureBottomGap = 8.0f;
            _selfInformedLabelTopGap = 20.0f;
            
            _addedUserLogoTopGap = 40.0f; //DV Temp
            _successAddUserLabelTopGap = 4.0f;
        }
        
        _backgroundGradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];
        backgroundGradientLayer.frame = self.backgroundGradientView.bounds;
        backgroundGradientLayer.colors = @[(id)[TAPUtil getColor:TAP_COLOR_DODGERBLUE_FF].CGColor, (id)[TAPUtil getColor:TAP_COLOR_BLURPLE_D7].CGColor];
        [self.backgroundGradientView.layer insertSublayer:backgroundGradientLayer atIndex:0];
        [self addSubview:self.backgroundGradientView];
        
        CGFloat widthSize = CGRectGetWidth(self.frame) - self.leftRightGap - self.leftRightGap;
        CGFloat heightSize = CGRectGetWidth(self.frame) / 375.0f * 359.0f; //375 is default iphone width
        _whiteBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.leftRightGap, (CGRectGetHeight(self.frame) - heightSize) / 2.0f, widthSize, heightSize)];
        self.whiteBaseView.backgroundColor = [UIColor whiteColor];
        self.whiteBaseView.alpha = 0.0f;
        self.whiteBaseView.layer.cornerRadius = 32.0f;
        self.whiteBaseView.clipsToBounds = YES;
        [self addSubview:self.whiteBaseView];
        
        _colorGradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.whiteBaseView.frame) - 54.0f, CGRectGetWidth(self.whiteBaseView.frame), 54.0f)];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.colorGradientView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:TAP_COLOR_ORANGE_33].CGColor, (id)[TAPUtil getColor:TAP_COLOR_ORANGE_00].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.colorGradientView.layer insertSublayer:gradient atIndex:0];
        [self.whiteBaseView addSubview:self.colorGradientView];
        
        _closePopupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.whiteBaseView.frame) - 24.0f - 28.0f, 24.0f, 28.0f, 28.0f)];
        self.closePopupImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.closePopupImageView.image = [UIImage imageNamed:@"TAPIconCloseGray" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.whiteBaseView addSubview:self.closePopupImageView];
        
        _closePopupButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.closePopupImageView.frame) - 6.0f, CGRectGetMinY(self.closePopupImageView.frame) - 6.0f, 40.0f, 40.0f)];
        [self.whiteBaseView addSubview:self.closePopupButton];
        
        _currentUserImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(-72.0f, self.profilePictureYPosition, 72.0f ,72.0f)];
        self.currentUserImageView.layer.cornerRadius = CGRectGetHeight(self.currentUserImageView.frame) / 2.0f;
        self.currentUserImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.currentUserImageView.layer.borderWidth = 4.0f;
        self.currentUserImageView.clipsToBounds = YES;
        self.currentUserImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.currentUserImageView.alpha = 0.0f;
        [self.whiteBaseView addSubview:self.currentUserImageView];
        
        _addedUserImageView = [[TAPImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.whiteBaseView.frame) - 72.0f) / 2.0f, CGRectGetMinY(self.currentUserImageView.frame), CGRectGetWidth(self.currentUserImageView.frame), CGRectGetHeight(self.currentUserImageView.frame))];
        self.addedUserImageView.layer.cornerRadius = CGRectGetHeight(self.addedUserImageView.frame) / 2.0f;
        self.addedUserImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.addedUserImageView.layer.borderWidth = 4.0f;
        self.addedUserImageView.clipsToBounds = YES;
        self.addedUserImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.whiteBaseView addSubview:self.addedUserImageView];
        
        _addedUserUsernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, CGRectGetMaxY(self.addedUserImageView.frame) + self.profilePictureBottomGap, CGRectGetWidth(self.whiteBaseView.frame) - 24.0f - 24.0f, 22.0f)];
        self.addedUserUsernameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:20.0f];
        self.addedUserUsernameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
        self.addedUserUsernameLabel.textAlignment = NSTextAlignmentCenter;
        self.addedUserUsernameLabel.numberOfLines = 2;
        [self.whiteBaseView addSubview:self.addedUserUsernameLabel];
        
        _addedUserFullnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.addedUserUsernameLabel.frame), CGRectGetMaxY(self.addedUserUsernameLabel.frame) + self.addedUserUsernameLabelBottomGap, CGRectGetWidth(self.addedUserUsernameLabel.frame), 18.0f)];
        self.addedUserFullnameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:13.0f];
        self.addedUserFullnameLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_9B];
        self.addedUserFullnameLabel.textAlignment = NSTextAlignmentCenter;
        [self.whiteBaseView addSubview:self.addedUserFullnameLabel];
        
        _selfInformedLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, CGRectGetMaxY(self.addedUserFullnameLabel.frame) + self.selfInformedLabelTopGap, CGRectGetWidth(self.whiteBaseView.frame) - 24.0f - 24.0f, 18.0f)];
        self.selfInformedLabel.text = NSLocalizedString(@"This is you", @"");
        self.selfInformedLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:13.0f];
        self.selfInformedLabel.textColor = [TAPUtil getColor:TAP_COLOR_ORANGE_00];
        self.selfInformedLabel.textAlignment = NSTextAlignmentCenter;
        self.selfInformedLabel.alpha = 0.0f;
        [self.whiteBaseView addSubview:self.selfInformedLabel];
        
        //Success Add Contact
        _successAddContactImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.whiteBaseView.frame) - 36.0f) / 2.0f, CGRectGetMaxY(self.currentUserImageView.frame) + self.addedUserLogoTopGap, 36.0f, 36.0f)];
        self.successAddContactImageView.image = [UIImage imageNamed:@"TAPIconAddedToContact" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.successAddContactImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.successAddContactImageView.alpha = 0.0f;
        [self.whiteBaseView addSubview:self.successAddContactImageView];
        
        _successAddContactLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, CGRectGetMaxY(self.successAddContactImageView.frame) + self.successAddUserLabelTopGap, CGRectGetWidth(self.whiteBaseView.frame) - 24.0f - 24.0f, 22.0f)];
        self.successAddContactLabel.alpha = 0.0f;
        self.successAddContactLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:13.0f];
        self.successAddContactLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
        self.successAddContactLabel.numberOfLines = 0;
        self.successAddContactLabel.textAlignment = NSTextAlignmentCenter;
        [self.whiteBaseView addSubview:self.successAddContactLabel];
        
        //Add To Contact View
        _addContactView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.colorGradientView.frame), CGRectGetHeight(self.colorGradientView.frame))];
        self.addContactView.backgroundColor = [UIColor clearColor];
        [self.colorGradientView addSubview:self.addContactView];
        
        _addContactLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (CGRectGetHeight(self.addContactView.frame) - 22.0f) / 2.0f, 76.0f, 22.0f)];
        self.addContactLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:15.0f];
        self.addContactLabel.textColor = [UIColor whiteColor];
        self.addContactLabel.textAlignment = NSTextAlignmentCenter;
        self.addContactLabel.text = NSLocalizedString(@"Add To Contacts", @"");
        [self.addContactView addSubview:self.addContactLabel];
        
        CGSize addContactDefaultLabelSize = [self.addContactLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.addContactLabel.frame))];
        self.addContactLabel.frame = CGRectMake(CGRectGetMinX(self.addContactLabel.frame), CGRectGetMinY(self.addContactLabel.frame), ceil(addContactDefaultLabelSize.width), CGRectGetHeight(self.addContactLabel.frame));
        
        CGFloat addContactLogoImageMinX = (CGRectGetWidth(self.addContactView.frame) - 5.0f - 10.0f - addContactDefaultLabelSize.width) / 2.0f;
        _addContactLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(addContactLogoImageMinX, (CGRectGetHeight(self.addContactView.frame) - 10.0f) / 2.0f, 10.0f, 10.0f)];
        self.addContactLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.addContactLogoImageView.image = [UIImage imageNamed:@"TAPIconPlusWhite" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.addContactView addSubview:self.addContactLogoImageView];
        
        self.addContactLabel.frame = CGRectMake(CGRectGetMaxX(self.addContactLogoImageView.frame) + 5.0f, CGRectGetMinY(self.addContactLabel.frame), CGRectGetWidth(self.addContactLabel.frame), CGRectGetHeight(self.addContactLabel.frame));
        
        _addContactButton = [[UIButton alloc] initWithFrame:self.addContactView.frame];
        [self.colorGradientView addSubview:self.addContactButton];
        
        //Chat Now View
        _chatNowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.colorGradientView.frame), CGRectGetHeight(self.colorGradientView.frame))];
        self.chatNowView.backgroundColor = [UIColor clearColor];
        self.chatNowView.alpha = 0.0f;
        [self.colorGradientView addSubview:self.chatNowView];
        
        _chatNowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (CGRectGetHeight(self.chatNowView.frame) - 22.0f) / 2.0f, 76.0f, 22.0f)];
        self.chatNowLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:15.0f];
        self.chatNowLabel.textColor = [UIColor whiteColor];
        self.chatNowLabel.textAlignment = NSTextAlignmentCenter;
        self.chatNowLabel.text = NSLocalizedString(@"Chat Now", @"");
        [self.chatNowView addSubview:self.chatNowLabel];
        
        CGSize chatNowDefaultLabelSize = [self.chatNowLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.chatNowLabel.frame))];
        self.chatNowLabel.frame = CGRectMake(CGRectGetMinX(self.chatNowLabel.frame), CGRectGetMinY(self.chatNowLabel.frame), ceil(chatNowDefaultLabelSize.width), CGRectGetHeight(self.chatNowLabel.frame));
        
        CGFloat chatNowLogoImageMinX = (CGRectGetWidth(self.chatNowView.frame) - 5.0f - 16.0f - chatNowDefaultLabelSize.width) / 2.0f;
        _chatNowLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(chatNowLogoImageMinX, (CGRectGetHeight(self.chatNowView.frame) - 16.0f) / 2.0f, 16.0f, 16.0f)];
        self.chatNowLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.chatNowLogoImageView.image = [UIImage imageNamed:@"TAPIconChatNow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.chatNowView addSubview:self.chatNowLogoImageView];
        
        self.chatNowLabel.frame = CGRectMake(CGRectGetMaxX(self.chatNowLogoImageView.frame) + 5.0f, CGRectGetMinY(self.chatNowLabel.frame), CGRectGetWidth(self.chatNowLabel.frame), CGRectGetHeight(self.chatNowLabel.frame));
        
        _chatNowButton = [[UIButton alloc] initWithFrame:self.chatNowView.frame];
        [self.colorGradientView addSubview:self.chatNowButton];
        
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.loadingView.backgroundColor = [UIColor blackColor];
        self.loadingView.alpha = 0.0f;
        [self addSubview:self.loadingView];
        
        _activityIndicatorLoading = [[UIActivityIndicatorView alloc] init];
        self.activityIndicatorLoading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.activityIndicatorLoading.center = CGPointMake(self.frame.size.width / 2.0f, (self.frame.size.height - 64.0f) / 2.0f);
        [self.activityIndicatorLoading startAnimating];
        self.activityIndicatorLoading.alpha = 0.0f;
        [self addSubview:self.activityIndicatorLoading];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)showPopupView:(BOOL)isVisible animated:(BOOL)isAnimated {
    CGFloat animateDuration = 0.0f;
    if (isAnimated) {
        animateDuration = 0.2f;
    }
    
    if (isVisible) {
        [UIView animateWithDuration:animateDuration animations:^{
            self.alpha = 1.0f;
        }];
    }
    else {
        self.whiteBaseView.alpha = 0.0f;
        [UIView animateWithDuration:animateDuration animations:^{
            self.alpha = 0.0f;
        }];
    }
}

- (void)setPopupInfoWithUserData:(TAPUserModel *)user isContact:(BOOL)isContact {
    
    NSString *currentUserID = [TAPDataManager getActiveUser].userID;
    currentUserID = [TAPUtil nullToEmptyString:currentUserID];
    
    NSString *searchedUserID = user.userID;
    
    if ([currentUserID isEqualToString:searchedUserID]) {
        //Scan theirselves
        [self setQRCodePopupViewDataWithType:ScanQRCodePopupViewTypeSelf userData:user];
    }
    else {
        if (isContact) {
            //Already Friend
            [self setQRCodePopupViewDataWithType:ScanQRCodePopupViewTypeAlreadyFriend userData:user];
        }
        else {
            //New Friend
            [self setQRCodePopupViewDataWithType:ScanQRCodePopupViewTypeNewFriend userData:user];
        }
    }
}

- (void)setQRCodePopupViewDataWithType:(ScanQRCodePopupViewType)type userData:(TAPUserModel *)user {
    
    //    ScanQRCodePopupViewTypeDefault = 0,
    //    ScanQRCodePopupViewTypeNewFriend = 1,
    //    ScanQRCodePopupViewTypeAlreadyFriend = 2,
    //    ScanQRCodePopupViewTypeSelf = 3
    
    [self setScanQRCodePopupViewType:type];
    
    NSString *currentUserProfileImage = [TAPDataManager getActiveUser].imageURL.thumbnail;
    currentUserProfileImage = [TAPUtil nullToEmptyString:currentUserProfileImage];
    [self.currentUserImageView setImageWithURLString:currentUserProfileImage];
    
    NSString *addedUserFullName = user.fullname;
    addedUserFullName = [TAPUtil nullToEmptyString:addedUserFullName];
    
    NSString *addedUserUsername = user.username;
    addedUserUsername = [TAPUtil nullToEmptyString:addedUserUsername];
    
    NSString *addedUserProfileImage = user.imageURL.thumbnail;
    addedUserProfileImage = [TAPUtil nullToEmptyString:addedUserProfileImage];
    
    [self.addedUserImageView setImageWithURLString:addedUserProfileImage];
    self.addedUserUsernameLabel.text = addedUserUsername;
    self.addedUserFullnameLabel.text = addedUserFullName;
    
    if (type == ScanQRCodePopupViewTypeDefault) {
        [self resizeToStandardPopupView];
    }
    else if (type == ScanQRCodePopupViewTypeNewFriend) {
        //First time add user, showing icon add friend
        NSString *localizedTemplateSuccessHeaderString = NSLocalizedString(@"You have added", @"");
        NSString *localizedTemplateSuccessFooterString = NSLocalizedString(@"to your contacts", @"");
        self.successAddContactLabel.text = [NSString stringWithFormat:@"%@ %@ %@", localizedTemplateSuccessHeaderString, addedUserFullName, localizedTemplateSuccessFooterString];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionary];
        [attributesDictionary setObject:[UIFont fontWithName:TAP_FONT_NAME_BOLD size:13.0f] forKey:NSFontAttributeName];
        [attributesDictionary setObject:[TAPUtil getColor:TAP_COLOR_BLACK_19] forKey:NSForegroundColorAttributeName];
        [attributesDictionary setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        
        NSMutableAttributedString *addedUserFullnameAttributedString = [[NSMutableAttributedString alloc] initWithString:self.successAddContactLabel.text];
        NSRange addedFullnameRange = [self.successAddContactLabel.text rangeOfString:addedUserFullName];
        [addedUserFullnameAttributedString addAttributes:attributesDictionary
                                                   range:addedFullnameRange];
        self.successAddContactLabel.attributedText = addedUserFullnameAttributedString;
        
        self.successAddContactLabel.textAlignment = NSTextAlignmentCenter;
        
        [self resizeToStandardPopupView];
    }
    else if (type == ScanQRCodePopupViewTypeAlreadyFriend) {
        NSString *localizedTemplateSuccessString = NSLocalizedString(@"is already in your contacts", @"");
        self.successAddContactLabel.text = [NSString stringWithFormat:@"%@ %@", addedUserFullName, localizedTemplateSuccessString];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionary];
        [attributesDictionary setObject:[UIFont fontWithName:TAP_FONT_NAME_BOLD size:13.0f] forKey:NSFontAttributeName];
        [attributesDictionary setObject:[TAPUtil getColor:TAP_COLOR_BLACK_19] forKey:NSForegroundColorAttributeName];
        [attributesDictionary setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        
        NSMutableAttributedString *addedUserFullnameAttributedString = [[NSMutableAttributedString alloc] initWithString:self.successAddContactLabel.text];
        NSRange addedFullnameRange = [self.successAddContactLabel.text rangeOfString:addedUserFullName];
        [addedUserFullnameAttributedString addAttributes:attributesDictionary
                                                   range:addedFullnameRange];
        self.successAddContactLabel.attributedText = addedUserFullnameAttributedString;
        
        self.successAddContactLabel.textAlignment = NSTextAlignmentCenter;
        
        [self resizeToStandardPopupView];
    }
    else if (type == ScanQRCodePopupViewTypeSelf) {
        [self resizeToSelfAddView];
    }
    
    [self animateBouncePopupViewWithType:type];
}

- (void)resizeToSelfAddView {
    CGFloat profilePictureHeight = CGRectGetHeight(self.addedUserImageView.frame);
    
    CGSize usernameLabelSize = [self.addedUserUsernameLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.addedUserUsernameLabel.frame), CGFLOAT_MAX)];
    CGFloat usernameHeight = ceil(usernameLabelSize.height);
    
    CGFloat addedUserFullnameLabelHeight = CGRectGetHeight(self.addedUserFullnameLabel.frame);
    
    CGFloat selfInformedLabelHeight = CGRectGetHeight(self.selfInformedLabel.frame);
    
    CGFloat bottomGap = 24.0f;
    
    CGFloat totalBaseViewHeight = self.profilePictureYPosition + profilePictureHeight + self.profilePictureBottomGap + usernameHeight + self.addedUserUsernameLabelBottomGap + addedUserFullnameLabelHeight + self.selfInformedLabelTopGap + selfInformedLabelHeight + bottomGap;
    
    //Resize View
    self.addedUserUsernameLabel.frame = CGRectMake(CGRectGetMinX(self.addedUserUsernameLabel.frame), CGRectGetMinY(self.addedUserUsernameLabel.frame), CGRectGetWidth(self.addedUserUsernameLabel.frame), usernameHeight);
    
    self.addedUserFullnameLabel.frame = CGRectMake(CGRectGetMinX(self.addedUserFullnameLabel.frame), CGRectGetMaxY(self.addedUserUsernameLabel.frame) + self.addedUserUsernameLabelBottomGap, CGRectGetWidth(self.addedUserFullnameLabel.frame), CGRectGetHeight(self.addedUserFullnameLabel.frame));
    
    self.selfInformedLabel.frame = CGRectMake(CGRectGetMinX(self.selfInformedLabel.frame), CGRectGetMaxY(self.addedUserFullnameLabel.frame) + self.selfInformedLabelTopGap, CGRectGetWidth(self.selfInformedLabel.frame), CGRectGetHeight(self.selfInformedLabel.frame));
    
    self.whiteBaseView.frame = CGRectMake(CGRectGetMinX(self.whiteBaseView.frame), (CGRectGetHeight(self.frame) - totalBaseViewHeight) / 2.0f, CGRectGetWidth(self.whiteBaseView.frame), totalBaseViewHeight);
}

- (void)resizeToStandardPopupView {
    CGFloat profilePictureHeight = CGRectGetHeight(self.addedUserImageView.frame);
    
    CGSize usernameLabelSize = [self.addedUserUsernameLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.addedUserUsernameLabel.frame), CGFLOAT_MAX)];
    CGFloat usernameHeight = ceil(usernameLabelSize.height);
    
    CGFloat addedUserFullnameLabelHeight = CGRectGetHeight(self.addedUserFullnameLabel.frame);
    
    CGFloat buttonViewHeight = CGRectGetHeight(self.colorGradientView.frame);
    
    CGFloat totalBaseViewHeight = self.profilePictureYPosition + profilePictureHeight + self.profilePictureBottomGap + usernameHeight + self.addedUserUsernameLabelBottomGap + addedUserFullnameLabelHeight + self.addedUserFullnameLabelBottomGap + buttonViewHeight;
    
    //Resize View
    self.addedUserUsernameLabel.frame = CGRectMake(CGRectGetMinX(self.addedUserUsernameLabel.frame), CGRectGetMinY(self.addedUserUsernameLabel.frame), CGRectGetWidth(self.addedUserUsernameLabel.frame), usernameHeight);
    
    self.addedUserFullnameLabel.frame = CGRectMake(CGRectGetMinX(self.addedUserFullnameLabel.frame), CGRectGetMaxY(self.addedUserUsernameLabel.frame) + 4.0f, CGRectGetWidth(self.addedUserFullnameLabel.frame), CGRectGetHeight(self.addedUserFullnameLabel.frame));
    
    self.whiteBaseView.frame = CGRectMake(CGRectGetMinX(self.whiteBaseView.frame), (CGRectGetHeight(self.frame) - totalBaseViewHeight) / 2.0f, CGRectGetWidth(self.whiteBaseView.frame), totalBaseViewHeight);
    
    self.colorGradientView.frame = CGRectMake(CGRectGetMinX(self.colorGradientView.frame), CGRectGetHeight(self.whiteBaseView.frame) - CGRectGetHeight(self.colorGradientView.frame), CGRectGetWidth(self.colorGradientView.frame), CGRectGetHeight(self.colorGradientView.frame));
}

- (void)animateBouncePopupViewWithType:(ScanQRCodePopupViewType)type {
    if (type == ScanQRCodePopupViewTypeNewFriend) {
        //Showing Add To contact button
        self.colorGradientView.alpha = 1.0f;
        self.selfInformedLabel.alpha = 0.0f;

        self.addContactView.alpha = 1.0f;
        self.addContactButton.alpha = 1.0f;
        self.addContactButton.userInteractionEnabled = YES;

        self.chatNowView.alpha = 0.0f;
        self.chatNowButton.alpha = 0.0f;
        self.chatNowButton.userInteractionEnabled = NO;
    }
    else if (type == ScanQRCodePopupViewTypeAlreadyFriend) {
        self.colorGradientView.alpha = 0.0f;
        self.selfInformedLabel.alpha = 0.0f;
        
        self.addContactView.alpha = 0.0f;
        self.addContactButton.alpha = 0.0f;
        self.addContactButton.userInteractionEnabled = NO;
        
        self.chatNowView.alpha = 1.0f;
        self.chatNowButton.alpha = 1.0f;
        self.chatNowButton.userInteractionEnabled = YES;
    }
    else if (type == ScanQRCodePopupViewTypeSelf) {
        self.colorGradientView.alpha = 0.0f;
        self.addContactButton.userInteractionEnabled = NO;
        self.chatNowButton.userInteractionEnabled = NO;
        self.selfInformedLabel.alpha = 1.0f;
    }
    
    self.whiteBaseView.transform = CGAffineTransformMakeScale(0.3, 0.4);
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.whiteBaseView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
    
    self.whiteBaseView.alpha = 1.0f;
    
    if (type == ScanQRCodePopupViewTypeAlreadyFriend) {
        //Auto expanding when already friend
        [self performSelector:@selector(animateExpandingView) withObject:nil afterDelay:0.5f];
    }
}

- (void)animateExpandingView {
    
    CGFloat additionalChangingHeight = 0.0f;
    if (IS_IPHONE_4_7_INCH_AND_ABOVE) {
        additionalChangingHeight = 40.0f;
    }
    else {
        additionalChangingHeight = 30.0f;
    }
    
    if (self.scanQRCodePopupViewType == ScanQRCodePopupViewTypeAlreadyFriend) {
        [self resizeFriendListViewChangingHeightWithFirstTimeAdd:NO];
    }
    else if (self.scanQRCodePopupViewType == ScanQRCodePopupViewTypeNewFriend) {
        [self resizeFriendListViewChangingHeightWithFirstTimeAdd:YES];
    }
    
    CGFloat whiteViewHeight = [self calculateFriendListViewChangingHeight];
    
    self.chatNowButton.alpha = 1.0f;
    self.chatNowButton.userInteractionEnabled = YES;
    self.chatNowView.alpha = 1.0f;
    
    self.addContactButton.alpha = 0.0f;
    self.addContactButton.userInteractionEnabled = NO;
    self.addContactView.alpha = 0.0f;
    
    //Slow 0.5
    //Fast 0.25
    [UIView animateWithDuration:0.25f animations:^{
        //Animate Base White Frame Changing
        self.whiteBaseView.frame = CGRectMake(CGRectGetMinX(self.whiteBaseView.frame), ((CGRectGetHeight(self.frame) - whiteViewHeight) / 2.0f) - (additionalChangingHeight / 2.0f), CGRectGetWidth(self.whiteBaseView.frame), whiteViewHeight + additionalChangingHeight);
        self.colorGradientView.frame = CGRectMake(CGRectGetMinX(self.colorGradientView.frame), CGRectGetHeight(self.whiteBaseView.frame) -  CGRectGetHeight(self.colorGradientView.frame), CGRectGetWidth(self.colorGradientView.frame), CGRectGetHeight(self.colorGradientView.frame));
        
        //Animate User Image Changing
        self.currentUserImageView.alpha = 1.0f;
        self.colorGradientView.alpha = 1.0f;
        
        [UIView animateWithDuration:0.5f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            CGFloat halfViewWidth = CGRectGetWidth(self.whiteBaseView.frame) / 2.0f;
            CGFloat xPosition = halfViewWidth - (CGRectGetWidth(self.addedUserImageView.frame) / 2.0f) - CGRectGetWidth(self.currentUserImageView.frame);
            //12 px is the left space of the intersection (total intersection width is 24 px)
            CGFloat halfIntersectionWidth = 24.0f / 2.0f;
            
            self.currentUserImageView.frame = CGRectMake(xPosition + (CGRectGetWidth(self.addedUserImageView.frame) / 2.0f) + halfIntersectionWidth, CGRectGetMinY(self.currentUserImageView.frame), CGRectGetWidth(self.currentUserImageView.frame), CGRectGetHeight(self.currentUserImageView.frame));
            
        } completion:^(BOOL finished) {
        }];
        
        //slow delay 0.3 damping 0.4 velocity 25
        //fast delay 0.15 damping 0.4 velocity 25
        [UIView animateWithDuration:1.0f delay:0.15f usingSpringWithDamping:0.4f initialSpringVelocity:25.0f options:UIViewAnimationOptionCurveLinear animations:^{
            //24 px is the width of the intersection
            self.addedUserImageView.frame = CGRectMake((CGRectGetWidth(self.whiteBaseView.frame) - CGRectGetWidth(self.addedUserImageView.frame)) / 2.0f + 24.0f, CGRectGetMinY(self.addedUserImageView.frame), CGRectGetWidth(self.addedUserImageView.frame), CGRectGetHeight(self.addedUserImageView.frame));
        } completion:^(BOOL finished) {
        }];
        
        //Show Success Add Contact
        [UIView animateWithDuration:0.5f animations:^{
            self.successAddContactImageView.alpha = 1.0f;
            self.successAddContactLabel.alpha = 1.0f;
            self.addedUserUsernameLabel.alpha = 0.0f;
            self.addedUserFullnameLabel.alpha = 0.0f;
        }];
        
    }];
}

- (void)resizeFriendListViewChangingHeightWithFirstTimeAdd:(BOOL)isFirstTime {
    if (isFirstTime) {
        //First time add user, showing icon add friend
        self.successAddContactImageView.alpha = 1.0f;
        
        if (IS_IPHONE_4_7_INCH_AND_ABOVE) {
            self.successAddUserLabelTopGap = 8.0f;
            self.addedUserLogoTopGap = 40.0f;
        }
        else {
            self.successAddUserLabelTopGap = 4.0f;
            self.addedUserLogoTopGap = 40.0f; //DV Temp
        }
        
        //Resize View
        self.successAddContactImageView.frame = CGRectMake(CGRectGetMinX(self.successAddContactImageView.frame), CGRectGetMaxY(self.addedUserImageView.frame) + self.addedUserLogoTopGap, CGRectGetWidth(self.successAddContactImageView.frame), 36.0f);
    }
    else {
        self.successAddContactImageView.alpha = 1.0f;
        
        self.successAddUserLabelTopGap = 0.0f;
        self.addedUserLogoTopGap = 64.0f;
        
        //Resize View
        self.successAddContactImageView.frame = CGRectMake(CGRectGetMinX(self.successAddContactImageView.frame), CGRectGetMaxY(self.addedUserImageView.frame) + self.addedUserLogoTopGap, CGRectGetWidth(self.successAddContactImageView.frame), 0.0f);
    }
    
    //Resize View
    CGSize successAddContactDefaultLabelSize = [self.successAddContactLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.successAddContactLabel.frame), CGFLOAT_MAX)];
    self.successAddContactLabel.frame = CGRectMake(CGRectGetMinX(self.successAddContactLabel.frame), CGRectGetMaxY(self.successAddContactImageView.frame) + self.successAddUserLabelTopGap, CGRectGetWidth(self.successAddContactLabel.frame), ceil(successAddContactDefaultLabelSize.height));
}

- (CGFloat)calculateFriendListViewChangingHeight {
    
    CGFloat profilePictureHeight = CGRectGetHeight(self.addedUserImageView.frame);
    CGFloat buttonViewHeight = CGRectGetHeight(self.colorGradientView.frame);
    
    CGFloat totalBaseViewHeight = self.profilePictureYPosition + profilePictureHeight + self.addedUserLogoTopGap  + CGRectGetHeight(self.successAddContactImageView.frame) + self.successAddUserLabelTopGap + CGRectGetHeight(self.successAddContactLabel.frame) + buttonViewHeight;
    
    return totalBaseViewHeight;
}

- (void)setPopupViewToDefault {
    //Resize to default size and view
    self.currentUserImageView.alpha = 0.0f;
    self.successAddContactImageView.alpha = 0.0f;
    self.successAddContactLabel.alpha = 0.0f;
    self.addedUserUsernameLabel.alpha = 1.0f;
    self.addedUserFullnameLabel.alpha = 1.0f;
    
    self.currentUserImageView.frame = CGRectMake(-72.0f, self.profilePictureYPosition, CGRectGetWidth(self.currentUserImageView.frame) ,CGRectGetHeight(self.currentUserImageView.frame));
    self.addedUserImageView.frame = CGRectMake((CGRectGetWidth(self.whiteBaseView.frame) - 72.0f) / 2.0f, CGRectGetMinY(self.currentUserImageView.frame), CGRectGetWidth(self.currentUserImageView.frame), CGRectGetHeight(self.currentUserImageView.frame));
    
    [self resizeToStandardPopupView];
}

- (void)setScanQRCodePopupViewType:(ScanQRCodePopupViewType)scanQRCodePopupViewType {
    _scanQRCodePopupViewType = scanQRCodePopupViewType;
}

- (void)setIsLoading:(BOOL)isLoading animated:(BOOL)isAnimated {
    
    CGFloat duration = 0.0f;
    if (isAnimated) {
        duration = 0.2f;
    }
    
    if (isLoading) {
        [UIView animateWithDuration:duration animations:^{
            self.loadingView.alpha = 0.4f;
            self.activityIndicatorLoading.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:duration animations:^{
            self.loadingView.alpha = 0.0f;
            self.activityIndicatorLoading.alpha = 0.0f;
        }];
    }
}

//DV Note - Animation of 2 view meetup at the middle
//- (void)animateExpandingView {
//    [UIView animateWithDuration:0.3f animations:^{
//
//        //Animate Base White Frame Changing
//        self.whiteBaseView.frame = CGRectMake(CGRectGetMinX(self.whiteBaseView.frame), CGRectGetMinY(self.whiteBaseView.frame) - (kHeightChanging / 2.0f), CGRectGetWidth(self.whiteBaseView.frame), CGRectGetHeight(self.whiteBaseView.frame) + kHeightChanging);
//        self.colorGradientView.frame = CGRectMake(CGRectGetMinX(self.colorGradientView.frame), CGRectGetHeight(self.whiteBaseView.frame) - 54.0f, CGRectGetWidth(self.colorGradientView.frame), CGRectGetHeight(self.colorGradientView.frame));
//
//        //Animate User Image Changing
//        self.addedUserImageView.alpha = 0.0f;
//        self.leftUserImageView.alpha = 1.0f;
//        self.rightUserImageView.alpha = 1.0f;
//        self.colorGradientView.alpha = 1.0f;
//
//        [UIView animateWithDuration:0.5f animations:^{
//            self.leftUserImageView.frame = CGRectMake(((CGRectGetWidth(self.whiteBaseView.frame) / 2.0f) - CGRectGetWidth(self.leftUserImageView.frame)) + 12.0f, CGRectGetMinY(self.leftUserImageView.frame), CGRectGetWidth(self.leftUserImageView.frame), CGRectGetHeight(self.leftUserImageView.frame));
//            self.rightUserImageView.frame = CGRectMake((CGRectGetWidth(self.whiteBaseView.frame) / 2.0f) - 12.0f, CGRectGetMinY(self.rightUserImageView.frame), CGRectGetWidth(self.rightUserImageView.frame), CGRectGetHeight(self.rightUserImageView.frame));
//
//            //Show Success Add Contact
//            self.successAddContactImageView.alpha = 1.0f;
//            self.successAddContactLabel.alpha = 1.0f;
//            self.addedUserUsernameLabel.alpha = 0.0f;
//            self.addedUserFullnameLabel.alpha = 0.0f;
//        }];
//
//    }];
//}

@end
