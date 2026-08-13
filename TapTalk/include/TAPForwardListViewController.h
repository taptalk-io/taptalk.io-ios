//
//  TAPForwardListViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 26/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPForwardListViewController : TAPBaseViewController

@property (weak, nonatomic) UINavigationController *currentNavigationController;
@property (strong, nonatomic) NSArray *forwardedMessages;

@end

NS_ASSUME_NONNULL_END
