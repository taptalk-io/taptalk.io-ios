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

@property (nonatomic) BOOL isDisableActivateInAppNotification;
@property (nonatomic) BOOL isLogoutButtonVisible;
@property (nonatomic) BOOL isSearchBarRoomListViewHidden;
@property (nonatomic) BOOL isLeftBarItemRoomListViewHidden;
@property (nonatomic) BOOL isRightBarItemRoomListViewHidden;
@property (nonatomic) BOOL isNewContactMenuButtonHidden;
@property (nonatomic) BOOL isScanQRMenuButtonHidden;
@property (nonatomic) BOOL isNewGroupMenuButtonHidden;
@property (nonatomic) BOOL isProfileButtonInChatRoomHidden;
@property (nonatomic) BOOL hideSetupLoadingViewFlow;
@property (nonatomic) BOOL hideReadStatus;

@property (nonatomic) BOOL isCloseRoomListButtonVisible;
//@property (nonatomic) BOOL isConnectionStatusIndicatorHidden;
@property (nonatomic) BOOL isDocumentAttachmentDisabled;
@property (nonatomic) BOOL isCameraAttachmentDisabled;
@property (nonatomic) BOOL isGalleryAttachmentDisabled;
@property (nonatomic) BOOL isLocationAttachmentDisabled;
@property (nonatomic) BOOL isReplyMessageMenuDisabled;
@property (nonatomic) BOOL isForwardMessageMenuDisabled;
@property (nonatomic) BOOL isCopyMessageMenuDisabled;
@property (nonatomic) BOOL isDeleteMessageMenuDisabled;
@property (nonatomic) BOOL isSaveMediaToGalleryMenuDisabled;
@property (nonatomic) BOOL isSaveDocumentMenuDisabled;
@property (nonatomic) BOOL isOpenLinkMenuDisabled;
@property (nonatomic) BOOL isComposeEmailMenuDisabled;
@property (nonatomic) BOOL isDialNumberMenuDisabled;
@property (nonatomic) BOOL isSendSMSMenuDisabled;
@property (nonatomic) BOOL isViewProfileMenuDisabled;
@property (nonatomic) BOOL isSendMessageMenuDisabled;
@property (nonatomic) BOOL isMentionUsernameDisabled;
@property (nonatomic) BOOL isAddToContactsButtonInChatRoomHidden;
@property (nonatomic) BOOL isAddToContactsButtonInChatProfileHidden;
@property (nonatomic) BOOL isAddContactDisabled;

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
//        _roomListViewController = [[TapUIRoomListViewController alloc] init];
        _customNotificationAlertViewController = [[TAPCustomNotificationAlertViewController alloc] init];
        _activeWindow = [[UIWindow alloc] init];
    }
    
    return self;
}

#pragma mark - Property
- (TapUIRoomListViewController *)roomListViewController {
    if (_roomListViewController == nil) {
        _roomListViewController = [[TapUIRoomListViewController alloc] init];
    }
    return _roomListViewController;
}

- (TAPCustomNotificationAlertViewController *)customNotificationAlertViewController {
    return _customNotificationAlertViewController;
}

#pragma mark - Custom Method
//Windows & View Controllers
- (void)setCurrentActiveWindow:(UIWindow *)activeWindow {
    _activeWindow = activeWindow;
}

- (void)activateTapTalkInAppNotification:(BOOL)activate {
    _isDisableActivateInAppNotification = !activate;
}

- (BOOL)getTapTalkInAppNotificationActivationStatus {
    return !self.isDisableActivateInAppNotification;
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
    [[TAPContactManager sharedManager] addContactWithUserModel:otherUser saveToDatabase:NO saveActiveUser:NO];
    
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
                [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO saveActiveUser:YES];
                
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
                [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO saveActiveUser:YES];
                
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

/**
Show or hide read status (green double checklist icon when read)
 
@param isVisible (BOOL) boolean to indicating is hide or not
*/
- (void)setHideReadStatus:(BOOL)hideReadStatus {
    _hideReadStatus = hideReadStatus;
}

/**
Get current state of hide read status
*/
- (BOOL)getReadStatusHiddenState {
    return self.hideReadStatus;
}

/**
Show or hide close button in room list
*/
- (void)setCloseRoomListButtonVisible:(BOOL)isVisible {
    _isCloseRoomListButtonVisible = isVisible;
}

/**
Get current visibility state of close button in room list
*/
- (BOOL)getCloseRoomListButtonVisibleState {
    return self.isCloseRoomListButtonVisible;
}
/**
Show or hide document attachment in chat room
*/
- (void)setDocumentAttachmentEnabled:(BOOL)isEnabled {
    _isDocumentAttachmentDisabled = !isEnabled;
}

/**
Get current visibility state of document attachment in chat room
*/
- (BOOL)isDocumentAttachmentEnabled {
    return !self.isDocumentAttachmentDisabled;
}

/**
Show or hide camera attachment in chat room
*/
- (void)setCameraAttachmentEnabled:(BOOL)isEnabled {
    _isCameraAttachmentDisabled = !isEnabled;
}

/**
Get current visibility state of camera attachment in chat room
*/
- (BOOL)isCameraAttachmentEnabled {
    return !self.isCameraAttachmentDisabled;
}

/**
Show or hide gallery attachment in chat room
*/
- (void)setGalleryAttachmentEnabled:(BOOL)isEnabled {
    _isGalleryAttachmentDisabled = !isEnabled;
}

/**
Get current visibility state of gallery attachment in chat room
*/
- (BOOL)isGalleryAttachmentEnabled {
    return !self.isGalleryAttachmentDisabled;
}

/**
Show or hide location attachment in chat room
*/
- (void)setLocationAttachmentEnabled:(BOOL)isEnabled {
    _isLocationAttachmentDisabled = !isEnabled;
}

/**
Get current visibility state of location attachment in chat room
*/
- (BOOL)isLocationAttachmentEnabled {
    return !self.isLocationAttachmentDisabled;
}

/**
Show or hide reply message long press menu in chat room
*/
- (void)setReplyMessageMenuEnabled:(BOOL)isEnabled {
    _isReplyMessageMenuDisabled = !isEnabled;
}

/**
Get current visibility state of reply message long press menu in chat room
*/
- (BOOL)isReplyMessageMenuEnabled {
    return !self.isReplyMessageMenuDisabled;
}

/**
Show or hide forward message long press menu in chat room
*/
- (void)setForwardMessageMenuEnabled:(BOOL)isEnabled {
    _isForwardMessageMenuDisabled = !isEnabled;
}

/**
Get current visibility state of forward message long press menu in chat room
*/
- (BOOL)isForwardMessageMenuEnabled {
    return !self.isForwardMessageMenuDisabled;
}

/**
Show or hide copy message long press menu in chat room
*/
- (void)setCopyMessageMenuEnabled:(BOOL)isEnabled {
    _isCopyMessageMenuDisabled = !isEnabled;
}

/**
Get current visibility state of copy message long press menu in chat room
*/
- (BOOL)isCopyMessageMenuEnabled {
    return !self.isCopyMessageMenuDisabled;
}

/**
Show or hide delete message long press menu in chat room
*/
- (void)setDeleteMessageMenuEnabled:(BOOL)isEnabled {
    _isDeleteMessageMenuDisabled = !isEnabled;
}

/**
Get current visibility state of delete message long press menu in chat room
*/
- (BOOL)isDeleteMessageMenuEnabled {
    return !self.isDeleteMessageMenuDisabled;
}

/**
Show or hide save media long press menu in chat room
*/
- (void)setSaveMediaToGalleryMenuEnabled:(BOOL)isEnabled {
    _isSaveMediaToGalleryMenuDisabled = !isEnabled;
}

/**
Get current visibility state of save media long press menu in chat room
*/
- (BOOL)isSaveMediaToGalleryMenuEnabled {
    return !self.isSaveMediaToGalleryMenuDisabled;
}

/**
Show or hide save document long press menu in chat room
*/
- (void)setSaveDocumentMenuEnabled:(BOOL)isEnabled {
    _isSaveDocumentMenuDisabled = !isEnabled;
}

/**
Get current visibility state of save document long press menu in chat room
*/
- (BOOL)isSaveDocumentMenuEnabled {
    return !self.isSaveDocumentMenuDisabled;
}

/**
Show or hide open link long press menu in chat room
*/
- (void)setOpenLinkMenuEnabled:(BOOL)isEnabled {
    _isOpenLinkMenuDisabled = !isEnabled;
}

/**
Get current visibility state of open link long press menu in chat room
*/
- (BOOL)isOpenLinkMenuEnabled {
    return !self.isOpenLinkMenuDisabled;
}

/**
Show or hide compose email long press menu in chat room
*/
- (void)setComposeEmailMenuEnabled:(BOOL)isEnabled {
    _isComposeEmailMenuDisabled = !isEnabled;
}

/**
Get current visibility state of compose email long press menu in chat room
*/
- (BOOL)isComposeEmailMenuEnabled {
    return !self.isComposeEmailMenuDisabled;
}

/**
Show or hide dial number long press menu in chat room
*/
- (void)setDialNumberMenuEnabled:(BOOL)isEnabled {
    _isDialNumberMenuDisabled = !isEnabled;
}

/**
Get current visibility state of dial number long press menu in chat room
*/
- (BOOL)isDialNumberMenuEnabled {
    return !self.isDialNumberMenuDisabled;
}

/**
Show or hide send SMS long press menu in chat room
*/
- (void)setSendSMSMenuEnabled:(BOOL)isEnabled {
    _isSendSMSMenuDisabled = !isEnabled;
}

/**
Get current visibility state of send SMS long press menu in chat room
*/
- (BOOL)isSendSMSMenuEnabled {
    return !self.isSendSMSMenuDisabled;
}

/**
Show or hide view profile long press menu in chat room
*/
- (void)setViewProfileMenuEnabled:(BOOL)isEnabled {
    _isViewProfileMenuDisabled = !isEnabled;
}

/**
Get current visibility state of view profile long press menu in chat room
*/
- (BOOL)isViewProfileMenuEnabled {
    return !self.isViewProfileMenuDisabled;
}

/**
Show or hide send message long press menu in chat room
*/
- (void)setSendMessageMenuEnabled:(BOOL)isEnabled {
    _isSendMessageMenuDisabled = !isEnabled;
}

/**
Get current visibility state of send message long press menu in chat room
*/
- (BOOL)isSendMessageMenuEnabled {
    return !self.isSendMessageMenuDisabled;
}

/**
Enable or disable mention username in chat room
*/
- (void)setMentionUsernameEnabled:(BOOL)isEnabled {
    _isMentionUsernameDisabled = !isEnabled;
}

/**
Get current status of mention username
*/
- (BOOL)isMentionUsernameEnabled {
    return !self.isMentionUsernameDisabled;
}

/**
Show or hide add to contacts button in chat room
*/
- (void)setAddToContactsButtonInChatRoomVisible:(BOOL)isVisible {
    _isAddToContactsButtonInChatRoomHidden = !isVisible;
}

/**
Get current visibility state of add to contacts button in chat room
*/
- (BOOL)getAddToContactsButtonInChatRoomVisibleState {
    return !self.isAddToContactsButtonInChatRoomHidden;
}

/**
Show or hide add to contacts button in user / group profile
*/
- (void)setAddToContactsButtonInChatProfileVisible:(BOOL)isVisible {
    _isAddToContactsButtonInChatProfileHidden = !isVisible;
}

/**
Get current visibility state of add to contacts button in user / group profile
*/
- (BOOL)getAddToContactsButtonInChatProfileVisibleState {
    return !self.isAddToContactsButtonInChatProfileHidden;
}

/**
Enable or disable adding contacts & contact list
*/
- (void)setAddContactEnabled:(BOOL)isEnabled {
    _isAddContactDisabled = !isEnabled;
}

/**
Get current status of adding contacts & contact list
*/
- (BOOL)isAddContactEnabled {
    return !self.isAddContactDisabled;
}

@end
