//
//  TAPForwardListView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 26/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPForwardListView.h"

@interface TAPForwardListView ()

@property (strong, nonatomic) UILabel *recentChatLabel;
@property (strong, nonatomic) UIView *separatorView;

//Empty State
@property (strong, nonatomic) UIView *emptyStateView;
@property (strong, nonatomic) UIImageView *emptyStateImageView;
@property (strong, nonatomic) UILabel *emptyStateLabel;

@end

@implementation TAPForwardListView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        
        _searchBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 46.0f)];
        self.searchBarBackgroundView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.searchBarBackgroundView];
        
        _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.searchBarBackgroundView.frame) - 16.0f - 16.0f, 30.0f)];
        self.searchBarView.backgroundColor = [UIColor whiteColor];
        self.searchBarView.customPlaceHolderString = NSLocalizedString(@"Search", @"");
        [self.searchBarBackgroundView addSubview:self.searchBarView];
        
        _recentChatLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame) + 8.0f, 150.0f, 13.0f)];
        self.recentChatLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
        self.recentChatLabel.textColor = [TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE];
        self.recentChatLabel.text = NSLocalizedString(@"RECENT CHATS", @"");
        [self addSubview:self.recentChatLabel];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.recentChatLabel.frame) + 8.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:@"E4E4E4"];
        [self addSubview:self.separatorView];
        
        _recentChatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.separatorView.frame), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.separatorView.frame))];
        self.recentChatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.recentChatTableView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        [self addSubview:self.recentChatTableView];
        
        _searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.separatorView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.separatorView.frame)) style:UITableViewStyleGrouped];
        self.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.searchResultTableView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        self.searchResultTableView.alpha = 0.0f;
        [self addSubview:self.searchResultTableView];
        
        _emptyStateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.searchBarBackgroundView.frame))];
        self.emptyStateView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        self.emptyStateView.alpha = 0.0f;
        [self addSubview:self.emptyStateView];
        
        _emptyStateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.emptyStateView.frame) - 170.0f) / 2.0f, 35.0f, 170.0f, 170.0f)];
        self.emptyStateImageView.image = [UIImage imageNamed:@"TAPIconEmptySearch" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.emptyStateView addSubview:self.emptyStateImageView];
        
        _emptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.emptyStateImageView.frame) + 10.0f, CGRectGetWidth(self.emptyStateView.frame) - 16.0f - 16.0f, 36.0f)];
        self.emptyStateLabel.text = NSLocalizedString(@"Oops…\nCould not find any results", @"");
        self.emptyStateLabel.font = [UIFont fontWithName:TAP_FONT_NAME_NORMAL size:15.0f];
        NSRange range = [self.emptyStateLabel.text rangeOfString:@"Oops…"];
        //set attribute
        NSMutableAttributedString *emptyAttribuetdString = [[NSMutableAttributedString alloc] initWithString:self.emptyStateLabel.text];
        [emptyAttribuetdString addAttribute:NSFontAttributeName
                                      value:[UIFont fontWithName:TAP_FONT_NAME_BOLD size:15.0f]
                                      range:range];
        self.emptyStateLabel.attributedText = emptyAttribuetdString;
        self.emptyStateLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.emptyStateLabel.numberOfLines = 2;
        self.emptyStateLabel.textAlignment = NSTextAlignmentCenter;
        [self.emptyStateView addSubview:self.emptyStateLabel];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)isShowEmptyState:(BOOL)isShow {
    if (isShow) {
        self.emptyStateView.alpha = 1.0f;
    }
    else {
        self.emptyStateView.alpha = 0.0f;
    }
}

- (void)isShowRecentChatView:(BOOL)isShow animated:(BOOL)isAnimated {
    if (isAnimated) {
        if (isShow) {
            [UIView animateWithDuration:0.2f animations:^{
                self.recentChatLabel.frame = CGRectMake(CGRectGetMinX(self.recentChatLabel.frame), CGRectGetMaxY(self.searchBarBackgroundView.frame) + 8.0f, CGRectGetWidth(self.recentChatLabel.frame), 13.0f);
                
                self.separatorView.frame = CGRectMake(CGRectGetMinX(self.separatorView.frame), CGRectGetMaxY(self.recentChatLabel.frame) + 8.0f, CGRectGetWidth(self.separatorView.frame), 1.0f);
                
                self.recentChatTableView.frame = CGRectMake(CGRectGetMinX(self.recentChatTableView.frame), CGRectGetMaxY(self.separatorView.frame), CGRectGetWidth(self.recentChatTableView.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.separatorView.frame));
                
                self.searchResultTableView.frame = self.recentChatTableView.frame;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.recentChatLabel.frame = CGRectMake(CGRectGetMinX(self.recentChatLabel.frame), CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.recentChatLabel.frame), 0.0f);
                
                self.separatorView.frame = CGRectMake(CGRectGetMinX(self.separatorView.frame), CGRectGetMaxY(self.recentChatLabel.frame), CGRectGetWidth(self.separatorView.frame), 0.0f);
                
                self.recentChatTableView.frame = CGRectMake(CGRectGetMinX(self.recentChatTableView.frame), CGRectGetMaxY(self.separatorView.frame), CGRectGetWidth(self.recentChatTableView.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.separatorView.frame));
                
                self.searchResultTableView.frame = self.recentChatTableView.frame;
            }];
        }
    }
    else {
        if (isShow) {
            self.recentChatLabel.frame = CGRectMake(CGRectGetMinX(self.recentChatLabel.frame), CGRectGetMaxY(self.searchBarBackgroundView.frame) + 8.0f, CGRectGetWidth(self.recentChatLabel.frame), 13.0f);
            
            self.separatorView.frame = CGRectMake(CGRectGetMinX(self.separatorView.frame), CGRectGetMaxY(self.recentChatLabel.frame) + 8.0f, CGRectGetWidth(self.separatorView.frame), 1.0f);
            
            self.recentChatTableView.frame = CGRectMake(CGRectGetMinX(self.recentChatTableView.frame), CGRectGetMaxY(self.separatorView.frame), CGRectGetWidth(self.recentChatTableView.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.separatorView.frame));
            
            self.searchResultTableView.frame = self.recentChatTableView.frame;
        }
        else {
            self.recentChatLabel.frame = CGRectMake(CGRectGetMinX(self.recentChatLabel.frame), CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.recentChatLabel.frame), 0.0f);
            
            self.separatorView.frame = CGRectMake(CGRectGetMinX(self.separatorView.frame), CGRectGetMaxY(self.recentChatLabel.frame), CGRectGetWidth(self.separatorView.frame), 0.0f);
            
            self.recentChatTableView.frame = CGRectMake(CGRectGetMinX(self.recentChatTableView.frame), CGRectGetMaxY(self.separatorView.frame), CGRectGetWidth(self.recentChatTableView.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.separatorView.frame));
            
            self.searchResultTableView.frame = self.recentChatTableView.frame;
        }
    }
}
@end
