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
    TAPProfileViewControllerTypeGroupMemberProfile = 1
};

@protocol TAPProfileViewControllerDelegate <NSObject>

@optional

- (void)profileViewControllerUpdatedRoom:(TAPRoomModel *)room;
- (void)profileViewControllerDidTriggerLeaveGroupWithRoom:(TAPRoomModel *)room;

@end

@interface TAPProfileViewController : TAPBaseViewController

@property (weak, nonatomic) TAPRoomListViewController *roomListViewController;

@property (weak, nonatomic) id<TAPProfileViewControllerDelegate> delegate;

@property (strong, nonatomic) TAPRoomModel *room;
@property (strong, nonatomic) TAPUserModel *user; //used in TAPProfileViewControllerTypeGroupMemberProfile
@property (strong, nonatomic) NSString *userID;

@property (nonatomic) TAPProfileViewControllerType tapProfileViewControllerType;

@end

NS_ASSUME_NONNULL_END
