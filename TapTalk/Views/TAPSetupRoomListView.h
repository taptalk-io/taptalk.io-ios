//
//  TAPSetupRoomListView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 02/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPSetupRoomListViewType) {
    TAPSetupRoomListViewTypeSettingUp = 0,
    TAPSetupRoomListViewTypeSuccess = 1,
    TAPSetupRoomListViewTypeFailed = 2
};

@interface TAPSetupRoomListView : TAPBaseView

@property (strong, nonatomic) UIButton *retryButton;
- (void)showSetupViewWithType:(TAPSetupRoomListViewType)type;
- (void)showFirstLoadingView:(BOOL)isVisible withType:(TAPSetupRoomListViewType)type;

@end

NS_ASSUME_NONNULL_END
