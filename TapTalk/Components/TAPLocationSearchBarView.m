//
//  TAPLocationSearchBarView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 20/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPLocationSearchBarView.h"

@interface TAPLocationSearchBarView () <UITextFieldDelegate>

//Background View
@property (strong, nonatomic) UIView *searchBarView;

//Left View
@property (strong, nonatomic) UIView *leftView;
@property (strong, nonatomic) UIImageView *leftViewImageView;

//Clear View
@property (strong, nonatomic) UIView *clearView;
@property (strong, nonatomic) UIButton *clearViewButton;
@property (strong, nonatomic) UILabel *clearViewLabel;

//Textfield
@property (strong, nonatomic) UITextField *searchBarTextField;
@property (strong, nonatomic) UIView *shadowView;

@end

@implementation TAPLocationSearchBarView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.shadowView.backgroundColor = [UIColor whiteColor];
        self.shadowView.layer.cornerRadius = 8.0f;
        self.shadowView.layer.shadowRadius = 5.0f;
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.shadowView.layer.shadowOpacity = 1.0f;
        self.shadowView.layer.masksToBounds = NO;
        self.shadowView.alpha = 0.0f;
        [self addSubview:self.shadowView];
        
        _searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.searchBarView.backgroundColor = [UIColor whiteColor];
        self.searchBarView.layer.cornerRadius = 10.0f;
        self.searchBarView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderInactive].CGColor;
        self.searchBarView.layer.borderWidth = 1.0f;
        self.searchBarView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.searchBarView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        self.searchBarView.layer.shadowRadius = 12.0f;
        self.searchBarView.layer.shadowOpacity = 0.1f;
        [self addSubview:self.searchBarView];
        
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.searchBarView.frame), CGRectGetMinY(self.searchBarView.frame), 30.0f, CGRectGetHeight(self.searchBarView.frame))];
        _leftViewFrame = self.leftView.frame;
        [self addSubview:self.leftView];
        
        _leftViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.leftView.frame) - 8.0f - 14.0f, (CGRectGetHeight(self.leftView.frame) - 14.0f) / 2.0f, 14.0f, 14.0f)];
        self.leftViewImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.leftView addSubview:self.leftViewImageView];
        
        _clearView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.searchBarView.frame) - 36.0f - 12.0f, 0.0f, 36.0f, CGRectGetHeight(self.searchBarView.frame))];
        [self showClearView:NO];
        [self.searchBarView addSubview:self.clearView];
        
        UIFont *clearButtonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLocationPickerClearButton];
        UIColor *clearButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLocationPickerClearButton];
        _clearViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.clearView.frame), CGRectGetHeight(self.clearView.frame))];
        self.clearViewLabel.text = NSLocalizedString(@"CLEAR", @"");
        self.clearViewLabel.textColor = clearButtonColor;
        self.clearViewLabel.font = clearButtonFont;
        [self.clearView addSubview:self.clearViewLabel];
        
        _clearViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.clearView.frame), CGRectGetHeight(self.clearView.frame))];
        [self.clearViewButton addTarget:self action:@selector(clearButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.clearView addSubview:self.clearViewButton];
        
        UIFont *locationTextFieldFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLocationPickerTextField];
        UIColor *locationTextFieldColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLocationPickerTextField];
        _searchBarTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.leftView.frame), 0.0f, CGRectGetMinX(self.clearView.frame) - CGRectGetMaxX(self.leftView.frame) - 8.0f, CGRectGetHeight(self.searchBarView.frame))]; //width -8.0f for gap between textfield and clear view.
        self.searchBarTextField.backgroundColor = [UIColor whiteColor];
        self.searchBarTextField.layer.cornerRadius = 4.0f;
        self.searchBarTextField.font = locationTextFieldFont;
        self.searchBarTextField.textColor = locationTextFieldColor;
        [self.searchBarTextField setTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldCursor]];
        [self.searchBarView addSubview:self.searchBarTextField];
        self.searchBarTextField.delegate = self;
    }
    
    return self;
}

#pragma mark - Delegate
#pragma mark UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([newText isEqualToString:@""]) {
        [self showClearView:NO];
    }
    
    else {
        NSString *firstChar = [NSString stringWithFormat:@"%c", [newText characterAtIndex:0]];
        if(string != nil) {
            //Handle for search that first char cannot be empty or whiteSpace
            if([firstChar isEqualToString:@""] || [firstChar isEqualToString:@" "]) {
                return NO;
            }
            else {
                [self showClearView:YES];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(searchBarViewTextField:shouldChangeCharactersInRange:replacementString:)]) {
        [self.delegate searchBarViewTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    _text = newText;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarViewTextFieldShouldReturn:)]) {
        [self.delegate searchBarViewTextFieldShouldReturn:textField];
    }
    
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self setAsActive:YES animated:YES];
    if ([self.delegate respondsToSelector:@selector(searchBarViewTextFieldShouldBeginEditing:)]) {
        [self.delegate searchBarViewTextFieldShouldBeginEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarViewTextFieldDidBeginEditing:)]) {
        [self.delegate searchBarViewTextFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarViewTextFieldShouldEndEditing:)]) {
        [self.delegate searchBarViewTextFieldShouldEndEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self setAsActive:NO animated:YES];
    if ([self.delegate respondsToSelector:@selector(searchBarViewTextFieldDidEndEditing:)]) {
        [self.delegate searchBarViewTextFieldDidEndEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason NS_AVAILABLE_IOS(10_0) {
    if ([self.delegate respondsToSelector:@selector(searchBarViewTextFieldDidEndEditing:reason:)]) {
        [self.delegate searchBarViewTextFieldDidEndEditing:textField reason:reason];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self setAsActive:NO animated:NO];
    if ([self.delegate respondsToSelector:@selector(searchBarViewTextFieldShouldClear:)]) {
        [self.delegate searchBarViewTextFieldShouldClear:textField];
    }
    
    return YES;
}


#pragma mark - Setter
- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    UIColor *placeholderColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLocationPickerTextFieldPlaceholder];
    NSDictionary *placeholderAttributes = @{NSForegroundColorAttributeName:placeholderColor};
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:placeholderAttributes];
    self.searchBarTextField.attributedPlaceholder = attributedPlaceholder;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.searchBarTextField.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
}

- (void)setText:(NSString *)text {
    _text = text;
    self.searchBarTextField.text = text;
}

- (void)setLeftViewImage:(UIImage *)leftViewImage {
    _leftViewImage = leftViewImage;
    self.leftViewImageView.image = self.leftViewImage;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    _returnKeyType = returnKeyType;
    [self.searchBarTextField setReturnKeyType:self.returnKeyType];
}

#pragma mark - Custom Method
- (BOOL)becomeFirstResponder {
    [self.searchBarTextField becomeFirstResponder];
    
    return YES;
}

- (BOOL)resignFirstResponder {
    [self.searchBarTextField resignFirstResponder];
    
    return YES;
}

- (void)clearButtonDidTapped {
    self.text = @"";
    [self showClearView:NO];
    if ([self.delegate respondsToSelector:@selector(searchBarViewAfterClearTextField)]) {
        [self.delegate searchBarViewAfterClearTextField];
    }
}

- (void)showClearView:(BOOL)isShowed {
    if (isShowed) {
        self.clearView.alpha = 1.0f;
    }
    else {
        self.clearView.alpha = 0.0f;
    }
}

- (void)showLeftView:(BOOL)isShowed {
    if (isShowed) {
        self.leftView.alpha = 1.0f;
    }
    else {
        self.leftView.alpha = 0.0f;
    }
}

- (void)showTextField:(BOOL)isShowed {
    if (isShowed) {
        self.searchBarTextField.alpha = 1.0f;
    }
    else {
        self.searchBarTextField.alpha = 0.0f;
    }
}

- (void)setAsActive:(BOOL)active animated:(BOOL)animated {
    if (animated) {
        if (active) {
            [UIView animateWithDuration:0.2f animations:^{
                self.shadowView.alpha = 1.0f;
                self.shadowView.layer.shadowColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderActive] colorWithAlphaComponent:0.24f].CGColor;
                self.searchBarView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderActive].CGColor;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.shadowView.alpha = 0.0f;
                self.searchBarView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderInactive].CGColor;
            }];
        }
    }
    else {
        if (active) {
            self.shadowView.alpha = 1.0f;
            self.shadowView.layer.shadowColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderActive] colorWithAlphaComponent:0.24f].CGColor;
            self.searchBarView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderActive].CGColor;
        }
        else {
            self.shadowView.alpha = 0.0f;
            self.searchBarView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderInactive].CGColor;
        }
    }
}

@end
