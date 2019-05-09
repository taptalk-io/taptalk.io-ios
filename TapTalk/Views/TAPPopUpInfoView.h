//
//  TAPPopUpInfoView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 19/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

typedef NS_ENUM(NSInteger, TAPPopupInfoViewType) {
    TAPPopupInfoViewTypeErrorMessage, // 1 button red
    TAPPopupInfoViewTypeSuccessMessage, // 1 button green
    TAPPopupInfoViewTypeInfoDefault, // 2 button (grey, green)
    TAPPopupInfoViewTypeInfoDestructive,// 2 button (grey, red)
};

typedef NS_ENUM(NSInteger, TAPPopupInfoViewThemeType) {
    TAPPopupInfoViewThemeTypeDefault, //Green theme
    TAPPopupInfoViewThemeTypeDestructive //Red theme
};

NS_ASSUME_NONNULL_BEGIN

@interface TAPPopUpInfoView : TAPBaseView

@property (nonatomic) TAPPopupInfoViewType popupInfoViewType;
@property (nonatomic) TAPPopupInfoViewThemeType popupInfoViewThemeType;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;

- (void)isShowTwoOptionButton:(BOOL)isShow;
- (void)setPopupInfoViewType:(TAPPopupInfoViewType)popupInfoViewType withTitle:(NSString *)title detailInformation:(NSString *)detailInfo leftOptionButtonTitle:(NSString *)leftOptionTitle singleOrRightOptionButtonTitle:(NSString *)singleOrRightOptionTitle;
- (void)setPopupInfoViewThemeType:(TAPPopupInfoViewThemeType)popupInfoViewThemeType;

@end

NS_ASSUME_NONNULL_END
