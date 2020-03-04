//
//  TAPSearchViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 20/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPSearchViewController.h"
#import "TAPSearchView.h"

//TableViewCell for SearchResultTableView
#import "TAPSearchResultChatTableViewCell.h"
#import "TAPContactTableViewCell.h"
#import "TAPSearchResultMessageTableViewCell.h"

@interface TAPSearchViewController () <UITableViewDataSource, UITableViewDelegate, TAPSearchBarViewDelegate>

@property (strong, nonatomic) TAPSearchView *searchView;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
@property (strong, nonatomic) UIButton *leftBarButton;
@property (strong, nonatomic) UIButton *rightBarButton;

@property (strong, nonatomic) NSMutableArray *recentSearchArray;
@property (strong, nonatomic) NSMutableArray *recentSearchUppercaseArray;
@property (strong, nonatomic) NSMutableArray *recentSearchUnreadCountArray;
@property (strong, nonatomic) NSMutableArray *searchResultMessageArray;
@property (strong, nonatomic) NSMutableArray *searchResultChatAndContactArray;
@property (strong, nonatomic) NSMutableArray *searchResultUnreadCountArray;
@property (strong, nonatomic) NSString *updatedString;

@end

@implementation TAPSearchViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.alpha = 0.0f;
    
    _searchView = [[TAPSearchView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.searchView];
    
    self.searchView.recentSearchTableView.delegate = self;
    self.searchView.recentSearchTableView.dataSource = self;
    self.searchView.searchResultTableView.delegate = self;
    self.searchView.searchResultTableView.dataSource = self;
    [self.searchView.clearHistoryButton addTarget:self action:@selector(clearHistoryButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.alpha = 0.0f;
    
    UIFont *searchBarCancelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchBarTextCancelButton];
    UIColor *searchBarCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarTextCancelButton];
    _rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 51.0f, 40.0f)];
    [self.rightBarButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.rightBarButton setTitleColor:searchBarCancelColor forState:UIControlStateNormal];
    self.rightBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.rightBarButton.titleLabel.font = searchBarCancelFont;
    [self.rightBarButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarButton];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    //TitleView
    _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(-55.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 73.0f - 16.0f, 30.0f)];
    self.searchBarView.delegate = self;
    [self.navigationItem setTitleView:self.searchBarView];
    
    [TAPDataManager getDatabaseRecentSearchResultSuccess:^(NSArray<TAPRecentSearchModel *> *recentSearchArray, NSArray *unreadCountArray) {
//        for (TAPRecentSearchModel *recentSearch in recentSearchArray) {
//            TAPRoomModel *room = recentSearch.room;
            self.recentSearchArray = [recentSearchArray mutableCopy];
            self.recentSearchUnreadCountArray = [unreadCountArray mutableCopy];
        [self.searchView.recentSearchTableView reloadData];
//        }
    } failure:^(NSError *error) {
        
    }];
    
    _searchResultMessageArray = [NSMutableArray array];
    _searchResultChatAndContactArray = [NSMutableArray array];
    _searchResultUnreadCountArray = [NSMutableArray array];
    _updatedString = @"";
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.view.alpha == 0.0f) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.alpha = 1.0f;
        } completion:^(BOOL finished) {
            self.navigationController.navigationBar.alpha = 1.0f;
            [self.searchBarView.searchTextField becomeFirstResponder];
        }];
    }
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchView.recentSearchTableView) {
        return 1;
    }
    else if (tableView == self.searchView.searchResultTableView) {
        return 2; //Chats & Contacts, Messages
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchView.recentSearchTableView) {
        return [self.recentSearchArray count];
    }
    else if (tableView == self.searchView.searchResultTableView) {
        if (section == 0) {
            //CHATS & CONTACTS
            return [self.searchResultChatAndContactArray count];
        }
        else if (section == 1) {
            //MESSAGES
            return [self.searchResultMessageArray count];
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchView.recentSearchTableView) {
        return 70.0f;
    }
    else if (tableView == self.searchView.searchResultTableView) {
        if (indexPath.section == 0) {
            return 70.0f;
        }
        else if (indexPath.section == 1) {
            return 70.0f;
        }
    }
    
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchView.recentSearchTableView) {
        static NSString *cellID = @"TAPRecentSearchTableViewCell";
        TAPSearchResultChatTableViewCell *cell = [[TAPSearchResultChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        TAPRecentSearchModel *recentSearch = [self.recentSearchArray objectAtIndex:indexPath.row];
        TAPRoomModel *room = recentSearch.room;
        [cell setSearchResultChatTableViewCellWithData:room
                                        searchedString:@""
                                numberOfUnreadMessages:[self.recentSearchUnreadCountArray objectAtIndex:indexPath.row]];
        
        return cell;
    }
    else if (tableView == self.searchView.searchResultTableView) {
        if (indexPath.section == 0) {
            //CHATS AND CONTACTS
            static NSString *cellID = @"TAPSearchResultChatTableViewCell";
            TAPSearchResultChatTableViewCell *cell = [[TAPSearchResultChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            
            TAPRoomModel *room = [self.searchResultChatAndContactArray objectAtIndex:indexPath.row];
            [cell setSearchResultChatTableViewCellWithData:room
                                            searchedString:self.updatedString
                                    numberOfUnreadMessages:[self.searchResultUnreadCountArray objectAtIndex:indexPath.row]];
            
            if (indexPath.row == [self.searchResultChatAndContactArray count] - 1) {
                [cell hideSeparatorView:YES];
            }
            else {
                [cell hideSeparatorView:NO];
            }
            
            return cell;
        }
        else if (indexPath.section == 1) {
            //MESSAGES
            static NSString *cellID = @"TAPSearchResultMessageTableViewCell";
            TAPSearchResultMessageTableViewCell *cell = [[TAPSearchResultMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            TAPMessageModel *message = [self.searchResultMessageArray objectAtIndex:indexPath.row];
            [cell setSearchResultMessageTableViewCell:message
                                       searchedString:self.updatedString];
            
            return cell;
        }
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchView.searchResultTableView) {
        if (section == 0) {
            if ([self.searchResultChatAndContactArray count] == 0) {
                return 0.0f;
            }
            else {
                return 28.0f; //Remember to update viewForHeaderInSection when this value is changed.
            }
        }
        else if (section == 1) {
            if ([self.searchResultMessageArray count] == 0) {
                return 0.0f;
            }
            else {
                return 28.0f; //Remember to update viewForHeaderInSection when this value is changed.
            }
        }
    }
    
    //For self.searchView.recentSearchTableView
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchView.searchResultTableView) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 28.0f)];
        headerView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        
        UIFont *sectionHeaderTitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
        UIColor *sectionHeaderTitleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTableViewSectionHeaderLabel];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, 13.0f)];
        titleLabel.font = sectionHeaderTitleLabelFont;
        titleLabel.textColor = sectionHeaderTitleLabelColor;
        NSString *titleString = @"";
        if (section == 0) {
            titleString = NSLocalizedStringFromTableInBundle(@"CHATS AND CONTACTS", nil, [TAPUtil currentBundle], @"");
        }
        else if (section == 1) {
            titleString = NSLocalizedStringFromTableInBundle(@"MESSAGES", nil, [TAPUtil currentBundle], @"");
        }
        titleLabel.text = titleString;
        
        NSMutableAttributedString *titleLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:titleLabel.text];
        [titleLabelAttributedString addAttribute:NSKernAttributeName
                                           value:@1.5f
                                           range:NSMakeRange(0, [titleLabel.text length])];
        titleLabel.attributedText = titleLabelAttributedString;

        
        [headerView addSubview:titleLabel];
        
        return headerView;
    }
    
    //For self.searchView.recentSearchTableView
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

#pragma mark - Delegate
#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.searchBarView.searchTextField resignFirstResponder];
    
    if (tableView == self.searchView.recentSearchTableView) {
        TAPRecentSearchModel *selectedRecentSearch = [self.recentSearchArray objectAtIndex:indexPath.row];
        TAPRoomModel *selectedRoom = selectedRecentSearch.room;
        
        [[TapUI sharedInstance] createRoomWithRoom:selectedRoom success:^(TapUIChatViewController * _Nonnull chatViewController) {
            chatViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatViewController animated:YES];
        }];
        
        NSDate *date = [NSDate date];
        long createdDate = [date timeIntervalSince1970] * 1000.0f;
        selectedRecentSearch.created = [NSNumber numberWithLong:createdDate];
        [TAPDataManager updateOrInsertDatabaseRecentSearchWithData:@[selectedRecentSearch] success:^{
            [self.recentSearchArray removeObjectAtIndex:indexPath.row];
            [self.recentSearchArray insertObject:selectedRecentSearch atIndex:0];
            [self.searchView.recentSearchTableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }
    else if (tableView == self.searchView.searchResultTableView) {
        if (indexPath.section == 0) {
            //CHATS AND CONTACTS
            TAPRoomModel *selectedRoom = [self.searchResultChatAndContactArray objectAtIndex:indexPath.row];
            
            [[TapUI sharedInstance] createRoomWithRoom:selectedRoom success:^(TapUIChatViewController * _Nonnull chatViewController) {
                chatViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:chatViewController animated:YES];
            }];
            
            //Add to recent chat
            TAPRecentSearchModel *recentSearch = [TAPRecentSearchModel new];
            recentSearch.room = selectedRoom;
            NSDate *date = [NSDate date];
            long createdDate = [date timeIntervalSince1970] * 1000.0f;
            recentSearch.created = [NSNumber numberWithLong:createdDate];
            
            [TAPDataManager updateOrInsertDatabaseRecentSearchWithData:@[recentSearch] success:^{
                [TAPDataManager getDatabaseRecentSearchResultSuccess:^(NSArray<TAPRecentSearchModel *> *recentSearchArray, NSArray *unreadCountArray) {
                    [self.recentSearchUnreadCountArray removeAllObjects];
                    for (TAPRecentSearchModel *recentSearch in recentSearchArray) {
                        TAPRoomModel *room = recentSearch.room;
                        self.recentSearchArray = [recentSearchArray mutableCopy];
                        self.recentSearchUnreadCountArray = [unreadCountArray mutableCopy];
                    }
                    
                    [self.searchView.recentSearchTableView reloadData];
                } failure:^(NSError *error) {
                    
                }];
            } failure:^(NSError *error) {
                
            }];
        }
        else if (indexPath.section == 1) {
            //MESSAGES
            TAPMessageModel *selectedMessage = [self.searchResultMessageArray objectAtIndex:indexPath.row];
            TAPRoomModel *selectedRoom = selectedMessage.room;
            
            [[TapUI sharedInstance] createRoomWithRoom:selectedRoom scrollToMessageWithLocalID:selectedMessage.localID success:^(TapUIChatViewController * _Nonnull chatViewController) {
                chatViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:chatViewController animated:YES];
            }];
        }
    }
}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBarView.searchTextField resignFirstResponder];
}

#pragma mark TAPSearchBarView
- (BOOL)searchBarTextFieldShouldClear:(UITextField *)textField {
    [self.searchResultMessageArray removeAllObjects];
    [self.searchResultChatAndContactArray removeAllObjects];
    [self.searchResultUnreadCountArray removeAllObjects];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.searchView.recentSearchTableView.alpha = 1.0f;
        self.searchView.searchResultTableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        //completion
        [self.searchView.searchResultTableView reloadData];
    }];
    
    return YES;
}

- (BOOL)searchBarTextFieldShouldReturn:(UITextField *)textField {
    return NO;
}

- (BOOL)searchBarTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *trimmedNewString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![trimmedNewString isEqualToString:@""]) {
        self.updatedString = newString;
        
        NSString *trimmedString = [self.updatedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [TAPDataManager searchMessageWithString:trimmedString sortBy:@"created" success:^(NSArray *resultArray) {
            [TAPDataManager searchChatAndContactWithString:trimmedString SortBy:@"roomName" success:^(NSArray *roomArray, NSArray *unreadCountArray) {
                self.searchResultMessageArray = [resultArray mutableCopy];
                self.searchResultChatAndContactArray = [roomArray mutableCopy];
                self.searchResultUnreadCountArray = [unreadCountArray mutableCopy];
                
                if (self.searchView.searchResultTableView.alpha == 1.0f) {
                    if ([self.searchResultMessageArray count] == 0 && [self.searchResultChatAndContactArray count] == 0) {
                        [UIView animateWithDuration:0.2f animations:^{
                            [self.searchView isShowEmptyState:YES];
                        }];
                    }
                    else {
                        [UIView animateWithDuration:0.2f animations:^{
                            [self.searchView isShowEmptyState:NO];
                        }];
                    }
                }
                
                [self.searchView.searchResultTableView reloadData];
            } failure:^(NSError *error) {
                
            }];
        } failure:^(NSError *error) {
            
        }];
        
        [UIView animateWithDuration:0.2f animations:^{
            self.searchView.recentSearchTableView.alpha = 0.0f;
            self.searchView.searchResultTableView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        textField.text = @"";
        
        [self.searchResultMessageArray removeAllObjects];
        [self.searchResultChatAndContactArray removeAllObjects];
        [self.searchResultUnreadCountArray removeAllObjects];
        [UIView animateWithDuration:0.2f animations:^{
            self.searchView.recentSearchTableView.alpha = 1.0f;
            self.searchView.searchResultTableView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.searchView.searchResultTableView reloadData];
        }];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Custom Method
- (void)cancelButtonDidTapped {
    [self.searchBarView handleCancelButtonTappedState];
    [self.searchBarView.searchTextField resignFirstResponder];
    
    self.searchBarView.searchTextField.text = @"";
    
    UIImage *rightBarImage = [UIImage imageNamed:@"TAPIconAddEditItem" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];;
    rightBarImage = [rightBarImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconStartNewChatButton]];

    _rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 51.0f, 40.0f)];
    [self.rightBarButton setImage:rightBarImage forState:UIControlStateNormal];
    self.rightBarButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -9.0f);
    [self.rightBarButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarButton];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBarButton];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    self.searchBarView.frame = CGRectMake(-55.0f, CGRectGetMinY(self.searchBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 73.0f - 16.0f, CGRectGetHeight(self.searchBarView.frame));
    
    [TAPUtil performBlock:^{
        if ([self.delegate respondsToSelector:@selector(searchViewControllerDidTappedSearchCancelButton)]) {
            [self.delegate searchViewControllerDidTappedSearchCancelButton];
        }
    } afterDelay:0.1f];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.searchBarView.frame = CGRectMake(0.0f, CGRectGetMinY(self.searchBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 55.0f - 73.0f - 16.0f, CGRectGetHeight(self.searchBarView.frame));
        
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.navigationController.navigationBar.alpha = 0.0f;
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            //completion
        }];
    }];
}

- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    [UIView animateWithDuration:0.2f animations:^{
        self.searchView.recentSearchTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, keyboardHeight, 0.0f);
    }];
}

- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
    [UIView animateWithDuration:0.2f animations:^{
        self.searchView.recentSearchTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }];
}

- (void)clearHistoryButtonDidTapped {
    [TAPDataManager deleteDatabaseAllRecentSearchSuccess:^{
        [self.recentSearchArray removeAllObjects];
        [self.searchView.recentSearchTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

@end
