//
//  TAPMyAccountView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 04/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPCustomTextFieldView.h"
#import "TAPCustomButtonView.h"
#import "TAPImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPMyAccountView : TAPBaseView

@property (strong, nonatomic) UIView *navigationHeaderView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIImageView *cancelImageView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UILabel *navigationHeaderLabel;
@property (strong, nonatomic) UIView *navigationSeparatorView;
@property (strong, nonatomic) UIView *halfRoundWhiteBackgroundView;
@property (strong, nonatomic) UIView *additionalWhiteBounceView;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) TAPCustomTextFieldView *fullNameTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *usernameTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *mobileNumberTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *emailTextField;
@property (strong, nonatomic) UIView *logoutView;
@property (strong, nonatomic) UIButton *logoutButton;
@property (strong, nonatomic) TAPCustomButtonView *continueButtonView;
@property (strong, nonatomic) TAPImageView *profileImageView;
@property (strong, nonatomic) UIButton *removeProfilePictureButton;
@property (strong, nonatomic) UIButton *changeProfilePictureButton;

- (void)refreshViewPosition;
- (void)setContinueButtonEnabled:(BOOL)enable;
- (void)setContentEditable:(BOOL)editable;
- (void)setProfilePictureWithImage:(UIImage *)image;
- (void)setProfilePictureWithImageURL:(NSString *)imageURL;
- (void)setAsLoading:(BOOL)loading;
- (void)animateProgressUploadingImageWithProgress:(CGFloat)progress total:(CGFloat)total;

@end

NS_ASSUME_NONNULL_END
