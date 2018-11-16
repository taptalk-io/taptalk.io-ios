//
//  TAPCustomNotificationAlertViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 23/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

@class TAPMessageModel;

NS_ASSUME_NONNULL_BEGIN

@protocol TAPCustomNotificationAlertViewControllerDelegate <NSObject>

- (void)customNotificationAlertViewControllerNotificationButtonDidTappedWithMessage:(TAPMessageModel *)message;
- (void)secondaryCustomNotificationAlertViewControllerNotificationButtonDidTappedWithMessage:(TAPMessageModel *)message;

@end


@interface TAPCustomNotificationAlertViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPCustomNotificationAlertViewControllerDelegate> delegate;

- (void)showWithMessage:(TAPMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
