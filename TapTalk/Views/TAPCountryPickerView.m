//
//  TAPCountryPickerView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 02/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCountryPickerView.h"

@interface TAPCountryPickerView ()

@end

@implementation TAPCountryPickerView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _searchBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 52.0f)];
        self.searchBarBackgroundView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.searchBarBackgroundView];
        
        _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.searchBarBackgroundView.frame) - 16.0f - 16.0f, 36.0f)];
        self.searchBarView.customPlaceHolderString = NSLocalizedString(@"Search for country", @"");
        [self.searchBarBackgroundView addSubview:self.searchBarView];
        
        UIFont *searchBarCancelButtonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchBarTextCancelButton];
        UIColor *searchBarCancelButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarTextCancelButton];
        _searchBarCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.searchBarView.frame) + 8.0f, 0.0f, 0.0f, CGRectGetHeight(self.searchBarBackgroundView.frame))];
        NSString *searchBarCancelString = NSLocalizedString(@"Cancel", @"");
        NSMutableAttributedString *searchBarCancelAttributedString = [[NSMutableAttributedString alloc] initWithString:searchBarCancelString];
        NSMutableDictionary *searchBarCancelAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat searchBarCancelLetterSpacing = -0.4f;
        [searchBarCancelAttributesDictionary setObject:@(searchBarCancelLetterSpacing) forKey:NSKernAttributeName];
        [searchBarCancelAttributesDictionary setObject:searchBarCancelButtonFont forKey:NSFontAttributeName];
        [searchBarCancelAttributesDictionary setObject:searchBarCancelButtonColor forKey:NSForegroundColorAttributeName];
        [searchBarCancelAttributedString addAttributes:searchBarCancelAttributesDictionary
                                                 range:NSMakeRange(0, [searchBarCancelString length])];
        [self.searchBarCancelButton setAttributedTitle:searchBarCancelAttributedString forState:UIControlStateNormal];
        self.searchBarCancelButton.clipsToBounds = YES;
        [self.searchBarBackgroundView addSubview:self.searchBarCancelButton];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(self.searchBarBackgroundView.frame)) style:UITableViewStylePlain];
        self.tableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView setSectionIndexColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTableViewSectionIndex]];
        [self.tableView setInsetsContentViewsToSafeArea:YES];
        [self addSubview:self.tableView];
        
        _searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(self.searchBarBackgroundView.frame)) style:UITableViewStylePlain];
        self.searchResultTableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.searchResultTableView setSectionIndexColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTableViewSectionIndex]];
        self.searchResultTableView.alpha = 0.0f;
        [self.searchResultTableView setInsetsContentViewsToSafeArea:YES];
        [self addSubview:self.searchResultTableView];
    }
    
    return self;
}

@end
