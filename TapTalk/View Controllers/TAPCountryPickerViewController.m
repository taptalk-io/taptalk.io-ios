//
//  TAPCountryPickerViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 02/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCountryPickerViewController.h"
#import "TAPCountryPickerView.h"
#import "TAPCountryPickerTableViewCell.h"

@interface TAPCountryPickerViewController () <UITableViewDelegate, UITableViewDataSource, TAPSearchBarViewDelegate>

@property (strong, nonatomic) TAPCountryPickerView *countryPickerView;

@property (strong, nonatomic) UIButton *leftBarButton;

@property (strong, nonatomic) NSArray *alphabetSectionTitles;
@property (strong, nonatomic) NSMutableDictionary *indexSectionDictionary;
@property (strong, nonatomic) NSArray *countryListArray;

@property (strong, nonatomic) NSMutableDictionary *searchResultIndexSectionDictionary;
@property (strong, nonatomic) NSMutableArray *searchResultCountryMutableArray;

@property (strong, nonatomic) NSString *updatedString;

- (void)closeButtonDidTapped;
- (void)searchBarCancelButtonDidTapped;
- (void)fetchCountryListWithData:(NSArray *)countryDataArray;
- (void)fetchSearchResultCountryListWithData:(NSArray *)countryDataArray;

@end

@implementation TAPCountryPickerViewController
#pragma mark - Lifecycle

- (void)loadView {
    [super loadView];
    _countryPickerView = [[TAPCountryPickerView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.countryPickerView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIFont *navigationBarButtonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarButtonLabel];
    UIColor *navigationBarButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarButtonLabel];
    
    _leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [self.leftBarButton setTitle:@"Close" forState:UIControlStateNormal];
    [self.leftBarButton setTitleColor:navigationBarButtonColor forState:UIControlStateNormal];
    self.leftBarButton.titleLabel.font = navigationBarButtonFont;
    [self.leftBarButton addTarget:self action:@selector(closeButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBarButton];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    
    [self.countryPickerView.searchBarCancelButton addTarget:self action:@selector(searchBarCancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _indexSectionDictionary = [[NSMutableDictionary alloc] init];
    _searchResultCountryMutableArray = [[NSMutableArray alloc] init];
    _searchResultIndexSectionDictionary = [[NSMutableArray alloc] init];
    _countryListArray = [[NSArray alloc] init];
    _updatedString = @"";
    
    self.title = NSLocalizedStringFromTableInBundle(@"Select Country", nil, [TAPUtil currentBundle], @"");
    
    if (@available(iOS 15.0, *)) {
        [self.countryPickerView.searchResultTableView setSectionHeaderTopPadding:0.0f];
    }
    
    self.countryPickerView.searchBarView.delegate = self;
    self.countryPickerView.tableView.delegate = self;
    self.countryPickerView.tableView.dataSource = self;
    self.countryPickerView.searchResultTableView.delegate = self;
    self.countryPickerView.searchResultTableView.dataSource = self;
    
    _alphabetSectionTitles = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    [self fetchCountryListWithData:self.countryDataArray];
    
    if (IS_IOS_13_OR_ABOVE) {
        self.countryPickerView.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, [TAPUtil topGapPresentingViewController], 0.0f);
        self.countryPickerView.searchResultTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, [TAPUtil topGapPresentingViewController], 0.0f);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self showNavigationSeparator:NO];
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.countryPickerView.tableView) {
         return [self.indexSectionDictionary count];
    }
    else if (tableView == self.countryPickerView.searchResultTableView) {
        return [self.searchResultIndexSectionDictionary count];
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.countryPickerView.tableView) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        NSString *key = [keysArray objectAtIndex:section];
        NSArray *countryArray = [self.indexSectionDictionary objectForKey:key];
        return [countryArray count];
    }
    else if (tableView == self.countryPickerView.searchResultTableView) {
        NSArray *keysArray = [self.searchResultIndexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        NSString *key = [keysArray objectAtIndex:section];
        NSArray *countryArray = [self.searchResultIndexSectionDictionary objectForKey:key];
        return [countryArray count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.countryPickerView.tableView) {
        static NSString *cellID = @"TAPCountryPickerTableViewCell";
        TAPCountryPickerTableViewCell *cell = [[TAPCountryPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        NSString *key = [keysArray objectAtIndex:indexPath.section];
        NSArray *countryArray = [self.indexSectionDictionary objectForKey:key];
        TAPCountryModel *currentCountry = [countryArray objectAtIndex:indexPath.row];
        [cell setCountryData:currentCountry];
        
//        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
//            [cell showSeparatorView:NO];
//        }
//        else {
//            [cell showSeparatorView:YES];
//        }
        
        if (self.selectedCountry.countryID != nil) {
            NSString *selectedCountryID = self.selectedCountry.countryID;
            NSString *currentCountryID = currentCountry.countryID;
            if ([selectedCountryID isEqualToString:currentCountryID]) {
                [cell setAsSelected:YES animated:NO];
            }
            else {
                [cell setAsSelected:NO animated:NO];
            }
        }
        
        return cell;
    }
    else if (tableView == self.countryPickerView.searchResultTableView) {
        static NSString *cellID = @"TAPCountryPickerTableViewCell";
        TAPCountryPickerTableViewCell *cell = [[TAPCountryPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        NSArray *keysArray = [self.searchResultIndexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        NSString *key = [keysArray objectAtIndex:indexPath.section];
        NSArray *countryArray = [self.searchResultIndexSectionDictionary objectForKey:key];
        TAPCountryModel *currentCountry = [countryArray objectAtIndex:indexPath.row];
        [cell setCountryData:currentCountry];
        
//        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
//            [cell showSeparatorView:NO];
//        }
//        else {
//            [cell showSeparatorView:YES];
//        }
        
        if (self.selectedCountry.countryID != nil) {
            NSString *selectedCountryID = self.selectedCountry.countryID;
            NSString *currentCountryID = currentCountry.countryID;
            if ([selectedCountryID isEqualToString:currentCountryID]) {
                [cell setAsSelected:YES animated:NO];
            }
            else {
                [cell setAsSelected:NO animated:NO];
            }
        }
        
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.countryPickerView.tableView) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 28.0f)];
        headerView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        
        if (section > 0) {
//            UIView *topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(headerView.frame), 1.0f)];
//            topSeparatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
//            [headerView addSubview:topSeparatorView];
        }
        
//        UIView *bottomSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(headerView.frame) - 1.0f, CGRectGetWidth(headerView.frame), 1.0f)];
//        bottomSeparatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
//        [headerView addSubview:bottomSeparatorView];
        
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        UIFont *sectionHeaderFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
        UIColor *sectionHeaderColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTableViewSectionHeaderLabel];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(headerView.frame) - 16.0f - 16.0f, CGRectGetHeight(headerView.frame))];
        titleLabel.textColor = sectionHeaderColor;
        titleLabel.font = sectionHeaderFont;
        [headerView addSubview:titleLabel];
        
        if ([keysArray count] != 0) {
            titleLabel.text = [keysArray objectAtIndex:section];
        }
        
        return headerView;
    }
    else if (tableView == self.countryPickerView.searchResultTableView) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 28.0f)];
        headerView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        
//        UIView *topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(headerView.frame), 1.0f)];
//        topSeparatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
//        [headerView addSubview:topSeparatorView];
        
//        UIView *bottomSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(headerView.frame) - 1.0f, CGRectGetWidth(headerView.frame), 1.0f)];
//        bottomSeparatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
//        [headerView addSubview:bottomSeparatorView];
        
        NSArray *keysArray = [self.searchResultIndexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        UIFont *sectionHeaderFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
        UIColor *sectionHeaderColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTableViewSectionHeaderLabel];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(headerView.frame) - 16.0f - 16.0f, CGRectGetHeight(headerView.frame))];
        titleLabel.textColor = sectionHeaderColor;
        titleLabel.font = sectionHeaderFont;
        [headerView addSubview:titleLabel];
        
        if ([keysArray count] != 0) {
            titleLabel.text = [keysArray objectAtIndex:section];
        }
        
        return headerView;
    }
    
    UIView *header = [[UIView alloc] init];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] init];
    return footer;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.countryPickerView.tableView) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        return [keysArray objectAtIndex:section];
    }
    else if (tableView == self.countryPickerView.searchResultTableView) {
        NSArray *keysArray = [self.searchResultIndexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        return [keysArray objectAtIndex:section];
    }
    
    return @"";
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.countryPickerView.tableView && [self.indexSectionDictionary count] >= 5) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        return keysArray;
    }
    
    NSArray *sectionIndexArray = [NSArray array];
    return sectionIndexArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.countryPickerView.tableView) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        //        return [keysArray indexOfObject:title] + 1;
        return [keysArray indexOfObject:title];
    }
    
    return 0;
}

#pragma mark - Delegate
#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TAPCountryModel *currentCountry;
    if (tableView == self.countryPickerView.tableView) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        NSString *key = [keysArray objectAtIndex:indexPath.section];
        NSArray *countryArray = [self.indexSectionDictionary objectForKey:key];
        currentCountry = [countryArray objectAtIndex:indexPath.row];
    }
    else if (tableView == self.countryPickerView.searchResultTableView) {
        NSArray *keysArray = [self.searchResultIndexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        NSString *key = [keysArray objectAtIndex:indexPath.section];
        NSArray *countryArray = [self.searchResultIndexSectionDictionary objectForKey:key];
        currentCountry = [countryArray objectAtIndex:indexPath.row];
    }
    
    if (self.selectedCountry.countryID == currentCountry.countryID) {
        TAPCountryPickerTableViewCell *cell = (TAPCountryPickerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setAsSelected:NO animated:YES];
    }
    else {
        TAPCountryPickerTableViewCell *cell = (TAPCountryPickerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setAsSelected:YES animated:YES];
    }
    
    _selectedCountry = currentCountry;
    
    if ([self.delegate respondsToSelector:@selector(countryPickerDidSelectCountryWithData:)]) {
        [self.delegate countryPickerDidSelectCountryWithData:currentCountry];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark TAPSearchBarView
- (BOOL)searchBarTextFieldShouldBeginEditing:(UITextField *)textField {
    
    [self.countryPickerView.searchBarView setAsActive:YES animated:NO]; //AS NOTE - CHANGE TO WITHOUT ANIMATION
    
    if ([textField.text isEqualToString:@""]) {
        if (textField == self.countryPickerView.searchBarView.searchTextField) {
            [UIView animateWithDuration:0.3f animations:^{
                CGRect searchBarViewFrame = self.countryPickerView.searchBarView.frame;
                searchBarViewFrame.size.width = CGRectGetWidth(self.countryPickerView.searchBarView.frame) - 70.0f;
                self.countryPickerView.searchBarView.frame = searchBarViewFrame;

                CGRect searchBarCancelButtonFrame = self.countryPickerView.searchBarCancelButton.frame;
                searchBarCancelButtonFrame.origin.x = CGRectGetMaxX(searchBarViewFrame) + 8.0f;
                searchBarCancelButtonFrame.size.width = 70.0f;
                self.countryPickerView.searchBarCancelButton.frame = searchBarCancelButtonFrame;
            } completion:^(BOOL finished) {
                //completion
                [self.searchResultCountryMutableArray removeAllObjects];
                [self.countryPickerView.tableView reloadData];
            }];
        }
    }

    return YES;
}

- (BOOL)searchBarTextFieldShouldEndEditing:(UITextField *)textField {
    
    [self.countryPickerView.searchBarView setAsActive:NO animated:NO]; //AS NOTE - CHANGE TO WITHOUT ANIMATION
    
    return YES;
}

- (BOOL)searchBarTextFieldShouldClear:(UITextField *)textField {
    [self.searchResultCountryMutableArray removeAllObjects];
    [self.searchResultIndexSectionDictionary removeAllObjects];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.countryPickerView.searchResultTableView.alpha = 0.0f;
        
        if ([self.indexSectionDictionary count] > 0) {
            self.countryPickerView.tableView.alpha = 1.0f;
            [self.countryPickerView isShowEmptyState:NO];
        }
        else {
            self.countryPickerView.tableView.alpha = 0.0f;
            [self.countryPickerView isShowEmptyState:YES];
        }
    } completion:^(BOOL finished) {
        //completion
        [self.countryPickerView.searchResultTableView reloadData];
    }];
    
    return YES;
}

- (BOOL)searchBarTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *trimmedNewString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![trimmedNewString isEqualToString:@""]) {
        self.updatedString = newString;
        
        [self.searchResultCountryMutableArray removeAllObjects];
        _searchResultIndexSectionDictionary = [NSMutableDictionary dictionary];
        
        NSString *trimmedString = [self.updatedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        for (NSInteger counter = 0; counter < [self.countryListArray count]; counter++) {
            TAPCountryModel *currentLoopCountry = [self.countryListArray objectAtIndex:counter];
            NSString *loopedCountryName = currentLoopCountry.countryCommonName;

            if ([[loopedCountryName lowercaseString] containsString:[trimmedString lowercaseString]]) {
                [self.searchResultCountryMutableArray addObject:currentLoopCountry];
            }
        }
        
        [self fetchSearchResultCountryListWithData:self.searchResultCountryMutableArray];
//        [UIView animateWithDuration:0.2f animations:^{
            if ([self.searchResultCountryMutableArray count] > 0) {
                self.countryPickerView.tableView.alpha = 1.0f;
                self.countryPickerView.searchResultTableView.alpha = 1.0f;
                [self.countryPickerView isShowEmptyState:NO];
            }
            else {
                self.countryPickerView.tableView.alpha = 0.0f;
                self.countryPickerView.searchResultTableView.alpha = 0.0f;
                [self.countryPickerView isShowEmptyState:YES];
            }
//        } completion:^(BOOL finished) {
//            //completion
//        }];
    }
    else {
        textField.text = @"";
        
        [self.searchResultCountryMutableArray removeAllObjects];
        [self.searchResultIndexSectionDictionary removeAllObjects];
        
        [UIView animateWithDuration:0.3f animations:^{
            CGRect searchBarViewFrame = self.countryPickerView.searchBarView.frame;
            searchBarViewFrame.size.width = CGRectGetWidth(self.countryPickerView.searchBarBackgroundView.frame) - 16.0f - 16.0f;
            self.countryPickerView.searchBarView.frame = searchBarViewFrame;
            self.countryPickerView.searchBarView.searchTextField.text = @"";
            [self.countryPickerView.searchBarView.searchTextField endEditing:YES];
            
            CGRect searchBarCancelButtonFrame = self.countryPickerView.searchBarCancelButton.frame;
            searchBarCancelButtonFrame.origin.x = CGRectGetMaxX(searchBarViewFrame) + 8.0f;
            searchBarCancelButtonFrame.size.width = 0.0f;
            self.countryPickerView.searchBarCancelButton.frame = searchBarCancelButtonFrame;
            
            self.countryPickerView.searchResultTableView.alpha = 0.0f;
            
            if ([self.indexSectionDictionary count] > 0) {
                self.countryPickerView.tableView.alpha = 1.0f;
                [self.countryPickerView isShowEmptyState:NO];
            }
            else {
                self.countryPickerView.tableView.alpha = 0.0f;
                [self.countryPickerView isShowEmptyState:YES];
            }
        } completion:^(BOOL finished) {
            //completion
            [self.countryPickerView.searchResultTableView reloadData];
        }];

        return NO;
    }

    return YES;
}

#pragma mark - Custom Method
- (void)closeButtonDidTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBarCancelButtonDidTapped {
    [self.countryPickerView.searchBarView handleCancelButtonTappedState];
    [self.searchResultCountryMutableArray removeAllObjects];
    [self.searchResultIndexSectionDictionary removeAllObjects];

    [UIView animateWithDuration:0.3f animations:^{
        CGRect searchBarViewFrame = self.countryPickerView.searchBarView.frame;
        searchBarViewFrame.size.width = CGRectGetWidth(self.countryPickerView.searchBarBackgroundView.frame) - 16.0f - 16.0f;
        self.countryPickerView.searchBarView.frame = searchBarViewFrame;
        self.countryPickerView.searchBarView.searchTextField.text = @"";
        [self.countryPickerView.searchBarView.searchTextField endEditing:YES];
        
        CGRect searchBarCancelButtonFrame = self.countryPickerView.searchBarCancelButton.frame;
        searchBarCancelButtonFrame.origin.x = CGRectGetMaxX(searchBarViewFrame) + 8.0f;
        searchBarCancelButtonFrame.size.width = 0.0f;
        self.countryPickerView.searchBarCancelButton.frame = searchBarCancelButtonFrame;
        
        self.countryPickerView.searchResultTableView.alpha = 0.0f;
        
        if ([self.indexSectionDictionary count] > 0) {
            self.countryPickerView.tableView.alpha = 1.0f;
            [self.countryPickerView isShowEmptyState:NO];
        }
        else {
            self.countryPickerView.tableView.alpha = 0.0f;
            [self.countryPickerView isShowEmptyState:YES];
        }
    } completion:^(BOOL finished) {
        //completion
        [self.countryPickerView.searchResultTableView reloadData];
    }];
}

- (void)fetchCountryListWithData:(NSArray *)countryDataArray {
    _countryListArray = countryDataArray;
    for (TAPCountryModel *country in self.countryListArray) {
        NSString *countryName = country.countryCommonName;
        
        NSString *firstAlphabet = [[countryName substringWithRange:NSMakeRange(0, 1)] uppercaseString];
        if ([self.alphabetSectionTitles containsObject:firstAlphabet]) {
            if ([self.indexSectionDictionary objectForKey:firstAlphabet] == nil) {
                //No alphabet found
                [self.indexSectionDictionary setObject:[NSArray arrayWithObjects:country, nil] forKey:firstAlphabet];
            }
            else {
                //Alphabet found
                NSMutableArray *countryArray = [[self.indexSectionDictionary objectForKey:firstAlphabet] mutableCopy];
                [countryArray addObject:country];
                [self.indexSectionDictionary setObject:countryArray forKey:firstAlphabet];
            }
        }
        else {
            if ([self.indexSectionDictionary objectForKey:@"#"] == nil) {
                //No alphabet found
                [self.indexSectionDictionary setObject:[NSArray arrayWithObjects:country, nil] forKey:firstAlphabet];
            }
            else {
                //Alphabet found
                NSMutableArray *countryArray = [[self.indexSectionDictionary objectForKey:@"#"] mutableCopy];
                [countryArray addObject:country];
                [self.indexSectionDictionary setObject:countryArray forKey:firstAlphabet];
            }
        }
    }
    
    if ([self.indexSectionDictionary count] > 0) {
        self.countryPickerView.tableView.alpha = 1.0f;
        [self.countryPickerView isShowEmptyState:NO];
    }
    else {
        self.countryPickerView.tableView.alpha = 0.0f;
        [self.countryPickerView isShowEmptyState:YES];
    }
    
    [self.countryPickerView.tableView reloadData];
}

- (void)fetchSearchResultCountryListWithData:(NSArray *)countryDataArray {
    for (TAPCountryModel *country in self.searchResultCountryMutableArray) {
        NSString *countryName = country.countryCommonName;
        
        NSString *firstAlphabet = [[countryName substringWithRange:NSMakeRange(0, 1)] uppercaseString];
        if ([self.alphabetSectionTitles containsObject:firstAlphabet]) {
            if ([self.searchResultIndexSectionDictionary objectForKey:firstAlphabet] == nil) {
                //No alphabet found
                [self.searchResultIndexSectionDictionary setObject:[NSArray arrayWithObjects:country, nil] forKey:firstAlphabet];
            }
            else {
                //Alphabet found
                NSMutableArray *countryArray = [[self.searchResultIndexSectionDictionary objectForKey:firstAlphabet] mutableCopy];
                [countryArray addObject:country];
                [self.searchResultIndexSectionDictionary setObject:countryArray forKey:firstAlphabet];
            }
        }
        else {
            if ([self.searchResultIndexSectionDictionary objectForKey:@"#"] == nil) {
                //No alphabet found
                [self.searchResultIndexSectionDictionary setObject:[NSArray arrayWithObjects:country, nil] forKey:firstAlphabet];
            }
            else {
                //Alphabet found
                NSMutableArray *countryArray = [[self.searchResultIndexSectionDictionary objectForKey:@"#"] mutableCopy];
                [countryArray addObject:country];
                [self.searchResultIndexSectionDictionary setObject:countryArray forKey:firstAlphabet];
            }
        }
    }
    
    [self.countryPickerView.searchResultTableView reloadData];
}

    
@end
