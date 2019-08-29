//
//  TAPAddNewContactViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 17/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPAddNewContactViewController.h"
#import "TAPAddNewContactView.h"
#import "TAPScanQRCodePopupView.h"
#import <AFNetworking/AFNetworking.h>

@interface TAPAddNewContactViewController () <TAPSearchBarViewDelegate>

@property (strong, nonatomic) TAPAddNewContactView *addNewContactView;
@property (strong, nonatomic) TAPScanQRCodePopupView *addContactPopupView;
@property (strong, nonatomic) TAPUserModel *searchedUser;
@property (strong, nonatomic) NSString *updatedString;

@property (nonatomic) BOOL wasFailedGetData;
@property (nonatomic) BOOL isTappedAddContactOrChatNowButton;

- (void)userChatNowButtonDidTapped;
- (void)addUserToContactButtonDidTapped;
- (void)expertChatNowButtonDidTapped;
- (void)addExpertToContactButtonDidTapped;

@end

@implementation TAPAddNewContactViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _addNewContactView = [[TAPAddNewContactView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    self.addNewContactView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
    [self.view addSubview:self.addNewContactView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"New Contact", @"");
    [self showCustomBackButton];
    
    [self.addNewContactView.userChatNowButton addTarget:self action:@selector(userChatNowButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.addNewContactView.expertChatNowButton addTarget:self action:@selector(expertChatNowButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.addNewContactView.addUserToContactButton addTarget:self action:@selector(addUserToContactButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.addNewContactView.addExpertToContactButton addTarget:self action:@selector(addExpertToContactButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.addNewContactView.searchBarView.delegate = self;
    [self.addNewContactView.searchBarView.searchTextField becomeFirstResponder];
    
    _wasFailedGetData = NO;
    _isTappedAddContactOrChatNowButton = NO;
    
    _addContactPopupView = [[TAPScanQRCodePopupView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.addContactPopupView.closePopupButton addTarget:self action:@selector(closePopupButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.addContactPopupView.chatNowButton addTarget:self action:@selector(userChatNowButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.addContactPopupView showPopupView:NO animated:NO];
    [self.navigationController.view addSubview:self.addContactPopupView];
    [self.navigationController.view bringSubviewToFront:self.addContactPopupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showNavigationSeparator:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
}

#pragma mark - Delegate
#pragma mark TAPSearchBar
- (BOOL)searchBarTextFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect searchBarViewFrame = self.addNewContactView.searchBarView.frame;
            searchBarViewFrame.size.width = CGRectGetWidth(self.addNewContactView.searchBarView.frame) - 70.0f;
            self.addNewContactView.searchBarView.frame = searchBarViewFrame;
            
            CGRect searchBarCancelButtonFrame = self.addNewContactView.searchBarCancelButton.frame;
            searchBarCancelButtonFrame.origin.x = CGRectGetMaxX(searchBarViewFrame) + 8.0f;
            searchBarCancelButtonFrame.size.width = 70.0f;
            self.addNewContactView.searchBarCancelButton.frame = searchBarCancelButtonFrame;
        } completion:^(BOOL finished) {
            //completion
        }];
    }
    return YES;
}

- (BOOL)searchBarTextFieldShouldReturn:(UITextField *)textField {
    [self.addNewContactView.searchBarView.searchTextField resignFirstResponder];
    return NO;
}

- (BOOL)searchBarTextFieldShouldClear:(UITextField *)textField {
    self.addNewContactView.searchBarView.searchTextField.text = @"";
    _searchedUser = nil;
    
    [self.addNewContactView setSearchViewLayoutWithType:LayoutTypeDefault];
    [self.addNewContactView showNoInternetView:NO];
    [self.addNewContactView isShowEmptyState:NO];
    [self.addNewContactView showLoading:NO];
    
    [UIView animateWithDuration:0.3f animations:^{
        CGRect searchBarViewFrame = self.addNewContactView.searchBarView.frame;
        searchBarViewFrame.size.width = CGRectGetWidth(self.addNewContactView.searchBarBackgroundView.frame) - 16.0f - 16.0f;
        self.addNewContactView.searchBarView.frame = searchBarViewFrame;
        [self.addNewContactView.searchBarView.searchTextField endEditing:YES];
        
        CGRect searchBarCancelButtonFrame = self.addNewContactView.searchBarCancelButton.frame;
        searchBarCancelButtonFrame.origin.x = CGRectGetMaxX(searchBarViewFrame) + 8.0f;
        searchBarCancelButtonFrame.size.width = 0.0f;
        self.addNewContactView.searchBarCancelButton.frame = searchBarCancelButtonFrame;
    } completion:^(BOOL finished) {
        //completion
    }];
    
    return NO;
}

- (BOOL)searchBarTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *trimmedNewString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self.addNewContactView setSearchViewLayoutWithType:LayoutTypeDefault];
    
    if (![trimmedNewString isEqualToString:@""]) {
        self.updatedString = newString;
        if ([textField.text isEqualToString:@""] || textField.text == nil) {
            [self reloadDataWithString];
        }
        else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadDataWithString) object:nil];
            [self performSelector:@selector(reloadDataWithString) withObject:nil afterDelay:0.3];
        }
    }
    else {
        textField.text = @"";
        
        @try {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadDataWithString) object:nil];
        } @catch (NSException *exception) {

        } @finally {
            
        }
        
        _wasFailedGetData = NO;
        _searchedUser = nil;
        
        [self.addNewContactView setSearchViewLayoutWithType:LayoutTypeDefault];
        [self.addNewContactView showNoInternetView:NO];
        [self.addNewContactView isShowEmptyState:NO];
        [self.addNewContactView showLoading:NO];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Custom Method
- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:popupIdentifier];
    
    if ([popupIdentifier isEqualToString:@"Error Add User To Contact"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Add Expert To Contact"]) {
        
    }
}

- (void)userChatNowButtonDidTapped {
    [self.addContactPopupView setPopupViewToDefault];
    [self.addContactPopupView showPopupView:NO animated:NO];
    
    if([self.delegate respondsToSelector:@selector(addNewContactViewControllerShouldOpenNewRoomWithUser:)]) {
        NSString *stringFromModel = [self.searchedUser toJSONString];
        [self.delegate addNewContactViewControllerShouldOpenNewRoomWithUser:[[TAPUserModel alloc] initWithString:stringFromModel error:nil]];
    }
    
//    [[TapUI sharedInstance] openRoomWithOtherUser:self.searchedUser fromNavigationController:self.navigationController];
//
//    //CS NOTE - Remove this VC in Navigation Stack to skip on pop
//    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
//    [navigationArray removeObject:self];
//    self.navigationController.viewControllers = navigationArray;
}

- (void)addUserToContactButtonDidTapped {
    
    NSString *currentUserID = [TAPDataManager getActiveUser].userID;
    currentUserID = [TAPUtil nullToEmptyString:currentUserID];
    NSString *searchedUserID = self.searchedUser.userID;
    
    if ([currentUserID isEqualToString:searchedUserID]) {
        //Add theirselves
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Add User To Contact"  title:NSLocalizedString(@"Error", @"") detailInformation:NSLocalizedString(@"Can't add yourself as contact",@"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }
    else {
        
        [TAPDataManager callAPIAddContactWithUserID:self.searchedUser.userID success:^(NSString *message, TAPUserModel *user) {
            [self.addNewContactView.searchBarView.searchTextField resignFirstResponder];
            [self.addContactPopupView setPopupInfoWithUserData:user isContact:NO];
            [self.addContactPopupView showPopupView:YES animated:YES];
            [self.addContactPopupView animateExpandingView];
            [self.addNewContactView setSearchUserButtonWithType:ButtonTypeChat];
            
            //Refresh Contact List From API
            [TAPDataManager callAPIGetContactList:^(NSArray *userArray) {
            } failure:^(NSError *error) {
            }];
            
        } failure:^(NSError *error) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }];
    }
}

- (void)expertChatNowButtonDidTapped {
    [self.addContactPopupView setPopupViewToDefault];
    [self.addContactPopupView showPopupView:NO animated:NO];
    
    if([self.delegate respondsToSelector:@selector(addNewContactViewControllerShouldOpenNewRoomWithUser:)]) {
#ifdef DEBUG
        NSLog(@"SEARCHED USER: %@", [self.searchedUser description]);
#endif
        
        NSString *stringFromModel = [self.searchedUser toJSONString];
        [self.delegate addNewContactViewControllerShouldOpenNewRoomWithUser:[[TAPUserModel alloc] initWithString:stringFromModel error:nil]];
    }
    
//    [[TapUI sharedInstance] openRoomWithOtherUser:self.searchedUser fromNavigationController:self.navigationController];
}

- (void)addExpertToContactButtonDidTapped {
    
    NSString *currentUserID = [TAPDataManager getActiveUser].userID;
    currentUserID = [TAPUtil nullToEmptyString:currentUserID];
    NSString *searchedUserID = self.searchedUser.userID;
    
    if ([currentUserID isEqualToString:searchedUserID]) {
        //Add theirselves
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Add Expert To Contact"  title:NSLocalizedString(@"Error", @"") detailInformation:NSLocalizedString(@"Can't add yourself as contact",@"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }
    else {
        [TAPDataManager callAPIAddContactWithUserID:self.searchedUser.userID success:^(NSString *message, TAPUserModel *user) {
            [self.addNewContactView.searchBarView.searchTextField resignFirstResponder];
            [self.addContactPopupView setPopupInfoWithUserData:user isContact:NO];
            [self.addContactPopupView showPopupView:YES animated:YES];
            [self.addContactPopupView animateExpandingView];
            [self.addNewContactView setSearchUserButtonWithType:ButtonTypeChat];
        
            //Refresh Contact List From API
            [TAPDataManager callAPIGetContactList:^(NSArray *userArray) {
            } failure:^(NSError *error) {
            }];
            
        } failure:^(NSError *error) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }];
    }
}

- (void)reloadDataWithString {

    if ([self.updatedString isEqualToString:@""]) {
        _wasFailedGetData = NO;
        _searchedUser = nil;
        
        [self.addNewContactView setSearchViewLayoutWithType:LayoutTypeDefault];
        [self.addNewContactView showNoInternetView:NO];
        [self.addNewContactView isShowEmptyState:NO];
        [self.addNewContactView showLoading:NO];
    }
    else {
        _wasFailedGetData = NO;
        
        [self.addNewContactView showLoading:YES];
        [TAPDataManager callAPIGetUserByUsername:self.updatedString success:^(TAPUserModel *user) {
            
            _searchedUser = user;
            
            [self.addNewContactView showNoInternetView:NO];
            [self.addNewContactView setContactWithUser:user];
            [self.addNewContactView isShowEmptyState:NO];
            [self.addNewContactView showLoading:NO];
            
        } failure:^(NSError *error) {
            //handle error
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
            NSInteger errorCode = error.code;
            if (errorCode == 40401) {
                //USER NOT FOUND
                [self.addNewContactView setSearchViewLayoutWithType:LayoutTypeDefault];
                [self.addNewContactView showNoInternetView:NO];
                _searchedUser = nil;
                [self.addNewContactView isShowEmptyState:YES];
                
                [self.addNewContactView showLoading:NO];
            }
            else if (errorCode == 199 || errorCode == 1009) {
                //NO INTERNET CONNECTION
                _wasFailedGetData = YES;
                _searchedUser = nil;
                
                [self.addNewContactView setSearchViewLayoutWithType:LayoutTypeDefault];
                [self.addNewContactView isShowEmptyState:NO];
                [self.addNewContactView showNoInternetView:YES];
            }
        }];
    }
}

- (void)reachabilityStatusChange:(NSNotification *)notification {
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        //CONNECTION AVAILABLE
        if (self.wasFailedGetData) {
            //RE-CALL API
            [self reloadDataWithString];
        }
    }
}

- (void)closePopupButtonDidTapped {
    [self.addContactPopupView setPopupViewToDefault];
    [self.addContactPopupView showPopupView:NO animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
