//
//  TAPSearchBarView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 3/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPSearchBarView.h"

@interface TAPSearchBarView() <UITextFieldDelegate>

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *shadowView;

@end

@implementation TAPSearchBarView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.shadowView.backgroundColor = [UIColor whiteColor];
        self.shadowView.layer.borderWidth = 1.0f;
        self.shadowView.layer.cornerRadius = CGRectGetHeight(self.shadowView.frame) / 2.0f;
        self.shadowView.layer.shadowRadius = 5.0f;
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.shadowView.layer.shadowOpacity = 1.0f;
        self.shadowView.layer.masksToBounds = NO;
        self.shadowView.alpha = 0.0f;
        [self addSubview:self.shadowView];
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgView];
        
        UIFont *searchBarFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchBarText];
        UIColor *searchBarColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarText];
        UIFont *searchBarPlaceholderFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchBarTextPlaceholder];
        UIColor *searchBarPlaceholderColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarTextPlaceholder];
        
        _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame))];
        self.searchTextField.delegate = self;
        self.searchTextField.backgroundColor = [UIColor whiteColor];
        [self.searchTextField setTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldCursor]];
        self.searchTextField.clearButtonMode = YES;
        UIImageView *leftViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, 0.0f, 14.0, 14.0f)];
        leftViewImageView.image = [UIImage imageNamed:@"TAPIconSearch" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        leftViewImageView.image = [leftViewImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconSearchBarMagnifier]];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(leftViewImageView.frame) + 8.0f + 8.0f, CGRectGetHeight(leftViewImageView.frame))];
        [leftView addSubview:leftViewImageView];
        self.searchTextField.leftView = leftView;
        self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
        NSMutableAttributedString *placeHolderAttributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Search", @"")];
        [placeHolderAttributedString addAttribute:NSFontAttributeName
                                            value:searchBarPlaceholderFont
                                            range:NSMakeRange(0, [NSLocalizedString(@"Search", @"") length])];
        [placeHolderAttributedString addAttribute:NSForegroundColorAttributeName
                                            value:searchBarPlaceholderColor
                                            range:NSMakeRange(0, [NSLocalizedString(@"Search", @"") length])];
        self.searchTextField.attributedPlaceholder = placeHolderAttributedString;
        self.searchTextField.layer.cornerRadius = 10.0f;
        self.searchTextField.layer.borderWidth = 1.0f;
        self.searchTextField.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderInactive].CGColor;
        self.searchTextField.font = searchBarFont;
        self.searchTextField.textColor = searchBarColor;
        self.searchTextField.clipsToBounds = YES;
        [self.bgView addSubview:self.searchTextField];
    }
    
    return self;
}

#pragma mark - Delegate
#pragma mark UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(searchBarTextField:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.delegate searchBarTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarTextFieldShouldReturn:)]) {
        return [self.delegate searchBarTextFieldShouldReturn:textField];
    }
    
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self setAsActive:YES animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(searchBarTextFieldShouldBeginEditing:)]) {
        return [self.delegate searchBarTextFieldShouldBeginEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarTextFieldDidBeginEditing:)]) {
        [self.delegate searchBarTextFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    [self setAsActive:NO animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(searchBarTextFieldShouldEndEditing:)]) {
        return [self.delegate searchBarTextFieldShouldEndEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarTextFieldDidEndEditing:)]) {
        [self.delegate searchBarTextFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarTextFieldShouldClear:)]) {
        return [self.delegate searchBarTextFieldShouldClear:textField];
    }
    
    return YES;
}

#pragma mark - Custom Method
- (void)setAsActive:(BOOL)active animated:(BOOL)animated {
    if (animated) {
        if (active) {
            [UIView animateWithDuration:0.2f animations:^{
                self.shadowView.alpha = 1.0f;
                self.shadowView.layer.shadowColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderActive] colorWithAlphaComponent:0.24f].CGColor;
                self.searchTextField.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderActive].CGColor;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.shadowView.alpha = 0.0f;
                self.searchTextField.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderInactive].CGColor;
            }];
        }
    }
    else {
        if (active) {
            self.shadowView.alpha = 1.0f;
            self.shadowView.layer.shadowColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderActive] colorWithAlphaComponent:0.24f].CGColor;
            self.searchTextField.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderActive].CGColor;
        }
        else {
            self.shadowView.alpha = 0.0f;
            self.searchTextField.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSearchBarBorderInactive].CGColor;
        }
    }
}

- (void)setCustomPlaceHolderString:(NSString *)customPlaceHolderString {
    _customPlaceHolderString = customPlaceHolderString;
    
    UIFont *searchBarPlaceholderFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchBarTextPlaceholder];
    UIColor *searchBarPlaceholderColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarTextPlaceholder];
    NSMutableAttributedString *placeHolderAttributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(self.customPlaceHolderString, @"")];
    [placeHolderAttributedString addAttribute:NSFontAttributeName
                                        value:searchBarPlaceholderFont
                                        range:NSMakeRange(0, [self.customPlaceHolderString length])];
    [placeHolderAttributedString addAttribute:NSForegroundColorAttributeName
                                        value:searchBarPlaceholderColor
                                        range:NSMakeRange(0, [self.customPlaceHolderString length])];
    self.searchTextField.attributedPlaceholder = placeHolderAttributedString;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.shadowView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    self.bgView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    self.searchTextField.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame));
}

- (void)handleCancelButtonTappedState {
    [self setAsActive:NO animated:YES];
}

@end
