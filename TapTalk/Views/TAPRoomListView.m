//
//  TAPRoomListView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 6/9/18.
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
        UITabBarController *tabBarController = [[[TapUI sharedInstance] getCurrentTapTalkActiveViewController] tabBarController];
        UITabBar *tabBar = tabBarController.tabBar;
        CGFloat tabbarHeight = CGRectGetHeight(tabBar.frame); //this will return 0 when tabBarController is nil.
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame) - tabbarHeight)];
        self.bgView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        [self addSubview:self.bgView];
        
        _roomListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame))];
        self.roomListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.roomListTableView.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:self.roomListTableView];
        
        _noChatsView = [[UIView alloc] initWithFrame:self.bgView.frame];
        self.noChatsView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.noChatsView.alpha = 0.0f;
        [self.bgView addSubview:self.noChatsView];
        
        UIFont *infoLabelTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelTitle];
        UIColor *infoLabelTitleColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelTitle];
        _titleNoChatsLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 159.0f, CGRectGetWidth(self.noChatsView.frame) - 64.0f - 64.0f, 30.0f)];
        self.titleNoChatsLabel.text = NSLocalizedStringFromTableInBundle(@"No chats to show", nil, [TAPUtil currentBundle], @"");
        self.titleNoChatsLabel.textColor = infoLabelTitleColor;
        self.titleNoChatsLabel.textAlignment = NSTextAlignmentCenter;
        self.titleNoChatsLabel.font = infoLabelTitleFont;
        [self.noChatsView addSubview:self.titleNoChatsLabel];
        
        UIFont *infoLabelBodyFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelBody];
        UIColor *infoLabelBodyColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelBody];
        _descriptionNoChatsLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.titleNoChatsLabel.frame) + 8.0f, CGRectGetWidth(self.noChatsView.frame) - 16.0f - 16.0f, 40.0f)];
        self.descriptionNoChatsLabel.text = NSLocalizedStringFromTableInBundle(@"It seems like you don't have any chats to show, but don't worry! Your chat list will grow once you", nil, [TAPUtil currentBundle], @"");
        self.descriptionNoChatsLabel.textColor = infoLabelBodyColor;
        self.descriptionNoChatsLabel.font = infoLabelBodyFont;
        self.descriptionNoChatsLabel.numberOfLines = 2;
        self.descriptionNoChatsLabel.textAlignment = NSTextAlignmentCenter;
        [self.noChatsView addSubview:self.descriptionNoChatsLabel];
        
        UIFont *clickableLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableLabel];
        UIColor *clickableLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableLabel];
        _startChatNoChatsButton = [[UIButton alloc] initWithFrame:CGRectMake(64.0f, CGRectGetMaxY(self.descriptionNoChatsLabel.frame) + 8.0f, CGRectGetWidth(self.noChatsView.frame) - 64.0f - 64.0f, 40.0f)];
        [self.startChatNoChatsButton setTitle:NSLocalizedStringFromTableInBundle(@"Start a New Chat", nil, [TAPUtil currentBundle], @"") forState:UIControlStateNormal];
        [self.startChatNoChatsButton setTitleColor:clickableLabelColor forState:UIControlStateNormal];
        self.startChatNoChatsButton.titleLabel.font = clickableLabelFont;
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
