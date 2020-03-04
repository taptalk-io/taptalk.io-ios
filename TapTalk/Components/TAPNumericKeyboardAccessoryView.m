//
//  TAPNumericKeyboardAccessoryView.m
//  Moselo
//
//  Created by Dominic Vedericho on 5/4/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPNumericKeyboardAccessoryView.h"

@implementation TAPNumericKeyboardAccessoryView

#pragma mark - Lifecycle
-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _headerKeyboardNumberView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 44.0f)];
        self.headerKeyboardNumberView.backgroundColor = [UIColor whiteColor];
        self.headerKeyboardNumberView.clipsToBounds = YES;
        [self addSubview:self.headerKeyboardNumberView];
        
        _topSeparatorKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.headerKeyboardNumberView.frame), [TAPUtil lineMinimumHeight])];
        self.topSeparatorKeyboardView.backgroundColor = [TAPUtil getColor:@"8C8C8C"];
        [self.headerKeyboardNumberView addSubview:self.topSeparatorKeyboardView];
        
        _bottomSeparatorKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.headerKeyboardNumberView.frame) - [TAPUtil lineMinimumHeight], CGRectGetWidth(self.headerKeyboardNumberView.frame), [TAPUtil lineMinimumHeight])];
        self.bottomSeparatorKeyboardView.backgroundColor = [TAPUtil getColor:@"8C8C8C"];
        [self.headerKeyboardNumberView addSubview:self.bottomSeparatorKeyboardView];
        
        UIFont *keyboardFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontKeyboardAccessoryLabel];
        UIColor *keyboardColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorKeyboardAccessoryLabel];
        _doneKeyboardButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.headerKeyboardNumberView.frame) - 80.0f, 0.0f, 80.0f, 44.0f)];
        [self.doneKeyboardButton.titleLabel setFont:keyboardFont];
        [self.doneKeyboardButton setTitleColor:keyboardColor forState:UIControlStateNormal];
        [self.headerKeyboardNumberView addSubview:self.doneKeyboardButton];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.activityIndicator.center = self.doneKeyboardButton.center;
        [self.activityIndicator startAnimating];
        self.activityIndicator.alpha = 0.0f;
        [self.headerKeyboardNumberView addSubview:self.activityIndicator];

    }
    return self;
}

- (void)setHeaderNumericKeyboardButtonTitleWithText:(NSString *)title {
    [self.doneKeyboardButton setTitle:title forState:UIControlStateNormal];
}

- (void)setIsLoading:(BOOL)isLoading {
    if(isLoading) {
        self.doneKeyboardButton.alpha = 0.0f;
        self.activityIndicator.alpha = 1.0f;
    }
    else {
        self.doneKeyboardButton.alpha = 1.0f;
        self.activityIndicator.alpha = 0.0f;
    }
}

@end
