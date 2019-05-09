//
//  TAPVerificationOTPViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPVerificationOTPViewController : TAPBaseViewController

@property (strong, nonatomic) NSString *phoneNumberWithCountryCode;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *countryID;
@property (strong, nonatomic) NSString *OTPKey;
@property (strong, nonatomic) NSString *OTPID;
@property (strong, nonatomic) TAPCountryModel *country;
@property (nonatomic) BOOL isNeedShowLoadingRequestingOTP;

@end

NS_ASSUME_NONNULL_END
