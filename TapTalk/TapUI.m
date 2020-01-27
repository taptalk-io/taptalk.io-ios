//
//  TapUI.m
//  
//
//  Created by Dominic Vedericho on 24/07/19.
//

#import "TapUI.h"

@interface TapUI ()

@property (strong, nonatomic) TapUIRoomListViewController *roomListViewController;
@property (strong, nonatomic) TAPCustomNotificationAlertViewController *customNotificationAlertViewController;

@property (nonatomic) BOOL isLogoutButtonVisible;
@property (nonatomic) BOOL isSearchBarRoomListViewHidden;
@property (nonatomic) BOOL isLeftBarItemRoomListViewHidden;
@property (nonatomic) BOOL isRightBarItemRoomListViewHidden;
@property (nonatomic) BOOL isNewContactMenuButtonHidden;
@property (nonatomic) BOOL isScanQRMenuButtonHidden;
@property (nonatomic) BOOL isNewGroupMenuButtonHidden;
@property (nonatomic) BOOL isProfileButtonInChatRoomHidden;
@property (nonatomic) BOOL hideSetupLoadingViewFlow;

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController;

@end

@implementation TapUI

#pragma mark - Lifecycle
+ (TapUI *)sharedInstance {
    static TapUI *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _roomListViewController = [[TapUIRoomListViewController alloc] init];
        _customNotificationAlertViewController = [[TAPCustomNotificationAlertViewController alloc] init];
        _activeWindow = [[UIWindow alloc] init];
    }
    
    return self;
}

#pragma mark - Property
- (TapUIRoomListViewController *)roomListViewController {
    return _roomListViewController;
}

- (TAPCustomNotificationAlertViewController *)customNotificationAlertViewController {
    return _customNotificationAlertViewController;
}

#pragma mark - Custom Method
//Windows & View Controllers
- (void)activateInAppNotificationInWindow:(UIWindow *)activeWindow {
    _activeWindow = activeWindow;
}

- (UINavigationController *)getCurrentTapTalkActiveNavigationController {
    return [self getCurrentTapTalkActiveViewController].navigationController;
}

- (UIViewController *)getCurrentTapTalkActiveViewController {
    return [self topViewControllerWithRootViewController:self.activeWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

//Custom Bubble
- (void)addCustomBubbleWithClassName:(NSString *)className type:(NSInteger)type delegate:(id)delegate bundle:(NSBundle *)bundle {
    [[TAPCustomBubbleManager sharedManager] addCustomBubbleDataWithCellName:className type:type delegate:delegate bundle:bundle];
}

//Room List

//Open Chat Room
- (void)createRoomWithOtherUser:(TAPUserModel *)otherUser
                        success:(void (^)(TapUIChatViewController *chatViewController))success {
    TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:otherUser];
    //    [[TAPChatManager sharedManager] openRoom:room]; //Called in ChatViewController willAppear
    
    //Save all unsent message (in case user retrieve message on another room)
    [[TAPChatManager sharedManager] saveAllUnsentMessage];
    
    //Save user to ContactManager Dictionary
    [[TAPContactManager sharedManager] addContactWithUserModel:otherUser saveToDatabase:NO];
    
    TapUIChatViewController *chatViewController = [[TapUIChatViewController alloc] initWithNibName:@"TapUIChatViewController" bundle:[TAPUtil currentBundle]];
    chatViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    chatViewController.currentRoom = room;
    chatViewController.delegate = [[TapUI sharedInstance] roomListViewController];
    success(chatViewController);
}

- (void)createRoomWithUserID:(NSString *)userID
               prefilledText:(NSString *)prefilledText
            customQuoteTitle:(nullable NSString *)customQuoteTitle
          customQuoteContent:(nullable NSString *)customQuoteContent
   customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                    userInfo:(nullable NSDictionary *)userInfo
                     success:(void (^)(TapUIChatViewController *chatViewController))success
                     failure:(void (^)(NSError *error))failure {
    //Check is user exist in TapTalk database
    [TAPDataManager getDatabaseContactByUserID:userID success:^(BOOL isContact, TAPUserModel *obtainedUser) {
        if (isContact) {
            //User is in contact
            //Create quote model and set quote to chat
            
            TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:obtainedUser];
            
            if (![customQuoteTitle isEqualToString:@""] && customQuoteTitle != nil) {
                TAPQuoteModel *quote = [TAPQuoteModel new];
                quote.title = customQuoteTitle;
                quote.content = customQuoteContent;
                quote.imageURL = customQuoteImageURL;
                
                [[TAPChatManager sharedManager] saveToQuotedMessage:quote userInfo:userInfo roomID:room.roomID];
            }
            
            NSString *draftMessage = [TAPUtil nullToEmptyString:prefilledText];
            if (![draftMessage isEqualToString:@""]) {
                [[TAPChatManager sharedManager] saveMessageToDraftWithMessage:draftMessage roomID:room.roomID];
            }
            
            //Open room
            [self createRoomWithOtherUser:obtainedUser success:^(TapUIChatViewController * _Nonnull chatViewController) {
                success(chatViewController);
            }];
        }
        else {
            //User not in contact, call API to obtain user data
            [TAPDataManager callAPIGetUserByUserID:userID success:^(TAPUserModel *user) {
                //Create quote model and set quote to chat
                TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:user];
                
                //Save user to ContactManager Dictionary
                [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO];
                
                if (![customQuoteTitle isEqualToString:@""] && customQuoteTitle != nil) {
                    TAPQuoteModel *quote = [TAPQuoteModel new];
                    quote.title = customQuoteTitle;
                    quote.content = customQuoteContent;
                    quote.imageURL = customQuoteImageURL;
                    
                    [[TAPChatManager sharedManager] saveToQuotedMessage:quote userInfo:userInfo roomID:room.roomID];
                }
                
                NSString *draftMessage = [TAPUtil nullToEmptyString:prefilledText];
                if (![draftMessage isEqualToString:@""]) {
                    [[TAPChatManager sharedManager] saveMessageToDraftWithMessage:draftMessage roomID:room.roomID];
                }
                
                //Open room
                [self createRoomWithOtherUser:user success:^(TapUIChatViewController * _Nonnull chatViewController) {
                    success(chatViewController);
                }];
                
                
            } failure:^(NSError *error) {
                NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
                failure(localizedError);
            }];
        }
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)createRoomWithXCUserID:(NSString *)XCUserID
                 prefilledText:(NSString *)prefilledText
              customQuoteTitle:(nullable NSString *)customQuoteTitle
            customQuoteContent:(nullable NSString *)customQuoteContent
     customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                      userInfo:(nullable NSDictionary *)userInfo
                       success:(void (^)(TapUIChatViewController *chatViewController))success
                       failure:(void (^)(NSError *error))failure {
    //Check is user exist in TapTalk database
    [TAPDataManager getDatabaseContactByXCUserID:XCUserID success:^(BOOL isContact, TAPUserModel *obtainedUser) {
        if (isContact) {
            //User is in contact
            //Create quote model and set quote to chat
            
            TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:obtainedUser];
            
            if (![customQuoteTitle isEqualToString:@""] && customQuoteTitle != nil) {
                TAPQuoteModel *quote = [TAPQuoteModel new];
                quote.title = customQuoteTitle;
                quote.content = customQuoteContent;
                quote.imageURL = customQuoteImageURL;
                
                [[TAPChatManager sharedManager] saveToQuotedMessage:quote userInfo:userInfo roomID:room.roomID];
            }
            
            NSString *draftMessage = [TAPUtil nullToEmptyString:prefilledText];
            if (![draftMessage isEqualToString:@""]) {
                [[TAPChatManager sharedManager] saveMessageToDraftWithMessage:draftMessage roomID:room.roomID];
            }
            
            //Open room
            [self createRoomWithOtherUser:obtainedUser success:^(TapUIChatViewController * _Nonnull chatViewController) {
                success(chatViewController);
            }];
        }
        else {
            //User not in contact, call API to obtain user data
            [TAPDataManager callAPIGetUserByXCUserID:XCUserID success:^(TAPUserModel *user) {
                //Create quote model and set quote to chat
                TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:user];
                
                //Save user to ContactManager Dictionary
                [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO];
                
                if (![customQuoteTitle isEqualToString:@""] && customQuoteTitle != nil) {
                    TAPQuoteModel *quote = [TAPQuoteModel new];
                    quote.title = customQuoteTitle;
                    quote.content = customQuoteContent;
                    quote.imageURL = customQuoteImageURL;
                    
                    [[TAPChatManager sharedManager] saveToQuotedMessage:quote userInfo:userInfo roomID:room.roomID];
                }
                
                NSString *draftMessage = [TAPUtil nullToEmptyString:prefilledText];
                if (![draftMessage isEqualToString:@""]) {
                    [[TAPChatManager sharedManager] saveMessageToDraftWithMessage:draftMessage roomID:room.roomID];
                }
                
                //Open room
                [self createRoomWithOtherUser:user success:^(TapUIChatViewController * _Nonnull chatViewController) {
                    success(chatViewController);
                }];

            } failure:^(NSError *error) {
                NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
                failure(localizedError);
            }];
        }
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)createRoomWithRoom:(TAPRoomModel *)room
          customQuoteTitle:(nullable NSString *)customQuoteTitle
        customQuoteContent:(nullable NSString *)customQuoteContent
 customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                  userInfo:(nullable NSDictionary *)userInfo
                   success:(void (^)(TapUIChatViewController *chatViewController))success {
    
    //Create quote model and set quote to chat
    if (![customQuoteTitle isEqualToString:@""] && customQuoteTitle != nil) {
        TAPQuoteModel *quote = [TAPQuoteModel new];
        quote.title = customQuoteTitle;
        quote.content = customQuoteContent;
        quote.imageURL = customQuoteImageURL;
        
        [[TAPChatManager sharedManager] saveToQuotedMessage:quote userInfo:userInfo roomID:room.roomID];
    }
    
    //Open room
    [self createRoomWithRoom:room success:^(TapUIChatViewController * _Nonnull chatViewController) {
        success(chatViewController);
    }];
}

- (void)createRoomWithRoom:(TAPRoomModel *)room
                   success:(void (^)(TapUIChatViewController *chatViewController))success {
    [self createRoomWithRoom:room scrollToMessageWithLocalID:nil success:^(TapUIChatViewController * _Nonnull chatViewController) {
        success(chatViewController);
    }];
}

- (void)createRoomWithRoom:(TAPRoomModel *)room
scrollToMessageWithLocalID:(NSString *)messageLocalID
                   success:(void (^)(TapUIChatViewController *chatViewController))success {
    //Save all unsent message (in case user retrieve message on another room)
    [[TAPChatManager sharedManager] saveAllUnsentMessage];
    
    TapUIChatViewController *chatViewController = [[TapUIChatViewController alloc] initWithNibName:@"TapUIChatViewController" bundle:[TAPUtil currentBundle]];
    chatViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    chatViewController.currentRoom = room;
    chatViewController.delegate = [[TapUI sharedInstance] roomListViewController];
    chatViewController.scrollToMessageLocalIDString = messageLocalID;
    success(chatViewController);
}

/**
Show or hide logout button in MyAccount view
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setLogoutButtonVisible:(BOOL)isVisible {
    _isLogoutButtonVisible = isVisible;
}

/**
Show or hide search bar view in the top of Room List view
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setSearchBarInRoomListVisible:(BOOL)isVisible {
    _isSearchBarRoomListViewHidden = !isVisible;
}

/**
Show or hide left bar button item view in the top of Room List view (My Account Button)
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setMyAccountButtonInRoomListVisible:(BOOL)isVisible {
    _isLeftBarItemRoomListViewHidden = !isVisible;
}

/**
Show or hide right bar button item view in the top of Room List view (New Chat Button)
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setNewChatButtonInRoomListVisible:(BOOL)isVisible {
    _isRightBarItemRoomListViewHidden = !isVisible;
}

/**
Show or hide setup loading view flow of Room List view
The default is false (showing), set the boolean to TRUE when you don't want to show setup loading view

@param hide (BOOL) boolean to indicating show or not
*/
- (void)hideSetupLoadingFlowInSetupRoomListView:(BOOL)hide {
    _hideSetupLoadingViewFlow = hide;
}

/**
Show or hide add new contact option menu in NewChat view

@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setNewContactMenuButtonVisible:(BOOL)isVisible {
    _isNewContactMenuButtonHidden = !isVisible;
}

/**
Show or hide scan QR code option menu in NewChat view

@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setScanQRMenuButtonVisible:(BOOL)isVisible {
    _isScanQRMenuButtonHidden = !isVisible;
}
/**
Show or hide new group option menu in NewChat view
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setNewGroupMenuButtonVisible:(BOOL)isVisible {
    _isNewGroupMenuButtonHidden = !isVisible;
}

/**
Show or hide profile button view in top right navigation in chat room view
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setProfileButtonInChatRoomVisible:(BOOL)isVisible {
    _isProfileButtonInChatRoomHidden = !isVisible;
}

/**
Get current visibility state of logout button
*/
- (BOOL)getLogoutButtonVisibleState {
    return self.isLogoutButtonVisible;
}

/**
Get current visibility state of search bar view in the top of Room List view
*/
- (BOOL)getSearchBarInRoomListVisibleState {
    return !self.isSearchBarRoomListViewHidden;
}

/**
Get current visibility state of left bar button item view in the top of Room List view (My Account Button)
*/
- (BOOL)getMyAccountButtonInRoomListViewVisibleState {
    return !self.isLeftBarItemRoomListViewHidden;
}

/**
Get current visibility state of right bar button item view in the top of Room List view (New Chat Button)
*/
- (BOOL)getNewChatButtonInRoomListVisibleState {
    return !self.isRightBarItemRoomListViewHidden;
}

/**
Get current visibility state of add new contact menu option
*/
- (BOOL)getNewContactMenuButtonVisibleState {
    return !self.isNewContactMenuButtonHidden;
}

/**
Get current visibility state of scan QR code menu option
*/
- (BOOL)getScanQRMenuButtonVisibleState {
    return !self.isScanQRMenuButtonHidden;
}

/**
Get current visibility state of new group menu option
*/
- (BOOL)getNewGroupMenuButtonVisibleState {
    return !self.isNewGroupMenuButtonHidden;
}

/**
Get current visibility state of profile button in chat room
*/
- (BOOL)getProfileButtonInChatRoomVisibleState {
    return !self.isProfileButtonInChatRoomHidden;
}

/**
Get current visibility state of setup loading view flow in Room List vie
*/
- (BOOL)getSetupLoadingFlowHiddenState {
    return self.hideSetupLoadingViewFlow;
}

@end
