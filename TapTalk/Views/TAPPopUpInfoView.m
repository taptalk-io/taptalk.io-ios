//
//  TAPPopUpInfoView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 19/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPPopUpInfoView.h"
#import "PowerTalk.h"

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
        
        _popupWhiteView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(self.frame) - 32.0f, 0.0f)];
        self.popupWhiteView.layer.cornerRadius = 8.0f;
        self.popupWhiteView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f].CGColor;
        self.popupWhiteView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.popupWhiteView.layer.shadowOpacity = 0.4f;
        self.popupWhiteView.layer.shadowRadius = 4.0f;
        self.popupWhiteView.backgroundColor = [UIColor whiteColor];
        self.popupWhiteView.clipsToBounds = YES;
        [self addSubview:self.popupWhiteView];
        
        UIFont *popupTitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupDialogTitle];
        UIColor *popupTitleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogTitle];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, 16.0f, CGRectGetWidth(self.popupWhiteView.frame) - 48.0f, 0.0f)];
        self.titleLabel.font = popupTitleLabelFont;
        self.titleLabel.textColor = popupTitleLabelColor;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.popupWhiteView addSubview:self.titleLabel];
        
        UIFont *popupBodyLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupDialogBody];
        UIColor *popupBodyLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogBody];
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame) + 8.0f, CGRectGetWidth(self.titleLabel.frame), 0.0f)];
        self.detailLabel.numberOfLines = 0;
        self.detailLabel.font = popupBodyLabelFont;
        self.detailLabel.textColor = popupBodyLabelColor;
        self.detailLabel.textAlignment = NSTextAlignmentCenter;
        [self.popupWhiteView addSubview:self.detailLabel];
        
        CGFloat buttonWidth = (CGRectGetWidth(self.popupWhiteView.frame) / 2) - 24.0f - 4.0f;
        
        _rightButton = [[TapHighlightCustomButtonView alloc] initWithFrame:CGRectMake(
            CGRectGetWidth(self.popupWhiteView.frame) - buttonWidth - 24.0f,
            CGRectGetMaxY(self.detailLabel.frame) + 16.0f,
            buttonWidth,
            40.0f
        )];
        [self.rightButton setType:TapHighlightCustomButtonViewTypeDefaultGradient];
        self.rightButton.labelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupDialogButtonTextPrimary];
        self.rightButton.labelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogButtonTextPrimary];
        [self.popupWhiteView addSubview:self.rightButton];
        
        _leftButton = [[TapHighlightCustomButtonView alloc] initWithFrame:CGRectMake(
            CGRectGetMinX(self.rightButton.frame) - 8.0f - CGRectGetWidth(self.rightButton.frame),
            CGRectGetMinY(self.rightButton.frame),
            CGRectGetWidth(self.rightButton.frame),
            CGRectGetHeight(self.rightButton.frame)
        )];
        [self.leftButton setType:TapHighlightCustomButtonViewTypeSecondaryOrangeBorder];
        self.leftButton.labelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupDialogButtonTextSecondary];
        self.leftButton.labelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogButtonTextSecondary];
        [self.popupWhiteView addSubview:self.leftButton];
        
    }
    return self;
}

#pragma mark - Custom Method
- (void)resizeSubview {
    CGSize sizeDetail = [self.detailLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.detailLabel.frame), CGFLOAT_MAX)];
    CGSize sizeTitle = [self.titleLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.titleLabel.frame), CGFLOAT_MAX)];
    
    self.titleLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), sizeTitle.height);
    self.detailLabel.frame = CGRectMake(CGRectGetMinX(self.detailLabel.frame), CGRectGetMaxY(self.titleLabel.frame) + 8.0f, CGRectGetWidth(self.detailLabel.frame), sizeDetail.height);
    
    [self.rightButton resizeFrame:CGRectMake(CGRectGetMinX(self.rightButton.frame), CGRectGetMaxY(self.detailLabel.frame) + 16.0f, CGRectGetWidth(self.rightButton.frame), CGRectGetHeight(self.rightButton.frame))];
    
    [self.leftButton resizeFrame:CGRectMake(CGRectGetMinX(self.rightButton.frame) - 8.0f - CGRectGetWidth(self.rightButton.frame), CGRectGetMinY(self.rightButton.frame), CGRectGetWidth(self.leftButton.frame), CGRectGetHeight(self.leftButton.frame))];

    CGFloat popupInfoViewHeight = CGRectGetMaxY(self.rightButton.frame) + 16.0f;
    self.popupWhiteView.frame = CGRectMake(CGRectGetMinX(self.popupWhiteView.frame), (CGRectGetHeight(self.frame) - popupInfoViewHeight) / 2.0f, CGRectGetWidth(self.popupWhiteView.frame), popupInfoViewHeight);
}

- (void)isShowTwoOptionButton:(BOOL)isShow {
    if (isShow) {
        self.leftButton.button.userInteractionEnabled = YES;
        self.leftButton.alpha = 1.0f;
    }
    else {
        self.leftButton.button.userInteractionEnabled = NO;
        self.leftButton.alpha = 0.0f;
    }
}

- (void)setPopupInfoViewType:(TAPPopupInfoViewType)popupInfoViewType 
                   withTitle:(NSString *)title
           detailInformation:(NSString *)detailInfo
       leftOptionButtonTitle:(NSString *)leftOptionTitle
singleOrRightOptionButtonTitle:(NSString *)singleOrRightOptionTitle {
    
    _popupInfoViewType = popupInfoViewType;
    CGFloat buttonWidth = (CGRectGetWidth(self.popupWhiteView.frame) / 2) - 24.0f - 4.0f;
    [self.rightButton resizeFrame:CGRectMake(
        CGRectGetWidth(self.popupWhiteView.frame) - buttonWidth - 24.0f,
        CGRectGetMaxY(self.detailLabel.frame) + 16.0f,
        buttonWidth,
        40.0f
    )];
    
    if (self.popupInfoViewType == TAPPopupInfoViewTypeErrorMessage) {
        [self setPopupInfoViewThemeType:TAPPopupInfoViewThemeTypeDestructive];
        [self.rightButton resizeFrame:CGRectMake(
            24.0f,
            CGRectGetMaxY(self.detailLabel.frame) + 16.0f,
            CGRectGetWidth(self.popupWhiteView.frame) - 48.0f,
            CGRectGetHeight(self.rightButton.frame)
        )];
    }
    else if (self.popupInfoViewType == TAPPopupInfoViewTypeSuccessMessage) {
        [self setPopupInfoViewThemeType:TAPPopupInfoViewThemeTypeSuccess];
        [self.rightButton resizeFrame:CGRectMake(
            24.0f,
            CGRectGetMaxY(self.detailLabel.frame) + 16.0f,
            CGRectGetWidth(self.popupWhiteView.frame) - 48.0f,
            CGRectGetHeight(self.rightButton.frame)
        )];
    }
    else if (self.popupInfoViewType == TAPPopupInfoViewTypeInfoDefault) {
        [self setPopupInfoViewThemeType:TAPPopupInfoViewThemeTypeDefault];
    }
    else if (self.popupInfoViewType == TAPPopupInfoViewTypeInfoDestructive) {
        [self setPopupInfoViewThemeType:TAPPopupInfoViewThemeTypeDestructive];
    }
    
    self.titleLabel.text = title;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:detailInfo attributes:nil];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:self.detailLabel.font.pointSize * 0.25f];
    [style setAlignment:NSTextAlignmentCenter];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, [attributedString length])];
    self.detailLabel.attributedText = attributedString;
    
    [self.leftButton setLabelText:leftOptionTitle];
    [self.rightButton setLabelText:singleOrRightOptionTitle];
    
    [self resizeSubview];
}


- (void)setPopupInfoViewThemeType:(TAPPopupInfoViewThemeType)popupInfoViewThemeType {
    _popupInfoViewThemeType = popupInfoViewThemeType;
    if (self.popupInfoViewThemeType == TAPPopupInfoViewThemeTypeDestructive) {
        //Red theme
        [self.rightButton setType:TapHighlightCustomButtonViewTypeDestructive];
        [self.leftButton setType:TapHighlightCustomButtonViewTypeSecondaryOrangeBorder];
    }
    else if (self.popupInfoViewThemeType == TAPPopupInfoViewThemeTypeSuccess) {
        //Default green theme
        [self.rightButton setType:TapHighlightCustomButtonViewTypeSuccess];
        [self.leftButton setType:TapHighlightCustomButtonViewTypeSecondaryOrangeBorder];
    }
    else {
        //Default orange theme
        [self.rightButton setType:TapHighlightCustomButtonViewTypeDefaultGradient];
        [self.leftButton setType:TapHighlightCustomButtonViewTypeSecondaryOrangeBorder];
    }
}

@end
