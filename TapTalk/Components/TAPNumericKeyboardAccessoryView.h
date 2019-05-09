//
//  TAPNumericKeyboardAccessoryView.h
//  Moselo
//
//  Created by Dominic Vedericho on 5/4/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

@interface TAPNumericKeyboardAccessoryView : TAPBaseView

@property (strong, nonatomic) UIView *headerKeyboardNumberView;
@property (strong, nonatomic) UIView *topSeparatorKeyboardView;
@property (strong, nonatomic) UIView *bottomSeparatorKeyboardView;
@property (strong, nonatomic) UIButton *doneKeyboardButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (void)setHeaderNumericKeyboardButtonTitleWithText:(NSString *)title;
- (void)setIsLoading:(BOOL)isLoading;

@end
