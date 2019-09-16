//
//  TAPRegisterView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 02/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPRegisterView.h"

@interface TAPRegisterView()

@end

@implementation TAPRegisterView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetMaxY(self.scrollView.frame));
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        
        UIFont *titleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTitleLabel];
        UIColor *titleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTitleLabel];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 16.0f, CGRectGetWidth(self.frame) - 32.0f, 46.0f)];
        titleLabel.font = titleLabelFont;
        titleLabel.textColor = titleLabelColor;
        titleLabel.text = NSLocalizedString(@"Register", @"");
        [self.scrollView addSubview:titleLabel];
        
        _profileImageView = [[TAPImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 96.0f) / 2, CGRectGetMaxY(titleLabel.frame) + 32.0f, 96.0f, 96.0f)];
        self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2.0f;
        self.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.profileImageView.layer.masksToBounds = YES;
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.scrollView addSubview:self.profileImageView];
        
        _removeProfilePictureView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) - 24.0f, CGRectGetMinY(self.profileImageView.frame), 24.0f, 24.0f)];
        self.removeProfilePictureView.alpha = 0.0f;
        self.removeProfilePictureView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRemoveItem];
        self.removeProfilePictureView.layer.cornerRadius = CGRectGetHeight(self.removeProfilePictureView.frame) / 2.0f;
        self.removeProfilePictureView.clipsToBounds = YES;
        [self.scrollView addSubview:self.removeProfilePictureView];
        
        _removeProfilePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.removeProfilePictureView.frame), CGRectGetHeight(self.removeProfilePictureView.frame))];
        UIImage *removeImage = [UIImage imageNamed:@"TAPIconRemoveMedia" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        removeImage = [removeImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRemoveItemBackground]];
        [self.removeProfilePictureButton setImage:removeImage forState:UIControlStateNormal];
        [self.removeProfilePictureView addSubview:self.removeProfilePictureButton];
        
        UIFont *clickableLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableLabel];
        UIColor *clickableLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableLabel];
        UILabel *changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.profileImageView.frame) + 8.0f, 100.0f, 22.0f)];
        changeLabel.font = clickableLabelFont;
        changeLabel.text = NSLocalizedString(@"Change", @"");
        changeLabel.textColor = clickableLabelColor;
        CGSize changeLabelSize = [changeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 22.0f)];
        changeLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - changeLabelSize.width - 4.0f - 14.0f) / 2, CGRectGetMinY(changeLabel.frame), changeLabelSize.width, 22.0f);
        [self.scrollView addSubview:changeLabel];
        
        UIImageView *changeIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(changeLabel.frame) + 4.0f, CGRectGetMinY(changeLabel.frame) + 4.0f, 14.0f, 14.0f)];
        changeIconImageView.image = [UIImage imageNamed:@"TAPIconAddEditItem" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        changeIconImageView.image = [changeIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChangePicture]];
        [self.scrollView addSubview:changeIconImageView];
        
        _changeProfilePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(changeLabel.frame), CGRectGetMinY(changeLabel.frame) - 8.0f, CGRectGetWidth(changeLabel.frame) + 4.0f + CGRectGetWidth(changeIconImageView.frame), 40.0f)];
        [self.scrollView addSubview:self.changeProfilePictureButton];
        
        _fullNameTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(changeLabel.frame) + 24.0f, CGRectGetWidth(self.frame), 0.0f)];
        [self.fullNameTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypeFullName];
        self.fullNameTextField.frame = CGRectMake(CGRectGetMinX(self.fullNameTextField.frame), CGRectGetMinY(self.fullNameTextField.frame), CGRectGetWidth(self.fullNameTextField.frame), [self.fullNameTextField getTextFieldHeight]);
        [self.scrollView addSubview:self.fullNameTextField];
        
        _usernameTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.fullNameTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 0.0f)];
        [self.usernameTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypeUsername];
        self.usernameTextField.frame = CGRectMake(CGRectGetMinX(self.usernameTextField.frame), CGRectGetMinY(self.usernameTextField.frame), CGRectGetWidth(self.usernameTextField.frame), [self.usernameTextField getTextFieldHeight]);
        [self.scrollView addSubview:self.usernameTextField];
        
        _mobileNumberTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.usernameTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 0.0f)];
        [self.mobileNumberTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypeMobileNumber];
        self.mobileNumberTextField.frame = CGRectMake(CGRectGetMinX(self.mobileNumberTextField.frame), CGRectGetMinY(self.mobileNumberTextField.frame), CGRectGetWidth(self.mobileNumberTextField.frame), [self.mobileNumberTextField getTextFieldHeight]);
        [self.scrollView addSubview:self.mobileNumberTextField];
        
        _emailTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.mobileNumberTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 0.0f)];
        [self.emailTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypeEmailOptional];
        self.emailTextField.frame = CGRectMake(CGRectGetMinX(self.emailTextField.frame), CGRectGetMinY(self.emailTextField.frame), CGRectGetWidth(self.emailTextField.frame), [self.emailTextField getTextFieldHeight]);
        [self.scrollView addSubview:self.emailTextField];
        
        //CS TEMP - uncomment code below to show password
//        _passwordTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.emailTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 0.0f)];
//        [self.passwordTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypePasswordOptional];
//        self.passwordTextField.frame = CGRectMake(CGRectGetMinX(self.passwordTextField.frame), CGRectGetMinY(self.passwordTextField.frame), CGRectGetWidth(self.passwordTextField.frame), [self.passwordTextField getTextFieldHeight]);
//        [self.scrollView addSubview:self.passwordTextField];
//
//        _retypePasswordTextField = [[TAPCustomTextFieldView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.passwordTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 0.0f)];
//        [self.retypePasswordTextField setTapCustomTextFieldViewType:TAPCustomTextFieldViewTypeReTypePassword];
//        self.retypePasswordTextField.frame = CGRectMake(CGRectGetMinX(self.retypePasswordTextField.frame), CGRectGetMinY(self.retypePasswordTextField.frame), CGRectGetWidth(self.retypePasswordTextField.frame), [self.retypePasswordTextField getTextFieldHeight]);
//        [self.scrollView addSubview:self.retypePasswordTextField];
//
//        _continueButtonView = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.retypePasswordTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 50.0f)];
        //END CS TEMP
        _continueButtonView = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.emailTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 50.0f)]; //CS TEMP - remove this line of code to show password
        [self.continueButtonView setCustomButtonViewType:TAPCustomButtonViewTypeInactive];
        [self.continueButtonView setButtonWithTitle:NSLocalizedString(@"Continue", @"")];
        [self.scrollView addSubview:self.continueButtonView];
        
        CGFloat bottomGap = 16.0f;
        if (IS_IPHONE_X_FAMILY) {
            bottomGap = [TAPUtil safeAreaBottomPadding];
        }
        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.continueButtonView.frame) + bottomGap);
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)refreshViewPosition {
    [UIView animateWithDuration:0.2f animations:^{
        self.fullNameTextField.frame = CGRectMake(CGRectGetMinX(self.fullNameTextField.frame), CGRectGetMinY(self.fullNameTextField.frame), CGRectGetWidth(self.fullNameTextField.frame), [self.fullNameTextField getTextFieldHeight]);
        self.usernameTextField.frame = CGRectMake(CGRectGetMinX(self.usernameTextField.frame), CGRectGetMaxY(self.fullNameTextField.frame) + 24.0f, CGRectGetWidth(self.usernameTextField.frame), [self.usernameTextField getTextFieldHeight]);
        self.mobileNumberTextField.frame = CGRectMake(CGRectGetMinX(self.mobileNumberTextField.frame), CGRectGetMaxY(self.usernameTextField.frame) + 24.0f, CGRectGetWidth(self.mobileNumberTextField.frame), [self.mobileNumberTextField getTextFieldHeight]);
        self.emailTextField.frame = CGRectMake(CGRectGetMinX(self.emailTextField.frame), CGRectGetMaxY(self.mobileNumberTextField.frame) + 24.0f, CGRectGetWidth(self.emailTextField.frame), [self.emailTextField getTextFieldHeight]);
        //CS TEMP - uncomment below code to show password
//        self.passwordTextField.frame = CGRectMake(CGRectGetMinX(self.passwordTextField.frame), CGRectGetMaxY(self.emailTextField.frame) + 24.0f, CGRectGetWidth(self.passwordTextField.frame), [self.passwordTextField getTextFieldHeight]);
//        self.retypePasswordTextField.frame = CGRectMake(CGRectGetMinX(self.retypePasswordTextField.frame), CGRectGetMaxY(self.passwordTextField.frame) + 24.0f, CGRectGetWidth(self.retypePasswordTextField.frame), [self.retypePasswordTextField getTextFieldHeight]);
//        self.continueButtonView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.retypePasswordTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 50.0f);
        //END CS TEMP
        self.continueButtonView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.emailTextField.frame) + 24.0f, CGRectGetWidth(self.frame), 50.0f); // CS TEMP - remove this line of code to show password
        
        CGFloat bottomGap = 16.0f;
        if (IS_IPHONE_X_FAMILY) {
            bottomGap = [TAPUtil safeAreaBottomPadding];
        }
        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.continueButtonView.frame) + bottomGap);
    }];
}

- (void)setContinueButtonEnabled:(BOOL)enable {
    [self.continueButtonView setAsActiveState:enable animated:NO];
}

- (void)setContentEditable:(BOOL)editable {
    if (editable) {
        [self.fullNameTextField setAsEnabled:YES];
        [self.usernameTextField setAsEnabled:YES];
        [self.emailTextField setAsEnabled:YES];
        [self.passwordTextField setAsEnabled:YES];
        [self.retypePasswordTextField setAsEnabled:YES];
    }
    else {
        [self.fullNameTextField setAsEnabled:NO];
        [self.usernameTextField setAsEnabled:NO];
        [self.emailTextField setAsEnabled:NO];
        [self.passwordTextField setAsEnabled:NO];
        [self.retypePasswordTextField setAsEnabled:NO];
    }
}

- (void)setProfilePictureWithImage:(UIImage *)image {
    if (image ==  nil) {
        self.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.removeProfilePictureView.alpha = 0.0f;
    }
    else {
        self.profileImageView.image = image;
        self.removeProfilePictureView.alpha = 1.0f;
    }
}

@end
