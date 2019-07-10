//
//  TAPChatViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 10/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"
#import "TAPRoomModel.h"
#import "TAPMediaPreviewModel.h"

typedef NS_ENUM(NSInteger, TAPChatViewControllerType) {
    TAPChatViewControllerTypeDefault = 0,
    TAPChatViewControllerTypePeek = 1
};

@protocol TAPChatViewControllerDelegate <NSObject>

@optional

- (void)chatViewControllerShouldUpdateUnreadBubbleForRoomID:(NSString *)roomID;
- (void)chatViewControllerDidLeaveGroupWithRoom:(TAPRoomModel *)room;

@end

@interface TAPChatViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPChatViewControllerDelegate> delegate;
@property (nonatomic) TAPChatViewControllerType chatViewControllerType;
@property (strong, nonatomic) TAPRoomModel *currentRoom;
@property (strong, nonatomic) NSString *scrollToMessageLocalIDString;

- (void)setChatViewControllerType:(TAPChatViewControllerType)chatViewControllerType;

@end
