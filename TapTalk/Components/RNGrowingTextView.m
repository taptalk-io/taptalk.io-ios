//
//  RNGrowingTextView.m
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/10/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "RNGrowingTextView.h"

@interface RNGrowingTextView () <UITextViewDelegate>

//@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *placeholderLabel;

- (void)xibSetup;
- (void)checkHeight;

@end

@implementation RNGrowingTextView

#pragma mark - Lifecycle
- (id)init {
    self = [super init];
    
    if (self) {
        [self xibSetup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self xibSetup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self xibSetup];
        
    }
    
    return self;
}

- (void)xibSetup {
    self.backgroundColor = [UIColor clearColor];
    UIView *currentView = [[[TAPUtil currentBundle] loadNibNamed:[[self class] description] owner:self options:nil] lastObject];
    
    //For iOS 7+ - Handle jumping text
    NSString *requiredSystemVersion = @"7.0";
    NSString *currentSystemVersion = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currentSystemVersion compare:requiredSystemVersion options:NSNumericSearch] != NSOrderedAscending);
    
    if (osVersionSupported) {
        UIFont *oldFont = self.textView.font;
        UIColor *oldTextColor = self.textView.textColor;
        UIColor *oldBackgroundColor = self.textView.backgroundColor;
        NSString *oldText = self.textView.text;
        
        [_textView removeFromSuperview];
        _textView = nil;
        
        NSTextStorage *textStorage = [[NSTextStorage alloc] init];
        NSLayoutManager *layoutManager = [NSLayoutManager new];
        [textStorage addLayoutManager:layoutManager];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
        [layoutManager addTextContainer:textContainer];
        
        _textView = [[TAPCustomTextView alloc] initWithFrame:self.bounds textContainer:textContainer];
        self.textView.font = oldFont;
        self.textView.delegate = self;
        self.textView.backgroundColor = oldBackgroundColor;
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        self.textView.textColor = oldTextColor;
        self.textView.text = oldText;
        self.textView.showsVerticalScrollIndicator = NO;
        self.textView.showsHorizontalScrollIndicator = NO;
        self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textView.autocorrectionType = UITextAutocorrectionTypeDefault;
        self.textView.spellCheckingType = UITextSpellCheckingTypeDefault;
        self.textView.keyboardType = UIKeyboardTypeDefault;
        self.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.textView.returnKeyType = UIReturnKeyDefault;
        self.textView.inputView.autoresizingMask = YES;
                
        [currentView addSubview:self.textView];
        
        //Trailing
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self.textView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:currentView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                  multiplier:1.0f
                                                                    constant:0.0f];
        
        //Leading
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.textView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:currentView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1.0f
                                                                    constant:0.0f];
        
        //Top
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.textView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:currentView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0f
                                                                constant:0.0f];
        
        //Bottom
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.textView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:currentView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0f
                                                                   constant:0.0f];
        
        [currentView addConstraint:trailing];
        [currentView addConstraint:leading];
        [currentView addConstraint:top];
        [currentView addConstraint:bottom];
    }
    
    self.textView.textContainerInset = UIEdgeInsetsMake(8.0f, -5.0f, 0.0f, 0.0f);
    
    if (self.minimumHeight == 0.0f) {
        self.minimumHeight = 28.0f;
    }
    
    if (self.maximumHeight == 0.0f) {
        self.maximumHeight = 97.0f;
    }
    
    currentView.frame = self.bounds;
    
    [self addSubview:currentView];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Delegate
#pragma mark UITextView
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    _text = newString;
    
    if ([newString isEqualToString:@""]) {
        self.placeholderLabel.alpha = 1.0f;
        
        if ([self.delegate respondsToSelector:@selector(growingTextViewDidStopTyping:)]) {
            [self.delegate growingTextViewDidStopTyping:self];
        }
    }
    else {
        self.placeholderLabel.alpha = 0.0f;
        
        if ([self.delegate respondsToSelector:@selector(growingTextViewDidStartTyping:)]) {
            [self.delegate growingTextViewDidStartTyping:self];
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self checkHeight];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
        [self.delegate growingTextViewDidBeginEditing:self];
    }
}

#pragma mark - Custom Method
- (void)setFont:(UIFont *)font {
    _font = font;
    
    self.textView.font = font;
    self.placeholderLabel.font = font;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    self.textView.text = text;
    
    if ([self.text isEqualToString:@""]) {
        self.placeholderLabel.alpha = 1.0f;
        
        if ([self.delegate respondsToSelector:@selector(growingTextViewDidStopTyping:)]) {
            [self.delegate growingTextViewDidStopTyping:self];
        }
    }
    else {
        self.placeholderLabel.alpha = 0.0f;
        
        if ([self.delegate respondsToSelector:@selector(growingTextViewDidStartTyping:)]) {
            [self.delegate growingTextViewDidStartTyping:self];
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
    CGSize contentSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(self.textView.frame), MAXFLOAT)];
    
    CGFloat containerHeight = contentSize.height;
    
    self.textView.textContainer.size = CGSizeMake(self.textView.textContainer.size.width, containerHeight);
    
    if (contentSize.height < self.minimumHeight) {
        contentSize.height = self.minimumHeight;
    }
    
    if (contentSize.height > self.maximumHeight) {
        contentSize.height = self.maximumHeight;
    }
    
    if (contentSize.height != CGRectGetHeight(self.frame)) {
        if ([self.delegate respondsToSelector:@selector(growingTextView:shouldChangeHeight:)]) {
            [self.delegate growingTextView:self shouldChangeHeight:contentSize.height];
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
@end
