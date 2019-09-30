//
//  TAPAddNewChatViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

@protocol TAPAddNewChatViewControllerDelegate <NSObject>

- (void)addNewChatViewControllerShouldOpenNewRoomWithUser:(TAPUserModel *)user;

@end

@interface TAPAddNewChatViewController : TAPBaseViewController

@property (weak, nonatomic) TapUIRoomListViewController *roomListViewController;
@property (weak, nonatomic) id<TAPAddNewChatViewControllerDelegate> delegate;

@end
