//
//  TapBaseChatRoomCustomNavigationBarManager.h
//  TapTalk
//
//  Created by Kevin on 10/28/22.
//  Copyright © 2022 Moselo. All rights reserved.
//

#import "TAPRoomModel.h"
#import "TAPUserModel.h"
#import "TAPOnlineStatusModel.h"
#import "TapUIChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TapBaseChatRoomCustomNavigationBarManager : NSObject

@property (strong, nonatomic) TapUIChatViewController *chatViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) TAPRoomModel *room;
@property (strong, nonatomic) TAPUserModel *activeUser;
@property (strong, nonatomic) TAPUserModel *recipientUser;
@property (strong, nonatomic) TAPOnlineStatusModel *onlineStatus;
@property (strong, nonatomic) NSDictionary<NSString *, TAPUserModel *> *typingUsers;

+ (instancetype)dispatch;

- (void)tapTalkNavigationBarManagerDidReceiveUpdatedChatRoomData:(TAPRoomModel *)room
                                                   recipientUser:(TAPUserModel *_Nullable)recipientUser
                                                    onlineStatus:(TAPOnlineStatusModel *)onlineStatus;

- (void)tapTalkNavigationBarManagerDidReceiveStartTypingWithUser:(TAPUserModel *)user
                                                          roomID:(NSString *)roomID;

- (void)tapTalkNavigationBarManagerDidReceiveStopTypingWithUser:(TAPUserModel *)user
                                                         roomID:(NSString *)roomID;

- (void)tapTalkNavigationBarManagerDidReceiveOnlineStatusWithUser:(TAPUserModel *)user
                                                     onlineStatus:(BOOL)isOnline
                                                       lastActive:(NSNumber *)lastActive;

- (void)tapTalkNavigationBarManagerChatRoomDidClose:(TAPRoomModel *)room
                                      recipientUser:(TAPUserModel * _Nullable)recipientUser
                              currentViewController:(UIViewController *)currentViewController
                        currentNavigationController:(UINavigationController *)currentNavigationController;

@end

NS_ASSUME_NONNULL_END
