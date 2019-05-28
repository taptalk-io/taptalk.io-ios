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
        self.popupWhiteView.layer.shadowColor = [TAPUtil getColor:@"D9D9D9"].CGColor;
        self.popupWhiteView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.popupWhiteView.layer.shadowOpacity = 0.4f;
        self.popupWhiteView.layer.shadowRadius = 4.0f;
        self.popupWhiteView.backgroundColor = [UIColor whiteColor];
        self.popupWhiteView.clipsToBounds = YES;
        [self addSubview:self.popupWhiteView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 16.0f, CGRectGetWidth(self.popupWhiteView.frame) - 16.0f - 16.0f, 22.0f)];
        self.titleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:17.0f];
        self.titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        [self.popupWhiteView addSubview:self.titleLabel];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame) + 4.0f, CGRectGetWidth(self.titleLabel.frame), 0.0f)];
        self.detailLabel.numberOfLines = 0;
        self.detailLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:13.0f];
        self.detailLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        [self.popupWhiteView addSubview:self.detailLabel];
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.popupWhiteView.frame) - 85.0f - 16.0f, CGRectGetMaxY(self.detailLabel.frame) + 16.0f, 85.0f, 40.0f)];
        self.rightButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:10.0f];
        self.rightButton.layer.cornerRadius = 4.0f;
        self.rightButton.titleLabel.textColor = [UIColor whiteColor];
        self.rightButton.backgroundColor = [TAPUtil getColor:TAP_COLOR_PRIMARY_COLOR_1];
        [self.popupWhiteView addSubview:self.rightButton];
        
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.rightButton.frame) - 6.0f - 85.0f, CGRectGetMinY(self.rightButton.frame), CGRectGetWidth(self.rightButton.frame), CGRectGetHeight(self.rightButton.frame))];
        self.leftButton.layer.cornerRadius = 4.0f;
        self.leftButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:10.0f];
        self.leftButton.titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_PRIMARY_COLOR_1];
        self.leftButton.backgroundColor = [UIColor whiteColor];
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
    _popupInfoViewThemeType = popupInfoViewThemeType;
    if (self.popupInfoViewThemeType == TAPPopupInfoViewThemeTypeDestructive) {
        //Red theme
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rightButton.backgroundColor = [TAPUtil getColor:TAP_COLOR_CORALPINK_6A];
        
        [self.leftButton setTitleColor:[TAPUtil getColor:TAP_COLOR_GREY_9B] forState:UIControlStateNormal];
        self.leftButton.backgroundColor = [UIColor whiteColor];
    }
    else {
        //Default green theme
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rightButton.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREEN_2A];
        
        [self.leftButton setTitleColor:[TAPUtil getColor:TAP_COLOR_GREY_9B] forState:UIControlStateNormal];
        self.leftButton.backgroundColor = [UIColor whiteColor];

    }
}

@end
