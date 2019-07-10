//
//  TAPPopUpInfoView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 19/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPPopUpInfoView.h"

@interface TAPPopUpInfoView ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *popupWhiteView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;

- (void)resizeSubview;
- (void)isShowTwoOptionButton:(BOOL)isShow;

@end

@implementation TAPPopUpInfoView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        [self addSubview:self.backgroundView];
        
        _popupWhiteView = [[UIView alloc] initWithFrame:CGRectMake(32.0f, 0.0f, CGRectGetWidth(self.frame) - 32.0f - 32.0f, 0.0f)];
        self.popupWhiteView.layer.cornerRadius = 4.0f;
        self.popupWhiteView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f].CGColor;
        self.popupWhiteView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.popupWhiteView.layer.shadowOpacity = 0.4f;
        self.popupWhiteView.layer.shadowRadius = 4.0f;
        self.popupWhiteView.backgroundColor = [UIColor whiteColor];
        self.popupWhiteView.clipsToBounds = YES;
        [self addSubview:self.popupWhiteView];
        
        UIFont *popupTitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupDialogTitle];
        UIColor *popupTitleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogTitle];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 16.0f, CGRectGetWidth(self.popupWhiteView.frame) - 16.0f - 16.0f, 22.0f)];
        self.titleLabel.font = popupTitleLabelFont;
        self.titleLabel.textColor = popupTitleLabelColor;
        [self.popupWhiteView addSubview:self.titleLabel];
        
        UIFont *popupBodyLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupDialogBody];
        UIColor *popupBodyLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogBody];
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame) + 4.0f, CGRectGetWidth(self.titleLabel.frame), 0.0f)];
        self.detailLabel.numberOfLines = 0;
        self.detailLabel.font = popupBodyLabelFont;
        self.detailLabel.textColor = popupBodyLabelColor;
        [self.popupWhiteView addSubview:self.detailLabel];
        
        UIFont *popupPrimaryButtonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupDialogButtonTextPrimary];
        UIColor *popupPrimaryButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogButtonTextPrimary];
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.popupWhiteView.frame) - 85.0f - 16.0f, CGRectGetMaxY(self.detailLabel.frame) + 16.0f, 85.0f, 40.0f)];
        self.rightButton.titleLabel.font = popupPrimaryButtonFont;
        self.rightButton.layer.cornerRadius = 4.0f;
        self.rightButton.titleLabel.textColor = popupPrimaryButtonColor;
        self.rightButton.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorPopupDialogPrimaryButtonSuccessBackground];
        [self.popupWhiteView addSubview:self.rightButton];
        
        UIFont *popupSecondaryButtonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupDialogButtonTextSecondary];
        UIColor *popupSecondaryButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogButtonTextSecondary];
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.rightButton.frame) - 6.0f - 85.0f, CGRectGetMinY(self.rightButton.frame), CGRectGetWidth(self.rightButton.frame), CGRectGetHeight(self.rightButton.frame))];
        self.leftButton.layer.cornerRadius = 4.0f;
        self.leftButton.titleLabel.font = popupSecondaryButtonFont;
        self.leftButton.titleLabel.textColor = popupSecondaryButtonColor;
        self.leftButton.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorPopupDialogSecondaryButtonBackground];
        [self.popupWhiteView addSubview:self.leftButton];
        
    }
    return self;
}

#pragma mark - Custom Method
- (void)resizeSubview {
    CGSize size = [self.detailLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.detailLabel.frame), CGFLOAT_MAX)];
    self.detailLabel.frame = CGRectMake(CGRectGetMinX(self.detailLabel.frame), CGRectGetMinY(self.detailLabel.frame), CGRectGetWidth(self.detailLabel.frame), size.height);
    
    self.rightButton.frame = CGRectMake(CGRectGetMinX(self.rightButton.frame), CGRectGetMaxY(self.detailLabel.frame) + 16.0f, CGRectGetWidth(self.rightButton.frame), CGRectGetHeight(self.rightButton.frame));
    
    self.leftButton.frame = CGRectMake(CGRectGetMinX(self.leftButton.frame), CGRectGetMinY(self.rightButton.frame), CGRectGetWidth(self.leftButton.frame), CGRectGetHeight(self.leftButton.frame));

    CGFloat popupInfoViewHeight = CGRectGetMaxY(self.rightButton.frame) + 16.0f;
    self.popupWhiteView.frame = CGRectMake(CGRectGetMinX(self.popupWhiteView.frame), (CGRectGetHeight(self.frame) - popupInfoViewHeight) / 2.0f, CGRectGetWidth(self.popupWhiteView.frame), popupInfoViewHeight);
}

- (void)isShowTwoOptionButton:(BOOL)isShow {
    if (isShow) {
        self.leftButton.userInteractionEnabled = YES;
        self.leftButton.alpha = 1.0f;
    }
    else {
        self.leftButton.userInteractionEnabled = NO;
        self.leftButton.alpha = 0.0f;
    }
}

- (void)setPopupInfoViewType:(TAPPopupInfoViewType)popupInfoViewType withTitle:(NSString *)title detailInformation:(NSString *)detailInfo leftOptionButtonTitle:(NSString *)leftOptionTitle singleOrRightOptionButtonTitle:(NSString *)singleOrRightOptionTitle {
    _popupInfoViewType = popupInfoViewType;
    
    if (self.popupInfoViewType == TAPPopupInfoViewTypeErrorMessage) {
        [self setPopupInfoViewThemeType:TAPPopupInfoViewThemeTypeDestructive];
    }
    else if (self.popupInfoViewType == TAPPopupInfoViewTypeSuccessMessage) {
        [self setPopupInfoViewThemeType:TAPPopupInfoViewThemeTypeDefault];
    }
    else if (self.popupInfoViewType == TAPPopupInfoViewTypeInfoDefault) {
        [self setPopupInfoViewThemeType:TAPPopupInfoViewThemeTypeDefault];
    }
    else if (self.popupInfoViewType == TAPPopupInfoViewTypeInfoDestructive) {
        [self setPopupInfoViewThemeType:TAPPopupInfoViewThemeTypeDestructive];
    }
    
    self.titleLabel.text = title;
    self.detailLabel.text = detailInfo;
    [self.leftButton setTitle:leftOptionTitle forState:UIControlStateNormal];
    [self.rightButton setTitle:singleOrRightOptionTitle forState:UIControlStateNormal];
    
    [self resizeSubview];
}


- (void)setPopupInfoViewThemeType:(TAPPopupInfoViewThemeType)popupInfoViewThemeType {
    
    UIColor *popupPrimaryButtonSuccessColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogButtonTextPrimary];
    UIColor *popupPrimaryButtonSuccessBackgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorPopupDialogPrimaryButtonSuccessBackground];
    
    UIColor *popupPrimaryButtonDestructiveColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogButtonTextPrimary];
    UIColor *popupPrimaryButtonDestructiveBackgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorPopupDialogPrimaryButtonErrorBackground];
    
    UIColor *popupSecondaryButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogButtonTextSecondary];
    UIColor *popupSecondaryBackgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorPopupDialogSecondaryButtonBackground];
    
    _popupInfoViewThemeType = popupInfoViewThemeType;
    if (self.popupInfoViewThemeType == TAPPopupInfoViewThemeTypeDestructive) {
        //Red theme
        [self.rightButton setTitleColor:popupPrimaryButtonDestructiveColor forState:UIControlStateNormal];
        self.rightButton.backgroundColor = popupPrimaryButtonDestructiveBackgroundColor;
        
        [self.leftButton setTitleColor:popupSecondaryButtonColor forState:UIControlStateNormal];
        self.leftButton.backgroundColor = popupSecondaryBackgroundColor;
    }
    else {
        //Default green theme
        [self.rightButton setTitleColor:popupPrimaryButtonSuccessColor forState:UIControlStateNormal];
        self.rightButton.backgroundColor = popupPrimaryButtonSuccessBackgroundColor;
        
        [self.leftButton setTitleColor:popupSecondaryButtonColor forState:UIControlStateNormal];
        self.leftButton.backgroundColor = popupSecondaryBackgroundColor;
    }
}

@end
