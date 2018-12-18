//
//  TAPRoomListViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 6/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPRoomListViewController.h"
#import "TAPRoomListView.h"
#import "TAPAddNewChatViewController.h"
#import "TAPChatViewController.h"
#import "TAPSetupRoomListView.h"
#import "TAPRoomListTableViewCell.h"
#import "TAPRoomListModel.h"
#import "TAPConnectionStatusViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "TAPSearchViewController.h"


#import "TAPImagePreviewViewController.h" //DV Temp



@interface TAPRoomListViewController () <UITableViewDelegate, UITableViewDataSource, TAPChatManagerDelegate, UITextFieldDelegate, TAPConnectionStatusViewControllerDelegate, TAPAddNewChatViewControllerDelegate, TAPChatViewControllerDelegate>
@property (strong, nonatomic) UIImage *navigationShadowImage;

@property (strong, nonatomic) TAPRoomListView *roomListView;
@property (strong, nonatomic) TAPSetupRoomListView *setupRoomListView;
@property (strong, nonatomic) TAPConnectionStatusViewController *connectionStatusViewController;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
@property (strong, nonatomic) UIButton *leftBarButton;
@property (strong, nonatomic) UIButton *rightBarButton;

@property (strong, nonatomic) NSMutableArray *roomListArray;
@property (strong, nonatomic) NSMutableDictionary *roomListDictionary;

@property (nonatomic) BOOL isNeedRefreshOnNetworkDown;

- (void)mappingMessageArrayToRoomListArrayAndDictionary:(NSArray *)messageArray;
- (void)insertRoomListToArrayAndDictionary:(TAPRoomListModel *)roomList atIndex:(NSInteger)index;
- (void)runFullRefreshSequence;
- (void)fetchDataFromAPI;
- (void)insertReloadMessageAndUpdateUILogicWithMessageArray:(NSArray *)messageArray;
- (void)reloadLocalDataAndUpdateUILogicAnimated:(BOOL)animated;
- (void)refreshViewAndQueryUnreadLogicWithMessageArray:(NSArray *)messageArray animateReloadData:(BOOL)animateReloadData;
- (void)queryNumberOfUnreadMessageInRoomListArrayInBackgroundAndUpdateUIAndReloadTableView:(BOOL)reloadTableView;
- (void)processMessageFromSocket:(TAPMessageModel *)message;
- (void)updateCellDataAtIndexPath:(NSIndexPath *)indexPath updateUnreadBubble:(BOOL)updateUnreadBubble;

@end

@implementation TAPRoomListViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _roomListView = [[TAPRoomListView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.roomListView];
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
    
    self.title = NSLocalizedString(@"Chats", @"");
    
    //LeftBarButton
    _leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [self.leftBarButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.leftBarButton setTitleColor:[TAPUtil getColor:TAP_COLOR_GREENBLUE_93] forState:UIControlStateNormal];
    self.leftBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 18.0f);
    self.leftBarButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:17.0f];
    [self.leftBarButton addTarget:self action:@selector(editButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBarButton];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    
    //RightBarButton
    UIImage *rightBarImage = [UIImage imageNamed:@"TAPIconAddChat" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];;
    _rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    [self.rightBarButton setImage:rightBarImage forState:UIControlStateNormal];
    self.rightBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
    [self.rightBarButton addTarget:self action:@selector(addButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarButton];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    //TitleView
    _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 55.0f - 73.0f - 18.0f, 30.0f)];
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
    
    //View appear sequence
    [self viewLoadedSequence];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isViewAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isViewAppear = NO;
    
    if (self.searchBarView.searchTextField.isFirstResponder) {
        [self.searchBarView.searchTextField resignFirstResponder];
    }
}

- (void)dealloc {
    [[TAPChatManager sharedManager] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        return 70.0f;
    }
    
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPRoomListTableViewCell";
        
        TAPRoomListTableViewCell *cell = [[TAPRoomListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        TAPRoomListModel *roomList = [self.roomListArray objectAtIndex:indexPath.row];
        [cell setRoomListTableViewCellWithData:roomList updateUnreadBubble:NO];
        [cell setAsTyping:[[TAPChatManager sharedManager] checkIsTypingWithRoomID:roomList.lastMessage.room.roomID]];
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

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *readRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"Read Did Tapped");
    }];
    readRowAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TAPIconSlideActionRead" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
    
    UITableViewRowAction *muteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"Mute Did Tapped");
    }];
    muteRowAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TAPIconSlideActionMute" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"Delete Did Tapped");
    }];
    deleteRowAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TAPIconSlideActionDelete" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
    
    NSArray<UITableViewRowAction *> *rowActionArray = [NSArray arrayWithObjects:deleteRowAction, muteRowAction, readRowAction, nil];
    return rowActionArray;
}


#pragma mark - Delegate
#pragma mark TableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//        UserModel *selectedUser = [self.contactListDictionary objectForKey:selectedUsername];
    TAPRoomListModel *selectedRoomList = [self.roomListArray objectAtIndex:indexPath.row];
    TAPMessageModel *selectedMessage = selectedRoomList.lastMessage;
    TAPRoomModel *selectedRoom = selectedMessage.room;
    [[TapTalk sharedInstance] openRoomWithRoom:selectedRoom fromNavigationController:self.navigationController animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchBarView.searchTextField.isFirstResponder) {
        [self.searchBarView.searchTextField resignFirstResponder];
    }
}

#pragma mark TAPChatManager
- (void)chatManagerDidReceiveNewMessageOnOtherRoom:(TAPMessageModel *)message {
    [self processMessageFromSocket:message];
}

- (void)chatManagerDidReceiveUpdateMessageOnOtherRoom:(TAPMessageModel *)message {
    [self processMessageFromSocket:message];
}

- (void)chatManagerDidReceiveDeleteMessageOnOtherRoom:(TAPMessageModel *)message {
    [self processMessageFromSocket:message];
}

- (void)chatManagerDidReceiveNewMessageInActiveRoom:(TAPMessageModel *)message {
    [self processMessageFromSocket:message];
}

- (void)chatManagerDidReceiveUpdateMessageInActiveRoom:(TAPMessageModel *)message {
    [self processMessageFromSocket:message];
}

- (void)chatManagerDidReceiveDeleteMessageInActiveRoom:(TAPMessageModel *)message {
    [self processMessageFromSocket:message];
}

- (void)chatManagerDidSendNewMessage:(TAPMessageModel *)message {
    [self processMessageFromSocket:message];
}

- (void)chatManagerDidReceiveStartTyping:(TAPTypingModel *)typing {
    //    NSLog(@"USER %@ IS START TYPING", user.fullname); //DV Temp
    TAPRoomModel *room = [self.roomListDictionary objectForKey:typing.roomID];
    NSInteger index = [self.roomListArray indexOfObject:room];
    TAPRoomListTableViewCell *cell = (TAPRoomListTableViewCell *)[self.roomListView.roomListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell setAsTyping:YES];
}

- (void)chatManagerDidReceiveStopTyping:(TAPTypingModel *)typing {
    //    NSLog(@"USER %@ IS STOP TYPING", user.fullname); //DV Temp
    TAPRoomModel *room = [self.roomListDictionary objectForKey:typing.roomID];
    NSInteger index = [self.roomListArray indexOfObject:room];
    TAPRoomListTableViewCell *cell = (TAPRoomListTableViewCell *)[self.roomListView.roomListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell setAsTyping:NO];
}

#pragma mark UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.navigationItem.leftBarButtonItem = nil;
    self.searchBarView.frame = CGRectMake(0.0f, CGRectGetMinY(self.searchBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 55.0f - 73.0f - 18.0f, CGRectGetHeight(self.searchBarView.frame));
    
    [UIView animateWithDuration:0.2f animations:^{
        self.searchBarView.frame = CGRectMake(-55.0f, CGRectGetMinY(self.searchBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 73.0f - 18.0f, CGRectGetHeight(self.searchBarView.frame));
        
        _rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        [self.rightBarButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.rightBarButton setTitleColor:[TAPUtil getColor:TAP_COLOR_GREENBLUE_93] forState:UIControlStateNormal];
        self.rightBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        self.rightBarButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:17.0f];
        [self.rightBarButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarButton];
        [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    } completion:^(BOOL finished) {
        TAPSearchViewController *searchViewController = [[TAPSearchViewController alloc] init];
        UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
        searchNavigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:searchNavigationController animated:NO completion:^{
            UIImage *rightBarImage = [UIImage imageNamed:@"TAPIconAddChat" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];;
            _rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
            [self.rightBarButton setImage:rightBarImage forState:UIControlStateNormal];
            self.rightBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
            [self.rightBarButton addTarget:self action:@selector(addButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarButton];
            [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
            
            UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBarButton];
            [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
            self.searchBarView.frame = CGRectMake(-55.0f, CGRectGetMinY(self.searchBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 73.0f - 18.0f, CGRectGetHeight(self.searchBarView.frame));
            
            self.searchBarView.frame = CGRectMake(0.0f, CGRectGetMinY(self.searchBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 55.0f - 73.0f - 18.0f, CGRectGetHeight(self.searchBarView.frame));
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
    [[TapTalk sharedInstance] openRoomWithOtherUser:user fromNavigationController:self.navigationController];
}

#pragma mark TAPChatViewController
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

#pragma mark - Custom Method
- (void)editButtonDidTapped {
    NSLog(@"Edit");
    
    //DV Temp
//    TAPImagePreviewViewController *imagePreviewViewController = [[TAPImagePreviewViewController alloc] init];
//    UINavigationController *imagePreviewNavigationController = [[UINavigationController alloc] initWithRootViewController:imagePreviewViewController];
//    [self.navigationController presentViewController:imagePreviewNavigationController animated:YES completion:nil];
    //END DV Temp
}

- (void)addButtonDidTapped {
    TAPAddNewChatViewController *addNewChatViewController = [[TAPAddNewChatViewController alloc] init];
    addNewChatViewController.delegate = self;
    UINavigationController *addNewChatNavigationController = [[UINavigationController alloc] initWithRootViewController:addNewChatViewController];
    [self presentViewController:addNewChatNavigationController animated:YES completion:nil];
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
    BOOL isDoneFirstSetup = [[NSUserDefaults standardUserDefaults] secureBoolForKey:TAP_PREFS_IS_DONE_FIRST_SETUP valid:nil];
    if (!isDoneFirstSetup) {
        [self.setupRoomListView showFirstLoadingView:YES];
    }
    
    if ([TAPChatManager sharedManager].activeUser == nil) {
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
        //Save pending messages, new messages, and waiting response messages to database
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
                [self.setupRoomListView showFirstLoadingView:NO];
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
                [self.setupRoomListView showFirstLoadingView:NO];
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
            [self.setupRoomListView showFirstLoadingView:NO];
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
                    
                    //Insert to table view
                    [self.roomListView.roomListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
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
                
                //Update table view
                [self updateCellDataAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] updateUnreadBubble:NO];
                [self.roomListView.roomListTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
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
                    
                    [self.roomListView.roomListTableView deleteRowsAtIndexPaths:[NSIndexPath indexPathForRow:oldIndex inSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *roomListLocalArray = [NSArray arrayWithArray:self.roomListArray];
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
                
                dispatch_async(dispatch_get_main_queue(), ^{
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

- (void)processMessageFromSocket:(TAPMessageModel *)message {
    NSString *messageRoomID = message.room.roomID;
    
    TAPRoomListModel *roomList = [self.roomListDictionary objectForKey:messageRoomID];
    
    if (roomList != nil) {
        //Room is on the list
        TAPMessageModel *roomLastMessage = roomList.lastMessage;
        
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

            if (![message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //Message from other recipient, increment number of unread message
                roomList.numberOfUnreadMessages++;
            }

            NSInteger cellRow = [self.roomListArray indexOfObject:roomList];
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:cellRow inSection:0];

            [self updateCellDataAtIndexPath:currentIndexPath updateUnreadBubble:YES];

            if (currentIndexPath != 0) {
                //Move cell to top
                [self.roomListArray removeObject:roomList];
                [self.roomListArray insertObject:roomList atIndex:0];

                [self.roomListView.roomListTableView moveRowAtIndexPath:currentIndexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
        }
    }
    else {
        //Room is not on the list, create new room
        TAPRoomListModel *newRoomList = [TAPRoomListModel new];
        newRoomList.lastMessage = message;
        
        if (![message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
            //Message from other recipient, set unread as 1
            newRoomList.numberOfUnreadMessages = 1;
        }
        else {
            //Current user send new message, set unread to 0
            newRoomList.numberOfUnreadMessages = 0;
        }
        
        [self insertRoomListToArrayAndDictionary:newRoomList atIndex:0];
        [self.roomListView.roomListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.roomListView showNoChatsView:NO];
    }
}

- (void)updateCellDataAtIndexPath:(NSIndexPath *)indexPath updateUnreadBubble:(BOOL)updateUnreadBubble {
    if (indexPath.row >= [self.roomListArray count]) {
        return;
    }
    
    TAPRoomListTableViewCell *cell = [self.roomListView.roomListTableView cellForRowAtIndexPath:indexPath];
    TAPRoomListModel *roomList = [self.roomListArray objectAtIndex:indexPath.row];
    [cell setRoomListTableViewCellWithData:roomList updateUnreadBubble:updateUnreadBubble];
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

@end
