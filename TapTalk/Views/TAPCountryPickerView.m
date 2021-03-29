//
//  TAPCountryPickerView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 02/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCountryPickerView.h"

@interface TAPCountryPickerView ()

@property (strong, nonatomic) UILabel *titleEmptyStateLabel;
@property (strong, nonatomic) UILabel *descriptionEmptyStateLabel;

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
        self.searchBarView.customPlaceHolderString = NSLocalizedStringFromTableInBundle(@"Search for country", nil, [TAPUtil currentBundle], @"");
        [self.searchBarBackgroundView addSubview:self.searchBarView];
        
        UIFont *searchBarCancelButtonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchBarTextCancelButton];
        UIColor *searchBarCancelButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarTextCancelButton];
        _searchBarCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.searchBarView.frame) + 8.0f, 0.0f, 0.0f, CGRectGetHeight(self.searchBarBackgroundView.frame))];
        NSString *searchBarCancelString = NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"");
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
        
        UIFont *titleEmptyStateLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarButtonLabel];
        UIColor *titleEmptyStateLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorCountryPickerLabel];
        _titleEmptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.searchBarView.frame) + 160.0f, 0.0f, 24.0f)]; //AS NOTE - width will be resized
        self.titleEmptyStateLabel.alpha = 0.0f; //AS NOTE - default value is hidden
        self.titleEmptyStateLabel.text = NSLocalizedStringFromTableInBundle(@"No countries found", nil, [TAPUtil currentBundle], @"");
        NSMutableAttributedString *titleEmptyStateLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:self.titleEmptyStateLabel.text];
        NSMutableDictionary *titleEmptyStateLabelAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat titleEmptyStateLabelLetterSpacing = -0.5f;
        [titleEmptyStateLabelAttributesDictionary setObject:@(titleEmptyStateLabelLetterSpacing) forKey:NSKernAttributeName];
        [titleEmptyStateLabelAttributesDictionary setObject:titleEmptyStateLabelFont forKey:NSFontAttributeName];
        [titleEmptyStateLabelAttributesDictionary setObject:titleEmptyStateLabelColor forKey:NSForegroundColorAttributeName];
        [titleEmptyStateLabelAttributedString addAttributes:titleEmptyStateLabelAttributesDictionary
                                               range:NSMakeRange(0, [self.titleEmptyStateLabel.text length])];
        self.titleEmptyStateLabel.attributedText = titleEmptyStateLabelAttributedString;
        
        CGSize titleEmptyStateLabelSize = [self.titleEmptyStateLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.titleEmptyStateLabel.frame))];
        self.titleEmptyStateLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - titleEmptyStateLabelSize.width) / 2.0f, CGRectGetMinY(self.titleEmptyStateLabel.frame), titleEmptyStateLabelSize.width, CGRectGetHeight(self.titleEmptyStateLabel.frame));
        [self addSubview:self.titleEmptyStateLabel];
        
        UIFont *descriptionEmptyStateLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontActionSheetDestructiveLabel];
        UIColor *descriptionEmptyStateLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarTextPlaceholder];
        _descriptionEmptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.titleEmptyStateLabel.frame) + 4.0f, 0.0f, 24.0f)]; //AS NOTE - width will be resized
        self.descriptionEmptyStateLabel.alpha = 0.0f; //AS NOTE - default value is hidden
        self.descriptionEmptyStateLabel.text = NSLocalizedStringFromTableInBundle(@"Try a different search.", nil, [TAPUtil currentBundle], @"");
        NSMutableAttributedString *descriptionEmptyStateLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:self.descriptionEmptyStateLabel.text];
        NSMutableDictionary *descriptionEmptyStateLabelAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat descriptionEmptyStateLabelLetterSpacing = -0.3f;
        [descriptionEmptyStateLabelAttributesDictionary setObject:@(descriptionEmptyStateLabelLetterSpacing) forKey:NSKernAttributeName];
        [descriptionEmptyStateLabelAttributesDictionary setObject:descriptionEmptyStateLabelFont forKey:NSFontAttributeName];
        [descriptionEmptyStateLabelAttributesDictionary setObject:descriptionEmptyStateLabelColor forKey:NSForegroundColorAttributeName];
        [descriptionEmptyStateLabelAttributedString addAttributes:descriptionEmptyStateLabelAttributesDictionary
                                               range:NSMakeRange(0, [self.descriptionEmptyStateLabel.text length])];
        self.descriptionEmptyStateLabel.attributedText = descriptionEmptyStateLabelAttributedString;
        
        CGSize descriptionEmptyStateLabelSize = [self.descriptionEmptyStateLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.descriptionEmptyStateLabel.frame))];
        self.descriptionEmptyStateLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - descriptionEmptyStateLabelSize.width) / 2.0f, CGRectGetMinY(self.descriptionEmptyStateLabel.frame), descriptionEmptyStateLabelSize.width, CGRectGetHeight(self.descriptionEmptyStateLabel.frame));
        [self addSubview:self.descriptionEmptyStateLabel];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)isShowEmptyState:(BOOL)isShow {
    if (isShow) {
        self.titleEmptyStateLabel.alpha = 1.0f;
        self.descriptionEmptyStateLabel.alpha = 1.0f;
    }
    else {
        self.titleEmptyStateLabel.alpha = 0.0f;
        self.descriptionEmptyStateLabel.alpha = 0.0f;
    }
}

@end
