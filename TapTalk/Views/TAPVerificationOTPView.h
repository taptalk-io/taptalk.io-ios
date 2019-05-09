//
//  TAPVerificationOTPView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPVerificationOTPView : TAPBaseView

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *resendVerificationButton;
@property (strong, nonatomic) UITextField *codeTextField;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) BOOL isLoading;

- (void)setVerificationInformationAsInvalidOTP:(BOOL)isInvalid;
- (void)setPhoneNumber:(NSString *)phoneNumber;
- (void)inputCodeWithUserInputData:(NSString *)userInputData;
- (void)showResendVerificationButton:(BOOL)show;
- (void)setResendVerificationLabelWithTimerMinutes:(NSInteger)minutes andSeconds:(NSInteger)seconds;
- (void)showLoading:(BOOL)isLoading animated:(BOOL)animated title:(NSString *)title;
- (void)showInputCodeAsFilled;
- (void)doneLoadingRequestingOTP;
- (void)showDoneResendOTP:(BOOL)isShow animated:(BOOL)animated;
- (void)removeLoadingSpinAnimation;

@end

NS_ASSUME_NONNULL_END
