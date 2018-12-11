//
//  AddNewChatViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPAddNewChatViewController.h"
#import "TAPAddNewChatView.h"
#import "TAPScanQRCodeViewController.h"
#import "TAPBlockedListViewController.h"
#import "TAPAddNewContactViewController.h"
#import "TAPNewGroupViewController.h"

#import "TAPChatViewController.h"
#import <Photos/Photos.h>

//WK Note - addNewChatView.contactsTableView tableViewCell
#import "TAPNewChatOptionTableViewCell.h"
#import "TAPContactTableViewCell.h"
#import "TAPNewChatBlockedContactsTableViewCell.h"

//WK Note - addNewChatView.searchResultTableView tableViewCell
#import "TAPNewChatAddNewContactTableViewCell.h"

@interface TAPAddNewChatViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) TAPAddNewChatView *addNewChatView;

@property (strong, nonatomic) NSArray *alphabetSectionTitles;
@property (strong, nonatomic) NSArray *contactListArray;
@property (strong, nonatomic) NSMutableArray *searchResultUserMutableArray;

@property (strong, nonatomic) NSMutableDictionary *indexSectionDictionary;
@property (strong, nonatomic) NSMutableDictionary *contactListDictionary;

@property (strong, nonatomic) NSString *updatedString;

- (void)loadContactListFromDatabase;

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
    self.addNewChatView.searchBarView.searchTextField.delegate = self;
    self.addNewChatView.contactsTableView.delegate = self;
    self.addNewChatView.contactsTableView.dataSource = self;
    self.addNewChatView.searchResultTableView.delegate = self;
    self.addNewChatView.searchResultTableView.dataSource = self;
    
    self.title = NSLocalizedString(@"New Chat", @"");
    
    [self showCustomCloseButton];
    
    _alphabetSectionTitles = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    //Refresh Contact List From API
    [TAPDataManager callAPIGetContactList:^(NSArray *userArray) {
        [self loadContactListFromDatabase];
    } failure:^(NSError *error) {
//        NSLog(@"%@", error);
    }];
    
    _searchResultUserMutableArray = [NSMutableArray array];
    _updatedString = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Load Contact List From Database
    [self loadContactListFromDatabase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.addNewChatView.contactsTableView) {
        return [self.indexSectionDictionary count] + 2;
        /*
         1 section is options (Add New Contact, Create Group, Scan QR Code)
         1 section is blocked contacts (in the bottom)
         */
    }
    else if (tableView == self.addNewChatView.searchResultTableView) {
        return 2; //1 section is add new contact
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.addNewChatView.contactsTableView) {
        if (section == 0) {
            return 3; //options (Add New Contact, Create Group, Scan QR Code)
        }
        else if (section <= [[self.indexSectionDictionary allKeys] count]) {
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSString *key = [keysArray objectAtIndex:section - 1];
            NSArray *contactArray = [self.indexSectionDictionary objectForKey:key];
            return [contactArray count];
        }
        else if (section == [tableView numberOfSections] - 1) {
            return 1; //blocked contacts
        }
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
        else if (indexPath.section == [self.indexSectionDictionary count] + 1) {
            return 98.0f;
        }
    }
    else if (tableView == self.addNewChatView.searchResultTableView) {
        if (indexPath.section == 0) {
            return 64.0f;
        }
        else if (indexPath.section == 1) {
            return 70.0f;
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
            
            if (indexPath.row == 0) {
                [cell setNewChatOptionTableViewCellType:TAPNewChatOptionTableViewCellTypeNewContact];
            }
            else if (indexPath.row == 1) {
                [cell setNewChatOptionTableViewCellType:TAPNewChatOptionTableViewCellTypeScanQRCode];
            }
            else if (indexPath.row == 2) {
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
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSString *key = [keysArray objectAtIndex:indexPath.section - 1];
            NSArray *userArray = [self.indexSectionDictionary objectForKey:key];
            TAPUserModel *currentUser = [userArray objectAtIndex:indexPath.row];
            [cell setContactTableViewCellWithUser:currentUser];

            [cell isRequireSelection:NO];
            
            if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
                [cell showSeparatorLine:NO];
            }
            else {
                [cell showSeparatorLine:YES];
            }
            
            return cell;
        }
        
        else if (indexPath.section == [tableView numberOfSections] - 1) {
            static NSString *cellID = @"TAPNewChatBlockedContactsTableViewCell";
            TAPNewChatBlockedContactsTableViewCell *cell = [[TAPNewChatBlockedContactsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
    }
    else if (tableView == self.addNewChatView.searchResultTableView) {
        if (indexPath.section == 0) {
            static NSString *cellID = @"TAPContactTableViewCell";
            TAPContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }

            TAPUserModel *user = [self.searchResultUserMutableArray objectAtIndex:indexPath.row];
            [cell setContactTableViewCellWithUser:user];
            [cell isRequireSelection:NO];
            
            if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
                [cell showSeparatorLine:NO];
            }
            else {
                [cell showSeparatorLine:YES];
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
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(header.frame) - 16.0f - 16.0f, 34.0f)];
            titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE];
            titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
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
            if (indexPath.row == 0) {
                //New Contact
                TAPAddNewContactViewController *addNewContactViewController = [[TAPAddNewContactViewController alloc] init];
                [self.navigationController pushViewController:addNewContactViewController animated:YES];
            }
            else if (indexPath.row == 1) {
                //Scan QR Code
                [self openScanQRCode];
            }
            else if (indexPath.row == 2) {
                //New Group
                TAPNewGroupViewController *createGroupViewController = [[TAPNewGroupViewController alloc] init]; //newGroupViewController
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
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:@"Cannot chat with yourself, please select other room" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else {
                TAPUserModel *selectedUser = [self.contactListDictionary objectForKey:selectedUsername];
                [[TapTalk sharedInstance] openRoomWithOtherUser:selectedUser fromNavigationController:self.navigationController];
            }
        }
        else if (indexPath.section == [tableView numberOfSections] - 1) {
            //Blocked Contacts
            TAPBlockedListViewController *blockedListViewController = [[TAPBlockedListViewController alloc] init];
            [self.navigationController pushViewController:blockedListViewController animated:YES];
        }
    }
    else if (tableView == self.addNewChatView.searchResultTableView) {
        if (indexPath.section == [tableView numberOfSections] - 1) {
            TAPAddNewContactViewController *addNewContactViewController = [[TAPAddNewContactViewController alloc] init];
            [self.navigationController pushViewController:addNewContactViewController animated:YES];
        }
        else {
            TAPUserModel *currentUser = [TAPDataManager getActiveUser];
            NSString *currentUsername = currentUser.username;
            
            TAPUserModel *selectedUser = [self.searchResultUserMutableArray objectAtIndex:indexPath.row];
            NSString *selectedUsername = selectedUser.username;
            if ([currentUsername isEqualToString:selectedUsername]) {
                //Chat with himself/herself
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:@"Cannot chat with yourself, please select other room" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else {
                TAPUserModel *selectedUser = [self.contactListDictionary objectForKey:selectedUsername];
                [[TapTalk sharedInstance] openRoomWithOtherUser:selectedUser fromNavigationController:self.navigationController];
            }
        }
    }
}

#pragma mark TextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
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

- (BOOL)textFieldShouldClear:(UITextField *)textField {
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *trimmedNewString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![trimmedNewString isEqualToString:@""]) {
        self.updatedString = newString;
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
            if (IS_IOS_10_OR_ABOVE) {
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
    
    _contactListArray = [NSMutableArray array];
    _indexSectionDictionary = [NSMutableDictionary dictionary];
    _contactListDictionary = [NSMutableDictionary dictionary];
    
    //WK NOTE - The type is TAPContactModel
    [TAPDataManager getDatabaseAllContactSortBy:@"fullname" success:^(NSArray *resultArray) {
        self.contactListArray = resultArray;
        for (TAPUserModel *user in self.contactListArray) {
            NSString *username = user.username;
            [self.contactListDictionary setValue:user forKey:username];
            
            NSString *nameString = user.fullname;
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
        
        [self.addNewChatView.contactsTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

@end
