//
//  TapTalk.m
//  TapTalk
//
//  Created by Ritchie Nathaniel on 11/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TapTalk.h"
#import "TAPProfileViewController.h"

@import AFNetworking;
@import GooglePlaces;
@import GoogleMaps;

@interface TapTalk () <TAPNotificationManagerDelegate>

- (void)firstRunSetupWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions;
- (void)resetPersistent;

@property (strong, nonatomic) TAPRoomListViewController *roomListViewController;
@property (strong, nonatomic) TAPCustomNotificationAlertViewController *customNotificationAlertViewController;

- (NSArray *)convertProductModelToDictionaryWithData:(NSArray *)productModelArray;
- (NSArray *)convertDictionaryToProductModelWithData:(NSArray *)productDictionaryArray;
- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController;

@end

@implementation TapTalk

#pragma mark - Lifecycle
+ (TAPConnectionManager *)sharedInstance {
    static TAPConnectionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        //Set secret for NSSecureUserDefaults
        [NSUserDefaults setSecret:TAP_SECURE_KEY_NSUSERDEFAULTS];
        
        _roomListViewController = [[TAPRoomListViewController alloc] init];
        _customNotificationAlertViewController = [[TAPCustomNotificationAlertViewController alloc] init];
        _activeWindow = [[UIWindow alloc] init];
        
        //Add notification manager delegate
        [TAPNotificationManager sharedManager].delegate = self;
        
    }
    
    return self;
}

#pragma mark - Authentication
- (void)setAuthTicket:(NSString *)authTicket
              success:(void (^)(void))success
              failure:(void (^)(NSError *error))failure {
    
    if (authTicket == nil || [authTicket isEqualToString:@""]) {
        NSMutableDictionary *errorDictionary = [NSMutableDictionary dictionary];
        [errorDictionary setObject:@"Invalid Auth Ticket" forKey:@"message"];
        [errorDictionary setObject:@"401" forKey:@"code"];
        NSError *error = [NSError errorWithDomain:@"Invalid Auth Ticket" code:401 userInfo:errorDictionary];
        failure(error);
    }
    
    [TAPDataManager callAPIGetAccessTokenWithAuthTicket:authTicket success:^{
        //Send Push Token to server
        NSString *pushToken = [[TAPNotificationManager sharedManager] pushToken];
        
        if (pushToken != nil) {

            BOOL isDebug = NO;
#ifdef DEBUG
            isDebug = YES;
#else
            isDebug = NO;
#endif
            
            [TAPDataManager callAPIUpdatePushNotificationWithToken:pushToken isDebug:isDebug success:^{
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_PUSH_TOKEN];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } failure:^(NSError *error) {
                
            }];
        }
        
        [[TAPChatManager sharedManager] connect];
        
        //Refresh Contact List
        [TAPDataManager callAPIGetContactList:^(NSArray *userArray) {
            
        } failure:^(NSError *error) {
            //        NSLog(@"%@", error);
        }];
        
        //First chat initialization on login
        self.roomListViewController.isShouldNotLoadFromAPI = NO;
        [self.roomListViewController viewLoadedSequence];
        
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (BOOL)isAuthenticated {
    NSString *accessToken = [TAPDataManager getAccessToken];
    
    if (accessToken == nil || [accessToken isEqualToString:@""]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Property
- (TAPRoomListViewController *)roomListViewController {
    return _roomListViewController;
}

- (TAPCustomNotificationAlertViewController *)customNotificationAlertViewController {
    return _customNotificationAlertViewController;
}

- (TAPLoginViewController *)loginViewController {
    TAPLoginViewController *loginViewController = [[TAPLoginViewController alloc] init];
    
    return loginViewController;
}
//END RN Temp

#pragma mark - AppDelegate Handling
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions environment:(TapTalkEnvironment)environment {
    // Override point for customization after application launch.
    _environment = environment;
    
    [self firstRunSetupWithApplication:application launchOptions:launchOptions];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_DID_FINISH_LAUNCHING object:application];
    
    //Update to isFailedSend = 1
    [[TAPChatManager sharedManager] updateSendingMessageToFailed];
    
    //Clean database message that is more than 1 month old every 1 week.
    [TAPOldDataManager runCleaningOldDataSequence];
    
    //Set TapTalk Environment to ConnectionManager (For define SocketURL)
    [[TAPConnectionManager sharedManager] setSocketURLWithTapTalkEnvironment:self.environment];
    
    //Validate and refresh access token
    [[TAPConnectionManager sharedManager] validateToken];
    
    //Populate User Country Code
    [[TAPContactManager sharedManager] populateContactFromDatabase];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_WILL_RESIGN_ACTIVE object:application];
    
    //Update application notification bubble
    [[TAPNotificationManager sharedManager] updateApplicationBadgeCount];
    [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToPreference];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_DID_ENTER_BACKGROUND object:application];
    
    //Run update message sequence when enter background
    [[TAPChatManager sharedManager] runEnterBackgroundSequenceWithApplication:application];
    
    //Send stop typing emit
    [[TAPChatManager sharedManager] stopTyping];
    
    //Clear all contact dictionary in ContactCacheManager
//    [[TAPContactCacheManager sharedManager] clearContactDictionary];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_WILL_ENTER_FOREGROUND object:application];
    
    //Remove all read count on MessageStatusManager because the room list is reloaded from database
    [[TAPMessageStatusManager sharedManager] clearReadCountDictionary];
    
    //Call to run room list view controller sequence
    self.roomListViewController.isShouldNotLoadFromAPI = NO;
    [self.roomListViewController viewLoadedSequence];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE object:application];
    
    _instanceState = TapTalkInstanceStateActive;

    [[TAPChatManager sharedManager] removeAllBackgroundSequenceTaskWithApplication:application];

    if ([TAPChatManager sharedManager].activeUser != nil) {
        //User active
        [[TAPConnectionManager sharedManager] connect];
    }

    //Start trigger timer to save new message
    [[TAPChatManager sharedManager] triggerSaveNewMessage];
    
    //Obtain downloaded file path from preference
    [[TAPFileDownloadManager sharedManager] fetchDownloadedFilePathFromPreference];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_WILL_TERMINATE object:application];
    
    [[TAPChatManager sharedManager] saveIncomingMessageAndDisconnect];
    _instanceState = TapTalkInstanceStateInactive;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *pushToken = [deviceToken description];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"PUSH TOKEN: %@", pushToken);
    
    [[TAPNotificationManager sharedManager] setPushToken:pushToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    [[TAPNotificationManager sharedManager] handlePushNotificationWithUserInfo:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        return;
    }
    
    NSDictionary *userInfo = [[notification userInfo] objectForKey:@"data"];
    
//    [self handleOpenAppsFromNotificationWithUserInfo:userInfo];
}

#pragma mark - Push Notification
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    //Called when a notification is delivered to a foreground app.
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

//Called to let your app know which action was selected by the user for a given notification.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    //Called when a notification is delivered to a foreground app.
    
    NSDictionary *userInfoDictionary = response.notification.request.content.userInfo;
    NSDictionary *messageDictionary = [userInfoDictionary valueForKeyPath:@"data.message"];
    TAPMessageModel *message = [TAPDataManager messageModelFromPayloadWithUserInfo:messageDictionary];
    
    [[TAPNotificationManager sharedManager] handleTappedNotificationWithUserInfo:messageDictionary];
    
    completionHandler();
}

#pragma mark - Exception Handling
- (void)handleException:(NSException *)exception {
    [[TAPChatManager sharedManager] saveUnsentMessageAndDisconnect];
    
    //Save all retrieved contact to database
    [[TAPContactManager sharedManager] saveContactToDatabase];
    
    //Save downloaded file path to preference
    [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToPreference];
    
    _instanceState = TapTalkInstanceStateInactive;
    
    //Send stop typing emit
    [[TAPChatManager sharedManager] stopTyping];
}

#pragma mark - First Run Setup
- (void)firstRunSetupWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    id versionObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"Prefs.appVersion"];
    
    NSString *versionFromPrefs = @"";
    
    if ([versionObject isKindOfClass:[NSNumber class]]) {
        versionFromPrefs = [versionObject stringValue];
    }
    else if ([versionObject isKindOfClass:[NSString class]]) {
        versionFromPrefs = versionObject;
    }
    
    if (versionFromPrefs == nil || [versionFromPrefs isEqualToString:@""]){
        [self resetPersistent];
    }
    else if (APP_VERSION_GREATER_THAN(versionFromPrefs)) {
        
    }
    else {
        
    }
    
    //Other initialization
    [TAPNetworkManager sharedManager];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //Google API Key
    [GMSPlacesClient provideAPIKey:@"AIzaSyC6PNBIZsFfQZ5OQm4MFElW98hk8JIjaYk"];
    [GMSServices provideAPIKey:@"AIzaSyC6PNBIZsFfQZ5OQm4MFElW98hk8JIjaYk"];
}

- (void)resetPersistent {
    //Set initial refresh rate
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Delegate
#pragma mark TAPNotificationManager
- (void)notificationManagerDidHandleTappedNotificationWithMessage:(TAPMessageModel *)message {
    
    //Save user to ContactManager Dictionary
    [[TAPContactManager sharedManager] addContactWithUserModel:message.user saveToDatabase:NO];
    
    UIViewController *currentActiveController = [[TapTalk sharedInstance] getCurrentTapTalkActiveViewController];
    if ([self.delegate respondsToSelector:@selector(tapTalkDidTappedNotificationWithMessage:fromActiveController:)]) {
        [self.delegate tapTalkDidTappedNotificationWithMessage:message fromActiveController:currentActiveController];
    }
}

#pragma mark - Custom Method
//General Set Up
- (void)setEnvironment:(TapTalkEnvironment)environment {
    _environment = environment;
    NSLog(@"ENVIRONMENT TYPE = %ld", self.environment);
    
    //Set Socket URL Environment
    [[TAPConnectionManager sharedManager] setSocketURLWithTapTalkEnvironment:self.environment];
}  

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

- (void)setUserAgent:(NSString *)userAgent {
    [[NSUserDefaults standardUserDefaults] setSecureObject:userAgent forKey:TAP_PREFS_USER_AGENT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAppKeySecret:(NSString *)appKeySecret {
    [[NSUserDefaults standardUserDefaults] setSecureObject:appKeySecret forKey:TAP_PREFS_APP_KEY_SECRET];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setAppKeyID:(NSString *)appKeyID {
    [[NSUserDefaults standardUserDefaults] setSecureObject:appKeyID forKey:TAP_PREFS_APP_KEY_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)refreshActiveUser {
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    
    if (currentUser == nil) {
        return;
    }
    
    NSString *userID = currentUser.userID;
    [TAPDataManager callAPIGetUserByUserID:userID success:^(TAPUserModel *user) {
        if (user != nil) {
            //Save to prefs
            [TAPDataManager setActiveUser:user];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)updateUnreadBadgeCount {
    [[TAPNotificationManager sharedManager] updateApplicationBadgeCount];
}

//Chat
- (void)openRoomWithXCUserID:(NSString *)XCUserID
               prefilledText:(NSString *)prefilledText
                  quoteTitle:(nullable NSString *)quoteTitle
                quoteContent:(nullable NSString *)quoteContent
         quoteImageURLString:(nullable NSString *)quoteImageURL
                    userInfo:(nullable NSDictionary *)userInfo
    fromNavigationController:(UINavigationController *)navigationController
                     success:(void (^)(void))success
                     failure:(void (^)(NSError *error))failure {
    //Check is user exist in TapTalk database
    [TAPDataManager getDatabaseContactByXCUserID:XCUserID success:^(BOOL isContact, TAPUserModel *obtainedUser) {
        if (isContact) {
            //User is in contact
            //Create quote model and set quote to chat
            
            TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:obtainedUser];
            
            if (![quoteTitle isEqualToString:@""] && quoteTitle != nil) {
                TAPQuoteModel *quote = [TAPQuoteModel new];
                quote.title = quoteTitle;
                quote.content = quoteContent;
                quote.imageURL = quoteImageURL;
                
                [[TAPChatManager sharedManager] saveToQuotedMessage:quote userInfo:userInfo roomID:room.roomID];
            }
            
            NSString *draftMessage = [TAPUtil nullToEmptyString:prefilledText];
            if (![draftMessage isEqualToString:@""]) {
                 [[TAPChatManager sharedManager] saveMessageToDraftWithMessage:draftMessage roomID:room.roomID];
            }
            
            //Open room
            [self openRoomWithOtherUser:obtainedUser fromNavigationController:navigationController];
            success();
        }
        else {
            //User not in contact, call API to obtain user data
            [TAPDataManager callAPIGetUserByXCUserID:XCUserID success:^(TAPUserModel *user) {
                //Create quote model and set quote to chat
                TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:user];
                
                //Save user to ContactManager Dictionary
                [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO];
                
                if (![quoteTitle isEqualToString:@""] && quoteTitle != nil) {
                    TAPQuoteModel *quote = [TAPQuoteModel new];
                    quote.title = quoteTitle;
                    quote.content = quoteContent;
                    quote.imageURL = quoteImageURL;
                    
                    [[TAPChatManager sharedManager] saveToQuotedMessage:quote userInfo:userInfo roomID:room.roomID];
                }
                
                NSString *draftMessage = [TAPUtil nullToEmptyString:prefilledText];
                if (![draftMessage isEqualToString:@""]) {
                    [[TAPChatManager sharedManager] saveMessageToDraftWithMessage:draftMessage roomID:room.roomID];
                }
                
                //Open room
                [self openRoomWithOtherUser:user fromNavigationController:navigationController];
                success();
            } failure:^(NSError *error) {
                failure(error);
            }];
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)openRoomWithOtherUser:(TAPUserModel *)otherUser
     fromNavigationController:(UINavigationController *)navigationController {
    TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:otherUser];
    [[TAPChatManager sharedManager] openRoom:room];
    
    //Save all unsent message (in case user retrieve message on another room)
    [[TAPChatManager sharedManager] saveAllUnsentMessage];
    
    //Save user to ContactManager Dictionary
    [[TAPContactManager sharedManager] addContactWithUserModel:otherUser saveToDatabase:NO];
    
    TAPChatViewController *chatViewController = [[TAPChatViewController alloc] initWithNibName:@"TAPChatViewController" bundle:[TAPUtil currentBundle]];
    chatViewController.currentRoom = room;
    chatViewController.delegate = [[TapTalk sharedInstance] roomListViewController];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [navigationController pushViewController:chatViewController animated:YES];
}

- (void)openRoomWithRoom:(TAPRoomModel *)room
              quoteTitle:(nullable NSString *)quoteTitle
            quoteContent:(nullable NSString *)quoteContent
     quoteImageURLString:(nullable NSString *)quoteImageURL
                userInfo:(nullable NSDictionary *)userInfo
fromNavigationController:(UINavigationController *)navigationController
                animated:(BOOL)isAnimated {

    //Create quote model and set quote to chat
    if (![quoteTitle isEqualToString:@""] && quoteTitle != nil) {
        TAPQuoteModel *quote = [TAPQuoteModel new];
        quote.title = quoteTitle;
        quote.content = quoteContent;
        quote.imageURL = quoteImageURL;
        
        [[TAPChatManager sharedManager] saveToQuotedMessage:quote userInfo:userInfo roomID:room.roomID];
    }

    //Open room
    [self openRoomWithRoom:room fromNavigationController:navigationController animated:isAnimated];
}

- (void)openRoomWithRoom:(TAPRoomModel *)room
fromNavigationController:(UINavigationController *)navigationController
                animated:(BOOL)isAnimated {
    [[TAPChatManager sharedManager] openRoom:room];
    
    //Save all unsent message (in case user retrieve message on another room)
    [[TAPChatManager sharedManager] saveAllUnsentMessage];
    
    TAPChatViewController *chatViewController = [[TAPChatViewController alloc] initWithNibName:@"TAPChatViewController" bundle:[TAPUtil currentBundle]];
    chatViewController.currentRoom = room;
    chatViewController.delegate = [[TapTalk sharedInstance] roomListViewController];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [navigationController pushViewController:chatViewController animated:isAnimated];
}

- (void)sendTextMessage:(NSString *)message recipientUser:(TAPUserModel *)recipient success:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:recipient];    
    [[TAPChatManager sharedManager] sendTextMessage:message room:room];
    success();
}

- (void)sendProductMessage:(NSArray<TAPProductModel *> *)productArray recipientUser:(TAPUserModel *)recipient success:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
    NSArray *convertedProductArray = [self convertProductModelToDictionaryWithData:productArray];
    TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:recipient];
    TAPMessageModel *message = [TAPMessageModel createMessageWithUser:recipient room:room body:@"Product List" type:TAPChatMessageTypeProduct];

    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    [dataDictionary setObject:convertedProductArray forKey:@"items"];
    
    message.data = dataDictionary;

    [[TAPChatManager sharedManager] sendProductMessage:message];
    success();
}

- (void)sendImageMessage:(UIImage *)image caption:(nullable NSString *)caption recipientUser:(TAPUserModel *)recipient success:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:recipient];
    
    NSString *captionString = @"";
    if (caption != nil) {
        captionString = caption;
    }
    
    [[TAPChatManager sharedManager] sendImageMessage:image caption:captionString room:room];
    success();
}

- (void)sendImageMessageWithAsset:(PHAsset *)asset caption:(nullable NSString *)caption recipientUser:(TAPUserModel *)recipient success:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:recipient];
    
    NSString *captionString = @"";
    if (caption != nil) {
        captionString = caption;
    }
    
    [[TAPChatManager sharedManager] sendImageMessageWithPHAsset:asset caption:caption room:room];
    success();
}

- (void)shouldRefreshAuthTicket {
    [[TAPChatManager sharedManager] disconnect];
    
    if ([self.delegate respondsToSelector:@selector(tapTalkShouldResetAuthTicket)]) {
        [self.delegate tapTalkShouldResetAuthTicket];
    }
}

//Custom Keyboard
- (NSArray *)getCustomKeyboardWithSender:(TAPUserModel *)sender recipient:(TAPUserModel *)recipient {
    if([self.delegate respondsToSelector:@selector(tapTalkCustomKeyboardForSender:recipient:)]) {
        return [self.delegate tapTalkCustomKeyboardForSender:sender recipient:recipient];
    }
    
    return [NSArray array];
}

- (void)customKeyboardDidTappedWithSender:(TAPUserModel *)sender
                                recipient:(TAPUserModel *)recipient
                             keyboardItem:(TAPCustomKeyboardItemModel *)keyboardItem {
    if ([self.delegate respondsToSelector:@selector(tapTalkCustomKeyboardDidTappedWithSender:recipient:room:keyboardItem:)]) {
        
        TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
        
        [self.delegate tapTalkCustomKeyboardDidTappedWithSender:sender recipient:recipient room:room keyboardItem:keyboardItem];
    }
}

//Custom Bubble
- (void)addCustomBubbleDataWithClassName:(NSString *)className type:(NSInteger)type delegate:(id)delegate {
    [[TAPCustomBubbleManager sharedManager] addCustomBubbleDataWithCellName:className type:type delegate:delegate];
}

//Custom Quote
- (void)quoteDidTappedWithUserInfo:(NSDictionary *)userInfo {
    NSLog(@"QUOTE TAPPED -- %@", userInfo);
    if ([self.delegate respondsToSelector:@selector(tapTalkQuoteDidTappedWithUserInfo:)]) {
        [self.delegate tapTalkQuoteDidTappedWithUserInfo:userInfo];
    }
}

- (NSArray *)convertProductModelToDictionaryWithData:(NSArray *)productModelArray {
    NSMutableArray *convertedProductArray = [[NSMutableArray alloc] init];
    
    for (TAPProductModel *product in productModelArray) {
        NSString *productID = product.productDataID;
        productID = [TAPUtil nullToEmptyString:productID];
        
        NSString *productNameString = product.productName;
        productNameString = [TAPUtil nullToEmptyString:productNameString];
        
        NSString *currencyString = product.productCurrency;
        currencyString = [TAPUtil nullToEmptyString:currencyString];
        
        NSString *priceString = product.productPrice;
        priceString = [TAPUtil nullToEmptyString:priceString];
        
        NSString *ratingString = product.productRating;
        ratingString = [TAPUtil nullToEmptyString:ratingString];
        
        NSString *weightString = product.productWeight;
        weightString = [TAPUtil nullToEmptyString:weightString];
        
        NSString *productDescriptionString = product.productDescription;
        productDescriptionString = [TAPUtil nullToEmptyString:productDescriptionString];
        
        NSString *productImageURLString = product.productImageURL;
        productImageURLString = [TAPUtil nullToEmptyString:productImageURLString];
        
        NSString *leftOptionTextString = product.buttonOption1Text;
        leftOptionTextString = [TAPUtil nullToEmptyString:leftOptionTextString];
        
        NSString *rightOptionTextString = product.buttonOption2Text;
        rightOptionTextString = [TAPUtil nullToEmptyString:rightOptionTextString];
        
        NSString *leftOptionColorString = product.buttonOption1Color;
        leftOptionColorString = [TAPUtil nullToEmptyString:leftOptionColorString];
        
        NSString *rightOptionColorString = product.buttonOption2Color;
        rightOptionColorString = [TAPUtil nullToEmptyString:rightOptionColorString];
        
        NSMutableDictionary *productDictionary = [[NSMutableDictionary alloc] init];
        [productDictionary setObject:productID forKey:@"id"];
        [productDictionary setObject:productNameString forKey:@"name"];
        [productDictionary setObject:currencyString forKey:@"currency"];
        [productDictionary setObject:priceString forKey:@"price"];
        [productDictionary setObject:ratingString forKey:@"rating"];
        [productDictionary setObject:weightString forKey:@"weight"];
        [productDictionary setObject:productDescriptionString forKey:@"description"];
        [productDictionary setObject:productImageURLString forKey:@"imageURL"];
        [productDictionary setObject:leftOptionTextString forKey:@"buttonOption1Text"];
        [productDictionary setObject:rightOptionTextString forKey:@"buttonOption2Text"];
        [productDictionary setObject:leftOptionColorString forKey:@"buttonOption1Color"];
        [productDictionary setObject:rightOptionColorString forKey:@"buttonOption2Color"];
        
        [convertedProductArray addObject:productDictionary];
    }
    
    return convertedProductArray;
}

- (NSArray *)convertDictionaryToProductModelWithData:(NSArray *)productDictionaryArray {
    NSMutableArray *convertedProductArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *productDictionary in productDictionaryArray) {
        NSString *productID = [productDictionary objectForKey:@"id"];
        productID = [TAPUtil nullToEmptyString:productID];
        
        NSString *productNameString = [productDictionary objectForKey:@"name"];
        productNameString = [TAPUtil nullToEmptyString:productNameString];
        
        NSString *currencyString = [productDictionary objectForKey:@"currency"];
        currencyString = [TAPUtil nullToEmptyString:currencyString];
        
        NSString *priceString = [productDictionary objectForKey:@"price"];
        priceString = [TAPUtil nullToEmptyString:priceString];
        
        NSString *ratingString = [productDictionary objectForKey:@"rating"];
        ratingString = [TAPUtil nullToEmptyString:ratingString];
        
        NSString *weightString = [productDictionary objectForKey:@"weight"];
        weightString = [TAPUtil nullToEmptyString:weightString];
        
        NSString *productDescriptionString = [productDictionary objectForKey:@"description"];
        productDescriptionString = [TAPUtil nullToEmptyString:productDescriptionString];
        
        NSString *productImageURLString = [productDictionary objectForKey:@"imageURL"];
        productImageURLString = [TAPUtil nullToEmptyString:productImageURLString];
        
        NSString *leftOptionTextString = [productDictionary objectForKey:@"buttonOption1Text"];
        leftOptionTextString = [TAPUtil nullToEmptyString:leftOptionTextString];
        
        NSString *rightOptionTextString = [productDictionary objectForKey:@"buttonOption2Text"];
        rightOptionTextString = [TAPUtil nullToEmptyString:rightOptionTextString];
        
        NSString *leftOptionColorString = [productDictionary objectForKey:@"buttonOption1Color"];
        leftOptionColorString = [TAPUtil nullToEmptyString:leftOptionColorString];
        
        NSString *rightOptionColorString = [productDictionary objectForKey:@"buttonOption2Color"];
        rightOptionColorString = [TAPUtil nullToEmptyString:rightOptionColorString];
        
        TAPProductModel *product = [TAPProductModel new];
        product.productDataID = productID;
        product.productName = productNameString;
        product.productCurrency = currencyString;
        product.productPrice = priceString;
        product.productRating = ratingString;
        product.productWeight = weightString;
        product.productDescription = productDescriptionString;
        product.productImageURL = productImageURLString;
        product.buttonOption1Text = leftOptionTextString;
        product.buttonOption2Text = rightOptionTextString;
        product.buttonOption1Color = leftOptionColorString;
        product.buttonOption2Color = rightOptionColorString;
        
        [convertedProductArray addObject:product];
    }
    
    return convertedProductArray;
}

//Other
- (void)logoutAndClearAllData {
    
    //Delete all data in database
    [TAPDatabaseManager deleteAllDataInDatabaseWithSuccess:^{
        
    } failure:^(NSError *error) {
        
    }];
    
    //Remove all preference
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_ACTIVE_USER];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_REFRESH_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_REFRESH_TOKEN_EXPIRED_TIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_ACCESS_TOKEN_EXPIRED_TIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_IS_DONE_FIRST_SETUP];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_LAST_UPDATED_CHAT_ROOM];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_LAST_DELETED_OLD_MESSAGE_TIMESTAMP];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_FILE_PATH_DICTIONARY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_COUNTRY_LIST_ARRAY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_COUNTRY_LIST_DICTIONARY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_LAST_UPDATED_COUNTRY_LIST_TIMESTAMP];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_USER_LOGIN_PHONE_TEMP_DICTIONARY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_USER_COUNTRY_CODE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_CONTACT_PERMISSION_ASKED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    TAPLoginViewController *loginViewController = [[TapTalk sharedInstance] loginViewController];
    [loginViewController presentLoginViewControllerIfNeededFromViewController:[[TapTalk sharedInstance] roomListViewController] force:YES];
}

//TapTalk Internal Usage Method
- (void)processingProductListLeftOrSingleOptionButtonTappedWithData:(NSArray *)dataArray isSingleOption:(BOOL)isSingleOption {
    
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:[TAPChatManager sharedManager].activeRoom.roomID];
    TAPUserModel *otherUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
    
    NSArray *convertedProductArray = [self convertDictionaryToProductModelWithData:dataArray];
    TAPProductModel *product = [convertedProductArray firstObject];
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    
    if ([self.delegate respondsToSelector:@selector(tapTalkProductListBubbleLeftOrSingleOptionDidTappedProduct:room:recipient:isSingleOption:)]) {
        [self.delegate tapTalkProductListBubbleLeftOrSingleOptionDidTappedProduct:product room:room recipient:otherUser isSingleOption:isSingleOption];
    }
}

- (void)processingProductListRightOptionButtonTappedWithData:(NSArray *)dataArray isSingleOption:(BOOL)isSingleOption {
    
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:[TAPChatManager sharedManager].activeRoom.roomID];
    TAPUserModel *otherUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
    
    NSArray *convertedProductArray = [self convertDictionaryToProductModelWithData:dataArray];
    TAPProductModel *product = [convertedProductArray firstObject];
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    
    if ([self.delegate respondsToSelector:@selector(tapTalkProductListBubbleRightOptionDidTappedWithProduct:room:recipient:isSingleOption:)]) {
        [self.delegate tapTalkProductListBubbleRightOptionDidTappedWithProduct:product room:room recipient:otherUser isSingleOption:isSingleOption];
    }
}

- (void)profileButtonDidTapped:(UIViewController *)activeViewController otherUser:(TAPUserModel *)otherUser {
    if ([self.delegate respondsToSelector:@selector(tapTalkProfileButtonDidTapped:otherUser:)]) {
        [self.delegate tapTalkProfileButtonDidTapped:activeViewController otherUser:otherUser];
    }
    else {
        NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:[TAPChatManager sharedManager].activeRoom.roomID];
        
        TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
        profileViewController.room = [TAPChatManager sharedManager].activeRoom;
        profileViewController.userID = otherUserID;
        [activeViewController.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (void)setBadgeWithNumberOfUnreadRooms:(NSInteger)numberOfUnreadRooms {
    if ([self.delegate respondsToSelector:@selector(tapTalkSetBadgeWithNumberOfUnreadRooms:)]) {
        [self.delegate tapTalkSetBadgeWithNumberOfUnreadRooms:numberOfUnreadRooms];
    }
}

- (void)getTapTalkUserWithClientUserID:(NSString *)clientUserID success:(void (^)(TAPUserModel *tapTalkUser))success failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetUserByXCUserID:clientUserID success:success failure:failure];
}

- (TAPUserModel *)getTapTalkActiveUser {
    return [TAPDataManager getActiveUser];
}

@end
