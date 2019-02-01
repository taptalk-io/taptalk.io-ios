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
@property (strong, nonatomic) UIImageView *noChatsImageView;
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
        
        _noChatsImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.noChatsView.frame) - 220.0f) / 2.0f, 53.0f, 220.0f, 220.0f)];
        self.noChatsImageView.image = [UIImage imageNamed:@"TAPIconNoChat" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.noChatsImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.noChatsImageView.clipsToBounds = YES;
        [self.noChatsView addSubview:self.noChatsImageView];
        
        _titleNoChatsLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, CGRectGetMaxY(self.noChatsImageView.frame), CGRectGetWidth(self.noChatsView.frame) - 64.0f - 64.0f, 24.0f)];
        self.titleNoChatsLabel.text = NSLocalizedString(@"No Chats", @"");
        self.titleNoChatsLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.titleNoChatsLabel.textAlignment = NSTextAlignmentCenter;
        self.titleNoChatsLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:16.0f];
        [self.noChatsView addSubview:self.titleNoChatsLabel];
        
        _descriptionNoChatsLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, CGRectGetMaxY(self.titleNoChatsLabel.frame), CGRectGetWidth(self.noChatsView.frame) - 64.0f - 64.0f, 38.0f)];
        self.descriptionNoChatsLabel.text = NSLocalizedString(@"You can start a new chat by tapping the icon on the top right corner", @"");
        self.descriptionNoChatsLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        
        self.descriptionNoChatsLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:13.0f];
        self.descriptionNoChatsLabel.numberOfLines = 3;
        NSMutableDictionary *descriptionNoChatsAttributesDictionary = [NSMutableDictionary dictionary];
        NSMutableParagraphStyle *descriptionNoChatsStyle = [[NSMutableParagraphStyle alloc] init];
        descriptionNoChatsStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [descriptionNoChatsStyle setLineSpacing:4];
        [descriptionNoChatsAttributesDictionary setObject:descriptionNoChatsStyle forKey:NSParagraphStyleAttributeName];
        NSMutableAttributedString *descriptionNoChatsAttributedString = [[NSMutableAttributedString alloc] initWithString:self.descriptionNoChatsLabel.text];
        [descriptionNoChatsAttributedString addAttributes:descriptionNoChatsAttributesDictionary
                                                    range:NSMakeRange(0, [self.descriptionNoChatsLabel.text length])];
        self.descriptionNoChatsLabel.attributedText = descriptionNoChatsAttributedString;
        self.descriptionNoChatsLabel.textAlignment = NSTextAlignmentCenter;
        [self.noChatsView addSubview:self.descriptionNoChatsLabel];
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
