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

//Chat Room Profile
- (void)tapTalkChatRoomProfileButtonTapped:(UIViewController *)viewController
                                 otherUser:(TAPUserModel *)otherUser;

//Message Quote
- (void)tapTalkMessageQuoteTappedWithUserInfo:(NSDictionary *)userInfo;

//Product List Button
- (void)tapTalkProductListBubbleLeftButtonTapped:(TAPProductModel *)product room:(TAPRoomModel *)room recipient:(TAPUserModel *)recipient isSingleOption:(BOOL)isSingleOption;

- (void)tapTalkProductListBubbleRightButtonTapped:(TAPProductModel *)product room:(TAPRoomModel *)room recipient:(TAPUserModel *)recipient isSingleOption:(BOOL)isSingleOption;

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

//Windows & View Controllers
- (void)activateInAppNotificationInWindow:(UIWindow *)activeWindow;
- (UINavigationController *)getCurrentTapTalkActiveNavigationController;
- (UIViewController *)getCurrentTapTalkActiveViewController;

//Custom Bubble
- (void)addCustomBubbleWithClassName:(NSString *)className type:(NSInteger)type delegate:(id)delegate;

//Open Chat Room
- (TAPChatViewController *)openRoomWithOtherUser:(TAPUserModel *)otherUser;

- (void)openRoomWithXCUserID:(NSString *)XCUserID
               prefilledText:(NSString *)prefilledText
                  quoteTitle:(nullable NSString *)quoteTitle
                quoteContent:(nullable NSString *)quoteContent
         quoteImageURLString:(nullable NSString *)quoteImageURL
                    userInfo:(nullable NSDictionary *)userInfo
                     success:(void (^)(TAPChatViewController *chatViewController))success
                     failure:(void (^)(NSError *error))failure;
- (TAPChatViewController *)openRoomWithRoom:(TAPRoomModel *)room
                                 quoteTitle:(nullable NSString *)quoteTitle
                               quoteContent:(nullable NSString *)quoteContent
                        quoteImageURLString:(nullable NSString *)quoteImageURL
                                   userInfo:(nullable NSDictionary *)userInfo;
- (TAPChatViewController *)openRoomWithRoom:(TAPRoomModel *)room;
- (TAPChatViewController *)openRoomWithRoom:(TAPRoomModel *)room
                 scrollToMessageWithLocalID:(NSString *)messageLocalID;


@end

NS_ASSUME_NONNULL_END
