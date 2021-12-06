//
//  TAPCoreChatRoomManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAPCoreChatRoomManagerDelegate <NSObject>

- (void)tapTalkDidStartTypingWithUser:(TAPUserModel *)user roomID:(NSString *)roomID;
- (void)tapTalkDidStopTypingWithUser:(TAPUserModel *)user roomID:(NSString *)roomID;
- (void)tapTalkDidReceiveOnlineStatusWithUser:(TAPUserModel *)user onlineStatus:(BOOL)isOnline lastActive:(NSNumber *)lastActive;

@end

@interface TAPCoreChatRoomManager : NSObject

@property (weak, nonatomic) id<TAPCoreChatRoomManagerDelegate> delegate;

+ (TAPCoreChatRoomManager *)sharedManager;

- (TAPRoomModel *)getActiveChatRoom;

- (void)getPersonalChatRoomWithRecipientUserID:(NSString *)userID
                                       success:(void (^)(TAPRoomModel *room))success
                                       failure:(void (^)(NSError *error))failure;
- (void)getPersonalChatRoomWithRecipientUser:(TAPUserModel *)user
                                     success:(void (^)(TAPRoomModel *room))success;
- (void)getGroupChatRoomWithGroupRoomID:(NSString *)groupRoomID
                                success:(void (^)(TAPRoomModel *room))success
                                failure:(void (^)(NSError *error))failure;
- (void)getChatRoomByXCRoomID:(NSString *)xcRoomID
                      success:(void (^)(TAPRoomModel *room))success
                      failure:(void (^)(NSError *error))failure;
- (void)createGroupChatRoomWithGroupName:(NSString *)groupName
            listOfParticipantUserIDs:(NSArray *)participantUserIDArray
                             success:(void (^)(TAPRoomModel *room))success
                             failure:(void (^)(NSError *error))failure;
- (void)createGroupChatRoomWithGroupName:(NSString *)groupName
            listOfParticipantUserIDs:(NSArray *)participantUserIDArray
                      profilePicture:(UIImage *)profilePictureImage
                             success:(void (^)(TAPRoomModel *room, BOOL isSuccessUploadGroupPicture))success
                             failure:(void (^)(NSError *error))failure;
- (void)updateGroupChatRoomDetailsWithGroupRoomID:(NSString *)groupRoomID
                                        groupName:(NSString *)groupName
                                          success:(void (^)(TAPRoomModel *room))success
                                          failure:(void (^)(NSError *error))failure;
- (void)updateGroupPicture:(UIImage *)groupPictureImage
                    roomID:(NSString *)roomID
              successBlock:(void (^)(TAPRoomModel *room))success
             progressBlock:(void (^)(CGFloat progress, CGFloat total))progress
              failureBlock:(void (^)(NSError *error))failure;
- (void)deleteLocalGroupChatRoomWithRoomID:(NSString *)roomID
                                   success:(void (^)(void))success
                                   failure:(void (^)(NSError *error))failure;
- (void)deleteGroupChatRoom:(TAPRoomModel *)room
                    success:(void (^)(void))success
                    failure:(void (^)(NSError *error))failure;
- (void)leaveGroupChatRoomWithRoomID:(NSString *)roomID
                             success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure;
- (void)addGroupChatMembersWithUserIDArray:(NSArray *)userIDArray
                                    roomID:(NSString *)roomID
                                   success:(void (^)(TAPRoomModel *room))success
                                   failure:(void (^)(NSError *error))failure;
- (void)removeGroupChatMembersWithUserIDArray:(NSArray *)userIDArray
                                       roomID:(NSString *)roomID
                                      success:(void (^)(TAPRoomModel *room))success
                                      failure:(void (^)(NSError *error))failure;
- (void)promoteGroupAdminsWithUserIDArray:(NSArray *)userIDArray
                                   roomID:(NSString *)roomID
                                  success:(void (^)(TAPRoomModel *room))success
                                  failure:(void (^)(NSError *error))failure;
- (void)demoteGroupAdminsWithUserIDArray:(NSArray *)userIDArray
                                  roomID:(NSString *)roomID
                                 success:(void (^)(TAPRoomModel *room))success
                                 failure:(void (^)(NSError *error))failure;
- (void)sendStartTypingEmitWithRoomID:(NSString *)roomID;
- (void)sendStopTypingEmitWithRoomID:(NSString *)roomID;

@end

NS_ASSUME_NONNULL_END
