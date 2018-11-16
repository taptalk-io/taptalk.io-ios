//
//  TAPBaseViewController.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 2/23/16.
//  Copyright © 2016 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPPopUpInfoViewController.h"

@interface TAPBaseViewController : UIViewController

- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight;
- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight;
- (void)showCustomBackButton;
- (void)reachabilityChangeIsReachable:(BOOL)reachable;
- (void)showPopupView:(BOOL)isVisible withPopupType:(TAPPopUpInfoViewControllerType *)type title:(NSString *)title detailInformation:(NSString *)detailInfo;
- (void)popUpInfoDidTappedLeftButton;
- (void)popUpInfoTappedSingleButtonOrRightButton;

@end
