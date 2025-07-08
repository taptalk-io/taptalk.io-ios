//
//  HighlightCustomButtonView.h
//  OneTalk
//
//  Created by Kevin on 8/2/24.
//  Copyright © 2024 TapTalk.io. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TapHighlightCustomButtonViewType) {
    TapHighlightCustomButtonViewTypeDefaultGradient = 0,
    TapHighlightCustomButtonViewTypeDefaultSolid = 1,
    TapHighlightCustomButtonViewTypeSuccess = 2,
    TapHighlightCustomButtonViewTypeDestructive = 3,
    TapHighlightCustomButtonViewTypeSecondaryOrangeBorder = 4,
    TapHighlightCustomButtonViewTypeSecondaryGrayBorder = 5,
    TapHighlightCustomButtonViewTypeLightOrange = 6,
    TapHighlightCustomButtonViewTypeDisabled = 7,
    TapHighlightCustomButtonViewTypeSmallSolidOrange = 8,
    TapHighlightCustomButtonViewTypeSmallGrayBorder = 9,
    TapHighlightCustomButtonViewTypeSmallLightOrange = 10,
    TapHighlightCustomButtonViewTypeSmallDisabled = 11,
    TapHighlightCustomButtonViewTypeFormFieldPicker = 12,
    TapHighlightCustomButtonViewTypeClear = -1,
};

typedef NS_ENUM(NSInteger, TapHighlightCustomButtonViewLoadingStyle) {
    TapHighlightCustomButtonViewLoadingStyleDefault = 0,
    TapHighlightCustomButtonViewLoadingStyleCenterNoText = 1,
    TapHighlightCustomButtonViewLoadingStyleLeftLoadingIcon = 2,
    TapHighlightCustomButtonViewLoadingStyleRightLoadingIcon = 3,
};

typedef NS_ENUM(NSInteger, TapHighlightCustomButtonViewTrimDirection) {
    TapHighlightCustomButtonViewTrimDirectionCenter = 0,
    TapHighlightCustomButtonViewTrimDirectionLeft = 1,
    TapHighlightCustomButtonViewTrimDirectionRight = 2,
};

typedef NS_ENUM(NSInteger, TapHighlightCustomButtonViewFieldPickerState) {
    TapHighlightCustomButtonViewFieldPickerStateDefault = 0,
    TapHighlightCustomButtonViewFieldPickerStateDisabled = 1,
    TapHighlightCustomButtonViewFieldPickerStateLoading = 2,
};

@protocol TapHighlightCustomButtonViewDelegate <NSObject>

@optional

- (void)highlightCustomButtonViewDidTappedWithIdentifier:(NSString *)buttonIdentifier;

@end

@interface TapHighlightCustomButtonView : UIView

#pragma mark - Properties
@property (weak, nonatomic) id <TapHighlightCustomButtonViewDelegate> delegate;
@property (strong, nonatomic) NSString *buttonIdentifier;
@property (strong, nonatomic) NSString *fieldPickerPlaceholder;
@property (nonatomic) TapHighlightCustomButtonViewType type;
@property (nonatomic) TapHighlightCustomButtonViewLoadingStyle loadingStyle;
@property (nonatomic) TapHighlightCustomButtonViewFieldPickerState fieldPickerState;
@property (nonatomic) BOOL isInitialLayoutCompleted;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isShowingError;

#pragma mark - Views
@property (strong, nonatomic) UIView *buttonContainerView;
@property (strong, nonatomic) UIView *buttonHighlightView;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UILabel *buttonLabel;
@property (strong, nonatomic) UIImageView *leftButtonIconImageView;
@property (strong, nonatomic) UIImageView *rightButtonIconImageView;

#pragma mark - Container View
@property (nonatomic) CGFloat containerViewRadius;
@property (nonatomic) CGFloat containerViewBorderWidth;
@property (nonatomic) CGFloat containerViewLeftPadding;
@property (nonatomic) CGFloat containerViewRightPadding;
@property (strong, nonatomic) UIColor *containerViewBackgroundColor;
@property (strong, nonatomic) UIColor *containerViewBorderColor;
@property (strong, nonatomic) UIColor *highlightColor;
@property (strong, nonatomic) CAGradientLayer * _Nullable containerViewBackgroundGradient;

#pragma mark - Label
@property (strong, nonatomic) NSString *labelText;
@property (strong, nonatomic) UIFont *labelFont;
@property (strong, nonatomic) UIColor *labelColor;
@property (nonatomic) CGFloat labelLetterSpacing;

#pragma mark - Left Icon
@property (nonatomic) CGFloat leftIconSize;
@property (nonatomic) CGFloat leftIconMargin;
@property (strong, nonatomic) UIImage * _Nullable leftIconImage;
@property (strong, nonatomic) UIColor * _Nullable leftIconTintColor;

#pragma mark - Right Icon
@property (nonatomic) CGFloat rightIconSize;
@property (nonatomic) CGFloat rightIconMargin;
@property (strong, nonatomic) UIImage * _Nullable rightIconImage;
@property (strong, nonatomic) UIColor * _Nullable rightIconTintColor;

#pragma mark - Custom Methods
- (void)setClickAction:(SEL)action target:(id)target;
- (void)setContainerViewBorderColor:(UIColor *)color width:(CGFloat)width;
- (void)setContainerViewHorizontalPadding:(CGFloat)horizontalPadding;
- (void)setLabelText:(NSString *)text font:(UIFont *)font color:(UIColor *)color;
- (void)setLeftIconImage:(UIImage * _Nullable)image size:(CGFloat)size margin:(CGFloat)margin;
- (void)setRightIconImage:(UIImage * _Nullable)image size:(CGFloat)size margin:(CGFloat)margin;
- (void)trimButtonFrame:(TapHighlightCustomButtonViewTrimDirection)direction;
- (void)resizeFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
