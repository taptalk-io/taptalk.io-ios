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

@interface TAPAddNewContactViewController () <UITextFieldDelegate>

@property (strong, nonatomic) TAPAddNewContactView *addNewContactView;
@property (strong, nonatomic) TAPScanQRCodePopupView *addContactPopupView;
@property (strong, nonatomic) TAPUserModel *searchedUser;
@property (strong, nonatomic) NSString *updatedString;

@property (nonatomic) BOOL wasFailedGetData;

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
    self.addNewContactView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
    [self.view addSubview:self.addNewContactView];
    
//    - (void)isShowDefaultLabel:(BOOL)isShow;
//    - (void)isShowExpertVerifiedLogo:(BOOL)isShow;
//    - (void)setSearchViewLayoutWithType:(NSInteger)type;
//    - (void)setSearchExpertButtonWithType:(NSInteger)type;
//    - (void)setSearchUserButtonWithType:(NSInteger)type;
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
    
    self.addNewContactView.searchBarView.searchTextField.delegate = self;
    [self.addNewContactView.searchBarView.searchTextField becomeFirstResponder];
    
    _wasFailedGetData = NO;
    
    _addContactPopupView = [[TAPScanQRCodePopupView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.addContactPopupView.closePopupButton addTarget:self action:@selector(closePopupButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.addContactPopupView.chatNowButton addTarget:self action:@selector(userChatNowButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.addContactPopupView showPopupView:NO animated:NO];
    [self.navigationController.view addSubview:self.addContactPopupView];
    [self.navigationController.view bringSubviewToFront:self.addContactPopupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
}

#pragma mark - Delegate
#pragma mark TextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.addNewContactView.searchBarView.searchTextField resignFirstResponder];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.addNewContactView.searchBarView.searchTextField.text = @"";
    _searchedUser = nil;
    
    [self.addNewContactView setSearchViewLayoutWithType:LayoutTypeDefault];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *trimmedNewString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
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
#ifdef DEBUG
            NSLog(@"FAILED TO CANCEL PREVIOUS REQUEST");
#endif
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
- (void)userChatNowButtonDidTapped {
    [self.addContactPopupView setPopupViewToDefault];
    [self.addContactPopupView showPopupView:NO animated:NO];
    
    [[TapTalk sharedInstance] openRoomWithOtherUser:self.searchedUser fromNavigationController:self.navigationController];
    
    //CS NOTE - Remove this VC in Navigation Stack to skip on pop
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    [navigationArray removeObject:self];
    self.navigationController.viewControllers = navigationArray;
}

- (void)addUserToContactButtonDidTapped {
    [TAPDataManager callAPIAddContactWithUserID:self.searchedUser.userID success:^(NSString *message) {
        [self.addNewContactView.searchBarView.searchTextField resignFirstResponder];
        [self.addContactPopupView setPopupInfoWithUserData:self.searchedUser isContact:YES];
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

- (void)expertChatNowButtonDidTapped {
    [[TapTalk sharedInstance] openRoomWithOtherUser:self.searchedUser fromNavigationController:self.navigationController];
}

- (void)addExpertToContactButtonDidTapped {
    [TAPDataManager callAPIAddContactWithUserID:self.searchedUser.userID success:^(NSString *message) {
        [self.addNewContactView.searchBarView.searchTextField resignFirstResponder];
        [self.addContactPopupView setPopupInfoWithUserData:self.searchedUser isContact:YES];
        [self.addContactPopupView showPopupView:YES animated:YES];
        [self.addContactPopupView animateExpandingView];
        [self.addNewContactView setSearchUserButtonWithType:ButtonTypeChat];
    } failure:^(NSError *error) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }];
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
            [self.addNewContactView showNoInternetView:NO];
            _searchedUser = user;
            [self.addNewContactView setContactWithUser:user];
            [self.addNewContactView isShowEmptyState:NO];
            [self.addNewContactView showLoading:NO];
        } failure:^(NSError *error) {
            //handle error
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
            NSInteger errorCode = error.code;
            if (errorCode == 40002) {
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
