//
//  TapUIRoomListViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 6/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TapAFNetworking.h"
#import "TapUIRoomListViewController.h"
#import "TAPRoomListView.h"
#import "TAPAddNewChatViewController.h"
#import "TapUIChatViewController.h"
#import "TAPSetupRoomListView.h"
#import "TAPRoomListTableViewCell.h"
#import "TAPRoomListModel.h"
#import "TAPConnectionStatusViewController.h"
#import "TAPSearchViewController.h"
#import "TAPMyAccountViewController.h"
#import "TAPMutedRoomModel.h"
#import "TAPClearedRoomModel.h"

@interface TapUIRoomListViewController () <UITableViewDelegate, UITableViewDataSource, TAPChatManagerDelegate, UITextFieldDelegate, TAPConnectionStatusViewControllerDelegate, TAPAddNewChatViewControllerDelegate, TAPChatViewControllerDelegate, UIViewControllerPreviewingDelegate, TAPSearchViewControllerDelegate, TAPMyAccountViewControllerDelegate, UIAdaptivePresentationControllerDelegate>
@property (strong, nonatomic) UIImage *navigationShadowImage;

@property (strong, nonatomic) TAPRoomListView *roomListView;
@property (strong, nonatomic) TAPSetupRoomListView *setupRoomListView;
@property (strong, nonatomic) TAPConnectionStatusViewController *connectionStatusViewController;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
@property (strong, nonatomic) TAPImageView *profileImageView;
@property (strong, nonatomic) UIView *leftBarView;
@property (strong, nonatomic) UIView *rightBarView;
@property (strong, nonatomic) UIView *leftBarInitialNameView;
@property (strong, nonatomic) UILabel *leftBarInitialNameLabel;
@property (strong, nonatomic) UIButton *leftBarInitialNameButton;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *myAccountButton;
@property (strong, nonatomic) UIButton *rightBarButton;
@property (strong, nonatomic) NSMutableArray *unreadRoomIDs;
@property (strong, nonatomic) NSMutableArray *pinnedRoomIDs;
@property (strong, nonatomic) NSMutableArray *clearedRoomModelArray;
@property (strong, nonatomic) NSMutableDictionary *mutedRoomDictionary;

@property (strong, nonatomic) NSMutableDictionary *unreadMentionDictionary;

@property (nonatomic) NSInteger firstUnreadProcessCount;
@property (nonatomic) NSInteger firstUnreadTotalCount;
@property (nonatomic) NSInteger counterOnSuccess;

@property (nonatomic) BOOL isPinRoomDataChange;
@property (nonatomic) BOOL isMuteRoomDataChange;
@property (strong, nonatomic) NSString *readUnreadStateString;
@property (strong, nonatomic) UIImage *readUnreadStateImage;

@property (nonatomic) BOOL isNeedRefreshOnNetworkDown;
@property (nonatomic) BOOL isShowMyAccountView;

- (void)mappingMessageArrayToRoomListArrayAndDictionary:(NSArray *)messageArray;
- (void)insertRoomListToArrayAndDictionary:(TAPRoomListModel *)roomList atIndex:(NSInteger)index;
- (void)runFullRefreshSequence;
- (void)fetchDataFromAPI;
- (void)insertReloadMessageAndUpdateUILogicWithMessageArray:(NSArray *)messageArray;
- (void)reloadLocalDataAndUpdateUILogicAnimated:(BOOL)animated;
- (void)refreshViewAndQueryUnreadLogicWithMessageArray:(NSArray *)messageArray animateReloadData:(BOOL)animateReloadData;
- (void)queryNumberOfUnreadMessageInRoomListArrayInBackgroundAndUpdateUIAndReloadTableView:(BOOL)reloadTableView;
- (void)processMessageFromSocket:(TAPMessageModel *)message isNewMessage:(BOOL)isNewMessage;
- (void)updateCellDataAtIndexPath:(NSIndexPath *)indexPath updateUnreadBubble:(BOOL)updateUnreadBubble;
- (void)openNewChatViewController;
- (void)hideSetupViewWithDelay:(double)delayTime;
- (void)getAndUpdateNumberOfUnreadToDelegate;
- (void)checkUpdatedUserProfileWithMessage:(TAPMessageModel *)message;
- (void)checkAndUpdateActiveUserProfile;

@end

@implementation TapUIRoomListViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    BOOL isShowCloseButton = [[TapUI sharedInstance] getCloseRoomListButtonVisibleState];
    BOOL isShowMyAccountInChatRoom = [[TapUI sharedInstance] getMyAccountButtonInRoomListViewVisibleState];
    BOOL isShowSearchBarInChatRoom = [[TapUI sharedInstance] getSearchBarInRoomListVisibleState];
    BOOL isShowNewChatButtonInChatRoom = [[TapUI sharedInstance] getNewChatButtonInRoomListVisibleState];
    if (!isShowCloseButton && !isShowMyAccountInChatRoom && !isShowSearchBarInChatRoom && !isShowNewChatButtonInChatRoom) {
        //hide navigation bar
        _roomListView = [[TAPRoomListView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
        CGFloat topBarGap = [TAPUtil currentDeviceStatusBarHeight];
        [self.roomListView setInitialYPositionOfTableView:topBarGap];
        [self.view addSubview:self.roomListView];
    }
    else {
        _roomListView = [[TAPRoomListView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
        [self.view addSubview:self.roomListView];
    }

    if ([self.lifecycleDelegate respondsToSelector:@selector(TapUIRoomListViewControllerLoadView)]) {
        [self.lifecycleDelegate TapUIRoomListViewControllerLoadView];
    }

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
    
    //Add chat manager delegate
    [[TAPChatManager sharedManager] addDelegate:self];
    
    _unreadRoomIDs = [NSMutableArray array];
    _pinnedRoomIDs = [NSMutableArray array];
    _clearedRoomModelArray = [NSMutableArray array];
    
    self.pinnedRoomIDs = [TAPDataManager getPinnedRoomIDs];
    self.mutedRoomDictionary = [[TAPDataManager getMutedRoomDictionary] mutableCopy];
    
    if(self.mutedRoomDictionary == nil){
        _mutedRoomDictionary = [NSMutableDictionary dictionary];
    }
    
    self.unreadRoomIDs = [[TAPDataManager getUnreadRoomIDs] mutableCopy];
    
    _setupRoomListView = [[TAPSetupRoomListView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    
    [self.navigationController.view addSubview:self.setupRoomListView];
    [self.navigationController.view bringSubviewToFront:self.setupRoomListView];
        
    [self.roomListView.startChatNoChatsButton addTarget:self action:@selector(openNewChatViewController) forControlEvents:UIControlEventTouchDown];
    
    
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    _myAccountButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    _leftBarInitialNameView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 42.0f, 42.0f)];
    _leftBarInitialNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(
        CGRectGetMinX(self.leftBarInitialNameView.frame),
        CGRectGetMinY(self.leftBarInitialNameView.frame),
        CGRectGetWidth(self.leftBarInitialNameView.frame),
        CGRectGetHeight(self.leftBarInitialNameView.frame))
    ];
    _leftBarInitialNameButton = [[UIButton alloc] initWithFrame:self.leftBarInitialNameView.frame];
    _profileImageView = [[TAPImageView alloc] initWithFrame:self.leftBarInitialNameView.frame];
    _leftBarView = [[UIView alloc] initWithFrame:CGRectMake(
        0.0f,
        0.0f,
        CGRectGetMaxX(self.myAccountButton.frame),
        40.0f
    )];
    _rightBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    _rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(
        0.0f,
        0.0f,
        CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(self.leftBarView.frame) - CGRectGetWidth(self.rightBarButton.frame) - 36.0f,
        36.0f
    )];
    [self setUpNavigationBar];
    
    self.roomListView.roomListTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    self.roomListView.roomListTableView.delegate = self;
    self.roomListView.roomListTableView.dataSource = self;
    self.roomListView.roomListTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.roomListView.roomListTableView.delaysContentTouches = NO;
    
    _roomListArray = [NSMutableArray array];
    _roomListDictionary = [NSMutableDictionary dictionary];
    _unreadMentionDictionary = [NSMutableDictionary dictionary];
    
    _connectionStatusViewController = [[TAPConnectionStatusViewController alloc] init];
    [self addChildViewController:self.connectionStatusViewController];
    [self.connectionStatusViewController didMoveToParentViewController:self];
    self.connectionStatusViewController.delegate = self;
    [self.roomListView addSubview:self.connectionStatusViewController.view];
    
    if ([self.lifecycleDelegate respondsToSelector:@selector(TapUIRoomListViewControllerViewDidLoad)]) {
        [self.lifecycleDelegate TapUIRoomListViewControllerViewDidLoad];
    }
    
    [self.setupRoomListView.retryButton addTarget:self action:@selector(viewLoadedSequence) forControlEvents:UIControlEventTouchUpInside];
    
    //View appear sequence
    [self viewLoadedSequence];
    
    //Check for 3D Touch availability
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)) {
        [self registerForPreviewingWithDelegate:self sourceView:self.roomListView.roomListTableView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isViewAppear = YES;
    
    //Check and update current active user profile picture
    [self checkAndUpdateActiveUserProfile];

    if ([self.lifecycleDelegate respondsToSelector:@selector(TapUIRoomListViewControllerViewWillAppear)]) {
        [self.lifecycleDelegate TapUIRoomListViewControllerViewWillAppear];
    }
    
    //Check show navigation bar of not
    BOOL isShowCloseButton = [[TapUI sharedInstance] getCloseRoomListButtonVisibleState];
    BOOL isShowMyAccountInChatRoom = [[TapUI sharedInstance] getMyAccountButtonInRoomListViewVisibleState];
    BOOL isShowSearchBarInChatRoom = [[TapUI sharedInstance] getSearchBarInRoomListVisibleState];
    BOOL isShowNewChatButtonInChatRoom = [[TapUI sharedInstance] getNewChatButtonInRoomListVisibleState];
    if (!isShowCloseButton && !isShowMyAccountInChatRoom && !isShowSearchBarInChatRoom && !isShowNewChatButtonInChatRoom) {
        //Hide Navigation Bar
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    if ([[TapTalk sharedInstance] getTapTalkSocketConnectionMode] == TapTalkSocketConnectionModeConnectIfNeeded) {
        [[TapTalk sharedInstance] connectWithSuccess:^{
                    
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isViewAppear = NO;
    
    if (self.searchBarView.searchTextField.isFirstResponder) {
        [self.searchBarView.searchTextField resignFirstResponder];
    }
    
    if ([self.lifecycleDelegate respondsToSelector:@selector(TapUIRoomListViewControllerViewWillDisappear)]) {
        [self.lifecycleDelegate TapUIRoomListViewControllerViewWillDisappear];
    }
    
    if ([[TapTalk sharedInstance] getTapTalkSocketConnectionMode] == TapTalkSocketConnectionModeConnectIfNeeded) {
        [[TapTalk sharedInstance] disconnectWithCompletionHandler:^{
            
        }];
    }
}

- (void)dealloc {
    [[TAPChatManager sharedManager] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
    
    if ([self.lifecycleDelegate respondsToSelector:@selector(TapUIRoomListViewControllerDealloc)]) {
        [self.lifecycleDelegate TapUIRoomListViewControllerDealloc];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self.lifecycleDelegate respondsToSelector:@selector(TapUIRoomListViewControllerDidReceiveMemoryWarning)]) {
        [self.lifecycleDelegate TapUIRoomListViewControllerDidReceiveMemoryWarning];
    }
}
    
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.lifecycleDelegate respondsToSelector:@selector(TapUIRoomListViewControllerViewDidAppear)]) {
        [self.lifecycleDelegate TapUIRoomListViewControllerViewDidAppear];
    }
}
    
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self.lifecycleDelegate respondsToSelector:@selector(TapUIRoomListViewControllerViewDidDisappear)]) {
        [self.lifecycleDelegate TapUIRoomListViewControllerViewDidDisappear];
    }
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.roomListArray count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 74.0f;
    }
    
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPRoomListTableViewCell";
        
        TAPRoomListTableViewCell *cell = [[TAPRoomListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        TAPRoomListModel *roomList = [self.roomListArray objectAtIndex:indexPath.row];
        cell.tableView = tableView;
        [cell setRoomListTableViewCellWithData:roomList updateUnreadBubble:NO];
        
        if (indexPath.row == [self.roomListArray count] - 1) {
            [cell setIsLastCellSeparator:YES];
        }
        else {
            [cell setIsLastCellSeparator:NO];
        }
        
        [cell setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
        
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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

//DV Note
//Temporary Hidden For V1 (30 Jan 2019)
//Hide Blocked Contacts
//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewRowAction *readRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        NSLog(@"Read Did Tapped");
//    }];
//    readRowAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TAPIconSlideActionRead" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
//
//    UITableViewRowAction *muteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        NSLog(@"Mute Did Tapped");
//    }];
//    muteRowAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TAPIconSlideActionMute" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
//
//    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        NSLog(@"Delete Did Tapped");
//    }];
//    deleteRowAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TAPIconSlideActionDelete" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
//
//    NSArray<UITableViewRowAction *> *rowActionArray = [NSArray arrayWithObjects:deleteRowAction, muteRowAction, readRowAction, nil];
//    return rowActionArray;
//}
//END DV NOTE

#pragma mark - Delegate
#pragma mark UIViewControllerPreviewing
//- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
//    NSIndexPath *indexPath = [self.roomListView.roomListTableView indexPathForRowAtPoint:location];
//
//    TAPRoomListTableViewCell *cell = [self.roomListView.roomListTableView cellForRowAtIndexPath:indexPath];
//
//    TAPRoomListModel *selectedRoomList = [self.roomListArray objectAtIndex:indexPath.row];
//    TAPMessageModel *selectedMessage = selectedRoomList.lastMessage;
//    TAPRoomModel *room = selectedMessage.room;
//
//    CGRect convertedRect = [cell convertRect:cell.bounds toView:self.roomListView.roomListTableView];
//    previewingContext.sourceRect = convertedRect;
//
//    //DV Note - Open Room with Room method (duplicate from TapTalk Instance)
//    [[TAPChatManager sharedManager] openRoom:room];
//    [[TAPChatManager sharedManager] saveAllUnsentMessage];
//
//    TapUIChatViewController *chatViewController = [[TapUIChatViewController alloc] initWithNibName:@"TapUIChatViewController" bundle:[TAPUtil currentBundle]];
//    chatViewController.currentRoom = room;
//    chatViewController.delegate = [[TapUI sharedInstance] roomListViewController];
//    [chatViewController setChatViewControllerType:TapUIChatViewControllerTypePeek];
//    //END DV Note
//
//    return chatViewController;
//}

//- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
//    TapUIChatViewController *chatViewController = (TapUIChatViewController *)viewControllerToCommit;
//    [chatViewController setChatViewControllerType:TapUIChatViewControllerTypeDefault];
//    [self.navigationController showViewController:chatViewController sender:nil];
//}

#pragma mark TableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TAPRoomListModel *selectedRoomList = [self.roomListArray objectAtIndex:indexPath.row];
    TAPMessageModel *selectedMessage = selectedRoomList.lastMessage;
    TAPRoomModel *selectedRoom = selectedMessage.room;
    
    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:selectedMessage.room.roomID];
    TAPUserModel *otherUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
    if (otherUser != nil) {
        selectedRoom.imageURL = otherUser.imageURL;
    }
    
    [[TapUI sharedInstance] createRoomWithRoom:selectedRoom success:^(TapUIChatViewController * _Nonnull chatViewController) {
        chatViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:YES];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchBarView.searchTextField.isFirstResponder) {
        [self.searchBarView.searchTextField resignFirstResponder];
    }
}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isPinnedRoom = NO;
    
    TAPRoomListModel *roomList = [self.roomListArray objectAtIndex:indexPath.row];
    TAPMessageModel *selectedMessage = roomList.lastMessage;
    TAPRoomModel *selectedRoom = selectedMessage.room;
    
    if([self.pinnedRoomIDs containsObject:selectedRoom.roomID]){
        isPinnedRoom = YES;
    }
    
    UIContextualAction *readUnreadAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self.view endEditing:YES];
        completionHandler(YES);
        
        TAPRoomListModel *roomList = [self.roomListArray objectAtIndex:indexPath.row];
        TAPMessageModel *selectedMessage = roomList.lastMessage;
        TAPRoomModel *selectedRoom = selectedMessage.room;
        
        if(roomList.numberOfUnreadMessages > 0 || roomList.isMarkedAsUnread) {
            roomList.numberOfUnreadMessages = 0;
            roomList.isMarkedAsUnread = NO;
            [self.unreadRoomIDs removeObject:selectedRoom.roomID];
            self.roomListArray[indexPath.row] = roomList;
            //[self.roomListView.roomListTableView reloadData];
            NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
            [self updateCellDataAtIndexPath:cellIndexPath updateUnreadBubble:YES];
            
            [[TAPCoreMessageManager sharedManager] markAllMessagesInRoomAsReadWithRoomID:selectedRoom.roomID];
        }
        else{
            [self.unreadRoomIDs addObject:selectedRoom.roomID];
            roomList.isMarkedAsUnread = YES;
            [[TAPCoreRoomListManager sharedManager] markChatRoomAsUnreadWithRoomID:selectedRoom.roomID success:^{
                // TODO: SAVE UNREAD IDS TO PREFERENCE
            }
            failure:^(NSError * _Nonnull error) {
                
            }];
            
           // [self.roomListView.roomListTableView reloadData];
            self.roomListArray[indexPath.row] = roomList;
            NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
            [self updateCellDataAtIndexPath:cellIndexPath updateUnreadBubble:YES];
            
        }
        TAPRoomListModel *tt = [self.roomListArray objectAtIndex:indexPath.row];
        NSLog(@"===== isMarked:%ld", tt.isMarkedAsUnread);
        [TAPDataManager setUnreadRoomIDs:self.unreadRoomIDs];
        [self getAndUpdateNumberOfUnreadToDelegate];
    }];
    
    UIContextualAction *pinUnpinAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self.view endEditing:YES];
        completionHandler(YES);
        
        if(isPinnedRoom) {
            [self.pinnedRoomIDs removeObject:selectedRoom.roomID];
            [TAPDataManager setPinnedRoomIDs:[self.pinnedRoomIDs copy]];
                
            [self showPinRoom:NO roomID:selectedRoom.roomID];
            [TAPDataManager callAPIUnpinRoom:@[selectedRoom.roomID] success:^(NSArray *roomIDs){
                
                
                
            } failure:^(NSError *error){
                    
            }];
            
            
        }
        else {
            NSInteger roomMaxPinned = [[TAPCoreRoomListManager sharedManager] getMaxPinnedRoom];
            
            if([self.pinnedRoomIDs count] < roomMaxPinned){
                [self.pinnedRoomIDs insertObject:selectedRoom.roomID atIndex:0];
                [TAPDataManager setPinnedRoomIDs:[self.pinnedRoomIDs copy]];
                
                [self showPinRoom:YES roomID:selectedRoom.roomID];
                [TAPDataManager callAPIPinRoom:@[selectedRoom.roomID] success:^(NSArray *roomIDs){
                    
                } failure:^(NSError *error){
                    
                }];
                
            }
            else{
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error" title:NSLocalizedStringFromTableInBundle(@"Error", nil, [TAPUtil currentBundle], @"") detailInformation:@"You have reached the maximum of pinned chat rooms." leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
            }
        }
        
    }];
    

    if(roomList.numberOfUnreadMessages > 0 || roomList.isMarkedAsUnread){
        /**
        if(![[TapUI sharedInstance] getMarkAsReadRoomListSwipeMenuEnabled]){
            return nil;
       
        }
        */
        self.readUnreadStateString = NSLocalizedStringFromTableInBundle(@"Read", nil, [TAPUtil currentBundle], @"");
        self.readUnreadStateImage = [UIImage imageNamed:@"TAPIconMarkRead" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    else{
        /**
        if(![[TapUI sharedInstance] getMarkAsUnreadRoomListSwipeMenuEnabled]){
            return nil;
            
        }
        */
        self.readUnreadStateString = NSLocalizedStringFromTableInBundle(@"Unread", nil, [TAPUtil currentBundle], @"");
        self.readUnreadStateImage = [UIImage imageNamed:@"TAPIconMarkUnread" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    
    UIImage *readUnreadImageRendered = [self createImageFromView:[self addedUIViewSwipeAction:self.readUnreadStateImage title:self.readUnreadStateString]];
    readUnreadAction.image = readUnreadImageRendered;
    readUnreadAction.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorRoomListSwipeButtonBackground];
    
    UIImage *pinUnpinImageRendered = nil;
    
    if(isPinnedRoom) {
        pinUnpinImageRendered = [self createImageFromView:[self addedUIViewSwipeAction: [UIImage imageNamed:@"TAPIconUnpinRoom" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] title:@"Unpin"]];
    }
    else {
        pinUnpinImageRendered = [self createImageFromView:[self addedUIViewSwipeAction: [UIImage imageNamed:@"TAPIconPinRoom" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] title:@"Pin"]];
    }
    
    
    pinUnpinAction.image = pinUnpinImageRendered;
    pinUnpinAction.backgroundColor = [TAPUtil getColor:@"BB5C00"];
    
    
    NSMutableArray *rowActionArray = [NSMutableArray array];
    
    
    if([[TapUI sharedInstance] getMarkAsUnreadRoomListSwipeMenuEnabled] && [[TapUI sharedInstance] getMarkAsReadRoomListSwipeMenuEnabled]){
        [rowActionArray addObject:readUnreadAction];
    }
    else {
        if((roomList.numberOfUnreadMessages > 0 || roomList.isMarkedAsUnread) && [[TapUI sharedInstance] getMarkAsReadRoomListSwipeMenuEnabled]){
            [rowActionArray addObject:readUnreadAction];
        }
        else if([[TapUI sharedInstance] getMarkAsUnreadRoomListSwipeMenuEnabled]){
            [rowActionArray addObject:readUnreadAction];
        }
    }
    
    if([[TapUI sharedInstance] getPinRoomListSwipeMenuEnabled]){
        [rowActionArray addObject:pinUnpinAction];
    }
    
    return [UISwipeActionsConfiguration configurationWithActions:rowActionArray];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    TAPRoomListModel *roomList = [self.roomListArray objectAtIndex:indexPath.row];
    TAPMessageModel *selectedMessage = roomList.lastMessage;
    TAPRoomModel *selectedRoom = selectedMessage.room;
    
    BOOL isMutedRoom = NO;
    NSNumber *mutedExpired = [self.mutedRoomDictionary objectForKey:selectedRoom.roomID];
    if(mutedExpired != nil){
        isMutedRoom = YES;
    }
    
    UIContextualAction *muteUnmuteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self.view endEditing:YES];
        completionHandler(YES);
        
        if(isMutedRoom) {
            [self callApiUnmuteRoom:selectedRoom.roomID];
        }
        else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            long oneHourinSecond = 3600;
            long oneHourInMili = oneHourinSecond * 1000;
            long oneDayInMili = (oneHourinSecond *24) * 1000;
            
            UIAlertAction *oneHourAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedStringFromTableInBundle(@"1 Hour", nil, [TAPUtil currentBundle], @"")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                long currentMilisecond = [TAPUtil currentTimeInMillis].longValue;
                
                currentMilisecond += oneHourInMili;
                
                [self callApiMuteRoom:selectedRoom.roomID expiredAt:@(currentMilisecond)];
                                           }];
            
            UIAlertAction *eightHoursAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedStringFromTableInBundle(@"8 Hours", nil, [TAPUtil currentBundle], @"")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                long currentMilisecond = [TAPUtil currentTimeInMillis].longValue;
                
                currentMilisecond += oneHourInMili * 8;
                
                [self callApiMuteRoom:selectedRoom.roomID expiredAt:@(currentMilisecond)];
               
                                           }];
            
            UIAlertAction *threeDaysAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedStringFromTableInBundle(@"3 Days", nil, [TAPUtil currentBundle], @"")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                long currentMilisecond = [TAPUtil currentTimeInMillis].longValue;
                
                currentMilisecond += oneDayInMili * 3;
                
                [self callApiMuteRoom:selectedRoom.roomID expiredAt:@(currentMilisecond)];
               
                                           }];
            
            UIAlertAction *alwaysAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedStringFromTableInBundle(@"Always", nil, [TAPUtil currentBundle], @"")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                long always = 0;
                [self callApiMuteRoom:selectedRoom.roomID expiredAt:@(always)];
                                           }];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction * action) {
                                               //Do some thing here
                                           }];
            
            UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetButtonLabelPrimary];
            UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
            
            [oneHourAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
            [eightHoursAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
            [threeDaysAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
            [alwaysAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
            [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
            
            [alertController addAction:oneHourAction];
            [alertController addAction:eightHoursAction];
            [alertController addAction:threeDaysAction];
            [alertController addAction:alwaysAction];
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }];
    
    UIContextualAction *deleteChatRoomAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self.view endEditing:YES];
        completionHandler(YES);
        
        
        NSString *deleteDescriptionString = NSLocalizedStringFromTableInBundle(@"Are you sure you want to delete this conversation?", nil, [TAPUtil currentBundle], @"");
        
        BOOL isPinnedRoom = NO;
        
        if([self.pinnedRoomIDs containsObject:selectedRoom.roomID]) {
            deleteDescriptionString = NSLocalizedStringFromTableInBundle(@"Are you sure you want to unpin and delete this conversation?", nil, [TAPUtil currentBundle], @"");
            isPinnedRoom = YES;
        }
    
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *deleteAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedStringFromTableInBundle(@"Delete for me", nil, [TAPUtil currentBundle], @"")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
            [self.setupRoomListView showSetupViewWithType:TAPSetupRoomListViewTypeLoading];
            [self.setupRoomListView showFirstLoadingView:YES withType:TAPSetupRoomListViewTypeLoading];
            
            if(isPinnedRoom) {
                [self.pinnedRoomIDs removeObject:selectedRoom.roomID];
                [TAPDataManager setPinnedRoomIDs:[self.pinnedRoomIDs copy]];
            }
            
            [self callApiDeleteRoom:selectedRoom.roomID];
            
           
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           //Do some thing here
            
        }];
        
        UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTitleLabel];
        UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
        
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:deleteDescriptionString];
        
        NSRange messageStringRange = [deleteDescriptionString rangeOfString:deleteDescriptionString];
        
        // Set background color, again for entire range
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                        value:actionSheetDefaultColor
                                        range:messageStringRange];
        UIFont *descriptionLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontImageDetailMessageStatus];
        NSDictionary *textAttributes = @{NSFontAttributeName: descriptionLabelFont,
                                     NSForegroundColorAttributeName: actionSheetDefaultColor};
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:deleteDescriptionString];
        
        NSMutableAttributedString *descriptionStringAtributed = [NSMutableAttributedString new];
        
        [attributedString addAttributes:textAttributes range:NSMakeRange(0, attributedString.length)];
        
        [descriptionStringAtributed appendAttributedString:attributedString];
        
       
        [deleteAction setValue:[TAPUtil getColor:@"E02E2E"] forKey:@"titleTextColor"];
        [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
        
        [alertController addAction:deleteAction];
        [alertController addAction:cancelAction];
        [alertController setValue:descriptionStringAtributed forKey:@"attributedMessage"];
        
        [self presentViewController:alertController animated:YES completion:nil];
      
        
    }];
    
    UIImage *muteUnmuteImageRendered = nil;
    if(!isMutedRoom){
        muteUnmuteImageRendered = [self createImageFromView:[self addedUIViewSwipeAction: [UIImage imageNamed:@"TAPIconMute" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] title:@"Mute"]];
    }
    else{
        muteUnmuteImageRendered = [self createImageFromView:[self addedUIViewSwipeAction: [UIImage imageNamed:@"TAPIconUnmute" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] title:@"Unmute"]];
    }
    
    muteUnmuteAction.image = muteUnmuteImageRendered;
    muteUnmuteAction.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorRoomListSwipeButtonBackground];
    
    UIImage *deleteChatroomImageRendered = [self createImageFromView:[self addedUIViewSwipeAction: [UIImage imageNamed:@"TAPIconTrashRoomList" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] title:@"Delete"]];
    
    deleteChatRoomAction.image = deleteChatroomImageRendered;
    deleteChatRoomAction.backgroundColor = [UIColor redColor];
    
    NSMutableArray *rowActionArray = [[NSMutableArray alloc] init];
    
    if([[TapUI sharedInstance] getMuteRoomListSwipeMenuEnabled]){
        [rowActionArray addObject:muteUnmuteAction];
    }
    
    if([[TapUI sharedInstance] getDeleteRoomListSwipeMenuEnabled]){
        [rowActionArray addObject:deleteChatRoomAction];
    }
    
    return [UISwipeActionsConfiguration configurationWithActions:rowActionArray];
}

#pragma mark TAPChatManager
- (void)chatManagerDidReceiveNewMessageOnOtherRoom:(TAPMessageModel *)message {
    [self processMessageFromSocket:message isNewMessage:YES];
}

- (void)chatManagerDidReceiveUpdateMessageOnOtherRoom:(TAPMessageModel *)message {
    [self processMessageFromSocket:message isNewMessage:NO];
}

- (void)chatManagerDidReceiveNewMessageInActiveRoom:(TAPMessageModel *)message {
    [self processMessageFromSocket:message isNewMessage:YES];
}

- (void)chatManagerDidReceiveUpdateRoom:(NSString *)eventName data:(NSDictionary *)data {
    NSDictionary *room = [data objectForKey:@"room"];
    NSDictionary *userDict = [data objectForKey:@"user"];
    NSString *roomID = [room objectForKey:@"roomID"];
    NSMutableArray *pinnedRoomIDs = [[TAPDataManager getPinnedRoomIDs] mutableCopy];
    NSMutableArray *blockedUserIDs = [[TAPDataManager getBlockedUserIDs] mutableCopy];
    if([eventName isEqualToString:@"room/clearChat"]) {
        TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
        
        if([pinnedRoomIDs containsObject:roomID]) {
            [pinnedRoomIDs removeObject:roomID];
            [TAPDataManager setPinnedRoomIDs:[pinnedRoomIDs copy]];
            self.pinnedRoomIDs = pinnedRoomIDs;
        }
        
        if(roomList != nil) {
            [self deleteChatRoomLocally:roomID];
        }
    }
    else if([eventName isEqualToString:@"room/pin"]) {
        if([pinnedRoomIDs containsObject:roomID]){
            return;
        }
        
        [pinnedRoomIDs insertObject:roomID atIndex:0];
        [TAPDataManager setPinnedRoomIDs:[pinnedRoomIDs copy]];
        self.pinnedRoomIDs = pinnedRoomIDs;
        [self showPinRoom:YES roomID:roomID];
    }
    else if([eventName isEqualToString:@"room/unpin"]) {
        if(![pinnedRoomIDs containsObject:roomID]){
            return;
        }
        
        [pinnedRoomIDs removeObject:roomID];
        [TAPDataManager setPinnedRoomIDs:[pinnedRoomIDs copy]];
        self.pinnedRoomIDs = pinnedRoomIDs;
        [self showPinRoom:NO roomID:roomID];
    }
    else if([eventName isEqualToString:@"room/mute"]) {
        NSNumber *expired = [self.mutedRoomDictionary objectForKey:roomID];
        
        if(expired != nil) {
            return;
        }
        
        NSNumber *expiredAt = [data objectForKey:@"expiredAt"];
        [self.mutedRoomDictionary setObject:expiredAt forKey:roomID];
        [TAPDataManager setMutedRoomDictionary:self.mutedRoomDictionary];
        TAPRoomModel *roomList = [self.roomListDictionary objectForKey:roomID];
        
        if(roomList == nil) {
            return;
        }
        
        NSInteger index = [self.roomListArray indexOfObject:roomList];
        NSIndexPath *messageIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        @try {
            [self.roomListView.roomListTableView performBatchUpdates:^{
                [self.roomListView.roomListTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:messageIndexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
                                                          completion:^(BOOL finished) {
                
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            [self.roomListView.roomListTableView reloadData];
        }
    }
    else if([eventName isEqualToString:@"room/unmute"]) {
        NSNumber *expired = [self.mutedRoomDictionary objectForKey:roomID];
        
        if(expired == nil) {
            return;
        }
        
        [self.mutedRoomDictionary removeObjectForKey:roomID];
        [TAPDataManager setMutedRoomDictionary:self.mutedRoomDictionary];
        TAPRoomModel *roomList = [self.roomListDictionary objectForKey:roomID];
        
        if(roomList == nil) {
            return;
        }
        
        NSInteger index = [self.roomListArray indexOfObject:roomList];
        NSIndexPath *messageIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        @try {
            [self.roomListView.roomListTableView performBatchUpdates:^{
                [self.roomListView.roomListTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:messageIndexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
                                                          completion:^(BOOL finished) {
                
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            [self.roomListView.roomListTableView reloadData];
        }
    }
    else if([eventName isEqualToString:@"user/block"]) {
        TAPUserModel *user = [TAPDataManager userModelFromDictionary:userDict];
        [blockedUserIDs addObject:user.userID];
        [TAPDataManager setBlockedUserIDs:blockedUserIDs];
    }
    else if([eventName isEqualToString:@"user/unblock"]) {
        TAPUserModel *user = [TAPDataManager userModelFromDictionary:userDict];
        if([blockedUserIDs containsObject:user.userID]) {
            [blockedUserIDs removeObject:user.userID];
        }
        [TAPDataManager setBlockedUserIDs:blockedUserIDs];
    }
}

- (void)chatManagerDidReceiveUpdateMessageInActiveRoom:(TAPMessageModel *)message {
    [self processMessageFromSocket:message isNewMessage:NO];
}

- (void)chatManagerDidSendNewMessage:(TAPMessageModel *)message {
    [self processMessageFromSocket:message isNewMessage:YES];
}

- (void)chatManagerDidReceiveStartTyping:(TAPTypingModel *)typing {
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:typing.roomID];
    
    NSInteger index = [self.roomListArray indexOfObject:roomList];
    TAPRoomListTableViewCell *cell = (TAPRoomListTableViewCell *)[self.roomListView.roomListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell setAsTyping:YES];
}

- (void)chatManagerDidReceiveStopTyping:(TAPTypingModel *)typing {
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:typing.roomID];

    NSInteger index = [self.roomListArray indexOfObject:roomList];
    TAPRoomListTableViewCell *cell = (TAPRoomListTableViewCell *)[self.roomListView.roomListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell setAsTyping:NO];
}

#pragma mark UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.navigationItem.leftBarButtonItem = nil;
    [UIView animateWithDuration:0.2f animations:^{
        self.leftBarView.alpha = 0.0f;
    }];
    
    BOOL showCloseButton = [[TapUI sharedInstance] getCloseRoomListButtonVisibleState];
    BOOL showMyAccountButton = [[TapUI sharedInstance] getMyAccountButtonInRoomListViewVisibleState];
    CGFloat searchBarViewX = 0.0f;
    if (showCloseButton && showMyAccountButton) {
        searchBarViewX = -54.0f;
    }
    if (showMyAccountButton) {
        searchBarViewX = -48.0f;
    }
    if (showCloseButton) {
        searchBarViewX = -32.0f;
    }
    [UIView animateWithDuration:0.2f animations:^{
        UIFont *searchBarCancelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchBarTextCancelButton];
        UIColor *searchBarCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarTextCancelButton];
        self.rightBarView.frame = CGRectMake(0.0f, 0.0f, 56.0f, 40.0f);
        self.rightBarButton.frame = CGRectMake(0.0f, 0.0f, 56.0f, 40.0f);
        [self.rightBarButton setTitleColor:searchBarCancelColor forState:UIControlStateNormal];
        self.rightBarButton.titleLabel.font = searchBarCancelFont;
        [self.rightBarButton setImage:nil forState:UIControlStateNormal];
        [self.rightBarButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        TapBarButtonItem *rightBarButtonItem = [[TapBarButtonItem alloc] initWithCustomView:self.rightBarButton];
        [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
        
        self.searchBarView.frame = CGRectMake(
            searchBarViewX,
            CGRectGetMinY(self.searchBarView.frame),
            CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(self.rightBarView.frame) - 36.0f,
            CGRectGetHeight(self.searchBarView.frame)
        );
    } completion:^(BOOL finished) {
        TAPSearchViewController *searchViewController = [[TAPSearchViewController alloc] init];
        searchViewController.delegate = self;
        UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
        searchNavigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:searchNavigationController animated:NO completion:^{
            [self setUpNavigationBar];
        }];
    }];
    
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    
    return YES;
}

#pragma mark TAPConnectionStatusViewController
- (void)connectionStatusViewControllerDelegateHeightChange:(CGFloat)height {
#ifdef DEBUG
//    DV Note - v1.0.18
//    28 Nov 2019 - Temporary comment to hide connecting, waiting for network, connected state for further changing UI flow
    NSLog(@"===============connectionStatusViewControllerDelegateHeightChange");
        [UIView animateWithDuration:0.2f animations:^{
            //change frame
            self.roomListView.roomListTableView.frame = CGRectMake(CGRectGetMinX(self.roomListView.roomListTableView.frame), height, CGRectGetWidth(self.roomListView.roomListTableView.frame), CGRectGetHeight(self.roomListView.roomListTableView.frame));
        }];
//    END DV Note
#endif

}

#pragma mark TAPAddNewChatViewController
- (void)addNewChatViewControllerShouldOpenNewRoomWithUser:(TAPUserModel *)user {
    [[TapUI sharedInstance] createRoomWithOtherUser:user success:^(TapUIChatViewController * _Nonnull chatViewController) {
        chatViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:YES];
    }];
}

- (void)chatViewControllerDidLeaveOrDeleteGroupWithRoom:(TAPRoomModel *)room {
    //Delete room & refresh the UI
    TAPRoomListModel *deletedRoomList = [self.roomListDictionary objectForKey:room.roomID];
    if (deletedRoomList != nil) {
        NSInteger deletedIndex = [self.roomListArray indexOfObject:deletedRoomList];
        [self.roomListArray removeObjectAtIndex:deletedIndex];
        [self.roomListDictionary removeObjectForKey:room.roomID];
        
        NSIndexPath *deletedIndexPath = [NSIndexPath indexPathForRow:deletedIndex inSection:0];
        [self.roomListView.roomListTableView deleteRowsAtIndexPaths:@[deletedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark TapUIChatViewController
- (void)chatViewControllerShouldUpdateUnreadBubbleForRoomID:(NSString *)roomID {
    NSInteger readCount = [[TAPMessageStatusManager sharedManager] getReadCountAndClearDictionaryForRoomID:roomID];
    NSInteger readMentionCount = [[TAPMessageStatusManager sharedManager] getReadMentionCountAndClearDictionaryForRoomID:roomID];
    
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
    roomList.numberOfUnreadMessages = roomList.numberOfUnreadMessages - readCount;
    roomList.numberOfUnreadMentions = roomList.numberOfUnreadMentions - readMentionCount;
    
    if(roomList.numberOfUnreadMessages < 0) {
        roomList.numberOfUnreadMessages = 0;
    }
    
    if(roomList.numberOfUnreadMentions < 0) {
        roomList.numberOfUnreadMentions = 0;
    }
    
    TAPMessageModel *selectedMessage = roomList.lastMessage;
    TAPRoomModel *selectedRoom = selectedMessage.room;
    roomList.isMarkedAsUnread = NO;
    [self.unreadRoomIDs removeObject:selectedRoom.roomID];
    [self callApiGetMarkedUnreadIDs];
    
    NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
    [self updateCellDataAtIndexPath:cellIndexPath updateUnreadBubble:YES];
}

- (void)chatViewControllerDidCloseWithRoomIDLastMessage:(NSString *)roomID lastMeesage:(TAPMessageModel *)lastMessage {
    BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:roomID];
    
    
    if(isSavedMessageRoom){
        if(lastMessage != nil) {
            TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
            
            roomList.lastMessage = lastMessage;
            
            NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
            [self updateCellDataAtIndexPath:cellIndexPath updateUnreadBubble:NO];
        }
        else {
            TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
            
            if(roomList != nil){
                NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
                NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
                
                [self.roomListDictionary removeObjectForKey:roomID];
                [self.roomListArray removeObject:roomList];
                
                
                @try {
                    [self.roomListView.roomListTableView beginUpdates];
                    
                    [self.roomListView.roomListTableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    [self.roomListView.roomListTableView endUpdates];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.reason);
                    [self.roomListView.roomListTableView reloadData];
                }
            }
            
        }
    }
}

- (void)chatViewControllerShouldClearUnreadBubbleForRoomID:(NSString *)roomID {
    //Force mark unread bubble and unread mention to 0
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
    TAPMessageModel *selectedMessage = roomList.lastMessage;
    TAPRoomModel *selectedRoom = selectedMessage.room;
    roomList.numberOfUnreadMessages = 0;
    roomList.numberOfUnreadMentions = 0;
    roomList.isMarkedAsUnread = NO;
    [self.unreadRoomIDs removeObject:selectedRoom.roomID];
    [self callApiGetMarkedUnreadIDs];
        
    NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
    [self updateCellDataAtIndexPath:cellIndexPath updateUnreadBubble:YES];
}

#pragma mark TAPSearchViewController
- (void)searchViewControllerDidTappedSearchCancelButton {
    [self checkAndUpdateActiveUserProfile];
    [UIView animateWithDuration:0.2f animations:^{
        self.leftBarView.alpha = 1.0f;
    }];
}

#pragma mark TAPMyAccountViewController
- (void)myAccountViewControllerDidTappedLogoutButton {
    [self.roomListArray removeAllObjects];
    [self.roomListDictionary removeAllObjects];
    [self.roomListView.roomListTableView reloadData];
}

- (void)myAccountViewControllerDoneChangingImageProfile {
    [self checkAndUpdateActiveUserProfile];
}

#pragma mark UIAdaptivePresentationController
- (void)presentationControllerWillDismiss:(UIPresentationController *)presentationController {
    [self checkAndUpdateActiveUserProfile];
}

#pragma mark - Custom Method

- (void)setUpNavigationBar {
    BOOL showCloseButton = [[TapUI sharedInstance] getCloseRoomListButtonVisibleState];
    BOOL showMyAccountButton = [[TapUI sharedInstance] getMyAccountButtonInRoomListViewVisibleState];
    BOOL showSearchBar = [[TapUI sharedInstance] getSearchBarInRoomListVisibleState];
    BOOL showNewChatButton = [[TapUI sharedInstance] getNewChatButtonInRoomListVisibleState];
    
    if (showCloseButton || showMyAccountButton) {
        if (showCloseButton) {
            UIImage *buttonImage = [UIImage imageNamed:@"TAPIconClose" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarCloseButton]];
            self.closeButton.frame = CGRectMake(-10.0f, 0.0f, 40.0f, 40.0f);
            [self.closeButton setImage:buttonImage forState:UIControlStateNormal];
            [self.closeButton addTarget:self action:@selector(closeButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
            [self.leftBarView addSubview:self.closeButton];
        }
        else {
            self.closeButton.frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
        
        if (showMyAccountButton) {
            CGFloat myAccountButtonX;
            if (showCloseButton) {
                myAccountButtonX = CGRectGetMaxX(self.closeButton.frame); + 4.0f;
            }
            else {
                myAccountButtonX = -4.0f;
            }
            
            self.myAccountButton.frame = CGRectMake(myAccountButtonX, 0.0f, 40.0f, 40.0f);

            self.leftBarInitialNameView.frame = CGRectMake(4.0f, 4.0f, 32.0f, 32.0f);
            self.leftBarInitialNameView.alpha = 0.0f;
            self.leftBarInitialNameView.layer.cornerRadius = CGRectGetHeight(self.leftBarInitialNameView.frame) / 2.0f;
            self.leftBarInitialNameView.clipsToBounds = YES;
            [self.myAccountButton addSubview:self.leftBarInitialNameView];
            
            UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarSmallLabel];
            UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarSmallLabel];
            self.leftBarInitialNameLabel.frame = CGRectMake(
                0.0f,
                0.0f,
                CGRectGetWidth(self.leftBarInitialNameView.frame),
                CGRectGetHeight(self.leftBarInitialNameView.frame)
            );
            self.leftBarInitialNameLabel.font = initialNameLabelFont;
            self.leftBarInitialNameLabel.textColor = initialNameLabelColor;
            self.leftBarInitialNameLabel.textAlignment = NSTextAlignmentCenter;
            self.leftBarInitialNameView.layer.cornerRadius = CGRectGetHeight(self.leftBarInitialNameView.frame) / 2.0f;
            self.leftBarInitialNameView.clipsToBounds = YES;
            [self.leftBarInitialNameView addSubview:self.leftBarInitialNameLabel];
            
            self.leftBarInitialNameButton.frame = self.leftBarInitialNameLabel.frame;
            self.leftBarInitialNameButton.alpha = 0.0f;
            self.leftBarInitialNameButton.userInteractionEnabled = NO;
            self.leftBarInitialNameButton.layer.cornerRadius = CGRectGetHeight(self.leftBarInitialNameButton.frame) / 2.0f;
            [self.leftBarInitialNameButton addTarget:self action:@selector(leftBarButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
            [self.leftBarInitialNameView addSubview:self.leftBarInitialNameButton];
            
            self.profileImageView.frame = self.leftBarInitialNameView.frame;
            self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds) / 2.0f;
            self.profileImageView.clipsToBounds = YES;
            self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.myAccountButton addSubview:self.profileImageView];
            [self.myAccountButton addTarget:self action:@selector(leftBarButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
            [self.leftBarView addSubview:self.myAccountButton];
        }
        else {
            self.myAccountButton.frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
        
        if (!showMyAccountButton) {
            self.leftBarView.frame = CGRectMake(
                0.0f,
                0.0f,
                CGRectGetMaxX(self.closeButton.frame),
                40.0f
            );
        }
        else {
            self.leftBarView.frame = CGRectMake(
                0.0f,
                0.0f,
                CGRectGetMaxX(self.myAccountButton.frame),
                40.0f
            );
        }
        
        TapBarButtonItem *leftBarButtonItem = [[TapBarButtonItem alloc] initWithCustomView:self.leftBarView];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    }
    else {
        self.leftBarView.frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        [self.navigationItem setLeftBarButtonItem:nil];
    }
        
    if (showNewChatButton) {
        //RightBarButton
        UIImage *rightBarImage = [UIImage imageNamed:@"TAPIconAddEditItem" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        rightBarImage = [rightBarImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconStartNewChatButton]];

        self.rightBarView.frame = CGRectMake(0.0f, 0.0f, 30.0f, 40.0f);
        self.rightBarButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
        [self.rightBarButton setImage:rightBarImage forState:UIControlStateNormal];
        [self.rightBarButton setTitle:nil forState:UIControlStateNormal];
        [self.rightBarButton addTarget:self action:@selector(rightBarButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.rightBarView addSubview:self.rightBarButton];
        TapBarButtonItem *rightBarButtonItem = [[TapBarButtonItem alloc] initWithCustomView:self.rightBarView];
        
        [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    }
    else {
        self.rightBarView.frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    if (showSearchBar) {
        //TitleView
        self.searchBarView.frame = CGRectMake(
            0.0f,
            0.0f,
            CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(self.leftBarView.frame) - CGRectGetWidth(self.rightBarView.frame) - 36.0f,
            36.0f
        );
        self.searchBarView.searchTextField.delegate = self;
        
        [self.navigationItem setTitleView:self.searchBarView];
        self.title = @"";
    }
    else {
        [self.navigationItem setTitleView:nil];
        self.title = NSLocalizedStringFromTableInBundle(@"Chats", nil, [TAPUtil currentBundle], @"");
    }
}

- (void)leftBarButtonDidTapped {
    id <TapUIRoomListDelegate> roomListDelegate = [TapUI sharedInstance].roomListDelegate;
    if ([roomListDelegate respondsToSelector:@selector(tapTalkAccountButtonTapped:currentShownNavigationController:)]) {
        [roomListDelegate tapTalkAccountButtonTapped:self currentShownNavigationController:self.navigationController];
    }
    else {
        TAPMyAccountViewController *myAccountViewController = [[TAPMyAccountViewController alloc] init];
        myAccountViewController.delegate = self;
        //myAccountViewController.presentationController.delegate = self;
        //UINavigationController *myAccountNavigationController = [[UINavigationController alloc] initWithRootViewController:myAccountViewController];
       // [self presentViewController:myAccountNavigationController animated:YES completion:nil];
        [self.navigationController pushViewController:myAccountViewController animated:YES];
    }
}

- (void)rightBarButtonDidTapped {
    id <TapUIRoomListDelegate> roomListDelegate = [TapUI sharedInstance].roomListDelegate;
    if ([roomListDelegate respondsToSelector:@selector(tapTalkNewChatButtonTapped:currentShownNavigationController:)]) {
        [roomListDelegate tapTalkNewChatButtonTapped:self currentShownNavigationController:self.navigationController];
    }
    else {
        [self openNewChatViewController];
    }
}

- (void)cancelButtonDidTapped {
//    [self.searchBarView.searchTextField resignFirstResponder];
//    self.searchBarView.searchTextField.text = @"";
}

- (void)closeButtonDidTapped {
    id <TapUIRoomListDelegate> roomListDelegate = [TapUI sharedInstance].roomListDelegate;
    if ([roomListDelegate respondsToSelector:@selector(tapTalkCloseRoomListButtonTapped:currentShownNavigationController:)]) {
        [roomListDelegate tapTalkCloseRoomListButtonTapped:self currentShownNavigationController:self.navigationController];
    }
    else {
        // FIXME:
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)mappingMessageArrayToRoomListArrayAndDictionary:(NSArray *)messageArray {
    if (_roomListArray != nil) {
        [self.roomListArray removeAllObjects];
        _roomListArray = nil;
    }
    
    if (_roomListDictionary != nil) {
        [self.roomListDictionary removeAllObjects];
        _roomListDictionary = nil;
    }
    
    _roomListDictionary = [[NSMutableDictionary alloc] init];
    _roomListArray = [[NSMutableArray alloc] init];
    
    NSArray *unreadRoomArray = [self.unreadRoomIDs copy];
    
    for (TAPMessageModel *message in messageArray) {
        TAPRoomModel *room = message.room;
        NSString *roomID = room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
        TAPRoomListModel *roomList = [TAPRoomListModel new];
        roomList.lastMessage = message;
        if([unreadRoomArray containsObject:room.roomID]){
            roomList.isMarkedAsUnread = YES;
        }
        
        [self insertRoomListToArrayAndDictionary:roomList atIndex:[self.roomListArray count]];
    }
    
    self.roomListArray = [[self sortPinnedRoomToTop:self.roomListArray] mutableCopy];
    
    [self getAndUpdateNumberOfUnreadToDelegate];
    
}

- (void)insertRoomListToArrayAndDictionary:(TAPRoomListModel *)roomList atIndex:(NSInteger)index {
    [self.roomListArray insertObject:roomList atIndex:index];
    [self.roomListDictionary setObject:roomList forKey:roomList.lastMessage.room.roomID];
}

- (NSArray *)sortPinnedRoomToTop:(NSArray *)resultArray {
    NSMutableArray *newArray = [resultArray mutableCopy];
    
    if(resultArray == nil || [resultArray count] == 0){
        return [newArray copy];
    }
    
    NSInteger pinIndexCounter = 0;
    NSArray *pinRoomIDs = [TAPDataManager getPinnedRoomIDs];
    
    if(pinRoomIDs == nil || [pinRoomIDs count] == 0){
        return resultArray;
    }
    
    for(TAPRoomListModel *roomList in resultArray) {
        TAPMessageModel *message = roomList.lastMessage;
        BOOL isPinRoom = [pinRoomIDs containsObject:message.room.roomID];
        if(pinIndexCounter >= [pinRoomIDs count]){
            break;
        }
        if(isPinRoom){
            //saved room
            //NSInteger pinnedIndex = [self.pinnedRoomIDs indexOfObject:message.room.roomID];
            [newArray removeObject:roomList];
            [newArray insertObject:roomList atIndex:pinIndexCounter];
            pinIndexCounter += 1;
        }
    }
    NSInteger counter = 0;
    
    for(NSString *roomID in pinRoomIDs) {
        
        TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
        
        if(roomList != nil) {
            TAPMessageModel *message = roomList.lastMessage;
            
            [newArray removeObject:roomList];
            [newArray insertObject:roomList atIndex:counter];
            
            counter += 1;
        }
    }
    
    return [newArray copy];
}

- (void)viewLoadedSequence {
    //Check if should show first loading view
    if ([TAPChatManager sharedManager].activeUser == nil) {
        [[TAPChatManager sharedManager] disconnect];
        
        if([TapTalk sharedInstance].isAuthenticated) {
    
            BOOL isDoneFirstSetup = [[NSUserDefaults standardUserDefaults] secureBoolForKey:TAP_PREFS_IS_DONE_FIRST_SETUP valid:nil];
            if (!isDoneFirstSetup) {
                [self.setupRoomListView showSetupViewWithType:TAPSetupRoomListViewTypeSettingUp];
                [self.setupRoomListView showFirstLoadingView:YES withType:TAPSetupRoomListViewTypeSettingUp];
            }
            
            id<TapTalkDelegate> tapTalkDelegate = [TapTalk sharedInstance].delegate;
            if ([tapTalkDelegate respondsToSelector:@selector(tapTalkRefreshTokenExpired)]) {
                [tapTalkDelegate tapTalkRefreshTokenExpired];
            }
        }
        else {
            //User not authenticated
            [self.setupRoomListView showSetupViewWithType:TAPSetupRoomListViewTypeFailed];
            [self.setupRoomListView showFirstLoadingView:YES withType:TAPSetupRoomListViewTypeFailed];
            
            NSLog(@"****************************************************\n\n\n");
            NSLog(@"TapTalk.io - Could not find active user data. Please make sure the client app is authenticated.");
            NSLog(@"\n\n\n****************************************************");
        }
        
        return; //User not logged in
    }
    
    if (self.isShouldNotLoadFromAPI) {
        //Load from database only
        [self reloadLocalDataAndUpdateUILogicAnimated:NO];
    }
    else {
        //Load from API and database
        _isShouldNotLoadFromAPI = YES;
        [self runFullRefreshSequence];
    }
}

- (void)runFullRefreshSequence {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //Save pending messages, new messages, waiting response messages, and waiting upload file messages to database
        [[TAPChatManager sharedManager] saveAllUnsentMessageInMainThread];
        
        [TAPDataManager getRoomListSuccess:^(NSArray *resultArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                BOOL isShouldAnimate = YES;
                
                if (self.roomListArray == nil || [self.roomListArray count] <= 0) {
                    isShouldAnimate = NO;
                }
                
                [self refreshViewAndQueryUnreadLogicWithMessageArray:resultArray animateReloadData:isShouldAnimate];
                
                [self fetchDataFromAPI];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideSetupViewWithDelay:0.0f];
            });
        }];
    });
    
    
}

- (void)fetchDataFromAPI {
    TAPUserModel *activeUser = [TAPChatManager sharedManager].activeUser;
    NSString *userID = activeUser.userID;
    userID = [TAPUtil nullToEmptyString:userID];
    
    BOOL isDoneFirstSetup = [[NSUserDefaults standardUserDefaults] secureBoolForKey:TAP_PREFS_IS_DONE_FIRST_SETUP valid:nil];
    if (!isDoneFirstSetup) {
        //First setup, run get room list and unread message
        [self showLoadingSetupView];
        [TAPDataManager callAPIGetMessageRoomListAndUnreadWithUserID:userID success:^(NSArray *messageArray) {
            //Call API Get Unread Room List
            [TAPDataManager callAPIGetMarkedAsUnreadChatRoomList:^(NSArray <NSString *> *roomIDs){
                //handle pref
                [self handleRommlistAndUnreadSuccess:messageArray];
            } failure:^(NSError *error) {
                [self handleRommlistAndUnreadSuccess:messageArray];
            }];
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isShouldNotLoadFromAPI = NO;
                [self.setupRoomListView showSetupViewWithType:TAPSetupRoomListViewTypeFailed];
                [self.setupRoomListView showFirstLoadingView:YES withType:TAPSetupRoomListViewTypeFailed];
            });
        }];
        
        return;
    }
    
    //Not first setup, get new and updated message
    [TAPDataManager callAPIGetNewAndUpdatedMessageSuccess:^(NSArray *messageArray) {
       
        [TAPDataManager callAPIGetMarkedAsUnreadChatRoomList:^(NSArray<NSString *> *roomIDs){
            //handle pref
            [self handleNewAndUpdatedSuccess:messageArray];
        } failure:^(NSError *error) {
            //handle pref
            [self handleNewAndUpdatedSuccess:messageArray];
        }];
        
    } failure:^(NSError *error) {
        self.isShouldNotLoadFromAPI = NO;
    }];
}

- (void)handleRommlistAndUnreadSuccess:(NSArray *)messageArray{
    //fetch pref
    self.unreadRoomIDs = [[TAPDataManager getUnreadRoomIDs] mutableCopy];

    self.pinnedRoomIDs = [[TAPDataManager getPinnedRoomIDs] mutableCopy];

    self.mutedRoomDictionary = [[TAPDataManager getMutedRoomDictionary] mutableCopy];
    
    if(self.mutedRoomDictionary == nil){
        _mutedRoomDictionary = [NSMutableDictionary dictionary];
    }
    
    self.counterOnSuccess = 0;
    
    self.isMuteRoomDataChange = NO;
    self.isPinRoomDataChange = NO;
    
    [TAPDataManager callAPIGetBlockedUserIDs:^(NSArray<NSString *> *blockedUserIDs) {
        [TAPDataManager setBlockedUserIDs:blockedUserIDs];
        
    } failure:^(NSError *error) {
        
    }];
    
    [TAPDataManager callAPIGetRoomIDsWithState:^(NSMutableArray<NSString *> *pinnedRoomIDsArray, NSMutableArray<TAPMutedRoomModel *> *mutedRoomModelArray, NSMutableArray<TAPClearedRoomModel *> *clearedRoomModelArray) {
           //muted room
           NSDictionary *mutedDictPref = [[TAPDataManager getMutedRoomDictionary] copy];
           [self.mutedRoomDictionary removeAllObjects];
           for(TAPMutedRoomModel *mutedRooom in mutedRoomModelArray) {
               [self.mutedRoomDictionary setObject:mutedRooom.expired forKey:mutedRooom.roomID];
               
               NSNumber *expiredPref = [mutedDictPref objectForKey:mutedRooom.roomID];
               if(expiredPref == nil) {
                   self.isMuteRoomDataChange = YES;
               }
               
           }
           
           if([self.mutedRoomDictionary count] != [mutedDictPref count]) {
               self.isMuteRoomDataChange = YES;
           }
           
           [TAPDataManager setMutedRoomDictionary:self.mutedRoomDictionary];
           
           //pinned room
           NSArray *pinRoomPref = [TAPDataManager getPinnedRoomIDs];
           if([pinRoomPref count] != [pinnedRoomIDsArray count]){
               self.isPinRoomDataChange = YES;
           }
           else {
               NSInteger counter = 0;
               for(NSString *roomID in pinnedRoomIDsArray) {
                   NSString *roomIDPref = [pinRoomPref objectAtIndex:counter];
                   if(![roomID isEqualToString:roomIDPref]) {
                       self.isPinRoomDataChange = YES;
                       break;
                   }
                   counter += 1;
               }
           }
           // Saved to preference
           [TAPDataManager setPinnedRoomIDs:pinnedRoomIDsArray];
           self.pinnedRoomIDs = [pinnedRoomIDsArray mutableCopy];
           NSInteger counter = 0;
           self.roomListArray = [[self sortPinnedRoomToTop:self.roomListArray] mutableCopy];
           
           if(self.isMuteRoomDataChange || self.isPinRoomDataChange) {
               [UIView performWithoutAnimation:^{ //Try to remove table view reload data flicker
                   [self.roomListView.roomListTableView reloadData];
                   [self.roomListView.roomListTableView layoutIfNeeded];
               }];
           }
           
           //cleared room
           long currentTime = [TAPUtil currentTimeInMillis].longValue;
           [TAPDataManager setLastRoomMessageDeleteTime:currentTime];
           
       } failure:^(NSError *error) {
           NSString *errorMessage = [error.userInfo objectForKey:@"message"];
           errorMessage = [TAPUtil nullToEmptyString:errorMessage];
           [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
       }];


    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setSecureBool:YES forKey:TAP_PREFS_IS_DONE_FIRST_SETUP];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    
    [self insertReloadMessageAndUpdateUILogicWithMessageArray:messageArray];
    
    
}

- (void)handleNewAndUpdatedSuccess:(NSArray *)messageArray{
    [self insertReloadMessageAndUpdateUILogicWithMessageArray:messageArray];
    
    //Update self profile
    [self checkAndUpdateActiveUserProfile];
    
    //Update leftover message status to delivered
    if ([messageArray count] != 0) {
        [[TAPMessageStatusManager sharedManager] filterAndUpdateBulkMessageStatusToDeliveredWithArray:messageArray];
    }
    
    //fetch pref
    self.unreadRoomIDs = [[TAPDataManager getUnreadRoomIDs] mutableCopy];

    self.pinnedRoomIDs = [[TAPDataManager getPinnedRoomIDs] mutableCopy];

    self.mutedRoomDictionary = [[TAPDataManager getMutedRoomDictionary] mutableCopy];
    
    if(self.mutedRoomDictionary == nil){
        _mutedRoomDictionary = [NSMutableDictionary dictionary];
    }
    
    self.isMuteRoomDataChange = NO;
    
    self.isPinRoomDataChange = NO;
    
    [TAPDataManager callAPIGetBlockedUserIDs:^(NSArray<NSString *> *blockedUserIDs) {
        [TAPDataManager setBlockedUserIDs:blockedUserIDs];
    } failure:^(NSError *error) {
        
    }];
    
    [TAPDataManager callAPIGetRoomIDsWithState:^(NSMutableArray<NSString *> *pinnedRoomIDsArray, NSMutableArray<TAPMutedRoomModel *> *mutedRoomModelArray, NSMutableArray<TAPClearedRoomModel *> *clearedRoomModelArray) {
            //muted room
            NSDictionary *mutedDictPref = [[TAPDataManager getMutedRoomDictionary] copy];
            [self.mutedRoomDictionary removeAllObjects];
            for(TAPMutedRoomModel *mutedRooom in mutedRoomModelArray) {
                [self.mutedRoomDictionary setObject:mutedRooom.expired forKey:mutedRooom.roomID];
                
                NSNumber *expiredPref = [mutedDictPref objectForKey:mutedRooom.roomID];
                if(expiredPref == nil) {
                    self.isMuteRoomDataChange = YES;
                }
                
            }
            
            if([self.mutedRoomDictionary count] != [mutedDictPref count]) {
                self.isMuteRoomDataChange = YES;
            }
            
            [TAPDataManager setMutedRoomDictionary:self.mutedRoomDictionary];
            
            //pinned room
            NSArray *pinRoomPref = [TAPDataManager getPinnedRoomIDs];
            if([pinRoomPref count] != [pinnedRoomIDsArray count]){
                self.isPinRoomDataChange = YES;
            }
            else {
                NSInteger counter = 0;
                for(NSString *roomID in pinnedRoomIDsArray) {
                    NSString *roomIDPref = [pinRoomPref objectAtIndex:counter];
                    if(![roomID isEqualToString:roomIDPref]) {
                        self.isPinRoomDataChange = YES;
                        break;
                    }
                    counter += 1;
                }
            }
            // Saved to preference
            [TAPDataManager setPinnedRoomIDs:pinnedRoomIDsArray];
            self.pinnedRoomIDs = [pinnedRoomIDsArray mutableCopy];
            NSInteger counter = 0;
            self.roomListArray = [[self sortPinnedRoomToTop:self.roomListArray] mutableCopy];
            
            if(self.isMuteRoomDataChange || self.isPinRoomDataChange) {
                [UIView performWithoutAnimation:^{ //Try to remove table view reload data flicker
                    [self.roomListView.roomListTableView reloadData];
                    [self.roomListView.roomListTableView layoutIfNeeded];
                }];
            }
            
            //cleared room
            long lastRoomDeleteTime = [TAPDataManager getLastRoomMessageDeleteTime];
            for(TAPClearedRoomModel *clearedModel in clearedRoomModelArray) {
                long clearTime = clearedModel.clearTime.longValue;
                if(clearTime > lastRoomDeleteTime) {
                    [self deleteChatRoomLocally:clearedModel.roomID];
                }
                else {
                    break;
                }
            }
            
        } failure:^(NSError *error) {
        }];


    
    
    //Delete physical files when isDeleted = 1 (message is deleted)
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (TAPMessageModel *message in messageArray) {
            if (message.isDeleted) {
                [TAPDataManager deletePhysicalFilesInBackgroundWithMessage:message success:^{
                    
                } failure:^(NSError *error) {
                    
                }];
            }
        }
    });
}

- (void)insertReloadMessageAndUpdateUILogicWithMessageArray:(NSArray *)messageArray {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //Save messages to database
        [TAPDataManager updateOrInsertDatabaseMessageInMainThreadWithData:messageArray success:^{
            //Get room list data from database and refresh UI
            [self reloadLocalDataAndUpdateUILogicAnimated:YES];
        } failure:^(NSError *error) {
            
        }];
    });
}

- (void)reloadLocalDataAndUpdateUILogicAnimated:(BOOL)animated {
    [TAPDataManager getRoomListSuccess:^(NSArray *resultArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.setupRoomListView showSetupViewWithType:TAPSetupRoomListViewTypeSuccess];
            [self hideSetupViewWithDelay:0.5f];
            [[NSUserDefaults standardUserDefaults] setSecureBool:YES forKey:TAP_PREFS_IS_DONE_FIRST_SETUP];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self refreshViewAndQueryUnreadLogicWithMessageArray:resultArray animateReloadData:animated];
        });
    } failure:^(NSError *error) {
        
    }];
}

- (void)refreshViewAndQueryUnreadLogicWithMessageArray:(NSArray *)messageArray animateReloadData:(BOOL)animateReloadData {
    BOOL isDoneFirstSetup = [[NSUserDefaults standardUserDefaults] secureBoolForKey:TAP_PREFS_IS_DONE_FIRST_SETUP valid:nil];
    
    if (!isDoneFirstSetup) {
        [self.roomListView showNoChatsView:NO];
    }
    else if ([self.roomListArray count] <= 0 && [messageArray count] <= 0) {
        //Show no chat view
        [self.roomListView showNoChatsView:YES];
    }
    else if ([self.roomListArray count] <= 0 && [messageArray count] > 0) {
        //Show data first before query unread message
        [self.roomListView showNoChatsView:NO];
        [self mappingMessageArrayToRoomListArrayAndDictionary:messageArray];
        
        [UIView performWithoutAnimation:^{ //Try to remove table view reload data flicker
            [self.roomListView.roomListTableView reloadData];
            [self.roomListView.roomListTableView layoutIfNeeded];
        }];
    }
    else {
        //Save old sequence to array and database
        NSMutableArray *oldRoomListArray = [NSMutableArray arrayWithArray:self.roomListArray];
        NSMutableDictionary *oldRoomListDictionary = [NSMutableDictionary dictionaryWithDictionary:self.roomListDictionary];
        
        [self.roomListView showNoChatsView:NO];
        [self mappingMessageArrayToRoomListArrayAndDictionary:messageArray];
        
        if (animateReloadData && self.isViewAppear) {
            //Update UI movement changes animation
            
            NSMutableArray *insertIndexArray = [NSMutableArray array];
            NSMutableArray *moveFromIndexArray = [NSMutableArray array];
            NSMutableArray *moveToIndexArray = [NSMutableArray array];
            
            for (NSInteger newIndex = 0; newIndex < [self.roomListArray count]; newIndex++) {
                TAPRoomListModel *newRoomList = [self.roomListArray objectAtIndex:newIndex];
                
                if (newRoomList == nil) {
                    continue;
                }
                
                TAPRoomListModel *oldRoomList = [oldRoomListDictionary objectForKey:newRoomList.lastMessage.room.roomID];
                
                if (oldRoomList == nil) {
                    //Room list not found in old data, so this is a new room
                    //Populate old data
                    [oldRoomListArray insertObject:newRoomList atIndex:newIndex];
                    [oldRoomListDictionary setObject:newRoomList forKey:newRoomList.lastMessage.room.roomID];
                    
                    [insertIndexArray addObject:[NSIndexPath indexPathForRow:newIndex inSection:0]];
                    //Insert to table view
//                    [self.roomListView.roomListTableView beginUpdates];
//                    [self.roomListView.roomListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//                    [self.roomListView.roomListTableView endUpdates];
                    continue;
                }
                
                NSInteger oldIndex = [oldRoomListArray indexOfObject:oldRoomList];
                
                if (newIndex == oldIndex) {
                    //Index is same, no need to move cell, just update data
                    [self updateCellDataAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] updateUnreadBubble:NO];
                    continue;
                }
                
                //Move cell to new index
                //Populate old data
                [oldRoomListArray removeObjectAtIndex:oldIndex];
                [oldRoomListArray insertObject:oldRoomList atIndex:newIndex];
                
                [moveFromIndexArray addObject:[NSString stringWithFormat:@"%ld", oldIndex]];
                [moveToIndexArray addObject:[NSString stringWithFormat:@"%ld", newIndex]];
                
                //Update table view
//                [self updateCellDataAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] updateUnreadBubble:NO];
//                [self.roomListView.roomListTableView beginUpdates];
//                [self.roomListView.roomListTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
//                [self.roomListView.roomListTableView endUpdates];
            }
            
            //Handle room insert
            if([insertIndexArray count] > 0) {
                @try {
                    [self.roomListView.roomListTableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [self.roomListView.roomListTableView insertRowsAtIndexPaths:insertIndexArray withRowAnimation:UITableViewRowAnimationAutomatic];
                    } completion:^(BOOL finished) {
                        [self.roomListView.roomListTableView scrollsToTop];
                    }];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.reason);
                    [self.roomListView.roomListTableView reloadData];
                }
            }
            
            //Handle room move
            if ([moveFromIndexArray count] > 0) {
                for (int count = 0; count < [moveFromIndexArray count]; count++) {
                    NSInteger oldIndex = [[moveFromIndexArray objectAtIndex:count] intValue];
                    NSInteger newIndex = [[moveToIndexArray objectAtIndex:count] intValue];
                    
                    [self updateCellDataAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] updateUnreadBubble:NO];
                    @try {
                        [self.roomListView.roomListTableView performBatchUpdates:^{
                            //changing beginUpdates and endUpdates with this because of deprecation
                            [self.roomListView.roomListTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
                        } completion:^(BOOL finished) {
                        }];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@", exception.reason);
                        [self.roomListView.roomListTableView reloadData];
                    }
                }
            }
            
            //Handle room deletion
            NSArray *loopedRoomListArray = [NSArray arrayWithArray:oldRoomListArray];
            for (NSInteger index = 0; index < [loopedRoomListArray count]; index++) {
                TAPRoomListModel *oldRoomList = [oldRoomListArray objectAtIndex:index];
                
                if (oldRoomList == nil) {
                    continue;
                }
                
                //Check if room list exist in new response
                TAPRoomListModel *newRoomList = [self.roomListDictionary objectForKey:oldRoomList.lastMessage.room.roomID];
                
                if (newRoomList == nil) {
                    //Data not exist, delete cell
                    NSInteger oldIndex = [oldRoomListArray indexOfObject:oldRoomList];
                    [oldRoomListArray removeObjectAtIndex:oldIndex];
                    @try {
                        [self.roomListView.roomListTableView performBatchUpdates:^{
                            //changing beginUpdates and endUpdates with this because of deprecation
                            [self.roomListView.roomListTableView deleteRowsAtIndexPaths:[NSIndexPath indexPathForRow:oldIndex inSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                        } completion:^(BOOL finished) {
                        }];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@", exception.reason);
                        [self.roomListView.roomListTableView reloadData];
                    }
                }
            }
        }
        else if (!self.isViewAppear) {
            //View not appear, just reload table view without animation
            [UIView performWithoutAnimation:^{ //Try to remove table view reload data flicker
                [self.roomListView.roomListTableView reloadData];
                [self.roomListView.roomListTableView layoutIfNeeded];
            }];
        }
    }
    
    //Query unread count and update UI
    [self queryNumberOfUnreadMessageInRoomListArrayInBackgroundAndUpdateUIAndReloadTableView:!animateReloadData];
}

- (void)queryNumberOfUnreadMessageInRoomListArrayInBackgroundAndUpdateUIAndReloadTableView:(BOOL)reloadTableView {
    NSArray *roomListLocalArray = [NSArray arrayWithArray:self.roomListArray];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        if ([roomListLocalArray count] == 0) {
            return;
        }
        
        _firstUnreadProcessCount = 0;
        _firstUnreadTotalCount = [roomListLocalArray count];
        NSMutableDictionary *unreadMentionDataDictionary = [NSMutableDictionary dictionary];
        
        for (TAPRoomListModel *roomList in roomListLocalArray) {
            TAPMessageModel *messageData = roomList.lastMessage;
            TAPRoomModel *roomData = messageData.room;
            NSString *roomIDString = roomData.roomID;
            roomIDString = [TAPUtil nullToEmptyString:roomIDString];
            
            NSString *usernameString = [TAPDataManager getActiveUser].username;
            usernameString = [TAPUtil nullToEmptyString:usernameString];
            NSString *activeUserID = [TAPDataManager getActiveUser].userID;
            activeUserID = [TAPUtil nullToEmptyString:activeUserID];
            
            [TAPDataManager getDatabaseUnreadMentionsInRoomWithUsername:usernameString roomID:roomIDString activeUserID:activeUserID success:^(NSArray *unreadMentionMessages) {
                NSInteger totalUnreadMention = [unreadMentionMessages count];
                [unreadMentionDataDictionary setObject:[NSNumber numberWithInteger:totalUnreadMention] forKey:roomIDString];
                
                [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:roomIDString activeUserID:[TAPChatManager sharedManager].activeUser.userID success:^(NSArray *unreadMessages) {
                    //Set number of unread messages to array and dictionary
                    NSInteger numberOfUnreadMessages = [unreadMessages count];
                    NSInteger numberOfUnreadMentions = [[unreadMentionDataDictionary objectForKey:roomIDString] integerValue];
                    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomIDString];
                    roomList.numberOfUnreadMessages = numberOfUnreadMessages;
                    roomList.numberOfUnreadMentions = numberOfUnreadMentions;
                    
                    if(roomList.numberOfUnreadMessages < 0) {
                        roomList.numberOfUnreadMessages = 0;
                    }
                    
                    if(roomList.numberOfUnreadMentions < 0) {
                        roomList.numberOfUnreadMentions = 0;
                    }
                    
                    _firstUnreadProcessCount++;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(self.firstUnreadProcessCount >= self.firstUnreadTotalCount) {
                            [self getAndUpdateNumberOfUnreadToDelegate];
                        }
                        
                        NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
                        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
                        [self updateCellDataAtIndexPath:cellIndexPath updateUnreadBubble:YES];
                    });
                } failure:^(NSError *error) {

                }];
            } failure:^(NSError *error) {
                
            }];
        }
        
        if (reloadTableView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView performWithoutAnimation:^{ //Try to remove table view reload data flicker
                    [self.roomListView.roomListTableView reloadData];
                    [self.roomListView.roomListTableView layoutIfNeeded];
                }];
            });
        }
    });
}

- (void)processMessageFromSocket:(TAPMessageModel *)message isNewMessage:(BOOL)isNewMessage {
    NSString *messageRoomID = message.room.roomID;
    //Check need to update user data or not
    if (message.type == TAPChatMessageTypeSystemMessage &&
        ([message.action isEqualToString:@"user/update"] ||
         [message.action isEqualToString:@"room/update"] ||
         [message.action isEqualToString:@"user/delete"])
    ) {
        [self checkUpdatedUserProfileWithMessage:message];
    }
    
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:messageRoomID];
    
    BOOL hasPinnedRoom = NO;
    BOOL isPinnedRoom = NO;
    NSInteger pinnedRoomListIndex = [self.pinnedRoomIDs indexOfObject:message.room.roomID];
    NSInteger unpinnedRoomListIndex = [self.pinnedRoomIDs count];
    
    NSInteger pinnedIndex = [self.pinnedRoomIDs indexOfObject:message.room.roomID];
    
    if([self.pinnedRoomIDs containsObject:message.room.roomID]){
        isPinnedRoom = YES;
    }
    
    if(self.pinnedRoomIDs.count > 0) {
        hasPinnedRoom = YES;
    }
    
    if (roomList != nil) {
        //Room is on the list
        TAPMessageModel *roomLastMessage = roomList.lastMessage;
        
        if (message.isHidden) {
            //Don't process last message that is hidden
            return;
        }
        
        if([roomLastMessage.created integerValue] > [message.created integerValue]) {
            //Don't process last message, current last message is newer that the incoming one
            return;
        }
        
        
        
        if ([roomLastMessage.localID isEqualToString:message.localID]) {
            //Last message is same, just updated, update the data only
            roomLastMessage.updated = message.updated;
            roomLastMessage.isDeleted = message.isDeleted;
            roomLastMessage.isSending = message.isSending;
            roomLastMessage.isFailedSend = message.isFailedSend;
            roomLastMessage.isRead = message.isRead;
            roomLastMessage.isDelivered = message.isDelivered;
            roomLastMessage.isHidden = message.isHidden;
            roomLastMessage.body = message.body;
            roomLastMessage.user.deleted = message.user.deleted;
            
            NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
            [self updateCellDataAtIndexPath:indexPath updateUnreadBubble:NO];
        }
        else {
            //Last message is different, move cell to top and update last message
            roomList.lastMessage = message;

            if (![message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && isNewMessage) {
                //Message from other recipient, increment number of unread message
                roomList.numberOfUnreadMessages++;
                
                BOOL hasMention = [TAPUtil isActiveUserMentionedWithMessage:message activeUser:[TAPDataManager getActiveUser]];
                if (hasMention) {
                    roomList.numberOfUnreadMentions++;
                }
            }
            
            NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];

            [self updateCellDataAtIndexPath:currentIndexPath updateUnreadBubble:YES];

            if (currentIndexPath != 0 && isNewMessage) {
                //Move cell to top
                if(hasPinnedRoom){
                    if(isPinnedRoom){
                        [self.roomListArray removeObject:roomList];
                        [self.roomListArray insertObject:roomList atIndex:pinnedRoomListIndex];
                    }
                    else{
                        [self.roomListArray removeObject:roomList];
                        [self.roomListArray insertObject:roomList atIndex:unpinnedRoomListIndex];
                    }
                }
                else{
                    [self.roomListArray removeObject:roomList];
                    [self.roomListArray insertObject:roomList atIndex:0];
                }
                
                @try {
                    [self.roomListView.roomListTableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        if(hasPinnedRoom){
                            if(isPinnedRoom){
                                [self.roomListView.roomListTableView moveRowAtIndexPath:currentIndexPath toIndexPath:[NSIndexPath indexPathForRow:pinnedRoomListIndex inSection:0]];
                            }
                            else{
                                [self.roomListView.roomListTableView moveRowAtIndexPath:currentIndexPath toIndexPath:[NSIndexPath indexPathForRow:unpinnedRoomListIndex inSection:0]];
                            }
                        }
                        else{
                            [self.roomListView.roomListTableView moveRowAtIndexPath:currentIndexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        }
                    } completion:^(BOOL finished) {
                    }];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.reason);
                    [self.roomListView.roomListTableView reloadData];
                }
            }
        }
    }
    else {
        //Room is not on the list, create new room
        TAPRoomListModel *newRoomList = [TAPRoomListModel new];
        newRoomList.lastMessage = message;
        
        if (message.isHidden) {
            //Don't process last message that is hidden
            return;
        }
        
        if (![message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
            //Message from other recipient, set unread as 1
            newRoomList.numberOfUnreadMessages = 1;
            
            BOOL hasMention = [TAPUtil isActiveUserMentionedWithMessage:message activeUser:[TAPDataManager getActiveUser]];
            if (hasMention) {
                newRoomList.numberOfUnreadMentions = 1;
            }
            else {
                newRoomList.numberOfUnreadMentions = 0;
            }
        }
        else {
            //Current user send new message, set unread to 0
            newRoomList.numberOfUnreadMessages = 0;
            newRoomList.numberOfUnreadMentions = 0;
        }
        
        if(hasPinnedRoom){
            if(isPinnedRoom){
                [self insertRoomListToArrayAndDictionary:newRoomList atIndex:pinnedRoomListIndex];
            }
            else{
                [self insertRoomListToArrayAndDictionary:newRoomList atIndex:unpinnedRoomListIndex];
            }
        }
        else{
            [self insertRoomListToArrayAndDictionary:newRoomList atIndex:0];
        }
        
        @try {
            [self.roomListView.roomListTableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                if(hasPinnedRoom){
                    if(isPinnedRoom){
                        [self.roomListView.roomListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pinnedRoomListIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    else{
                        [self.roomListView.roomListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:unpinnedRoomListIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }
                else{
                    [self.roomListView.roomListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                
            } completion:^(BOOL finished) {
                [self.roomListView showNoChatsView:NO];
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            [self.roomListView.roomListTableView reloadData];
        }
    }
    
    [self getAndUpdateNumberOfUnreadToDelegate];
}

- (void)updateCellDataAtIndexPath:(NSIndexPath *)indexPath updateUnreadBubble:(BOOL)updateUnreadBubble {
    if (indexPath.row >= [self.roomListArray count]) {
        return;
    }
    
    TAPRoomListTableViewCell *cell = [self.roomListView.roomListTableView cellForRowAtIndexPath:indexPath];
    TAPRoomListModel *roomList = [self.roomListArray objectAtIndex:indexPath.row];
    [cell setRoomListTableViewCellWithData:roomList updateUnreadBubble:updateUnreadBubble];
    
    //Check message draft
    NSString *draftMessage = [[TAPChatManager sharedManager] getMessageFromDraftWithRoomID:roomList.lastMessage.room.roomID];
    draftMessage = [TAPUtil nullToEmptyString:draftMessage];
    if (![draftMessage isEqualToString:@""]) {
        [cell showMessageDraftWithMessage:draftMessage];
    }
}

- (void)openNewChatViewController {
    TAPAddNewChatViewController *addNewChatViewController = [[TAPAddNewChatViewController alloc] init];
    addNewChatViewController.roomListViewController = self;
    addNewChatViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    addNewChatViewController.delegate = self;
    UINavigationController *addNewChatNavigationController = [[UINavigationController alloc] initWithRootViewController:addNewChatViewController];
    addNewChatNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:addNewChatNavigationController animated:YES completion:nil];
}

- (void)hideSetupViewWithDelay:(double)delayTime {
    [TAPUtil performBlock:^{
        [self.setupRoomListView showFirstLoadingView:NO withType:TAPSetupRoomListViewTypeSuccess];
    } afterDelay:delayTime];
}

- (void)reachabilityStatusChange:(NSNotification *)notification {
    if ([TapAFNetworkReachabilityManager sharedManager].reachable) {
        if (self.isNeedRefreshOnNetworkDown) {
            //Reload new data from API
            _isShouldNotLoadFromAPI = NO;
            [self viewLoadedSequence];
            
            _isNeedRefreshOnNetworkDown = NO;
            
        }
    }
    else {
        _isNeedRefreshOnNetworkDown = YES;
    }
}

- (void)showLoadingSetupView {
    [self.setupRoomListView showSetupViewWithType:TAPSetupRoomListViewTypeSettingUp];
    [self.setupRoomListView showFirstLoadingView:YES withType:TAPSetupRoomListViewTypeSettingUp];
}

- (void)clearAllData {
    [self.roomListArray removeAllObjects];
    [self.roomListDictionary removeAllObjects];
    [self.roomListView.roomListTableView reloadData];
}

- (void)getAndUpdateNumberOfUnreadToDelegate {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSInteger unreadRoomCount = 0;
        NSArray *unreadRoomArray = [self.unreadRoomIDs copy];
        for(TAPRoomListModel *roomList in self.roomListArray) {
            TAPMessageModel *selectedMessage = roomList.lastMessage;
            TAPRoomModel *room = selectedMessage.room;
            if(roomList.numberOfUnreadMessages > 0 || roomList.isMarkedAsUnread) {
                unreadRoomCount++;
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Send delegate to be used to client side, update to delegate after check unread database
            if ([[TapTalk sharedInstance].delegate respondsToSelector:@selector(tapTalkUnreadChatRoomBadgeCountUpdated:)]) {
                [[TapTalk sharedInstance].delegate tapTalkUnreadChatRoomBadgeCountUpdated:unreadRoomCount];
            }
        });
        
    });
}

- (void)checkUpdatedUserProfileWithMessage:(TAPMessageModel *)message {
    NSString *roomID = message.room.roomID;
    
    NSString *currentActiveUserID = [TAPChatManager sharedManager].activeUser.userID;
    currentActiveUserID = [TAPUtil nullToEmptyString:currentActiveUserID];
    NSString *constructedCurrentRoomID = [NSString stringWithFormat:@"%li-%li", (long)[currentActiveUserID integerValue], (long)[currentActiveUserID integerValue]];
    
    if ([roomID isEqualToString:constructedCurrentRoomID]) {
        //Update self profile
        [self checkAndUpdateActiveUserProfile];
    }
    else {
        //update user profile
        TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
        NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
        [self updateCellDataAtIndexPath:cellIndexPath updateUnreadBubble:NO];
    }
}

- (void)checkAndUpdateActiveUserProfile {
    NSString *profileImageURL = [TAPChatManager sharedManager].activeUser.imageURL.thumbnail;
    if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        TAPUserModel *currentActiveUser = [TAPDataManager getActiveUser];
        if (currentActiveUser.fullname == nil || [currentActiveUser.fullname isEqualToString:@""]) {
            self.leftBarInitialNameView.alpha = 0.0f;
            self.leftBarInitialNameButton.alpha = 0.0f;
            self.leftBarInitialNameButton.userInteractionEnabled = NO;
            self.profileImageView.alpha = 1.0f;
            self.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }
        else {
            self.leftBarInitialNameView.alpha = 1.0f;
            self.leftBarInitialNameButton.alpha = 1.0f;
            self.leftBarInitialNameButton.userInteractionEnabled = YES;
            self.profileImageView.alpha = 0.0f;
            self.leftBarInitialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:currentActiveUser.fullname];
            self.leftBarInitialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:currentActiveUser.fullname isGroup:NO];
        }
    }
    else {
        self.leftBarInitialNameView.alpha = 0.0f;
        self.leftBarInitialNameButton.alpha = 0.0f;
        self.leftBarInitialNameButton.userInteractionEnabled = NO;
        self.profileImageView.alpha = 1.0f;
        [self.profileImageView setImageWithURLString:profileImageURL];
    }
}

- (void)hideSetupView {
    [self.setupRoomListView showFirstLoadingView:NO withType:TAPSetupRoomListViewTypeSuccess];
}

- (UIImage *)createImageFromView:(UIView *)view {
    //AS NOTE - THIS METHOD CONVERT UIVIEW INTO UIIMAGE
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);

    [view.layer renderInContext:UIGraphicsGetCurrentContext()];;

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIView *)addedUIViewSwipeAction:(UIImage *)image title:(NSString *)title {
    //Create UIVIEW as you want view for Action Button
    NSString *descriptionActionString = @"";
    
    descriptionActionString = title;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 74.0f, 86.0f)];
    containerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *iconImageview = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(containerView.frame) - 32.0f) / 2.0f, (CGRectGetHeight(containerView.frame) - 32.0f - 6.0f - 16.0f) / 2.0f, 32.0f, 32.0f)];
    iconImageview.contentMode = UIViewContentModeScaleAspectFit;
    iconImageview.backgroundColor = [UIColor clearColor];
    iconImageview.image = image;
    [containerView addSubview:iconImageview];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(iconImageview.frame) + 6.0f, CGRectGetWidth(containerView.frame), 16.0f)];
    descriptionLabel.text = descriptionActionString;
    descriptionLabel.textColor = [UIColor whiteColor]; //AS NOTE - default 793DA0
    UIFont *descriptionLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListTime];
    //descriptionLabel.font = descriptionLabelFont;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:descriptionLabel];
    
    return containerView;
}

- (void)callApiDeleteRoom:(NSString *)roomID {
    if(roomID == nil) {
        return;
    }
    
    [TAPDataManager callAPIDeleteChatroom:@[roomID] success:^(NSArray *deletedRoomIDs){
        [self deleteChatRoomLocally:roomID];
    } failure:^(NSError *error){
        [self.setupRoomListView showFirstLoadingView:NO withType:TAPSetupRoomListViewTypeLoading];
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Delete Group" title:NSLocalizedStringFromTableInBundle(@"Oops! Failed to delete chat room", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

- (void)showPinRoom:(BOOL)isShow roomID:(NSString *)roomID {
    if(isShow) {
        TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
        
        if(roomList == nil) {
            return;
        }
        
        NSInteger index = [self.roomListArray indexOfObject:roomList];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        @try {
            [self.roomListView.roomListTableView performBatchUpdates:^{
                [self.roomListView.roomListTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }
                                                          completion:^(BOOL finished) {
                [self.roomListView.roomListTableView performBatchUpdates:^{
                    [self.roomListView.roomListTableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                }
                                                              completion:^(BOOL finished) {
                    [self.roomListView.roomListTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                    
                }];
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            [self.roomListView.roomListTableView reloadData];
        }
        
        [self.roomListArray removeObject:roomList];
        [self.roomListArray insertObject:roomList atIndex:0];
    }
    else {
        TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
        
        if(roomList == nil) {
            return;
        }
            
        NSInteger index = [self.roomListArray indexOfObject:roomList];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            
        @try {
            [self.roomListView.roomListTableView performBatchUpdates:^{
                [self.roomListView.roomListTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
                                                          completion:^(BOOL finished) {
                
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            [self.roomListView.roomListTableView reloadData];
        }
        
        TAPMessageModel *lastMessage = roomList.lastMessage;
        long lastMessageCreated = lastMessage.created.longValue;
        
        NSInteger unpinnedIndex = 0;
        NSInteger counter = -1;
        NSInteger pinnedCount = [self.pinnedRoomIDs count] - 1;
        for(TAPRoomListModel *roomList in self.roomListArray) {
            long created = roomList.lastMessage.created.longValue;
            if(counter > pinnedCount && lastMessageCreated > created){
                unpinnedIndex = counter;
                break;
            }
            counter += 1;
            unpinnedIndex = counter;
        }
        
        
        
        NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
        
        @try {
            [self.roomListView.roomListTableView performBatchUpdates:^{
                [self.roomListView.roomListTableView moveRowAtIndexPath:currentIndexPath toIndexPath:[NSIndexPath indexPathForRow:unpinnedIndex inSection:0]];
            }completion:^(BOOL finished) {
                
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            [self.roomListView.roomListTableView reloadData];
        }
        [self.roomListArray removeObject:roomList];
        [self.roomListArray insertObject:roomList atIndex:unpinnedIndex];
    }
}

- (void)deleteChatRoomLocally:(NSString *)roomID {
    [TAPDataManager deleteAllMessageAndPhysicalFilesInRoomWithRoomID:roomID success:^{
        TAPRoomListModel *deletedRoomList = [self.roomListDictionary objectForKey:roomID];
        if (deletedRoomList != nil) {
            NSInteger deletedIndex = [self.roomListArray indexOfObject:deletedRoomList];
            [self.roomListArray removeObjectAtIndex:deletedIndex];
            [self.roomListDictionary removeObjectForKey:roomID];
            
            NSIndexPath *deletedIndexPath = [NSIndexPath indexPathForRow:deletedIndex inSection:0];
            [self.roomListView.roomListTableView deleteRowsAtIndexPaths:@[deletedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.setupRoomListView showFirstLoadingView:NO withType:TAPSetupRoomListViewTypeLoading];
        long currentTime = [TAPUtil currentTimeInMillis].longValue;
        [TAPDataManager setLastRoomMessageDeleteTime:currentTime];
        //Throw view to room list
        [TAPUtil performBlock:^{
            
        } afterDelay:1.2f];
        
    } failure:^(NSError *error) {
        [self.setupRoomListView showFirstLoadingView:NO withType:TAPSetupRoomListViewTypeLoading];
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
      //  [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Delete Group Manually" title:NSLocalizedStringFromTableInBundle(@"Oops! Failed to delete chat room", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}


- (void)callApiGetMarkedUnreadIDs{
    [TAPDataManager callAPIGetMarkedAsUnreadChatRoomList:^(NSArray <NSString *> *roomIDs){
        // Saved to preference
    }
    failure:^(NSError *error) {
    }];
}

- (void)callApiMuteRoom:(NSString *)roomID expiredAt:(NSNumber *)expiredAt {
    [self.mutedRoomDictionary setObject:expiredAt forKey:roomID];
    [TAPDataManager setMutedRoomDictionary:self.mutedRoomDictionary];
    
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
    
    if(roomList == nil) {
        return;
    }
    
    NSInteger index = [self.roomListArray indexOfObject:roomList];
    NSIndexPath *messageIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    @try {
        [self.roomListView.roomListTableView performBatchUpdates:^{
            [self.roomListView.roomListTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:messageIndexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
                                                      completion:^(BOOL finished) {
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
        [self.roomListView.roomListTableView reloadData];
    }
    
    [TAPDataManager callAPIMuteRoom:@[roomID] expiredAt:expiredAt  success:^(NSArray *roomIDs) {
        
    } failure:^(NSError *error) {
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

- (void)callApiUnmuteRoom:(NSString *)roomID {
    [self.mutedRoomDictionary removeObjectForKey:roomID];
    [TAPDataManager setMutedRoomDictionary:self.mutedRoomDictionary];
    
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
    
    if(roomList == nil) {
        return;
    }
    
    NSInteger index = [self.roomListArray indexOfObject:roomList];
    NSIndexPath *messageIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    @try {
        [self.roomListView.roomListTableView performBatchUpdates:^{
            [self.roomListView.roomListTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:messageIndexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
                                                      completion:^(BOOL finished) {
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
        [self.roomListView.roomListTableView reloadData];
    }
    [TAPDataManager callAPIUnMuteRoom:@[roomID] success:^(NSArray *roomIDs) {
        
    } failure:^(NSError *error) {
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

@end
