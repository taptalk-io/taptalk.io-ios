//
//  TAPNotificationManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 23/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPNotificationManager.h"

#define NOTIFICATION_SOUND_NAME @"moselo-notification.caf"

@interface TAPNotificationManager () <TAPChatManagerDelegate, TAPCustomNotificationAlertViewControllerDelegate>

@property (nonatomic) BOOL isViewIsAddedToSubview;

@end

@implementation TAPNotificationManager

#pragma mark - Lifecycle
+ (TAPNotificationManager *)sharedManager {
    static TAPNotificationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if(self) {
        //Add chat manager delegate
        [[TAPChatManager sharedManager] addDelegate:self];
        _isViewIsAddedToSubview = NO;
    }
    
    return self;
}

- (void)dealloc {
    //Remove chat manager delegate
    [[TAPChatManager sharedManager] removeDelegate:self];
}

#pragma mark TAPChatManager
- (void)chatManagerDidReceiveNewMessageOnOtherRoom:(TAPMessageModel *)message {
    [self handleIncomingMessage:message shouldNotShowNotification:NO isNeedDecrypted:NO]; //DV Temp
}

- (void)chatManagerDidReceiveUpdateMessageOnOtherRoom:(TAPMessageModel *)message {
    [self handleIncomingMessage:message shouldNotShowNotification:NO isNeedDecrypted:NO]; //DV Temp
}

- (void)chatManagerDidReceiveDeleteMessageOnOtherRoom:(TAPMessageModel *)message {
    [self handleIncomingMessage:message shouldNotShowNotification:NO isNeedDecrypted:NO]; //DV Temp
}

#pragma mark - TAPCustomNotificationAlertViewController
- (void)customNotificationAlertViewControllerNotificationButtonDidTappedWithMessage:(TAPMessageModel *)message {

}

- (void)secondaryCustomNotificationAlertViewControllerNotificationButtonDidTappedWithMessage:(TAPMessageModel *)message {

}

#pragma mark - Custom Method
- (void)setPushToken:(NSString *)pushToken {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAP_PREFS_PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setSecureObject:pushToken forKey:TAP_PREFS_PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *accessToken = [TAPDataManager getAccessToken];
    if(![accessToken isEqualToString:@""] && accessToken != nil) {
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
}

- (NSString *)pushToken {
    NSString *pushToken = [[NSUserDefaults standardUserDefaults] secureObjectForKey:TAP_PREFS_PUSH_TOKEN valid:nil];
    pushToken = [TAPUtil nullToEmptyString:pushToken];
    return pushToken;
}

- (void)handlePushNotificationWithUserInfo:(NSDictionary *)userInfo {
#ifdef DEBUG
    NSLog(@"Did receive notification: %@", [userInfo description]);
#endif
    
    if([[userInfo valueForKeyPath:@"aps.content-available"] boolValue] == NO) {
        //Not a silent push, ignore notification
        return;
    }
    
    NSDictionary *messageDictionary = [NSDictionary dictionary];
    messageDictionary = [userInfo valueForKeyPath:@"data.message"];
    
    TAPMessageModel *message = [TAPDataManager messageModelFromPayloadWithUserInfo:messageDictionary];
    [[TAPNotificationManager sharedManager] handleIncomingMessage:message shouldNotShowNotification:YES isNeedDecrypted:YES];
}

- (void)handleIncomingMessage:(TAPMessageModel *)message shouldNotShowNotification:(BOOL)shouldNotShowNotification isNeedDecrypted:(BOOL)isNeedDecrypted {
    if(message == nil) {
        return;
    }
    
    TAPMessageModel *decryptedMessage = [TAPMessageModel new];
    if(isNeedDecrypted) {
        //Decrypt message
        decryptedMessage = [TAPEncryptorManager decryptMessage:message];
    }
    else {
        decryptedMessage = message;
    }
    
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        //Handling local push notification
        if([UNUserNotificationCenter class]) { //Check if UNUserNotifcation is supported
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = decryptedMessage.user.fullname;
            NSString *messageText = decryptedMessage.body;
            content.body = messageText;
            content.sound = [UNNotificationSound soundNamed:NOTIFICATION_SOUND_NAME];
            content.userInfo = decryptedMessage.toDictionary;

            // Deliver the notification after x second
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                          triggerWithTimeInterval:1.0f repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:decryptedMessage.localID
                                                                                  content:content
                                                                                  trigger:trigger];

            // Schedule the notification.
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {

            }];
        }
        else {
            //UserNotifcation.framework is not available below iOS 10
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            NSDate *currentDate = [NSDate date];
            NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
            currentTimeInterval += 1.0f; //Fire message with delay to avoid miss date
            NSDate *updatedDate = [NSDate dateWithTimeIntervalSince1970:currentTimeInterval];
            localNotification.fireDate = updatedDate;
            localNotification.alertTitle = decryptedMessage.user.fullname;
            NSString *messageText = decryptedMessage.body;
            localNotification.alertBody = messageText;
            localNotification.soundName = NOTIFICATION_SOUND_NAME;
            localNotification.userInfo = [decryptedMessage toDictionary];

            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
    else if (![message.room.roomID isEqualToString:[TAPChatManager sharedManager].activeRoom.roomID]) {
        [self showInAppNotificationWithMessage:decryptedMessage];
    }
    
}

- (void)showInAppNotificationWithMessage:(TAPMessageModel *)message {
//    if([message.type integerValue] == ChatMessageTypeNewUser || [message.type integerValue] == ChatMessageTypeUserLeave) {
//        return;
//    }
    
    if([TAPChatManager sharedManager].activeUser.userID == nil || [[TAPChatManager sharedManager].activeUser.userID isEqualToString:@""]) {
        //Do not show if user id nil
        return;
    }
    
    if([[TapTalk sharedInstance] roomListViewController].isViewAppear) {
        //Do not show if currently in room list
        return;
    }
    
    if(!self.isViewIsAddedToSubview) {
        [self initCustomNotificationAlertViewController];
    }
    
    [[TapTalk sharedInstance].customNotificationAlertViewController showWithMessage:message];
}

- (void)initCustomNotificationAlertViewController {
    if([TapTalk sharedInstance].activeWindow != nil) {
        [TapTalk sharedInstance].customNotificationAlertViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 66.0f + 20.0f);
        [TapTalk sharedInstance].customNotificationAlertViewController.delegate = self;
        [[TapTalk sharedInstance].activeWindow addSubview:[TapTalk sharedInstance].customNotificationAlertViewController.view];
        _isViewIsAddedToSubview = YES;
    }
}

- (void)handleTappedNotificationWithUserInfo:(NSDictionary *)userInfo {
    TAPMessageModel *message = [TAPDataManager messageModelFromPayloadWithUserInfo:userInfo];

    if([self.delegate respondsToSelector:@selector(notificationManagerDidHandleTappedNotificationWithMessage:)]) {
        [self.delegate notificationManagerDidHandleTappedNotificationWithMessage:message];
    }
}

- (void)removeReadLocalNotificationWithMessage:(TAPMessageModel *)message {
    //Handling local push notification
    if([UNUserNotificationCenter class]) { //Check if UNUserNotifcation is supported
        [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            
            for(NSInteger counter = 0; counter < [notifications count]; counter++) {
                UNNotification *notification = [notifications objectAtIndex:counter];
                NSString *identifier = notification.request.identifier;
                NSDictionary *userInfoDictionary = notification.request.content.userInfo;
                NSString *notificationRoomID = [userInfoDictionary valueForKeyPath:@"room.roomID"];
                
                NSString *obtainedLocalID = message.localID;
                NSString *obtainedRoomID = message.room.roomID;
                
                if([identifier isEqualToString:obtainedLocalID] && [notificationRoomID isEqualToString:obtainedRoomID]) {
                    //Cancelling local notification
                    [[UNUserNotificationCenter currentNotificationCenter]
                     removeDeliveredNotificationsWithIdentifiers:@[identifier]];
                    break;
                }
            }
        }];
    }
    else {
        //UserNotifcation.framework is not available below iOS 10
        NSArray *localNotificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (NSInteger counter = 0; counter < [localNotificationArray count]; counter++) {
            UILocalNotification *selectedLocalNotification = [localNotificationArray objectAtIndex:counter];
            NSDictionary *currentUserInfo = selectedLocalNotification.userInfo;
            NSString *notificationLocalID = [currentUserInfo objectForKey:@"localID"];
            NSString *notificationRoomID = [currentUserInfo valueForKeyPath:@"room.roomID"];

            NSString *obtainedLocalID = message.localID;
            NSString *obtainedRoomID = message.room.roomID;
            
            if ([notificationLocalID isEqualToString:obtainedLocalID] && [notificationRoomID isEqualToString:obtainedRoomID]) {
                    //Cancelling local notification
                    [[UIApplication sharedApplication] cancelLocalNotification:selectedLocalNotification];
                    break;
            }
        }
    }
}

@end
