//
//  TAPRegisterView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 02/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPCustomTextFieldView.h"
#import "TAPCustomButtonView.h"
#import "TAPImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPRegisterView : TAPBaseView

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) TAPCustomTextFieldView *fullNameTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *usernameTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *mobileNumberTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *emailTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *passwordTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *retypePasswordTextField;
@property (strong, nonatomic) TAPCustomButtonView *continueButtonView;
@property (strong, nonatomic) TAPImageView *profileImageView;
@property (strong, nonatomic) UIButton *removeProfilePictureButton;
@property (strong, nonatomic) UIButton *changeProfilePictureButton;

- (void)refreshViewPosition;
- (void)setContinueButtonEnabled:(BOOL)enable;
- (void)setContentEditable:(BOOL)editable;
- (void)setProfilePictureWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
