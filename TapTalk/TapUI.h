//
//  TapUI.h
//  
//
//  Created by Dominic Vedericho on 24/07/19.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "TAPLoginViewController.h"
#import "TapUIRoomListViewController.h"
#import "TAPProfileViewController.h"
#import "TAPCustomNotificationAlertViewController.h"
#import "TAPCustomKeyboardItemModel.h"

NS_ASSUME_NONNULL_BEGIN

//==========================================================
//                 TapUIChatRoomDelegate
//==========================================================
@protocol TapUIChatRoomDelegate <NSObject>
@optional
/**
 Called when user click the profile button on the top right side of personal chat room page.
 
 @param viewController (UIViewController *) current shown view controller
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
 
 @param viewController (UIViewController *) current shown view controller
 @param room (TAPRoomModel *) room data that will be shown
 @param currentNavigationController (TapUserModel *) current shown navigation controller, you can handle push or push using this navigation controller
 */
- (void)tapTalkGroupChatRoomProfileButtonTapped:(UIViewController *)currentViewController
                                           room:(TAPRoomModel *)room
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
 Called when user click the profile button on the top right side of group chat room page.
 
 @param currentViewController (UIViewController *) current shown view controller
 @param currentNavigationController (TapUserModel *) current shown navigation controller, you can handle push or push using this navigation controller
 */
- (void)tapTalkAccountButtonTapped:(UIViewController *)currentViewController
  currentShownNavigationController:(UINavigationController *)currentNavigationController;
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


@interface TapUI : NSObject

@property (weak, nonatomic) UIWindow *activeWindow;
@property (weak, nonatomic) id<TapUIChatRoomDelegate> chatRoomDelegate;
@property (weak, nonatomic) id<TapUIRoomListDelegate> roomListDelegate;
@property (weak, nonatomic) id<TapUICustomKeyboardDelegate> customKeyboardDelegate;

@property (nonatomic) BOOL isLogoutButtonVisible;

//Initalization
+ (TapUI *)sharedInstance;

//Property
- (TapUIRoomListViewController *)roomListViewController;
- (TAPCustomNotificationAlertViewController *)customNotificationAlertViewController;

//==========================================================
//                 Windows & View Controllers
//==========================================================
/**
 Set user active window to activate in app notification view on top of current user defined window
 */
- (void)activateInAppNotificationInWindow:(UIWindow *)activeWindow;

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
- (void)addCustomBubbleWithClassName:(NSString *)className type:(NSInteger)type delegate:(id)delegate;

//==========================================================
//                       Room List
//==========================================================
/**
 Show my account on top left of room list view (near search bar)
 The default value is shown
 */
- (void)setMyAccountButtonInRoomListVisible:(BOOL)isVisible;

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

@end

NS_ASSUME_NONNULL_END
