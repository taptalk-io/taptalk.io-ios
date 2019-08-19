//
//  TAPCreateGroupViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 17/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCreateGroupViewController.h"
#import "TAPCreateGroupView.h"
#import "TAPCreateGroupSubjectViewController.h"
#import "TAPProfileViewController.h"

#import "TAPContactTableViewCell.h"

#import "TAPContactCollectionViewCell.h"
#import "TAPPlainInfoLabelTableViewCell.h"

@interface TAPCreateGroupViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, TAPSearchBarViewDelegate, TAPCreateGroupViewControllerDelegate, TAPProfileViewControllerDelegate>
@property (strong, nonatomic) TAPCreateGroupView *createGroupView;

@property (strong, nonatomic) NSArray *alphabetSectionTitles;
@property (strong, nonatomic) NSArray *contactListArray;
@property (strong, nonatomic) NSMutableDictionary *indexSectionDictionary;
@property (strong, nonatomic) NSMutableDictionary *roomParticipantsDictionary;

@property (strong, nonatomic) NSDictionary *contactListDictionary;
@property (strong, nonatomic) NSMutableArray *selectedUserModelArray;
@property (strong, nonatomic) NSMutableDictionary *selectedIndexDictionary;
@property (strong, nonatomic) NSMutableDictionary *selectedIndexSectionRowPositionDictionary;
@property (strong, nonatomic) NSMutableDictionary *selectedIndexRowSearchPositionDictionary;

@property (strong, nonatomic) NSMutableArray *searchResultUserMutableArray;
@property (strong, nonatomic) NSString *updatedString;

@property (strong, nonatomic) TAPUserModel *currentSelectedUser; //used in remove member, promote admin/ demote admin

@property (nonatomic) BOOL isEditMode;

- (void)loadContactListFromDatabase;
- (void)loadContactsFromRoomModel;
- (void)continueButtonDidTapped;
- (void)addMembersButtonDidTapped;
- (void)removeMembersButtonDidTapped;
- (void)promoteAdminButtonDidTapped;
- (void)demoteAdminButtonDidTapped;

- (void)showFinishLoadingStateWithType:(TAPCreateGroupLoadingType)type;
- (void)removeLoadingView;

@end

@implementation TAPCreateGroupViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _createGroupView = [[TAPCreateGroupView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.createGroupView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.createGroupView.searchBarView.delegate = self;
    
    self.createGroupView.contactsTableView.delegate = self;
    self.createGroupView.contactsTableView.dataSource = self;
    self.createGroupView.searchResultTableView.delegate = self;
    self.createGroupView.searchResultTableView.dataSource = self;
    
    self.createGroupView.selectedContactsCollectionView.delegate = self;
    self.createGroupView.selectedContactsCollectionView.dataSource = self;
    
    [self.createGroupView.continueButtonView.button addTarget:self action:@selector(continueButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.createGroupView.removeMembersButtonView.button addTarget:self action:@selector(removeMembersButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.createGroupView.addMembersButtonView.button addTarget:self action:@selector(addMembersButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.createGroupView.promoteAdminButtonView.button addTarget:self action:@selector(promoteAdminButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.createGroupView.demoteAdminButtonView.button addTarget:self action:@selector(demoteAdminButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];

   _alphabetSectionTitles = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault) {
        self.title = NSLocalizedString(@"New Group", @"");
        [self showCustomBackButton];
        [self.createGroupView setTapCreateGroupViewType:TAPCreateGroupViewTypeDefault];
        [self loadContactListFromDatabase];
        self.createGroupView.searchBarView.customPlaceHolderString = NSLocalizedString(@"Search for contacts", @"");

    }
    else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewTypeAddMember) {
        self.title = NSLocalizedString(@"Add Members", @"");
        [self showCustomCancelButton];
        [self.createGroupView setTapCreateGroupViewType:TAPCreateGroupViewTypeAddMember];
        _roomParticipantsDictionary = [[NSMutableDictionary alloc] init];
        for (TAPUserModel *user in self.room.participants) {
            [self.roomParticipantsDictionary setObject:user forKey:user.userID];
        }
        [self loadContactListFromDatabase];
        self.createGroupView.searchBarView.customPlaceHolderString = NSLocalizedString(@"Search for contacts", @"");
      
    }
    else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
        [self.createGroupView setTapCreateGroupViewType:TAPCreateGroupViewTypeMemberList];
        [self showCustomBackButton];
        
        self.title = NSLocalizedString(@"Group Members", @"");
        if ([self.room.participants count] > 0) {
            //participants loaded
            //load and populate UI
            [self loadContactsFromRoomModel];
        }
        else {
            //participants not loaded - call api, show loading
            [self.createGroupView showLoadingMembersView:YES];
            [TAPDataManager callAPIGetRoomWithRoomID:self.room.roomID success:^(TAPRoomModel *room) {
                _room = room;
                [self.createGroupView showLoadingMembersView:NO];
                [self loadContactsFromRoomModel];

            } failure:^(NSError *error) {
                [self.createGroupView showLoadingMembersView:NO];
                  [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Get Members" title:NSLocalizedString(@"Failed", @"") detailInformation:error.domain leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
            }];
        }
        self.createGroupView.searchBarView.customPlaceHolderString = NSLocalizedString(@"Search for members", @"");
    }
    
    _selectedUserModelArray = [NSMutableArray array];
    _selectedIndexDictionary = [NSMutableDictionary dictionary];
    _searchResultUserMutableArray = [NSMutableArray array];
    _selectedIndexSectionRowPositionDictionary = [NSMutableDictionary dictionary];
    _selectedIndexRowSearchPositionDictionary = [NSMutableDictionary dictionary];
    _updatedString = @"";
    
    [self.navigationController.navigationBar addSubview:self.createGroupView.loadingBackgroundView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showNavigationSeparator:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.createGroupView.contactsTableView) {
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
            return 1;
        }
        return [self.indexSectionDictionary count];
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        return 1;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.createGroupView.contactsTableView) {
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
            return [self.room.participants count] + 1;
        }
        else if (section <= [self.indexSectionDictionary count] - 1) {
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSString *key = [keysArray objectAtIndex:section];
            NSArray *contactArray = [self.indexSectionDictionary objectForKey:key];
            return [contactArray count];
        }
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        if (section == 0) {
            return [self.searchResultUserMutableArray count];
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.createGroupView.contactsTableView) {
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
            if (indexPath.row == [self.room.participants count]) {
                return 68.0f;
            }
            return 64.0;
        }
        else {
            if (indexPath.section <= [self.alphabetSectionTitles count] - 1) {
                return 64.0f;
            }
        }
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        if (indexPath.section == 0) {
            return 64.0f;
        }
    }
    
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.createGroupView.contactsTableView) {
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
            if (indexPath.row < [self.room.participants count]) {
                static NSString *cellID = @"TAPContactTableViewCell";
                TAPContactTableViewCell *cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                TAPUserModel *currentUser = [self.room.participants objectAtIndex:indexPath.row];
                [cell setContactTableViewCellWithUser:currentUser];
                
                [cell isRequireSelection:self.isEditMode];
                //if current user is self, do nothing
                if ([currentUser.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                    [cell isRequireSelection:NO];
                }
                
                if (self.isEditMode && ![currentUser.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                    if ([self.selectedIndexDictionary objectForKey:currentUser.userID]) {
                        [cell isCellSelected:YES];
                    }
                    else {
                        [cell isCellSelected:NO];
                    }
                }
                
                if (indexPath.row == [self.room.participants count] - 1) {
                    [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeFull];
                }
                else {
                    [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeDefault];
                }
                
                if ([self.room.admins containsObject:currentUser.userID]) {
                    //is admin
                    [cell showAdminIndicator:YES];
                }
                else {
                    //not admin
                    [cell showAdminIndicator:NO];
                }
                
                return cell;
            }
            else {
             //number of member cell
                static NSString *cellID = @"TAPPlainInfoLabelTableViewCell";
                TAPPlainInfoLabelTableViewCell *cell = [[TAPPlainInfoLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                [cell setInfoLabelWithString:[NSString stringWithFormat:@"%ld Members", [self.room.participants count]]];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault || self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
        
            if (indexPath.section <= [self.indexSectionDictionary count] - 1) {
                static NSString *cellID = @"TAPContactTableViewCell";
                TAPContactTableViewCell *cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                
                NSArray *keysArray = [self.indexSectionDictionary allKeys];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
                keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
                
                NSString *key = [keysArray objectAtIndex:indexPath.section];
                NSArray *contactArray = [self.indexSectionDictionary objectForKey:key];
                TAPUserModel *currentUser = [contactArray objectAtIndex:indexPath.row];
                [cell setContactTableViewCellWithUser:currentUser];
                
                [cell isRequireSelection:YES];
                
                if ([self.selectedIndexDictionary objectForKey:currentUser.userID]) {
                    [cell isCellSelected:YES];
                }
                else {
                    [cell isCellSelected:NO];
                }
                
                if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
                    [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeFull];
                }
                else {
                    [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeDefault];
                }
                
                //save section and row position to dictionary
                if ([self.selectedIndexSectionRowPositionDictionary objectForKey:currentUser.userID] == nil) {
                    [self.selectedIndexSectionRowPositionDictionary setObject:[NSString stringWithFormat:@"%ld - %ld", indexPath.section, indexPath.row] forKey:currentUser.userID];
                }
                return cell;

        }
            
        }
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        static NSString *cellID = @"TAPContactTableViewCell";
        TAPContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        TAPUserModel *user = [self.searchResultUserMutableArray objectAtIndex:indexPath.row];
        [cell setContactTableViewCellWithUser:user];
        
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault || self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
            [cell isRequireSelection:YES];
            
            if ([self.selectedIndexDictionary objectForKey:user.userID]) {
                [cell isCellSelected:YES];
            }
            else {
                [cell isCellSelected:NO];
            }
        }
        else {
            [cell isRequireSelection:self.isEditMode];
            
            if (self.isEditMode) {
                if ([self.selectedIndexDictionary objectForKey:user.userID]) {
                    [cell isCellSelected:YES];
                }
                else {
                    [cell isCellSelected:NO];
                }
            }
            
            if ([self.room.admins containsObject:user.userID]) {
                //is admin
                [cell showAdminIndicator:YES];
            }
            else {
                //not admin
                [cell showAdminIndicator:NO];
            }
        }
        
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeFull];
        }
        else {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeDefault];
        }
        
        //save section and row position to dictionary
        if ([self.selectedIndexRowSearchPositionDictionary objectForKey:user.userID] == nil) {
            [self.selectedIndexRowSearchPositionDictionary setObject:[NSString stringWithFormat:@"%ld", indexPath.row] forKey:user.userID];
        }
        
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.createGroupView.contactsTableView) {
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
            return CGFLOAT_MIN;
        }
        else if (section <= [self.alphabetSectionTitles count] - 1) {
            return 34.0f;
        }
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.createGroupView.contactsTableView) {
        if (section <= [[self.indexSectionDictionary allKeys] count]) {
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 34.0f)];
            header.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            UIFont *sectionHeaderFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
            UIColor *sectionHeaderColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTableViewSectionHeaderLabel];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(header.frame) - 16.0f - 16.0f, 34.0f)];
            titleLabel.textColor = sectionHeaderColor;
            titleLabel.font = sectionHeaderFont;
            [header addSubview:titleLabel];
            
            if ([keysArray count] != 0) {
                titleLabel.text = [keysArray objectAtIndex:section];
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
    if (tableView == self.createGroupView.contactsTableView) {
        if (section <= [[self.indexSectionDictionary allKeys] count]) {
            //Contacts
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            return [keysArray objectAtIndex:section];
        }
    }
    
    return @"";
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.createGroupView.contactsTableView && [self.indexSectionDictionary count] >= 5) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        return keysArray;
    }
    
    NSArray *sectionIndexArray = [NSArray array];
    return sectionIndexArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.createGroupView.contactsTableView) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        return [keysArray indexOfObject:title];
    }
    
    return 0;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.room.participants count]) {
        return [UISwipeActionsConfiguration configurationWithActions:@[]];
    }
    
    TAPUserModel *currentUser = nil;
    if (tableView == self.createGroupView.contactsTableView) {
        //contacts table view
        currentUser = [self.contactListArray objectAtIndex:indexPath.row];
    }
    else {
        //search result table view
        currentUser = [self.searchResultUserMutableArray objectAtIndex:indexPath.row];
    }
    
    UIContextualAction *promoteAdminAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        self.currentSelectedUser = currentUser;
//       [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Promote Admin" title:NSLocalizedString(@"Promote to Admin", @"") detailInformation:NSLocalizedString(@"Are you sure you want to promote this member to admin?", @"") leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"OK"];
        [self.createGroupView showLoadingView:YES];
        [self.createGroupView setAsLoadingState:YES withType:TAPCreateGroupLoadingTypeAppointAdmin];
        [TAPDataManager callAPIPromoteRoomAdminsWithRoomID:self.room.roomID userIDArray:@[self.currentSelectedUser.userID] success:^(TAPRoomModel *room) {
            _room = room;
            _isEditMode = NO;
            [self.selectedIndexDictionary removeAllObjects];
            [self.selectedUserModelArray removeAllObjects];
            [self loadContactsFromRoomModel];
            [self showFinishLoadingStateWithType:TAPCreateGroupLoadingTypeAppointAdmin];
            
            [self.createGroupView showBottomActionButtonViewExtension:NO withActiveButton:0];
            
        } failure:^(NSError *error) {
            [self removeLoadingView];
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Promote Admin" title:NSLocalizedString(@"Failed", @"") detailInformation:error.domain leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
    }];
    promoteAdminAction.image = [UIImage imageNamed:@"TAPSwipeActionPromote" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    promoteAdminAction.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
    
    UIContextualAction *demoteAdminAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        self.currentSelectedUser = currentUser;
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Demote Admin" title:NSLocalizedString(@"Demote from Admin", @"") detailInformation:NSLocalizedString(@"Are you sure you want to demote this admin?", @"") leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"OK"];
        
    }];
    demoteAdminAction.image = [UIImage imageNamed:@"TAPSwipeActionDemote" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    demoteAdminAction.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
    
    UIContextualAction *removeAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        self.currentSelectedUser = currentUser;
[self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Remove Member" title:NSLocalizedString(@"Remove Member", @"") detailInformation:NSLocalizedString(@"Are you sure you want to remove this member?", @"") leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"OK"];
        
    }];
    removeAction.image = [UIImage imageNamed:@"TAPSwipeActionRemove" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    removeAction.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconDestructive];
    
    NSArray *rowActionArray = @[removeAction, promoteAdminAction];

    BOOL currentUserIsAdmin = [self.room.admins containsObject:currentUser.userID];

    if (currentUserIsAdmin) {
        rowActionArray = @[removeAction, demoteAdminAction];
    }

    BOOL isAdmin = [self.room.admins containsObject:[TAPDataManager getActiveUser].userID];
    if (self.isEditMode || self.tapCreateGroupViewControllerType != TAPCreateGroupViewControllerTypeMemberList || !isAdmin || [[TAPDataManager getActiveUser].userID isEqualToString:currentUser.userID]) {
        return [UISwipeActionsConfiguration configurationWithActions:@[]];
    }
    
    return [UISwipeActionsConfiguration configurationWithActions:rowActionArray];
}

#pragma mark UICollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(52.0f, 74.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0f, 16.0f, 0.0f, 16.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 16.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember || self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
        return [self.selectedUserModelArray count];
    }
    return [self.selectedUserModelArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPContactCollectionViewCell";
        
        [collectionView registerClass:[TAPContactCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPContactCollectionViewCell *cell = (TAPContactCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault) {
            if (indexPath.row == 0) {
                //Group Admin
                [cell setContactCollectionViewCellWithModel:[TAPDataManager getActiveUser]];
                [cell showRemoveIcon:NO];
                
                return cell;
            }
            else {
                TAPUserModel *user = [self.selectedUserModelArray objectAtIndex:indexPath.row - 1];
                
                [cell setContactCollectionViewCellWithModel:user];
                [cell showRemoveIcon:YES];
                
                return cell;
            }
        }
        else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
            TAPUserModel *user = [self.selectedUserModelArray objectAtIndex:indexPath.row];
            
            [cell setContactCollectionViewCellWithModel:user];
            [cell showRemoveIcon:YES];
            
            return cell;
        }
    }
    
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    return cell;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesInRect = [NSArray array];
    return attributesInRect;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
        return reusableview;
    }
    else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
        return reusableview;
    }
    
    return nil;
}

#pragma mark - Delegate
#pragma mark TableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.createGroupView.contactsTableView) {
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault || self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
            //Contacts
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSString *key = [keysArray objectAtIndex:indexPath.section];
            NSArray *contactArray = [self.indexSectionDictionary objectForKey:key];
            TAPUserModel *currentUser = [contactArray objectAtIndex:indexPath.row];
            
            NSString *objectString = currentUser.userID;
            
            TAPContactTableViewCell *contactTableViewCell = [self.createGroupView.contactsTableView cellForRowAtIndexPath:indexPath];
            if ([self.selectedIndexDictionary objectForKey:objectString]) {
                [self.selectedUserModelArray removeObject:[self.selectedIndexDictionary objectForKey:objectString]];
                [self.selectedIndexDictionary removeObjectForKey:objectString];
                [contactTableViewCell isCellSelected:NO];
            }
            else {
                TAPCoreConfigsModel *coreConfigs = [TAPDataManager getCoreConfigs];
                NSInteger maxGroupMember = [coreConfigs.groupMaxParticipants integerValue] - 1; // -1 for admin that created the group
                if ([self.selectedUserModelArray count] == maxGroupMember - [self.room.participants count]) {
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Add More Member In Group" title:NSLocalizedString(@"Cannot add more people", @"") detailInformation:NSLocalizedString(@"The max limit number of people in one group chat has been reached",@"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                }
                else {
                    [self.selectedUserModelArray addObject:currentUser];
                    [self.selectedIndexDictionary setObject:currentUser forKey:objectString];
                    
                    [contactTableViewCell isCellSelected:YES];
                }
            }
            
            //check array count
            [self validateselectedUserModelArray];
        }
        else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList && self.isEditMode && indexPath.row < [self.contactListArray count]) {

            TAPUserModel *currentUser = [self.contactListArray objectAtIndex:indexPath.row];

            //if current user is self, do nothing
            if ([currentUser.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                return;
            }
            
            TAPContactTableViewCell *contactTableViewCell = [self.createGroupView.contactsTableView cellForRowAtIndexPath:indexPath];
            if ([self.selectedIndexDictionary objectForKey:currentUser.userID]) {
                [self.selectedIndexDictionary removeObjectForKey:currentUser.userID];
                [contactTableViewCell isCellSelected:NO];
            }
            else {
                [self.selectedIndexDictionary setObject:currentUser forKey:currentUser.userID];
                
                [contactTableViewCell isCellSelected:YES];
            }
            
            if ([self.selectedIndexDictionary count] == 1) {
                NSArray *indexArray = [self.selectedIndexDictionary allKeys];
                TAPUserModel *user = [self.selectedIndexDictionary objectForKey:[indexArray firstObject]];
                if ([self.room.admins containsObject:user.userID]) {                    //is admin
                    [self.createGroupView showBottomActionButtonViewExtension:YES withActiveButton:TAPCreateGroupActionExtensionTypeDemoteAdmin];
                }
                else {
                    //not admin
                    [self.createGroupView showBottomActionButtonViewExtension:YES withActiveButton:TAPCreateGroupActionExtensionTypePromoteAdmin];
                }
            }
            else {
                [self.createGroupView showBottomActionButtonViewExtension:NO withActiveButton:0];
            }
        }
        else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList && !self.isEditMode && indexPath.row < [self.contactListArray count]) {
            
            TAPUserModel *currentUser = [self.contactListArray objectAtIndex:indexPath.row];
            
            //if current user is self, do nothing
            if ([currentUser.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                return;
            }
            
            TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
            profileViewController.room = self.room;
            profileViewController.user = currentUser;
            profileViewController.delegate = self;
            profileViewController.tapProfileViewControllerType = TAPProfileViewControllerTypeGroupMemberProfile;
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        //Contacts
        TAPUserModel *currentUser = [self.searchResultUserMutableArray objectAtIndex:indexPath.row];
        
        NSString *objectString = currentUser.userID;
        
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault || self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
            TAPContactTableViewCell *contactTableViewCell = [self.createGroupView.searchResultTableView cellForRowAtIndexPath:indexPath];
            if ([self.selectedIndexDictionary objectForKey:objectString]) {
                [self.selectedUserModelArray removeObject:[self.selectedIndexDictionary objectForKey:objectString]];
                [self.selectedIndexDictionary removeObjectForKey:objectString];
                
                [contactTableViewCell isCellSelected:NO];
            }
            else {
                TAPCoreConfigsModel *coreConfigs = [TAPDataManager getCoreConfigs];
                NSInteger maxGroupMember = [coreConfigs.groupMaxParticipants integerValue] - 1; // -1 for admin that created the group
                if ([self.selectedUserModelArray count] == maxGroupMember && self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault) {
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Add More Member In Group" title:NSLocalizedString(@"Failed", @"") detailInformation:NSLocalizedString(@"Exceeded number of maximum group members",@"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                }
                else if ([self.selectedUserModelArray count] == maxGroupMember - [self.room.participants count] + 1 && self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Add More Member In Group" title:NSLocalizedString(@"Failed", @"") detailInformation:NSLocalizedString(@"Exceeded number of maximum group members",@"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                }
                else {
                    [self.selectedUserModelArray addObject:currentUser];
                    [self.selectedIndexDictionary setObject:currentUser forKey:objectString];
                    
                    [contactTableViewCell isCellSelected:YES];
                }
            }
        }
        else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList && self.isEditMode && indexPath.row < [self.contactListArray count]) {
            
            TAPContactTableViewCell *contactTableViewCell = [self.createGroupView.searchResultTableView cellForRowAtIndexPath:indexPath];
            TAPUserModel *currentUser = [self.searchResultUserMutableArray objectAtIndex:indexPath.row];
            if ([self.selectedIndexDictionary objectForKey:currentUser.userID]) {
                [self.selectedIndexDictionary removeObjectForKey:currentUser.userID];
                [contactTableViewCell isCellSelected:NO];
            }
            else {
                [self.selectedIndexDictionary setObject:currentUser forKey:currentUser.userID];
                
                [contactTableViewCell isCellSelected:YES];
            }
            
            if ([self.selectedIndexDictionary count] == 1) {
                NSArray *indexArray = [self.selectedIndexDictionary allKeys];
                TAPUserModel *user = [self.selectedIndexDictionary objectForKey:[indexArray firstObject]];
                if ([self.room.admins containsObject:user.userID]) {
                    //is admin
                    [self.createGroupView showBottomActionButtonViewExtension:YES withActiveButton:TAPCreateGroupActionExtensionTypeDemoteAdmin];
                }
                else {
                    //not admin
                    [self.createGroupView showBottomActionButtonViewExtension:YES withActiveButton:TAPCreateGroupActionExtensionTypePromoteAdmin];
                }
            }
            else {
                [self.createGroupView showBottomActionButtonViewExtension:NO withActiveButton:0];
            }
        }
        else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList && !self.isEditMode && indexPath.row < [self.contactListArray count]) {
            
            TAPUserModel *currentUser = [self.searchResultUserMutableArray objectAtIndex:indexPath.row];
            
            //if current user is self, do nothing
            if ([currentUser.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                return;
            }
            
            TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
            profileViewController.room = self.room;
            profileViewController.user = currentUser;
            profileViewController.delegate = self;
            profileViewController.tapProfileViewControllerType = TAPProfileViewControllerTypeGroupMemberProfile;
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
        
        //check array count
        [self validateselectedUserModelArray];
    }
}

#pragma mark UICollectionView
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault) {
        if (indexPath.row != 0) { //WK Note : indexPath.row 0 is group admin
            
            TAPUserModel *currentUser = [self.selectedUserModelArray objectAtIndex:indexPath.row - 1];
            
            NSString *objectString = [self.selectedIndexSectionRowPositionDictionary objectForKey:currentUser.userID];
            
            if (![TAPUtil isEmptyString:objectString]) {
                NSArray *objectStringSplitArray = [objectString componentsSeparatedByString:@" - "];
                NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:[[objectStringSplitArray objectAtIndex:1] integerValue] inSection:[[objectStringSplitArray objectAtIndex:0] integerValue]];
                
                NSIndexPath *selectedSearchIndexPath = [NSIndexPath indexPathForItem:[[self.selectedIndexRowSearchPositionDictionary objectForKey:currentUser.userID] integerValue] inSection:0];

                [self.selectedUserModelArray removeObjectAtIndex:indexPath.row - 1];
                [self.selectedIndexDictionary removeObjectForKey:currentUser.userID];
                
                TAPContactTableViewCell *contactTableViewCell = [self.createGroupView.contactsTableView cellForRowAtIndexPath:selectedIndexPath];
                [contactTableViewCell isCellSelected:NO];
                
                TAPContactTableViewCell *contactSearchTableViewCell = [self.createGroupView.searchResultTableView cellForRowAtIndexPath:selectedSearchIndexPath];
                [contactSearchTableViewCell isCellSelected:NO];
            }
            
            [self validateselectedUserModelArray];
        }
    }
    else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
            TAPUserModel *currentUser = [self.selectedUserModelArray objectAtIndex:indexPath.row];
            
            NSString *objectString = [self.selectedIndexSectionRowPositionDictionary objectForKey:currentUser.userID];
            
            if (![TAPUtil isEmptyString:objectString]) {
                NSArray *objectStringSplitArray = [objectString componentsSeparatedByString:@" - "];
                NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:[[objectStringSplitArray objectAtIndex:1] integerValue] inSection:[[objectStringSplitArray objectAtIndex:0] integerValue]];
                
                NSIndexPath *selectedSearchIndexPath = [NSIndexPath indexPathForItem:[[self.selectedIndexRowSearchPositionDictionary objectForKey:currentUser.userID] integerValue] inSection:0];
                
                [self.selectedUserModelArray removeObjectAtIndex:indexPath.row];
                [self.selectedIndexDictionary removeObjectForKey:currentUser.userID];
                
                TAPContactTableViewCell *contactTableViewCell = [self.createGroupView.contactsTableView cellForRowAtIndexPath:selectedIndexPath];
                [contactTableViewCell isCellSelected:NO];
                
                TAPContactTableViewCell *contactSearchTableViewCell = [self.createGroupView.searchResultTableView cellForRowAtIndexPath:selectedSearchIndexPath];
                [contactSearchTableViewCell isCellSelected:NO];
            
            [self validateselectedUserModelArray];
        }
    }
}

#pragma mark TAPCreateGroupView
- (BOOL)searchBarTextFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        if (textField == self.createGroupView.searchBarView.searchTextField) {
            [self.createGroupView showOverlayView:YES];
            [UIView animateWithDuration:0.3f animations:^{
                CGRect searchBarViewFrame = self.createGroupView.searchBarView.frame;
                searchBarViewFrame.size.width = CGRectGetWidth(self.createGroupView.searchBarView.frame) - 70.0f;
                self.createGroupView.searchBarView.frame = searchBarViewFrame;
                
                CGRect searchBarCancelButtonFrame = self.createGroupView.searchBarCancelButton.frame;
                searchBarCancelButtonFrame.origin.x = CGRectGetMaxX(searchBarViewFrame) + 8.0f;
                searchBarCancelButtonFrame.size.width = 70.0f;
                self.createGroupView.searchBarCancelButton.frame = searchBarCancelButtonFrame;
            } completion:^(BOOL finished) {
                //completion
                [self.searchResultUserMutableArray removeAllObjects];
                [self.createGroupView.searchResultTableView reloadData];
            }];
        }
    }
    
    return YES;
}

- (BOOL)searchBarTextFieldShouldClear:(UITextField *)textField {
    [self.searchResultUserMutableArray removeAllObjects];
    [self.createGroupView showOverlayView:YES];
    [UIView animateWithDuration:0.2f animations:^{
        self.createGroupView.searchResultTableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        //completion
        [self.createGroupView.searchResultTableView reloadData];
        [self.createGroupView.contactsTableView reloadData];
    }];
    return YES;
}

- (BOOL)searchBarTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *trimmedNewString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![trimmedNewString isEqualToString:@""]) {
        self.updatedString = newString;
        NSString *trimmedString = [self.updatedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault || self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
            [TAPDataManager getDatabaseContactSearchKeyword:trimmedString sortBy:@"fullname" success:^(NSArray *resultArray) {
                self.searchResultUserMutableArray = resultArray;
                
                if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
                    //filter added user in group
                    NSMutableArray *filteredArray = [NSMutableArray array];
                    for (TAPUserModel *user in resultArray) {
                        if ([self.roomParticipantsDictionary objectForKey:user.userID] == nil) {
                            [filteredArray addObject:user];
                        }
                    }
                    self.searchResultUserMutableArray = filteredArray;
                }
                
                [self.selectedIndexRowSearchPositionDictionary removeAllObjects];
                [self.createGroupView.searchResultTableView reloadData];
                
                [self.createGroupView showOverlayView:NO];
                [UIView animateWithDuration:0.2f animations:^{
                    self.createGroupView.searchResultTableView.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    //completion
                }];
            } failure:^(NSError *error) {
                
            }];
        }
        else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullname contains[c] %@",trimmedString];
            NSArray *resultArray = [self.contactListArray filteredArrayUsingPredicate:predicate];
            
            self.searchResultUserMutableArray = [resultArray mutableCopy];
            [self.createGroupView.searchResultTableView reloadData];
            
            [self.createGroupView showOverlayView:NO];
            [UIView animateWithDuration:0.2f animations:^{
                self.createGroupView.searchResultTableView.alpha = 1.0f;
            } completion:^(BOOL finished) {
                //completion
            }];
        }
    }
    else {
        textField.text = @"";
        [self.searchResultUserMutableArray removeAllObjects];
        [self.createGroupView showOverlayView:YES];
        [UIView animateWithDuration:0.2f animations:^{
            self.createGroupView.searchResultTableView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            //completion
            [self.createGroupView.searchResultTableView reloadData];
            [self.createGroupView.contactsTableView reloadData];
        }];
        
        return NO;
    }
    
    return YES;
}

#pragma mark TAPCreateGroupViewController
- (void)createGroupViewControllerUpdatedRoom:(TAPRoomModel *)room {
    if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
        _room = room;
        [self loadContactsFromRoomModel];
    }
}

#pragma mark TAPProfileViewController
- (void)profileViewControllerUpdatedRoom:(TAPRoomModel *)room {
    if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
        _room = room;
        [self loadContactsFromRoomModel];
    }
}

#pragma mark PopUpInfoViewController
- (void)popUpInfoDidTappedLeftButtonWithIdentifier:(NSString *)popupIdentifier {
    
}

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:popupIdentifier];
    
    if ([popupIdentifier isEqualToString:@"Error Add More Member In Group"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Remove Members"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Remove Member"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Add Members"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Promote Admin"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Demote Admin"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Get Members"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([popupIdentifier isEqualToString:@"Promote Admin"]) {
//        [self.createGroupView showLoadingView:YES];
//        [self.createGroupView setAsLoadingState:YES withType:TAPCreateGroupLoadingTypeAppointAdmin];
//        [TAPDataManager callAPIPromoteRoomAdminsWithRoomID:self.room.roomID userIDArray:@[self.currentSelectedUser.userID] success:^(TAPRoomModel *room) {
//            _room = room;
//            _isEditMode = NO;
//            [self.selectedIndexDictionary removeAllObjects];
//            [self.selectedUserModelArray removeAllObjects];
//            [self loadContactsFromRoomModel];
//            [self showFinishLoadingStateWithType:TAPCreateGroupLoadingTypeAppointAdmin];
//
//            [self.createGroupView showBottomActionButtonViewExtension:NO withActiveButton:0];
//
//        } failure:^(NSError *error) {
//            [self removeLoadingView];
//           [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Promote Admin" title:NSLocalizedString(@"Failed", @"") detailInformation:error.domain leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
//        }];
    }
    else if ([popupIdentifier isEqualToString:@"Demote Admin"]) {
        [self.createGroupView showLoadingView:YES];
        [self.createGroupView setAsLoadingState:YES withType:TAPCreateGroupLoadingTypeRemoveAdmin];
        [TAPDataManager callAPIDemoteRoomAdminsWithRoomID:self.room.roomID userIDArray:@[self.currentSelectedUser.userID] success:^(TAPRoomModel *room) {
            _room = room;
            _isEditMode = NO;
            [self.selectedIndexDictionary removeAllObjects];
            [self.selectedUserModelArray removeAllObjects];
            [self loadContactsFromRoomModel];
            [self showFinishLoadingStateWithType:TAPCreateGroupLoadingTypeRemoveAdmin];
            
            [self.createGroupView showBottomActionButtonViewExtension:NO withActiveButton:0];
        } failure:^(NSError *error) {
            [self removeLoadingView];
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Demote Admin" title:NSLocalizedString(@"Failed", @"") detailInformation:error.domain leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
    }
    else if ([popupIdentifier isEqualToString:@"Remove Member"]) {
        [self.createGroupView showLoadingView:YES];
        [self.createGroupView setAsLoadingState:YES withType:TAPCreateGroupLoadingTypeRemoveMember];
        [TAPDataManager callAPIRemoveRoomParticipantsWithRoomID:self.room.roomID userIDArray:@[self.currentSelectedUser.userID] success:^(TAPRoomModel *room) {
            _room = room;
            _isEditMode = NO;
            [self loadContactsFromRoomModel];
            [self.selectedIndexDictionary removeAllObjects];
            [self.selectedUserModelArray removeAllObjects];
            [self showFinishLoadingStateWithType:TAPCreateGroupLoadingTypeRemoveMember];
        } failure:^(NSError *error) {
            [self removeLoadingView];
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Remove Member" title:NSLocalizedString(@"Failed", @"") detailInformation:error.domain leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
    }
    else if ([popupIdentifier isEqualToString:@"Remove Members"]) {
        [self.createGroupView showLoadingView:YES];
        [self.createGroupView setAsLoadingState:YES withType:TAPCreateGroupLoadingTypeRemoveMember];
        [TAPDataManager callAPIRemoveRoomParticipantsWithRoomID:self.room.roomID userIDArray:[self.selectedIndexDictionary allKeys] success:^(TAPRoomModel *room) {
            _room = room;
            [self showCustomEditButton];
            _isEditMode = NO;
            [self.createGroupView.contactsTableView reloadData];
            [self.createGroupView showAddMembersButton];
            [self.selectedIndexDictionary removeAllObjects];
            [self.selectedUserModelArray removeAllObjects];
            [self loadContactsFromRoomModel];
            [self showFinishLoadingStateWithType:TAPCreateGroupLoadingTypeRemoveMember];
        } failure:^(NSError *error) {
            [self removeLoadingView];
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Remove Members" title:NSLocalizedString(@"Failed", @"") detailInformation:error.domain leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
    }
}

#pragma mark - Custom Method
- (void)validateselectedUserModelArray {
    TAPCoreConfigsModel *coreConfigs = [TAPDataManager getCoreConfigs];
    NSInteger maxGroupMember = [coreConfigs.groupMaxParticipants integerValue] - 1; // -1 for admin that created the group
    if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault || self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault) {
            if ([self.selectedUserModelArray count] > 0) {
                [self.createGroupView showSelectedContacts:YES];
                self.createGroupView.selectedContactsTitleLabel.text = [NSString stringWithFormat:@"GROUP MEMBERS (%ld/%ld)", [self.selectedUserModelArray count] + 1, maxGroupMember + 1];
                
                [self.createGroupView.selectedContactsCollectionView reloadData];
            }
            else {
                [self.createGroupView showSelectedContacts:NO];
                self.createGroupView.selectedContactsTitleLabel.text = [NSString stringWithFormat:@"GROUP MEMBERS (1/%ld)", maxGroupMember + 1];
            }
        }
        else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
            if ([self.selectedUserModelArray count] > 0) {
                [self.createGroupView showSelectedContacts:YES];
                self.createGroupView.selectedContactsTitleLabel.text = [NSString stringWithFormat:@"GROUP MEMBERS (%ld/%ld)", [self.selectedUserModelArray count] + [self.room.participants count], maxGroupMember + 1];
                
                [self.createGroupView.selectedContactsCollectionView reloadData];
            }
            else {
                [self.createGroupView showSelectedContacts:NO];
                self.createGroupView.selectedContactsTitleLabel.text = [NSString stringWithFormat:@"GROUP MEMBERS (0/%ld)", maxGroupMember - [self.room.participants count] + 1];
            }
        }
        
        NSMutableDictionary *selectedContactsTitleAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat selectedContactsTitleLetterSpacing = 1.5f;
        [selectedContactsTitleAttributesDictionary setObject:@(selectedContactsTitleLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *selectedContactsTitleAttributedString = [[NSMutableAttributedString alloc] initWithString:self.createGroupView.selectedContactsTitleLabel.text];
        [selectedContactsTitleAttributedString addAttributes:selectedContactsTitleAttributesDictionary
                                                       range:NSMakeRange(0, [self.createGroupView.selectedContactsTitleLabel.text length])];
        self.createGroupView.selectedContactsTitleLabel.attributedText = selectedContactsTitleAttributedString;
    }
    else {
        //Member List
    }
   
}

- (void)continueButtonDidTapped {
    if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeDefault) {
        //Continue
        TAPCreateGroupSubjectViewController *createGroupSubjectViewController = [[TAPCreateGroupSubjectViewController alloc] init];
        createGroupSubjectViewController.roomListViewController = self.roomListViewController;
        
        NSMutableArray *contactArray = [NSMutableArray array];
        [contactArray addObject:[TAPDataManager getActiveUser]];
        [contactArray addObjectsFromArray:self.selectedUserModelArray];
        
        createGroupSubjectViewController.selectedContactArray = contactArray;
        [self.navigationController pushViewController:createGroupSubjectViewController animated:YES];
    }
    else if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
        //Add Members
        [self.createGroupView.continueButtonView setAsLoading:YES animated:NO];
        self.createGroupView.searchBarView.userInteractionEnabled = NO;
        self.createGroupView.contactsTableView.userInteractionEnabled = NO;
        self.createGroupView.searchResultTableView.userInteractionEnabled = NO;
        NSArray *userIDArray = [self.selectedIndexDictionary allKeys];
        [TAPDataManager callAPIAddRoomParticipantsWithRoomID:self.room.roomID userIDArray:userIDArray success:^(TAPRoomModel *room) {
            _room = room;
            [self.selectedIndexDictionary removeAllObjects];
            [self.selectedUserModelArray removeAllObjects];
            if ([self.delegate respondsToSelector:@selector(createGroupViewControllerUpdatedRoom:)]) {
                [self.delegate createGroupViewControllerUpdatedRoom:room];
            }
            [self.createGroupView.continueButtonView setAsLoading:NO animated:NO];
            self.createGroupView.searchBarView.userInteractionEnabled = YES;
            self.createGroupView.contactsTableView.userInteractionEnabled = YES;
            self.createGroupView.searchResultTableView.userInteractionEnabled = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSError *error) {
            [self.createGroupView.continueButtonView setAsLoading:NO animated:NO];
            [self.createGroupView.continueButtonView setAsLoading:NO animated:NO];
            self.createGroupView.searchBarView.userInteractionEnabled = YES;
            self.createGroupView.contactsTableView.userInteractionEnabled = YES;
            self.createGroupView.searchResultTableView.userInteractionEnabled = YES;
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Add Members" title:NSLocalizedString(@"Failed", @"") detailInformation:error.domain leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
    }
}

- (void)loadContactListFromDatabase {
    
    [TAPDataManager getDatabaseAllContactSortBy:@"fullname" success:^(NSArray *resultArray) {
        _contactListArray = [NSMutableArray array];
        _indexSectionDictionary = [NSMutableDictionary dictionary];
        _contactListDictionary = [NSMutableDictionary dictionary];
        
        self.contactListArray = resultArray;
        
        if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeAddMember) {
            //filter added user in group
            NSMutableArray *filteredArray = [NSMutableArray array];
            for (TAPUserModel *user in resultArray) {
                if ([self.roomParticipantsDictionary objectForKey:user.userID] == nil) {
                    [filteredArray addObject:user];
                }
            }
            self.contactListArray = filteredArray;
        }
        
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
        
        [self.createGroupView.contactsTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)loadContactsFromRoomModel {
    _contactListArray = [NSMutableArray array];
    _indexSectionDictionary = [NSMutableDictionary dictionary];
    _contactListDictionary = [NSMutableDictionary dictionary];
    self.contactListArray = self.room.participants;
    [self.createGroupView.contactsTableView reloadData];
    
    TAPCoreConfigsModel *coreConfigs = [TAPDataManager getCoreConfigs];
    NSInteger maxGroupMember = [coreConfigs.groupMaxParticipants integerValue] - 1; // -1 for admin that created the group
    
    if ([self.room.admins containsObject:[TAPDataManager getActiveUser].userID]) {
        [self showCustomEditButton];
        if ([self.room.participants count] >= maxGroupMember + 1) {
            [self.createGroupView showBottomActionButtonView:NO];
        }
        else {
            [self.createGroupView showBottomActionButtonView:YES];
        }
    }
    else {
        [self.createGroupView showBottomActionButtonView:NO];
    }
    
    if ([self.room.participants count] == 1) {
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (void)setTapCreateGroupViewControllerType:(TAPCreateGroupViewControllerType)tapCreateGroupViewControllerType {
    _tapCreateGroupViewControllerType = tapCreateGroupViewControllerType;
}

- (void)addMembersButtonDidTapped {
    if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
        //Add Members
        TAPCreateGroupViewController *createGroupViewController = [[TAPCreateGroupViewController alloc] init]; //createGroupViewController
        createGroupViewController.tapCreateGroupViewControllerType = TAPCreateGroupViewControllerTypeAddMember;
        createGroupViewController.room = self.room;
        createGroupViewController.delegate = self;
        UINavigationController *createGroupNavigationController = [[UINavigationController alloc] initWithRootViewController:createGroupViewController];
        [self presentViewController:createGroupNavigationController animated:YES completion:nil];
    }
}

- (void)removeMembersButtonDidTapped {
    if (self.tapCreateGroupViewControllerType == TAPCreateGroupViewControllerTypeMemberList) {
        //call api remove member
        
        if ([self.selectedIndexDictionary count] == 0) {
            return;
        }
        
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Remove Members" title:NSLocalizedString(@"Remove Members", @"") detailInformation:NSLocalizedString(@"Are you sure you want to remove selected members?", @"") leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"OK"];
    }
}

- (void)promoteAdminButtonDidTapped {
    NSArray *indexArray = [self.selectedIndexDictionary allKeys];
    TAPUserModel *user = [self.selectedIndexDictionary objectForKey:[indexArray firstObject]];
    [self.createGroupView showLoadingView:YES];
    [self.createGroupView setAsLoadingState:YES withType:TAPCreateGroupLoadingTypeAppointAdmin];
    [TAPDataManager callAPIPromoteRoomAdminsWithRoomID:self.room.roomID userIDArray:@[user.userID] success:^(TAPRoomModel *room) {
        _room = room;
        _isEditMode = NO;
        [self.selectedIndexDictionary removeAllObjects];
        [self.selectedUserModelArray removeAllObjects];
        [self loadContactsFromRoomModel];
        [self showFinishLoadingStateWithType:TAPCreateGroupLoadingTypeAppointAdmin];
        [self.createGroupView showBottomActionButtonViewExtension:NO withActiveButton:0];
    } failure:^(NSError *error) {
        [self removeLoadingView];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Promote Admin" title:NSLocalizedString(@"Failed", @"") detailInformation:error.domain leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

- (void)demoteAdminButtonDidTapped {
    NSArray *indexArray = [self.selectedIndexDictionary allKeys];
    TAPUserModel *user = [self.selectedIndexDictionary objectForKey:[indexArray firstObject]];
    self.currentSelectedUser = user;
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Demote Admin" title:NSLocalizedString(@"Demote from Admin", @"") detailInformation:NSLocalizedString(@"Are you sure you want to demote this admin?", @"") leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"OK"];
}

- (void)editButtonDidTapped {
    [self showCustomCancelButtonRight];
    _isEditMode = YES;
    [self.createGroupView.contactsTableView reloadData];
    
    [self.createGroupView showRemoveMembersButton];
}

- (void)cancelButtonDidTapped {
    TAPCoreConfigsModel *coreConfigs = [TAPDataManager getCoreConfigs];
    NSInteger maxGroupMember = [coreConfigs.groupMaxParticipants integerValue] - 1; // -1 for admin that created the group
    
    if ([self.room.admins containsObject:[TAPDataManager getActiveUser].userID]) {
        [self showCustomEditButton];
        if ([self.room.participants count] >= maxGroupMember + 1) {
            [self.createGroupView showBottomActionButtonView:NO];
        }
        else {
            [self.createGroupView showBottomActionButtonView:YES];
        }
    }
    [self showCustomEditButton];
    _isEditMode = NO;
    [self.createGroupView showBottomActionButtonViewExtension:NO withActiveButton:0];
    [self.createGroupView.contactsTableView reloadData];
    [self.createGroupView showAddMembersButton];
    [self.selectedIndexDictionary removeAllObjects];
}

- (void)showFinishLoadingStateWithType:(TAPCreateGroupLoadingType)type {
    [self.createGroupView setAsLoadingState:NO withType:type];
    [self performSelector:@selector(removeLoadingView) withObject:nil afterDelay:1.0f];
}

- (void)removeLoadingView {
    [self.createGroupView showLoadingView:NO];
}

@end
