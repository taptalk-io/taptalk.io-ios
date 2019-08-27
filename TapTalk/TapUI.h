//
//  TapUI.h
//  
//
//  Created by Dominic Vedericho on 24/07/19.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "TAPLoginViewController.h"
#import "TAPRoomListViewController.h"
#import "TAPCustomNotificationAlertViewController.h"

#import "TAPCustomKeyboardManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TapUIDelegate <NSObject>
@optional

//Chat Room Profile
/**
 Called when user click the profile button on the top right side of the chat room page.
 
 @param viewController (UIViewController) view controller that will be shown
 @param otherUser (TapUserModel *) user data that will be shown
 @param currentNavigationController (TapUserModel *) current shown navigation controller, you can handle push or push using this navigation controller

 */
- (void)tapTalkChatRoomProfileButtonTapped:(UIViewController *)viewController
                                 otherUser:(TAPUserModel *)otherUser
          currentShownNavigationController:(UINavigationController *)currentNavigationController;

//Message Quote
/**
 Called when user click the quote view that appears in the chat bubble.
 
 @param userInfo (NSDictionary *) other data or details of custom quote
 */
- (void)tapTalkMessageQuoteTappedWithUserInfo:(NSDictionary *)userInfo;
@end

@interface TapUI : NSObject

@property (weak, nonatomic) UIWindow *activeWindow;
@property (weak, nonatomic) id<TapUIDelegate> delegate;

//Initalization
+ (TapUI *)sharedInstance;

//Property
- (TAPRoomListViewController *)roomListViewController;
- (TAPCustomNotificationAlertViewController *)customNotificationAlertViewController;
- (TAPCustomKeyboardManager *)customKeyboardManager;

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
//                      Open Chat Room
//==========================================================
/**
 Open chat room with provided user
 
 @param otherUser (TapUserModel *) user data that will be shown
 */
- (TAPChatViewController *)openRoomWithOtherUser:(TAPUserModel *)otherUser;

/**
 Open chat room with TapTalk.io user ID
 
 @param userID (NSString *) client user ID
 @param prefilledText (NSString *) prefilled text of message
 @param customQuoteTitle (NSString *) title of custom quote data
 @param customQuoteContent (NSString *) content / subtitle of custom quote data
 @param customQuoteImageURL (NSString *) image url string of custom quote image
 @param userInfo (NSString *) other data or details of custom quote
 */
- (void)openRoomWithUserID:(NSString *)userID
             prefilledText:(NSString *)prefilledText
          customQuoteTitle:(nullable NSString *)customQuoteTitle
        customQuoteContent:(nullable NSString *)customQuoteContent
 customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                  userInfo:(nullable NSDictionary *)userInfo
                   success:(void (^)(TAPChatViewController *chatViewController))success
                   failure:(void (^)(NSError *error))failure;

/**
 Open chat room with client user ID
 
 @param XCUserID (NSString *) client user ID
 @param prefilledText (NSString *) prefilled text of message
 @param customQuoteTitle (NSString *) title of custom quote data
 @param customQuoteContent (NSString *) content / subtitle of custom quote data
 @param customQuoteImageURL (NSString *) image url of custom quote image
 @param userInfo (NSString *) other data or details of custom quote
 */
- (void)openRoomWithXCUserID:(NSString *)XCUserID
               prefilledText:(NSString *)prefilledText
            customQuoteTitle:(nullable NSString *)customQuoteTitle
          customQuoteContent:(nullable NSString *)customQuoteContent
   customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                    userInfo:(nullable NSDictionary *)userInfo
                     success:(void (^)(TAPChatViewController *chatViewController))success
                     failure:(void (^)(NSError *error))failure;

/**
 Open chat room with provided room
 
 @param room (TAPRoomModel *) room that will be opened
 @param customQuoteTitle (NSString *) title of custom quote data
 @param customQuoteContent (NSString *) content / subtitle of custom quote data
 @param customQuoteImageURL (NSString *) image url of custom quote image
 @param userInfo (NSString *) other data or details of custom quote
 */
- (TAPChatViewController *)openRoomWithRoom:(TAPRoomModel *)room
                           customQuoteTitle:(nullable NSString *)customQuoteTitle
                         customQuoteContent:(nullable NSString *)customQuoteContent
                  customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                                   userInfo:(nullable NSDictionary *)userInfo;

/**
 Open chat room with provided room
 
 @param room (TAPRoomModel *) room that will be opened
 */
- (TAPChatViewController *)openRoomWithRoom:(TAPRoomModel *)room;

/**
 Open chat room with provided room and scroll to certain message
 
 @param room (TAPRoomModel *) room that will be opened
 @param messageLocalID (NSString *) scrolled to selected message with provided message ID
 */
- (TAPChatViewController *)openRoomWithRoom:(TAPRoomModel *)room
                 scrollToMessageWithLocalID:(NSString *)messageLocalID;


@end

NS_ASSUME_NONNULL_END
