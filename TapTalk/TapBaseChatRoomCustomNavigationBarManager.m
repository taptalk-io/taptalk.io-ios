//
//  TapBaseChatRoomCustomNavigationBarManager.m
//  TapTalk
//
//  Created by Kevin on 10/28/22.
//  Copyright © 2022 Moselo. All rights reserved.
//

#import "TapBaseChatRoomCustomNavigationBarManager.h"

@interface TapBaseChatRoomCustomNavigationBarManager () <TapUIChatRoomCustomNavigationBarDelegate, TapUIChatRoomDelegate, TAPCoreChatRoomManagerDelegate>

@property (nonatomic) BOOL isOpeningChatRoom;

@end

@implementation TapBaseChatRoomCustomNavigationBarManager

+ (instancetype)dispatch {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[TapUI sharedInstance] setChatRoomCustomNavigationBarDelegate:self];
        [[TapUI sharedInstance] setChatRoomDelegate:self];
        [[TAPCoreChatRoomManager sharedManager] setDelegate:self];
    }
    return self;
}

#pragma mark TapUIChatRoomDelegate

- (void)tapTalkChatRoomDidOpen:(TAPRoomModel *)room
                     otherUser:(TAPUserModel * _Nullable)otherUser
         currentViewController:(UIViewController *)currentViewController
currentShownNavigationController:(UINavigationController *)currentNavigationController {
    
    _isOpeningChatRoom = YES;
    TAPUserModel *activeUser = [[TapTalk sharedInstance] getTapTalkActiveUser];
    if ([currentViewController isKindOfClass:[TapUIChatViewController class]]) {
        _chatViewController = (TapUIChatViewController *)currentViewController;
    }
    _navigationController = currentNavigationController;
    _room = room;
    _activeUser = activeUser;
    if (otherUser != nil) {
        _recipientUser = otherUser;
        _onlineStatus = [TAPOnlineStatusModel new];
        self.onlineStatus.user = otherUser;
        self.onlineStatus.isOnline = otherUser.isOnline;
        self.onlineStatus.lastActive = otherUser.lastActivity;
    }
    _typingUsers = [[TAPChatManager sharedManager] getTypingUsersWithRoomID:room.roomID];
    _isOpeningChatRoom = NO;
}

- (void)tapTalkChatRoomDidClose:(TAPRoomModel *)room
                      otherUser:(TAPUserModel * _Nullable)otherUser
          currentViewController:(UIViewController *)currentViewController
currentShownNavigationController:(UINavigationController *)currentNavigationController {
    
    if (self.room != nil && ![self.room.roomID isEqualToString:room.roomID] || self.isOpeningChatRoom) {
        return;
    }
    _chatViewController = nil;
    _navigationController = nil;
    _room = nil;
    _activeUser = nil;
    _recipientUser = nil;
    _onlineStatus = nil;
    _typingUsers = [NSDictionary dictionary];
    
    [self tapTalkNavigationBarManagerChatRoomDidClose:room
                                        recipientUser:otherUser
                                currentViewController:currentViewController
                          currentNavigationController:currentNavigationController];
    
    // TODO: REMOVE DELEGATES FROM ARRAY
}

#pragma mark TAPCoreChatRoomManagerDelegate

- (void)tapTalkDidReceiveUpdatedChatRoomData:(TAPRoomModel *)room recipientUser:(TAPUserModel *_Nullable)recipientUser {
    if (self.room != nil && [self.room.roomID isEqualToString:room.roomID]) {
        _room = room;
        if (recipientUser != nil) {
            _recipientUser = recipientUser;
        }
        if (recipientUser != nil) {
            _onlineStatus = [TAPOnlineStatusModel new];
            self.onlineStatus.user = recipientUser;
            self.onlineStatus.isOnline = recipientUser.isOnline;
            self.onlineStatus.lastActive = recipientUser.lastActivity;
        }
        [self tapTalkNavigationBarManagerDidReceiveUpdatedChatRoomData:room recipientUser:recipientUser onlineStatus:self.onlineStatus];
    }
}

- (void)tapTalkDidStartTypingWithUser:(TAPUserModel *)user roomID:(NSString *)roomID {
    if (self.room != nil && [self.room.roomID isEqualToString:roomID]) {
        [self tapTalkNavigationBarManagerDidReceiveStartTypingWithUser:user roomID:roomID];
    }
    
}

- (void)tapTalkDidStopTypingWithUser:(TAPUserModel *)user roomID:(NSString *)roomID {
    if (self.room != nil && [self.room.roomID isEqualToString:roomID]) {
        [self tapTalkNavigationBarManagerDidReceiveStopTypingWithUser:user roomID:roomID];
    }
}

- (void)tapTalkDidReceiveOnlineStatusWithUser:(TAPUserModel *)user onlineStatus:(BOOL)isOnline lastActive:(NSNumber *)lastActive {
    if (self.room == nil || user == nil) {
        return;
    }
    BOOL isRoomParticipant = NO;
    if (self.room.type == RoomTypePersonal) {
        NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.room.roomID];
        if ([user.userID isEqualToString:otherUserID]) {
            isRoomParticipant = YES;
        }
    }
    else if (self.room.participants != nil && self.room.participants.count > 0) {
        for (TAPUserModel *participant in self.room.participants) {
            if ([user.userID isEqualToString:participant.userID]) {
                isRoomParticipant = YES;
                break;
            }
        }
    }
    
    if (isRoomParticipant) {
        _onlineStatus = [TAPOnlineStatusModel new];
        self.onlineStatus.user = user;
        self.onlineStatus.isOnline = isOnline;
        self.onlineStatus.lastActive = lastActive;
        if (self.recipientUser != nil) {
            _recipientUser = user;
        }
        [self tapTalkNavigationBarManagerDidReceiveOnlineStatusWithUser:user onlineStatus:isOnline lastActive:lastActive];
    }
}

#pragma mark TapBaseChatRoomCustomNavigationBarManager

- (void)tapTalkNavigationBarManagerDidReceiveUpdatedChatRoomData:(TAPRoomModel *)room
                                                   recipientUser:(TAPUserModel *_Nullable)recipientUser
                                                    onlineStatus:(TAPOnlineStatusModel *)onlineStatus {
    
}

- (void)tapTalkNavigationBarManagerDidReceiveStartTypingWithUser:(TAPUserModel *)user roomID:(NSString *)roomID {

}

- (void)tapTalkNavigationBarManagerDidReceiveStopTypingWithUser:(TAPUserModel *)user roomID:(NSString *)roomID {

}

- (void)tapTalkNavigationBarManagerDidReceiveOnlineStatusWithUser:(TAPUserModel *)user
                                                     onlineStatus:(BOOL)isOnline
                                                       lastActive:(NSNumber *)lastActive {

}

- (void)tapTalkNavigationBarManagerChatRoomDidClose:(TAPRoomModel *)room
                                      recipientUser:(TAPUserModel * _Nullable)recipientUser
                              currentViewController:(UIViewController *)currentViewController
                        currentNavigationController:(UINavigationController *)currentNavigationController {
    
}

@end
