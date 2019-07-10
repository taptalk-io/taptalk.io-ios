//
//  TAPCustomGrowingTextView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 20/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCustomGrowingTextView.h"

@interface TAPCustomGrowingTextView () <UITextViewDelegate>

@property (strong, nonatomic) UILabel *placeholderLabel;

- (void)initialSetup;
- (void)checkHeight;

@end

@implementation TAPCustomGrowingTextView

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    
    if (self) {
        [self initialSetup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialSetup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialSetup];
        
    }
    
    return self;
}


#pragma mark - Custom Method
- (void)initialSetup {
    
    self.backgroundColor = [UIColor clearColor];
    
    //For iOS 7+ - Handle jumping text
    NSString *requiredSystemVersion = @"7.0";
    NSString *currentSystemVersion = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currentSystemVersion compare:requiredSystemVersion options:NSNumericSearch] != NSOrderedAscending);
    
    if (osVersionSupported) {
        
        [_textView removeFromSuperview];
        _textView = nil;
        
        NSTextStorage *textStorage = [[NSTextStorage alloc] init];
        NSLayoutManager *layoutManager = [NSLayoutManager new];
        [textStorage addLayoutManager:layoutManager];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
        [layoutManager addTextContainer:textContainer];
        
        UIFont *textViewFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaPreviewCaption];
        UIColor *textViewColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorMediaPreviewCaption];
        _textView = [[TAPCustomTextView alloc] initWithFrame:self.bounds textContainer:textContainer];
        self.textView.delegate = self;
        self.textView.textContainer.lineFragmentPadding = 0;
        self.textView.font = textViewFont;
        self.textView.textColor = textViewColor;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.showsVerticalScrollIndicator = NO;
        self.textView.showsHorizontalScrollIndicator = NO;
        self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textView.autocorrectionType = UITextAutocorrectionTypeDefault;
        self.textView.spellCheckingType = UITextSpellCheckingTypeDefault;
        self.textView.keyboardType = UIKeyboardTypeDefault;
        self.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.textView.returnKeyType = UIReturnKeyDefault;
        self.textView.inputView.autoresizingMask = YES;
        
        [self addSubview:self.textView];
    }
    
    self.textView.textContainerInset = UIEdgeInsetsZero;
    
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textView.frame), CGRectGetMinY(self.textView.frame), CGRectGetWidth(self.textView.frame), CGRectGetHeight(self.textView.frame))];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.placeholderLabel];
    
    if (self.minimumHeight == 0.0f) {
        self.minimumHeight = 22.0f;
    }
    
    if (self.maximumHeight == 0.0f) {
        self.maximumHeight = 60.0f;
    }
    
    self.characterCountLimit = 0;
}

#pragma mark - Delegate
#pragma mark UITextView
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if (self.characterCountLimit != 0 && [newString length] > self.characterCountLimit) {
        return NO;
    }
    
    _text = newString;
    
    if ([newString isEqualToString:@""]) {
        self.placeholderLabel.alpha = 1.0f;
        
        if ([self.delegate respondsToSelector:@selector(customGrowingTextViewDidStopTyping:)]) {
            [self.delegate customGrowingTextViewDidStopTyping:self];
        }
    }
    else {
        self.placeholderLabel.alpha = 0.0f;
        
        if ([self.delegate respondsToSelector:@selector(customGrowingTextViewDidStartTyping:)]) {
            [self.delegate customGrowingTextViewDidStartTyping:self];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(customGrowingTextView:shouldChangeTextInRange:replacementText:)]) {
        BOOL result = [self.delegate customGrowingTextView:textView shouldChangeTextInRange:range replacementText:text];
        return result;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self checkHeight];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.placeholderLabel.alpha = 0.0f;
    
    if ([self.delegate respondsToSelector:@selector(customGrowingTextViewDidBeginEditing:)]) {
        [self.delegate customGrowingTextViewDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(customGrowingTextViewDidEndEditing:)]) {
        [self.delegate customGrowingTextViewDidEndEditing:self];
    }
}

#pragma mark - Custom Method
- (void)setFont:(UIFont *)font {
    _font = font;
    
    self.textView.font = font;
    self.placeholderLabel.font = font;
}

- (void)setTextColor:(UIColor *)color {
    self.textView.textColor = color;
}

- (void)setPlaceholderColor:(UIColor *)color {
    self.placeholderLabel.textColor = color;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    self.textView.text = text;
    
    if ([self.text isEqualToString:@""]) {
        self.placeholderLabel.alpha = 1.0f;
        
        if ([self.delegate respondsToSelector:@selector(customGrowingTextViewDidStopTyping:)]) {
            [self.delegate customGrowingTextViewDidStopTyping:self];
        }
    }
    else {
        self.placeholderLabel.alpha = 0.0f;
        
        if ([self.delegate respondsToSelector:@selector(customGrowingTextViewDidStartTyping:)]) {
            [self.delegate customGrowingTextViewDidStartTyping:self];
        }
    }
    
    [self checkHeight];
}

- (void)setInitialText:(NSString *)text {
    _text = text;
    
    self.textView.text = text;
    
    if ([self.text isEqualToString:@""]) {
        self.placeholderLabel.alpha = 1.0f;
    }
    else {
        self.placeholderLabel.alpha = 0.0f;
    }
    
    [self checkHeight];
}

- (void)checkHeight {
    CGSize contentSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)];
    
    self.textView.textContainer.size = CGSizeMake(self.textView.textContainer.size.width, contentSize.height);
    
    if (contentSize.height < self.minimumHeight) {
        contentSize.height = self.minimumHeight;
    }
    
    if (contentSize.height > self.maximumHeight) {
        contentSize.height = self.maximumHeight;
    }
    
    self.textView.frame = CGRectMake(CGRectGetMinX(self.textView.frame), CGRectGetMinY(self.textView.frame), CGRectGetWidth(self.textView.frame), contentSize.height);
    
    if (contentSize.height != CGRectGetHeight(self.frame)) {
        if ([self.delegate respondsToSelector:@selector(customGrowingTextView:shouldChangeHeight:)]) {
            [self.delegate customGrowingTextView:self shouldChangeHeight:contentSize.height];
        }
    }
}

- (void)becameFirstResponder {
    [self.textView becomeFirstResponder];
    //    [self performSelector:@selector(setTextViewFirstResponder) withObject:nil afterDelay:0.2f];
}

- (void)resignFirstResponder {
    [self.textView resignFirstResponder];
}

- (void)resignFirstResponderWithoutAnimation {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    [self.textView resignFirstResponder];
    
    [UIView commitAnimations];
}

- (BOOL)isFirstResponder {
    return [self.textView isFirstResponder];
}

- (void)setInputView:(UIView *)inputView {
    self.textView.inputView = inputView;
    [self.textView reloadInputViews];
}

- (void)selectAll:(id)sender {
    [self.textView selectAll:sender];
}

- (void)setPlaceholderText:(NSString *)text {
    self.placeholderLabel.text = text;
}

- (void)setCharCountLimit:(NSInteger)limit {
    _characterCountLimit = limit;
}

@end

