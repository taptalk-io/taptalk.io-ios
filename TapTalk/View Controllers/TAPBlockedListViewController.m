//
//  TAPBlockedListViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 14/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBlockedListViewController.h"
#import "TAPBlockedListView.h"
#import "TAPContactTableViewCell.h"

@interface TAPBlockedListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) TAPBlockedListView *blockedListView;
@property (strong, nonatomic) UIButton *rightNavigationButton;
@property (strong, nonatomic) UIBarButtonItem *barButtonRightItem;
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIImageView *loadingImageView;
@property (strong, nonatomic) NSMutableArray* blockedUserList;

@property (nonatomic) BOOL isEditState;
@property (strong, nonatomic) TAPUserModel* selectedContact;

@end

@implementation TAPBlockedListViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _blockedListView = [[TAPBlockedListView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.blockedListView];
    
    // Loading view
    _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.loadingView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.4f];
    self.loadingView.alpha = 0.0f;
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:self.loadingView];
    
    CGFloat loadingImageSize = 56.0f;
    _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.loadingView.frame) - loadingImageSize) / 2, (CGRectGetHeight(self.loadingView.frame) - loadingImageSize) / 2, loadingImageSize, loadingImageSize)];
    [self.loadingImageView setImage:[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
    self.loadingImageView.image = [self.loadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
    [self.loadingView addSubview:self.loadingImageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _blockedUserList = [[NSMutableArray alloc] init];
    _isEditState = NO;
    [self setupNavigationViewData];
    
    self.blockedListView.tableView.delegate = self;
    self.blockedListView.tableView.dataSource = self;
    self.blockedListView.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    // Do any additional setup after loading the view.
    
    self.blockedListView.emptyStateView.alpha = 0.0f;
    
    [TAPDataManager callAPIGetBlockedUserList:^(NSArray<TAPUserModel *> *blockedUserList) {
        self.blockedUserList = [blockedUserList mutableCopy];
        [self.blockedListView.tableView  reloadData];
        
        if(self.blockedUserList.count == 0) {
            self.blockedListView.emptyStateView.alpha = 1.0f;
        }
        else {
            self.blockedListView.emptyStateView.alpha = 0.0f;
        }
        
        if(self.blockedUserList.count == 0) {
            [self.rightNavigationButton setTitle:@"" forState:UIControlStateNormal];
            self.rightNavigationButton.userInteractionEnabled = NO;
            self.barButtonRightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavigationButton];
            [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
            
            return;
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TAPDataManager callAPIGetBlockedUserList:^(NSArray<TAPUserModel *> *blockedUserList) {
        self.blockedUserList = [blockedUserList mutableCopy];
        [self.blockedListView.tableView  reloadData];
        
        if(self.blockedUserList.count == 0) {
            self.blockedListView.emptyStateView.alpha = 1.0f;
        }
        else {
            self.blockedListView.emptyStateView.alpha = 0.0f;
        }
        
        if(self.blockedUserList.count == 0) {
            [self.rightNavigationButton setTitle:@"" forState:UIControlStateNormal];
            self.rightNavigationButton.userInteractionEnabled = NO;
            self.barButtonRightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavigationButton];
            [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
            
            return;
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewDidUnload {
    [self.loadingView removeFromSuperview];
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.blockedUserList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPContactTableViewCell";
        TAPContactTableViewCell *cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        TAPUserModel *user = [self.blockedUserList objectAtIndex:indexPath.row];
        [cell setContactTableViewCellWithUser:user]; //WK Temp
        [cell setContactTableViewCellType:TAPContactTableViewCellTypeDefault];
        [cell isRequireSelection:NO];
        
        if(self.isEditState) {
            [cell showBlockedContactIcon:YES];
        }
        else {
            [cell showBlockedContactIcon:NO];
        }
        
        
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeFull];
        }
        else {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeDefault];
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

#pragma mark - Delegate
#pragma mark TableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isEditState) {
        self.selectedContact = [self.blockedUserList objectAtIndex:indexPath.row];
        NSString *blockTitleString = [NSString stringWithFormat:@"Unblock %@?", self.selectedContact.fullname];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"unblock confirmation" title:blockTitleString detailInformation:@"Unblocking lets user send messages and calls from this contact . Are you sure you want to continue?" leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"Yes"];
    }
    else {
        TAPUserModel *user = [self.blockedUserList objectAtIndex:indexPath.row];
        TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:user];
        TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
        profileViewController.room = room;
        profileViewController.user = user;
        profileViewController.otherUserID = user.userID;
        profileViewController.delegate = self;
        profileViewController.tapProfileViewControllerType = TAPProfileViewControllerTypeDefault;
        if([TAPUtil isSaveMessageRoom:room.roomID]){
            profileViewController.tapProfileViewControllerType = TAPProfileViewControllerTypeSavedMessageProfile;
        }
        [self.navigationController pushViewController:profileViewController animated:YES];
       
    }
}

#pragma mark - Custom Method
- (void)rightNavigationButtonDidTapped {
    [self updateRightNavigation];
}

- (void)updateRightNavigation {
    if (self.blockedUserList.count == 0) {
        [self.rightNavigationButton setTitle:@"" forState:UIControlStateNormal];
        self.rightNavigationButton.userInteractionEnabled = NO;
        self.barButtonRightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavigationButton];
        [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
        
        return;
    }
    
    self.rightNavigationButton.userInteractionEnabled = YES;
    if (self.isEditState) {
        self.isEditState = NO;
        [self.rightNavigationButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else {
        self.isEditState = YES;
        [self.rightNavigationButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    [self.blockedListView.tableView reloadData];
    self.barButtonRightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavigationButton];
    [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
}

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    if ([popupIdentifier isEqualToString:@"unblock confirmation"]) {
        [self showLoading:YES];
        [[TAPCoreContactManager sharedManager] unblockUserWithUserID:self.selectedContact.userID success:^(TAPUserModel * _Nonnull unblockedUser) {
            
            NSMutableArray *blockedUserIDs = [[TAPDataManager getBlockedUserIDs] mutableCopy];
            
            if ([blockedUserIDs containsObject:self.selectedContact.userID]) {
                [blockedUserIDs removeObject:self.selectedContact.userID];
            }
            //[TAPDataManager setBlockedUserIDs:[blockedUserIDs copy]];
            
            [self.blockedUserList removeObject:self.selectedContact];
            
            [self.blockedListView.tableView  reloadData];
            
            if (self.blockedUserList.count == 0) {
                self.blockedListView.emptyStateView.alpha = 1.0f;
            }
            else {
                self.blockedListView.emptyStateView.alpha = 0.0f;
            }
            
            if (blockedUserIDs.count == 0) {
                [self updateRightNavigation];
            }
            
            [self showLoading:NO];
        } failure:^(NSError *error) {
            [self showLoading:NO];
        }];
    }
}

- (void)setupNavigationViewData {
    //This method is used to setup the title view of navigation bar, and also bar button view
    
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    self.title = @"Blocked Contacts";
    //Edit Button
    UIColor *buttonLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarButtonLabel];
    UIFont *buttonLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarButtonLabel];
    self.rightNavigationButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 33.0f, 24.0f)];
    [self.rightNavigationButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.rightNavigationButton setTitleColor:buttonLabelColor forState:UIControlStateNormal];
    self.rightNavigationButton.titleLabel.font = buttonLabelFont;
    self.barButtonRightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavigationButton];
    [self.rightNavigationButton addTarget:self action:@selector(rightNavigationButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
    
    
    //Back Bar Button
    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

- (void)showLoading:(BOOL)show {
    if (show) {
        if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] == nil) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.cumulative = YES;
            animation.removedOnCompletion = NO;
            [self.loadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
        [UIView animateWithDuration:0.1f animations:^{
            self.loadingView.alpha = 1.0f;
            [self.view layoutIfNeeded];
        }];
    }
    else {
        [UIView animateWithDuration:0.1f animations:^{
            self.loadingView.alpha = 0.0f;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if ([self.loadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                [self.loadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
            }
        }];
    }
}

@end
