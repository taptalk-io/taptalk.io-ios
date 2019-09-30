//
//  TAPCreateGroupSubjectViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 19/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPCreateGroupSubjectViewControllerType) {
    TAPCreateGroupSubjectViewControllerTypeDefault = 0,
    TAPCreateGroupSubjectViewControllerTypeUpdate = 1
};

@protocol TAPCreateGroupSubjectViewControllerDelegate <NSObject>

@optional

- (void)createGroupSubjectViewControllerUpdatedRoom:(TAPRoomModel *)room;

@end

@interface TAPCreateGroupSubjectViewController : TAPBaseViewController

@property (weak, nonatomic) TapUIRoomListViewController *roomListViewController;
@property (weak, nonatomic) id<TAPCreateGroupSubjectViewControllerDelegate> delegate;
@property (weak, nonatomic) TAPRoomModel *roomModel;
@property (strong, nonatomic) NSArray *selectedContactArray;
@property (nonatomic) TAPCreateGroupSubjectViewControllerType tapCreateGroupSubjectControllerType;

@end

NS_ASSUME_NONNULL_END
