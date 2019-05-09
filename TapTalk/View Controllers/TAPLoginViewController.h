//
//  TAPLoginViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPLoginViewController : TAPBaseViewController

- (void)presentLoginViewControllerIfNeededFromViewController:(UIViewController *)viewController force:(BOOL)force;

@end

NS_ASSUME_NONNULL_END
