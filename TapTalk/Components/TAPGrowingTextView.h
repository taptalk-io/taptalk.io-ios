//
//  TAPGrowingTextView.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/10/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPCustomTextView.h"

@class TAPGrowingTextView;

@protocol TAPGrowingTextViewDelegate <NSObject>

@optional

- (void)growingTextView:(TAPGrowingTextView *)textView shouldChangeHeight:(CGFloat)height;
- (void)growingTextViewDidBeginEditing:(TAPGrowingTextView *)textView;
- (void)growingTextViewDidStartTyping:(TAPGrowingTextView *)textView;
- (void)growingTextViewDidStopTyping:(TAPGrowingTextView *)textView;
- (void)growingTextViewShouldChangeTextInRange:(NSRange)range
                               replacementText:(NSString *)text
                                       newText:(NSString *)newText;

@end

@interface TAPGrowingTextView : UIView

@property (weak, nonatomic) id<TAPGrowingTextViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet TAPCustomTextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *placeholderLabel;

@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) NSString *text;

@property (nonatomic) CGFloat minimumHeight;
@property (nonatomic) CGFloat maximumHeight;

- (void)becameFirstResponder;
- (void)resignFirstResponder;
- (void)resignFirstResponderWithoutAnimation;
- (BOOL)isFirstResponder;
- (void)selectAll:(id)sender;
- (void)setInitialText:(NSString *)text;

- (void)setInputView:(UIView *)inputView;

@end
