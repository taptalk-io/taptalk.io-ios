//
//  TAPMyAccountViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 04/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPMyAccountViewControllerDelegate <NSObject>

- (void)myAccountViewControllerDidTappedLogoutButton;
- (void)myAccountViewControllerDoneChangingImageProfile;

@end

@interface TAPMyAccountViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPMyAccountViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
