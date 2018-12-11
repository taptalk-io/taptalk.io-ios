//
//  RNGrowingTextView.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/10/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPCustomTextView.h"

@class RNGrowingTextView;

@protocol RNGrowingTextViewDelegate <NSObject>

@optional

- (void)growingTextView:(RNGrowingTextView *)textView shouldChangeHeight:(CGFloat)height;
- (void)growingTextViewDidBeginEditing:(RNGrowingTextView *)textView;
- (void)growingTextViewDidStartTyping:(RNGrowingTextView *)textView;
- (void)growingTextViewDidStopTyping:(RNGrowingTextView *)textView;

@end

@interface RNGrowingTextView : UIView

@property (weak, nonatomic) id<RNGrowingTextViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet TAPCustomTextView *textView;

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
