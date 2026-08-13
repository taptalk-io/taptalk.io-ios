//
//  TAPCountryModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPCountryModel : TAPBaseModel

@property (strong, nonatomic) NSString *countryID;
@property (strong, nonatomic) NSString *countryCommonName;
@property (strong, nonatomic) NSString *countryOfficialName;
@property (strong, nonatomic) NSString *countryISO2Code;
@property (strong, nonatomic) NSString *countryISO3Code;
@property (strong, nonatomic) NSString *countryCallingCode;
@property (strong, nonatomic) NSString *countryCurrencyCode;
@property (strong, nonatomic) NSString *flagIconURL;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL isHidden;

@end

NS_ASSUME_NONNULL_END
