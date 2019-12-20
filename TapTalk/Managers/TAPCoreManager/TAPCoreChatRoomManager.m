//
//  TAPCoreChatRoomManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCoreChatRoomManager.h"
#import "TAPCoreContactManager.h"

@interface TAPCoreChatRoomManager () <TAPChatManagerDelegate>

@end

@implementation TAPCoreChatRoomManager
#pragma mark - Lifecycle
+ (TAPCoreChatRoomManager *)sharedManager {
    
    //Check if only implement TAPUI, don't init the core manager
    TapTalkImplentationType implementationType = [[TapTalk sharedInstance] getTapTalkImplementationType];
    if (implementationType == TapTalkImplentationTypeUI) {
        return nil;
    }
    
    static TAPCoreChatRoomManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        //Add chat manager delegate
        [[TAPChatManager sharedManager] addDelegate:self];

    }
    
    return self;
}

- (void)dealloc {
    //Remove chat manager delegate
    [[TAPChatManager sharedManager] removeDelegate:self];
}

#pragma mark - Delegate
#pragma mark TAPChatManager
- (void)chatManagerDidReceiveOnlineStatus:(TAPOnlineStatusModel *)onlineStatus {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidReceiveOnlineStatusWithUser:onlineStatus:lastActive:)]) {
        [self.delegate tapTalkDidReceiveOnlineStatusWithUser:onlineStatus.user onlineStatus:onlineStatus.isOnline lastActive:onlineStatus.lastActive];
    }
}

- (void)chatManagerDidReceiveStartTyping:(TAPTypingModel *)typing {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidStartTypingWithUser:roomID:)]) {
        [self.delegate tapTalkDidStartTypingWithUser:typing.user roomID:typing.roomID];
    }
}

- (void)chatManagerDidReceiveStopTyping:(TAPTypingModel *)typing {
    if ([self.delegate respondsToSelector:@selector(tapTalkDidStopTypingWithUser:roomID:)]) {
        [self.delegate tapTalkDidStopTypingWithUser:typing.user roomID:typing.roomID];
    }
}

#pragma mark - Custom Method
- (void)getPersonalChatRoomWithRecipientUserID:(NSString *)userID
                                       success:(void (^)(TAPRoomModel *room))success
                                       failure:(void (^)(NSError *error))failure {
    TAPUserModel *obtainedUser = [[TAPContactManager sharedManager] getUserWithUserID:userID];
    if (obtainedUser == nil || obtainedUser.userID == nil || [obtainedUser.userID isEqualToString:@""]) {
        [[TAPCoreContactManager sharedManager] getUserDataWithUserID:userID success:^(TAPUserModel * _Nonnull user) {
            TAPRoomModel *generatedRoom = [TAPRoomModel createPersonalRoomIDWithOtherUser:user];
            success(generatedRoom);
        } failure:^(NSError * _Nonnull error) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failure(localizedError);
        }];
    }
    else {
        TAPUserModel *activeUser = [TAPChatManager sharedManager].activeUser;
        if (activeUser == nil || [activeUser.userID isEqualToString:@""] || activeUser.userID == nil) {
            NSString *errorMessage = @"Active user not found";
            NSError *error = [[TAPCoreErrorManager sharedManager] generateLocalizedErrorWithErrorCode:90001 errorMessage:errorMessage];
            failure(error);
        }
        else {
            TAPRoomModel *generatedRoom = [TAPRoomModel createPersonalRoomIDWithOtherUser:obtainedUser];
            success(generatedRoom);
        }
    }
}

- (void)getPersonalChatRoomWithRecipientUser:(TAPUserModel *)user
                                     success:(void (^)(TAPRoomModel *room))success {
   TAPRoomModel *generatedRoom = [TAPRoomModel createPersonalRoomIDWithOtherUser:user];
    success(generatedRoom);
}

- (void)getGroupChatRoomWithGroupRoomID:(NSString *)groupRoomID
                                success:(void (^)(TAPRoomModel *room))success
                                failure:(void (^)(NSError *error))failure {
    TAPRoomModel *obtainedRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:groupRoomID];
    if (obtainedRoom == nil) {
        [TAPDataManager callAPIGetRoomWithRoomID:groupRoomID success:^(TAPRoomModel *room) {
            [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:room];
            success(room);
        } failure:^(NSError *error) {
            NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
            failure(localizedError);
        }];
    }
    else {
        success(obtainedRoom);
    }
}

- (void)createGroupChatRoomWithGroupName:(NSString *)groupName
                listOfParticipantUserIDs:(NSArray *)participantUserIDArray
                                 success:(void (^)(TAPRoomModel *room))success
                                 failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPICreateRoomWithName:groupName type:RoomTypeGroup userIDArray:participantUserIDArray success:^(TAPRoomModel *room) {
        [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:room];
        success(room);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)createGroupChatRoomWithGroupName:(NSString *)groupName
                listOfParticipantUserIDs:(NSArray *)participantUserIDArray
                          profilePicture:(UIImage *)profilePictureImage
                                 success:(void (^)(TAPRoomModel *room, BOOL isSuccessUploadGroupPicture))success
                             failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPICreateRoomWithName:groupName type:RoomTypeGroup userIDArray:participantUserIDArray success:^(TAPRoomModel *room) {
        if (profilePictureImage != nil) {
            //has image, upload image
            UIImage *imageToSend = [self rotateImage:profilePictureImage];
            NSData *imageData = UIImageJPEGRepresentation(imageToSend, 0.6);
            [TAPDataManager callAPIUploadRoomImageWithImageData:imageData roomID:room.roomID completionBlock:^(TAPRoomModel *room) {
                //Update to group cache
                TAPRoomModel *existingRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:room.roomID];
                existingRoom.name = room.name;
                existingRoom.color = room.color;
                existingRoom.isDeleted = room.isDeleted;
                existingRoom.deleted = room.deleted;
                existingRoom.imageURL = room.imageURL;
                
                if (existingRoom != nil) {
                    [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:existingRoom];
                }

                success(room, YES);
            } progressBlock:^(CGFloat progress, CGFloat total) {
                
            } failureBlock:^(NSError *error) {
                success(room, NO);
            }];
        }
        else {
            [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:room];
            success(room, NO);
        }
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)updateGroupChatRoomDetailsWithGroupRoomID:(NSString *)groupRoomID
                                        groupName:(NSString *)groupName
                                          success:(void (^)(TAPRoomModel *room))success
                                          failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIUpdateRoomWithRoomID:groupRoomID roomName:groupName success:^(TAPRoomModel *room) {
        //Update to group cache
        TAPRoomModel *existingRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:room.roomID];
        existingRoom.name = room.name;
        existingRoom.color = room.color;
        existingRoom.isDeleted = room.isDeleted;
        existingRoom.deleted = room.deleted;
        existingRoom.imageURL = room.imageURL;
        
        if (existingRoom != nil) {
            [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:existingRoom];
        }
        
        success(room);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)updateGroupPicture:(UIImage *)groupPictureImage
                    roomID:(NSString *)roomID
              successBlock:(void (^)(TAPRoomModel *room))successBlock
             progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
              failureBlock:(void (^)(NSError *error))failureBlock {
    UIImage *imageToSend = [self rotateImage:groupPictureImage];
    NSData *imageData = UIImageJPEGRepresentation(imageToSend, 0.6);
    [TAPDataManager callAPIUploadRoomImageWithImageData:imageData roomID:roomID completionBlock:^(TAPRoomModel *room) {
        //Update to group cache
        TAPRoomModel *existingRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:room.roomID];
        existingRoom.name = room.name;
        existingRoom.color = room.color;
        existingRoom.isDeleted = room.isDeleted;
        existingRoom.deleted = room.deleted;
        existingRoom.imageURL = room.imageURL;
        
        if (existingRoom != nil) {
            [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:existingRoom];
        }
        
        successBlock(room);
    } progressBlock:^(CGFloat progress, CGFloat total) {
        progressBlock(progress, total);
    } failureBlock:^(NSError *error) {
        failureBlock(error);
    }];
}

- (void)deleteGroupChatRoom:(TAPRoomModel *)room
                    success:(void (^)(void))success
                    failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIDeleteRoomWithRoom:room success:^{
        //Remove from group preference
        [[TAPGroupManager sharedManager] removeRoomWithRoomID:room.roomID];
        success();
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)leaveGroupChatRoomWithRoomID:(NSString *)roomID
                             success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPILeaveRoomWithRoomID:roomID success:^{
        //Remove from group preference
        [[TAPGroupManager sharedManager] removeRoomWithRoomID:roomID];        
        success();
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)addGroupChatMembersWithUserIDArray:(NSArray *)userIDArray
                                    roomID:(NSString *)roomID
                                   success:(void (^)(TAPRoomModel *room))success
                                   failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIAddRoomParticipantsWithRoomID:roomID userIDArray:userIDArray success:^(TAPRoomModel *room) {
        success(room);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)removeGroupChatMembersWithUserIDArray:(NSArray *)userIDArray
                                       roomID:(NSString *)roomID
                                      success:(void (^)(TAPRoomModel *room))success
                                      failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIRemoveRoomParticipantsWithRoomID:roomID userIDArray:userIDArray success:^(TAPRoomModel *room) {
        success(room);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)promoteGroupAdminsWithUserIDArray:(NSArray *)userIDArray
                                   roomID:(NSString *)roomID
                                  success:(void (^)(TAPRoomModel *room))success
                                  failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIPromoteRoomAdminsWithRoomID:roomID userIDArray:userIDArray success:^(TAPRoomModel *room) {
        success(room);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)demoteGroupAdminsWithUserIDArray:(NSArray *)userIDArray
                                  roomID:(NSString *)roomID
                                 success:(void (^)(TAPRoomModel *room))success
                                 failure:(void (^)(NSError *error))failure {
    [TAPDataManager callAPIDemoteRoomAdminsWithRoomID:roomID userIDArray:userIDArray success:^(TAPRoomModel *room) {
        success(room);
    } failure:^(NSError *error) {
        NSError *localizedError = [[TAPCoreErrorManager sharedManager] generateLocalizedError:error];
        failure(localizedError);
    }];
}

- (void)sendStartTypingEmitWithRoomID:(NSString *)roomID {
    [[TAPChatManager sharedManager] startTypingWithRoomID:roomID];
}

- (void)sendStopTypingEmitWithRoomID:(NSString *)roomID {
    [[TAPChatManager sharedManager] stopTypingWithRoomID:roomID];
}

- (UIImage*)rotateImage:(UIImage* )originalImage {
    UIImageOrientation orientation = originalImage.imageOrientation;
    UIGraphicsBeginImageContext(originalImage.size);
    [originalImage drawAtPoint:CGPointMake(0, 0)];
    CGContextRef context = UIGraphicsGetCurrentContext();

     if (orientation == UIImageOrientationRight) {
         CGContextRotateCTM (context, [self radians:90]);
     } else if (orientation == UIImageOrientationLeft) {
         CGContextRotateCTM (context, [self radians:90]);
     } else if (orientation == UIImageOrientationDown) {
         // NOTHING
     } else if (orientation == UIImageOrientationUp) {
         CGContextRotateCTM (context, [self radians:0]);
     }
      return UIGraphicsGetImageFromCurrentImageContext();
}

- (CGFloat)radians:(int)degree {
    return (degree/180)*(22/7);
}


@end
