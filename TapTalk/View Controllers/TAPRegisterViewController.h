//
//  TAPRegisterViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 02/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPRegisterViewController : TAPBaseViewController

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *phoneNumberWithCountryCode;
@property (strong, nonatomic) TAPCountryModel *country;

@end

NS_ASSUME_NONNULL_END
