//
//  TAPSearchBarView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 3/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAPSearchBarViewDelegate <NSObject>

- (BOOL)searchBarTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)searchBarTextFieldShouldReturn:(UITextField *)textField;
- (BOOL)searchBarTextFieldShouldBeginEditing:(UITextField *)textField;
- (void)searchBarTextFieldDidBeginEditing:(UITextField *)textField;
- (BOOL)searchBarTextFieldShouldEndEditing:(UITextField *)textField;
- (void)searchBarTextFieldDidEndEditing:(UITextField *)textField;
- (BOOL)searchBarTextFieldShouldClear:(UITextField *)textField;

@end

@interface TAPSearchBarView : UIView

@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) NSString *customPlaceHolderString;
@property (weak, nonatomic) id <TAPSearchBarViewDelegate> delegate;

- (void)setAsActive:(BOOL)active animated:(BOOL)animated;
- (void)handleCancelButtonTappedState;

@end

NS_ASSUME_NONNULL_END
