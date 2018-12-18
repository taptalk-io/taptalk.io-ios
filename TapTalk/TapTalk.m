//
//  TapTalk.m
//  TapTalk
//
//  Created by Ritchie Nathaniel on 11/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TapTalk.h"
#import "AFHTTPSessionManager.h"

@interface TapTalk () <TAPNotificationManagerDelegate>

- (void)firstRunSetupWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions;
- (void)resetPersistent;

@property (strong, nonatomic) TAPRoomListViewController *roomListViewController;
@property (strong, nonatomic) TAPCustomNotificationAlertViewController *customNotificationAlertViewController;

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

//RN Temp
- (TAPRegisterViewController *)registerViewController {
    TAPRegisterViewController *registerViewController = [[TAPRegisterViewController alloc] initWithNibName:@"TAPRegisterViewController" bundle:[TAPUtil currentBundle]];
    
    return registerViewController;
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
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_WILL_RESIGN_ACTIVE object:application];
    
    //Update application notification bubble
    [[TAPNotificationManager sharedManager] updateApplicationBadgeCount];
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
    
    
    //DV Temp
    //Temporary show log notification prefs
//    NSMutableArray *pushNotificationArray = [[NSMutableArray alloc] init];
//    pushNotificationArray = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_INCOMING_PUSH_NOTIFICATION valid:nil];
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Push Notification"
//                                                    message:[NSString stringWithFormat:@"COUNT DICT NOTIFICATION: %ld", (long)[pushNotificationArray count]]
//                                                   delegate:self
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE object:application];
    
    //RN Temp
    TAPRegisterViewController *registerViewController = [[TapTalk sharedInstance] registerViewController];
    [registerViewController presentRegisterViewControllerIfNeededFromViewController:[[TapTalk sharedInstance] roomListViewController] force:NO];
    //END RN Temp
    
    _instanceState = TapTalkInstanceStateActive;

    [[TAPChatManager sharedManager] removeAllBackgroundSequenceTaskWithApplication:application];

    if ([TAPChatManager sharedManager].activeUser != nil) {
        //User active
        [[TAPConnectionManager sharedManager] connect];
    }

    //Start trigger timer to save new message
    [[TAPChatManager sharedManager] triggerSaveNewMessage];
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
    
    //DV Temp
    //DV Note - Temporary open chat room when tapped notification - later will be handled in client's app delegate
    TAPRoomModel *room = message.room;
    
    UIViewController *currentActiveController = ((UINavigationController *)self.activeWindow.rootViewController).topViewController;
    UINavigationController *currentNavigationController = currentActiveController.navigationController;
    
    if ([currentActiveController isKindOfClass:[TAPChatViewController class]]) {
//        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray:currentNavigationController.viewControllers];
//        NSInteger viewControllerIndex = [navigationArray indexOfObject:currentActiveController];
//        [navigationArray removeObjectAtIndex: viewControllerIndex];
//        currentNavigationController.viewControllers = navigationArray;
        [currentActiveController.navigationController popViewControllerAnimated:NO];
    }
    
    [[TapTalk sharedInstance] openRoomWithRoom:room fromNavigationController:currentNavigationController animated:YES];
    
    //END DV Temp
    
    completionHandler();
}

#pragma mark - Exception Handling
- (void)handleException:(NSException *)exception {
    [[TAPChatManager sharedManager] saveUnsentMessageAndDisconnect];
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
}

- (void)resetPersistent {
    //Set initial refresh rate
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Delegate
#pragma mark TAPNotificationManager
- (void)notificationManagerDidHandleTappedNotificationWithMessage:(TAPMessageModel *)message {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidTappedNotificationWithMessage:)]) {
        [self.delegate tapTalkDidTappedNotificationWithMessage:message];
    }
}

#pragma mark - Custom Method
//General Set Up
- (void)setEnvironment:(TapTalkEnvironment)environment {
    _environment = environment;
    NSLog(@"ENVIRONMENT TYPE = %ld", self.environment);
    
}

- (void)activateInAppNotificationInWindow:(UIWindow *)activeWindow {
    _activeWindow = activeWindow;
}

- (UINavigationController *)getCurrentTapTalkActiveNavigationController {
    UINavigationController *currentActiveNavigationController = (UINavigationController *)self.activeWindow.rootViewController;
    return currentActiveNavigationController;
}

- (UIViewController *)getCurrentTapTalkActiveViewController {
    UIViewController *currentActiveController = ((UINavigationController *)self.activeWindow.rootViewController).topViewController;
    return currentActiveController;
}

//Chat
- (void)openRoomWithOtherUser:(TAPUserModel *)otherUser fromNavigationController:(UINavigationController *)navigationController {
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

- (void)openRoomWithRoom:(TAPRoomModel *)room fromNavigationController:(UINavigationController *)navigationController animated:(BOOL)isAnimated {
    [[TAPChatManager sharedManager] openRoom:room];
    
    //Save all unsent message (in case user retrieve message on another room)
    [[TAPChatManager sharedManager] saveAllUnsentMessage];
    
    TAPChatViewController *chatViewController = [[TAPChatViewController alloc] initWithNibName:@"TAPChatViewController" bundle:[TAPUtil currentBundle]];
    chatViewController.currentRoom = room;
    chatViewController.delegate = [[TapTalk sharedInstance] roomListViewController];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [navigationController pushViewController:chatViewController animated:isAnimated];
}

- (void)sendTextMessage:(NSString *)message recipientXCUserID:(NSString *)recipientXCUserID success:(void (^)(void))success failure:(void (^)(NSError *error))failure {

    TAPUserModel *recipientUser = [[TAPContactManager sharedManager] getUserWithUserID:recipientXCUserID];
    
    if(recipientUser == nil) {
        //User not exist in database, call api
        [TAPDataManager callAPIGetUserByXCUserID:recipientXCUserID success:^(TAPUserModel *user) {
            
            if(user == nil) {
                //Failed to obtain user data
                NSError *error; //DV Temp
                failure(error);
            }
            
            TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:user];
            [[TAPChatManager sharedManager] constructMessage:message user:[TAPChatManager sharedManager].activeUser room:room];
            success();
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else {
        TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:recipientUser];
        [[TAPChatManager sharedManager] constructMessage:message user:[TAPChatManager sharedManager].activeUser room:room];
        success();
    }
}

- (void)requestToSendProductListWithRecipientXCUserID:(NSString *)recipientXCUserID {
    //Call API
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
    if ([self.delegate respondsToSelector:@selector(tapTalkCustomKeyboardDidTappedWithSender:recipient:keyboardItem:)]) {
        [self.delegate tapTalkCustomKeyboardDidTappedWithSender:sender recipient:recipient keyboardItem:keyboardItem];
    }
}

//Custom Bubble
- (void)addCustomBubbleDataWithClassName:(NSString *)className type:(NSInteger)type delegate:(id)delegate {
    [[TAPCustomBubbleManager sharedManager] addCustomBubbleDataWithCellName:className type:type delegate:delegate];
}

@end
