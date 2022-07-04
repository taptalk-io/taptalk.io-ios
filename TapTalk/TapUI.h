//
//  TapUI.h
//
//
//  Created by Dominic Vedericho on 24/07/19.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "TapUIRoomListViewController.h"
#import "TAPProfileViewController.h"
#import "TAPCustomNotificationAlertViewController.h"
#import "TAPCustomKeyboardItemModel.h"
#import "TAPProductModel.h"
#import "TapUIChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

//==========================================================
//                 TapUIChatRoomDelegate
//==========================================================
@protocol TapUIChatRoomDelegate <NSObject>
@optional

/**
 Called when a chat room is opened
 
 @param room (TAPRoomModel *) room data that is opened
 @param otherUser (TapUserModel *) user data that will be shown
 @param currentViewController (UIViewController *) current shown view controller
 @param currentNavigationController (TapUserModel *) current shown navigation controller, you can handle push or push using this navigation controller
 */
- (void)tapTalkChatRoomDidOpen:(TAPRoomModel *)room
                     otherUser:(TAPUserModel * _Nullable)otherUser
         currentViewController:(UIViewController *)currentViewController
currentShownNavigationController:(UINavigationController *)currentNavigationController;

/**
 Called when a chat room is closed
 
 @param room (TAPRoomModel *) room data that is closed
 @param otherUser (TapUserModel *) user data that will be shown
 @param currentViewController (UIViewController *) current shown view controller
 @param currentNavigationController (TapUserModel *) current shown navigation controller, you can handle push or push using this navigation controller
 */
- (void)tapTalkChatRoomDidClose:(TAPRoomModel *)room
                      otherUser:(TAPUserModel * _Nullable)otherUser
          currentViewController:(UIViewController *)currentViewController
currentShownNavigationController:(UINavigationController *)currentNavigationController;

/**
 Called when user sends any message to a chat room
 
 @param message (TAPMessageModel *) temporary message data that is being sent to the chat room
 @param room (TAPRoomModel *) room data that will be shown
 @param currentViewController (UIViewController *) current shown view controller
 @param currentNavigationController (TapUserModel *) current shown navigation controller, you can handle push or push using this navigation controller
 */
- (void)tapTalkActiveUserDidSendMessage:(TAPMessageModel *)message
                                   room:(TAPRoomModel *)room
                  currentViewController:(UIViewController *)currentViewController
       currentShownNavigationController:(UINavigationController *)currentNavigationController;

/**
 Called when user click the profile button on the top right side of personal chat room page.
 
 @param currentViewController (UIViewController *) current shown view controller
 @param otherUser (TapUserModel *) user data that will be shown
 @param room (TAPRoomModel *) room data that will be shown
 @param currentNavigationController (TapUserModel *) current shown navigation controller, you can handle push or push using this navigation controller
 */
- (void)tapTalkChatRoomProfileButtonTapped:(UIViewController *)currentViewController
                                 otherUser:(TAPUserModel *)otherUser
                                      room:(TAPRoomModel *)room
          currentShownNavigationController:(UINavigationController *)currentNavigationController;

/**
 Called when user click the profile button on the top right side of group chat room page.
 
 @param currentViewController (UIViewController *) current shown view controller
 @param room (TAPRoomModel *) room data that will be shown
 @param currentNavigationController (TapUserModel *) current shown navigation controller, you can handle push or push using this navigation controller
 */
- (void)tapTalkGroupChatRoomProfileButtonTapped:(UIViewController *)currentViewController
                                           room:(TAPRoomModel *)room
               currentShownNavigationController:(UINavigationController *)currentNavigationController;

/**
Called when user click the avatar in bubble chat in group room.

@param room (TAPRoomModel *) room data that will be shown (group)
@param user (TAPUserModel *) tapped user data
@param currentNavigationController (TapUserModel *) current shown navigation controller, you can handle push or push using this navigation controller
*/
- (void)tapTalkGroupMemberAvatarTappedWithRoom:(TAPRoomModel *)room
                                          user:(TAPUserModel *)user
              currentShownNavigationController:(UINavigationController *)currentNavigationController;

/**
Called when user click mention in the bubble chat.

@param room (TAPRoomModel *) room data that will be shown
@param mentionedUser (TAPUserModel *) user data that is selected
@param isRoomParticipant (BOOL) indicator to show current mention user is participant of the group or not
@param message  (TAPMessageModel *) message data of the mention
@param currentViewController (UIViewController *) current shown view controller
@param currentNavigationController (TapUserModel *) current shown navigation controller, you can handle push or push using this navigation controller
*/
- (void)tapTalkUserMentionTappedWithRoom:(TAPRoomModel *)room
                           mentionedUser:(TAPUserModel *)mentionedUser
                           isRoomParticipant:(BOOL)isRoomParticipant
                                 message:(TAPMessageModel *)message
                   currentViewController:(UIViewController *)currentViewController
        currentShownNavigationController:(UINavigationController *)currentNavigationController;

/**
 Called when user click the quote view that appears in the message chat bubble.
 
 @param userInfo (NSDictionary *) other data or details of custom quote
 */
- (void)tapTalkMessageQuoteTappedWithUserInfo:(NSDictionary *)userInfo;

/**
 Called when user click product bubble cell left option or single option button
 
 @param product (TAPProductModel *) selected product data
 @param room (TAPRoomModel *) selected room when user click the product
 @param recipient (TAPUserModel *) recipient user data
 @param isSingleOption (BOOL) indicating whether the option is single or double
 */
- (void)tapTalkProductListBubbleLeftOrSingleButtonTapped:(TAPProductModel *)product room:(TAPRoomModel *)room recipient:(TAPUserModel *)recipient isSingleOption:(BOOL)isSingleOption;

/**
 Called when user click product bubble cell right option
 
 @param product (TAPProductModel *) selected product data
 @param room (TAPRoomModel *) selected room when user click the product
 @param recipient (TAPUserModel *) recipient user data
 @param isSingleOption (BOOL) indicating whether the option is single or double
 */
- (void)tapTalkProductListBubbleRightButtonTapped:(TAPProductModel *)product room:(TAPRoomModel *)room recipient:(TAPUserModel *)recipient isSingleOption:(BOOL)isSingleOption;

@end

//==========================================================
//                 TapUIRoomListDelegate
//==========================================================
@protocol TapUIRoomListDelegate <NSObject>
@optional
/**
 Called when user click the profile button on the top left side of room list view.
 
 @param currentViewController (UIViewController *) current shown view controller
 @param currentNavigationController (UINavigationController *) current shown navigation controller, you can handle push or push using this navigation controller
 */
- (void)tapTalkAccountButtonTapped:(UIViewController *)currentViewController
  currentShownNavigationController:(UINavigationController *)currentNavigationController;

/**
 Called when user click the new chat button on the top right side of room list view.
 
 @param currentViewController (UIViewController *) current shown view controller
 @param currentNavigationController (UINavigationController *) current shown navigation controller, you can handle push or push using this navigation controller
 */
- (void)tapTalkNewChatButtonTapped:(UIViewController *)currentViewController
  currentShownNavigationController:(UINavigationController *)currentNavigationController;

@end

//==========================================================
//                 TapMyAccountDelegate
//==========================================================

@protocol TapUIMyAccountDelegate <NSObject>
@optional

/**
 Called when user click the delete account button on my account view..
 
 @param currentViewController (UIViewController *) current shown view controller
 @param currentNavigationController (UINavigationController *) current shown navigation controller, you can handle push or push using this navigation controller
 */
- (void)tapTalkDeleteAccountButtonTapped:(UIViewController *)currentViewController
  currentShownNavigationController:(UINavigationController *)currentNavigationController;
@end

//==========================================================
//                 TapUIChatProfileDelegate
//==========================================================
@protocol TapUIChatProfileDelegate <NSObject>
@optional

/**
 Called when user taps the Report User button in chat profile
 
 @param currentViewController (UIViewController *) current shown view controller
 @param room (TAPRoomModel *) chat room details of the reported user
 @param reportedUser (TapUserModel *) details of the reported user
 */
- (void)reportUserButtonDidTapped:(UIViewController *)currentViewController
                             room:(TAPRoomModel *)room
                             user:(TAPUserModel *)reportedUser;

/**
 Called when user taps the Report Group button in chat profile
 
 @param currentViewController (UIViewController *) current shown view controller
 @param room (TAPRoomModel *) chat room details of the reported group
 */
- (void)reportGroupButtonDidTapped:(UIViewController *)currentViewController
                              room:(TAPRoomModel *)room;

@end

//==========================================================
//                 TapUICustomKeyboardDelegate
//==========================================================
@protocol TapUICustomKeyboardDelegate <NSObject>
@optional
/**
Called when user tap the option in custom keyboard.

@param room (TAPRoomModel *) selected room
@param sender (TapUserModel *) sender user data
@param recipient (TapUserModel *) recipient user data
@param keyboardItem (TAPCustomKeyboardItemModel *) selected custom keyboard item data
*/
- (void)customKeyboardItemTappedWithRoom:(TAPRoomModel * _Nonnull)room
                                  sender:(TAPUserModel * _Nonnull)sender
                               recipient:(TAPUserModel * _Nullable)recipient
                            keyboardItem:(TAPCustomKeyboardItemModel * _Nonnull)keyboardItem;

/**
Use to set keyboard option items that will appears in custom keyboard.
You have to create TAPCustomKeyboardItemModel for each options, see documentation for more reference
https://developer.taptalk.io/docs/event-delegate#section-tapuicustomkeyboarddelegate

@param room (TAPRoomModel *) selected room
@param sender (TapUserModel *) sender user data
@param recipient (TapUserModel *) recipient user data
*/
- (NSArray<TAPCustomKeyboardItemModel *> *)setCustomKeyboardItemsForRoom:(TAPRoomModel * _Nonnull)room
                                                                  sender:(TAPUserModel * _Nonnull)sender
                                                               recipient:(TAPUserModel * _Nullable)recipient;
@end


//==========================================================
//             TapUIInAppNotificationDelegate
//==========================================================
@protocol TapUIInAppNotificationDelegate <NSObject>
@optional

/**
 Called when a message is received when the app is on foreground
 
 @param message (TAPMessageModel *) message to be shown in the app notification
 @return YES if TapTalk should show the in-app notification, NO if the notification should not be shown
 */
- (BOOL)tapTalkShouldShowInAppNotificationWithMessage:(TAPMessageModel *)message;

@end

@interface TapUI : NSObject

@property (weak, nonatomic) UIWindow *activeWindow;
@property (weak, nonatomic) id<TapUIChatRoomDelegate> chatRoomDelegate;
@property (weak, nonatomic) id<TapUIRoomListDelegate> roomListDelegate;
@property (weak, nonatomic) id<TapUIMyAccountDelegate> myAccountDelegate;
@property (weak, nonatomic) id<TapUIChatProfileDelegate> chatProfileDelegate;
@property (weak, nonatomic) id<TapUICustomKeyboardDelegate> customKeyboardDelegate;
@property (weak, nonatomic) id<TapUIInAppNotificationDelegate> inAppNotificationDelegate;

//Initalization
+ (TapUI *)sharedInstance;

//Property
- (TapUIRoomListViewController *)roomListViewController;
- (TAPCustomNotificationAlertViewController *)customNotificationAlertViewController;

//==========================================================
//                 Windows & View Controllers
//==========================================================
/**
 Set your current active window to TapTalk.io
 */
- (void)setCurrentActiveWindow:(UIWindow *)activeWindow;

/**
 To activate in-app push notification with your current window
 The default is TRUE/YES
 */
- (void)activateTapTalkInAppNotification:(BOOL)activate;

/**
 Get the  activation status of In App Notification
 */
- (BOOL)getTapTalkInAppNotificationActivationStatus;

/**
 Obtain current active navigation controller
 */
- (UINavigationController *)getCurrentTapTalkActiveNavigationController;

/**
 Obtain current active view controller
 */
- (UIViewController *)getCurrentTapTalkActiveViewController;

//==========================================================
//                    Custom Bubble Chat
//==========================================================
/**
 Add new custom bubble class
 */
- (void)addCustomBubbleWithClassName:(NSString *)className
                                type:(NSInteger)type
                            delegate:(id)delegate
                              bundle:(NSBundle *)bundle;

//==========================================================
//                      My Account View
//==========================================================
/**
Show or hide change profile picture button in MyAccount view
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setChangeProfilePictureButtonVisible:(BOOL)isVisible;

/**
Get current visibility state of change profile picture button
*/
- (BOOL)getChangeProfilePictureButtonVisibleState;

/**
Show or hide logout button in MyAccount view
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setLogoutButtonVisible:(BOOL)isVisible;

/**
Get current visibility state of logout button
*/
- (BOOL)getLogoutButtonVisibleState;

//==========================================================
//                       Room List
//==========================================================
/**
Show or hide search bar view in the top of Room List view
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setSearchBarInRoomListVisible:(BOOL)isVisible;

/**
Show or hide left bar button item view in the top of Room List view (My Account Button)
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setMyAccountButtonInRoomListVisible:(BOOL)isVisible;

/**
Show or hide right bar button item view in the top of Room List view (New Chat Button)
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setNewChatButtonInRoomListVisible:(BOOL)isVisible;

/**
Show or hide setup loading view flow of Room List view
The default is false (showing), set the boolean to TRUE when you don't want to show setup loading view

 @param hide (BOOL) boolean to indicating show or not
*/
- (void)hideSetupLoadingFlowInSetupRoomListView:(BOOL)hide;

/**
Get current visibility state of search bar view in the top of Room List view
*/
- (BOOL)getSearchBarInRoomListVisibleState;

/**
Get current visibility state of left bar button item view in the top of Room List view (My Account Button)
*/
- (BOOL)getMyAccountButtonInRoomListViewVisibleState;

/**
Get current visibility state of right bar button item view in the top of Room List view (New Chat Button)
*/
- (BOOL)getNewChatButtonInRoomListVisibleState;

/**
Get current visibility state of setup loading view flow in Room List vie
*/
- (BOOL)getSetupLoadingFlowHiddenState;

//==========================================================
//                      New Chat View
//==========================================================

/**
Show or hide add new contact option menu in NewChat view

@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setNewContactMenuButtonVisible:(BOOL)isVisible;

/**
Show or hide scan QR code option menu in NewChat view

@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setScanQRMenuButtonVisible:(BOOL)isVisible;

/**
Show or hide new group option menu in NewChat view
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setNewGroupMenuButtonVisible:(BOOL)isVisible;

/**
Get current visibility state of add new contact menu option
*/
- (BOOL)getNewContactMenuButtonVisibleState;

/**
Get current visibility state of scan QR code menu option
*/
- (BOOL)getScanQRMenuButtonVisibleState;

/**
Get current visibility state of new group menu option
*/
- (BOOL)getNewGroupMenuButtonVisibleState;

//==========================================================
//                       Chat Room
//==========================================================
/**
 Create chat room with provided user
 
 @param otherUser (TapUserModel *) user data that will be shown
 */
- (void)createRoomWithOtherUser:(TAPUserModel *)otherUser
                        success:(void (^)(TapUIChatViewController *chatViewController))success;

/**
 Create chat room with TapTalk.io user ID
 
 @param userID (NSString *) client user ID
 @param prefilledText (NSString *) prefilled text of message
 @param customQuoteTitle (NSString *) title of custom quote data
 @param customQuoteContent (NSString *) content / subtitle of custom quote data
 @param customQuoteImageURL (NSString *) image url string of custom quote image
 @param userInfo (NSString *) other data or details of custom quote
 */
- (void)createRoomWithUserID:(NSString *)userID
               prefilledText:(NSString *)prefilledText
            customQuoteTitle:(nullable NSString *)customQuoteTitle
          customQuoteContent:(nullable NSString *)customQuoteContent
   customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                    userInfo:(nullable NSDictionary *)userInfo
                     success:(void (^)(TapUIChatViewController *chatViewController))success
                     failure:(void (^)(NSError *error))failure;

/**
 Create chat room with client user ID
 
 @param XCUserID (NSString *) client user ID
 @param prefilledText (NSString *) prefilled text of message
 @param customQuoteTitle (NSString *) title of custom quote data
 @param customQuoteContent (NSString *) content / subtitle of custom quote data
 @param customQuoteImageURL (NSString *) image url of custom quote image
 @param userInfo (NSString *) other data or details of custom quote
 */
- (void)createRoomWithXCUserID:(NSString *)XCUserID
                 prefilledText:(NSString *)prefilledText
              customQuoteTitle:(nullable NSString *)customQuoteTitle
            customQuoteContent:(nullable NSString *)customQuoteContent
     customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                      userInfo:(nullable NSDictionary *)userInfo
                       success:(void (^)(TapUIChatViewController *chatViewController))success
                       failure:(void (^)(NSError *error))failure;

/**
 Create chat room with provided room
 
 @param room (TAPRoomModel *) room that will be opened
 @param customQuoteTitle (NSString *) title of custom quote data
 @param customQuoteContent (NSString *) content / subtitle of custom quote data
 @param customQuoteImageURL (NSString *) image url of custom quote image
 @param userInfo (NSString *) other data or details of custom quote
 */
- (void)createRoomWithRoom:(TAPRoomModel *)room
          customQuoteTitle:(nullable NSString *)customQuoteTitle
        customQuoteContent:(nullable NSString *)customQuoteContent
 customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                  userInfo:(nullable NSDictionary *)userInfo
                   success:(void (^)(TapUIChatViewController *chatViewController))success;

/**
 Create chat room with provided room
 
 @param room (TAPRoomModel *) room that will be opened
 */
- (void)createRoomWithRoom:(TAPRoomModel *)room
                   success:(void (^)(TapUIChatViewController *chatViewController))success;

/**
 Create chat room with provided room and scroll to certain message
 
 @param room (TAPRoomModel *) room that will be opened
 @param messageLocalID (NSString *) scrolled to selected message with provided message ID
 */
- (void)createRoomWithRoom:(TAPRoomModel *)room
scrollToMessageWithLocalID:(NSString *)messageLocalID
                   success:(void (^)(TapUIChatViewController *chatViewController))success;

/**
Show or hide profile button view in top right navigation in chat room view
 
@param isVisible (BOOL) boolean to indicating is visible or not
*/
- (void)setProfileButtonInChatRoomVisible:(BOOL)isVisible;

/**
Get current visibility state of profile button in chat room
*/
- (BOOL)getProfileButtonInChatRoomVisibleState;

//==========================================================
//                        Others
//==========================================================
/**
Show or hide read status (green double checklist icon when read)
 
@param hideReadStatus (BOOL) boolean to indicating is hide or not
*/
- (void)setHideReadStatus:(BOOL)hideReadStatus;

/**
Get current state of hide read status
*/
- (BOOL)getReadStatusHiddenState;

/**
Show or hide close button in room list
*/
- (void)setCloseRoomListButtonVisible:(BOOL)isVisible;

/**
Get current visibility state of close button in room list
*/
- (BOOL)getCloseRoomListButtonVisibleState;
    
/**
Show or hide document attachment in chat room
*/
- (void)setDocumentAttachmentEnabled:(BOOL)isEnabled;

/**
Get current visibility state of document attachment in chat room
*/
- (BOOL)isDocumentAttachmentEnabled;

/**
Show or hide camera attachment in chat room
*/
- (void)setCameraAttachmentEnabled:(BOOL)isEnabled;

/**
Get current visibility state of camera attachment in chat room
*/
- (BOOL)isCameraAttachmentEnabled;

/**
Show or hide gallery attachment in chat room
*/
- (void)setGalleryAttachmentEnabled:(BOOL)isEnabled;

/**
Get current visibility state of gallery attachment in chat room
*/
- (BOOL)isGalleryAttachmentEnabled;

/**
Show or hide location attachment in chat room
*/
- (void)setLocationAttachmentEnabled:(BOOL)isEnabled;

/**
Get current visibility state of location attachment in chat room
*/
- (BOOL)isLocationAttachmentEnabled;

/**
Show or hide reply message long press menu in chat room
*/
- (void)setReplyMessageMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of reply message long press menu in chat room
*/
- (BOOL)isReplyMessageMenuEnabled;

/**
Show or hide forward message long press menu in chat room
*/
- (void)setForwardMessageMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of forward message long press menu in chat room
*/
- (BOOL)isForwardMessageMenuEnabled;

/**
Show or hide copy message long press menu in chat room
*/
- (void)setCopyMessageMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of copy message long press menu in chat room
*/
- (BOOL)isCopyMessageMenuEnabled;

/**
Show or hide delete message long press menu in chat room
*/
- (void)setDeleteMessageMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of delete message long press menu in chat room
*/
- (BOOL)isDeleteMessageMenuEnabled;

/**
Show or hide save media long press menu in chat room
*/
- (void)setSaveMediaToGalleryMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of save media long press menu in chat room
*/
- (BOOL)isSaveMediaToGalleryMenuEnabled;

/**
Show or hide save document long press menu in chat room
*/
- (void)setSaveDocumentMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of save document long press menu in chat room
*/
- (BOOL)isSaveDocumentMenuEnabled;

/**
Show or hide open link long press menu in chat room
*/
- (void)setOpenLinkMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of open link long press menu in chat room
*/
- (BOOL)isOpenLinkMenuEnabled;

/**
Show or hide compose email long press menu in chat room
*/
- (void)setComposeEmailMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of compose email long press menu in chat room
*/
- (BOOL)isComposeEmailMenuEnabled;

/**
Show or hide dial number long press menu in chat room
*/
- (void)setDialNumberMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of dial number long press menu in chat room
*/
- (BOOL)isDialNumberMenuEnabled;

/**
Show or hide send SMS long press menu in chat room
*/
- (void)setSendSMSMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of send SMS long press menu in chat room
*/
- (BOOL)isSendSMSMenuEnabled;

/**
Show or hide view profile long press menu in chat room
*/
- (void)setViewProfileMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of view profile long press menu in chat room
*/
- (BOOL)isViewProfileMenuEnabled;

/**
Show or hide send message long press menu in chat room
*/
- (void)setSendMessageMenuEnabled:(BOOL)isEnabled;

/**
Get current visibility state of send message long press menu in chat room
*/
- (BOOL)isSendMessageMenuEnabled;

/**
Enable or disable mention username in chat room
*/
- (void)setMentionUsernameEnabled:(BOOL)isEnabled;

/**
Get current status of mention username
*/
- (BOOL)isMentionUsernameEnabled;

/**
Show or hide add to contacts button in chat room
*/
- (void)setAddToContactsButtonInChatRoomVisible:(BOOL)isVisible;

/**
Get current visibility state of add to contacts button in chat room
*/
- (BOOL)getAddToContactsButtonInChatRoomVisibleState;

/**
Show or hide add to contacts button in user / group profile
*/
- (void)setAddToContactsButtonInChatProfileVisible:(BOOL)isVisible;

/**
Get current visibility state of add to contacts button in user / group profile
*/
- (BOOL)getAddToContactsButtonInChatProfileVisibleState;

/**
Enable or disable adding contacts & contact list
*/
- (void)setAddContactEnabled:(BOOL)isEnabled;

/**
Get current status of adding contacts & contact list
*/
- (BOOL)isAddContactEnabled;

/**
Show or hide report button in user/group profile page
*/
- (void)setReportButtonInChatProfileVisible:(BOOL)isVisible;
/**
 Get current visibility state of report button in user/group profile page
*/
- (BOOL)getReportButtonInChatProfileVisibleState;

/**
Show or hide username label in user/group profile page
*/
- (void)setUsernameInChatProfileVisible:(BOOL)isVisible;
/**
 Get current visibility state of username label in user/group profile page
*/
- (BOOL)getUsernameInChatProfileVisible;

/**
Show or hide mobile number label in user/group profile page
*/
- (void)setMobileNumberInChatProfileVisible:(BOOL)isVisible;
/**
 Get current visibility state of mobile number label in user/group profile page
*/
- (BOOL)getMobileNumberInChatProfileVisible;

/**
Show or hide email label in user/group profile page
*/
- (void)setEmailAddressInChatProfileVisible:(BOOL)isVisible;
/**
 Get current visibility state of email label in user/group profile page
*/
- (BOOL)getEmailAddressInChatProfileVisible;


/**
Show or hide bio in user/group profile page
*/
- (void)setEditBioTextFieldVisible:(BOOL)isVisible;

/**
 Get current visibility state of bio in user/group profile page and my account page
*/
- (BOOL)getEditBioTextFieldVisible;

/**
<<<<<<< HEAD
Enable or disable mark as read swipe in chat room list
*/
- (void)setMarkAsReadRoomListSwipeMenuEnabled:(BOOL)isEnabled;

/**
 Get current isEnabled state of mark as read swipe in chat room list
*/
- (BOOL)getMarkAsReadRoomListSwipeMenuEnabled;

/**
 Enable or disable mark as unread swipe in chat room list
*/
- (void)setMarkAsUnreadRoomListSwipeMenuEnabled:(BOOL)isEnabled;

/**
 Get current isEnabled state of mark as unread swipe in chat room list
*/
- (BOOL)getMarkAsUnreadRoomListSwipeMenuEnabled;


/**
Show or hide star message menu from message bubble long press & chat profile
*/
- (void)setStarMessageMenuEnabled:(BOOL)isEnabled;

/**
Get current status of star message menu from message bubble long press & chat profile
*/
- (BOOL)isStarMessageMenuEnabled;

/**
Show or hide voice note menu from message bubble long press & chat profile
*/
- (void)setSendVoiceNoteMenuEnabled:(BOOL)isEnabled;

/**
Get current status of voice noite menu from message bubble long press & chat profile
*/
- (BOOL)isSendVoiceNoteMenuEnabled;

/**
Show or hide edit message menu from message bubble long press & chat profile
*/
- (void)setEditMessageMenuEnabled:(BOOL)isEnabled;

/**
Get current status of voice noite menu from message bubble long press & chat profile
*/
- (BOOL)isEditMessageMenuEnabled;

/**
Show or hide delete account button in my account
*/
- (void)setDeleteAccountButtonVisible:(BOOL)isVisible;

/**
Get current visibility state of  delete account button in my account
*/
- (BOOL)getDeleteAccountButtonVisible;


@end

NS_ASSUME_NONNULL_END
