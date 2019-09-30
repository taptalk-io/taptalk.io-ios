//
//  TAPCreateGroupViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 17/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

typedef NS_ENUM(NSInteger, TAPCreateGroupViewControllerType) {
    TAPCreateGroupViewControllerTypeDefault = 0,
    TAPCreateGroupViewControllerTypeAddMember = 1,
    TAPCreateGroupViewControllerTypeMemberList = 2
};

@protocol TAPCreateGroupViewControllerDelegate <NSObject>

@optional

- (void)createGroupViewControllerUpdatedRoom:(TAPRoomModel *)room;

@end

@interface TAPCreateGroupViewController : TAPBaseViewController

@property (weak, nonatomic) TapUIRoomListViewController *roomListViewController;
@property (weak, nonatomic) id<TAPCreateGroupViewControllerDelegate> delegate;
@property (nonatomic) TAPCreateGroupViewControllerType tapCreateGroupViewControllerType;
@property (strong, nonatomic) TAPRoomModel *room; //used in add members, member list

@end
