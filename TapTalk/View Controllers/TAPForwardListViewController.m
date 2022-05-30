//
//  TAPForwardListViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 26/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPForwardListViewController.h"
#import "TAPForwardListView.h"

#import "TAPSearchResultChatTableViewCell.h"
#import "TAPContactTableViewCell.h"
#import "TAPSearchResultMessageTableViewCell.h"

@interface TAPForwardListViewController () <UITableViewDataSource, UITableViewDelegate, TAPSearchBarViewDelegate>

@property (strong, nonatomic) TAPForwardListView *forwardListView;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;

@property (strong, nonatomic) UIImage *navigationShadowImage; //shadow under navigation bar

@property (strong, nonatomic) NSMutableArray *recentChatArray;
@property (strong, nonatomic) NSMutableArray *searchResultChatAndContactArray;
@property (strong, nonatomic) NSString *updatedString;

- (void)cancelButtonDidTapped;

@end

@implementation TAPForwardListViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    _forwardListView = [[TAPForwardListView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.forwardListView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO];
    
    UIFont *navigationBarButtonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarButtonLabel];
    UIColor *navigationBarButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarButtonLabel];
    UIButton* leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [leftBarButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [leftBarButton setTitleColor:navigationBarButtonColor forState:UIControlStateNormal];
    leftBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 18.0f);
    leftBarButton.titleLabel.font = navigationBarButtonFont;
    [leftBarButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    
    self.title = NSLocalizedStringFromTableInBundle(@"Forward", nil, [TAPUtil currentBundle], @"");
    
    if (@available(iOS 15.0, *)) {
        [self.forwardListView.recentChatTableView setSectionHeaderTopPadding:0.0f];
        [self.forwardListView.searchResultTableView setSectionHeaderTopPadding:0.0f];
    }
    
    self.forwardListView.searchBarView.delegate = self;
    self.forwardListView.recentChatTableView.delegate = self;
    self.forwardListView.recentChatTableView.dataSource = self;
    self.forwardListView.searchResultTableView.delegate = self;
    self.forwardListView.searchResultTableView.dataSource = self;
    
    _recentChatArray = [NSMutableArray array];
    _searchResultChatAndContactArray = [NSMutableArray array];
    _updatedString = @"";
    
    [TAPDataManager getRoomListSuccess:^(NSArray *resultArray) {
        _recentChatArray = resultArray;
        [self.forwardListView.recentChatTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _navigationShadowImage = self.navigationController.navigationBar.shadowImage;
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setShadowImage:self.navigationShadowImage];
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.forwardListView.recentChatTableView) {
        return 1;
    }
    else if (tableView == self.forwardListView.searchResultTableView) {
        return 1;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.forwardListView.recentChatTableView) {
        return [self.recentChatArray count];
    }
    else if (tableView == self.forwardListView.searchResultTableView) {
        //CHATS & CONTACTS
        return [self.searchResultChatAndContactArray count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.forwardListView.recentChatTableView) {
        return 70.0f;
    }
    else if (tableView == self.forwardListView.searchResultTableView) {
        return 70.0f;
    }
    
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.forwardListView.recentChatTableView) {
        static NSString *cellID = @"TAPRecentSearchTableViewCell";
        TAPSearchResultChatTableViewCell *cell = [[TAPSearchResultChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        TAPRecentSearchModel *recentSearch = [self.recentChatArray objectAtIndex:indexPath.row];
        TAPRoomModel *room = recentSearch.room;
        [cell setSearchResultChatTableViewCellWithData:room
                                        searchedString:@""
                                numberOfUnreadMessages:@"0"
                                            hasMention:NO];
        
        return cell;
    }
    else if (tableView == self.forwardListView.searchResultTableView) {
        //CHATS AND CONTACTS
        static NSString *cellID = @"TAPSearchResultChatTableViewCell";
        TAPSearchResultChatTableViewCell *cell = [[TAPSearchResultChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        TAPRoomModel *room = [self.searchResultChatAndContactArray objectAtIndex:indexPath.row];
        [cell setSearchResultChatTableViewCellWithData:room
                                        searchedString:self.updatedString
                                numberOfUnreadMessages:@"0"
                                            hasMention:NO];
        
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.forwardListView.searchResultTableView) {
        if (section == 0) {
            if ([self.searchResultChatAndContactArray count] == 0) {
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
    if (tableView == self.forwardListView.searchResultTableView) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 28.0f)];
        headerView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        
        UIFont *sectionHeaderLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
        UIColor *sectionHeaderLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTableViewSectionHeaderLabel];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, 13.0f)];
        titleLabel.font = sectionHeaderLabelFont;
        titleLabel.textColor = sectionHeaderLabelColor;
        titleLabel.text = NSLocalizedStringFromTableInBundle(@"CHATS AND CONTACTS", nil, [TAPUtil currentBundle], @"");
        
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
    
    [self.forwardListView.searchBarView.searchTextField resignFirstResponder];
    
    NSString *currentSelectedRoomID = @"";
    if (tableView == self.forwardListView.recentChatTableView) {
        //ROOM LIST - RECENT CHAT
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self.currentNavigationController popToRootViewControllerAnimated:YES];
        
        TAPMessageModel *currentMessage = [self.recentChatArray objectAtIndex:indexPath.row];
        currentSelectedRoomID = currentMessage.room.roomID;

        [[TapUI sharedInstance] createRoomWithRoom:currentMessage.room success:^(TapUIChatViewController * _Nonnull chatViewController) {
            chatViewController.hidesBottomBarWhenPushed = YES;
            [self.currentNavigationController pushViewController:chatViewController animated:YES];
        }];
    }
    else if (tableView == self.forwardListView.searchResultTableView) {
        //CHATS AND CONTACTS
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self.currentNavigationController popToRootViewControllerAnimated:YES];
        
        TAPRoomModel *selectedRoom = [self.searchResultChatAndContactArray objectAtIndex:indexPath.row];
        currentSelectedRoomID = selectedRoom.roomID;
        
        [[TapUI sharedInstance] createRoomWithRoom:selectedRoom success:^(TapUIChatViewController * _Nonnull chatViewController) {
            chatViewController.hidesBottomBarWhenPushed = YES;
            [self.currentNavigationController pushViewController:chatViewController animated:YES];
        }];
    }
    
    for(TAPMessageModel *forwardedMessage in self.forwardedMessages){
        if (forwardedMessage.type == TAPChatMessageTypeFile || forwardedMessage.type == TAPChatMessageTypeVideo) {
            NSDictionary *dataDictionary = forwardedMessage.data;
            NSString *fileID = [dataDictionary objectForKey:@"fileID"];
            
            NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:forwardedMessage.room.roomID fileID:fileID];
            filePath = [TAPUtil nullToEmptyString:filePath];
            
            if (![filePath isEqualToString:@""]) {
                [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToDictionaryWithFilePath:filePath roomID:currentSelectedRoomID fileID:fileID];
            }
        }
        
    }
    
    [[TAPChatManager sharedManager] saveToQuoteActionWithType:TAPChatManagerQuoteActionTypeForward roomID:currentSelectedRoomID];
    [[TAPChatManager sharedManager] saveToForwardedMessages:self.forwardedMessages userInfo:[NSDictionary dictionary] roomID:currentSelectedRoomID];
}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBarView.searchTextField resignFirstResponder];
}

#pragma mark TAPSearchBarView
- (BOOL)searchBarTextFieldShouldClear:(UITextField *)textField {
    [self.searchResultChatAndContactArray removeAllObjects];
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.forwardListView isShowRecentChatView:YES animated:NO];
        [self.forwardListView isShowEmptyState:NO];
        self.forwardListView.searchResultTableView.alpha = 0.0f;
        self.forwardListView.recentChatTableView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        //completion
        [self.forwardListView.searchResultTableView reloadData];
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
        
        [self.forwardListView isShowRecentChatView:NO animated:YES];
        
        [TAPDataManager searchChatAndContactWithString:trimmedString SortBy:@"roomName" success:^(NSArray *roomArray, NSArray *unreadCountArray, NSDictionary *unreadMentionDictionary) {
            self.searchResultChatAndContactArray = [roomArray mutableCopy];

            if (self.forwardListView.searchResultTableView.alpha == 1.0f) {
                if ([self.searchResultChatAndContactArray count] == 0) {
                    [UIView animateWithDuration:0.2f animations:^{
                        [self.forwardListView isShowEmptyState:YES];
                    }];
                }
                else {
                    [UIView animateWithDuration:0.2f animations:^{
                        [self.forwardListView isShowEmptyState:NO];
                    }];
                }
            }
            
            [self.forwardListView.searchResultTableView reloadData];
        } failure:^(NSError *error) {

        }];
        
        [UIView animateWithDuration:0.2f animations:^{
            self.forwardListView.recentChatTableView.alpha = 0.0f;
            self.forwardListView.searchResultTableView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        textField.text = @"";
        
        [self.searchResultChatAndContactArray removeAllObjects];
        [UIView animateWithDuration:0.2f animations:^{
            [self.forwardListView isShowRecentChatView:YES animated:NO];
            [self.forwardListView isShowEmptyState:NO];
            self.forwardListView.searchResultTableView.alpha = 0.0f;
            self.forwardListView.recentChatTableView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [self.forwardListView.searchResultTableView reloadData];
        }];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Custom Method
- (void)cancelButtonDidTapped {
    [self.forwardListView.searchBarView handleCancelButtonTappedState];
    [self.forwardListView.searchBarView.searchTextField resignFirstResponder];
    self.forwardListView.searchBarView.searchTextField.text = @"";
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    [UIView animateWithDuration:0.2f animations:^{
        self.forwardListView.recentChatTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, keyboardHeight, 0.0f);
    }];
}

- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
    [UIView animateWithDuration:0.2f animations:^{
        self.forwardListView.recentChatTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }];
}

@end
