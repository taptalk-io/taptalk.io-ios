//
//  TAPRoomListView.m
//  TapTalk
//
//  Created by Welly Kencana on 6/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPRoomListView.h"

@interface TAPRoomListView()
@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) UIView *noChatsView;
@property (strong, nonatomic) UILabel *titleNoChatsLabel;
@property (strong, nonatomic) UILabel *descriptionNoChatsLabel;
@end

@implementation TAPRoomListView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        UITabBarController *tabBarController = [[[TapTalk sharedInstance] getCurrentTapTalkActiveViewController] tabBarController];
        UITabBar *tabBar = tabBarController.tabBar;
        CGFloat tabbarHeight = CGRectGetHeight(tabBar.frame); //this will return 0 when tabBarController is nil.
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame) - tabbarHeight)];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bgView];
        
        _roomListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame))];
        self.roomListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.bgView addSubview:self.roomListTableView];
        
        _noChatsView = [[UIView alloc] initWithFrame:self.bgView.frame];
        self.noChatsView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        self.noChatsView.alpha = 0.0f;
        [self.bgView addSubview:self.noChatsView];
        
        _titleNoChatsLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 159.0f, CGRectGetWidth(self.noChatsView.frame) - 64.0f - 64.0f, 30.0f)];
        self.titleNoChatsLabel.text = NSLocalizedString(@"No chats to show", @"");
        self.titleNoChatsLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
        self.titleNoChatsLabel.textAlignment = NSTextAlignmentCenter;
        self.titleNoChatsLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:24.0f];
        [self.noChatsView addSubview:self.titleNoChatsLabel];
        
        _descriptionNoChatsLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.titleNoChatsLabel.frame) + 8.0f, CGRectGetWidth(self.noChatsView.frame) - 16.0f - 16.0f, 40.0f)];
        self.descriptionNoChatsLabel.text = NSLocalizedString(@"It seems like you don't have any chats to show, but don't worry! Your chat list will grow once you", @"");
        self.descriptionNoChatsLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
        self.descriptionNoChatsLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:14.0f];
        self.descriptionNoChatsLabel.numberOfLines = 2;
        self.descriptionNoChatsLabel.textAlignment = NSTextAlignmentCenter;
        [self.noChatsView addSubview:self.descriptionNoChatsLabel];
        
        _startChatNoChatsButton = [[UIButton alloc] initWithFrame:CGRectMake(64.0f, CGRectGetMaxY(self.descriptionNoChatsLabel.frame) + 8.0f, CGRectGetWidth(self.noChatsView.frame) - 64.0f - 64.0f, 40.0f)];
        [self.startChatNoChatsButton setTitle:NSLocalizedString(@"Start a New Chat", @"") forState:UIControlStateNormal];
        [self.startChatNoChatsButton setTitleColor:[TAPUtil getColor:TAP_COLOR_ORANGE_00] forState:UIControlStateNormal];
        self.startChatNoChatsButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:16.0f];
        [self.noChatsView addSubview:self.startChatNoChatsButton];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)showNoChatsView:(BOOL)isVisible {
    if (isVisible && self.noChatsView.alpha != 1.0f) {
        self.noChatsView.alpha = 1.0f;
    }
    else if (!isVisible && self.noChatsView.alpha != 0.0f) {
        self.noChatsView.alpha = 0.0f;
    }
}

@end
