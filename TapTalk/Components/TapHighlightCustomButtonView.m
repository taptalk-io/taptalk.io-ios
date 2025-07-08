//
//  HighlightCustomButtonView.m
//  OneTalk
//
//  Created by Kevin on 8/2/24.
//  Copyright © 2024 TapTalk.io. All rights reserved.
//

#import "TapHighlightCustomButtonView.h"

@implementation TapHighlightCustomButtonView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _containerViewLeftPadding = 12.0f;
        _containerViewRightPadding = 12.0f;
        _labelLetterSpacing = -0.5f;
        _leftIconSize = 20.0f;
        _rightIconSize = 20.0f;
        _leftIconMargin = 4.0f;
        _rightIconMargin = 4.0f;
        
        _buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(
            0.0f,
            0.0f,
            CGRectGetWidth(self.frame),
            CGRectGetHeight(self.frame)
        )];
        self.buttonContainerView.clipsToBounds = YES;
        [self addSubview:self.buttonContainerView];
        
        _buttonHighlightView = [[UIView alloc] initWithFrame:self.buttonContainerView.frame];
        self.buttonHighlightView.clipsToBounds = YES;
        self.buttonHighlightView.alpha = 0.0f;
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        [self addSubview:self.buttonHighlightView];
        
        [self setContainerViewBackgroundColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
//        [self setContainerViewBorderColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
//        [self setContainerViewBorderWidth:1.0f];
        [self setContainerViewRadius:8.0f];
        
        _leftButtonIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(
            CGRectGetWidth(self.frame) / 2,
            CGRectGetHeight(self.frame) / 2,
            0.0f,
            0.0f
        )];
        self.leftButtonIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.leftButtonIconImageView.alpha = 0.0f;
        [self addSubview:self.leftButtonIconImageView];
        

        _rightButtonIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(
            CGRectGetWidth(self.frame) / 2,
            CGRectGetHeight(self.frame) / 2,
            0.0f,
            0.0f
        )];
        self.rightButtonIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.rightButtonIconImageView.alpha = 0.0f;
        [self addSubview:self.rightButtonIconImageView];
        
        _buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(
            CGRectGetWidth(self.frame) / 2,
            CGRectGetHeight(self.frame) / 2,
            0.0f,
            0.0f
        )];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
        self.buttonLabel.numberOfLines = 1;
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:16.0f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight]];
        [self addSubview:self.buttonLabel];
        
        _button = [[UIButton alloc] initWithFrame:self.buttonContainerView.frame];
        [self.button addTarget:self action:@selector(buttonDidTouched) forControlEvents:UIControlEventTouchDown];
        [self.button addTarget:self action:@selector(buttonDidReleased) forControlEvents:UIControlEventTouchCancel];
        [self.button addTarget:self action:@selector(buttonDidReleased) forControlEvents:UIControlEventTouchDragExit];
        [self.button addTarget:self action:@selector(buttonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        self.button.backgroundColor = [UIColor clearColor];
        [self addSubview:self.button];
    }
    
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    UIView *superview = self.superview;
    while (superview) {
        if ([superview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *) superview).delaysContentTouches = NO;
            //((UIScrollView *) superview).canCancelContentTouches = YES;
            //((UIScrollView *) superview).multipleTouchEnabled = YES;
        }
        superview = superview.superview;
    }
}

#pragma mark - Custom Method

- (void)setType:(TapHighlightCustomButtonViewType)type {
    _type = type;
    if (self.type == TapHighlightCustomButtonViewTypeDefaultSolid) {
        [self setContainerViewRadius:8.0f];
        [self setContainerViewHorizontalPadding:12.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
        [self setContainerViewBorderWidth:0.0f];
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:16.0f]];
        [self setLabelLetterSpacing:-0.5f];
        [self setLeftIconSize:20.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:20.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (self.type == TapHighlightCustomButtonViewTypeSuccess) {
        [self setContainerViewRadius:8.0f];
        [self setContainerViewHorizontalPadding:12.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorSuccess]];
        [self setContainerViewBorderWidth:0.0f];
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:16.0f]];
        [self setLabelLetterSpacing:-0.5f];
        [self setLeftIconSize:20.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:20.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (self.type == TapHighlightCustomButtonViewTypeDestructive) {
        [self setContainerViewRadius:8.0f];
        [self setContainerViewHorizontalPadding:12.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError]];
        [self setContainerViewBorderWidth:0.0f];
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:16.0f]];
        [self setLabelLetterSpacing:-0.5f];
        [self setLeftIconSize:20.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:20.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (self.type == TapHighlightCustomButtonViewTypeSecondaryOrangeBorder) {
        [self setContainerViewRadius:8.0f];
        [self setContainerViewHorizontalPadding:12.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[UIColor clearColor]];
        [self setContainerViewBorderColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
        [self setContainerViewBorderWidth:1.0f];
        [self setHighlightColor:[[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary] colorWithAlphaComponent:0.18f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:16.0f]];
        [self setLabelLetterSpacing:-0.5f];
        [self setLeftIconSize:20.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:20.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (self.type == TapHighlightCustomButtonViewTypeSecondaryGrayBorder) {
        [self setContainerViewRadius:8.0f];
        [self setContainerViewHorizontalPadding:12.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[UIColor clearColor]];
        [self setContainerViewBorderColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.1f]];
        [self setContainerViewBorderWidth:1.0f];
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:16.0f]];
        [self setLabelLetterSpacing:-0.5f];
        [self setLeftIconSize:20.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:20.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (self.type == TapHighlightCustomButtonViewTypeLightOrange) {
        [self setContainerViewRadius:8.0f];
        [self setContainerViewHorizontalPadding:12.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimaryExtraLight]];
        [self setContainerViewBorderWidth:0.0f];
        [self setHighlightColor:[[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary] colorWithAlphaComponent:0.18f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:16.0f]];
        [self setLabelLetterSpacing:-0.5f];
        [self setLeftIconSize:20.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:20.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (self.type == TapHighlightCustomButtonViewTypeDisabled) {
        [self setContainerViewRadius:8.0f];
        [self setContainerViewHorizontalPadding:12.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.1f]];
        [self setContainerViewBorderWidth:0.0f];
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        [self setLabelColor:[[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark] colorWithAlphaComponent:0.4f]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:16.0f]];
        [self setLabelLetterSpacing:-0.5f];
        [self setLeftIconSize:20.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:20.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (self.type == TapHighlightCustomButtonViewTypeSmallSolidOrange) {
        [self setContainerViewRadius:4.0f];
        [self setContainerViewHorizontalPadding:16.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
        [self setContainerViewBorderWidth:0.0f];
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:12.0f]];
        [self setLabelLetterSpacing:-0.4f];
        [self setLeftIconSize:12.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:12.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (self.type == TapHighlightCustomButtonViewTypeSmallGrayBorder) {
        [self setContainerViewRadius:4.0f];
        [self setContainerViewHorizontalPadding:16.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[UIColor clearColor]];
        [self setContainerViewBorderColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.1f]];
        [self setContainerViewBorderWidth:1.0f];
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:12.0f]];
        [self setLabelLetterSpacing:-0.4f];
        [self setLeftIconSize:12.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:12.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (self.type == TapHighlightCustomButtonViewTypeSmallLightOrange) {
        [self setContainerViewRadius:4.0f];
        [self setContainerViewHorizontalPadding:8.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimaryExtraLight]];
        [self setContainerViewBorderWidth:0.0f];
        [self setHighlightColor:[[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary] colorWithAlphaComponent:0.18f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:12.0f]];
        [self setLabelLetterSpacing:-0.4f];
        [self setLeftIconSize:12.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:12.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
//    else if (self.type == TapHighlightCustomButtonViewTypeDisabled) {
//        [self setContainerViewRadius:4.0f];
//        [self setContainerViewHorizontalPadding:8.0f];
//        [self setContainerViewBackgroundGradient:nil];
//        [self setContainerViewBackgroundColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.1f]];
//        [self setContainerViewBorderWidth:0.0f];
//        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
//        [self setLabelColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.4f]];
//        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:12.0f]];
//        [self setLabelLetterSpacing:-0.4f];
//        [self setLeftIconSize:12.0f];
//        [self setLeftIconMargin:4.0f];
//        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
//    }
    else if (self.type == TapHighlightCustomButtonViewTypeFormFieldPicker) {
        [self setContainerViewRadius:8.0f];
        [self setContainerViewHorizontalPadding:16.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[UIColor clearColor]];
        [self setContainerViewBorderColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.1f]];
        [self setContainerViewBorderWidth:1.0f];
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.1f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular] fontWithSize:16.0f]];
        [self setLabelLetterSpacing:-0.3f];
        [self setLeftIconSize:24.0f];
        [self setLeftIconMargin:8.0f];
        [self setRightIconSize:24.0f];
        [self setRightIconMargin:8.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentLeft;
    }
    else if (self.type == TapHighlightCustomButtonViewTypeClear) {
        [self setContainerViewRadius:0.0f];
        [self setContainerViewHorizontalPadding:0.0f];
        [self setContainerViewBackgroundGradient:nil];
        [self setContainerViewBackgroundColor:[UIColor clearColor]];
        [self setContainerViewBorderWidth:0.0f];
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        [self setLabelColor:[UIColor clearColor]];
        [self setLabelFont:[UIFont fontWithName:TAP_FONT_FAMILY_BOLD size:0.0f]];
        [self setLeftIconSize:0.0f];
        [self setRightIconSize:0.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    else {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.buttonContainerView.bounds;
        gradient.colors = [NSArray arrayWithObjects:
            (id)[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimaryLight].CGColor,
            (id)[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary].CGColor,
            nil
        ];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self setContainerViewRadius:8.0f];
        [self setContainerViewHorizontalPadding:12.0f];
        [self setContainerViewBackgroundGradient:gradient];
        [self setContainerViewBackgroundColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
        [self setContainerViewBorderColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
        [self setContainerViewBorderWidth:1.0f];
        [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        [self setLabelColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight]];
        [self setLabelFont:[[[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold] fontWithSize:16.0f]];
        [self setLabelLetterSpacing:-0.5f];
        [self setLeftIconSize:20.0f];
        [self setLeftIconMargin:4.0f];
        [self setRightIconSize:20.0f];
        [self setRightIconMargin:4.0f];
        self.buttonLabel.textAlignment = NSTextAlignmentCenter;
    }
    [self setLeftIconImage:self.leftIconImage];
    [self setRightIconImage:self.rightIconImage];
}

- (void)setIsLoading:(BOOL)isLoading {
    _isLoading = isLoading;
    if (self.isLoading) {
        if (self.type == TapHighlightCustomButtonViewTypeFormFieldPicker) {
            // Form field picker loading
            [self setFieldPickerState:TapHighlightCustomButtonViewFieldPickerStateLoading];
        }
        else if (self.loadingStyle == TapHighlightCustomButtonViewLoadingStyleLeftLoadingIcon ||
            (self.loadingStyle != TapHighlightCustomButtonViewLoadingStyleCenterNoText &&
             self.rightButtonIconImageView.image == nil &&
             self.leftButtonIconImageView.image != nil)
        ) {
            // Left loading icon
            self.rightButtonIconImageView.image = nil;
            [self setImageView:self.leftButtonIconImageView image:[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] tintColor:self.leftIconTintColor];
            [TAPUtil addSpinAnimation:self.leftButtonIconImageView];
        }
        else if (self.loadingStyle == TapHighlightCustomButtonViewLoadingStyleRightLoadingIcon ||
            (self.loadingStyle != TapHighlightCustomButtonViewLoadingStyleCenterNoText &&
             self.leftButtonIconImageView.image == nil &&
             self.rightButtonIconImageView.image != nil)
        ) {
            // Right loading icon
            self.leftButtonIconImageView.image = nil;
            [self setImageView:self.rightButtonIconImageView image:[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] tintColor:self.rightIconTintColor];
            [TAPUtil addSpinAnimation:self.rightButtonIconImageView];
        }
        else {
            // Center loading icon
            self.buttonLabel.text = nil;
            if (self.leftButtonIconImageView.image == nil && self.rightButtonIconImageView.image != nil) {
                self.leftButtonIconImageView.image = nil;
                [self setImageView:self.rightButtonIconImageView image:[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] tintColor:self.rightIconTintColor];
                [TAPUtil addSpinAnimation:self.rightButtonIconImageView];
            }
            else {
                self.rightButtonIconImageView.image = nil;
                [self setImageView:self.leftButtonIconImageView image:[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] tintColor:self.leftIconTintColor];
                [TAPUtil addSpinAnimation:self.leftButtonIconImageView];
            }
        }
    }
    else {
        [TAPUtil removeSpinAnimation:self.leftButtonIconImageView];
        [TAPUtil removeSpinAnimation:self.rightButtonIconImageView];
        [self setLeftIconImage:self.leftIconImage];
        [self setRightIconImage:self.rightIconImage];
        [self setLabelText:self.labelText];
        if (self.type == TapHighlightCustomButtonViewTypeFormFieldPicker) {
            [self setFieldPickerState:TapHighlightCustomButtonViewFieldPickerStateDefault];
        }
    }
}

- (void)showLoadingImageView:(UIImageView *)imageView {
    if (self.type == TapHighlightCustomButtonViewTypeDisabled) {
        imageView.image = [[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] setImageTintColor:[TAPUtil getColor:TAP_COLOR_BLACK_19]];
        imageView.alpha = 0.4;
    }
    else {
        imageView.image = [[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] setImageTintColor:[UIColor whiteColor]];
        imageView.alpha = 1.0f;
    }
    [TAPUtil addSpinAnimation:imageView];
}

- (void)setFieldPickerState:(TapHighlightCustomButtonViewFieldPickerState)fieldPickerState {
    if (self.type != TapHighlightCustomButtonViewTypeFormFieldPicker) {
        return;
    }
    _fieldPickerState = fieldPickerState;
    if (fieldPickerState == TapHighlightCustomButtonViewFieldPickerStateDisabled) {
        _isLoading = NO;
        [self setContainerViewBackgroundColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.1f]];
        if (![TAPUtil isEmptyString:self.labelText]) {
            self.buttonLabel.alpha = 0.6f;
        }
        else {
            self.buttonLabel.alpha = 0.4f;
        }
        [self setRightIconImage:self.rightIconImage];
        [TAPUtil removeSpinAnimation:self.rightButtonIconImageView];
    }
    else if (fieldPickerState == TapHighlightCustomButtonViewFieldPickerStateLoading) {
        _isLoading = YES;
        [self setContainerViewBackgroundColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.1f]];
        if (![TAPUtil isEmptyString:self.labelText]) {
            self.buttonLabel.alpha = 0.6f;
        }
        else {
            self.buttonLabel.alpha = 0.4f;
        }
        [self setImageView:self.rightButtonIconImageView image:[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] tintColor:self.rightIconTintColor];
        [TAPUtil addSpinAnimation:self.rightButtonIconImageView];
    }
    else {
        _isLoading = NO;
        [self setContainerViewBackgroundColor:[UIColor clearColor]];
        if (![TAPUtil isEmptyString:self.labelText]) {
            self.buttonLabel.alpha = 1.0f;
        }
        else {
            self.buttonLabel.alpha = 0.4f;
        }
        [self setRightIconImage:self.rightIconImage];
        [TAPUtil removeSpinAnimation:self.rightButtonIconImageView];
    }
}

- (void)setIsShowingError:(BOOL)isShowingError {
    _isShowingError = isShowingError;
    if (isShowingError) {
        self.buttonContainerView.layer.borderColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError].CGColor;
    }
    else {
        [self setContainerViewBorderColor:self.containerViewBorderColor];
    }
}

- (void)resetIconImageView:(UIImageView *)imageView image:(UIImage *)image {
    if (self.type == TapHighlightCustomButtonViewTypeDisabled) {
        imageView.image = [image setImageTintColor:[TAPUtil getColor:TAP_COLOR_BLACK_19]];
        imageView.alpha = 0.4;
    }
    else {
        imageView.image = [image setImageTintColor:[UIColor whiteColor]];
        imageView.alpha = 1.0f;
    }
    [TAPUtil removeSpinAnimation:imageView];
}

- (void)setClickAction:(SEL)action target:(id)target {
    [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setContainerViewRadius:(CGFloat)radius {
    if (radius < 0.0f) {
        radius = 0.0f;
    }
    _containerViewRadius = radius;
    self.layer.cornerRadius = radius;
    self.buttonContainerView.layer.cornerRadius = radius;
    self.buttonHighlightView.layer.cornerRadius = radius;
}

- (void)setContainerViewBackgroundColor:(UIColor *)color {
    _containerViewBackgroundColor = color;
    self.buttonContainerView.backgroundColor = color;
}

- (void)setContainerViewBorderColor:(UIColor *)color width:(CGFloat)width {
    [self setContainerViewBorderColor:color];
    [self setContainerViewBorderWidth:width];
}

- (void)setContainerViewBorderColor:(UIColor *)color {
    _containerViewBorderColor = color;
    self.buttonContainerView.layer.borderColor = color.CGColor;
}

- (void)setContainerViewBorderWidth:(CGFloat)width {
    if (width < 0.0f) {
        width = 0.0f;
    }
    _containerViewBorderWidth = width;
    self.buttonContainerView.layer.borderWidth = width;
}

- (void)setContainerViewBackgroundGradient:(CAGradientLayer * _Nullable)gradient {
    _containerViewBackgroundGradient = gradient;
    [[self.buttonContainerView.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
    if (gradient != nil) {
        [TAPUtil performBlock:^{
            gradient.frame = self.buttonContainerView.bounds;
        } afterDelay:0.0f];
        [self.buttonContainerView.layer insertSublayer:gradient atIndex:0];
    }
    [self.buttonContainerView setNeedsDisplay];
}

- (void)setHighlightColor:(UIColor *)color {
    _highlightColor = color;
    self.buttonHighlightView.backgroundColor = color;
}

- (void)setContainerViewLeftPadding:(CGFloat)leftPadding {
    if (leftPadding < 0.0f) {
        leftPadding = 0.0f;
    }
    _containerViewLeftPadding = leftPadding;
    [self resizeContentViews];
}

- (void)setContainerViewRightPadding:(CGFloat)rightPadding {
    if (rightPadding < 0.0f) {
        rightPadding = 0.0f;
    }
    _containerViewRightPadding = rightPadding;
    [self resizeContentViews];
}

- (void)setContainerViewHorizontalPadding:(CGFloat)horizontalPadding {
    if (horizontalPadding < 0.0f) {
        horizontalPadding = 0.0f;
    }
    _containerViewLeftPadding = horizontalPadding;
    _containerViewRightPadding = horizontalPadding;
    [self resizeContentViews];
}

- (void)setLabelText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    [self setLabelText:text];
    [self setLabelFont:font];
    [self setLabelColor:color];
    [self resizeContentViews];
}

- (void)setLabelText:(NSString *)text {
    _labelText = text;
    if (![TAPUtil isEmptyString:text]) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{
            NSKernAttributeName:@(self.labelLetterSpacing),
        }];
        if (self.isLoading ||
            self.fieldPickerState == TapHighlightCustomButtonViewFieldPickerStateLoading ||
            self.fieldPickerState == TapHighlightCustomButtonViewFieldPickerStateDisabled
        ) {
            self.buttonLabel.alpha = 0.6f;
        }
        else {
            self.buttonLabel.alpha = 1.0f;
        }
        self.buttonLabel.attributedText = attributedText;
    }
    else {
        if (self.type == TapHighlightCustomButtonViewTypeFormFieldPicker && ![TAPUtil isEmptyString:self.fieldPickerPlaceholder]) {
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.fieldPickerPlaceholder attributes:@{
                NSKernAttributeName:@(self.labelLetterSpacing),
            }];
            if (self.isLoading ||
                self.fieldPickerState == TapHighlightCustomButtonViewFieldPickerStateLoading ||
                self.fieldPickerState == TapHighlightCustomButtonViewFieldPickerStateDisabled
            ) {
                self.buttonLabel.alpha = 0.4f;
            }
            else {
                self.buttonLabel.alpha = 0.4f;
            }
            self.buttonLabel.attributedText = attributedText;
        }
        else {
            self.buttonLabel.text = text;
        }
    }
    [self resizeContentViews];
}

- (void)setLabelFont:(UIFont *)font {
    _labelFont = font;
    self.buttonLabel.font = font;
    [self resizeContentViews];
}

- (void)setLabelColor:(UIColor *)color {
    _labelColor = color;
    self.buttonLabel.textColor = color;
}

- (void)setLabelLetterSpacing:(CGFloat)labelLetterSpacing {
    _labelLetterSpacing = labelLetterSpacing;
    [self setLabelText:self.labelText];
}

- (void)setFieldPickerPlaceholder:(NSString *)fieldPickerPlaceholder {
    _fieldPickerPlaceholder = fieldPickerPlaceholder;
    [self setLabelText:self.labelText];
}

- (void)setLeftIconImage:(UIImage * _Nullable)image size:(CGFloat)size margin:(CGFloat)margin {
    [self setLeftIconImage:image];
    [self setLeftIconSize:size];
    [self setLeftIconMargin:margin];
}

- (void)setLeftIconImage:(UIImage * _Nullable)image {
    _leftIconImage = image;
    [self setImageView:self.leftButtonIconImageView image:image tintColor:self.leftIconTintColor];
}

- (void)setLeftIconTintColor:(UIColor *)leftIconTintColor {
    _leftIconTintColor = leftIconTintColor;
    [self setLeftIconImage:self.leftIconImage];
}

- (void)setLeftIconSize:(CGFloat)size {
    if (size < 0.0f) {
        size = 0.0f;
    }
    _leftIconSize = size;
    if (size <= 0.0f) {
        self.leftButtonIconImageView.image = nil;
        self.leftButtonIconImageView.alpha = 0.0f;
        [self resizeContentViews];
    }
    else {
        [self setLeftIconImage:self.leftIconImage];
    }
}

- (void)setLeftIconMargin:(CGFloat)margin {
    if (margin < 0.0f) {
        margin = 0.0f;
    }
    _leftIconMargin = margin;
    [self resizeContentViews];
}

- (void)setRightIconImage:(UIImage * _Nullable)image size:(CGFloat)size margin:(CGFloat)margin {
    [self setRightIconImage:image];
    [self setRightIconSize:size];
    [self setRightIconMargin:margin];
}

- (void)setRightIconImage:(UIImage * _Nullable)image {
    _rightIconImage = image;
    [self setImageView:self.rightButtonIconImageView image:image tintColor:self.rightIconTintColor];
}

- (void)setRightIconTintColor:(UIColor * _Nullable)rightIconTintColor {
    _rightIconTintColor = rightIconTintColor;
    [self setRightIconImage:self.rightIconImage];
}

- (void)setRightIconSize:(CGFloat)size {
    if (size < 0.0f) {
        size = 0.0f;
    }
    _rightIconSize = size;
    if (size <= 0.0f) {
        self.rightButtonIconImageView.image = nil;
        self.rightButtonIconImageView.alpha = 0.0f;
        [self resizeContentViews];
    }
    else {
        [self setRightIconImage:self.rightIconImage];
    }
}

- (void)setRightIconMargin:(CGFloat)margin {
    if (margin < 0.0f) {
        margin = 0.0f;
    }
    _rightIconMargin = margin;
    [self resizeContentViews];
}

- (void)setImageView:(UIImageView *)imageView image:(UIImage * _Nullable)image tintColor:(UIColor * _Nullable)tintColor {
    if (image != nil) {
        if (tintColor != nil) {
            imageView.image = [image setImageTintColor:tintColor];
            imageView.alpha = 1.0f;
        }
        else if (self.type == TapHighlightCustomButtonViewTypeFormFieldPicker) {
            if (imageView == self.rightButtonIconImageView) {
                if (self.isLoading || self.fieldPickerState == TapHighlightCustomButtonViewFieldPickerStateLoading) {
                    imageView.image = [image setImageTintColor:[TAPUtil getColor:TAP_COLOR_BLACK_19]];
                    imageView.alpha = 0.4f;
                }
                else if (self.fieldPickerState == TapHighlightCustomButtonViewFieldPickerStateDisabled) {
                    imageView.image = [image setImageTintColor:[TAPUtil getColor:TAP_COLOR_BLACK_19]];
                    imageView.alpha = 0.6f;
                }
                else {
                    imageView.image = [image setImageTintColor:[TAPUtil getColor:TAP_COLOR_BLACK_19]];
                    imageView.alpha = 1.0f;
                }
            }
            else {
                imageView.image = image;
                imageView.alpha = 1.0f;
            }
        }
        else if (self.type == TapHighlightCustomButtonViewTypeSecondaryOrangeBorder) {
            imageView.image = [image setImageTintColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
            imageView.alpha = 1.0f;
        }
        else if (self.type == TapHighlightCustomButtonViewTypeSecondaryGrayBorder ||
                 self.type == TapHighlightCustomButtonViewTypeLightOrange ||
                 self.type == TapHighlightCustomButtonViewTypeSmallLightOrange
        ) {
            imageView.image = [image setImageTintColor:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary]];
            imageView.alpha = 1.0f;
        }
        else if (self.type == TapHighlightCustomButtonViewTypeDisabled ||
                 self.type == TapHighlightCustomButtonViewTypeSmallDisabled
        ) {
            imageView.image = [image setImageTintColor:[TAPUtil getColor:TAP_COLOR_BLACK_19]];
            imageView.alpha = 0.4f;
        }
        else if (self.type == TapHighlightCustomButtonViewTypeSmallGrayBorder) {
            imageView.image = [image setImageTintColor:[TAPUtil getColor:TAP_COLOR_BLACK_19]];
            imageView.alpha = 1.0f;
        }
        else {
            imageView.image = [image setImageTintColor:[UIColor whiteColor]];
            imageView.alpha = 1.0f;
        }
    }
    else {
        imageView.image = nil;
        imageView.alpha = 0.0f;
    }
    [self resizeContentViews];
}

- (void)trimButtonFrame:(TapHighlightCustomButtonViewTrimDirection)direction {
    CGSize buttonLabelSize = [self.buttonLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat buttonWidth = self.containerViewLeftPadding + self.containerViewRightPadding + buttonLabelSize.width;
    if (self.leftButtonIconImageView.image != nil && self.leftButtonIconImageView.alpha > 0.0f) {
        buttonWidth += CGRectGetWidth(self.leftButtonIconImageView.frame) + self.leftIconMargin;
    }
    if (self.rightButtonIconImageView.image != nil && self.rightButtonIconImageView.alpha > 0.0f) {
        buttonWidth += CGRectGetWidth(self.rightButtonIconImageView.frame) + self.rightIconMargin;
    }
    CGFloat minX = 0.0f;
    if (direction == TapHighlightCustomButtonViewTrimDirectionCenter) {
        minX = (CGRectGetWidth(self.frame) - buttonWidth) / 2;
    }
    else if (direction == TapHighlightCustomButtonViewTrimDirectionRight) {
        minX = (CGRectGetWidth(self.frame) - buttonWidth);
    }
    
    [self resizeFrame:CGRectMake(
        CGRectGetMinX(self.frame) + minX,
        CGRectGetMinY(self.frame),
        buttonWidth,
        CGRectGetHeight(self.frame)
    )];
    
}

- (void)resizeFrame:(CGRect)frame {
    self.frame = frame;
    self.buttonContainerView.frame = CGRectMake(
        0.0f,
        0.0f,
        CGRectGetWidth(self.frame),
        CGRectGetHeight(self.frame)
    );
    self.buttonHighlightView.frame = self.buttonContainerView.frame;
    self.button.frame = self.buttonContainerView.frame;
    [self resizeContentViews];
}

- (void)resizeContentViews {
    CGFloat animationDuration = 0.0f;
    if (self.isInitialLayoutCompleted) {
        animationDuration = 0.2f;
    }
    [UIView animateWithDuration:0.0f animations:^{
        if (self.type != TapHighlightCustomButtonViewTypeFormFieldPicker &&
            ([TAPUtil isEmptyString:self.buttonLabel.text] || self.buttonLabel.alpha == 0.0f)
        ) {
            // No text
            self.buttonLabel.frame = CGRectMake(
                CGRectGetWidth(self.frame) / 2,
                CGRectGetHeight(self.frame) / 2,
                0.0f,
                0.0f
            );
            // Centered icon
            if (self.leftButtonIconImageView.image != nil && self.leftButtonIconImageView.alpha > 0.0f) {
                self.leftButtonIconImageView.frame = CGRectMake(
                    (CGRectGetWidth(self.frame) - self.leftIconSize) / 2,
                    (CGRectGetHeight(self.frame) - self.leftIconSize) / 2,
                    self.leftIconSize,
                    self.leftIconSize
                );
            }
            else {
                self.leftButtonIconImageView.frame = CGRectMake(
                    CGRectGetWidth(self.frame) / 2,
                    CGRectGetHeight(self.frame) / 2,
                    0.0f,
                    0.0f
                );
            }
            if (self.rightButtonIconImageView.image != nil && self.rightButtonIconImageView.alpha > 0.0f) {
                self.rightButtonIconImageView.frame = CGRectMake(
                    (CGRectGetWidth(self.frame) - self.rightIconSize) / 2,
                    (CGRectGetHeight(self.frame) - self.rightIconSize) / 2,
                    self.rightIconSize,
                    self.rightIconSize
                );
            }
            else {
                self.rightButtonIconImageView.frame = CGRectMake(
                    CGRectGetWidth(self.frame) / 2,
                    CGRectGetHeight(self.frame) / 2,
                    0.0f,
                    0.0f
                );
            }
        }
        else {
            // With text
            if (self.type == TapHighlightCustomButtonViewTypeFormFieldPicker && [TAPUtil isEmptyString:self.labelText]) {
                if (self.isLoading ||
                    self.fieldPickerState == TapHighlightCustomButtonViewFieldPickerStateLoading ||
                    self.fieldPickerState == TapHighlightCustomButtonViewFieldPickerStateDisabled
                ) {
                    self.buttonLabel.alpha = 0.4f;
                }
                else {
                    self.buttonLabel.alpha = 0.4f;
                }
            }
            CGSize labelSize = [self.buttonLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
            CGFloat maxContentWidth = CGRectGetWidth(self.frame) - self.containerViewLeftPadding - self.containerViewRightPadding;
            CGFloat maxLabelWidth = maxContentWidth;
            if (self.leftButtonIconImageView.image != nil) {
                maxLabelWidth = maxLabelWidth - self.leftIconSize - self.leftIconMargin;
            }
            if (self.rightButtonIconImageView.image != nil) {
                maxLabelWidth = maxLabelWidth - self.rightIconSize - self.rightIconMargin;
            }
            if (self.type == TapHighlightCustomButtonViewTypeFormFieldPicker || labelSize.width > maxLabelWidth) {
                labelSize.width = maxLabelWidth;
            }
            else if (labelSize.width < 0.0f) {
                labelSize.width = 0.0f;
            }
            if (labelSize.height > CGRectGetHeight(self.frame)) {
                labelSize.height = CGRectGetHeight(self.frame);
            }
            CGFloat contentWidth = labelSize.width;
            if (self.leftButtonIconImageView.image != nil) {
                contentWidth = contentWidth + self.leftIconSize + self.leftIconMargin;
            }
            if (self.rightButtonIconImageView.image != nil) {
                contentWidth = contentWidth + self.rightIconSize + self.rightIconMargin;
            }
            
            CGFloat leftIconX = ((CGRectGetWidth(self.frame) - contentWidth) / 2);
            if (self.containerViewLeftPadding != self.containerViewRightPadding) {
                leftIconX = leftIconX - ((self.containerViewRightPadding - self.containerViewLeftPadding) / 2);
            }
            if (leftIconX < self.containerViewLeftPadding) {
                leftIconX = self.containerViewLeftPadding;
            }
            if (self.leftButtonIconImageView.image != nil && self.leftButtonIconImageView.alpha > 0.0f) {
                // Show left icon
                self.leftButtonIconImageView.frame = CGRectMake(
                    leftIconX,
                    (CGRectGetHeight(self.frame) - self.leftIconSize) / 2,
                    self.leftIconSize,
                    self.leftIconSize
                );
            }
            else {
                // Hide left icon
                self.leftButtonIconImageView.frame = CGRectMake(
                    leftIconX - self.leftIconMargin,
                    CGRectGetHeight(self.frame) / 2,
                    0.0f,
                    0.0f
                );
            }
            self.buttonLabel.frame = CGRectMake(
                CGRectGetMaxX(self.leftButtonIconImageView.frame) + self.leftIconMargin,
                (CGRectGetHeight(self.frame) - labelSize.height) / 2,
                labelSize.width,
                labelSize.height
            );
            CGFloat rightIconX = CGRectGetMaxX(self.buttonLabel.frame) + self.rightIconMargin;
//            CGFloat rightIconX = ((CGRectGetWidth(self.frame) + contentWidth) / 2) - self.rightIconSize;
            if (rightIconX > (CGRectGetWidth(self.frame) - self.rightIconSize - self.containerViewRightPadding)) {
                rightIconX = (CGRectGetWidth(self.frame) - self.rightIconSize - self.containerViewRightPadding);
            }
            if (self.rightButtonIconImageView.image != nil && self.rightButtonIconImageView.alpha > 0.0f) {
                // Show right icon
                self.rightButtonIconImageView.frame = CGRectMake(
                    rightIconX,
                    (CGRectGetHeight(self.frame) - self.rightIconSize) / 2,
                    self.rightIconSize,
                    self.rightIconSize
                );
            }
            else {
                // Hide right icon
                self.rightButtonIconImageView.frame = CGRectMake(
                    rightIconX + self.rightIconMargin,
                    CGRectGetHeight(self.frame) / 2,
                    0.0f,
                    0.0f
                );
            }
        }
        self->_isInitialLayoutCompleted = YES;
    }];
}

- (void)buttonDidTouched {
    [UIView animateWithDuration:0.1f animations:^{
        self.buttonHighlightView.alpha = 1.0f;
//        if (self.type == TapHighlightCustomButtonViewTypeFormFieldPicker &&
//            !self.isShowingError &&
//            !self.isLoading
//        ) {
//            self.buttonContainerView.layer.borderColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary].CGColor;
//        }
    }];
}

- (void)buttonDidReleased {
    [UIView animateWithDuration:0.1f animations:^{
        self.buttonHighlightView.alpha = 0.0f;
//        if (self.type == TapHighlightCustomButtonViewTypeFormFieldPicker &&
//            !self.isShowingError &&
//            !self.isLoading
//        ) {
//            [self setContainerViewBorderColor:self.containerViewBorderColor];
//        }
    }];
}

- (void)buttonDidTapped {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(highlightCustomButtonViewDidTappedWithIdentifier:)]) {
        [self.delegate highlightCustomButtonViewDidTappedWithIdentifier:self.buttonIdentifier];
    }
    [self buttonDidReleased];
}

@end
