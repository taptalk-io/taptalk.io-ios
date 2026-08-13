//
//  TAPCustomNotificationAlertViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 23/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"
#import "TAPMessageModel.h"

//@class TAPMessageModel;

NS_ASSUME_NONNULL_BEGIN

@protocol TAPCustomNotificationAlertViewControllerDelegate <NSObject>

- (void)customNotificationAlertViewControllerNotificationButtonDidTappedWithMessage:(TAPMessageModel *)message;
- (void)secondaryCustomNotificationAlertViewControllerNotificationButtonDidTappedWithMessage:(TAPMessageModel *)message;

@end


//@interface TAPCustomNotificationAlertViewController : TAPBaseViewController
@interface TAPCustomNotificationAlertViewController : UIViewController

@property (weak, nonatomic) id<TAPCustomNotificationAlertViewControllerDelegate> delegate;

- (void)showWithMessage:(TAPMessageModel *)message isSchedule:(BOOL)isSchedule;

@end

NS_ASSUME_NONNULL_END
