//
//  TAPCoreContactManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAPCoreContactManagerDelegate <NSObject>
- (void)tapTalkDidBlockContact:(TAPUserModel *)user;
- (void)tapTalkDidUnblockContact:(TAPUserModel *)user;
@end

@interface TAPCoreContactManager : NSObject

+ (TAPCoreContactManager *)sharedManager;

@property (weak, nonatomic) id<TAPCoreContactManagerDelegate> delegate;

- (void)getAllUserContactsWithSuccess:(void (^)(NSArray <TAPUserModel *>*userArray))success
                              failure:(void (^)(NSError *error))failure;
- (void)fetchAllUserContactsFromServerWithSuccess:(void (^)(NSArray <TAPUserModel *>*userArray))success
                                          failure:(void (^)(NSError *error))failure;
- (TAPUserModel *)getLocalUserDataWithUserID:(NSString *)userID;
- (void)getUserDataWithUserID:(NSString *)userID
                      success:(void (^)(TAPUserModel *user))success
                      failure:(void (^)(NSError *error))failure;
- (void)getUserDataWithXCUserID:(NSString *)xcUserID
                        success:(void (^)(TAPUserModel *user))success
                        failure:(void (^)(NSError *error))failure;
- (void)saveUserData:(TAPUserModel *)user;
- (void)addToTapTalkContactsWithUserID:(NSString *)userID
                               success:(void (^)(void))success
                               failure:(void (^)(NSError *error))failure;
- (void)addToTapTalkContactsWithPhoneNumber:(NSString *)phoneNumber
                                    success:(void (^)(void))success
                                    failure:(void (^)(NSError *error))failure;
- (void)removeFromTapTalkContactsWithUserID:(NSString *)userID
                                    success:(void (^)(NSString *successMessage))success
                                    failure:(void (^)(NSError *error))failure;
- (void)searchLocalContactsByName:(NSString *)keyword
                          success:(void (^)(NSArray <TAPUserModel *>*userArray))success
                          failure:(void (^)(NSError *error))failure;
- (void)updateActiveUserBio:(NSString *)bio
                    success:(void (^)(void))success
                    failure:(void (^)(NSError *error))failure;
- (void)getGroupsInCommon:(NSString *)userID
                    success:(void (^)(NSArray<TAPRoomModel *> *groupRooms))success
                  failure:(void (^)(NSError *error))failure;
- (void)blockUserWithUserID:(NSString *)userID
                    success:(void (^)(TAPUserModel *blockedUser))success
                    failure:(void (^)(NSError *error))failure;
- (void)unblockUserWithUserID:(NSString *)userID
                      success:(void (^)(TAPUserModel *unblockedUser))success
                      failure:(void (^)(NSError *error))failure;
- (void)getBlockedUserList:(void (^)(NSArray<TAPUserModel *> *blockedUserList))success
                   failure:(void (^)(NSError *error))failure;
- (void)getBlockedUserIDs:(void (^)(NSArray<NSString *> *blockedUserIDs))success
                  failure:(void (^)(NSError *error))failure;
- (void)reportUser:(NSString *)userID
          category:(NSString *)category
   isOtherCategory:(BOOL)isOtherCategory
            reason:(NSString *)reason
           success:(void (^)(BOOL isSuccess))success
           failure:(void (^)(NSError *error))failure;

- (void)reportMessage:(NSString *)messageID
               roomID:(NSString *)roomID
          category:(NSString *)category
   isOtherCategory:(BOOL)isOtherCategory
            reason:(NSString *)reason
           success:(void (^)(BOOL isSuccess))success
              failure:(void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
