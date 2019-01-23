//
//  TAPChatViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 10/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"
#import "TAPRoomModel.h"
#import "TAPImagePreviewModel.h"

@protocol TAPChatViewControllerDelegate <NSObject>

@optional

- (void)chatViewControllerShouldUpdateUnreadBubbleForRoomID:(NSString *)roomID;

@end

@interface TAPChatViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPChatViewControllerDelegate> delegate;
@property (strong, nonatomic) TAPRoomModel *currentRoom;

@end
