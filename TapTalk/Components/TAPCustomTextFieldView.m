//
//  TAPCustomTextFieldView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCustomTextFieldView.h"
#import "TAPCustomPhoneNumberPickerView.h"

@interface TAPCustomTextFieldView () <UITextFieldDelegate, TAPCustomPhoneNumberPickerViewDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *infoDescriptionLabel;
@property (strong, nonatomic) UILabel *errorInfoLabel;

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIView *containerSeparatorView;

@property (strong, nonatomic) UIImageView *passwordShowImageView;

@property (strong, nonatomic) UIButton *showPasswordButton;

@property (strong, nonatomic) TAPCustomPhoneNumberPickerView *phoneNumberPickerView;

@property (nonatomic) BOOL isError;
@property (nonatomic) BOOL isActive;

- (void)setInfoDescriptionText:(NSString *)string;
- (void)showPasswordButtonDidTapped;
- (void)showShowPasswordButton:(BOOL)show;

@end

@implementation TAPCustomTextFieldView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UIFont *formLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontFormLabel];
        UIColor *formLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorFormLabel];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, 22.0f)];
        self.titleLabel.font = formLabelFont;
        self.titleLabel.textColor = formLabelColor;
        [self addSubview:self.titleLabel];
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame) + 8.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, 50.0f)];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive].CGColor;
        self.containerView.layer.cornerRadius = 8.0f;
        self.containerView.layer.borderWidth = 1.0f;
        
        _phoneNumberPickerView = [[TAPCustomPhoneNumberPickerView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.titleLabel.frame) + 8.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 50.0f)];
        self.phoneNumberPickerView.delegate = self;
        [self.phoneNumberPickerView setCountryCodePhoneNumberWithData:[TAPCountryModel new]];
        
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.containerView.frame), CGRectGetMinY(self.containerView.frame), CGRectGetWidth(self.containerView.frame), 50.0f)];
        self.shadowView.backgroundColor = [UIColor whiteColor];
        self.shadowView.layer.cornerRadius = 8.0f;
        self.shadowView.layer.shadowRadius = 5.0f;
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.shadowView.layer.shadowOpacity = 1.0f;
        self.shadowView.layer.masksToBounds = NO;
        self.shadowView.alpha = 0.0f;
        [self addSubview:self.shadowView];

        [self addSubview:self.containerView];
        [self addSubview:self.phoneNumberPickerView];
        
        _containerSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.containerView.frame) - 50.0f, 0.0f, 1.0f, CGRectGetHeight(self.containerView.frame))];
        self.containerSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive];
        [self.containerView addSubview:self.containerSeparatorView];
        
        _passwordShowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.containerSeparatorView.frame) + 15.0f, 15.0f, 20.0f, 20.0f)];
        self.passwordShowImageView.image = [UIImage imageNamed:@"TAPIconShowPassword" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.passwordShowImageView.image = [self.passwordShowImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconViewPasswordInactive]];
        [self.containerView addSubview:self.passwordShowImageView];
        
        _showPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.containerSeparatorView.frame), 0.0f, 50.0f, 50.0f)];
        [self.showPasswordButton addTarget:self action:@selector(showPasswordButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:self.showPasswordButton];
        
        UIFont *textFieldFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontFormTextField];
        UIColor *textFieldColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorFormTextField];
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(self.containerView.frame) - 16.0f - 16.0f, CGRectGetHeight(self.containerView.frame))];
        self.textField.delegate = self;
        [self.textField setTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldCursor]];
        self.textField.textColor = textFieldColor;
        self.textField.font = textFieldFont;
        [self.containerView addSubview:self.textField];
        
        UIFont *formDescriptionLabelBodyFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontFormDescriptionLabel];
        UIColor *formDescriptionLabelBodyColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorFormDescriptionLabel];
        _infoDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.containerView.frame) + 8.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, 0.0f)];
        self.infoDescriptionLabel.font = formDescriptionLabelBodyFont;
        self.infoDescriptionLabel.textColor = formDescriptionLabelBodyColor;
        self.infoDescriptionLabel.numberOfLines = 0;
        [self addSubview:self.infoDescriptionLabel];
        
        UIFont *formErrorInfoLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontFormErrorInfoLabel];
        UIColor *formErrorInfoLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorFormErrorInfoLabel];
        _errorInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.infoDescriptionLabel.frame) + 8.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, 0.0f)];
        self.errorInfoLabel.font = formErrorInfoLabelFont;
        self.errorInfoLabel.textColor = formErrorInfoLabelColor;
        self.errorInfoLabel.numberOfLines = 0;
        [self addSubview:self.errorInfoLabel];
                
    }
    
    return self;
}

#pragma mark - Delegate
#pragma mark UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([self.delegate respondsToSelector:@selector(customTextFieldViewTextField:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.delegate customTextFieldViewTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(customTextFieldViewTextFieldShouldReturn:)]) {
        return [self.delegate customTextFieldViewTextFieldShouldReturn:textField];
    }
    
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self setAsActive:YES animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(customTextFieldViewTextFieldShouldBeginEditing:)]) {
        return [self.delegate customTextFieldViewTextFieldShouldBeginEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(customTextFieldViewTextFieldDidBeginEditing:)]) {
        [self.delegate customTextFieldViewTextFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    [self setAsActive:NO animated:YES];

    if ([self.delegate respondsToSelector:@selector(customTextFieldViewTextFieldShouldEndEditing:)]) {
        return [self.delegate customTextFieldViewTextFieldShouldEndEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(customTextFieldViewTextFieldDidEndEditing:)]) {
        [self.delegate customTextFieldViewTextFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(customTextFieldViewTextFieldShouldClear:)]) {
        return [self.delegate customTextFieldViewTextFieldShouldClear:textField];
    }
    
    return YES;
}

#pragma mark TAPCustomPhoneNumberPickerView

- (void)customPhoneNumberPickerViewDidTappedDoneKeyboardButton {
    
}
- (BOOL)customPhoneNumberPickerViewTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];

    self.textField.text = newText;
    
    if ([self.delegate respondsToSelector:@selector(customTextFieldViewTextField:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.delegate customTextFieldViewTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

- (BOOL)customPhoneNumberPickerViewTextFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)customPhoneNumberPickerViewTextFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)customPhoneNumberPickerViewTextFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)customPhoneNumberPickerViewTextFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)customPhoneNumberPickerViewTextFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)customPhoneNumberPickerViewTextFieldShouldClear:(UITextField *)textField {
    return YES;
}

#pragma mark - Custom Method
- (void)setTapCustomTextFieldViewType:(TAPCustomTextFieldViewType)tapCustomTextFieldViewType {
    _tapCustomTextFieldViewType = tapCustomTextFieldViewType;
    if (tapCustomTextFieldViewType == TAPCustomTextFieldViewTypeFullName) {
        self.titleLabel.text = NSLocalizedString(@"Full Name", @"");
        [self setInfoDescriptionText:@""];
        [self setErrorInfoText:@""];
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.placeholder = NSLocalizedString(@"Full Name", @"");
        self.containerView.alpha = 1.0f;
        self.phoneNumberPickerView.alpha = 0.0f;
        [self showShowPasswordButton:NO];
    }
    else if (tapCustomTextFieldViewType == TAPCustomTextFieldViewTypeUsername) {
        self.titleLabel.text = NSLocalizedString(@"Username", @"");
        [self setInfoDescriptionText:NSLocalizedString(@"Username is always required.\nMust be between 4-32 characters.\nCan only contain a-z, 0-9, underscores, and dot.\nCan't start with number or underscore or dot.\nCan't end with underscore or dot.\nCan't contain consecutive underscores, consecutive dot, underscore followed with dot, and otherwise.", @"")];
        [self setErrorInfoText:@""];
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.placeholder = NSLocalizedString(@"e.g user_1234", @"");
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.containerView.alpha = 1.0f;
        self.phoneNumberPickerView.alpha = 0.0f;
        [self showShowPasswordButton:NO];
    }
    else if (tapCustomTextFieldViewType == TAPCustomTextFieldViewTypeUsernameWithoutDescription) {
        self.titleLabel.text = NSLocalizedString(@"Username", @"");
        [self setInfoDescriptionText:@""];
        [self setErrorInfoText:@""];
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.placeholder = NSLocalizedString(@"e.g user_1234", @"");
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.containerView.alpha = 1.0f;
        self.phoneNumberPickerView.alpha = 0.0f;
        [self showShowPasswordButton:NO];
    }
    else if (tapCustomTextFieldViewType == TAPCustomTextFieldViewTypeMobileNumber) {
        self.titleLabel.text = NSLocalizedString(@"Mobile Number", @"");
        [self setInfoDescriptionText:@""];
        [self setErrorInfoText:@""];
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.placeholder = @"";
        self.containerView.alpha = 0.0f;
        self.phoneNumberPickerView.alpha = 1.0f;
        [self showShowPasswordButton:NO];
        [self.phoneNumberPickerView setAsDisabled:YES];
    }
    else if (tapCustomTextFieldViewType == TAPCustomTextFieldViewTypeEmailOptional) {
        self.titleLabel.text = NSLocalizedString(@"Email Address Optional", @"");
        
        UIFont *formDescriptionFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontFormDescriptionLabel];
        NSString *optionalString = NSLocalizedString(@"Optional", @"");
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text];
        [attributedString addAttribute:NSFontAttributeName
                                            value:formDescriptionFont
                                            range:[self.titleLabel.text rangeOfString:optionalString]];
        self.titleLabel.attributedText = attributedString;
        
        [self setInfoDescriptionText:@""];
        [self setErrorInfoText:@""];
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.placeholder = NSLocalizedString(@"e.g example@work.com", @"");;
        self.containerView.alpha = 1.0f;
        self.phoneNumberPickerView.alpha = 0.0f;
        [self showShowPasswordButton:NO];
    }
    else if (tapCustomTextFieldViewType == TAPCustomTextFieldViewTypePasswordOptional) {
        self.titleLabel.text = NSLocalizedString(@"Password Optional", @"");
        
        UIFont *formDescriptionFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontFormDescriptionLabel];
        NSString *optionalString = NSLocalizedString(@"Optional", @"");
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text];
        [attributedString addAttribute:NSFontAttributeName
                                 value:formDescriptionFont
                                 range:[self.titleLabel.text rangeOfString:optionalString]];
        self.titleLabel.attributedText = attributedString;
        
        [self setInfoDescriptionText:NSLocalizedString(@"Password must contain at least one lowercase, uppercase, special character, and a number.", @"")];
        [self setErrorInfoText:@""];
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.placeholder = NSLocalizedString(@"Insert Password", @"");
        self.textField.secureTextEntry = YES;
        self.containerView.alpha = 1.0f;
        self.phoneNumberPickerView.alpha = 0.0f;
        [self showShowPasswordButton:YES];
    }
    else if (tapCustomTextFieldViewType == TAPCustomTextFieldViewTypeReTypePassword) {
        self.titleLabel.text = NSLocalizedString(@"Retype Password", @"");
        [self setInfoDescriptionText:@""];
        [self setErrorInfoText:@""];
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.placeholder = NSLocalizedString(@"Retype Password", @"");
        self.textField.secureTextEntry = YES;
        self.containerView.alpha = 1.0f;
        self.phoneNumberPickerView.alpha = 0.0f;
        [self showShowPasswordButton:YES];
    }
    else if (tapCustomTextFieldViewType == TAPCustomTextFieldViewTypeGroupName) {
        self.titleLabel.text = NSLocalizedString(@"Group Name", @"");
        [self setInfoDescriptionText:@""];
        [self setErrorInfoText:@""];
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.placeholder = NSLocalizedString(@"Insert Name", @"");
        self.containerView.alpha = 1.0f;
        self.phoneNumberPickerView.alpha = 0.0f;
        [self showShowPasswordButton:NO];
    }
}

- (void)setInfoDescriptionText:(NSString *)string {
    self.infoDescriptionLabel.text = string;
    
    CGFloat ySpacing = 8.0f;
    if ([string isEqualToString:@""] || string ==  nil) {
        ySpacing = 0.0f;
    }
    
    CGSize size = [self.infoDescriptionLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.infoDescriptionLabel.frame), CGFLOAT_MAX)];
    self.infoDescriptionLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.containerView.frame) + ySpacing, CGRectGetWidth(self.infoDescriptionLabel.frame), size.height);
    
    CGFloat errorInfoYSpacing = 8.0f;
    if ([self.errorInfoLabel.text isEqualToString:@""] || self.errorInfoLabel.text ==  nil) {
        errorInfoYSpacing = 0.0f;
    }
    self.errorInfoLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.infoDescriptionLabel.frame) + errorInfoYSpacing, CGRectGetWidth(self.errorInfoLabel.frame), CGRectGetHeight(self.errorInfoLabel.frame));
}

- (void)setErrorInfoText:(NSString *)string {
    self.errorInfoLabel.text = string;
    
    CGFloat ySpacing = 8.0f;
    if ([string isEqualToString:@""] || string ==  nil) {
        ySpacing = 0.0f;
    }
    
    CGSize size = [self.errorInfoLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.errorInfoLabel.frame), CGFLOAT_MAX)];
    self.errorInfoLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.infoDescriptionLabel.frame) + ySpacing, CGRectGetWidth(self.errorInfoLabel.frame), size.height);
}

- (CGFloat)getTextFieldHeight {
    return CGRectGetMaxY(self.errorInfoLabel.frame);
}

- (void)setAsActive:(BOOL)active animated:(BOOL)animated {
    
    _isActive = active;
    
    if (self.isError) {
        return;
    }
    
    if (animated) {
        if (active) {
            [UIView animateWithDuration:0.2f animations:^{
                self.shadowView.alpha = 1.0f;
                self.shadowView.layer.shadowColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderActive] colorWithAlphaComponent:0.24f].CGColor;
                self.containerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderActive].CGColor;
                self.containerSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderActive];
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.shadowView.alpha = 0.0f;
                self.containerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive].CGColor;
                self.containerSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive];
            }];
        }
    }
    else {
        if (active) {
            self.shadowView.alpha = 1.0f;
            self.shadowView.layer.shadowColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderActive] colorWithAlphaComponent:0.24f].CGColor;
            self.containerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderActive].CGColor;
            self.containerSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderActive];
        }
        else {
            self.shadowView.alpha = 0.0f;
            self.containerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive].CGColor;
            self.containerSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive];
        }
    }
}

- (void)setAsEnabled:(BOOL)enabled {
    
    UIColor *textFieldColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorFormTextField];
    UIColor *textFieldPlaceholderColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorFormTextFieldPlaceholder];
    
    if (enabled) {
        self.textField.textColor = textFieldColor;
        self.textField.userInteractionEnabled = YES;
    }
    else {
        self.textField.textColor = textFieldPlaceholderColor;
        self.textField.userInteractionEnabled = NO;
    }
}

- (void)setAsError:(BOOL)error animated:(BOOL)animated {
    _isError = error;
    
    if (self.isActive && !error) {
        [self setAsActive:YES animated:animated];
        return;
    }
    
    if (animated) {
        if (error) {
            [UIView animateWithDuration:0.2f animations:^{
                self.shadowView.alpha = 0.0f;
                self.containerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderError].CGColor;
                self.containerSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderError];
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.shadowView.alpha = 0.0f;
                self.containerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive].CGColor;
                self.containerSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive];
                
            }];
        }
    }
    else {
        if (error) {
            self.shadowView.alpha = 0.0f;
            self.containerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderError].CGColor;
            self.containerSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderError];
        }
        else {
            self.shadowView.alpha = 0.0f;
            self.containerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive].CGColor;
            self.containerSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive];
        }
    }
}

- (void)showPasswordButtonDidTapped {
    if (self.textField.isSecureTextEntry) {
        self.textField.secureTextEntry = NO;
        self.passwordShowImageView.image = [UIImage imageNamed:@"TAPIconShowPassword" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.passwordShowImageView.image = [self.passwordShowImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconViewPasswordActive]];
    }
    else {
        self.textField.secureTextEntry = YES;
        self.passwordShowImageView.image = [UIImage imageNamed:@"TAPIconShowPassword" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.passwordShowImageView.image = [self.passwordShowImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconViewPasswordInactive]];
    }
}

- (void)showShowPasswordButton:(BOOL)show {
    if (show) {
        self.containerSeparatorView.alpha = 1.0f;
        self.passwordShowImageView.alpha = 1.0f;
        self.showPasswordButton.alpha = 1.0f;
        self.textField.frame = CGRectMake(CGRectGetMinX(self.textField.frame), CGRectGetMinY(self.textField.frame), CGRectGetWidth(self.containerView.frame) - CGRectGetWidth(self.showPasswordButton.frame) - 16.0f, CGRectGetHeight(self.textField.frame));
    }
    else {
        self.containerSeparatorView.alpha = 0.0f;
        self.passwordShowImageView.alpha = 0.0f;
        self.showPasswordButton.alpha = 0.0f;
        self.textField.frame = CGRectMake(CGRectGetMinX(self.textField.frame), CGRectGetMinY(self.textField.frame), CGRectGetWidth(self.containerView.frame) - 16.0f - 16.0f, CGRectGetHeight(self.textField.frame));
    }
}

- (NSString *)getText {
    return self.textField.text;
}

- (void)setPhoneNumber:(NSString *)phoneNumber country:(TAPCountryModel *)country {
    
    //remove all characters
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                   componentsJoinedByString:@""];
    
    NSString *countryCallingCode = country.countryCallingCode;
    countryCallingCode = [TAPUtil nullToEmptyString:countryCallingCode];
    if ([phoneNumber hasPrefix:countryCallingCode] && ![countryCallingCode isEqualToString:@""]) {
        phoneNumber = [phoneNumber stringByReplacingCharactersInRange:NSMakeRange(0, [country.countryCallingCode length]) withString:@""];
    }
    
    [self.phoneNumberPickerView setCountryCodePhoneNumberWithData:country];
    self.phoneNumberPickerView.phoneNumberTextField.text = phoneNumber;
    self.textField.text = phoneNumber;
}

- (void)setTextFieldWithData:(NSString *)dataString {
    self.textField.text = dataString;
}

@end
