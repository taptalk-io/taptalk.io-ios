//
//  TAPCustomTextFieldView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,TAPCustomTextFieldViewType) {
    TAPCustomTextFieldViewTypeFullName,
    TAPCustomTextFieldViewTypeUsername,
    TAPCustomTextFieldViewTypeUsernameWithoutDescription, //To show username without validation description
    TAPCustomTextFieldViewTypeMobileNumber,
    TAPCustomTextFieldViewTypeEmailOptional,
    TAPCustomTextFieldViewTypePasswordOptional,
    TAPCustomTextFieldViewTypeReTypePassword,
    TAPCustomTextFieldViewTypeGroupName,
};

@protocol TAPCustomTextFieldViewDelegate <NSObject>

- (BOOL)customTextFieldViewTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)customTextFieldViewTextFieldShouldReturn:(UITextField *)textField;
- (BOOL)customTextFieldViewTextFieldShouldBeginEditing:(UITextField *)textField;
- (void)customTextFieldViewTextFieldDidBeginEditing:(UITextField *)textField;
- (BOOL)customTextFieldViewTextFieldShouldEndEditing:(UITextField *)textField;
- (void)customTextFieldViewTextFieldDidEndEditing:(UITextField *)textField;
- (BOOL)customTextFieldViewTextFieldShouldClear:(UITextField *)textField;

@end

@interface TAPCustomTextFieldView : UIView

@property (strong, nonatomic) UITextField *textField;

@property (weak, nonatomic) id<TAPCustomTextFieldViewDelegate> delegate;

@property (nonatomic) TAPCustomTextFieldViewType tapCustomTextFieldViewType;

- (CGFloat)getTextFieldHeight;
- (void)setAsActive:(BOOL)active animated:(BOOL)animated;
- (void)setAsEnabled:(BOOL)enabled;
- (void)setAsError:(BOOL)error animated:(BOOL)animated;
- (void)setErrorInfoText:(NSString *)string;
- (NSString *)getText;
- (void)setPhoneNumber:(NSString *)phoneNumber country:(TAPCountryModel *)country;
- (void)setTextFieldWithData:(NSString *)dataString;

@end

NS_ASSUME_NONNULL_END
