//
//  TAPCustomGrowingTextView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 20/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#pragma mark - Notes
//Use this for growing text view without xib

#import <UIKit/UIKit.h>

@class TAPCustomGrowingTextView;

@protocol TAPCustomGrowingTextViewDelegate <NSObject>

@optional

- (BOOL)customGrowingTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)customGrowingTextView:(UITextView *)textView shouldChangeHeight:(CGFloat)height;
- (void)customGrowingTextViewDidBeginEditing:(UITextView *)textView;
- (void)customGrowingTextViewDidEndEditing:(UITextView *)textView;
- (void)customGrowingTextViewDidStartTyping:(UITextView *)textView;
- (void)customGrowingTextViewDidStopTyping:(UITextView *)textView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TAPCustomGrowingTextView : UIView

@property (weak, nonatomic) id<TAPCustomGrowingTextViewDelegate> delegate;

@property (strong, nonatomic) UITextView *textView;

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
- (void)setPlaceholderText:(NSString *)text;
- (void)setTextColor:(UIColor *)color;
- (void)setPlaceholderColor:(UIColor *)color;

- (void)setInputView:(UIView *)inputView;


@end

NS_ASSUME_NONNULL_END
