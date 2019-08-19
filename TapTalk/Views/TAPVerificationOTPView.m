//
//  TAPVerificationOTPView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPVerificationOTPView.h"

@interface TAPVerificationOTPView ()

@property (strong, nonatomic) UIImageView *backImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *phoneNumberLabel;

@property (strong, nonatomic) UIView *codeContainerView;
@property (strong, nonatomic) UIView *firstCodeSeparatorView;
@property (strong, nonatomic) UIView *secondCodeSeparatorView;
@property (strong, nonatomic) UIView *thirdCodeSeparatorView;
@property (strong, nonatomic) UIView *fourthCodeSeparatorView;
@property (strong, nonatomic) UIView *fifthCodeSeparatorView;
@property (strong, nonatomic) UIView *sixthCodeSeparatorView;
@property (strong, nonatomic) UIView *firstCodeFilledView;
@property (strong, nonatomic) UIView *secondCodeFilledView;
@property (strong, nonatomic) UIView *thirdCodeFilledView;
@property (strong, nonatomic) UIView *fourthCodeFilledView;
@property (strong, nonatomic) UIView *fifthCodeFilledView;
@property (strong, nonatomic) UIView *sixthCodeFilledView;

@property (strong, nonatomic) UILabel *verificationInformationLabel;
@property (strong, nonatomic) UILabel *counterResendLabel;

@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UILabel *loadingInfoLabel;
@property (strong, nonatomic) UIImageView *loadingImageView;

@property (strong, nonatomic) UIView *doneResendOTPView;
@property (strong, nonatomic) UILabel *doneResendOTPLabel;
@property (strong, nonatomic) UIImageView *doneResendOTPImageView;

@end

@implementation TAPVerificationOTPView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        CGFloat currentStatusBarHeight = [TAPUtil currentDeviceStatusBarHeight];
        
        _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0f, currentStatusBarHeight + 12.0f, 24.0f, 35.0f)];
        self.backImageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
        self.backImageView.image = buttonImage;
        [self addSubview:self.backImageView];
        
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, currentStatusBarHeight, 45.0f, 45.0f)];
        [self addSubview:self.backButton];

        UIFont *titleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLoginVerificationInfoLabel];
        UIColor *titleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLoginVerificationInfoLabel];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, currentStatusBarHeight + 165.0f, CGRectGetWidth(self.frame) - 50.0f - 50.0f, 20.0f)];
        self.titleLabel.font = titleLabelFont;
        self.titleLabel.textColor = titleLabelColor;
        self.titleLabel.text = NSLocalizedString(@"Enter the 6 digit OTP we’ve sent to", @"");
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];

        
        UIFont *phoneNumberFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLoginVerificationPhoneNumberLabel];
        UIColor *phoneNumberColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLoginVerificationPhoneNumberLabel];
        _phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), 24.0f)];
        self.phoneNumberLabel.font = phoneNumberFont;
        self.phoneNumberLabel.textColor = phoneNumberColor;
        self.phoneNumberLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.phoneNumberLabel];
        
        CGFloat innerGap = 25.0f;
        CGFloat totalInnerGap = 5 * 25.0f;
        CGFloat codeWidth = 24.0f;
        CGFloat totalCodeWidth = 6 * 24.0f;
        CGFloat minXPosition = (CGRectGetWidth(self.frame) - totalInnerGap - totalCodeWidth) / 2.0f;
        
        _codeContainerView = [[UIView alloc] initWithFrame:CGRectMake(minXPosition, CGRectGetMaxY(self.phoneNumberLabel.frame) + 32.0f, CGRectGetWidth(self.frame) - minXPosition - minXPosition, 24.0f)];
        self.codeContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.codeContainerView];
        
        _codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.codeContainerView.frame), CGRectGetHeight(self.codeContainerView.frame))];
        self.codeTextField.backgroundColor = [UIColor clearColor];
        self.codeTextField.textColor = [UIColor clearColor];
        self.codeTextField.tintColor = [UIColor clearColor];
        self.codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        [self.codeContainerView addSubview:self.codeTextField];
        
        _firstCodeSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 22.0f, codeWidth, 2.0f)];
        self.firstCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        [self.codeContainerView addSubview:self.firstCodeSeparatorView];
        
        _secondCodeSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.firstCodeSeparatorView.frame) + innerGap, CGRectGetMinY(self.firstCodeSeparatorView.frame), CGRectGetWidth(self.firstCodeSeparatorView.frame), CGRectGetHeight(self.firstCodeSeparatorView.frame))];
        self.secondCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        [self.codeContainerView addSubview:self.secondCodeSeparatorView];
        
        _thirdCodeSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.secondCodeSeparatorView.frame) + innerGap, CGRectGetMinY(self.firstCodeSeparatorView.frame), CGRectGetWidth(self.firstCodeSeparatorView.frame), CGRectGetHeight(self.firstCodeSeparatorView.frame))];
        self.thirdCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        [self.codeContainerView addSubview:self.thirdCodeSeparatorView];
        
        _fourthCodeSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thirdCodeSeparatorView.frame) + innerGap, CGRectGetMinY(self.firstCodeSeparatorView.frame), CGRectGetWidth(self.firstCodeSeparatorView.frame), CGRectGetHeight(self.firstCodeSeparatorView.frame))];
        self.fourthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        [self.codeContainerView addSubview:self.fourthCodeSeparatorView];
        
        _fifthCodeSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.fourthCodeSeparatorView.frame) + innerGap, CGRectGetMinY(self.firstCodeSeparatorView.frame), CGRectGetWidth(self.firstCodeSeparatorView.frame), CGRectGetHeight(self.firstCodeSeparatorView.frame))];
        self.fifthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        [self.codeContainerView addSubview:self.fifthCodeSeparatorView];
        
        _sixthCodeSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.fifthCodeSeparatorView.frame) + innerGap, CGRectGetMinY(self.firstCodeSeparatorView.frame), CGRectGetWidth(self.firstCodeSeparatorView.frame), CGRectGetHeight(self.firstCodeSeparatorView.frame))];
        self.sixthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        [self.codeContainerView addSubview:self.sixthCodeSeparatorView];
        
        _firstCodeFilledView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, codeWidth, codeWidth)];
        self.firstCodeFilledView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.firstCodeFilledView.layer.cornerRadius = CGRectGetHeight(self.firstCodeFilledView.frame) / 2.0f;
        self.firstCodeFilledView.clipsToBounds = YES;
        self.firstCodeFilledView.alpha = 0.0f;
        [self.codeContainerView addSubview:self.firstCodeFilledView];
        
        _secondCodeFilledView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.firstCodeFilledView.frame) + innerGap, CGRectGetMinY(self.firstCodeFilledView.frame), CGRectGetWidth(self.firstCodeFilledView.frame), CGRectGetHeight(self.firstCodeFilledView.frame))];
        self.secondCodeFilledView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.secondCodeFilledView.layer.cornerRadius = CGRectGetHeight(self.secondCodeFilledView.frame) / 2.0f;
        self.secondCodeFilledView.clipsToBounds = YES;
        self.secondCodeFilledView.alpha = 0.0f;
        [self.codeContainerView addSubview:self.secondCodeFilledView];
        
        _thirdCodeFilledView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.secondCodeFilledView.frame) + innerGap, CGRectGetMinY(self.firstCodeFilledView.frame), CGRectGetWidth(self.firstCodeFilledView.frame), CGRectGetHeight(self.firstCodeFilledView.frame))];
        self.thirdCodeFilledView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.thirdCodeFilledView.layer.cornerRadius = CGRectGetHeight(self.thirdCodeFilledView.frame) / 2.0f;
        self.thirdCodeFilledView.clipsToBounds = YES;
        self.thirdCodeFilledView.alpha = 0.0f;
        [self.codeContainerView addSubview:self.thirdCodeFilledView];
        
        _fourthCodeFilledView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thirdCodeFilledView.frame) + innerGap, CGRectGetMinY(self.firstCodeFilledView.frame), CGRectGetWidth(self.firstCodeFilledView.frame), CGRectGetHeight(self.firstCodeFilledView.frame))];
        self.fourthCodeFilledView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fourthCodeFilledView.layer.cornerRadius = CGRectGetHeight(self.fourthCodeFilledView.frame) / 2.0f;
        self.fourthCodeFilledView.clipsToBounds = YES;
        self.fourthCodeFilledView.alpha = 0.0f;
        [self.codeContainerView addSubview:self.fourthCodeFilledView];
        
        _fifthCodeFilledView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.fourthCodeFilledView.frame) + innerGap, CGRectGetMinY(self.firstCodeFilledView.frame), CGRectGetWidth(self.firstCodeFilledView.frame), CGRectGetHeight(self.firstCodeFilledView.frame))];
        self.fifthCodeFilledView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fifthCodeFilledView.layer.cornerRadius = CGRectGetHeight(self.fifthCodeFilledView.frame) / 2.0f;
        self.fifthCodeFilledView.clipsToBounds = YES;
        self.fifthCodeFilledView.alpha = 0.0f;
        [self.codeContainerView addSubview:self.fifthCodeFilledView];
        
        _sixthCodeFilledView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.fifthCodeFilledView.frame) + innerGap, CGRectGetMinY(self.firstCodeFilledView.frame), CGRectGetWidth(self.firstCodeFilledView.frame), CGRectGetHeight(self.firstCodeFilledView.frame))];
        self.sixthCodeFilledView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.sixthCodeFilledView.layer.cornerRadius = CGRectGetHeight(self.sixthCodeFilledView.frame) / 2.0f;
        self.sixthCodeFilledView.clipsToBounds = YES;
        self.sixthCodeFilledView.alpha = 0.0f;
        [self.codeContainerView addSubview:self.sixthCodeFilledView];
        
        UIFont *infoLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelBody];
        UIColor *infoLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelBody];
        _verificationInformationLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.codeContainerView.frame) + 34.0f, CGRectGetWidth(self.titleLabel.frame), 20.0f)];
        self.verificationInformationLabel.font = infoLabelFont;
        self.verificationInformationLabel.textColor = infoLabelColor;
        self.verificationInformationLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.verificationInformationLabel];

        UIFont *countdownLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLoginVerificationStatusCountdownLabel];
        UIColor *countdownLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLoginVerificationStatusCountdownLabel];
        _counterResendLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.verificationInformationLabel.frame) + 8.0f, CGRectGetWidth(self.titleLabel.frame), 50.0f)];
        self.counterResendLabel.font = countdownLabelFont;
        self.counterResendLabel.textColor = countdownLabelColor;
        self.counterResendLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.counterResendLabel];

        UIFont *clickableLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableLabel];
        UIColor *clickableLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableLabel];
        _resendVerificationButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.verificationInformationLabel.frame) + 8.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 50.0f)];
        self.resendVerificationButton.alpha = 0.0f;
        self.resendVerificationButton.userInteractionEnabled = NO;
        [self.resendVerificationButton setTitle:NSLocalizedString(@"Request Again", @"") forState:UIControlStateNormal];
        self.resendVerificationButton.titleLabel.font = clickableLabelFont;
        [self.resendVerificationButton setTitleColor:clickableLabelColor forState:UIControlStateNormal];
        self.resendVerificationButton.backgroundColor = [UIColor clearColor];
        [self addSubview:self.resendVerificationButton];
        
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(16.0f,CGRectGetMaxY(self.verificationInformationLabel.frame) + 22.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 22.0f)];
        self.loadingView.alpha = 0.0f;
        [self addSubview:self.loadingView];
        
        _loadingInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 22.0f)];
        self.loadingInfoLabel.font = clickableLabelFont;
        self.loadingInfoLabel.textColor = clickableLabelColor;
        [self.loadingView addSubview:self.loadingInfoLabel];
        
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.loadingInfoLabel.frame) + 8.0f, 1.0f, 20.0f, 20.0f)];
        [self.loadingImageView setImage:[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        self.loadingImageView.image = [self.loadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
        [self.loadingView addSubview:self.loadingImageView];
        
        _doneResendOTPView = [[UIView alloc] initWithFrame:CGRectMake(16.0f,CGRectGetMaxY(self.verificationInformationLabel.frame) + 22.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 22.0f)];
        self.doneResendOTPView.alpha = 0.0f;
        [self addSubview:self.doneResendOTPView];
        
        UIFont *verificationSuccessLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLoginVerificationStatusSuccessLabel];
        UIColor *verificationSuccessLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLoginVerificationStatusSuccessLabel];
        _doneResendOTPLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 22.0f)];
        self.doneResendOTPLabel.font = verificationSuccessLabelFont;
        self.doneResendOTPLabel.textColor = verificationSuccessLabelColor;
        self.doneResendOTPLabel.text = NSLocalizedString(@"OTP Successfully Sent", @"");
        [self.doneResendOTPView addSubview:self.doneResendOTPLabel];
        
        _doneResendOTPImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.doneResendOTPLabel.frame) + 8.0f, 1.0f, 20.0f, 20.0f)];
        [self.doneResendOTPImageView setImage:[UIImage imageNamed:@"TAPIconSuccessSent" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        [self.doneResendOTPView addSubview:self.doneResendOTPImageView];
    }
 
    return self;
}

#pragma mark - Custom Method

- (void)setVerificationInformationAsInvalidOTP:(BOOL)isInvalid {
    if (isInvalid) {
        self.verificationInformationLabel.textColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError];
        self.verificationInformationLabel.text = NSLocalizedString(@"Invalid OTP, please try again", @"");
    }
    else {
        self.verificationInformationLabel.textColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.verificationInformationLabel.text = NSLocalizedString(@"Didn’t receive the 6 digit OTP?", @"");
    }
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    self.phoneNumberLabel.text = phoneNumber;
}

- (void)inputCodeWithUserInputData:(NSString *)userInputData {
    if(userInputData.length == 0) {
        
        self.firstCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
        self.secondCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.thirdCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fourthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fifthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.sixthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];

        self.firstCodeSeparatorView.alpha = 1.0f;
        self.secondCodeSeparatorView.alpha = 1.0f;
        self.thirdCodeSeparatorView.alpha = 1.0f;
        self.fourthCodeSeparatorView.alpha = 1.0f;
        self.fifthCodeSeparatorView.alpha = 1.0f;
        self.sixthCodeSeparatorView.alpha = 1.0f;
        
        self.firstCodeFilledView.alpha = 0.0f;
        self.secondCodeFilledView.alpha = 0.0f;
        self.thirdCodeFilledView.alpha = 0.0f;
        self.fourthCodeFilledView.alpha = 0.0f;
        self.fifthCodeFilledView.alpha = 0.0f;
        self.sixthCodeFilledView.alpha = 0.0f;
    }
    else if(userInputData.length == 1) {

        self.firstCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.secondCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
        self.thirdCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fourthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fifthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.sixthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        
        self.thirdCodeSeparatorView.alpha = 1.0f;
        self.fourthCodeSeparatorView.alpha = 1.0f;
        self.fifthCodeSeparatorView.alpha = 1.0f;
        self.sixthCodeSeparatorView.alpha = 1.0f;

        self.thirdCodeFilledView.alpha = 0.0f;
        self.fourthCodeFilledView.alpha = 0.0f;
        self.fifthCodeFilledView.alpha = 0.0f;
        self.sixthCodeFilledView.alpha = 0.0f;
 
       self.firstCodeSeparatorView.alpha = 0.0f;
        
        [UIView animateWithDuration:0.2f animations:^{
            self.firstCodeFilledView.alpha = 1.0f;
            
            self.secondCodeSeparatorView.alpha = 1.0f;
            self.secondCodeFilledView.alpha = 0.0f;
        }];
    }
    else if(userInputData.length == 2) {
        self.firstCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.secondCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.thirdCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
        self.fourthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fifthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.sixthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        
        self.firstCodeSeparatorView.alpha = 0.0f;
   
        self.firstCodeFilledView.alpha = 1.0f;

        self.fourthCodeSeparatorView.alpha = 1.0f;
        self.fifthCodeSeparatorView.alpha = 1.0f;
        self.sixthCodeSeparatorView.alpha = 1.0f;

        self.fourthCodeFilledView.alpha = 0.0f;
        self.fifthCodeFilledView.alpha = 0.0f;
        self.sixthCodeFilledView.alpha = 0.0f;

        self.secondCodeSeparatorView.alpha = 0.0f;

        [UIView animateWithDuration:0.2f animations:^{
            self.secondCodeFilledView.alpha = 1.0f;
            
            self.thirdCodeSeparatorView.alpha = 1.0f;
            self.thirdCodeFilledView.alpha = 0.0f;
        }];
    }
    else if(userInputData.length == 3) {
        self.firstCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.secondCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.thirdCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fourthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
        self.fifthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.sixthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        
        self.firstCodeSeparatorView.alpha = 0.0f;
        self.secondCodeSeparatorView.alpha = 0.0f;
        
        self.firstCodeFilledView.alpha = 1.0f;
        self.secondCodeFilledView.alpha = 1.0f;
        
        self.fifthCodeSeparatorView.alpha = 1.0f;
        self.sixthCodeSeparatorView.alpha = 1.0f;

        self.fifthCodeFilledView.alpha = 0.0f;
        self.sixthCodeFilledView.alpha = 0.0f;

        self.thirdCodeSeparatorView.alpha = 0.0f;

        [UIView animateWithDuration:0.2f animations:^{
            self.thirdCodeFilledView.alpha = 1.0f;
            
            self.fourthCodeSeparatorView.alpha = 1.0f;
            self.fourthCodeFilledView.alpha = 0.0f;
        }];
    }
    else if(userInputData.length == 4) {
        self.firstCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.secondCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.thirdCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fourthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fifthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
        self.sixthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        
        self.firstCodeSeparatorView.alpha = 0.0f;
        self.secondCodeSeparatorView.alpha = 0.0f;
        self.thirdCodeSeparatorView.alpha = 0.0f;
        
        self.firstCodeFilledView.alpha = 1.0f;
        self.secondCodeFilledView.alpha = 1.0f;
        self.thirdCodeFilledView.alpha = 1.0f;

        self.sixthCodeSeparatorView.alpha = 1.0f;
        self.sixthCodeFilledView.alpha = 0.0f;
        
        self.fourthCodeSeparatorView.alpha = 0.0f;
        
        [UIView animateWithDuration:0.2f animations:^{
            self.fourthCodeFilledView.alpha = 1.0f;
            
            self.fifthCodeSeparatorView.alpha = 1.0f;
            self.fifthCodeFilledView.alpha = 0.0f;
        }];
    }
    else if(userInputData.length == 5) {
        
        self.firstCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.secondCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.thirdCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fourthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fifthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.sixthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
        
        self.firstCodeSeparatorView.alpha = 0.0f;
        self.secondCodeSeparatorView.alpha = 0.0f;
        self.thirdCodeSeparatorView.alpha = 0.0f;
        self.fourthCodeSeparatorView.alpha = 0.0f;
        
        self.firstCodeFilledView.alpha = 1.0f;
        self.secondCodeFilledView.alpha = 1.0f;
        self.thirdCodeFilledView.alpha = 1.0f;
        self.fourthCodeFilledView.alpha = 1.0f;

        self.fifthCodeSeparatorView.alpha = 0.0f;

        [UIView animateWithDuration:0.2f animations:^{
            self.fifthCodeFilledView.alpha = 1.0f;

            self.sixthCodeSeparatorView.alpha = 1.0f;
            self.sixthCodeFilledView.alpha = 0.0f;
        }];
    }
    else if(userInputData.length == 6) {
        self.firstCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.secondCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.thirdCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fourthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.fifthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        self.sixthCodeSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPTextColorLoginVerificationCodeInputLabel];
        
        self.firstCodeSeparatorView.alpha = 0.0f;
        self.secondCodeSeparatorView.alpha = 0.0f;
        self.thirdCodeSeparatorView.alpha = 0.0f;
        self.fourthCodeSeparatorView.alpha = 0.0f;
        self.fifthCodeSeparatorView.alpha = 0.0f;
        self.sixthCodeSeparatorView.alpha = 0.0f;
        
        self.firstCodeFilledView.alpha = 1.0f;
        self.secondCodeFilledView.alpha = 1.0f;
        self.thirdCodeFilledView.alpha = 1.0f;
        self.fourthCodeFilledView.alpha = 1.0f;
        self.fifthCodeFilledView.alpha = 1.0f;
        
        [UIView animateWithDuration:0.2f animations:^{
            self.sixthCodeFilledView.alpha = 1.0f;
        }];
    }
}

- (void)showInputCodeAsFilled {
    self.firstCodeSeparatorView.alpha = 0.0f;
    self.secondCodeSeparatorView.alpha = 0.0f;
    self.thirdCodeSeparatorView.alpha = 0.0f;
    self.fourthCodeSeparatorView.alpha = 0.0f;
    self.fifthCodeSeparatorView.alpha = 0.0f;
    self.sixthCodeSeparatorView.alpha = 0.0f;
    
    self.firstCodeFilledView.alpha = 1.0f;
    self.secondCodeFilledView.alpha = 1.0f;
    self.thirdCodeFilledView.alpha = 1.0f;
    self.fourthCodeFilledView.alpha = 1.0f;
    self.fifthCodeFilledView.alpha = 1.0f;
    self.sixthCodeFilledView.alpha = 1.0f;
}

- (void)showResendVerificationButton:(BOOL)show {
    if (show) {
        [UIView animateWithDuration:0.2f animations:^{
            self.counterResendLabel.alpha = 0.0f;
            self.resendVerificationButton.alpha = 1.0f;
        }completion:^(BOOL finished) {
            self.resendVerificationButton.userInteractionEnabled = YES;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.counterResendLabel.alpha = 1.0f;
            self.resendVerificationButton.alpha = 0.0f;
        }completion:^(BOOL finished) {
            self.resendVerificationButton.userInteractionEnabled = NO;
        }];
    }
}

- (void)setResendVerificationLabelWithTimerMinutes:(NSInteger)minutes andSeconds:(NSInteger)seconds {
    
    NSString *tempString;
    if(minutes == 0) {
        if(seconds == 0) {
            if(!self.isLoading) {
                [self showResendVerificationButton:YES];
            }
        }
        else if(seconds > 0 && seconds < 10) {
            tempString = [NSString stringWithFormat:@"Wait 0:0%ld", seconds];
        }
        else {
            tempString = [NSString stringWithFormat:@"Wait 0:%ld", seconds];
        }
    }
    else {
        tempString = [NSString stringWithFormat:@"Wait %ld:%ld", minutes, seconds];
    }
    
    self.counterResendLabel.text = tempString;
}

- (void)doneLoadingRequestingOTP {
    _isLoading = NO;
    self.loadingView.alpha = 0.0f;
    self.doneResendOTPView.alpha = 0.0f;
    self.counterResendLabel.alpha = 1.0f;
    self.resendVerificationButton.alpha = 0.0f;
    self.resendVerificationButton.userInteractionEnabled = NO;
}

- (void)showLoading:(BOOL)isLoading animated:(BOOL)animated title:(NSString *)title {
    
    _isLoading = isLoading;
    
    self.loadingInfoLabel.text = title;
    
    CGSize loadingInfoLabelSize = [self.loadingInfoLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.loadingInfoLabel.frame))];
    CGFloat totalSize = loadingInfoLabelSize.width + 8.0f + CGRectGetWidth(self.loadingImageView.frame);
    self.loadingInfoLabel.frame = CGRectMake(0.0f, 0.0f, loadingInfoLabelSize.width, CGRectGetHeight(self.loadingInfoLabel.frame));
    self.loadingImageView.frame = CGRectMake(CGRectGetMaxX(self.loadingInfoLabel.frame) + 8.0f, CGRectGetMinY(self.loadingImageView.frame), CGRectGetWidth(self.loadingImageView.frame), CGRectGetHeight(self.loadingImageView.frame));
    self.loadingView.frame = CGRectMake((CGRectGetWidth([UIScreen mainScreen].bounds) - totalSize) / 2.0f, CGRectGetMinY(self.loadingView.frame), totalSize, CGRectGetHeight(self.loadingView.frame));
    
    if (isLoading) {
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^{
                self.loadingView.alpha = 1.0f;
                self.counterResendLabel.alpha = 0.0f;
                self.resendVerificationButton.alpha = 0.0f;
                self.resendVerificationButton.userInteractionEnabled = NO;
                self.doneResendOTPView.alpha = 0.0f;
            }];
            
            //ADD ANIMATION
            if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] == nil) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                animation.fromValue = [NSNumber numberWithFloat:0.0f];
                animation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
                animation.duration = 1.5f;
                animation.repeatCount = INFINITY;
                animation.cumulative = YES;
                animation.removedOnCompletion = NO;
                [self.loadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
            }
        }
        else {
            self.loadingView.alpha = 1.0f;
            self.counterResendLabel.alpha = 0.0f;
            self.resendVerificationButton.alpha = 0.0f;
            self.resendVerificationButton.userInteractionEnabled = NO;
            self.doneResendOTPView.alpha = 0.0f;

            //ADD ANIMATION
            if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] == nil) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                animation.fromValue = [NSNumber numberWithFloat:0.0f];
                animation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
                animation.duration = 1.5f;
                animation.repeatCount = INFINITY;
                animation.cumulative = YES;
                animation.removedOnCompletion = NO;
                [self.loadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
            }
        }
    }
    else {
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^{
                self.loadingView.alpha = 0.0f;
                self.doneResendOTPView.alpha = 0.0f;
                [self showResendVerificationButton:YES];
                [self.timer invalidate];
            }];
            
            //REMOVE ANIMATION
            if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                [self.loadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
            }
        }
        else {
            self.loadingView.alpha = 0.0f;
            self.doneResendOTPView.alpha = 0.0f;
            [self showResendVerificationButton:YES];
            [self.timer invalidate];
            
            //REMOVE ANIMATION
            if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                [self.loadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
            }
        }
    }
}

- (void)removeLoadingSpinAnimation {
    if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
        [self.loadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
    }
    [self.loadingImageView.layer removeAllAnimations];
}

- (void)showDoneResendOTP:(BOOL)isShow animated:(BOOL)animated {
    
    CGSize doneResendOTPLabelSize = [self.doneResendOTPLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.doneResendOTPLabel.frame))];
    CGFloat totalSize = doneResendOTPLabelSize.width + 8.0f + CGRectGetWidth(self.doneResendOTPImageView.frame);
    self.doneResendOTPLabel.frame = CGRectMake(0.0f, 0.0f, doneResendOTPLabelSize.width, CGRectGetHeight(self.doneResendOTPLabel.frame));
    self.doneResendOTPImageView.frame = CGRectMake(CGRectGetMaxX(self.doneResendOTPLabel.frame) + 8.0f, CGRectGetMinY(self.doneResendOTPImageView.frame), CGRectGetWidth(self.doneResendOTPImageView.frame), CGRectGetHeight(self.doneResendOTPImageView.frame));
    self.doneResendOTPView.frame = CGRectMake((CGRectGetWidth([UIScreen mainScreen].bounds) - totalSize) / 2.0f, CGRectGetMinY(self.doneResendOTPView.frame), totalSize, CGRectGetHeight(self.doneResendOTPView.frame));
    
    if (isShow) {
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^{
                self.doneResendOTPView.alpha = 1.0f;
                self.counterResendLabel.alpha = 0.0f;
                self.resendVerificationButton.alpha = 0.0f;
                self.resendVerificationButton.userInteractionEnabled = NO;
                self.loadingView.alpha = 0.0f;
            }];
        }
        else {
            self.doneResendOTPView.alpha = 1.0f;
            self.counterResendLabel.alpha = 0.0f;
            self.resendVerificationButton.alpha = 0.0f;
            self.resendVerificationButton.userInteractionEnabled = NO;
            self.loadingView.alpha = 0.0f;
        }
    }
    else {
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^{
                self.loadingImageView.alpha = 0.0f;
                self.doneResendOTPView.alpha = 0.0f;
                [self showResendVerificationButton:NO];
            }];
        }
        else {
            self.loadingImageView.alpha = 0.0f;
            self.doneResendOTPView.alpha = 0.0f;
            [self showResendVerificationButton:NO];
        }
    }
}


@end
