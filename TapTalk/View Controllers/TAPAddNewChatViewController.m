//
//  AddNewChatViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPAddNewChatViewController.h"
#import "TAPAddNewChatView.h"
#import "TAPScanQRCodeViewController.h"
#import "TAPBlockedListViewController.h"
#import "TAPAddNewContactViewController.h"
#import "TAPCreateGroupViewController.h"

#import "TapUIChatViewController.h"
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>

//WK Note - addNewChatView.contactsTableView tableViewCell
#import "TAPNewChatOptionTableViewCell.h"
#import "TAPContactTableViewCell.h"
#import "TAPNewChatBlockedContactsTableViewCell.h"

//WK Note - addNewChatView.searchResultTableView tableViewCell
#import "TAPNewChatAddNewContactTableViewCell.h"

@interface TAPAddNewChatViewController () <UITableViewDelegate, UITableViewDataSource, TAPAddNewContactViewControllerDelegate, TAPCustomButtonViewDelegate, TAPSearchBarViewDelegate>

@property (strong, nonatomic) TAPAddNewChatView *addNewChatView;

@property (strong, nonatomic) NSArray *alphabetSectionTitles;
@property (strong, nonatomic) NSArray *contactListArray;
@property (strong, nonatomic) NSMutableArray *searchResultUserMutableArray;
@property (strong, nonatomic) NSMutableArray *filledMenuOptionArray;

@property (strong, nonatomic) NSMutableDictionary *indexSectionDictionary;
@property (strong, nonatomic) NSMutableDictionary *contactListDictionary;

@property (strong, nonatomic) NSString *updatedString;

@property (nonatomic) BOOL skipCheckContactSync;

- (void)loadContactListFromDatabase;
- (void)syncContactWithLoading:(BOOL)loading;
- (void)requestAccessAndCheckNewContact;

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification;

@end

@implementation TAPAddNewChatViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _addNewChatView = [[TAPAddNewChatView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.addNewChatView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addNewChatView.searchBarView.delegate = self;
    self.addNewChatView.contactsTableView.delegate = self;
    self.addNewChatView.contactsTableView.dataSource = self;
    self.addNewChatView.searchResultTableView.delegate = self;
    self.addNewChatView.searchResultTableView.dataSource = self;
    
    self.title = NSLocalizedStringFromTableInBundle(@"New Chat", nil, [TAPUtil currentBundle], @"");
    
    [self showCustomCloseButton];
    
    _alphabetSectionTitles = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    //Refresh Contact List From API
    [TAPDataManager callAPIGetContactList:^(NSArray *userArray) {
        [self loadContactListFromDatabase];
    } failure:^(NSError *error) {
    }];
    
    _searchResultUserMutableArray = [NSMutableArray array];
    _updatedString = @"";
    
    self.addNewChatView.syncButton.delegate = self;
    
    [self.addNewChatView showSyncContactButtonView:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:TAP_NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE object:nil];
    
    _filledMenuOptionArray = [NSMutableArray array];
    
    if ([[TapUI sharedInstance] getNewContactMenuButtonVisibleState]) {
        //options Add New Contact
        [self.filledMenuOptionArray addObject:@"1"];
    }
    if ([[TapUI sharedInstance] getScanQRMenuButtonVisibleState]) {
        //options Scan QR Code
        [self.filledMenuOptionArray addObject:@"2"];
    }
    if ([[TapUI sharedInstance] getNewGroupMenuButtonVisibleState]) {
        //options Create Group
        [self.filledMenuOptionArray addObject:@"3"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showNavigationSeparator:NO];
    
    //Load Contact List From Database
    [self loadContactListFromDatabase];
    
    [self requestAccessAndCheckNewContact];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE object:nil];
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.addNewChatView.contactsTableView) {
        //DV Note
        //Temporary Hidden For V1 (30 Jan 2019)
        //Hide Blocked Contacts
//        return [self.indexSectionDictionary count] + 2;
//        /*
//         1 section is options (Add New Contact, Create Group, Scan QR Code)
//         1 section is blocked contacts (in the bottom)
//         */
        //END DV Note
        return [self.indexSectionDictionary count] + 1;
    }
    else if (tableView == self.addNewChatView.searchResultTableView) {
        return 2; //1 section is add new contact
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.addNewChatView.contactsTableView) {
        if (section == 0) {
            return [self.filledMenuOptionArray count];
        }
        else if (section <= [[self.indexSectionDictionary allKeys] count]) {
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSString *key = [keysArray objectAtIndex:section - 1];
            NSArray *contactArray = [self.indexSectionDictionary objectForKey:key];
            return [contactArray count];
        }
        //DV Note
        //Temporary Hidden For V1 (30 Jan 2019)
        //Hide Blocked Contacts
//        else if (section == [tableView numberOfSections] - 1) {
//            return 1; //blocked contacts
//        }
        //END DV Note
    }
    else if (tableView == self.addNewChatView.searchResultTableView) {
        if (section == 0) {
            return [self.searchResultUserMutableArray count];
        }
        else if (section == 1) {
            return 1;
        }
        
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.addNewChatView.contactsTableView) {
        if (indexPath.section == 0) {
            return 56.0f;
        }
        else if (indexPath.section <= [self.indexSectionDictionary count]) {
            return 64.0f;
        }
        //DV Note
        //Temporary Hidden For V1 (30 Jan 2019)
        //Hide Blocked Contact
//        else if (indexPath.section == [self.indexSectionDictionary count] + 1) {
//            return 98.0f;
//        }
        //END DV Note
    }
    else if (tableView == self.addNewChatView.searchResultTableView) {
        if (indexPath.section == 0) {
            return 64.0f;
        }
        else if (indexPath.section == 1) {
            return 78.0f;
        }
    }
    
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.addNewChatView.contactsTableView) {
        if (indexPath.section == 0) {
            static NSString *cellID = @"TAPNewChatOptionTableViewCell";
            TAPNewChatOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[TAPNewChatOptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            
            NSInteger obtainedIndexOptionFromArray = [[self.filledMenuOptionArray objectAtIndex:indexPath.row] integerValue];
            if (obtainedIndexOptionFromArray == 1) {
                //options Add New Contact
                [cell setNewChatOptionTableViewCellType:TAPNewChatOptionTableViewCellTypeNewContact];
            }
            else if (obtainedIndexOptionFromArray == 2) {
                //options Scan QR Code
                [cell setNewChatOptionTableViewCellType:TAPNewChatOptionTableViewCellTypeScanQRCode];
            }
            else if (obtainedIndexOptionFromArray == 3) {
                //options Create Group
                [cell setNewChatOptionTableViewCellType:TAPNewChatOptionTableViewCellTypeNewGroup];
            }
            
            return cell;
        }
        else if (indexPath.section <= [[self.indexSectionDictionary allKeys] count]) {
            static NSString *cellID = @"TAPContactTableViewCell";
            TAPContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            
            [cell setContactTableViewCellType:TAPContactTableViewCellTypeWithUsername];
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSString *key = [keysArray objectAtIndex:indexPath.section - 1];
            NSArray *userArray = [self.indexSectionDictionary objectForKey:key];
            TAPUserModel *currentUser = [userArray objectAtIndex:indexPath.row];
            [cell setContactTableViewCellWithUser:currentUser];

            [cell isRequireSelection:NO];
            
            if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
                [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeFull];
            }
            else {
                [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeDefault];
            }
            
            return cell;
        }
        //DV Note
        //Temporary Hidden For V1 (30 Jan 2019)
        //Hide Blocked Contact
//        else if (indexPath.section == [tableView numberOfSections] - 1) {
//            static NSString *cellID = @"TAPNewChatBlockedContactsTableViewCell";
//            TAPNewChatBlockedContactsTableViewCell *cell = [[TAPNewChatBlockedContactsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//            return cell;
//        }
        //END DV Note
    }
    else if (tableView == self.addNewChatView.searchResultTableView) {
        if (indexPath.section == 0) {
            static NSString *cellID = @"TAPContactTableViewCell";
            TAPContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }

            [cell setContactTableViewCellType:TAPContactTableViewCellTypeWithUsername];
            
            TAPUserModel *user = [self.searchResultUserMutableArray objectAtIndex:indexPath.row];
            [cell setContactTableViewCellWithUser:user];
            [cell isRequireSelection:NO];
            
            if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
                [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeFull];
            }
            else {
                [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeDefault];
            }
            
            return cell;
        }
        else if (indexPath.section == 1) {
            static NSString *cellID = @"TAPNewChatAddNewContactTableViewCell";
            TAPNewChatAddNewContactTableViewCell *cell = [[TAPNewChatAddNewContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.addNewChatView.contactsTableView) {
        if (section <= [[self.indexSectionDictionary allKeys] count] && section != 0) {
            return 34.0f;
        }
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.addNewChatView.contactsTableView) {
        if (section <= [[self.indexSectionDictionary allKeys] count] && section != 0) {
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 34.0f)];
            header.backgroundColor = [TAPUtil getColor:@"F8F8F8"];
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            UIFont *sectionHeaderLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
            UIColor *sectionHeaderLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTableViewSectionHeaderLabel];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(header.frame) - 16.0f - 16.0f, 34.0f)];
            titleLabel.textColor = sectionHeaderLabelColor;
            titleLabel.font = sectionHeaderLabelFont;
            [header addSubview:titleLabel];
            
            if ([keysArray count] != 0) {
                titleLabel.text = [keysArray objectAtIndex:section - 1];
            }
            
            return header;
        }
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
    if (tableView == self.addNewChatView.contactsTableView) {
        if (section == 0) {
            return @"";
        }
        else if (section <= [[self.indexSectionDictionary allKeys] count]) {
            //Contacts
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            return [keysArray objectAtIndex:section - 1];
        }
        else if (section == [tableView numberOfSections] - 1) {
            //Blocked Contacts
            return @"";
        }
    }
    
    return @"";
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.addNewChatView.contactsTableView && [self.indexSectionDictionary count] >= 5) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        return keysArray;
    }
    
    NSArray *sectionIndexArray = [NSArray array];
    return sectionIndexArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.addNewChatView.contactsTableView) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        return [keysArray indexOfObject:title] + 1;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.addNewChatView.contactsTableView) {
        if (indexPath.section == 0) {
            NSInteger obtainedIndexOptionFromArray = [[self.filledMenuOptionArray objectAtIndex:indexPath.row] integerValue];
            if (obtainedIndexOptionFromArray == 1) {
                //options Add New Contact
                TAPAddNewContactViewController *addNewContactViewController = [[TAPAddNewContactViewController alloc] init];
                addNewContactViewController.delegate = self;
                [self.navigationController pushViewController:addNewContactViewController animated:YES];
            }
            else if (obtainedIndexOptionFromArray == 2) {
                //options Scan QR Code
                [self openScanQRCode];
            }
            else if (obtainedIndexOptionFromArray == 3) {
                //options Create Group
                TAPCreateGroupViewController *createGroupViewController = [[TAPCreateGroupViewController alloc] init]; //createGroupViewController
                createGroupViewController.roomListViewController = self.roomListViewController;
                createGroupViewController.tapCreateGroupViewControllerType = TAPCreateGroupViewControllerTypeDefault;
                [self.navigationController pushViewController:createGroupViewController animated:YES];
            }
        }
        else if (indexPath.section <= [[self.indexSectionDictionary allKeys] count]) {
            //Contacts
            //WK Note - Checking 1 on 1 chat
            TAPUserModel *currentUser = [TAPDataManager getActiveUser];
            NSString *currentUsername = currentUser.username;
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            NSString *key = [keysArray objectAtIndex:indexPath.section - 1];
            NSArray *userArray = [self.indexSectionDictionary objectForKey:key];
            
            TAPUserModel *selectedUser = [userArray objectAtIndex:indexPath.row];
            NSString *selectedUsername = selectedUser.username;
            if ([currentUsername isEqualToString:selectedUsername]) {
                //SELECTED THE USER ITSELF
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") message:@"Cannot chat with yourself, please select other room" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else {
                TAPUserModel *selectedUser = [self.contactListDictionary objectForKey:selectedUsername];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    if([self.delegate respondsToSelector:@selector(addNewChatViewControllerShouldOpenNewRoomWithUser:)]) {
                        [self.delegate addNewChatViewControllerShouldOpenNewRoomWithUser:selectedUser];
                    }
                }];
            }
        }
        //DV Note
        //Temporary Hidden For V1 (30 Jan 2019)
        //Hide Blocked Contact
//        else if (indexPath.section == [tableView numberOfSections] - 1) {
//            //Blocked Contacts
//            TAPBlockedListViewController *blockedListViewController = [[TAPBlockedListViewController alloc] init];
//            [self.navigationController pushViewController:blockedListViewController animated:YES];
//        }
        //END DV Note
    }
    else if (tableView == self.addNewChatView.searchResultTableView) {
        if (indexPath.section == [tableView numberOfSections] - 1) {
            TAPAddNewContactViewController *addNewContactViewController = [[TAPAddNewContactViewController alloc] init];
            addNewContactViewController.delegate = self;
            [self.navigationController pushViewController:addNewContactViewController animated:YES];
        }
        else {
            TAPUserModel *currentUser = [TAPDataManager getActiveUser];
            NSString *currentUsername = currentUser.username;
            
            TAPUserModel *selectedUser = [self.searchResultUserMutableArray objectAtIndex:indexPath.row];
            NSString *selectedUsername = selectedUser.username;
            if ([currentUsername isEqualToString:selectedUsername]) {
                //Chat with himself/herself
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") message:@"Cannot chat with yourself, please select other room" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else {
                TAPUserModel *selectedUser = [self.contactListDictionary objectForKey:selectedUsername];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    if([self.delegate respondsToSelector:@selector(addNewChatViewControllerShouldOpenNewRoomWithUser:)]) {
                        [self.delegate addNewChatViewControllerShouldOpenNewRoomWithUser:selectedUser];
                    }
                }];
            }
        }
    }
}

#pragma mark TAPSearchBarView
- (BOOL)searchBarTextFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        if (textField == self.addNewChatView.searchBarView.searchTextField) {
            [self.addNewChatView showOverlayView:YES];
            [UIView animateWithDuration:0.3f animations:^{
                CGRect searchBarViewFrame = self.addNewChatView.searchBarView.frame;
                searchBarViewFrame.size.width = CGRectGetWidth(self.addNewChatView.searchBarView.frame) - 70.0f;
                self.addNewChatView.searchBarView.frame = searchBarViewFrame;
                
                CGRect searchBarCancelButtonFrame = self.addNewChatView.searchBarCancelButton.frame;
                searchBarCancelButtonFrame.origin.x = CGRectGetMaxX(searchBarViewFrame) + 8.0f;
                searchBarCancelButtonFrame.size.width = 70.0f;
                self.addNewChatView.searchBarCancelButton.frame = searchBarCancelButtonFrame;
            } completion:^(BOOL finished) {
                //completion
                [self.searchResultUserMutableArray removeAllObjects];
                [self.addNewChatView.searchResultTableView reloadData];
            }];
        }
    }
    
    return YES;
}

- (BOOL)searchBarTextFieldShouldClear:(UITextField *)textField {
    [self.searchResultUserMutableArray removeAllObjects];
    [self.addNewChatView showOverlayView:YES];
    [UIView animateWithDuration:0.2f animations:^{
        self.addNewChatView.searchResultTableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        //completion
        [self.addNewChatView.searchResultTableView reloadData];
    }];
    return YES;
}

- (BOOL)searchBarTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *trimmedNewString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![trimmedNewString isEqualToString:@""]) {
        self.updatedString = newString;
        [self.addNewChatView showSyncContactButtonView:NO];
        NSString *trimmedString = [self.updatedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [TAPDataManager getDatabaseContactSearchKeyword:trimmedString sortBy:@"fullname" success:^(NSArray *resultArray) {
            self.searchResultUserMutableArray = resultArray;
            
            [self.addNewChatView.searchResultTableView reloadData];
            
            [self.addNewChatView showOverlayView:NO];
            [UIView animateWithDuration:0.2f animations:^{
                self.addNewChatView.searchResultTableView.alpha = 1.0f;
            } completion:^(BOOL finished) {
                //completion
            }];
        } failure:^(NSError *error) {
            
        }];
    }
    else {
        textField.text = @"";
        [self.searchResultUserMutableArray removeAllObjects];
        [self.addNewChatView showOverlayView:YES];
        [UIView animateWithDuration:0.2f animations:^{
            self.addNewChatView.searchResultTableView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            //completion
            [self.addNewChatView.searchResultTableView reloadData];
        }];
        
        return NO;
    }
    
    return YES;
}

#pragma mark TAPCustomButtonView
- (void)customButtonViewDidTappedButton {
    //Sync Button Tapped
//    [self syncContactWithLoading:YES];
    
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Sync Contact Manually" title:NSLocalizedStringFromTableInBundle(@"Contact Access", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"We need your permission to access your contact, we will sync your contact to our server and automatically find your friend so it is easier for you to find your friends.", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Allow", nil, [TAPUtil currentBundle], @"")];
}

#pragma mark TAPAddNewContactViewController
- (void)addNewContactViewControllerShouldOpenNewRoomWithUser:(TAPUserModel *)user {
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(addNewChatViewControllerShouldOpenNewRoomWithUser:)]) {
            [self.delegate addNewChatViewControllerShouldOpenNewRoomWithUser:user];
        }
    }];
}

#pragma mark - Custom Method
- (void)openScanQRCode {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        TAPScanQRCodeViewController *scanQRCodeViewController = [[TAPScanQRCodeViewController alloc] init];
        [self.navigationController pushViewController:scanQRCodeViewController animated:YES];
    }
    else if (status == AVAuthorizationStatusNotDetermined) {
        //request
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self openScanQRCode];
            });
        }];
    }
    else {
        //No permission. Trying to normally request it
        NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (IS_IOS_11_OR_ABOVE) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
        [alertController addAction:settingsAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)loadContactListFromDatabase {
    
    [TAPDataManager getDatabaseAllContactSortBy:@"fullname" success:^(NSArray *resultArray) {
        _contactListArray = [NSMutableArray array];
        _indexSectionDictionary = [NSMutableDictionary dictionary];
        _contactListDictionary = [NSMutableDictionary dictionary];
        self.contactListArray = resultArray;
        for (TAPUserModel *user in self.contactListArray) {
            NSString *username = user.username;
            [self.contactListDictionary setValue:user forKey:username];
            
            NSString *nameString = user.fullname;
            if (![TAPUtil isEmptyString:nameString]) {
                NSString *firstAlphabet = [[nameString substringWithRange:NSMakeRange(0, 1)] uppercaseString];
                if ([self.alphabetSectionTitles containsObject:firstAlphabet]) {
                    if ([self.indexSectionDictionary objectForKey:firstAlphabet] == nil) {
                        //No alphabet found
                        [self.indexSectionDictionary setObject:[NSArray arrayWithObjects:user, nil] forKey:firstAlphabet];
                    }
                    else {
                        //Alphabet found
                        NSMutableArray *contactArray = [[self.indexSectionDictionary objectForKey:firstAlphabet] mutableCopy];
                        [contactArray addObject:user];
                        [self.indexSectionDictionary setObject:contactArray forKey:firstAlphabet];
                    }
                }
                else {
                    if ([self.indexSectionDictionary objectForKey:@"#"] == nil) {
                        //No alphabet found
                        [self.indexSectionDictionary setObject:[NSArray arrayWithObjects:user, nil] forKey:firstAlphabet];
                    }
                    else {
                        //Alphabet found
                        NSMutableArray *contactArray = [[self.indexSectionDictionary objectForKey:@"#"] mutableCopy];
                        [contactArray addObject:user];
                        [self.indexSectionDictionary setObject:contactArray forKey:firstAlphabet];
                    }
                }
            }
        }
        
        [self.addNewChatView.contactsTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)syncContactWithLoading:(BOOL)loading {
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                
                [[NSUserDefaults standardUserDefaults] setSecureBool:YES forKey:TAP_PREFS_IS_CONTACT_SYNC_ALLOWED_BY_USER];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (loading) {
                    [self.addNewChatView showSyncNotificationWithString:NSLocalizedStringFromTableInBundle(@"Syncing Contacts", nil, [TAPUtil currentBundle], @"") type:TAPSyncNotificationViewTypeSyncing];
                }
                
                //keys with fetching properties
                NSArray *keys = @[CNContactPhoneNumbersKey];
                NSString *containerId = store.defaultContainerIdentifier;
                NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
                NSError *error;
                NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
                if (error) {
                    if (loading) {
                        [self.addNewChatView hideSyncNotification];
                    }
                } else {
                    NSMutableArray *numbersStringArray = [NSMutableArray array];
                    
                    for (CNContact *contact in cnContacts) {
                        for (CNLabeledValue *label in contact.phoneNumbers) {
                            NSString *phone = [label.value stringValue];
                            phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
                            
                            if ([phone length] < 1 || [phone containsString:@"*"] || [phone containsString:@"#"] || [phone containsString:@";"] || [phone containsString:@","]) {
                                //Skip if length is lest than 1, skip if phone contains *#:,
                                continue;
                            }
                            
                            //remove all characters
                            NSString *phoneNumberString = [[phone componentsSeparatedByCharactersInSet:
                                                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                                           componentsJoinedByString:@""];
                            
                            NSString *userCountryCode = [[TAPContactManager sharedManager] getUserCountryCode];
                            if (![phone hasPrefix:@"+"]) {
                                if ([phoneNumberString hasPrefix:@"0"]) {
                                    phoneNumberString = [phoneNumberString stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:userCountryCode];
                                }
                                
                                if (![phoneNumberString hasPrefix:@"0"] && ![phoneNumberString hasPrefix:userCountryCode]) {
                                    phoneNumberString = [NSString stringWithFormat:@"%@%@", userCountryCode, phoneNumberString];
                                }
                            }
                            
                            //Check if number is in contact list
                            if (![[TAPContactManager sharedManager] checkUserExistWithPhoneNumber:phoneNumberString]) {
                                [numbersStringArray addObject:phoneNumberString];
                            }
                        }
                    }
                    
                    if ([numbersStringArray count] > 0) {
                        //There's New Contacts
                        [TAPDataManager callAPIAddContactWithPhones:numbersStringArray success:^(NSArray *users) {
                            [self loadContactListFromDatabase];
                            if (loading) {
                                [self.addNewChatView hideSyncNotification];
                            }
                            if ([users count] > 0) {
                                //new contacts synced
                                
                                NSString *contactString = NSLocalizedStringFromTableInBundle(@"Contact", nil, [TAPUtil currentBundle], @"");
                                if ([users count] > 1) {
                                    contactString = NSLocalizedStringFromTableInBundle(@"Contacts", nil, [TAPUtil currentBundle], @"");
                                }
                                
                                NSString *syncedString = NSLocalizedStringFromTableInBundle(@"Synced", nil, [TAPUtil currentBundle], @"");
                                
                                [self.addNewChatView showSyncNotificationWithString:[NSString stringWithFormat:@"%ld %@ %@", [users count], syncedString, contactString] type:TAPSyncNotificationViewTypeSynced];
                            }
                            else {
                                //All contacts synced
                                if (loading) {
                                    [self.addNewChatView showSyncNotificationWithString:NSLocalizedStringFromTableInBundle(@"All Contacts Synced", nil, [TAPUtil currentBundle], @"") type:TAPSyncNotificationViewTypeSynced];
                                }
                            }
                        } failure:^(NSError *error) {
                            if (loading) {
                                [self.addNewChatView hideSyncNotification];
                            }
                        }];
                    }
                    else {
                        //No New Contacts
                        if (loading) {
                            [self.addNewChatView showSyncNotificationWithString:NSLocalizedStringFromTableInBundle(@"All Contacts Synced", nil, [TAPUtil currentBundle], @"") type:TAPSyncNotificationViewTypeSynced];
                        }
                    }
                }
            }
            else {
                NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSContactsUsageDescription"];
                
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:NSLocalizedStringFromTableInBundle(@"To give permissions tap on 'Change Settings' button", nil, [TAPUtil currentBundle], @"") preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                
                UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Change Settings", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (IS_IOS_11_OR_ABOVE) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
                    }
                    else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                }];
                [alertController addAction:settingsAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
        });
    }];
}

- (void)requestAccessAndCheckNewContact {
    BOOL isAutoSyncEnabled = [[TapTalk sharedInstance] isAutoContactSyncEnabled];
    BOOL isContactSyncAllowedByUser = [[NSUserDefaults standardUserDefaults] secureBoolForKey:TAP_PREFS_IS_CONTACT_SYNC_ALLOWED_BY_USER valid:nil];
    if (!isAutoSyncEnabled) {
        //Auto sync contact disabled
        return;
    }
    
    BOOL isContactPermissionAsked = [[TAPContactManager sharedManager] isContactPermissionAsked];
    if (isContactPermissionAsked) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted && isContactSyncAllowedByUser) {
                    //2nd time sync contact and so on, not show loading
                    [self syncContactWithLoading:NO];
                }
                else {
                    //not granted, show sync button view
                    [self.addNewChatView showSyncContactButtonView:YES];
                }
            });
        }];
    }
    else {
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Contact Access" title:NSLocalizedStringFromTableInBundle(@"Contact Access", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"We need your permission to access your contact, we will sync your contact to our server and automatically find your friend so it is easier for you to find your friends.", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Allow", nil, [TAPUtil currentBundle], @"")];
        [[TAPContactManager sharedManager] setContactPermissionAsked];
        [[NSUserDefaults standardUserDefaults] setSecureBool:NO forKey:TAP_PREFS_IS_CONTACT_SYNC_ALLOWED_BY_USER];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    if(!self.skipCheckContactSync) {
        [self requestAccessAndCheckNewContact];
    }
}

#pragma mark PopUpInfoViewController
- (void)popUpInfoDidTappedLeftButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoDidTappedLeftButtonWithIdentifier:popupIdentifier];
    if ([popupIdentifier isEqualToString:@"Contact Access"]) {
        //Decline Access
        //not granted, show sync button view
        [self.addNewChatView showSyncContactButtonView:YES];
    }
    else if ([popupIdentifier isEqualToString:@"Sync Contact Manually"]) {
        //Decline
    }
}

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:popupIdentifier];
    if ([popupIdentifier isEqualToString:@"Contact Access"]) {
        //Allow Access
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    //1st time sync contact, show loading
                    [self syncContactWithLoading:YES];
                }
                else {
                    //not granted, show sync button view
                    [self.addNewChatView showSyncContactButtonView:YES];
                    _skipCheckContactSync = YES;
                }
            });
        }];
    }
    else if ([popupIdentifier isEqualToString:@"Sync Contact Manually"]) {
        [self.addNewChatView showSyncContactButtonView:NO];
        [self syncContactWithLoading:YES];
    }
}

@end
