//
//  TAPNewGroupViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 17/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPNewGroupViewController.h"
#import "TAPCreateGroupView.h"
#import "TAPCreateGroupSubjectViewController.h"

#import "TAPContactTableViewCell.h"

#import "TAPContactCollectionViewCell.h"

#import "TAPGroupModel.h"

#define kMaxGroupMember 50 - 1 //1 is group admin.

@interface TAPNewGroupViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) TAPCreateGroupView *createGroupView;

@property (strong, nonatomic) NSArray *alphabetSectionTitles;
@property (strong, nonatomic) NSArray *contactListArray;
@property (strong, nonatomic) NSMutableDictionary *indexSectionDictionary;

@property (strong, nonatomic) NSDictionary *contactListDictionary; //DV Temp
@property (strong, nonatomic) NSMutableArray *selectedIndexArray;
@property (strong, nonatomic) TAPGroupModel *groupModel;
@end

@implementation TAPNewGroupViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _createGroupView = [[TAPCreateGroupView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.createGroupView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.createGroupView.searchBarView.searchTextField.delegate = self;
    
    self.createGroupView.contactsTableView.delegate = self;
    self.createGroupView.contactsTableView.dataSource = self;
    self.createGroupView.searchResultTableView.delegate = self;
    self.createGroupView.searchResultTableView.dataSource = self;
    
    self.createGroupView.selectedContactsCollectionView.delegate = self;
    self.createGroupView.selectedContactsCollectionView.dataSource = self;
    
    [self.createGroupView.continueButton addTarget:self action:@selector(continueButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.title = NSLocalizedString(@"New Group", @"");
    [self showCustomBackButton];
    
    //DV Temp
    TAPUserModel *firstUser = [TAPUserModel new];
    firstUser.userID = @"1";
    firstUser.xcUserID = @"1";
    firstUser.fullname = @"ritchie";
    firstUser.email = @"ritchie@moselo.com";
    firstUser.phone = @"08979809026";
    firstUser.username = @"ritchie";
    
    TAPUserModel *secondUser = [TAPUserModel new];
    secondUser.userID = @"2";
    secondUser.xcUserID = @"2";
    secondUser.fullname = @"dominic";
    secondUser.email = @"dominic@moselo.com";
    secondUser.phone = @"08979809026";
    secondUser.username = @"dominic";
    
    TAPUserModel *thirdUser = [TAPUserModel new];
    thirdUser.userID = @"3";
    thirdUser.xcUserID = @"3";
    thirdUser.fullname = @"rionaldo";
    thirdUser.email = @"rionaldo@moselo.com";
    thirdUser.phone = @"08979809026";
    thirdUser.username = @"rionaldo";
    
    TAPUserModel *fourthUser = [TAPUserModel new];
    fourthUser.userID = @"4";
    fourthUser.xcUserID = @"4";
    fourthUser.fullname = @"kevin";
    fourthUser.email = @"kevin@moselo.com";
    fourthUser.phone = @"08979809026";
    fourthUser.username = @"kevin";
    
    TAPUserModel *fifthUser = [TAPUserModel new];
    fifthUser.userID = @"5";
    fifthUser.xcUserID = @"5";
    fifthUser.fullname = @"welly";
    fifthUser.email = @"welly@moselo.com";
    fifthUser.phone = @"08979809026";
    fifthUser.username = @"welly";
    
    TAPUserModel *sixthUser = [TAPUserModel new];
    sixthUser.userID = @"6";
    sixthUser.xcUserID = @"6";
    sixthUser.fullname = @"jony";
    sixthUser.email = @"jony@moselo.com";
    sixthUser.phone = @"08979809026";
    sixthUser.username = @"jony";
    
    TAPUserModel *seventhUser = [TAPUserModel new];
    seventhUser.userID = @"7";
    seventhUser.xcUserID = @"7";
    seventhUser.fullname = @"michael";
    seventhUser.email = @"michael@moselo.com";
    seventhUser.phone = @"08979809026";
    seventhUser.username = @"michael";
    
    TAPUserModel *eighthUser = [TAPUserModel new];
    eighthUser.userID = @"8";
    eighthUser.xcUserID = @"8";
    eighthUser.fullname = @"richard";
    eighthUser.email = @"richard@moselo.com";
    eighthUser.phone = @"08979809026";
    eighthUser.username = @"richard";
    
    TAPUserModel *ninthUser = [TAPUserModel new];
    ninthUser.userID = @"9";
    ninthUser.xcUserID = @"9";
    ninthUser.fullname = @"erwin";
    ninthUser.email = @"erwin@moselo.com";
    ninthUser.phone = @"08979809026";
    ninthUser.username = @"erwin";
    
    TAPUserModel *tenthUser = [TAPUserModel new];
    tenthUser.userID = @"10";
    tenthUser.xcUserID = @"10";
    tenthUser.fullname = @"jefry";
    tenthUser.email = @"jefry@moselo.com";
    tenthUser.phone = @"08979809026";
    tenthUser.username = @"jefry";
    
    TAPUserModel *eleventhUser = [TAPUserModel new];
    eleventhUser.userID = @"11";
    eleventhUser.xcUserID = @"11";
    eleventhUser.fullname = @"cundy";
    eleventhUser.email = @"cundy@moselo.com";
    eleventhUser.phone = @"08979809026";
    eleventhUser.username = @"cundy";
    
    TAPUserModel *twelfthUser = [TAPUserModel new];
    twelfthUser.userID = @"12";
    twelfthUser.xcUserID = @"12";
    twelfthUser.fullname = @"rizka";
    twelfthUser.email = @"rizka@moselo.com";
    twelfthUser.phone = @"08979809026";
    twelfthUser.username = @"rizka";
    
    TAPUserModel *thirteenthUser = [TAPUserModel new];
    thirteenthUser.userID = @"13";
    thirteenthUser.xcUserID = @"13";
    thirteenthUser.fullname = @"test1";
    thirteenthUser.email = @"test1@moselo.com";
    thirteenthUser.phone = @"08979809026";
    thirteenthUser.username = @"test1";
    
    TAPUserModel *fourteenthUser = [TAPUserModel new];
    fourteenthUser.userID = @"14";
    fourteenthUser.xcUserID = @"14";
    fourteenthUser.fullname = @"test2";
    fourteenthUser.email = @"test2@moselo.com";
    fourteenthUser.phone = @"08979809026";
    fourteenthUser.username = @"test2";
    
    TAPUserModel *fifteenthUser = [TAPUserModel new];
    fifteenthUser.userID = @"15";
    fifteenthUser.xcUserID = @"15";
    fifteenthUser.fullname = @"test3";
    fifteenthUser.email = @"test3@moselo.com";
    fifteenthUser.phone = @"08979809026";
    fifteenthUser.username = @"test3";
    
    TAPUserModel *sixteenthUser = [TAPUserModel new];
    sixteenthUser.userID = @"17";
    sixteenthUser.xcUserID = @"16";
    sixteenthUser.fullname = @"Santo";
    sixteenthUser.email = @"santo@moselo.com";
    sixteenthUser.phone = @"08979809026";
    sixteenthUser.username = @"santo";
    
    _contactListDictionary = @{@"ritchie" : firstUser, @"dominic" : secondUser, @"rionaldo" : thirdUser, @"kevin" : fourthUser, @"welly" : fifthUser, @"jony" : sixthUser, @"michael" : seventhUser, @"richard" : eighthUser, @"erwin" : ninthUser, @"jefry" : tenthUser, @"cundy" : eleventhUser, @"rizka" : twelfthUser, @"test1" : thirteenthUser, @"test2" : fourteenthUser, @"test3" : fifteenthUser, @"santo" : sixteenthUser};
    //END DV Temp
    
    _alphabetSectionTitles = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil];
    
    _contactListArray = [NSMutableArray array];
    _indexSectionDictionary = [NSMutableDictionary dictionary];
    
    NSArray *unsortedContactListArray = @[firstUser, secondUser, thirdUser, fourthUser, fifthUser, sixthUser, seventhUser, eighthUser, ninthUser, tenthUser, eleventhUser, twelfthUser, thirteenthUser, fourteenthUser, fifteenthUser, sixteenthUser];
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"fullname"
                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSArray *sortedArray = [unsortedContactListArray sortedArrayUsingDescriptors:sortDescriptors];
    
    self.contactListArray = sortedArray;
    
    for (TAPUserModel *user in self.contactListArray) {
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
    
    _groupModel = [TAPGroupModel new]; //WK Temp
    
    _selectedIndexArray = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.createGroupView.contactsTableView) {
        return [self.indexSectionDictionary count];
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        return 1;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.createGroupView.contactsTableView) {
        if (section <= [self.indexSectionDictionary count] - 1) {
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
            return 5; //WK Temp
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.createGroupView.contactsTableView) {
        if (indexPath.section <= [self.alphabetSectionTitles count] - 1) {
            return 64.0f;
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
            
            NSString *objectString = [NSString stringWithFormat:@"%ld - %ld", indexPath.section, indexPath.row];
            if ([self.selectedIndexArray containsObject:objectString]) {
                [cell isCellSelected:YES];
            }
            else {
                [cell isCellSelected:NO];
            }
            
            if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
                [cell showSeparatorLine:NO];
            }
            else {
                [cell showSeparatorLine:YES];
            }
            
            return cell;
        }
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        if (indexPath.section <= [self.alphabetSectionTitles count] - 1) {
            static NSString *cellID = @"TAPContactTableViewCell";
            TAPContactTableViewCell *cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            
            [cell setContactTableViewCellWithUser:[TAPUserModel new]]; //WK Temp
//            [cell setContactTableViewCellWithUser:currentUser];

            [cell isRequireSelection:YES];
            
            [cell isCellSelected:YES];
            
            if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
                [cell showSeparatorLine:NO];
            }
            else {
                [cell showSeparatorLine:YES];
            }
            
            return cell;
        }
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.createGroupView.contactsTableView) {
        if (section <= [self.alphabetSectionTitles count] - 1) {
            return 34.0f;
        }
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.createGroupView.contactsTableView) {
        if (section <= [[self.indexSectionDictionary allKeys] count]) {
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 34.0f)];
            header.backgroundColor = [TAPUtil getColor:@"F8F8F8"];
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(header.frame) - 16.0f - 16.0f, 34.0f)];
            titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE];
            titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
            [header addSubview:titleLabel];
            
            if([keysArray count] != 0) {
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
    if (tableView == self.createGroupView.contactsTableView) {
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
    return [self.selectedIndexArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPContactCollectionViewCell";
        
        [collectionView registerClass:[TAPContactCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPContactCollectionViewCell *cell = (TAPContactCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            //Group Admin
            [cell setContactCollectionViewCellWithModel:@"You"];
            [cell showRemoveIcon:NO];
            
            return cell;
        }
        else {
            NSString *objectString = [self.selectedIndexArray objectAtIndex:indexPath.row - 1];
            NSArray *objectStringSplitArray = [objectString componentsSeparatedByString:@" - "];
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:[[objectStringSplitArray objectAtIndex:1] integerValue] inSection:[[objectStringSplitArray objectAtIndex:0] integerValue]];
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSString *key = [keysArray objectAtIndex:selectedIndexPath.section];
            NSArray *contactArray = [self.indexSectionDictionary objectForKey:key];
            TAPUserModel *currentUser = [contactArray objectAtIndex:selectedIndexPath.row];
//            [cell setContactTableViewCellWithUser:currentUser];
            
//            NSArray *keysArray = [self.indexSectionDictionary allKeys];
//            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
//            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
//
//            NSString *key = [keysArray objectAtIndex:selectedIndexPath.section];
//            NSArray *userArray = [self.contactListDictionary valueForKey:key];
            
//            [cell setContactCollectionViewCellWithModel:[self.alphabetSectionTitles objectAtIndex:selectedIndexPath.section]];
//            TAPUserModel *user = [userArray objectAtIndex:selectedIndexPath.row];
            [cell setContactCollectionViewCellWithModel:currentUser.username];
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
        //Contacts
//        if ([self.selectedIndexArray count] == kMaxGroupMember) {
//            //WK Temp
//            [self isShowTwoOptionButton:NO];
//            [self showPopupView:YES];
//        }
//        else {
            NSString *objectString = [NSString stringWithFormat:@"%ld - %ld", indexPath.section, indexPath.row];
            NSArray *objectStringSplitArray = [objectString componentsSeparatedByString:@" - "];
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:[[objectStringSplitArray objectAtIndex:1] integerValue] inSection:[[objectStringSplitArray objectAtIndex:0] integerValue]];
            TAPContactTableViewCell *contactTableViewCell = [self.createGroupView.contactsTableView cellForRowAtIndexPath:selectedIndexPath];
            if ([self.selectedIndexArray containsObject:objectString]) {
                [self.selectedIndexArray removeObject:objectString];
                [contactTableViewCell isCellSelected:NO];
            }
            else {
                if ([self.selectedIndexArray count] == kMaxGroupMember) {
                    //WK Temp
                    [self showPopupView:YES withPopupType:TAPPopUpInfoViewControllerTypeErrorMessage title:NSLocalizedString(@"Failed", @"") detailInformation:NSLocalizedString(@"Exceeded number of maximum group members",@"")];
                    //END WK Temp
                }
                else {
                    [self.selectedIndexArray addObject:objectString];
                    [contactTableViewCell isCellSelected:YES];
                }
            }
            
            //check array count
            [self validateSelectedIndexArray];
        
//        [self.createGroupView.contactsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        }
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        //Contacts
    }
}

#pragma mark UICollectionView
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0) { //WK Note : indexPath.row 0 is group admin
        NSString *objectString = [self.selectedIndexArray objectAtIndex:indexPath.row - 1];
        NSArray *objectStringSplitArray = [objectString componentsSeparatedByString:@" - "];
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:[[objectStringSplitArray objectAtIndex:1] integerValue] inSection:[[objectStringSplitArray objectAtIndex:0] integerValue]];
        [self.selectedIndexArray removeObjectAtIndex:indexPath.row - 1];
        
        TAPContactTableViewCell *contactTableViewCell = [self.createGroupView.contactsTableView cellForRowAtIndexPath:selectedIndexPath];
        [contactTableViewCell isCellSelected:NO];
        
        [self validateSelectedIndexArray];
    }
    
//    [self.createGroupView.contactsTableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark TextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
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
        }];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.createGroupView showOverlayView:YES];
    [UIView animateWithDuration:0.2f animations:^{
        self.createGroupView.searchResultTableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        //completion
    }];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([newString length] <= 0) {
        [self.createGroupView showOverlayView:YES];
        [UIView animateWithDuration:0.2f animations:^{
            self.createGroupView.searchResultTableView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            //completion
        }];
    }
    else {
        [self.createGroupView showOverlayView:NO];
        [UIView animateWithDuration:0.2f animations:^{
            self.createGroupView.searchResultTableView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            //completion
        }];
    }
    
    return YES;
}

#pragma mark - Custom Method
- (void)validateSelectedIndexArray {
    if ([self.selectedIndexArray count] > 0) {
        [self.createGroupView showSelectedContacts:YES];
        self.createGroupView.selectedContactsTitleLabel.text = [NSString stringWithFormat:@"Group Members (%ld/%ld)", [self.selectedIndexArray count] + 1, kMaxGroupMember + 1];
        
        [self.createGroupView.selectedContactsCollectionView reloadData];
    }
    else {
        [self.createGroupView showSelectedContacts:NO];
        self.createGroupView.selectedContactsTitleLabel.text = [NSString stringWithFormat:@"Group Members (1/%ld)", kMaxGroupMember + 1];
    }
}

- (void)continueButtonDidTapped {
    TAPCreateGroupSubjectViewController *createGroupSubjectViewController = [[TAPCreateGroupSubjectViewController alloc] init];
    createGroupSubjectViewController.groupModel = self.groupModel;
    [self.navigationController pushViewController:createGroupSubjectViewController animated:YES];
}

- (void)popUpInfoTappedSingleButtonOrRightButton {
    [self showPopupView:NO withPopupType:TAPPopUpInfoViewControllerTypeErrorMessage title:@"" detailInformation:@""];
}

@end
