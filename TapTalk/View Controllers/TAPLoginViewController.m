//
//  TAPLoginViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPLoginViewController.h"
#import "TAPLoginView.h"

#import<CoreTelephony/CTCallCenter.h>
#import<CoreTelephony/CTCall.h>
#import<CoreTelephony/CTCarrier.h>
#import<CoreTelephony/CTTelephonyNetworkInfo.h>

#import "TAPCountryPickerViewController.h"
#import "TAPVerificationOTPViewController.h"

@interface TAPLoginViewController () <TAPCustomPhoneNumberPickerViewDelegate, TAPLoginViewDelegate, TAPCountryPickerViewControllerDelegate>

@property (strong, nonatomic) TAPLoginView *loginView;
@property (strong, nonatomic) NSMutableArray *countryListArray;
@property (strong, nonatomic) TAPCountryModel *selectedCountry;

@property (strong, nonatomic) NSString *OTPKey;
@property (strong, nonatomic) NSString *OTPID;

- (void)countryPickerButtonDidTapped;
- (void)fetchCountryListData;
- (NSString *)fetchMobileCarrierCountryISO2Code;

@end

@implementation TAPLoginViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    _loginView = [[TAPLoginView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    self.loginView.delegate = self;
    [self.view addSubview:self.loginView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loginView.phoneNumberPickerView.delegate = self;
    [self.loginView.phoneNumberPickerView.pickerButton addTarget:self action:@selector(countryPickerButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _countryListArray = [NSMutableArray array];
    [self fetchCountryListData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Delegate
#pragma mark TAPCustomPhoneNumberPickerView
- (void)customPhoneNumberPickerViewDidTappedDoneKeyboardButton {
    [self.view endEditing:YES];
}

- (BOOL)customPhoneNumberPickerViewTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([newText length] < 7 || [newText length] > 15) {
        [self.loginView setContinueButtonAsDisabled:YES animated:YES];
    }
    else {
        [self.loginView setContinueButtonAsDisabled:NO animated:YES];
    }
    
    return YES;
}

- (BOOL)customPhoneNumberPickerViewTextFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)customPhoneNumberPickerViewTextFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)customPhoneNumberPickerViewTextFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)customPhoneNumberPickerViewTextFieldShouldClear:(UITextField *)textField {
    return YES;
}

#pragma mark TAPLoginView
- (void)loginViewDidTappedContinueButton {
    
    [self.loginView setAsLoading:YES animated:YES];
    
    NSString *countryCode = self.selectedCountry.countryCallingCode;
    NSString *countryID = self.selectedCountry.countryID;
    NSString *phoneNumber = self.loginView.phoneNumberPickerView.phoneNumberTextField.text;
    
    if([phoneNumber hasPrefix:@"0"]) {
        phoneNumber = [phoneNumber substringWithRange:NSMakeRange(1, [phoneNumber length]-1)];
    }
    
    if([phoneNumber hasPrefix:countryCode]) {
        phoneNumber = [phoneNumber substringWithRange:NSMakeRange([countryCode length], [phoneNumber length]-[countryCode length])];
    }
    
    NSString *formattedPhoneNumber = [NSString stringWithFormat:@"+%@%@", countryCode, phoneNumber];
    
    NSDictionary *phoneDictionary = [[NSUserDefaults standardUserDefaults] secureDictionaryForKey:TAP_PREFS_USER_LOGIN_PHONE_TEMP_DICTIONARY valid:NO];
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    
    if(phoneDictionary != nil && [[phoneDictionary objectForKey:@"phone"] isEqualToString:formattedPhoneNumber] && [[phoneDictionary objectForKey:@"expireTime"] integerValue] > timeInterval) {
        
        TAPVerificationOTPViewController *verificationOTPViewController = [[TAPVerificationOTPViewController alloc] init];
        verificationOTPViewController.phoneNumberWithCountryCode = formattedPhoneNumber;
        verificationOTPViewController.phoneNumber = phoneNumber;
        verificationOTPViewController.OTPKey = self.OTPKey;
        verificationOTPViewController.OTPID = self.OTPID;
        verificationOTPViewController.isNeedShowLoadingRequestingOTP = NO;
        verificationOTPViewController.country = self.selectedCountry;
        [self.navigationController pushViewController:verificationOTPViewController animated:YES];
        
        [self.loginView setAsLoading:NO animated:YES];
    }
    else {
        [TAPDataManager callAPIRequestVerificationCodeWithPhoneNumber:phoneNumber countryID:countryID method:@"phone" success:^(NSString *OTPKey, NSString *OTPID, NSString *successMessage) {
            
            _OTPKey = OTPKey;
            _OTPID = OTPID;
            
            NSMutableDictionary *phoneDictionary = [NSMutableDictionary dictionary];
            [phoneDictionary setObject:formattedPhoneNumber forKey:@"phone"];
            
            NSDate *date = [NSDate date];
            NSTimeInterval timeInterval = [date timeIntervalSince1970];
            NSInteger expireTime = timeInterval + 30;
            
            [phoneDictionary setObject:[NSString stringWithFormat:@"%ld", (long)expireTime] forKey:@"expireTime"];
            
            [[NSUserDefaults standardUserDefaults] setSecureObject:phoneDictionary forKey:TAP_PREFS_USER_LOGIN_PHONE_TEMP_DICTIONARY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            TAPVerificationOTPViewController *verificationOTPViewController = [[TAPVerificationOTPViewController alloc] init];
            verificationOTPViewController.phoneNumberWithCountryCode = formattedPhoneNumber;
            verificationOTPViewController.phoneNumber = phoneNumber;
            verificationOTPViewController.countryID = countryID;
            verificationOTPViewController.OTPKey = self.OTPKey;
            verificationOTPViewController.OTPID = self.OTPID;
            verificationOTPViewController.isNeedShowLoadingRequestingOTP = YES;
            verificationOTPViewController.country = self.selectedCountry;
            [self.navigationController pushViewController:verificationOTPViewController animated:YES];
            
            [self.loginView setAsLoading:NO animated:YES];
            
        } failure:^(NSError *error) {
            
             [self.loginView setAsLoading:NO animated:YES];
            
        }];
    }
}

#pragma mark TAPCountryPickerViewController
- (void)countryPickerDidSelectCountryWithData:(TAPCountryModel *)country {
    _selectedCountry = country;
    [self.loginView setCountryCodeWithData:self.selectedCountry];
}

#pragma mark - Custom Method
- (void)countryPickerButtonDidTapped {
    TAPCountryPickerViewController *countryPickerViewController = [[TAPCountryPickerViewController alloc] init];
    countryPickerViewController.countryDataArray = self.countryListArray;
    countryPickerViewController.delegate = self;
    countryPickerViewController.selectedCountry = self.selectedCountry;
    UINavigationController *countryPickerNavigationController = [[UINavigationController alloc] initWithRootViewController:countryPickerViewController];
    [self presentViewController:countryPickerNavigationController animated:YES completion:nil];
}

- (void)fetchCountryListData {
    [self.loginView showLoadingFetchData:YES];
    
    NSString *countryCode = @"";
    
    NSString *carrierCountryCode = [self fetchMobileCarrierCountryISO2Code];
    if (carrierCountryCode != nil && ![carrierCountryCode isEqualToString:@""]) {
        countryCode = carrierCountryCode;
    }
    else {
        countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    }
    
    NSTimeInterval lastUpdatedTimestamp = [[[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_LAST_UPDATED_COUNTRY_LIST_TIMESTAMP valid:nil] longValue];
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval differenceTimestamp = currentTimestamp - lastUpdatedTimestamp;
    
    NSArray *savedCountryListArray = nil;
    savedCountryListArray = [[NSUserDefaults standardUserDefaults] secureArrayForKey:TAP_PREFS_COUNTRY_LIST_ARRAY valid:nil];
    
    if (([savedCountryListArray count] == 0 || savedCountryListArray == nil) || (differenceTimestamp > TAP_UPDATED_TIME_LIMIT)) {
        [TAPDataManager callAPIGetCountryListWithCurrentCountryCode:countryCode success:^(NSArray *countryModelArray, NSArray *countryDictionaryArray, NSDictionary *countryListDictionary, TAPCountryModel *defaultLocaleCountry) {
            
            _countryListArray = [countryModelArray mutableCopy];
            NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
            [[NSUserDefaults standardUserDefaults] setSecureObject:countryDictionaryArray forKey:TAP_PREFS_COUNTRY_LIST_ARRAY];
            [[NSUserDefaults standardUserDefaults] setSecureObject:countryListDictionary forKey:TAP_PREFS_COUNTRY_LIST_DICTIONARY];
            [[NSUserDefaults standardUserDefaults] setSecureObject:[NSNumber numberWithLong:currentTimeInterval] forKey:TAP_PREFS_LAST_UPDATED_COUNTRY_LIST_TIMESTAMP];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (![defaultLocaleCountry.countryCommonName isEqualToString:@""] && defaultLocaleCountry.countryCommonName != nil) {
                _selectedCountry = defaultLocaleCountry;
            }
            else {
                //Not found, set to indonesia
                TAPCountryModel *customSelectedCountry = [TAPCountryModel new];
                customSelectedCountry.countryCommonName = @"Indonesia";
                customSelectedCountry.countryOfficialName = @"Republic of Indonesia";
                customSelectedCountry.countryCallingCode = @"62";
                customSelectedCountry.countryID = @"1";
                customSelectedCountry.countryISO2Code = @"ID";
                customSelectedCountry.countryISO3Code = @"IDN";
                customSelectedCountry.countryCurrencyCode = @"IDR";
                _selectedCountry = customSelectedCountry;
            }
            
            [self.loginView setCountryCodeWithData:self.selectedCountry];
            
            [self.loginView showLoadingFetchData:NO];
        } failure:^(NSError *error) {

            [self.loginView showLoadingFetchData:NO];
        }];
    }
    else {
        NSMutableArray *countryListDataArray = [NSMutableArray array];
        BOOL isSelectedCountryFound = NO;
        for (NSDictionary *dictionary in savedCountryListArray) {
            TAPCountryModel *country = [TAPDataManager countryModelFromDictionary:dictionary];
            [countryListDataArray addObject:country];
            
            if ([country.countryISO2Code isEqualToString:countryCode]) {
                _selectedCountry = country;
                isSelectedCountryFound = YES;
            }
        }
        
        if (!isSelectedCountryFound) {
            //Not found, set to indonesia
            TAPCountryModel *customSelectedCountry = [TAPCountryModel new];
            customSelectedCountry.countryCommonName = @"Indonesia";
            customSelectedCountry.countryOfficialName = @"Republic of Indonesia";
            customSelectedCountry.countryCallingCode = @"62";
            customSelectedCountry.countryID = @"1";
            customSelectedCountry.countryISO2Code = @"ID";
            customSelectedCountry.countryISO3Code = @"IDN";
            customSelectedCountry.countryCurrencyCode = @"IDR";
            _selectedCountry = customSelectedCountry;
        }
        
        [self.loginView setCountryCodeWithData:self.selectedCountry];
        _countryListArray = countryListDataArray;
        [self.loginView showLoadingFetchData:NO];
    }
}

- (void)presentLoginViewControllerIfNeededFromViewController:(UIViewController *)viewController force:(BOOL)force {
    UINavigationController *loginNavigationController = [[UINavigationController alloc] initWithRootViewController:self];
    if (![[TapTalk sharedInstance] isAuthenticated] || force) {
        
        //Prevention to clear existing data
        [[TapTalk sharedInstance] clearAllTapTalkData];
        
        [viewController presentViewController:loginNavigationController animated:YES completion:nil];
    }
}

- (NSString *)fetchMobileCarrierCountryISO2Code {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString *isoCountryCode = carrier.isoCountryCode;
    isoCountryCode = [TAPUtil nullToEmptyString:isoCountryCode];
    return [isoCountryCode uppercaseString];
}

@end
