//
//  TAPSearchView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 20/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPSearchView.h"

@interface TAPSearchView ()

@property (strong, nonatomic) UILabel *recentSearchLabel;
@property (strong, nonatomic) UILabel *clearHistoryLabel;
@property (strong, nonatomic) UIView *separatorView;

//Empty State
@property (strong, nonatomic) UIView *emptyStateView;
@property (strong, nonatomic) UIImageView *emptyStateImageView;
@property (strong, nonatomic) UILabel *emptyStateLabel;

@end

@implementation TAPSearchView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        
        UIFont *sectionHeaderLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
        UIColor *sectionHeaderLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTableViewSectionHeaderLabel];
        _recentSearchLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 8.0f, 150.0f, 13.0f)];
        self.recentSearchLabel.font = sectionHeaderLabelFont;
        self.recentSearchLabel.textColor = sectionHeaderLabelColor;
        self.recentSearchLabel.text = NSLocalizedStringFromTableInBundle(@"RECENT", nil, [TAPUtil currentBundle], @"");
        
        NSMutableAttributedString *recentSearchLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:self.recentSearchLabel.text];
        [recentSearchLabelAttributedString addAttribute:NSKernAttributeName
                                             value:@1.5f
                                             range:NSMakeRange(0, [self.recentSearchLabel.text length])];
        
        self.recentSearchLabel.attributedText = recentSearchLabelAttributedString;
        [self addSubview:self.recentSearchLabel];
        
        _clearHistoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 150.0f, 8.0f, 150.0f, 13.0f)];
        self.clearHistoryLabel.font = sectionHeaderLabelFont;
        self.clearHistoryLabel.text = @"CLEAR HISTORY";
        self.clearHistoryLabel.textColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchClearHistoryLabel];
        self.clearHistoryLabel.textAlignment = NSTextAlignmentRight;
        
        NSMutableAttributedString *clearHistoryLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:self.clearHistoryLabel.text];
        
        [clearHistoryLabelAttributedString addAttribute:NSKernAttributeName
                                                  value:@1.5f
                                                  range:NSMakeRange(0, [self.clearHistoryLabel.text length])];
        
        self.clearHistoryLabel.attributedText = clearHistoryLabelAttributedString;

        CGSize clearHistorySize = [self.clearHistoryLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.clearHistoryLabel.frame))];
        self.clearHistoryLabel.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - clearHistorySize.width, CGRectGetMinY(self.clearHistoryLabel.frame), clearHistorySize.width, CGRectGetHeight(self.clearHistoryLabel.frame));
        [self addSubview:self.clearHistoryLabel];
        
        _clearHistoryButton = [[UIButton alloc] initWithFrame:self.clearHistoryLabel.frame];
        [self addSubview:self.clearHistoryButton];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.recentSearchLabel.frame) + 8.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self addSubview:self.separatorView];
        
        _recentSearchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.separatorView.frame), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.separatorView.frame))];
        self.recentSearchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.recentSearchTableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        [self addSubview:self.recentSearchTableView];
        
        _searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame)) style:UITableViewStyleGrouped];
        self.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.searchResultTableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.searchResultTableView.alpha = 0.0f;
        [self addSubview:self.searchResultTableView];
        
        _emptyStateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.emptyStateView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.emptyStateView.alpha = 0.0f;
        [self addSubview:self.emptyStateView];
        
        //DV Note
        //Temporary remove asset to change not from moselo style
        //        _emptyStateImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.emptyStateView.frame) - 170.0f) / 2.0f, 35.0f, 170.0f, 170.0f)];
        //        self.emptyStateImageView.image = [UIImage imageNamed:@"TAPIconEmptySearch" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        //        [self.emptyStateView addSubview:self.emptyStateImageView];
        
        //        _emptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.emptyStateImageView.frame) + 10.0f, CGRectGetWidth(self.emptyStateView.frame) - 16.0f - 16.0f, 40.0f)];
        //        self.emptyStateLabel.text = NSLocalizedStringFromTableInBundle(@"Oops…\nCould not find any results", nil, [TAPUtil currentBundle], @"");
        //        self.emptyStateLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:15.0f];
        //        NSRange range = [self.emptyStateLabel.text rangeOfString:@"Oops…"];
        //        //set attribute
        //        NSMutableAttributedString *emptyAttribuetdString = [[NSMutableAttributedString alloc] initWithString:self.emptyStateLabel.text];
        //        [emptyAttribuetdString addAttribute:NSFontAttributeName
        //                                      value:[UIFont fontWithName:TAP_FONT_NAME_BOLD size:15.0f]
        //                                      range:range];
        //        self.emptyStateLabel.attributedText = emptyAttribuetdString;
        //        self.emptyStateLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
        //        self.emptyStateLabel.numberOfLines = 2;
        //        self.emptyStateLabel.textAlignment = NSTextAlignmentCenter;
        //        [self.emptyStateView addSubview:self.emptyStateLabel];
        //END DV Note
        
        UIFont *infoLabelTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelTitle];
        UIColor *infoLabelTitleColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelTitle];
        UIFont *infoLabelBodyFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelBody];

        _emptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.emptyStateImageView.frame) + 10.0f, CGRectGetWidth(self.emptyStateView.frame) - 16.0f - 16.0f, 60.0f)];
        self.emptyStateLabel.text = NSLocalizedStringFromTableInBundle(@"Oops…\nCould not find any results", nil, [TAPUtil currentBundle], @"");
        self.emptyStateLabel.font = infoLabelBodyFont;
        NSRange range = [self.emptyStateLabel.text rangeOfString:@"Oops…"];
        //set attribute
        NSMutableAttributedString *emptyAttribuetdString = [[NSMutableAttributedString alloc] initWithString:self.emptyStateLabel.text];
        [emptyAttribuetdString addAttribute:NSFontAttributeName
                                      value:infoLabelTitleFont
                                      range:range];
        self.emptyStateLabel.attributedText = emptyAttribuetdString;
        self.emptyStateLabel.textColor = infoLabelTitleColor;
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
@end
