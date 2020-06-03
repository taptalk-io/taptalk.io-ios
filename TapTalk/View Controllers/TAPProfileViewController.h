//
//  TAPProfileViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM( NSInteger, TAPProfileViewControllerType) {
    TAPProfileViewControllerTypeDefault = 0,
    TAPProfileViewControllerTypeGroupMemberProfile = 1,
    TAPProfileViewControllerTypePersonalFromClickedMention = 2
};

@protocol TAPProfileViewControllerDelegate <NSObject>

@optional

- (void)profileViewControllerUpdatedRoom:(TAPRoomModel *)room;
- (void)profileViewControllerDidTriggerLeaveOrDeleteGroupWithRoom:(TAPRoomModel *)room;

@end

@interface TAPProfileViewController : TAPBaseViewController

@property (weak, nonatomic) TapUIRoomListViewController *roomListViewController;

@property (weak, nonatomic) id<TAPProfileViewControllerDelegate> delegate;

@property (strong, nonatomic) TAPRoomModel *room;
@property (strong, nonatomic) TAPUserModel *user; //used in TAPProfileViewControllerTypeGroupMemberProfile
@property (strong, nonatomic) NSString *otherUserID;

@property (nonatomic) TAPProfileViewControllerType tapProfileViewControllerType;

@end

NS_ASSUME_NONNULL_END
