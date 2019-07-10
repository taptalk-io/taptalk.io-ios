//
//  TAPRoomListView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 6/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

@interface TAPRoomListView : TAPBaseView

@property (strong, nonatomic) UITableView *roomListTableView;
@property (strong, nonatomic) UIButton *startChatNoChatsButton;

- (void)showNoChatsView:(BOOL)isVisible;

@end
