//
//  TAPCustomPhoneNumberPickerView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPNumericKeyboardAccessoryView.h"
#import "TAPCountryModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPCustomPhoneNumberPickerViewDelegate <NSObject>

- (void)customPhoneNumberPickerViewDidTappedDoneKeyboardButton;
- (BOOL)customPhoneNumberPickerViewTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)customPhoneNumberPickerViewTextFieldShouldReturn:(UITextField *)textField;
- (BOOL)customPhoneNumberPickerViewTextFieldShouldBeginEditing:(UITextField *)textField;
- (void)customPhoneNumberPickerViewTextFieldDidBeginEditing:(UITextField *)textField;
- (BOOL)customPhoneNumberPickerViewTextFieldShouldEndEditing:(UITextField *)textField;
- (void)customPhoneNumberPickerViewTextFieldDidEndEditing:(UITextField *)textField;
- (BOOL)customPhoneNumberPickerViewTextFieldShouldClear:(UITextField *)textField;

@end

@interface TAPCustomPhoneNumberPickerView : UIView

@property (strong, nonatomic) TAPNumericKeyboardAccessoryView *keyboardAccessoryView;
@property (strong, nonatomic) UIButton *pickerButton;
@property (strong, nonatomic) UITextField *phoneNumberTextField;
@property (weak, nonatomic) id<TAPCustomPhoneNumberPickerViewDelegate> delegate;

- (void)showLoading:(BOOL)isLoading animated:(BOOL)animated;
- (void)setAsActive:(BOOL)active animated:(BOOL)animated;
- (void)setCountryCodePhoneNumberWithData:(TAPCountryModel *)countryData;
- (void)setAsDisabled:(BOOL)disabled;

@end

NS_ASSUME_NONNULL_END
