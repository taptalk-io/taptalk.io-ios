//
//  TAPBaseViewController.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 2/23/16.
//  Copyright © 2016 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TapTalkSnackBarType) {
    TapTalkSnackBarTypeDefault,
    TapTalkSnackBarTypeError,
    TapTalkSnackBarTypeToast,
};

typedef NS_ENUM(NSInteger, TAPPopUpInfoViewControllerType) {
    TAPPopUpInfoViewControllerTypeErrorMessage, // 1 button red
    TAPPopUpInfoViewControllerTypeSuccessMessage, // 1 button green
    TAPPopUpInfoViewControllerTypeInfoDefault, // 2 button (grey, green)
    TAPPopUpInfoViewControllerTypeInfoDestructive, // 2 button (grey, red)
};

@interface TAPBaseViewController : UIViewController

- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight;
- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight;
- (void)showCustomBackButton;
- (void)showCustomBackButtonOrange;
- (void)showCustomCloseButton;
- (void)showCustomCancelButton;
- (void)showCustomEditButton;
- (void)showCustomCancelButtonRight;
- (void)reachabilityChangeIsReachable:(BOOL)reachable;
- (void)showSnackBar:(TapTalkSnackBarType)type message:(NSString *_Nonnull)message iconName:(NSString *_Nullable)iconName;
- (void)showSnackBar:(TapTalkSnackBarType)type message:(NSString *_Nonnull)message iconName:(NSString *_Nullable)iconName showDuration:(CGFloat)showDuration animationDuration:(CGFloat)animationDuration;
- (void)showPopupViewWithPopupType:(TAPPopUpInfoViewControllerType)type popupIdentifier:(NSString * _Nonnull)popupIdentifier title:(NSString * _Nonnull)title detailInformation:(NSString * _Nonnull)detailInfo leftOptionButtonTitle:(NSString * __nullable)leftOptionString singleOrRightOptionButtonTitle:(NSString * __nullable)singleOrRightOptionString;
- (void)popUpInfoDidTappedLeftButtonWithIdentifier:(NSString * _Nonnull)popupIdentifier;
- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString * _Nonnull)popupIdentifier;
- (void)showNavigationSeparator:(BOOL)show;

@end
