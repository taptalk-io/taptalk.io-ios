//
//  TAPLocationSearchBarView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 20/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPLocationSearchBarViewDelegate <NSObject>

@optional
- (void)searchBarViewAfterClearTextField;

- (BOOL)searchBarViewTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)searchBarViewTextFieldShouldReturn:(UITextField *)textField;

- (BOOL)searchBarViewTextFieldShouldBeginEditing:(UITextField *)textField;
- (void)searchBarViewTextFieldDidBeginEditing:(UITextField *)textField;
- (BOOL)searchBarViewTextFieldShouldEndEditing:(UITextField *)textField;
- (void)searchBarViewTextFieldDidEndEditing:(UITextField *)textField;
- (void)searchBarViewTextFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason NS_AVAILABLE_IOS(10_0);

- (BOOL)searchBarViewTextFieldShouldClear:(UITextField *)textField;

@end

@interface TAPLocationSearchBarView : TAPBaseView

@property (weak, nonatomic) id<TAPLocationSearchBarViewDelegate> delegate;
@property (nonatomic) CGRect leftViewFrame;

//Setter
@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIImage *leftViewImage;
@property (nonatomic) UIReturnKeyType returnKeyType;

//Custom Methods
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (void)showLeftView:(BOOL)isShowed;
- (void)showClearView:(BOOL)isShowed;
- (void)showTextField:(BOOL)isShowed;


@end

NS_ASSUME_NONNULL_END
