//
//  TapUIChatViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 10/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"
#import "TAPRoomModel.h"
#import "TAPMediaPreviewModel.h"

typedef NS_ENUM(NSInteger, TapUIChatViewControllerType) {
    TapUIChatViewControllerTypeDefault = 0,
    TapUIChatViewControllerTypePeek = 1
};

@protocol TAPChatViewControllerDelegate <NSObject>

@optional

/**
 Triggered when chat room will disappear and needs to update unread bubble in TapUIRoomListViewController
 */
- (void)chatViewControllerShouldUpdateUnreadBubbleForRoomID:(NSString *)roomID;

/**
 Triggered to clear unread bubble in TapUIRoomListViewController
 */
- (void)chatViewControllerShouldClearUnreadBubbleForRoomID:(NSString *)roomID;

/**
Triggered when user delete or leave from group and will pass the delegate to TapUIRoomListViewController
*/
- (void)chatViewControllerDidLeaveOrDeleteGroupWithRoom:(TAPRoomModel *)room;

@end

@interface TapUIChatViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPChatViewControllerDelegate> delegate;
@property (nonatomic) TapUIChatViewControllerType chatViewControllerType;
@property (strong, nonatomic) TAPRoomModel *currentRoom;
@property (strong, nonatomic) NSString *scrollToMessageLocalIDString;

- (void)setChatViewControllerType:(TapUIChatViewControllerType)chatViewControllerType;

/**
Initialize chat room with other user or recipient user data

@param otherUser (TAPUserModel *) recipient user data
*/
- (instancetype)initWithOtherUser:(TAPUserModel *)otherUser;

/**
Initialize chat room with room data
 
@param room (TAPRoomModel *) room data
*/
- (instancetype)initWithRoom:(TAPRoomModel *)room;

/**
Initialize chat room with room data and scrolled to selected message
 
@param room (TAPRoomModel *) room data
@param messageLocalID (NSString *) local ID of message that scrolled into when chat is opened
*/
- (instancetype)initWithRoom:(TAPRoomModel *)room scrollToMessageWithLocalID:(NSString *)messageLocalID;

/**
 Show input view / message composer view
 */
- (void)showTapTalkMessageComposerView;

@end
