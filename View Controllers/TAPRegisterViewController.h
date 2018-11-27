//
//  TAPRegisterViewController.h
//  TapTalk
//
//  Created by Welly Kencana on 16/8/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

@interface TAPRegisterViewController : TAPBaseViewController

- (void)presentRegisterViewControllerIfNeededFromViewController:(UIViewController *)viewController force:(BOOL)force;

@end
