//
//  TAPPopUpInfoViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 19/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"
#import "TAPPopUpInfoView.h"

typedef NS_ENUM(NSInteger, TAPPopUpInfoViewControllerType) {
    TAPPopUpInfoViewControllerTypeErrorMessage, // 1 button red
    TAPPopUpInfoViewControllerTypeSuccessMessage, // 1 button green
    TAPPopUpInfoViewControllerTypeInfoDefault, // 2 button (grey, green)
    TAPPopUpInfoViewControllerTypeInfoDestructive, // 2 button (grey, red)
};

@protocol TAPPopUpInfoViewControllerDelegate <NSObject>

- (void)popUpInfoViewControllerDidTappedLeftButtonWithIdentifier:(NSString *)identifier;
- (void)popUpInfoViewControllerDidTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TAPPopUpInfoViewController : UIViewController

@property (weak, nonatomic) id <TAPPopUpInfoViewControllerDelegate> delegate;
@property (strong, nonatomic) TAPPopUpInfoView *popUpInfoView;
@property (nonatomic) TAPPopUpInfoViewControllerType popUpInfoViewControllerType;
@property (strong, nonatomic) NSString *titleInformation;
@property (strong, nonatomic) NSString *detailInformation;
@property (strong, nonatomic) NSString *popupIdentifier;

- (void)setPopUpInfoViewControllerType:(TAPPopUpInfoViewControllerType)popUpInfoViewControllerType withTitle:(NSString *)title detailInformation:(NSString *)detailInfo leftOptionButtonTitle:(NSString * __nullable)leftOptionTitle singleOrRightOptionButtonTitle:(NSString * __nullable)singleOrRightOptionTitle;

- (void)showPopupInfoView:(BOOL)isShow animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
