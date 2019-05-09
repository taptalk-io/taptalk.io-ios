//
//  TAPLoginView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPCustomPhoneNumberPickerView.h"
#import "TAPCustomButtonView.h"

#import "TAPCountryModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPLoginViewDelegate <NSObject>

- (void)loginViewDidTappedContinueButton;

@end

@interface TAPLoginView : TAPBaseView

@property (weak, nonatomic) id <TAPLoginViewDelegate> delegate;
@property (strong, nonatomic) TAPCustomPhoneNumberPickerView *phoneNumberPickerView;
@property (strong, nonatomic) TAPCustomButtonView *loginButton;

- (void)setCountryCodeWithData:(TAPCountryModel *)countryData;
- (void)showLoadingFetchData:(BOOL)isLoading;
- (void)setContinueButtonAsDisabled:(BOOL)disabled animated:(BOOL)animated;
- (void)setAsLoading:(BOOL)isLoading animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
