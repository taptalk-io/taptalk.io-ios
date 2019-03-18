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
    TAPPopUpInfoViewControllerTypeErrorMessage,
};

@protocol TAPPopUpInfoViewControllerDelegate <NSObject>

- (void)popUpInfoViewControllerDidTappedLeftButton;
- (void)popUpInfoViewControllerDidTappedSingleButtonOrRightButton;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TAPPopUpInfoViewController : UIViewController

@property (weak, nonatomic) id <TAPPopUpInfoViewControllerDelegate> delegate;
@property (strong, nonatomic) TAPPopUpInfoView *popUpInfoView;
@property (nonatomic) TAPPopUpInfoViewControllerType popUpInfoViewControllerType;
@property (strong, nonatomic) NSString *titleInformation;
@property (strong, nonatomic) NSString *detailInformation;

- (void)setPopUpInfoViewControllerType:(TAPPopUpInfoViewControllerType)popUpInfoViewControllerType withTitle:(NSString *)title detailInformation:(NSString *)detailInfo;
- (void)showPopupInfoView:(BOOL)isShow animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
