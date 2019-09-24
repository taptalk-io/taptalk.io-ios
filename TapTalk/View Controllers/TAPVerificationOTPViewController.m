//
//  TAPVerificationOTPViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPVerificationOTPViewController.h"
#import "TAPVerificationOTPView.h"
#import "TAPRegisterViewController.h"

#define TAP_VERIFICATION_CODE_MAX_LENGTH 6

@interface TAPVerificationOTPViewController () <UITextFieldDelegate>

@property (strong, nonatomic) TAPVerificationOTPView *verificationOTPView;

@property (nonatomic) BOOL isLoading;
@property (nonatomic) NSInteger currentMinute;
@property (nonatomic) NSInteger currentSeconds;

- (void)backButtonDidTapped;
- (void)resendVerificationButtonDidTapped;
- (void)startTimer;
- (void)timerFired;
- (void)submitWithVerificationCode:(NSString *)verificationCode;

@end

@implementation TAPVerificationOTPViewController

- (void)loadView {
    [super loadView];
    _verificationOTPView = [[TAPVerificationOTPView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.view addSubview:self.verificationOTPView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.verificationOTPView.codeTextField.delegate = self;
    
    [self.verificationOTPView.backButton addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.verificationOTPView.resendVerificationButton addTarget:self action:@selector(resendVerificationButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.verificationOTPView setVerificationInformationAsInvalidOTP:NO];
    [self.verificationOTPView setPhoneNumber:self.phoneNumberWithCountryCode];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.verificationOTPView.timer invalidate];
    [self.verificationOTPView inputCodeWithUserInputData:@""];
    self.verificationOTPView.codeTextField.text = @"";
    [self.verificationOTPView showResendVerificationButton:NO];
    
    if (self.isNeedShowLoadingRequestingOTP) {
        [self.verificationOTPView showLoading:YES animated:NO title:NSLocalizedString(@"Requesting OTP", @"")];
    }
    
    NSDictionary *phoneDictionary = [[NSUserDefaults standardUserDefaults] secureDictionaryForKey:TAP_PREFS_USER_LOGIN_PHONE_TEMP_DICTIONARY valid:nil];
    NSInteger expireTime = [[phoneDictionary objectForKey:@"expireTime"] integerValue];
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    
    if(expireTime > timeInterval) {
        NSInteger secondsLeft = expireTime - (NSInteger)timeInterval;
        NSInteger minute = (NSInteger)((floor)(secondsLeft/60.0f));
        NSInteger secondsRemain = secondsLeft % 60;
        _currentMinute = minute;
        _currentSeconds = secondsRemain;
    }
    else {
        _currentMinute = 0;
        _currentSeconds = 00;
        [self.verificationOTPView showResendVerificationButton:YES];
    }
  [self startTimer];
    
    [self.verificationOTPView.codeTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.verificationOTPView removeLoadingSpinAnimation];
    _isNeedShowLoadingRequestingOTP = NO;
}

#pragma mark - Delegate
#pragma mark UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(self.isLoading) {
        return NO;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (newString.length > TAP_VERIFICATION_CODE_MAX_LENGTH && range.length == 0) {
        return NO;
    }
    
    [self.verificationOTPView inputCodeWithUserInputData:newString];
    
    if(newString.length == 6) {
        //Done input code, verify code
        [self.verificationOTPView showInputCodeAsFilled];
        [self submitWithVerificationCode:newString];
    }

    return YES;
}

#pragma mark - Custom Method
- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:popupIdentifier];
}

- (void)backButtonDidTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resendVerificationButtonDidTapped {
    [self.verificationOTPView.timer invalidate];
    [self.verificationOTPView setVerificationInformationAsInvalidOTP:NO];
    [self.verificationOTPView inputCodeWithUserInputData:@""];
    self.verificationOTPView.codeTextField.text = @"";
    
    [self.verificationOTPView showLoading:YES animated:NO title:NSLocalizedString(@"Requesting OTP", @"")];
    
    [TAPDataManager callAPIRequestVerificationCodeWithPhoneNumber:self.phoneNumber countryID:self.countryID method:@"phone" success:^(NSString *OTPKey, NSString *OTPID, NSString *successMessage) {
        [self.verificationOTPView showLoading:NO animated:NO title:@""];

        _currentMinute = 0;
        _currentSeconds = 30;
        [self startTimer];
        
        [self.verificationOTPView showDoneResendOTP:YES animated:YES];
        
        [TAPUtil performBlock:^{

            [self.verificationOTPView showDoneResendOTP:NO animated:NO];
            
            _OTPKey = OTPKey;
            _OTPID = OTPID;
            
            NSMutableDictionary *phoneDictionary = [NSMutableDictionary dictionary];
            [phoneDictionary setObject:self.phoneNumberWithCountryCode forKey:@"phone"];
            
            NSDate *date = [NSDate date];
            NSTimeInterval timeInterval = [date timeIntervalSince1970];
            NSInteger expireTime = timeInterval + 30;
            
            [phoneDictionary setObject:[NSString stringWithFormat:@"%ld", (long)expireTime] forKey:@"expireTime"];
            
            [[NSUserDefaults standardUserDefaults] setSecureObject:phoneDictionary forKey:TAP_PREFS_USER_LOGIN_PHONE_TEMP_DICTIONARY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } afterDelay:2.0f];
        
    } failure:^(NSError *error) {
        [self.verificationOTPView showLoading:NO animated:NO title:@""];
        [self.verificationOTPView showDoneResendOTP:NO animated:NO];
    }];
}

- (void)startTimer {
    self.verificationOTPView.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

- (void)timerFired {
    if((self.currentMinute > 0 || self.currentSeconds >= 0) && self.currentMinute >= 0) {
        if(self.currentSeconds == 0) {
            self.currentMinute -= 1;
            self.currentSeconds = 59;
        }
        else if(self.currentSeconds > 0) {
            self.currentSeconds -= 1;
        }
        
        if(self.currentMinute > -1 || (self.currentMinute == 0 && self.currentSeconds == 0)) {
            [self.verificationOTPView setResendVerificationLabelWithTimerMinutes:self.currentMinute andSeconds:self.currentSeconds];
            if (self.verificationOTPView.isLoading) {
                [self.verificationOTPView doneLoadingRequestingOTP];
            }
        }
    }
    else {
        if(!self.isLoading) {
            //Checking if is loading finished show ResendButton
            [self.verificationOTPView showResendVerificationButton:YES];
        }
        else {
            //Checking if is loading finished hide ResendButton
            [self.verificationOTPView showResendVerificationButton:NO];
        }
        
        [self.verificationOTPView.timer invalidate];
    }
}

- (void)submitWithVerificationCode:(NSString *)verificationCode {
    _isLoading = YES;
    [self.verificationOTPView.timer invalidate];
    [self.verificationOTPView removeLoadingSpinAnimation];
    [self.verificationOTPView showLoading:YES animated:NO title:NSLocalizedString(@"Verifying OTP", @"")];
    
    [TAPDataManager callAPIVerifyOTPWithCode:verificationCode OTPID:self.OTPID OTPKey:self.OTPKey success:^(BOOL isRegistered, NSString *userID, NSString *ticket) {

        _isLoading = NO;

        if (isRegistered) {
            //Already Registered
            [[TapTalk sharedInstance] authenticateWithAuthTicket:ticket connectWhenSuccess:YES success:^{
                [self.verificationOTPView endEditing:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
                [[TAPContactManager sharedManager] saveUserCountryCode:self.country.countryCallingCode];
            } failure:^(NSError *error) {

                //DV Temp
                //DV Note - show error with custom popup
                //        NSInteger errorCode = error.code;
                //        if (errorCode != 999) {
                //            [self showFailAPIWithMessageString:error.domain show:YES];
                //        }
                //END DV Temp

                NSString *errorMessage = [error.userInfo objectForKey:@"message"];
                errorMessage = [TAPUtil nullToEmptyString:errorMessage];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:errorMessage preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];

                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }];
        }
        else {
            //Show Register Screen
            
            [self.verificationOTPView endEditing:YES];
            
            TAPRegisterViewController *registerViewController = [[TAPRegisterViewController alloc] init];
            registerViewController.country = self.country;
            registerViewController.phoneNumber = self.phoneNumber;
            registerViewController.phoneNumberWithCountryCode = self.phoneNumberWithCountryCode;
            [self.navigationController pushViewController:registerViewController animated:YES];
        }

        [self.verificationOTPView showLoading:NO animated:NO title:@""];

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_USER_LOGIN_PHONE_TEMP_DICTIONARY];
        [[NSUserDefaults standardUserDefaults] synchronize];


    } failure:^(NSError *error) {
        _isLoading = NO; 
        [self.verificationOTPView showLoading:NO animated:NO title:@""];
        [self.verificationOTPView setVerificationInformationAsInvalidOTP:YES];
    }];
}

@end
