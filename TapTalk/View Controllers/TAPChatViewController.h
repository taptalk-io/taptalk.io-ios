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

typedef NS_ENUM(NSInteger, TAPChatViewControllerType) {
    TAPChatViewControllerTypeDefault = 0,
    TAPChatViewControllerTypePeek = 1
};

@protocol TAPChatViewControllerDelegate <NSObject>

@optional

- (void)chatViewControllerShouldUpdateUnreadBubbleForRoomID:(NSString *)roomID;

@end

@interface TAPChatViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPChatViewControllerDelegate> delegate;
@property (nonatomic) TAPChatViewControllerType chatViewControllerType;
@property (strong, nonatomic) TAPRoomModel *currentRoom;

- (void)setChatViewControllerType:(TAPChatViewControllerType)chatViewControllerType;

@end
