//
//  TAPLoginView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPLoginView.h"
#import "TAPCountryModel.h"

@interface TAPLoginView () <TAPCustomButtonViewDelegate>

@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UILabel *welcomePlacholderLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;

@property (strong, nonatomic) UIView *countryPickerView;

@end

@implementation TAPLoginView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 100.0f, 132.0f, 22.0f)];
        self.logoImageView.image = [UIImage imageNamed:@"TAPIconTapTalkBoxLogo" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.logoImageView];
        
        _welcomePlacholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.logoImageView.frame) + 64.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 46.0f)];
        self.welcomePlacholderLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:40.0f];
        self.welcomePlacholderLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
        self.welcomePlacholderLabel.text = NSLocalizedString(@"Welcome", @"");
        [self addSubview:self.welcomePlacholderLabel];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.welcomePlacholderLabel.frame), CGRectGetMaxY(self.welcomePlacholderLabel.frame) + 8.0f, CGRectGetWidth(self.welcomePlacholderLabel.frame), 22.0f)];
        self.subtitleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_MEDIUM size:16.0f];
        self.subtitleLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
        self.subtitleLabel.text = NSLocalizedString(@"Enter your mobile number to continue", @"");
        [self addSubview:self.subtitleLabel];
        
        _phoneNumberPickerView = [[TAPCustomPhoneNumberPickerView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.subtitleLabel.frame) + 8.0f, CGRectGetWidth(self.frame), 50.0f)];
        [self.phoneNumberPickerView setCountryCodePhoneNumberWithData:[TAPCountryModel new]];
        [self addSubview:self.phoneNumberPickerView];
        
        _loginButton = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.phoneNumberPickerView.frame) + 24.0f, CGRectGetWidth(self.frame), 50.0f)];
        self.loginButton.delegate = self;
        [self.loginButton setCustomButtonViewType:TAPCustomButtonViewTypeInactive];
        [self.loginButton setButtonWithTitle:NSLocalizedString(@"Continue", @"")];
        [self addSubview:self.loginButton];
    }
    
    return self;
}

#pragma mark - Delegate
#pragma mark TAPCustomButtonView
- (void)customButtonViewDidTappedButton {
    if ([self.delegate respondsToSelector:@selector(loginViewDidTappedContinueButton)]) {
        [self.delegate loginViewDidTappedContinueButton];
    }
}

#pragma mark - Custom Method
- (void)setCountryCodeWithData:(TAPCountryModel *)countryData {
    [self.phoneNumberPickerView setCountryCodePhoneNumberWithData:countryData];
}

- (void)showLoadingFetchData:(BOOL)isLoading {
    if (isLoading) {
        [self.phoneNumberPickerView showLoading:YES animated:YES];
        [self setContinueButtonAsDisabled:YES animated:NO];
    }
    else {
        [self.phoneNumberPickerView showLoading:NO animated:YES];
    }
}

- (void)setContinueButtonAsDisabled:(BOOL)disabled animated:(BOOL)animated {
    if (disabled) {
        [self.loginButton setAsActiveState:NO animated:animated];
    }
    else {
        [self.loginButton setAsActiveState:YES animated:animated];
    }
}

- (void)setAsLoading:(BOOL)isLoading animated:(BOOL)animated {
    if (isLoading) {
        [self.phoneNumberPickerView setAsDisabled:YES];
        [self.loginButton setAsLoading:YES animated:animated];
    }
    else {
        [self.phoneNumberPickerView setAsDisabled:NO];
        [self.loginButton setAsLoading:NO animated:animated];
    }
}

@end
