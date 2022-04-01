//
//  TAPProfileViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPProfileViewController.h"
#import "TAPProfileView.h"

#import "TAPProfileCollectionViewCell.h"
#import "TAPImageCollectionViewCell.h"

#import "TAPMediaDetailViewController.h"
#import "TAPCreateGroupSubjectViewController.h"
#import "TAPCreateGroupViewController.h"
#import "TAPImagePreviewCollectionViewCell.h"
#import "TAPStarredMessageViewController.h"

@interface TAPProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, TAPImageCollectionViewCellDelegate, TAPMediaDetailViewControllerDelegate, TAPCreateGroupSubjectViewControllerDelegate, TAPImagePreviewCollectionViewCellDelegate, TAPStarredMessageViewControllerDelegate>

@property (strong, nonatomic) TAPProfileView *profileView;
@property (strong, nonatomic) TAPUserModel *updatedUser;
@property (strong, nonatomic) NSMutableArray *mediaMessageDataArray;
@property (strong, nonatomic) NSMutableDictionary *mediaMessageDataDictionary;
@property (nonatomic) BOOL isFullNameChanged;
@property (nonatomic) BOOL isUserProfileURLChanged;
@property (nonatomic) BOOL isMediaLastPage;
@property (nonatomic) BOOL isCurrentActiveUserIsAdmin;
@property (nonatomic) BOOL isLeaveFromGroupProfilePage;

//NAVIGATION BAR
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIView *userDescriptionView;
@property (strong, nonatomic) UIView *userStatusView;
@property (strong, nonatomic) UILabel *userStatusLabel;

@property (weak, nonatomic) id openedBubbleCell;

@property (nonatomic) NSInteger lastPageIndicatorIndex;
@property (strong, nonatomic) NSMutableArray<TAPPhotoListModel *> *photoListArray;

- (void)getUserProfileDataWithUserID:(NSString *)userID;
- (void)getRoomDataWithRoomID:(NSString *)roomID;
- (void)fetchImageDataWithMessage:(TAPMessageModel *)message;
- (void)fetchVideoDataWithMessage:(TAPMessageModel *)message;

- (void)fileDownloadManagerProgressNotification:(NSNotification *)notification;
- (void)fileDownloadManagerStartNotification:(NSNotification *)notification;
- (void)fileDownloadManagerFinishNotification:(NSNotification *)notification;
- (void)fileDownloadManagerFailureNotification:(NSNotification *)notification;

- (void)editButtonDidTapped;
- (void)showFinishLoadingStateWithType:(TAPProfileLoadingType)type;
- (void)removeLoadingView;

- (void)refreshProfileRoomViewData;

@end

@implementation TAPProfileViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    _profileView = [[TAPProfileView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.profileView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    for (NSString *adminUserID in self.room.admins) {
        if ([adminUserID isEqualToString:[TAPDataManager getActiveUser].userID]) {
            self.isCurrentActiveUserIsAdmin = YES;
        }
    }

    if (self.isLeaveFromGroupProfilePage && self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault) {
        [self getRoomDataWithRoomID:self.room.roomID];
        NSRange range = NSMakeRange(0, 1);
        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.profileView.collectionView reloadSections:section];
    }
    
    NSString *profileImageURL = @"";
    NSString *roomName = @"";
    NSString *userID = @"";
    
    if (self.room.type == RoomTypeGroup) {
        TAPRoomModel *obtainedRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:self.room.roomID];
        NSString *groupProfileImageURL = obtainedRoom.imageURL.fullsize;
        groupProfileImageURL = [TAPUtil nullToEmptyString:groupProfileImageURL];
        
        NSString *groupRoomName = obtainedRoom.name;
        groupRoomName = [TAPUtil nullToEmptyString:groupRoomName];
        
        if ([groupProfileImageURL isEqualToString:@""]) {
            profileImageURL = self.room.imageURL.fullsize;
            profileImageURL = [TAPUtil nullToEmptyString:profileImageURL];
        }
        else {
            profileImageURL = groupProfileImageURL;
            profileImageURL = [TAPUtil nullToEmptyString:profileImageURL];
        }
        
        if ([groupRoomName isEqualToString:@""]) {
            roomName = self.room.name;
            roomName = [TAPUtil nullToEmptyString:roomName];
        }
        else {
            roomName = groupRoomName;
            roomName = [TAPUtil nullToEmptyString:roomName];
        }
        
        if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        
            TAPRoomModel *obtainedRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:self.room.roomID];
            NSString *groupProfileImageURL = obtainedRoom.imageURL.fullsize;
            groupProfileImageURL = [TAPUtil nullToEmptyString:groupProfileImageURL];
                
            NSString *groupRoomName = obtainedRoom.name;
            groupRoomName = [TAPUtil nullToEmptyString:groupRoomName];
            [self.profileView setProfilePictureWithImageURL:profileImageURL userFullName:groupRoomName];
        }
        else {
            [self.profileView.profileImageView setImageWithURLString:profileImageURL];
            
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photoListArray = [NSMutableArray array];
    
    self.profileView.profilImageCollectionView.dataSource = self;
    self.profileView.profilImageCollectionView.delegate = self;
    self.profileView.pageIndicatorCollectionView.dataSource = self;
    self.profileView.pageIndicatorCollectionView.delegate = self;
    
    [self.profileView.navigationBackButton addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.profileView.backButton addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.profileView.navigationEditButton addTarget:self action:@selector(editButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.profileView.editButton addTarget:self action:@selector(editButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pictureLongPressClicked)];
    [self.profileView.saveProfileImageButton addGestureRecognizer:longPress];
    
    NSString *profileImageURL = @"";
    NSString *roomName = @"";
    NSString *userID = @"";
    if (self.room.type == RoomTypePersonal) {
        NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
        TAPUserModel *obtainedUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
        if([self.room.deleted longValue] != 0) {
            profileImageURL = @"";
        }
        userID = obtainedUser.userID;
        if (obtainedUser != nil && ![obtainedUser.imageURL.thumbnail isEqualToString:@""]) {
            profileImageURL = obtainedUser.imageURL.fullsize;
            profileImageURL = [TAPUtil nullToEmptyString:profileImageURL];
        }
        else {
            profileImageURL = self.room.imageURL.fullsize;
            profileImageURL = [TAPUtil nullToEmptyString:profileImageURL];
        }
        
        if (obtainedUser != nil && obtainedUser.fullname != nil && [self.room.deleted longValue] == 0) {
            roomName = obtainedUser.fullname;
            roomName = [TAPUtil nullToEmptyString:roomName];
        }
        else {
            roomName = self.room.name;
            roomName = [TAPUtil nullToEmptyString:roomName];
        }
    }
    else if (self.room.type == RoomTypeGroup) {
        TAPRoomModel *obtainedRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:self.room.roomID];
        NSString *groupProfileImageURL = obtainedRoom.imageURL.fullsize;
        groupProfileImageURL = [TAPUtil nullToEmptyString:groupProfileImageURL];
        
        NSString *groupRoomName = obtainedRoom.name;
        groupRoomName = [TAPUtil nullToEmptyString:groupRoomName];
        
        if ([groupProfileImageURL isEqualToString:@""]) {
            profileImageURL = self.room.imageURL.fullsize;
            profileImageURL = [TAPUtil nullToEmptyString:profileImageURL];
        }
        else {
            profileImageURL = groupProfileImageURL;
            profileImageURL = [TAPUtil nullToEmptyString:profileImageURL];
        }
        
        if ([groupRoomName isEqualToString:@""]) {
            roomName = self.room.name;
            roomName = [TAPUtil nullToEmptyString:roomName];
        }
        else {
            roomName = groupRoomName;
            roomName = [TAPUtil nullToEmptyString:roomName];
        }
    }
    
    if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        
        if (self.room.type == RoomTypePersonal) {
            //Personal
            NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
            TAPUserModel *obtainedUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
            NSString *fullname = obtainedUser.fullname;
            [self.profileView setProfilePictureWithImageURL:profileImageURL userFullName:fullname];
            
        }
        else {
            TAPRoomModel *obtainedRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:self.room.roomID];
            NSString *groupProfileImageURL = obtainedRoom.imageURL.fullsize;
            groupProfileImageURL = [TAPUtil nullToEmptyString:groupProfileImageURL];
            
            NSString *groupRoomName = obtainedRoom.name;
            groupRoomName = [TAPUtil nullToEmptyString:groupRoomName];
            [self.profileView setProfilePictureWithImageURL:profileImageURL userFullName:groupRoomName];
        }
    }
    else {
        if(self.room.type == RoomTypePersonal){
            if(userID != nil){
                [self.profileView.profileImageView setImageWithURLString:profileImageURL];
                NSLog(@"===== userID: %@", userID);
                [self getPhotoListApi:userID];
            }
        }
        else{
            [self.profileView.profileImageView setImageWithURLString:profileImageURL];
        }
        
    }
    
    self.profileView.nameLabel.text = roomName;
    self.profileView.navigationNameLabel.text = roomName;
    
    if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault || self.tapProfileViewControllerType == TAPProfileViewControllerTypePersonalFromClickedMention) {
        if (self.room.type == RoomTypePersonal) {
            //type personal
            self.profileView.editButton.alpha = 0.0f;
            [self getUserProfileDataWithUserID:self.otherUserID];
            
            
        }
        else {
            //type group or channel
            if ([self.room.admins containsObject:[TAPDataManager getActiveUser].userID]) {
                self.profileView.editButton.alpha = 1.0f;
            }
            else {
                self.profileView.editButton.alpha = 0.0f;
            }
            
            [self getRoomDataWithRoomID:self.room.roomID];
            
            
        }
        
        _mediaMessageDataArray = [[NSMutableArray alloc] init];
        _mediaMessageDataDictionary = [[NSMutableDictionary alloc] init];
        
        [TAPDataManager getDatabaseMediaMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:@"" numberOfItem:50 success:^(NSArray *mediaMessages) {
            _mediaMessageDataArray = [mediaMessages mutableCopy];
            for (TAPMessageModel *message in self.mediaMessageDataArray) {
                [self.mediaMessageDataDictionary setObject:message forKey:message.localID];
            }
            [self.profileView.collectionView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }
    else if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile) {
         self.profileView.editButton.alpha = 0.0f;
        
        NSString *profileImageURL = self.user.imageURL.fullsize;
        if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
            if (self.room.type == RoomTypePersonal) {
                //Personal
                self.profileView.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            }
            else {
                //Group or Channel
                self.profileView.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultGroupAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            }
            [self.profileView setProfilePictureWithImageURL:profileImageURL userFullName:self.user.fullname];
        }
        else {
            if(self.user.userID != nil){
                [self.profileView.profileImageView setImageWithURLString:profileImageURL];
                [self.profileView setProfilePictureWithImageURL:profileImageURL userFullName:self.user.fullname];
                NSLog(@"===== userID: %@", self.user.userID);
                [self getPhotoListApi:self.user.userID];
                
            }
        }
        
        self.profileView.nameLabel.text = self.user.fullname;
        self.profileView.navigationNameLabel.text = self.user.fullname;
    }
    
    self.profileView.collectionView.delegate = self;
    self.profileView.collectionView.dataSource = self;
   [self setupNavigationViewData];
    
    if (![[TapUI sharedInstance] getEditBioTextFieldVisible] || self.user.bio == nil && ![[TapUI sharedInstance] getUsernameInChatProfileVisible] || self.user.username == nil && ![[TapUI sharedInstance] getMobileNumberInChatProfileVisible] || self.user.phone == nil && ![[TapUI sharedInstance] getEmailAddressInChatProfileVisible] || self.user.email == nil) {
        if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault && self.room.type == RoomTypeGroup){
            
        }
        else{
            //[self.profileView hideHeaderSeperatorView];
        }
       
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerProgressNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerStartNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFinishNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFailureNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:nil];
}

#pragma mark - Data Source
#pragma mark CollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //profil picture collection view
        if(collectionView == self.profileView.pageIndicatorCollectionView){
            CGSize cellSize = CGSizeMake((CGRectGetWidth([UIScreen mainScreen].bounds) / self.photoListArray.count) - 1, 3.0f);
            return cellSize;
        }
        else if(collectionView == self.profileView.profilImageCollectionView){
            CGSize cellSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 360.0f);
            return cellSize;
        }
        
        CGFloat height = 56.0f;
        
        if (self.tapProfileViewControllerType == TAPProfileViewControllerTypePersonalFromClickedMention) {
            TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:self.user.userID];
            if (indexPath.row == 0) {
                //add to contacts
                if (![[TapUI sharedInstance] isAddContactEnabled] ||
                    ![[TapUI sharedInstance] getAddToContactsButtonInChatRoomVisibleState] ||
                    user != nil && user.isContact ||
                    [user.userID isEqualToString:[TAPDataManager getActiveUser].userID]
                ) {
                    // Hide if add to contacts menu is disabled in TapUI or user is already a contact
                    height = 0.0f;
                }
            }
            else if (indexPath.row == 1) {
                // Report member
                if (![[TapUI sharedInstance] getReportButtonInChatProfileVisibleState]) {
                    height = 0.0f;
                }
            }
        }
        else if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault  && self.room.type == RoomTypeGroup){
            height = 56.0f;
            TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
            NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
            
            TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
            
            if(indexPath.row == 1){
                if (self.profileView.editButton.alpha == 0) {
                    height = 0.0f;
                }
            }
            
            
        }
        else if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault){
            NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
            TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
            
            if(indexPath.row == 0){
                if (![[TapUI sharedInstance] getEditBioTextFieldVisible] || user.bio == nil || [user.bio isEqualToString:@""]) {
                    // Hide if bio in chat profile is disabled in TapUI
                    height = 0.0f;
                }
                else{
                    UILabel *bioHeightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 24.0f - 24.0f, 24.0f)];
                    UIFont *titleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileMenuLabel];
                    bioHeightLabel.font = titleLabelFont;
                    bioHeightLabel.numberOfLines = 0;
                    bioHeightLabel.text = user.bio;
                    [bioHeightLabel sizeToFit];
                    height = CGRectGetHeight(bioHeightLabel.frame) + 35.0f;
                    NSLog(@"===== user bio:%@", user.bio);
                }
            }
            else if(indexPath.row == 1){
                if (![[TapUI sharedInstance] getUsernameInChatProfileVisible] || user.username == nil || [user.username isEqualToString:@""]) {
                    // Hide if username in chat profile is disabled in TapUI
                    height = 0.0f;
                }
            }
            else if(indexPath.row == 2){
                if (![[TapUI sharedInstance] getMobileNumberInChatProfileVisible] || user.phone == nil || [user.phone isEqualToString:@""]) {
                    // Hide if mobile number in chat profile is disabled in TapUI
                    height = 0.0f;
                }
            }
            else if(indexPath.row == 3){
                if (![[TapUI sharedInstance] getEmailAddressInChatProfileVisible] || user.email == nil || [user.email isEqualToString:@""]) {
                    // Hide if email in chat profile is disabled in TapUI
                    height = 0.0f;
                }
            }
                
        }
        else if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile){
            if(indexPath.row == 0){
                if (![[TapUI sharedInstance] getEditBioTextFieldVisible] || self.user.bio == nil || [self.user.bio isEqualToString:@""]) {
                    // Hide if bio in chat profile is disabled in TapUI
                    height = 0.0f;
                }
                else{
                    UILabel *bioHeightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 24.0f - 24.0f, 24.0f)];
                    bioHeightLabel.text = self.user.bio;
                    [bioHeightLabel sizeToFit];
                    height += CGRectGetHeight(bioHeightLabel.frame) + 10.0f;
                }
            }
            else if(indexPath.row == 1){
                if (![[TapUI sharedInstance] getUsernameInChatProfileVisible] || self.user.username == nil || [self.user.username isEqualToString:@""]) {
                    // Hide if username in chat profile is disabled in TapUI
                    height = 0.0f;
                }
            }
            else if(indexPath.row == 2){
                if (![[TapUI sharedInstance] getMobileNumberInChatProfileVisible] || self.user.phone == nil || [self.user.phone isEqualToString:@""]) {
                    // Hide if mobile number in chat profile is disabled in TapUI
                    height = 0.0f;
                }
            }
            else if(indexPath.row == 3){
                if (![[TapUI sharedInstance] getEmailAddressInChatProfileVisible] || self.user.email == nil || [self.user.email isEqualToString:@""]) {
                    // Hide if email in chat profile is disabled in TapUI
                    height = 0.0f;
                }
            }
            
        }
        CGSize cellSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), height);
        return cellSize;
        
    }
    else if(indexPath.section == 1){
        CGFloat height = 56.0f;
        if (![[TapUI sharedInstance] isStarMessageMenuEnabled]){
            height = 0.0f;
        }
        CGSize cellSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), height);
        return cellSize;
    }
    else if(indexPath.section == 2){
        CGFloat height = 56.0f;
        if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault) {
            if (self.room.type == RoomTypePersonal) {
                if (indexPath.row == 1) {
                    //add to contacts
                    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
                    TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
                    if (![[TapUI sharedInstance] isAddContactEnabled] ||
                        ![[TapUI sharedInstance] getAddToContactsButtonInChatRoomVisibleState] ||
                        user != nil && user.isContact ||
                        [user.userID isEqualToString:[TAPDataManager getActiveUser].userID]
                    ) {
                        // Hide if add to contacts menu is disabled in TapUI or user is already a contact
                        height = 0.0f;
                    }
                }
                else if (indexPath.row == 2) {
                    // Report user
                    if (![[TapUI sharedInstance] getReportButtonInChatProfileVisibleState]) {
                        height = 0.0f;
                    }
                }
            }
            else if(self.room.type == RoomTypeGroup){
                if (indexPath.row == 1) {
                    // Report user
                    if (![[TapUI sharedInstance] getReportButtonInChatProfileVisibleState]) {
                        height = 0.0f;
                    }
                }
                
            }
        }
        else if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile){
            
            TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:self.user.userID];
            if (indexPath.row == 1) {
                //add to contacts
                if (![[TapUI sharedInstance] isAddContactEnabled] ||
                    ![[TapUI sharedInstance] getAddToContactsButtonInChatRoomVisibleState] ||
                    user != nil && user.isContact || [user.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                    // Hide if add to contacts menu is disabled in TapUI or user is already a contact
                    height = 0.0f;
                    
                }
                
            }

            
        }
        CGSize cellSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), height);
        return cellSize;
    }

    else if (indexPath.section == 3) {
        CGFloat height = 56.0f;
        CGSize cellSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), height);
        return cellSize;
    }
    
    else if (indexPath.section == 4) {
        CGSize cellSize = CGSizeMake((CGRectGetWidth([UIScreen mainScreen].bounds) - 3.0f) / 3.0f, (CGRectGetWidth([UIScreen mainScreen].bounds) - 3.0f) / 3.0f);
        return cellSize;
    }
    
    CGSize size = CGSizeZero;
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    if (section == 4) {
        UIEdgeInsets cellInsets = UIEdgeInsetsMake(0.0f, 0.5f, 0.0f, 0.5f);
        return cellInsets;
    }
    
    return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    //profil picture collection view
    if(collectionView == self.profileView.pageIndicatorCollectionView){
        return 1.0f;
    }
    else if(collectionView == self.profileView.profilImageCollectionView){
        return 0.0f;
    }
    
    
    if (section == 4) {
        return 1.0f;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    //profil picture collection view
    if(collectionView == self.profileView.pageIndicatorCollectionView){
        return 1.0f;
    }
    else if(collectionView == self.profileView.profilImageCollectionView){
        return 0.0f;
    }
    
    if (section == 4) {
        return 1.0f;
    }
    
    return 0.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   // if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile) {
       // return 1;
   // }
    
    //profil picture collection view
    if(collectionView == self.profileView.pageIndicatorCollectionView || collectionView == self.profileView.profilImageCollectionView){
        return 1;
    }
    
    if ([self.mediaMessageDataArray count] == 0 || self.mediaMessageDataArray == nil) {
        return 4; //Not showing 2 section because shared media is empty
    }
    
    return 5; //with media
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault) {
            //DV Note
            //Temporary Hidden For V1 because features is not complete (25 Mar 2019)
            //        return 5;
            //END DV Note
            
            //profil picture collection view
            if(collectionView == self.profileView.pageIndicatorCollectionView || collectionView == self.profileView.profilImageCollectionView){
                return self.photoListArray.count;
            }
            
            NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
            TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
            
            if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault && self.room.type == RoomTypeGroup){
                if (self.profileView.editButton.alpha == 1) {
                    return 2;
                }
                else{
                    return 1;
                }
            }
            
            if (![[TapUI sharedInstance] getEditBioTextFieldVisible] || user.bio == nil && ![[TapUI sharedInstance] getUsernameInChatProfileVisible] || user.username == nil && ![[TapUI sharedInstance] getMobileNumberInChatProfileVisible] || user.phone == nil && ![[TapUI sharedInstance] getEmailAddressInChatProfileVisible] || user.email == nil) {
                return 0;
            }
            else{
                return 4;
            }
            
        }
        else if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile){
            if(collectionView == self.profileView.pageIndicatorCollectionView || collectionView == self.profileView.profilImageCollectionView){
                return self.photoListArray.count;
            }
            
            
            if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault && self.room.type == RoomTypeGroup){
                return 1;
            }
            
            if (![[TapUI sharedInstance] getEditBioTextFieldVisible] || self.user.bio == nil && ![[TapUI sharedInstance] getUsernameInChatProfileVisible] || self.user.username == nil && ![[TapUI sharedInstance] getMobileNumberInChatProfileVisible] || self.user.phone == nil && ![[TapUI sharedInstance] getEmailAddressInChatProfileVisible] || self.user.email == nil) {
                return 0;
            }
            else{
                return 4;
            }
        }
        else if (self.tapProfileViewControllerType == TAPProfileViewControllerTypePersonalFromClickedMention) {
            return 3; //add to contact, send message, report
        }
        return 0;
    }
    else if(section == 1){
        return 1;
    }
    else if(section == 2){
        if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault) {
            //DV Note
            //Temporary Hidden For V1 because features is not complete (25 Mar 2019)
            //        return 5;
            //END DV Note
            if (self.room.type == RoomTypePersonal) {
                NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
                TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
                if(user.isContact){
                    return 0;
                }
                return 2;
            }
            if (self.room.type == RoomTypeGroup) {
                return 1;
                /**
                if (![[TapUI sharedInstance] getReportButtonInChatProfileVisibleState]) {
                    return 1;
                }
                else{
                    return 2;
                }
                */
            }
        }
        else if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile) {
            if (![self.room.admins containsObject:self.user.userID]) {
                return 3;
            }
            else{
                NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
                TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
                if(!user.isContact){
                    return 3;
                }
                
            }
        }
    }
    else if (section == 3) {
        if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault){
            if(self.room.type == RoomTypePersonal){
                return 2;
            }
            else{
                return 0;
            }
        }
        else if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile){
            return 2;
        }
        
    }
    else if (section == 4) {
        return [self.mediaMessageDataArray count];
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //DV Note
        //Temporary Hidden For V1 because features is not complete (25 Mar 2019)
//        NSString *cellID = @"TAPProfileCollectionViewCell";
//        [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
//        TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
//
//        if (indexPath.item == 0) {
//            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeNotification];
//            [cell showSeparatorView:YES];
//        }
//        else if (indexPath.item == 1) {
//            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeConversationColor];
//            [cell showSeparatorView:YES];
//        }
//        else if (indexPath.item == 2) {
//            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeBlock];
//            [cell showSeparatorView:YES];
//        }
//        else if (indexPath.item == 3) {
//            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeClearChat];
//            [cell showSeparatorView:NO];
//        }
//
//        return cell;
        //END DV Note
        
        //profil picture collection view
        if(collectionView == self.profileView.pageIndicatorCollectionView || collectionView == self.profileView.profilImageCollectionView){
            NSString *cellID = @"TAPImagePreviewCollectionViewCell";
            [collectionView registerClass:[TAPImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:cellID];
            TAPImagePreviewCollectionViewCell *cell = (TAPImagePreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
            
            [cell setImagePreviewCollectionViewCellType:TAPImagePreviewCollectionViewCellTypeProfileImage];
            cell.delegate = self;
            
            if(collectionView == self.profileView.pageIndicatorCollectionView){
                if(indexPath.row == 0){
                    [cell setPageIndicatorActive:YES];
                }
                else{
                    [cell setPageIndicatorActive:NO];
                }
            }
            else{
                //UIImage *image = [UIImage imageNamed:@"TAPIconDefaultGroupAvatar"];
                NSString *imageUrl = self.photoListArray[indexPath.row].fullsizeImageURL;
                [cell setImagePreviewImageWithUrl:imageUrl];
                //cell.backgroundColor = [TAPUtil randomPastelColor];
            }
            
            return cell;
        }
        
        if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault) {
            if (self.room.type == RoomTypePersonal) {
                NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
                TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
                NSString *cellID = @"TAPProfileCollectionViewCell";
                [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
                TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
                if (indexPath.item == 0) {
                    //BIO
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeUserDetail];
                    [cell showSeparatorView:YES];
                    [cell setUserDetailString: NSLocalizedStringFromTableInBundle(@"BIO", nil, [TAPUtil currentBundle], @"") detail:user.bio];
                    [cell setUserDetail:user.bio];
                }
                else if (indexPath.item == 1) {
                    //USERNAME
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeUserDetail];
                    [cell showSeparatorView:YES];
                    [cell setUserDetailString: NSLocalizedStringFromTableInBundle(@"USERNAME", nil, [TAPUtil currentBundle], @"") detail:user.username];
                }
                else if (indexPath.item == 2) {
                    //MOBILE NUMBER
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeUserDetail];
                    [cell setUserDetailString: NSLocalizedStringFromTableInBundle(@"MOBILE NUMBER", nil, [TAPUtil currentBundle], @"") detail:user.phone];
                    
                    if([[TapUI sharedInstance] getEmailAddressInChatProfileVisible]){
                        [cell showSeparatorView:YES];
                    }
                    else{
                        [cell showSeparatorView:NO];
                    }
                }
                else if (indexPath.item == 3) {
                    //MOBILE NUMBER
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeUserDetail];
                    [cell showSeparatorView:NO];
                    [cell setUserDetailString: NSLocalizedStringFromTableInBundle(@"EMAIL", nil, [TAPUtil currentBundle], @"") detail:user.email];
                }
                return cell;
            }
            else if (self.room.type == RoomTypeGroup) {
                NSString *cellID = @"TAPProfileCollectionViewCell";
                [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
                TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
                /**
                if (indexPath.item == 0) {
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeNotification];
                    [cell showSeparatorView:YES];
                }
                else if (indexPath.item == 1) {
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeSearchChat];
                    [cell showSeparatorView:YES];
                }
                */
                if (indexPath.item == 0) {
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeViewGroupMembers];
                    [cell showSeparatorView:YES];
                }
                else if (indexPath.item == 1) {
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeEditGroup];
                    [cell showSeparatorView:NO];
                }
                
                return cell;
            }
        }
        else if( self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile){
            NSString *cellID = @"TAPProfileCollectionViewCell";
            [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
            TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
            if (indexPath.item == 0) {
                //BIO
                [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeUserDetail];
                [cell showSeparatorView:YES];
                [cell setUserDetailString: NSLocalizedStringFromTableInBundle(@"BIO", nil, [TAPUtil currentBundle], @"") detail:self.user.bio];
                [cell setUserDetail:self.user.bio];
            }
            else if (indexPath.item == 1) {
                //USERNAME
                [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeUserDetail];
                [cell showSeparatorView:YES];
                [cell setUserDetailString: NSLocalizedStringFromTableInBundle(@"USERNAME", nil, [TAPUtil currentBundle], @"") detail:self.user.username];
            }
            else if (indexPath.item == 2) {
                //MOBILE NUMBER
                [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeUserDetail];
                [cell setUserDetailString: NSLocalizedStringFromTableInBundle(@"MOBILE NUMBER", nil, [TAPUtil currentBundle], @"") detail:self.user.phone];
                
                if([[TapUI sharedInstance] getEmailAddressInChatProfileVisible]){
                    [cell showSeparatorView:YES];
                }
                else{
                    [cell showSeparatorView:NO];
                }
            }
            else if (indexPath.item == 3) {
                //MOBILE NUMBER
                [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeUserDetail];
                [cell showSeparatorView:NO];
                [cell setUserDetailString: NSLocalizedStringFromTableInBundle(@"EMAIL", nil, [TAPUtil currentBundle], @"") detail:self.user.email];
            }
            return cell;
        }
        else if (self.tapProfileViewControllerType == TAPProfileViewControllerTypePersonalFromClickedMention) {
            NSString *cellID = @"TAPProfileCollectionViewCell";
            [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
            TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
            
            if (indexPath.item == 0) {
                //add contact
                [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeAddContacts];
                [cell showSeparatorView:YES];
            }
            else if (indexPath.item == 1) {
                //send message
                [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeSendMessage];
                [cell showSeparatorView:YES];
            }
            else if (indexPath.item == 2) {
                [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeReportUser];
                [cell showSeparatorView:YES];
            }
            
            return cell;
        }
    }
    else if(indexPath.section == 1){
        NSString *cellID = @"TAPProfileCollectionViewCell";
        [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
        [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeStarMessage];
        [cell showSeparatorView:YES];
        
        return cell;
    }
    else if(indexPath.section == 2){
        if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault) {
            if(self.room.type == RoomTypePersonal){
                NSString *cellID = @"TAPProfileCollectionViewCell";
                [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
                TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
                if (indexPath.item == 0) {
                    //add contact
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeSendMessage];
                    [cell showSeparatorView:YES];
                }
                else if (indexPath.item == 1) {
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeAddContacts];
                    [cell showSeparatorView:YES];
                }
                else if (indexPath.item == 2) {
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeReportUser];
                    [cell showSeparatorView:YES];
                }
                return cell;
            }
            else if(self.room.type == RoomTypeGroup){
                NSString *cellID = @"TAPProfileCollectionViewCell";
                [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
                TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
                
                if (indexPath.item == 0) {
                    if (self.isCurrentActiveUserIsAdmin && [self.room.participants count] == 1) {
                        //only 1 participant left, show delete group
                        [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeDeleteGroup];
                    }
                    else {
                        [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeLeaveGroup];
                    }
                    
                    [cell showSeparatorView:NO];
                }
                /**
                else if (indexPath.item == 1) {
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeDeleteGroup];
                    [cell showSeparatorView:NO];
                }
                */
                else if (indexPath.item == 1) {
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeReportGroup];
                    [cell showSeparatorView:NO];
                }
                return cell;
                
            }
        }
        else if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile) {
            NSString *cellID = @"TAPProfileCollectionViewCell";
            [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
            TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
            
            if (indexPath.item == 0) {
                //send message
                [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeSendMessage];
                [cell showSeparatorView:YES];
            }
            if (indexPath.item == 1) {
                //appoint as admin
                if(!self.user.isContact){
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeAddContacts];
                    [cell showSeparatorView:YES];
                }
                else if (![self.room.admins containsObject:self.user.userID]) {
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeAppointAsAdmin];
                }
                else {
                      [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeRemoveFromAdmin];
                }
            }
            else if (indexPath.item == 2) {
                //appoint as admin
                if (![self.room.admins containsObject:self.user.userID]) {
                    [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeAppointAsAdmin];
                }
                else {
                      [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeRemoveFromAdmin];
                }
                
                [cell showSeparatorView:YES];
            }
            else if (indexPath.item == 3) {
                //remove member
                [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeRemoveMember];
                [cell showSeparatorView:YES];
            }
            else if (indexPath.item == 4) {
                [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeReportUser];
                [cell showSeparatorView:YES];
            }
            
            return cell;
        }
    }
    else if(indexPath.section == 3){
        NSString *cellID = @"TAPProfileCollectionViewCell";
        [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        if (indexPath.item == 0) {
            //Report User
            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeReportUser];
            [cell showSeparatorView:YES];
        }
        else if(indexPath.item == 1){
            //Block User
            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeBlock];
            [cell showSeparatorView:YES];
        }
        
        return cell;
        
    }
    else if (indexPath.section == 4) {
        NSString *cellID = @"TAPImageCollectionViewCell";
        [collectionView registerClass:[TAPImageCollectionViewCell class] forCellWithReuseIdentifier:cellID];

        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        cell.delegate = self;
        
        TAPMessageModel *message = [self.mediaMessageDataArray objectAtIndex:indexPath.row];
        [cell setImageCollectionViewCellWithMessage:message];
        
        NSString *roomID = message.room.roomID;
        NSString *localID = message.localID;
        NSDictionary *dataDictionary = message.data;
        NSString *fileID = [dataDictionary objectForKey:@"fileID"];
        fileID = [TAPUtil nullToEmptyString:fileID];
        
        NSString *urlKey = [dataDictionary objectForKey:@"url"];
        if (urlKey == nil || [urlKey isEqualToString:@""]) {
            urlKey = [dataDictionary objectForKey:@"fileURL"];
        }
        urlKey = [TAPUtil nullToEmptyString:urlKey];
        
        if (![urlKey isEqualToString:@""]) {
            urlKey = [[urlKey componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
        }
        urlKey = [TAPUtil nullToEmptyString:urlKey];
        
        if (message.type == TAPChatMessageTypeImage) {
            if (![fileID isEqualToString:@""] || ![urlKey isEqualToString:@""]) {
                [TAPImageView imageFromCacheWithKey:urlKey message:message
                success:^(UIImage * _Nullable savedImage, TAPMessageModel *resultMessage) {
                    [self setImageCollectionViewCell:cell image:savedImage message:resultMessage];
                } failure:^(TAPMessageModel *resultMessage) {
                    [TAPImageView imageFromCacheWithKey:fileID message:message
                    success:^(UIImage * _Nullable savedImage, TAPMessageModel *resultMessage) {
                        [self setImageCollectionViewCell:cell image:savedImage message:resultMessage];
                    } failure:^(TAPMessageModel *resultMessage) {
                        [self setImageCollectionViewCell:cell image:nil message:resultMessage];
                    }];
                }];
            }
        }
        else if (message.type == TAPChatMessageTypeVideo) {
            NSNumber *duration = [message.data objectForKey:@"duration"];
            NSTimeInterval durationTimeInterval = [duration integerValue] / 1000; //convert to second
            NSString *videoDurationString = [TAPUtil stringFromTimeInterval:ceil(durationTimeInterval)];
            
            NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[message.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
            
            //Check video exist in cache
            
            //Check video is done downloaded or not
            NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:urlKey];
            if ([filePath isEqualToString:@""] || filePath == nil) {
                filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:message.room.roomID fileID:fileID];
            }
            
            NSDictionary *progressDictionary = [[TAPFileDownloadManager sharedManager] getDownloadProgressWithLocalID:message.localID];
       
            if ([filePath isEqualToString:@""] || filePath == nil) {
                //File not exist, download file
                [cell setAsNotDownloaded];
                [cell setInfoLabelWithString:fileSize];
            }
            else if (progressDictionary != nil) {
                //File is in downloading progress
                CGFloat progress = [[progressDictionary objectForKey:@"progress"] floatValue];
                CGFloat total = [[progressDictionary objectForKey:@"total"] floatValue];
                [cell setInitialAnimateDownloadingMedia];
                [cell setInfoLabelWithString:fileSize];
                [cell animateProgressDownloadingMediaWithProgress:progress total:total];
            }
            else {
                //File exist, show downloaded file
                [cell setInfoLabelWithString:videoDurationString];
                [cell setAsDownloaded];
                [cell setThumbnailImageForVideoWithMessage:message];
            }
        }
        
        return cell;
    }
    
    static NSString *cellID = @"UICollectionViewCell";
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    return cell;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesInRect = [NSArray array];
    return attributesInRect;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 4) {
        CGSize headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 24.0f + 36.0f);
        return headerSize;
    }
    else if(section == 1){
        CGSize headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 24.0f);
        headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 24.0f);
        return headerSize;
    }
    else if(section == 2){
        CGSize headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 24.0f);
        if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault){
            if(self.room.type == RoomTypePersonal){
                NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
                TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
                
                if(![[TapUI sharedInstance] getEditBioTextFieldVisible] && ![[TapUI sharedInstance] getUsernameInChatProfileVisible] && ![[TapUI sharedInstance] getMobileNumberInChatProfileVisible] && ![[TapUI sharedInstance] getEmailAddressInChatProfileVisible]){
                    headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0.01f);
                }
                
                if (![[TapUI sharedInstance] isAddContactEnabled] ||
                    ![[TapUI sharedInstance] getAddToContactsButtonInChatRoomVisibleState] ||
                    user != nil && user.isContact ||
                    [user.userID isEqualToString:[TAPDataManager getActiveUser].userID]
                ) {
                    // Hide if add to contacts menu is disabled in TapUI or user is already a contact
                    headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0.01f);
                }
                else{
                    headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 24.0f);
                }
                /**
                if (![[TapUI sharedInstance] getReportButtonInChatProfileVisibleState]) {
                    headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0.01f);
                }
                else{
                    headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 24.0f);
                }
                 */
            }
        }
        
        return headerSize;
    }
    else if(section == 3){
        CGSize headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 24.0f);
        if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault){
            if(self.room.type == RoomTypeGroup){
                headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0.01f);
            }
        }
        return headerSize;
    }
    
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 4) {
            NSString *headerID = @"ShareMediaHeaderView";
            [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:headerID];
            
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID forIndexPath:indexPath];
            
            UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
            [headerView preferredLayoutAttributesFittingAttributes:attributes];
            
            headerView.backgroundColor = [UIColor whiteColor];
            UIFont *sectionHeaderLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
            
            UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(headerView.frame), 24.0f)];
            seperatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
            [headerView addSubview:seperatorView];
            
            UIColor *sectionHeaderLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatProfileDetailTitleLabel];

            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 34.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, 18.0f)];
            titleLabel.text = NSLocalizedStringFromTableInBundle(@"SHARED MEDIA", nil, [TAPUtil currentBundle], @"");
            titleLabel.textColor = sectionHeaderLabelColor;
            titleLabel.font = sectionHeaderLabelFont;
            
            NSMutableAttributedString *titleLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:titleLabel.text];
            [titleLabelAttributedString addAttribute:NSKernAttributeName
                                                    value:@1.5f
                                                    range:NSMakeRange(0, [titleLabel.text length])];
            titleLabel.attributedText = titleLabelAttributedString;

            [headerView addSubview:titleLabel];
            
            return headerView;
        }

        else if(indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3){

            NSString *headerID = @"ShareMediaHeaderView";
            [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:headerID];
            
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID forIndexPath:indexPath];
            
            UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
            [headerView preferredLayoutAttributesFittingAttributes:attributes];
            
            headerView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
            
            return headerView;
            
        }
        
        NSString *headerID = @"headerView";
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:headerID];
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID forIndexPath:indexPath];
        
        UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
        [headerView preferredLayoutAttributesFittingAttributes:attributes];
        
        if (headerView == nil) {
            headerView = [[UICollectionReusableView alloc] initWithFrame:CGRectZero];
        }
        
        return headerView;
    }
    else if (kind == UICollectionElementKindSectionFooter) {
        NSString *footerID = @"footerView";
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:footerID];
        
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerID forIndexPath:indexPath];
        
        UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
        [footerView preferredLayoutAttributesFittingAttributes:attributes];
        
        if (footerView == nil) {
            footerView = [[UICollectionReusableView alloc] initWithFrame:CGRectZero];
        }
        
        return footerView;
    }
    
    return nil;
}

#pragma mark - Delegate

- (void)saveImageButtonDidLongpressWithIndex:(TAPImageView *)currentImageView{
    [self pictureLongPressClicked:currentImageView.image];
}

#pragma mark CollectionView
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault && self.room.type == RoomTypeGroup) {
            if (indexPath.row == 0) {
                //view group members
                _isLeaveFromGroupProfilePage = YES;
                TAPCreateGroupViewController *createGroupViewController = [[TAPCreateGroupViewController alloc] init]; //createGroupViewController
                createGroupViewController.tapCreateGroupViewControllerType = TAPCreateGroupViewControllerTypeMemberList;
                createGroupViewController.room = self.room;
                [self.navigationController pushViewController:createGroupViewController animated:YES];
            }
            else if (indexPath.row == 1) {
                [self editButtonDidTapped];
            }
            else if (indexPath.row == 2) {
                
            }
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            TAPStarredMessageViewController *tapStarredMessageViewController = [[TAPStarredMessageViewController alloc] initWithNibName:@"TAPStarredMessageViewController" bundle:[TAPUtil currentBundle]];
        
            if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault){
                tapStarredMessageViewController.currentRoom = self.room;
            }
            else if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile){
                [[TapUI sharedInstance] createRoomWithOtherUser:self.user success:^(TapUIChatViewController * _Nonnull chatViewController) {
                    tapStarredMessageViewController.currentRoom = chatViewController.currentRoom;
                }];
            }
            
            
            
            tapStarredMessageViewController.delegate = self;
            tapStarredMessageViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:tapStarredMessageViewController animated:YES];
        }
    }
    if (indexPath.section == 2) {
        if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault) {
            if (self.room.type == RoomTypePersonal) {
                if(indexPath.row == 0){
                    //send message
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
                    TAPUserModel *user = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
                    [[TapUI sharedInstance] createRoomWithOtherUser:user success:^(TapUIChatViewController * _Nonnull chatViewController) {
                        chatViewController.hidesBottomBarWhenPushed = YES;
                        [[[TapUI sharedInstance] roomListViewController].navigationController pushViewController:chatViewController animated:YES];
                    }];
                }
                else if (indexPath.row == 1) {
                    //add to contacts
                    [self.profileView showLoadingView:YES];
                    [self.profileView setAsLoadingState:YES withType:TAPProfileLoadingTypeAddToContact];
                    NSString *currentUserID = [TAPDataManager getActiveUser].userID;
                    currentUserID = [TAPUtil nullToEmptyString:currentUserID];
                    
                    if ([currentUserID isEqualToString:self.user.userID]) {
                        //Add theirselves
                        [self removeLoadingView];
                        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Add User To Contact"  title:NSLocalizedStringFromTableInBundle(@"Error", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Can't add yourself as contact", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                    }
                    else {
                        NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
                        TAPUserModel *obtainedUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
                        [TAPDataManager callAPIAddContactWithUserID:obtainedUser.userID success:^(NSString *message, TAPUserModel *user) {
                            [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:YES saveActiveUser:NO];
                            [self showFinishLoadingStateWithType:TAPProfileLoadingTypeAddToContact];
                            
                            [TAPUtil performBlock:^{
                                [self.navigationController popViewControllerAnimated:YES];
                            } afterDelay:1.2f];
                            
                        } failure:^(NSError *error) {
    #ifdef DEBUG
                            NSLog(@"%@", error);
    #endif
                            
                            [self removeLoadingView];
                        }];
                    }
                }
                else if (indexPath.row == 2) {
                    // Report user
                    id <TapUIChatProfileDelegate> chatProfileDelegate = [TapUI sharedInstance].chatProfileDelegate;
                    if ([chatProfileDelegate respondsToSelector:@selector(reportUserButtonDidTapped:room:user:)]) {
                        NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
                        TAPUserModel *obtainedUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
                        [chatProfileDelegate reportUserButtonDidTapped:self room:self.room user:obtainedUser];
                    }
                }
            }
            else if(self.room.type == RoomTypeGroup){
                if(indexPath.row == 0){
                    //leave group
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Leave Group" title:NSLocalizedStringFromTableInBundle(@"Leave Group", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"All messages and shared medias from this room will be inaccessible. Are you sure you want to leave?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Leave", nil, [TAPUtil currentBundle], @"")];
                }
                else if(indexPath.row == 1){
                    //delete group
                    
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Delete Group" title:NSLocalizedStringFromTableInBundle(@"Delete Group", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"All messages and shared medias from this room will be inaccessible. Are you sure you want to delete?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Delete", nil, [TAPUtil currentBundle], @"")];
                }
            }
        }
        else if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile) {
            if (indexPath.row == 1) {
                //add to contacts
                [self.profileView showLoadingView:YES];
                [self.profileView setAsLoadingState:YES withType:TAPProfileLoadingTypeAddToContact];
                NSString *currentUserID = [TAPDataManager getActiveUser].userID;
                currentUserID = [TAPUtil nullToEmptyString:currentUserID];
                
                if ([currentUserID isEqualToString:self.user.userID]) {
                    //Add theirselves
                    [self removeLoadingView];
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Add User To Contact"  title:NSLocalizedStringFromTableInBundle(@"Error", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Can't add yourself as contact", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                }
                else {
                    [TAPDataManager callAPIAddContactWithUserID:self.user.userID success:^(NSString *message, TAPUserModel *user) {
                        [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:YES saveActiveUser:NO];
                        [self showFinishLoadingStateWithType:TAPProfileLoadingTypeAddToContact];
                        
                        [TAPUtil performBlock:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        } afterDelay:1.2f];
                        
                    } failure:^(NSError *error) {
#ifdef DEBUG
                        NSLog(@"%@", error);
#endif
                        
                        [self removeLoadingView];
                    }];
                }
            }
            else if (indexPath.row == 0) {
                //send message
                [self.navigationController popToRootViewControllerAnimated:NO];
                
                [[TapUI sharedInstance] createRoomWithOtherUser:self.user success:^(TapUIChatViewController * _Nonnull chatViewController) {
                    chatViewController.hidesBottomBarWhenPushed = YES;
                    [[[TapUI sharedInstance] roomListViewController].navigationController pushViewController:chatViewController animated:YES];
                }];
            }
            else if (indexPath.row == 2) {
                //appoint & remove admin
                if ([self.room.admins containsObject:self.user.userID]) {
                     [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Demote Admin" title:NSLocalizedStringFromTableInBundle(@"Demote Admin", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Are you sure you want to demote this admin?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [TAPUtil currentBundle], @"")];
                }
                else {
                    //appoint as admin
                    [self.profileView showLoadingView:YES];
                    [self.profileView setAsLoadingState:YES withType:TAPProfileLoadingTypeAppointAdmin];
                    [TAPDataManager callAPIPromoteRoomAdminsWithRoomID:self.room.roomID userIDArray:@[self.user.userID] success:^(TAPRoomModel *room) {
                        _room = room;
                        
                        if ([self.delegate respondsToSelector:@selector(profileViewControllerUpdatedRoom:)]) {
                            [self.delegate profileViewControllerUpdatedRoom:room];
                        }
                        
                        [self showFinishLoadingStateWithType:TAPProfileLoadingTypeAppointAdmin];
                        
                        [TAPUtil performBlock:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        } afterDelay:1.2f];
                        
                    } failure:^(NSError *error) {
                        [self removeLoadingView];
                        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
                        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
                        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Promote Admin" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                    }];
                }
            }
            else if (indexPath.row == 3) {
                //remove member
                 [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Remove Member" title:NSLocalizedStringFromTableInBundle(@"Remove Member", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Are you sure you want to remove this member?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [TAPUtil currentBundle], @"")];
            }
            else if (indexPath.row == 4) {
                // Report member
                id <TapUIChatProfileDelegate> chatProfileDelegate = [TapUI sharedInstance].chatProfileDelegate;
                if ([chatProfileDelegate respondsToSelector:@selector(reportUserButtonDidTapped:room:user:)]) {
                    [chatProfileDelegate reportUserButtonDidTapped:self room:self.room user:self.user];
                }
            }
        }
        else if (self.tapProfileViewControllerType == TAPProfileViewControllerTypePersonalFromClickedMention) {
            if (indexPath.row == 0) {
                //add to contacts
                [self.profileView showLoadingView:YES];
                [self.profileView setAsLoadingState:YES withType:TAPProfileLoadingTypeAddToContact];
                NSString *currentUserID = [TAPDataManager getActiveUser].userID;
                currentUserID = [TAPUtil nullToEmptyString:currentUserID];
                
                if ([currentUserID isEqualToString:self.user.userID]) {
                    //Add theirselves
                    [self removeLoadingView];
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Add User To Contact"  title:NSLocalizedStringFromTableInBundle(@"Error", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Can't add yourself as contact", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                }
                else {
                    [TAPDataManager callAPIAddContactWithUserID:self.user.userID success:^(NSString *message, TAPUserModel *user) {
                        [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:YES saveActiveUser:NO];
                        [self showFinishLoadingStateWithType:TAPProfileLoadingTypeAddToContact];
                        
                        [TAPUtil performBlock:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        } afterDelay:1.2f];
                        
                    } failure:^(NSError *error) {
#ifdef DEBUG
                        NSLog(@"%@", error);
#endif
                        
                        [self removeLoadingView];
                    }];
                }
            }
            else if (indexPath.row == 1) {
                //send message
                [self.navigationController popToRootViewControllerAnimated:NO];
                
                [[TapUI sharedInstance] createRoomWithOtherUser:self.user success:^(TapUIChatViewController * _Nonnull chatViewController) {
                    chatViewController.hidesBottomBarWhenPushed = YES;
                    [[[TapUI sharedInstance] roomListViewController].navigationController pushViewController:chatViewController animated:YES];
                }];
            }
            else if (indexPath.row == 2) {
                // Report user
                id <TapUIChatProfileDelegate> chatProfileDelegate = [TapUI sharedInstance].chatProfileDelegate;
                if ([chatProfileDelegate respondsToSelector:@selector(reportUserButtonDidTapped:room:user:)]) {
                    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
                    TAPUserModel *obtainedUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
                    [chatProfileDelegate reportUserButtonDidTapped:self room:self.room user:obtainedUser];
                }
            }
        }
    }
    /**
    else if(indexPath.section == 1){
        if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeDefault){
            if(self.room.type == RoomTypeGroup){
                if(indexPath.row == 0){
                    //clear and exit group
                    
                    if (self.isCurrentActiveUserIsAdmin && [self.room.participants count] == 1) {
                        //delete group
                        
                        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Delete Group" title:NSLocalizedStringFromTableInBundle(@"Delete Group", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"All messages and shared medias from this room will be inaccessible. Are you sure you want to delete?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Delete", nil, [TAPUtil currentBundle], @"")];
                    }
                    else {
                        //leave group
                        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Leave Group" title:NSLocalizedStringFromTableInBundle(@"Leave Group", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"All messages and shared medias from this room will be inaccessible. Are you sure you want to leave?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Leave", nil, [TAPUtil currentBundle], @"")];
                    }
                }
                else if(indexPath.row == 1){
                    // Report group
                    id <TapUIChatProfileDelegate> chatProfileDelegate = [TapUI sharedInstance].chatProfileDelegate;
                    if ([chatProfileDelegate respondsToSelector:@selector(reportGroupButtonDidTapped:room:)]) {
                        [chatProfileDelegate reportGroupButtonDidTapped:self room:self.room];
                    }
                }
            }
        }
    }
    */

    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeSuccessMessage popupIdentifier:@"report user"  title:NSLocalizedStringFromTableInBundle(@"You have submitted a report.", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Your report is anonymous, and this user will not be notified. The process will take up to 24 hours.", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:@"OK"];
        }
        else if (indexPath.row == 1) {
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeSuccessMessage popupIdentifier:@"block user"  title:NSLocalizedStringFromTableInBundle(@"You’ve blocked this user.", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"The process will take up to 48 hours. They won’t be notified that you blocked them.", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:@"OK"];
        }
    }
    else if (indexPath.section == 4) {
        TAPMessageModel *selectedMessage = [self.mediaMessageDataArray objectAtIndex:indexPath.row];
        
        NSArray *messageArray = [self.mediaMessageDataArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:selectedMessage];
        
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:4]];

        
        if (selectedMessage.type == TAPChatMessageTypeImage) {
            CGFloat bubbleImageViewMinY = 0.0f;
            
            TAPMediaDetailViewController *mediaDetailViewController = [[TAPMediaDetailViewController alloc] init];
            [mediaDetailViewController setMediaDetailViewControllerType:TAPMediaDetailViewControllerTypeImage];
            mediaDetailViewController.delegate = self;
            mediaDetailViewController.message = cell.currentMessage;
            
            UIImage *cellImage = cell.imageView.image;
            NSArray *imageSliderImage = [NSArray array];
            if(cellImage != nil) {
                imageSliderImage = @[cellImage];
                TAPMessageModel *currentMessage = cell.currentMessage;
                NSString *cellImageURLString = [TAPUtil nullToEmptyString:[cell.currentMessage.data objectForKey:@"fileID"]];
                
                NSString *fileID = [cell.currentMessage.data objectForKey:@"fileID"];
                fileID = [TAPUtil nullToEmptyString:fileID];
                
                [mediaDetailViewController setThumbnailImageArray:imageSliderImage];
                [mediaDetailViewController setImageArray:@[cellImage]];
                
                [mediaDetailViewController setActiveIndex:0];
                
                NSInteger selectedRow = [self.mediaMessageDataArray indexOfObject:cell.currentMessage];
                NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:selectedRow inSection:4];
                
                UICollectionViewLayoutAttributes *attributes = [self.profileView.collectionView layoutAttributesForItemAtIndexPath:indexPath];

                CGRect cellRectInCollectionView = attributes.frame;
                
                CGRect cellRectInView = [self.profileView.collectionView convertRect:cellRectInCollectionView toView:self.profileView];

                [mediaDetailViewController showToViewController:self.navigationController thumbnailImage:cellImage thumbnailFrame:cellRectInView];
                cell.imageView.alpha = 0.0f;
                cell.thumbnailImageView.alpha = 0.0f;
                _openedBubbleCell = cell;
            }

        }
        if (selectedMessage.type == TAPChatMessageTypeVideo) {
            NSDictionary *dataDictionary = selectedMessage.data;
            dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
            
            NSString *key = [dataDictionary objectForKey:@"fileID"];
            key = [TAPUtil nullToEmptyString:key];
            
            NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:selectedMessage.room.roomID fileID:key];
            
            if (filePath == nil || [filePath isEqualToString:@""]) {
                NSString *fileURL = [dataDictionary objectForKey:@"url"];
                if (fileURL == nil || [fileURL isEqualToString:@""]) {
                    fileURL = [dataDictionary objectForKey:@"fileURL"];
                }
                fileURL = [TAPUtil nullToEmptyString:fileURL];
                
                if (![fileURL isEqualToString:@""]) {
                    key = fileURL;
                    key = [[key componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
                }
                
                filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:selectedMessage.room.roomID fileID:key];
            }
            
            if (filePath == nil || [filePath isEqualToString:@""]) {
                return;
            }
            
            NSURL *url = [NSURL fileURLWithPath:filePath];
            AVAsset *asset = [AVAsset assetWithURL:url];
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            
            //        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
            AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
            
            AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
            controller.delegate = self;
            controller.showsPlaybackControls = YES;
            [self presentViewController:controller animated:YES completion:nil];
            controller.player = player;
            [player play];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4 && indexPath.row == [self.mediaMessageDataArray count] - 10 && !self.isMediaLastPage) {
        TAPMessageModel *lastMessage = (TAPMessageModel *)[self.mediaMessageDataArray lastObject];
        [TAPDataManager getDatabaseMediaMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:[lastMessage.created stringValue] numberOfItem:50 success:^(NSArray *mediaMessages) {
            [self.mediaMessageDataArray addObjectsFromArray:mediaMessages];
            
            for (TAPMessageModel *message in mediaMessages) {
                [self.mediaMessageDataDictionary setObject:message forKey:message.localID];
            }
            
            [self.profileView.collectionView reloadData];
            
            if ([mediaMessages count] < 50) {
                _isMediaLastPage = YES;
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

/**
#pragma mark ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat topPadding = 0.0f;
    if (IS_IPHONE_X_FAMILY) {
        topPadding = [TAPUtil currentDeviceStatusBarHeight];
    }
    
    CGFloat meetingPoint = 44.0f + [TAPUtil currentDeviceStatusBarHeight];
    if (IS_IPHONE_X_FAMILY) {
        meetingPoint = 44.0f; //WK Note - Because the image Y position is max Y of status bar for iphone X.
    }
    
    CGFloat scrollProgress = 1 + ((scrollView.contentOffset.y + meetingPoint) / (CGRectGetHeight(self.profileView.profileImageView.frame) - meetingPoint));
    if (scrollProgress < 0.0f) {
        scrollProgress = 0.0f;
    }
    else if (scrollProgress > 1.0f) {
        scrollProgress = 1.0f;
    }
    
    //CHANGE FRAME nameLabel
    CGRect nameLabelFrame = self.profileView.nameLabel.frame;
    CGFloat nameLabelYPosition = self.profileView.nameLabelYPosition - (CGRectGetHeight(self.profileView.profileImageView.frame) - meetingPoint) * scrollProgress;
    nameLabelFrame.origin.y = nameLabelYPosition;
    self.profileView.nameLabel.frame = nameLabelFrame;
    
    //CHANGE FRAME navigationBarView
    CGRect navigationBarViewFrame = self.profileView.navigationBarView.frame;
    CGFloat navigationBarViewYPosition = -self.profileView.navigationBarHeight + topPadding + ((self.profileView.navigationBarHeight - topPadding) * scrollProgress);
    navigationBarViewFrame.origin.y = navigationBarViewYPosition;
    self.profileView.navigationBarView.frame = navigationBarViewFrame;
    
    //CHANGE FRAME navigationNameLabel
    CGRect navigationNameLabelFrame = self.profileView.navigationNameLabel.frame;
    CGFloat navigationNameLabelYPosition = self.profileView.navigationNameLabelYPosition - CGRectGetHeight(self.profileView.profileImageView.frame) * scrollProgress;
    navigationNameLabelFrame.origin.y = navigationNameLabelYPosition;
    self.profileView.navigationNameLabel.frame = navigationNameLabelFrame;
    
    self.profileView.navigationBackButton.alpha = scrollProgress;

    self.profileView.backButton.alpha = 1 - scrollProgress;
    if (self.room.type == RoomTypeGroup && [self.room.admins containsObject:self.otherUserID]) {
        self.profileView.navigationEditButton.alpha = scrollProgress;
        self.profileView.editButton.alpha = 1 - scrollProgress;
    }
    
    self.profileView.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:scrollProgress];
}
*/
#pragma mark - ScrollViewlDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollViewHeight = CGRectGetHeight(scrollView.frame);
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height;
    CGFloat currentYOffset = scrollView.contentOffset.y;
    
    if(scrollView == self.profileView.profilImageCollectionView){
        NSInteger currentIndex = roundf(scrollView.contentOffset.x / CGRectGetWidth([UIScreen mainScreen].bounds));
        [self updatePageIndicator:currentIndex];
        self.lastPageIndicatorIndex = currentIndex;
    }
}
#pragma mark - TAPStarredMessageViewControllerDelegate
- (void)starMessageBubbleCliked:(TAPMessageModel *)message{
    if ([self.delegate respondsToSelector:@selector(starMessageBubbleCliked:)]) {
        [self.delegate starMessageBubbleCliked:message];
    }
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma mark - TAPImageCollectionViewCellDelegate
- (void)imageCollectionViewCellDidTappedDownloadWithMessage:(TAPMessageModel *)message {
    if (message.type == TAPChatMessageTypeImage) {
        [self fetchImageDataWithMessage:message];
    }
    else if (message.type == TAPChatMessageTypeVideo) {
        [self fetchVideoDataWithMessage:message];
    }
}

- (void)imageCollectionViewCellDidTappedCancelWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] cancelDownloadWithMessage:message];
    TAPMessageModel *currentMessage = [self.mediaMessageDataDictionary objectForKey:message.localID];
    NSArray *messageArray = [self.mediaMessageDataArray copy];
    NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
    
    TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:4]];
    [cell animateFailedDownloadingMedia];
}

#pragma mark TAPMediaDetailViewController
- (void)mediaDetailViewControllerWillStartClosingAnimation {
    
}

- (void)mediaDetailViewControllerDidFinishClosingAnimation {
    if ([self.openedBubbleCell isKindOfClass:[TAPImageCollectionViewCell class]]) {
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)self.openedBubbleCell;
        cell.imageView.alpha = 1.0f;
        cell.thumbnailImageView.alpha = 1.0f;
    }
}

#pragma mark TAPCreateGroupSubjectViewController
- (void)createGroupSubjectViewControllerUpdatedRoom:(TAPRoomModel *)room {
    self.room.name = room.name;
    self.room.imageURL = room.imageURL;
    
    NSString *roomName = self.room.name;
    NSString *roomURL = self.room.imageURL.fullsize;
    
    self.profileView.nameLabel.text = roomName;
    self.profileView.navigationNameLabel.text = roomName;
    
    if (roomURL == nil || [roomURL isEqualToString:@""]) {
        if (self.room.type == RoomTypePersonal) {
            //Personal
            self.profileView.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }
        else {
            //Group or Channel
            self.profileView.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultGroupAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }
    }
    else {
        [self.profileView.profileImageView setImageWithURLString:roomURL];
    }
}

#pragma mark PopUpInfoViewController
- (void)popUpInfoDidTappedLeftButtonWithIdentifier:(NSString *)popupIdentifier {
    
}

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:popupIdentifier];
    
    if ([popupIdentifier isEqualToString:@"Error Promote Admin"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Demote Admin"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Add User To Contact"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Remove Member"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Leave Group"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Delete Group"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Demote Admin"]) {
        //remove from admin
        [self.profileView showLoadingView:YES];
        [self.profileView setAsLoadingState:YES withType:TAPProfileLoadingTypeRemoveAdmin];
        [TAPDataManager callAPIDemoteRoomAdminsWithRoomID:self.room.roomID userIDArray:@[self.user.userID] success:^(TAPRoomModel *room) {
            _room = room;
            
            if ([self.delegate respondsToSelector:@selector(profileViewControllerUpdatedRoom:)]) {
                [self.delegate profileViewControllerUpdatedRoom:room];
            }
            
            [self showFinishLoadingStateWithType:TAPProfileLoadingTypeRemoveAdmin];
            
            [TAPUtil performBlock:^{
                [self.navigationController popViewControllerAnimated:YES];
            } afterDelay:1.2f];
            
        } failure:^(NSError *error) {
            [self removeLoadingView];
            NSString *errorMessage = [error.userInfo objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Demote Admin" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
    }
    else if ([popupIdentifier isEqualToString:@"Remove Member"]) {
        [self.profileView showLoadingView:YES];
        [self.profileView setAsLoadingState:YES withType:TAPProfileLoadingTypeRemoveMember];
        
        [TAPDataManager callAPIRemoveRoomParticipantsWithRoomID:self.room.roomID userIDArray:@[self.user.userID] success:^(TAPRoomModel *room) {
            _room = room;
            
            if ([self.delegate respondsToSelector:@selector(profileViewControllerUpdatedRoom:)]) {
                [self.delegate profileViewControllerUpdatedRoom:room];
            }
            
            [self showFinishLoadingStateWithType:TAPProfileLoadingTypeRemoveMember];
            
            [TAPUtil performBlock:^{
                [self.navigationController popViewControllerAnimated:YES];
            } afterDelay:1.2f];
            
        } failure:^(NSError *error) {
            [self removeLoadingView];
            NSString *errorMessage = [error.userInfo objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Remove Member" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
        
    }
    else if ([popupIdentifier isEqualToString:@"Leave Group"]) {
        [self.profileView showLoadingView:YES];
        [self.profileView setAsLoadingState:YES withType:TAPProfileLoadingTypeLeaveGroup];
        [TAPDataManager callAPILeaveRoomWithRoomID:self.room.roomID success:^{
            [self showFinishLoadingStateWithType:TAPProfileLoadingTypeLeaveGroup];

            if ([self.delegate respondsToSelector:@selector(profileViewControllerDidTriggerLeaveOrDeleteGroupWithRoom:)]) {
                [self.delegate profileViewControllerDidTriggerLeaveOrDeleteGroupWithRoom:self.room];
            }
            
            //Throw view to room list
            [TAPUtil performBlock:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            } afterDelay:1.2f];
        } failure:^(NSError *error) {
            [self removeLoadingView];
            NSString *errorMessage = [error.userInfo objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Leave Group" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
    }
    else if ([popupIdentifier isEqualToString:@"Delete Group"]) {
        [self.profileView showLoadingView:YES];
        [self.profileView setAsLoadingState:YES withType:TAPProfileLoadingTypeDeleteGroup];
        
        [TAPDataManager callAPIDeleteRoomWithRoom:self.room success:^{
            [self showFinishLoadingStateWithType:TAPProfileLoadingTypeDeleteGroup];
            
            if ([self.delegate respondsToSelector:@selector(profileViewControllerDidTriggerLeaveOrDeleteGroupWithRoom:)]) {
                [self.delegate profileViewControllerDidTriggerLeaveOrDeleteGroupWithRoom:self.room];
            }
            
            //Throw view to room list
            [TAPUtil performBlock:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            } afterDelay:1.2f];
        } failure:^(NSError *error) {
            [self removeLoadingView];
            NSString *errorMessage = [error.userInfo objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Delete Group" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
    }
}

#pragma mark - Custom Method
#pragma mark ViewDidLoad Method
- (void)setupNavigationViewData {
    //This method is used to setup the title view of navigation bar, and also bar button view
    
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    //Title View
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 56.0f - 56.0f, 43.0f)];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 2.0f, CGRectGetWidth(self.titleView.frame), 22.0f)];
    
    UIFont *chatRoomNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatRoomNameLabel];
    UIColor *chatRoomNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomNameLabel];
    self.nameLabel.text = room.name;
   // self.nameLabel.text = [NSString stringWithFormat:@"%ld Members", [self.room.participants count]];
    self.nameLabel.textColor = chatRoomNameLabelColor;
    self.nameLabel.font = chatRoomNameLabelFont;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    
    if (self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile || self.room.type == RoomTypePersonal) {
        if(self.tapProfileViewControllerType == TAPProfileViewControllerTypeGroupMemberProfile){
            self.nameLabel.text = self.user.fullname;
        }
        self.nameLabel.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.titleView.frame), CGRectGetHeight(self.titleView.frame));
    }
    else{
        UIFont *chatRoomStatusLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatRoomStatusLabel];
        UIColor *chatRoomStatusLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomStatusLabel];
        _userStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.nameLabel.frame), CGRectGetWidth(self.titleView.frame), 16.0f)];
        self.userStatusLabel.textColor = chatRoomStatusLabelColor;
        self.userStatusLabel.font = chatRoomStatusLabelFont;
        self.userStatusLabel.textAlignment = NSTextAlignmentCenter;
        self.userStatusLabel.text = [NSString stringWithFormat:@"%ld Members", [self.room.participants count]];
        [self.titleView addSubview:self.userStatusLabel];
    }
    
    [self.titleView addSubview:self.nameLabel];
    
    _userStatusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, (16.0f - 7.0f) / 2.0f + 1.6f, 7.0f, 7.0f)];
    self.userStatusView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconUserStatusActive];
    self.userStatusView.layer.cornerRadius = CGRectGetHeight(self.userStatusView.frame) / 2.0f;
    self.userStatusView.alpha = 0.0f;
    self.userStatusView.clipsToBounds = YES;
    
    
    
    
    CGFloat userStatusViewWidth = CGRectGetWidth(self.userStatusLabel.frame) + CGRectGetWidth(self.userStatusView.frame) + 4.0f;
    _userDescriptionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.nameLabel.frame), userStatusViewWidth, 16.0f)];
    self.userDescriptionView.center = CGPointMake(self.nameLabel.center.x, self.userDescriptionView.center.y);
    [self.userDescriptionView addSubview:self.userStatusView];
   // [self.userDescriptionView addSubview:self.userStatusLabel];
    
    if (room.type != RoomTypeTransaction) {
        [self.titleView addSubview:self.userDescriptionView];
    }
    
    [self.navigationItem setTitleView:self.titleView];
    
    //Back Bar Button
    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}
#pragma mark Download Notification
- (void)fileDownloadManagerProgressNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = currentRoom.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        NSString *progressString = [notificationParameterDictionary objectForKey:@"progress"];
        CGFloat progress = [progressString floatValue];
        
        NSString *totalString = [notificationParameterDictionary objectForKey:@"total"];
        CGFloat total = [totalString floatValue];
        
        TAPMessageModel *currentMessage = [self.mediaMessageDataDictionary objectForKey:localID];
        NSArray *messageArray = [self.mediaMessageDataArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        TAPChatMessageType type = currentMessage.type;
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:4]];
        if (type == TAPChatMessageTypeImage) {
            [cell animateProgressDownloadingMediaWithProgress:progress total:total];
        }
        else if (type == TAPChatMessageTypeVideo) {
            [cell animateProgressDownloadingMediaWithProgress:progress total:total];
        }
    });
}

- (void)fileDownloadManagerStartNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = currentRoom.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        TAPMessageModel *currentMessage = [self.mediaMessageDataDictionary objectForKey:localID];
        NSArray *messageArray = [self.mediaMessageDataArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        TAPChatMessageType type = currentMessage.type;
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:4]];

        if (type == TAPChatMessageTypeImage) {
            [cell setInitialAnimateDownloadingMedia];
        }
        else if (type == TAPChatMessageTypeVideo) {
            [cell setInitialAnimateDownloadingMedia];
        }
    });
}

- (void)fileDownloadManagerFinishNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = currentRoom.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        TAPMessageModel *currentMessage = [self.mediaMessageDataDictionary objectForKey:localID];
        NSArray *messageArray = [self.mediaMessageDataArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        TAPChatMessageType type = currentMessage.type;
        
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:4]];
        
        if (type == TAPChatMessageTypeImage) {
            UIImage *fullImage = [notificationParameterDictionary objectForKey:@"fullImage"];

            if (fullImage != nil) {
                [cell setImageCollectionViewCellImageWithImage:fullImage];
            }
            [cell animateFinishedDownloadingMedia];
            [cell setAsDownloaded];
            [cell setInfoLabelWithString:@""];
        }
        else if (type == TAPChatMessageTypeVideo) {
            [cell animateFinishedDownloadingMedia];
            [cell setAsDownloaded];
            NSNumber *duration = [currentMessage.data objectForKey:@"duration"];
            NSTimeInterval durationTimeInterval = [duration integerValue] / 1000; //convert to second
            NSString *videoDurationString = [TAPUtil stringFromTimeInterval:ceil(durationTimeInterval)];
            [cell setInfoLabelWithString:videoDurationString];
            [cell setThumbnailImageForVideoWithMessage:currentMessage];
            
        }
    });
}

- (void)fileDownloadManagerFailureNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        NSError *error = [notificationParameterDictionary objectForKey:@"error"];
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = currentRoom.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        TAPMessageModel *currentMessage = [self.mediaMessageDataDictionary objectForKey:localID];
        NSArray *messageArray = [self.mediaMessageDataArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        TAPChatMessageType type = currentMessage.type;
        
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:4]];
        
        NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[currentMessage.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
        
        if (type == TAPChatMessageTypeImage) {
            [cell animateFailedDownloadingMedia];
            //if not show download button
            [cell setInfoLabelWithString:fileSize];
            [cell setAsNotDownloaded];
        }
        else if (type == TAPChatMessageTypeVideo) {
            [cell animateFailedDownloadingMedia];
            //File not exist, download file
            [cell setAsNotDownloaded];
            [cell setInfoLabelWithString:fileSize];
        }
    });
}

#pragma mark Others
- (void)backButtonDidTapped {
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.room.type == RoomTypePersonal && (self.isFullNameChanged || self.isUserProfileURLChanged)) {
        NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
        [objectDictionary setObject:self.room forKey:@"room"];
        [objectDictionary setObject:self.updatedUser forKey:@"user"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_USER_PROFILE_CHANGES object:objectDictionary];
    }
}

- (void)updatePageIndicator:(NSInteger)currentIndex{
    TAPImagePreviewCollectionViewCell *cellActive = (TAPImagePreviewCollectionViewCell *)[self.profileView.pageIndicatorCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0]];
    [cellActive setPageIndicatorActive:YES];
    
    if(currentIndex != self.lastPageIndicatorIndex){
        TAPImagePreviewCollectionViewCell *cellDisable = (TAPImagePreviewCollectionViewCell *)[self.profileView.pageIndicatorCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.lastPageIndicatorIndex inSection:0]];
       [cellDisable setPageIndicatorActive:NO];
    }
   
}

- (void)getPhotoListApi:(NSString *)userID {
    [TAPDataManager callAPIGetPhotoList:userID success:^(NSMutableArray<TAPPhotoListModel *> * photoListArray) {
        if(photoListArray.count > 0 || photoListArray != nil){
            self.photoListArray = photoListArray;
            self.profileView.profilImageCollectionView.alpha = 1.0f;
            self.profileView.initialNameView.alpha = 0.0f;
            [self.profileView.profilImageCollectionView reloadData];
            if(self.photoListArray.count == 1){
                self.profileView.pageIndicatorCollectionView.alpha = 0.0f;
            }
            else{
                self.profileView.pageIndicatorCollectionView.alpha = 1.0f;
            }
            [self.profileView.pageIndicatorCollectionView reloadData];
        }
        else{
            self.profileView.profilImageCollectionView.alpha = 0.0f;
            self.profileView.initialNameView.alpha = 1.0f;
            
        }
        
    } failure:^(NSError *error) {
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Get Photo List" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

- (void)pictureLongPressClicked:(UIImage *)image{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *saveImageAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Save Image", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
        [self saveImage:image];
                                   }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Do some thing here
                                   }];
    
    
    UIImage *saveImageActionImage = [UIImage imageNamed:@"TAPIconSaveOrange" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    saveImageActionImage = [saveImageActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconSelectPictureCamera]];
    [saveImageAction setValue:[saveImageActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    
    [saveImageAction setValue:@0 forKey:@"titleTextAlignment"];
    
    UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
    UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
    [saveImageAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
    
    [alertController addAction:saveImageAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image {
    [self.profileView setAsLoadingState:YES withType:TAPProfileLoadingTypeDoneLoading];
    [self.profileView showLoadingView:YES];
    UIImage *currentImage = image;
    if(currentImage == nil) {
        //[self showFinishSavingImageState];
    }
    else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    UIImageWriteToSavedPhotosAlbum(currentImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                }
                else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
                    [self removeSaveImageLoadingView];
                    //No permission. Trying to normally request it
                    
                    NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
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
}

//Override completionSelector method of save image to gallery
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (error == nil && status == PHAuthorizationStatusAuthorized) {
        [self showFinishSavingImageState];
    }
    else {
        [self removeSaveImageLoadingView];
    }
}

- (void)showFinishSavingImageState {
    [self.profileView setAsLoadingState:NO withType:TAPProfileLoadingTypeImageSaveLoading];
    [self performSelector:@selector(removeSaveImageLoadingView) withObject:nil afterDelay:1.0f];
}

- (void)removeSaveImageLoadingView {
    [self.profileView showLoadingView:NO];
}

- (void)getUserProfileDataWithUserID:(NSString *)userID {
    [TAPDataManager callAPIGetUserByUserID:userID success:^(TAPUserModel *user) {
        
        _updatedUser = user;
        
        NSString *existingUserFullName = self.room.name;
        NSString *obtainedUserFullName = user.fullname;
        
        NSString *existingUserProfileURL = self.room.imageURL.fullsize;
        NSString *obtainedUserProfileURL = user.imageURL.fullsize;
        
        _isFullNameChanged = NO;
        _isUserProfileURLChanged = NO;
        
        if (![obtainedUserFullName isEqualToString:existingUserFullName]) {
            //Change when name is different
            _isFullNameChanged = YES;
            self.profileView.nameLabel.text = obtainedUserFullName;
            self.profileView.navigationNameLabel.text = obtainedUserFullName;
        }
        
        if (![obtainedUserProfileURL isEqualToString:existingUserProfileURL]) {
            _isUserProfileURLChanged = YES;
            //Change when profile image is different
            [self.profileView.profileImageView setImageWithURLString:obtainedUserProfileURL];
        }
        
        if (self.room.type == RoomTypePersonal && (self.isFullNameChanged || self.isUserProfileURLChanged)) {
            //Save changes to contact dictionary
            [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO saveActiveUser:YES];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)getRoomDataWithRoomID:(NSString *)roomID {
    
    TAPRoomModel *roomFromPref = [[TAPGroupManager sharedManager] getRoomWithRoomID:roomID];
    if (roomFromPref != nil) {
        _room = roomFromPref;
        [self refreshProfileRoomViewData];
    }
    
    [TAPDataManager callAPIGetRoomWithRoomID:roomID success:^(TAPRoomModel *room) {
        _room = room;
        [self refreshProfileRoomViewData];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)fetchImageDataWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] receiveImageDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } success:^(UIImage * _Nonnull fullImage, TAPMessageModel * _Nonnull receivedMessage, NSString * _Nullable filePath) {
        //Already handled via Notification
    } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    }];
}

- (void)fetchVideoDataWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] receiveVideoDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } success:^(NSData * _Nonnull fileData, TAPMessageModel * _Nonnull receivedMessage, NSString * _Nonnull filePath) {
        //Already handled via Notification
    } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    }];
}

- (void)editButtonDidTapped {
    //CS TEMP - use this for update group view
    TAPCreateGroupSubjectViewController *createGroupSubjectViewController = [[TAPCreateGroupSubjectViewController alloc] init];
    createGroupSubjectViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    createGroupSubjectViewController.tapCreateGroupSubjectControllerType = TAPCreateGroupSubjectViewControllerTypeUpdate;
    [createGroupSubjectViewController setRoomData:self.room];
    createGroupSubjectViewController.delegate = self;
    createGroupSubjectViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:createGroupSubjectViewController animated:YES completion:nil];
}

- (void)showFinishLoadingStateWithType:(TAPProfileLoadingType)type {
    [self.profileView setAsLoadingState:NO withType:type];
    [self performSelector:@selector(removeLoadingView) withObject:nil afterDelay:1.0f];
}

- (void)removeLoadingView {
    [self.profileView showLoadingView:NO];
}

- (void)refreshProfileRoomViewData {
    NSString *roomName = self.room.name;
    NSString *roomURL = self.room.imageURL.fullsize;
    
    self.profileView.nameLabel.text = roomName;
    self.profileView.navigationNameLabel.text = roomName;
    
    if (roomURL == nil || [roomURL isEqualToString:@""]) {
        if (self.room.type == RoomTypePersonal) {
            //Personal
            self.profileView.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }
        else {
            //Group or Channel
            self.profileView.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultGroupAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }
    }
    else {
        [self.profileView.profileImageView setImageWithURLString:roomURL];
    }
    
    if ([self.room.admins containsObject:[TAPDataManager getActiveUser].userID]) {
        self.profileView.editButton.alpha = 1.0f;
    }
    else {
        self.profileView.editButton.alpha = 0.0f;
    }
}

- (void)setImageCollectionViewCell:(TAPImageCollectionViewCell *)cell
                             image:(UIImage *)image
                           message:(TAPMessageModel *)message {
    
    NSString *currentRoomID = message.room.roomID;
    NSString *currentLocalID = message.localID;
    NSDictionary *currentDataDictionary = message.data;
    
    NSDictionary *progressDictionary = [[TAPFileDownloadManager sharedManager] getDownloadProgressWithLocalID:message.localID];

    //Check image exist in cache
    if (image != nil) {
        //Image exist
        //set as downloaded
        //set image
        [cell setImageCollectionViewCellImageWithImage:image];
        [cell setAsDownloaded];
        [cell setInfoLabelWithString:@""];
    }
    //Check image is downloading
    else if (progressDictionary != nil) {
        CGFloat progress = [[progressDictionary objectForKey:@"progress"] floatValue];
        CGFloat total = [[progressDictionary objectForKey:@"total"] floatValue];
        [cell setInitialAnimateDownloadingMedia];
        
        NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[message.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
        [cell setInfoLabelWithString:fileSize];
        
        [cell animateProgressDownloadingMediaWithProgress:progress total:total];
    }
    else {
        //Image not exist in cache
        //if not show download button
        NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[message.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
        [cell setInfoLabelWithString:fileSize];
        [cell setAsNotDownloaded];
    }
}

@end
