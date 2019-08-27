//
//  TapUI.m
//  
//
//  Created by Dominic Vedericho on 24/07/19.
//

#import "TapUI.h"

@interface TapUI ()

@property (strong, nonatomic) TAPRoomListViewController *roomListViewController;
@property (strong, nonatomic) TAPCustomNotificationAlertViewController *customNotificationAlertViewController;

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
        _roomListViewController = [[TAPRoomListViewController alloc] init];
        _customNotificationAlertViewController = [[TAPCustomNotificationAlertViewController alloc] init];
        _activeWindow = [[UIWindow alloc] init];
    }
    
    return self;
}

#pragma mark - Property
- (TAPRoomListViewController *)roomListViewController {
    return _roomListViewController;
}

- (TAPCustomNotificationAlertViewController *)customNotificationAlertViewController {
    return _customNotificationAlertViewController;
}

- (TAPCustomKeyboardManager *)customKeyboardManager {
    return [TAPCustomKeyboardManager sharedManager];
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
- (void)addCustomBubbleWithClassName:(NSString *)className type:(NSInteger)type delegate:(id)delegate {
    [[TAPCustomBubbleManager sharedManager] addCustomBubbleDataWithCellName:className type:type delegate:delegate];
}

//Open Chat Room
- (TAPChatViewController *)openRoomWithOtherUser:(TAPUserModel *)otherUser {
    TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:otherUser];
    //    [[TAPChatManager sharedManager] openRoom:room]; //Called in ChatViewController willAppear
    
    //Save all unsent message (in case user retrieve message on another room)
    [[TAPChatManager sharedManager] saveAllUnsentMessage];
    
    //Save user to ContactManager Dictionary
    [[TAPContactManager sharedManager] addContactWithUserModel:otherUser saveToDatabase:NO];
    
    TAPChatViewController *chatViewController = [[TAPChatViewController alloc] initWithNibName:@"TAPChatViewController" bundle:[TAPUtil currentBundle]];
    chatViewController.currentRoom = room;
    chatViewController.delegate = [[TapUI sharedInstance] roomListViewController];
    return chatViewController;
}

- (void)openRoomWithUserID:(NSString *)userID
             prefilledText:(NSString *)prefilledText
          customQuoteTitle:(nullable NSString *)customQuoteTitle
        customQuoteContent:(nullable NSString *)customQuoteContent
 customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                  userInfo:(nullable NSDictionary *)userInfo
                   success:(void (^)(TAPChatViewController *chatViewController))success
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
            TAPChatViewController *obtainedChatViewController = [self openRoomWithOtherUser:obtainedUser];
            success(obtainedChatViewController);
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
                TAPChatViewController *obtainedChatViewController = [self openRoomWithOtherUser:user];
                success(obtainedChatViewController);
                
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

- (void)openRoomWithXCUserID:(NSString *)XCUserID
               prefilledText:(NSString *)prefilledText
            customQuoteTitle:(nullable NSString *)customQuoteTitle
          customQuoteContent:(nullable NSString *)customQuoteContent
   customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                    userInfo:(nullable NSDictionary *)userInfo
                     success:(void (^)(TAPChatViewController *chatViewController))success
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
            TAPChatViewController *obtainedChatViewController = [self openRoomWithOtherUser:obtainedUser];
            success(obtainedChatViewController);
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
                TAPChatViewController *obtainedChatViewController = [self openRoomWithOtherUser:user];
                success(obtainedChatViewController);

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

- (TAPChatViewController *)openRoomWithRoom:(TAPRoomModel *)room
                           customQuoteTitle:(nullable NSString *)customQuoteTitle
                         customQuoteContent:(nullable NSString *)customQuoteContent
                  customQuoteImageURLString:(nullable NSString *)customQuoteImageURL
                                   userInfo:(nullable NSDictionary *)userInfo {
    
    //Create quote model and set quote to chat
    if (![customQuoteTitle isEqualToString:@""] && customQuoteTitle != nil) {
        TAPQuoteModel *quote = [TAPQuoteModel new];
        quote.title = customQuoteTitle;
        quote.content = customQuoteContent;
        quote.imageURL = customQuoteImageURL;
        
        [[TAPChatManager sharedManager] saveToQuotedMessage:quote userInfo:userInfo roomID:room.roomID];
    }
    
    //Open room
    return [self openRoomWithRoom:room];
}

- (TAPChatViewController *)openRoomWithRoom:(TAPRoomModel *)room {
    return [self openRoomWithRoom:room scrollToMessageWithLocalID:nil];
}

- (TAPChatViewController *)openRoomWithRoom:(TAPRoomModel *)room
                 scrollToMessageWithLocalID:(NSString *)messageLocalID {
    //Save all unsent message (in case user retrieve message on another room)
    [[TAPChatManager sharedManager] saveAllUnsentMessage];
    
    TAPChatViewController *chatViewController = [[TAPChatViewController alloc] initWithNibName:@"TAPChatViewController" bundle:[TAPUtil currentBundle]];
    chatViewController.currentRoom = room;
    chatViewController.delegate = [[TapUI sharedInstance] roomListViewController];
    chatViewController.scrollToMessageLocalIDString = messageLocalID;
    return chatViewController;
}

@end
