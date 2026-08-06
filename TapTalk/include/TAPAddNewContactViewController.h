//
//  TAPAddNewContactViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 17/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"
#import "TAPUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPAddNewContactViewControllerDelegate <NSObject>

- (void)addNewContactViewControllerShouldOpenNewRoomWithUser:(TAPUserModel *)user;

@end

@interface TAPAddNewContactViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPAddNewContactViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
