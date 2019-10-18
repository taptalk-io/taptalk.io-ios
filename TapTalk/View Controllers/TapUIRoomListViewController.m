//
//  TapUIRoomListViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 6/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

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

#import <AFNetworking/AFNetworking.h>

@interface TapUIRoomListViewController () <UITableViewDelegate, UITableViewDataSource, TAPChatManagerDelegate, UITextFieldDelegate, TAPConnectionStatusViewControllerDelegate, TAPAddNewChatViewControllerDelegate, TAPChatViewControllerDelegate, UIViewControllerPreviewingDelegate, TAPSearchViewControllerDelegate, TAPMyAccountViewControllerDelegate, UIAdaptivePresentationControllerDelegate>
@property (strong, nonatomic) UIImage *navigationShadowImage;

@property (strong, nonatomic) TAPRoomListView *roomListView;
@property (strong, nonatomic) TAPSetupRoomListView *setupRoomListView;
@property (strong, nonatomic) TAPConnectionStatusViewController *connectionStatusViewController;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
@property (strong, nonatomic) TAPImageView *profileImageView;
@property (strong, nonatomic) UIButton *leftBarButton;
@property (strong, nonatomic) UIButton *rightBarButton;

@property (strong, nonatomic) NSMutableArray *roomListArray;
@property (strong, nonatomic) NSMutableDictionary *roomListDictionary;

@property (nonatomic) NSInteger firstUnreadProcessCount;
@property (nonatomic) NSInteger firstUnreadTotalCount;

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

@end

@implementation TapUIRoomListViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _roomListView = [[TAPRoomListView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.roomListView];
    
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
    
    _setupRoomListView = [[TAPSetupRoomListView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.navigationController.view addSubview:self.setupRoomListView];
    [self.navigationController.view bringSubviewToFront:self.setupRoomListView];
    
    [self.roomListView.startChatNoChatsButton addTarget:self action:@selector(openNewChatViewController) forControlEvents:UIControlEventTouchDown];
    
    //LeftBarButton
    _leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    
    _profileImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 30.0f, 30.0f)];
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds)/2.0f;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.leftBarButton addSubview:self.profileImageView];
    
    self.leftBarButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 8.0f);
    [self.leftBarButton addTarget:self action:@selector(leftBarButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBarButton];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    
    //RightBarButton
    UIImage *rightBarImage = [UIImage imageNamed:@"TAPIconAddEditItem" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    rightBarImage = [rightBarImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconStartNewChatButton]];

    _rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    self.rightBarButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -9.0f);
    [self.rightBarButton setImage:rightBarImage forState:UIControlStateNormal];
    [self.rightBarButton addTarget:self action:@selector(rightBarButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarButton];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    //TitleView
    _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 118.0f, 30.0f)];
    self.searchBarView.searchTextField.delegate = self;
    [self.navigationItem setTitleView:self.searchBarView];
    
    self.roomListView.roomListTableView.delegate = self;
    self.roomListView.roomListTableView.dataSource = self;
    self.roomListView.roomListTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    _roomListArray = [NSMutableArray array];
    _roomListDictionary = [NSMutableDictionary dictionary];
    
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
    
    NSString *profileImageURL = [TAPChatManager sharedManager].activeUser.imageURL.thumbnail;
    if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        self.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    else {
        [self.profileImageView setImageWithURLString:profileImageURL];
    }

    if ([self.lifecycleDelegate respondsToSelector:@selector(TapUIRoomListViewControllerViewWillAppear)]) {
        [self.lifecycleDelegate TapUIRoomListViewControllerViewWillAppear];
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        [cell setRoomListTableViewCellWithData:roomList updateUnreadBubble:NO];
        
        if (indexPath.row == [self.roomListArray count] - 1) {
            [cell setIsLastCellSeparator:YES];
        }
        else {
            [cell setIsLastCellSeparator:NO];
        }
        
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
        self.leftBarButton.alpha = 0.0f;
    }];
    
    self.searchBarView.frame = CGRectMake(0.0f, CGRectGetMinY(self.searchBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 55.0f - 73.0f - 16.0f, CGRectGetHeight(self.searchBarView.frame));
    
    [UIView animateWithDuration:0.2f animations:^{
        self.searchBarView.frame = CGRectMake(-55.0f, CGRectGetMinY(self.searchBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 73.0f - 16.0f, CGRectGetHeight(self.searchBarView.frame));

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
        
    } completion:^(BOOL finished) {
        TAPSearchViewController *searchViewController = [[TAPSearchViewController alloc] init];
        searchViewController.delegate = self;
        UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
        searchNavigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:searchNavigationController animated:NO completion:^{
            UIImage *rightBarImage = [UIImage imageNamed:@"TAPIconAddEditItem" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            rightBarImage = [rightBarImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconStartNewChatButton]];

            _rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 51.0f, 40.0f)];
            [self.rightBarButton setImage:rightBarImage forState:UIControlStateNormal];
            self.rightBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
            [self.rightBarButton addTarget:self action:@selector(rightBarButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarButton];
            [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
            
            UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBarButton];
            [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];

            self.searchBarView.frame = CGRectMake(0.0f, CGRectGetMinY(self.searchBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 55.0f - 73.0f - 16.0f, CGRectGetHeight(self.searchBarView.frame));
        }];
    }];
    
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    
    return YES;
}

#pragma mark TAPConnectionStatusViewController
- (void)connectionStatusViewControllerDelegateHeightChange:(CGFloat)height {
    [UIView animateWithDuration:0.2f animations:^{
        //change frame
        self.roomListView.roomListTableView.frame = CGRectMake(CGRectGetMinX(self.roomListView.roomListTableView.frame), height, CGRectGetWidth(self.roomListView.roomListTableView.frame), CGRectGetHeight(self.roomListView.roomListTableView.frame));
    }];
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
    if (deletedRoomList) {
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
    
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
    roomList.numberOfUnreadMessages = roomList.numberOfUnreadMessages - readCount;
    
    if(roomList.numberOfUnreadMessages < 0) {
        roomList.numberOfUnreadMessages = 0;
    }
    
    NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
    [self updateCellDataAtIndexPath:cellIndexPath updateUnreadBubble:YES];
}

- (void)chatViewControllerShouldClearUnreadBubbleForRoomID:(NSString *)roomID {
    //Force mark unread bubble to 0
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomID];
    roomList.numberOfUnreadMessages = 0;
        
    NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];
    [self updateCellDataAtIndexPath:cellIndexPath updateUnreadBubble:YES];

}

#pragma mark TAPSearchViewController
- (void)searchViewControllerDidTappedSearchCancelButton {
    [UIView animateWithDuration:0.2f animations:^{
        self.leftBarButton.alpha = 1.0f;
    }];
}

#pragma mark TAPMyAccountViewController
- (void)myAccountViewControllerDidTappedLogoutButton {
    [self.roomListArray removeAllObjects];
    [self.roomListDictionary removeAllObjects];
    [self.roomListView.roomListTableView reloadData];
}

- (void)myAccountViewControllerDoneChangingImageProfile {
    NSString *profileImageURL = [TAPChatManager sharedManager].activeUser.imageURL.thumbnail;
    if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        self.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    else {
        [self.profileImageView setImageWithURLString:profileImageURL];
    }
}

#pragma mark UIAdaptivePresentationController
- (void)presentationControllerWillDismiss:(UIPresentationController *)presentationController {
    NSString *profileImageURL = [TAPChatManager sharedManager].activeUser.imageURL.thumbnail;
    if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        self.profileImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    else {
        [self.profileImageView setImageWithURLString:profileImageURL];
    }
}

#pragma mark - Custom Method
- (void)leftBarButtonDidTapped {
    
    id <TapUIRoomListDelegate> roomListDelegate = [TapUI sharedInstance].roomListDelegate;
    if ([roomListDelegate respondsToSelector:@selector(tapTalkAccountButtonTapped:currentShownNavigationController:)]) {
        [roomListDelegate tapTalkAccountButtonTapped:self currentShownNavigationController:self.navigationController];
    }
    else {
        TAPMyAccountViewController *myAccountViewController = [[TAPMyAccountViewController alloc] init];
        myAccountViewController.delegate = self;
        myAccountViewController.presentationController.delegate = self;
        UINavigationController *myAccountNavigationController = [[UINavigationController alloc] initWithRootViewController:myAccountViewController];
        [self presentViewController:myAccountNavigationController animated:YES completion:nil];
    }
}

- (void)rightBarButtonDidTapped {
    [self openNewChatViewController];
}

- (void)cancelButtonDidTapped {
//    [self.searchBarView.searchTextField resignFirstResponder];
//    self.searchBarView.searchTextField.text = @"";
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
    
    for (TAPMessageModel *message in messageArray) {
        TAPRoomModel *room = message.room;
        NSString *roomID = room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
        TAPRoomListModel *roomList = [TAPRoomListModel new];
        roomList.lastMessage = message;
        
        [self insertRoomListToArrayAndDictionary:roomList atIndex:[self.roomListArray count]];
    }
}

- (void)insertRoomListToArrayAndDictionary:(TAPRoomListModel *)roomList atIndex:(NSInteger)index {
    [self.roomListArray insertObject:roomList atIndex:index];
    [self.roomListDictionary setObject:roomList forKey:roomList.lastMessage.room.roomID];
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
            
            NSLog(@"****************************************************/n/n/n");
            NSLog(@"TapTalk.io - Could not find active user data. Please make sure the client app is authenticated.");
            NSLog(@"/n/n/n****************************************************");
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
                
                //Call API Get Room List
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
        [TAPDataManager callAPIGetMessageRoomListAndUnreadWithUserID:userID success:^(NSArray *messageArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setSecureBool:YES forKey:TAP_PREFS_IS_DONE_FIRST_SETUP];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
            
            [self insertReloadMessageAndUpdateUILogicWithMessageArray:messageArray];
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.setupRoomListView showSetupViewWithType:TAPSetupRoomListViewTypeFailed];
                [self.setupRoomListView showFirstLoadingView:YES withType:TAPSetupRoomListViewTypeFailed];
            });
        }];
        
        return;
    }
    
    //Not first setup, get new and updated message
    [TAPDataManager callAPIGetNewAndUpdatedMessageSuccess:^(NSArray *messageArray) {
        [self insertReloadMessageAndUpdateUILogicWithMessageArray:messageArray];
        
        //Update leftover message status to delivered
        if ([messageArray count] != 0) {
            [[TAPMessageStatusManager sharedManager] filterAndUpdateBulkMessageStatusToDeliveredWithArray:messageArray];
        }
        
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
        
    } failure:^(NSError *error) {
        
    }];
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
                [self.roomListView.roomListTableView beginUpdates];
                [self.roomListView.roomListTableView insertRowsAtIndexPaths:insertIndexArray withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.roomListView.roomListTableView endUpdates];
                [self.roomListView.roomListTableView scrollsToTop];
            }
            
            //Handle room move
            if ([moveFromIndexArray count] > 0) {
                for (int count = 0; count < [moveFromIndexArray count]; count++) {
                    NSInteger oldIndex = [moveFromIndexArray objectAtIndex:count];
                    NSInteger newIndex = [moveToIndexArray objectAtIndex:count];

                    [self updateCellDataAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] updateUnreadBubble:NO];
                    [self.roomListView.roomListTableView beginUpdates];
                    [self.roomListView.roomListTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
                    [self.roomListView.roomListTableView endUpdates];
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
                    [self.roomListView.roomListTableView beginUpdates];
                    [self.roomListView.roomListTableView deleteRowsAtIndexPaths:[NSIndexPath indexPathForRow:oldIndex inSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.roomListView.roomListTableView endUpdates];
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
        
        for (TAPRoomListModel *roomList in roomListLocalArray) {
            TAPMessageModel *messageData = roomList.lastMessage;
            TAPRoomModel *roomData = messageData.room;
            NSString *roomIDString = roomData.roomID;
            roomIDString = [TAPUtil nullToEmptyString:roomIDString];
            
            [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:roomIDString activeUserID:[TAPChatManager sharedManager].activeUser.userID success:^(NSArray *unreadMessages) {
                //Set number of unread messages to array and dictionary
                NSInteger numberOfUnreadMessages = [unreadMessages count];
                TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:roomIDString];
                roomList.numberOfUnreadMessages = numberOfUnreadMessages;
                
                if(roomList.numberOfUnreadMessages < 0) {
                    roomList.numberOfUnreadMessages = 0;
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
    
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:messageRoomID];
    
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
            }

            NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];

            [self updateCellDataAtIndexPath:currentIndexPath updateUnreadBubble:YES];

            if (currentIndexPath != 0 && isNewMessage) {
                //Move cell to top
                [self.roomListArray removeObject:roomList];
                [self.roomListArray insertObject:roomList atIndex:0];
                [self.roomListView.roomListTableView beginUpdates];
                [self.roomListView.roomListTableView moveRowAtIndexPath:currentIndexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [self.roomListView.roomListTableView endUpdates];
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
        }
        else {
            //Current user send new message, set unread to 0
            newRoomList.numberOfUnreadMessages = 0;
        }
        
        [self insertRoomListToArrayAndDictionary:newRoomList atIndex:0];
        [self.roomListView.roomListTableView beginUpdates];
        [self.roomListView.roomListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.roomListView.roomListTableView endUpdates];
        [self.roomListView showNoChatsView:NO];
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
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
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

- (void)setMyAccountButtonInRoomListVisible:(BOOL)isVisible {
    self.isShowMyAccountView = isVisible;
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
        
        for(TAPRoomListModel *roomList in self.roomListArray) {
            if(roomList.numberOfUnreadMessages > 0) {
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

@end
