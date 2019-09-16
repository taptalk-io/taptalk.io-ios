//
//  TapTalk.m
//  TapTalk
//
//  Created by Ritchie Nathaniel on 11/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TapTalk.h"
#import "TAPProfileViewController.h"
#import <CoreText/CoreText.h>

@import AFNetworking;
@import GooglePlaces;
@import GoogleMaps;

@interface TapTalk () <TAPNotificationManagerDelegate>

@property (nonatomic) TapTalkImplentationType implementationType;
@property (nonatomic) BOOL isAutoConnectDisabled;

@property (strong, nonatomic) NSDictionary * _Nullable projectConfigsDictionary;
@property (strong, nonatomic) NSDictionary * _Nullable coreConfigsDictionary;
@property (strong, nonatomic) NSDictionary * _Nullable customConfigsDictionary;

- (void)firstRunSetupWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions;
- (void)resetPersistent;
- (void)loadCustomFontData;

@end

@implementation TapTalk

#pragma mark - Lifecycle
+ (TapTalk *)sharedInstance {
    static TapTalk *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        
        _projectConfigsDictionary = [[NSDictionary alloc] init];
        _coreConfigsDictionary = [[NSDictionary alloc] init];
        _customConfigsDictionary = [[NSDictionary alloc] init];
        
        //Set secret for NSSecureUserDefaults
        [NSUserDefaults setSecret:TAP_SECURE_KEY_NSUSERDEFAULTS];
                
        //Add notification manager delegate
        [TAPNotificationManager sharedManager].delegate = self;
        
    }
    
    return self;
}

#pragma mark - Authentication
- (void)authenticateWithAuthTicket:(NSString *_Nonnull)authTicket
                connectWhenSuccess:(BOOL)connectWhenSuccess
                           success:(void (^_Nonnull)(void))success
                           failure:(void (^_Nonnull)(NSError * _Nonnull error))failure { 
    
    if (authTicket == nil || [authTicket isEqualToString:@""]) {
        NSMutableDictionary *errorDictionary = [NSMutableDictionary dictionary];
        [errorDictionary setObject:@"Invalid Auth Ticket" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"io.TapTalk.framework.ErrorDomain" code:90005 userInfo:errorDictionary];
        failure(error);
    }
    
    [TAPDataManager callAPIGetAccessTokenWithAuthTicket:authTicket success:^{
        //Check need to send push token to server
        if ([[TapTalk sharedInstance].delegate respondsToSelector:@selector(tapTalkDidRequestRemoteNotification)]) {
            [[TapTalk sharedInstance].delegate tapTalkDidRequestRemoteNotification];
        }
        
        if (connectWhenSuccess) {
            [[TAPChatManager sharedManager] connect];
        }
        
        //Refresh Contact List
        [TAPDataManager callAPIGetContactList:^(NSArray *userArray) {
        } failure:^(NSError *error) {
        }];
        
        if (self.implementationType != TapTalkImplentationTypeCore) {
            //First chat initialization on login
            //Only run when using TAPUI or both implementation
            [[TapUI sharedInstance] roomListViewController].isShouldNotLoadFromAPI = NO;
            [[[TapUI sharedInstance] roomListViewController] viewLoadedSequence];
        }
        
        success();
        
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (BOOL)isAuthenticated {
    NSString *accessToken = [TAPDataManager getAccessToken];
    
    if (accessToken == nil || [accessToken isEqualToString:@""]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isConnected {
    TAPConnectionManagerStatusType statusType = [TAPConnectionManager sharedManager].tapConnectionStatus;
    
    if (statusType == TAPConnectionManagerStatusTypeConnected) {
        return YES;
    }
    
    return NO;
}

- (void)connectWithSuccess:(void (^_Nonnull)(void))success
                   failure:(void (^_Nonnull)(NSError *_Nonnull error))failure {
    
    BOOL authenticated = [self isAuthenticated];
    if (!authenticated) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90002 errorMessage:@"Access token is not available, please call authenticateWithAuthTicket method before connecting"];
        failure(localizedError);
        return;
    }
    
    TAPConnectionManagerStatusType statusType = [TAPConnectionManager sharedManager].tapConnectionStatus;
    if (statusType == TAPConnectionManagerStatusTypeConnected || statusType == TAPConnectionManagerStatusTypeConnecting) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90003 errorMessage:@"Already connected"];
        failure(localizedError);
        return;
    }
    
    //Connect Socket
    [[TAPChatManager sharedManager] connect];
    success();
}

- (void)disconnectWithCompletionHandler:(void (^_Nonnull)(void))completion {
    //Disconnect Socket
    [[TAPChatManager sharedManager] disconnect];
    completion();
}

- (void)enableAutoConnect {
    _isAutoConnectDisabled = NO;
}

- (void)disableAutoConnect {
    _isAutoConnectDisabled = YES;
}

- (BOOL)isAutoConnectEnabled {
    return !self.isAutoConnectDisabled;
}

#pragma mark - AppDelegate Handling
- (void)application:(UIApplication *_Nonnull)application didFinishLaunchingWithOptions:(NSDictionary *_Nonnull)launchOptions {
    // Override point for customization after application launch.
    
    [self firstRunSetupWithApplication:application launchOptions:launchOptions];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_DID_FINISH_LAUNCHING object:application];
    
    //Load custom font data
    [self loadCustomFontData];
    
    //Update to isFailedSend = 1
    [[TAPChatManager sharedManager] updateSendingMessageToFailed];
    
    //Obtain downloaded file path from preference
    [[TAPFileDownloadManager sharedManager] fetchDownloadedFilePathFromPreference];
    
    //Clean database message that is more than 1 month old every 1 week.
    [TAPOldDataManager runCleaningOldDataSequence];
    
    //Populate User Country Code
    [[TAPContactManager sharedManager] populateContactFromDatabase];
    
    //Populate Room Model Dictionary from Preference
    [[TAPGroupManager sharedManager] populateRoomFromPreference];
 }

- (void)applicationWillResignActive:(UIApplication *_Nonnull)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_WILL_RESIGN_ACTIVE object:application];
    
    //Update application notification bubble
    [[TAPNotificationManager sharedManager] updateApplicationBadgeCount];
    [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToPreference];
    
}

- (void)applicationDidEnterBackground:(UIApplication *_Nonnull)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_DID_ENTER_BACKGROUND object:application];
    
    //Run update message sequence when enter background
    [[TAPChatManager sharedManager] runEnterBackgroundSequenceWithApplication:application];
    
    //Send stop typing emit
    [[TAPChatManager sharedManager] stopTyping];
    
    //Save retrieved group model dictionary to preference
    [[TAPGroupManager sharedManager] saveRoomToPreference];
    
    //Clear all contact dictionary in ContactCacheManager
//    [[TAPContactCacheManager sharedManager] clearContactDictionary];
}

- (void)applicationWillEnterForeground:(UIApplication *_Nonnull)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_WILL_ENTER_FOREGROUND object:application];
    
    //Remove all read count on MessageStatusManager because the room list is reloaded from database
    [[TAPMessageStatusManager sharedManager] clearReadCountDictionary];
    
    if (self.implementationType != TapTalkImplentationTypeCore) {
        //Call to run room list view controller sequence
        //Only run when using TAPUI or both implementation
        [[TapUI sharedInstance] roomListViewController].isShouldNotLoadFromAPI = NO;
        [[[TapUI sharedInstance] roomListViewController] viewLoadedSequence];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *_Nonnull)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE object:application];
    
    _instanceState = TapTalkInstanceStateActive;

    [[TAPChatManager sharedManager] removeAllBackgroundSequenceTaskWithApplication:application];

    if ([TAPChatManager sharedManager].activeUser != nil) {
        //User active
        BOOL isAutoConnectEnabled = [[TapTalk sharedInstance] isAutoConnectEnabled];
        if (isAutoConnectEnabled) {
            [[TAPChatManager sharedManager] connect];
        }
        
        //Check is need to trigger get push token flow
        if ([[TapTalk sharedInstance].delegate respondsToSelector:@selector(tapTalkDidRequestRemoteNotification)]) {
            [[TapTalk sharedInstance].delegate tapTalkDidRequestRemoteNotification];
        }
    }

    //Start trigger timer to save new message
    [[TAPChatManager sharedManager] triggerSaveNewMessage];
    
    //Obtain downloaded file path from preference
    [[TAPFileDownloadManager sharedManager] fetchDownloadedFilePathFromPreference];
}

- (void)applicationWillTerminate:(UIApplication *_Nonnull)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_APPLICATION_WILL_TERMINATE object:application];
    
    [[TAPChatManager sharedManager] saveIncomingMessageAndDisconnect];
    _instanceState = TapTalkInstanceStateInactive;
}

- (void)application:(UIApplication *_Nonnull)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *_Nonnull)deviceToken {
    NSString *pushToken = [deviceToken description];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[TAPNotificationManager sharedManager] setPushToken:pushToken];
}

- (void)application:(UIApplication *_Nonnull)application didReceiveRemoteNotification:(NSDictionary *_Nonnull)userInfo fetchCompletionHandler:(void (^_Nonnull)(UIBackgroundFetchResult result))completionHandler {
    
    [[TAPNotificationManager sharedManager] handlePushNotificationWithUserInfo:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        return;
    }
    
//    NSDictionary *userInfo = [[notification userInfo] objectForKey:@"data"];
//    [self handleOpenAppsFromNotificationWithUserInfo:userInfo];
}

#pragma mark - Push Notification
- (void)userNotificationCenter:(UNUserNotificationCenter *_Nonnull)center willPresentNotification:(UNNotification *_Nonnull)notification withCompletionHandler:(void (^_Nonnull)(UNNotificationPresentationOptions options))completionHandler {
    //Called when a notification is delivered to a foreground app.
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

//Called to let your app know which action was selected by the user for a given notification.
- (void)userNotificationCenter:(UNUserNotificationCenter *_Nonnull)center didReceiveNotificationResponse:(UNNotificationResponse *_Nonnull)response withCompletionHandler:(void(^_Nonnull)(void))completionHandler {
    //Called when a notification is delivered to a foreground app.
    
    NSDictionary *userInfoDictionary = response.notification.request.content.userInfo;
    NSDictionary *messageDictionary = [userInfoDictionary valueForKeyPath:@"data.message"];
    [[TAPNotificationManager sharedManager] handleTappedNotificationWithUserInfo:messageDictionary];
    
    completionHandler();
}

#pragma mark - Exception Handling
- (void)handleException:(NSException * _Nonnull)exception {
    [[TAPChatManager sharedManager] saveUnsentMessageAndDisconnect];
    
    //Save all retrieved contact to database
    [[TAPContactManager sharedManager] saveContactToDatabase];
    
    //Save downloaded file path to preference
    [[TAPFileDownloadManager sharedManager] saveDownloadedFilePathToPreference];
    
    //Save retrieved group model dictionary to preference
    [[TAPGroupManager sharedManager] saveRoomToPreference];
    
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
    
    //Save user to ContactManager Dictionary
    [[TAPContactManager sharedManager] addContactWithUserModel:message.user saveToDatabase:NO];
    
    UIViewController *currentActiveController = nil;
    if (self.implementationType != TapTalkImplentationTypeCore) {
        currentActiveController = [[TapUI sharedInstance] getCurrentTapTalkActiveViewController];
    }
    
    if ([self.delegate respondsToSelector:@selector(tapTalkDidTappedNotificationWithMessage:fromActiveController:)]) {
        [self.delegate tapTalkDidTappedNotificationWithMessage:message fromActiveController:currentActiveController];
    }
}

#pragma mark - Custom Method
//General Set Up
- (void)initWithAppKeyID:(NSString *_Nonnull)appKeyID
            appKeySecret:(NSString *_Nonnull)appKeySecret
            apiURLString:(NSString *_Nonnull)apiURLString
      implementationType:(TapTalkImplentationType)tapTalkImplementationType {
    
    NSString *appKey = [NSString stringWithFormat:@"%@:%@", appKeyID, appKeySecret];
    [[TAPNetworkManager sharedManager] setAppKey:appKey];
    [[TAPAPIManager sharedManager] setBaseAPIURLString:apiURLString];
    [[TAPConnectionManager sharedManager] setSocketURLString:apiURLString];
    
    _implementationType = tapTalkImplementationType;
    
    //Fetch remote configs data
    [[TapTalk sharedInstance] refreshRemoteConfigsWithSuccess:^{
        
    } failure:^(NSError *error) {
        
    }];
    
    //Validate and refresh access token
    [[TAPConnectionManager sharedManager] validateToken];
}

- (void)initializeGooglePlacesAPIKey:(NSString * _Nonnull)apiKey {
    //Google API Key
    [GMSPlacesClient provideAPIKey:apiKey];
    [GMSServices provideAPIKey:apiKey];
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

//Other
- (void)refreshRemoteConfigsWithSuccess:(void (^)(void))success
                                failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIGetProjectConfigsWithSuccess:^(NSDictionary *projectConfigsDictionary) {
        
        NSDictionary *coreDictionary = [projectConfigsDictionary objectForKey:@"core"];
        coreDictionary = [TAPUtil nullToEmptyDictionary:coreDictionary];
        
        NSDictionary *projectDictionary = [projectConfigsDictionary objectForKey:@"project"];
        projectDictionary = [TAPUtil nullToEmptyDictionary:projectDictionary];
        
        NSDictionary *customDictionary = [projectConfigsDictionary objectForKey:@"custom"];
        customDictionary = [TAPUtil nullToEmptyDictionary:customDictionary];
        
        _projectConfigsDictionary = projectDictionary;
        _coreConfigsDictionary = coreDictionary;
        _customConfigsDictionary = customDictionary;
        
        success();
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (NSDictionary *)getCoreConfigs {
    NSMutableDictionary *coreDictionary = [NSMutableDictionary dictionary];
    coreDictionary = [self.coreConfigsDictionary mutableCopy];
    return [coreDictionary copy];
}

- (NSDictionary *)getProjectConfigs {
    NSMutableDictionary *projectDictionary = [NSMutableDictionary dictionary];
    projectDictionary = [self.projectConfigsDictionary mutableCopy];
    return [projectDictionary copy];
}

- (NSDictionary *)getCustomConfigs {
    NSMutableDictionary *customDictionary = [NSMutableDictionary dictionary];
    customDictionary = [self.customConfigsDictionary mutableCopy];
    return [customDictionary copy];
}

- (TapTalkImplentationType)getTapTalkImplementationType {
    return self.implementationType;
}

- (void)logoutAndClearAllTapTalkDataWithSuccess:(void (^_Nonnull)(void))success
                                        failure:(void (^_Nonnull)(NSError *_Nonnull error))failure {
    [TAPDataManager callAPILogoutWithSuccess:^{
        [[TapTalk sharedInstance] clearAllTapTalkData];
        [[TapTalk sharedInstance] disconnectWithCompletionHandler:^{
        }];
        
        success();
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)clearAllTapTalkData {
    //Delete all data in database
    [TAPDatabaseManager deleteAllDataInDatabaseWithSuccess:^{
        
    } failure:^(NSError *error) {
        
    }];
    
    //Remove all preference
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_ACTIVE_USER];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_REFRESH_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_REFRESH_TOKEN_EXPIRED_TIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_ACCESS_TOKEN_EXPIRED_TIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_IS_DONE_FIRST_SETUP];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_LAST_UPDATED_CHAT_ROOM];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_LAST_DELETED_OLD_MESSAGE_TIMESTAMP];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_FILE_PATH_DICTIONARY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_USER_LOGIN_PHONE_TEMP_DICTIONARY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_USER_COUNTRY_CODE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_CONTACT_PERMISSION_ASKED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_PROJECT_CONFIGS_DICTIONARY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_AUTO_SYNC_CONTACT_DISABLED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_DONE_FIRST_TIME_AUTO_SYNC_CONTACT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Clear Manager Data
    [[TAPChatManager sharedManager] clearChatManagerData];
    [[TAPContactManager sharedManager] clearContactManagerData];
    [[TAPFetchMediaManager sharedManager] clearFetchMediaManagerData];
    [[TAPFileDownloadManager sharedManager] clearFileDownloadManagerData];
    [[TAPFileUploadManager sharedManager] clearFileUploadManagerData];
    [[TAPMessageStatusManager sharedManager] clearMessageStatusManagerData];
}

- (TAPUserModel *_Nonnull)getTapTalkActiveUser {
    return [TAPDataManager getActiveUser];
}

- (void)loadCustomFontData {
    NSArray *fontArray = @[@"DMSans-Italic", @"PTRootUI-Regular", @"PTRootUI-Medium", @"PTRootUI-Bold"];
    
    for (NSString *fontName in fontArray) {
        NSString *fontPath = [[TAPUtil currentBundle] pathForResource:fontName ofType:@"ttf"];
        NSData *inData = [NSData dataWithContentsOfFile:fontPath];
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
}

- (void)enableAutoContactSync {
    [[NSUserDefaults standardUserDefaults] setSecureBool:NO forKey:TAP_PREFS_AUTO_SYNC_CONTACT_DISABLED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)disableAutoContactSync {
    [[NSUserDefaults standardUserDefaults] setSecureBool:YES forKey:TAP_PREFS_AUTO_SYNC_CONTACT_DISABLED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isAutoContactSyncEnabled {
    BOOL isDisabled = [[NSUserDefaults standardUserDefaults] secureBoolForKey:TAP_PREFS_AUTO_SYNC_CONTACT_DISABLED valid:nil];
    return !isDisabled;
}

@end
