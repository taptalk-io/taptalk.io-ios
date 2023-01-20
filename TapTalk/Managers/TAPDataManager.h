//
//  TAPDataManager.h
//  TapTalk
//
//  Created by Ritchie Nathaniel on 20/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPUserModel.h"
#import "TAPRecentSearchModel.h"
#import "TAPCountryModel.h"
#import "TAPProjectConfigsModel.h"
#import "TAPCoreConfigsModel.h"
#import "TAPPhotoListModel.h"
#import "TAPMutedRoomModel.h"
#import "TAPScheduledMessageModel.h"
#import "TAPClearedRoomModel.h"
#import "TapMessageRecipientModel.h"

@import AFNetworking;

@interface TAPDataManager : NSObject

+ (TAPDataManager *)sharedManager;

+ (void)setActiveUser:(TAPUserModel *)user;
+ (TAPUserModel *)getActiveUser;
+ (void)setAccessToken:(NSString *)accessToken expiryDate:(NSTimeInterval)expiryDate;
+ (NSString *)getAccessToken;
+ (NSTimeInterval)getAccessTokenExpiryTime;
+ (void)setRefreshToken:(NSString *)refreshToken expiryDate:(NSTimeInterval)expiryDate;
+ (NSString *)getRefreshToken;
+ (TAPProjectConfigsModel *)getProjectConfigs;
+ (TAPCoreConfigsModel *)getCoreConfigs;
+ (void)setUnreadRoomIDs:(NSArray *)roomIDs;
+ (NSArray *)getUnreadRoomIDs;
+ (void)setLatestPinnedWithMessageRoomID:(TAPMessageModel *)message roomID:(NSInteger)roomID;
+ (NSMutableDictionary *)getLatestPinnedMessage;
+ (void)setPinnedRoomIDs:(NSArray *)roomIDs;
+ (NSArray *)getPinnedRoomIDs;
+ (void)setMutedRoomDictionary:(NSMutableDictionary *)mutedRoomDictionaryList;
+ (NSMutableDictionary *)getMutedRoomDictionary;
+ (void)setBlockedUserIDs:(NSArray *)userIDs;
+ (NSArray *)getBlockedUserIDs;
+ (void)setLastRoomMessageDeleteTime:(long)timestamp;
+ (long)getLastRoomMessageDeleteTime;
+ (void)setPendingScheduleMessages:(NSArray *)scheduleMessages;
+ (NSArray *)getPendingScheduleMessages;
+ (void)updateMessageToFailedWhenClosedInDatabase;
+ (void)updateMessageToFailedWithLocalID:(NSString *)localID;
+ (void)setMessageLastUpdatedWithRoomID:(NSString *)roomID lastUpdated:(NSNumber *)lastUpdated;
+ (NSNumber *)getMessageLastUpdatedWithRoomID:(NSString *)roomID;
+ (void)deletePhysicalFilesWithMessage:(TAPMessageModel *)message
                               success:(void (^)(void))success
                               failure:(void (^)(NSError *error))failure;
+ (void)deletePhysicalFilesInBackgroundWithMessage:(TAPMessageModel *)message
                                           success:(void (^)(void))success
                                           failure:(void (^)(NSError *error))failure;
+ (void)deletePhysicalFileAndMessageSequenceWithMessageArray:(NSArray *)messageArray
                                                     success:(void (^)(void))success
                                                     failure:(void (^)(NSError *error))failure;
+ (void)deleteAllMessageAndPhysicalFilesInRoomWithRoomID:(NSString *)roomID
                                                 success:(void (^)(void))success
                                                 failure:(void (^)(NSError *error))failure;
+ (void)removeImageFromCacheWithMessage:(TAPMessageModel *)message;

//Convert from dictionary to model or model to dictionary
+ (TAPMessageModel *)messageModelFromDictionary:(NSDictionary *)dictionary;
+ (TAPMessageModel *)messageModelFromPayloadWithUserInfo:(NSDictionary *)dictionary;
+ (TAPCountryModel *)countryModelFromDictionary:(NSDictionary *)dictionary;
+ (TAPUserModel *)userModelFromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFromUserModel:(TAPUserModel *)user;
+ (TAPProductModel *)productModelFromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFromProductModel:(TAPProductModel *)product;

+ (NSString *)escapedDatabaseStringFromString:(NSString *)string;
+ (NSString *)normalizedDatabaseStringFromString:(NSString *)string;

//Database Call
+ (void)searchMessageWithString:(NSString *)searchString
                         sortBy:(NSString *)columnName
                        success:(void (^)(NSArray *resultArray))success
                        failure:(void (^)(NSError *error))failure;
+ (void)searchMessageWithString:(NSString *)searchString
                         roomID:(NSString *)roomID
                         sortBy:(NSString *)columnName
                        success:(void (^)(NSArray *resultArray))success
                        failure:(void (^)(NSError *error))failure;
+ (void)getMessageFromDatabaseWithLocalID:(NSString *)localID
                                  success:(void (^)(NSArray<TAPMessageModel *> *resultArray))success
                                  failure:(void (^)(NSError *error))failure;
+ (void)getMessageFromDatabaseWithLocalIDs:(NSArray<NSString *> *)localIDs
                                   success:(void (^)(NSArray<TAPMessageModel *> *resultArray))success
                                   failure:(void (^)(NSError *error))failure;
+ (void)getMessageWithRoomID:(NSString *)roomID
        lastMessageTimeStamp:(NSNumber *)timeStamp
                   limitData:(NSInteger)limit
                     success:(void (^)(NSArray<TAPMessageModel *> *obtainedMessageArray))success
                     failure:(void (^)(NSError *error))failure;
+ (void)getMessageWithRoomID:(NSString *)roomID
        lastMessageTimeStamp:(NSNumber *)timeStamp
                   limitData:(NSInteger)limit
               excludeHidden:(BOOL)excludeHidden
                     success:(void (^)(NSArray<TAPMessageModel *> *obtainedMessageArray))success
                     failure:(void (^)(NSError *error))failure;
+ (void)getAllMessageWithRoomID:(NSString *)roomID
                      sortByKey:(NSString *)columnName
                      ascending:(BOOL)isAscending
                        success:(void (^)(NSArray<TAPMessageModel *> *messageArray))success
                        failure:(void (^)(NSError *error))failure;
+ (void)getAllMessageWithRoomID:(NSString *)roomID
                      sortByKey:(NSString *)columnName
                      ascending:(BOOL)isAscending
                  excludeHidden:(BOOL)excludeHidden
                        success:(void (^)(NSArray<TAPMessageModel *> *messageArray))success
                        failure:(void (^)(NSError *error))failure;
+ (void)getAllMessageWithQuery:(NSString *)query
                     sortByKey:(NSString *)columnName
                     ascending:(BOOL)isAscending
                       success:(void (^)(NSArray<TAPMessageModel *> *messageArray))success
                       failure:(void (^)(NSError *error))failure;
+ (void)getAllMessageWithRoomID:(NSString *)roomID
                   messageTypes:(NSArray *)messageTypeArray
             minimumDateCreated:(NSTimeInterval)minCreated
                      sortByKey:(NSString *)columnName
                      ascending:(BOOL)isAscending
                        success:(void (^)(NSArray<TAPMessageModel *> *messageArray))success
                        failure:(void (^)(NSError *error))failure;
+ (void)getAllMessageWithRoomID:(NSString *)roomID
                   messageTypes:(NSArray *)messageTypeArray
                      sortByKey:(NSString *)columnName
                      ascending:(BOOL)isAscending
                        success:(void (^)(NSArray<TAPMessageModel *> *messageArray))success
                        failure:(void (^)(NSError *error))failure;
+ (void)getRoomListSuccess:(void (^)(NSArray *resultArray))success
                   failure:(void (^)(NSError *error))failure;
+ (void)getForwardRoomListSuccess:(void (^)(NSArray *resultArray))success
                          failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseRecentSearchResultSuccess:(void (^)(NSArray<TAPRecentSearchModel *> *recentSearchArray, NSArray *unreadCountArray, NSDictionary *unreadMentionDictionary))success
                                     failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseAllUnreadMessagesWithSuccess:(void (^)(NSArray *unreadMessages))success
                                        failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseUnreadMessagesInRoomWithRoomID:(NSString *)roomID
                                     activeUserID:(NSString *)activeUserID
                                          success:(void (^)(NSArray *unreadMessages))success
                                          failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseUnreadMentionsInRoomWithUsername:(NSString *)username
                                             roomID:(NSString *)roomID
                                     activeUserID:(NSString *)activeUserID
                                          success:(void (^)(NSArray *unreadMentionMessages))success
                                          failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseMediaMessagesInRoomWithRoomID:(NSString *)roomID
                                   lastTimestamp:(NSString *)lastTimestamp
                                    numberOfItem:(NSInteger)numberOfItem
                                         success:(void (^)(NSArray *mediaMessages))success
                                         failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseFileMessagesInRoomWithRoomID:(NSString *)roomID
                                   lastTimestamp:(NSString *)lastTimestamp
                                    numberOfItem:(NSInteger)numberOfItem
                                         success:(void (^)(NSArray *fileMessages))success
                                        failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseLinkMessagesInRoomWithRoomID:(NSString *)roomID
                                   lastTimestamp:(NSString *)lastTimestamp
                                    numberOfItem:(NSInteger)numberOfItem
                                         success:(void (^)(NSArray *linkMessages))success
                                        failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseUnreadRoomCountWithActiveUserID:(NSString *)activeUserID
                                           success:(void (^)(NSArray *unreadRoomIDs))success
                                           failure:(void (^)(NSError *))failure;
+ (void)getDatabaseOldestCreatedTimeFromRoom:(NSString *)roomID
                                     success:(void (^)(NSNumber *createdTime))success
                                     failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseContactSearchKeyword:(NSString *)keyword
                                 sortBy:(NSString *)columnName
                                success:(void (^)(NSArray *resultArray))success
                                failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseNonContactSearchKeyword:(NSString *)keyword
                                    sortBy:(NSString *)columnName
                                   success:(void (^)(NSArray *resultArray))success
                                   failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseAllUserSortBy:(NSString *)columnName
                         success:(void (^)(NSArray *resultArray))success
                         failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseAllContactSortBy:(NSString *)columnName
                            success:(void (^)(NSArray *resultArray))success
                            failure:(void (^)(NSError *error))failure;
+ (void)searchChatAndContactWithString:(NSString *)searchString
                                SortBy:(NSString *)columnName
                               success:(void (^)(NSArray *roomArray, NSArray *unreadCountArray, NSDictionary *unreadMentionDictionary))success
                               failure:(void (^)(NSError *error))failure;
+ (void)insertDatabaseMessageWithData:(NSArray *)dataArray
                            tableName:(NSString *)tableName
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure;
+ (void)updateOrInsertDatabaseMessageWithData:(NSArray *)dataArray
                                      success:(void (^)(void))success
                                      failure:(void (^)(NSError *error))failure;
+ (void)updateOrInsertDatabaseMessageInMainThreadWithData:(NSArray *)dataArray
                                                  success:(void (^)(void))success
                                                  failure:(void (^)(NSError *error))failure;
+ (void)updateOrInsertDatabaseRecentSearchWithData:(NSArray *)dataArray
                                           success:(void (^)(void))success
                                           failure:(void (^)(NSError *error))failure;
+ (void)updateOrInsertDatabaseContactWithData:(NSArray *)dataArray
                                      success:(void (^)(void))success
                                      failure:(void (^)(NSError *error))failure;
+ (void)updateMessageReadStatusToDatabaseWithData:(NSArray *)dataArray
                                          success:(void (^)(void))success
                                          failure:(void (^)(NSError *error))failure;
+ (void)updateMessageDeliveryStatusToDatabaseWithData:(NSArray *)dataArray
                                              success:(void (^)(void))success
                                              failure:(void (^)(NSError *error))failure;
+ (void)deleteDatabaseMessageWithData:(NSArray *)dataArray
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure;
+ (void)deleteDatabaseMessageWithRoomID:(NSString *)roomID
                                success:(void (^)(void))success
                                failure:(void (^)(NSError *error))failure;
+ (void)deleteDatabaseMessageWithPredicateString:(NSString *)predicateString
                                         success:(void (^)(void))success
                                         failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseContactByUserID:(NSString *)userID
                           success:(void (^)(BOOL isContact, TAPUserModel *obtainedUser))success
                           failure:(void (^)(NSError *error))failure;
+ (void)getDatabaseContactByXCUserID:(NSString *)XCUserID
                           success:(void (^)(BOOL isContact, TAPUserModel *obtainedUser))success
                           failure:(void (^)(NSError *error))failure;
+ (void)deleteDatabaseAllRecentSearchSuccess:(void (^)(void))success
                                     failure:(void (^)(NSError *error))failure;

//API Call
+ (void)callAPILogoutWithSuccess:(void (^)(void))success
                         failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetAccessTokenWithAuthTicket:(NSString *)authTicket
                                    success:(void (^)(void))success
                                    failure:(void (^)(NSError *error))failure;
- (void)callAPIRefreshAccessTokenSuccess:(void (^)(void))success
                                 failure:(void (^)(NSError *error))failure;
+ (void)callAPIValidateAccessTokenAndAutoRefreshSuccess:(void (^)(void))success
                                  failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetMessageRoomListAndUnreadWithUserID:(NSString *)userID
                                             success:(void (^)(NSArray *messageArray))success
                                             failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetNewAndUpdatedMessageSuccess:(void (^)(NSArray *messageArray))success
                                      failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetMessageBeforeWithRoomID:(NSString *)roomID
                               maxCreated:(NSNumber *)maxCreated
                            numberOfItems:(NSNumber *)numberOfItems
                                  success:(void (^)(NSArray *messageArray, BOOL hasMore))success
                                  failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetMessageAfterWithRoomID:(NSString *)roomID
                              minCreated:(NSNumber *)minCreated
                             lastUpdated:(NSNumber *)lastUpdated
          needToSaveLastUpdatedTimestamp:(BOOL)needToSaveLastUpdatedTimestamp
                                 success:(void (^)(NSArray *messageArray))success
                                 failure:(void (^)(NSError *error))failure;
+ (void)callAPISendCustomMessageToPersonalRoomWithRecipientUserID:(NSString *)recipientUserID
                                                          localID:(NSString *)localID
                                                      messageType:(NSInteger)messageType
                                                             body:(NSString *)body
                                                             data:(NSString *)data
                                                         filterID:(NSString *)filterID
                                                         isHidden:(BOOL)isHidden
                                                          success:(void (^)(void))success
                                                          failure:(void (^)(NSError *error))failure;
+ (void)callAPISendCustomMessageWithRoomID:(NSString *)roomID
                                   localID:(NSString *)localID
                               messageType:(NSInteger)messageType
                                      body:(NSString *)body
                                      data:(NSString *)data
                                  filterID:(NSString *)filterID
                                  isHidden:(BOOL)isHidden
                                   success:(void (^)(void))success
                                   failure:(void (^)(NSError *error))failure;
+ (void)callAPIDeleteMessageWithMessageIDs:(NSArray *)messageIDArray
                                    roomID:(NSString *)roomID
                      isDeletedForEveryone:(BOOL)isDeletedForEveryone
                                   success:(void (^)(NSArray *deletedMessageIDArray))success
                                   failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetContactList:(void (^)(NSArray *userArray))success
                      failure:(void (^)(NSError *error))failure;
+ (void)callAPIAddContactWithUserID:(NSString *)userID
                            success:(void (^)(NSString *message, TAPUserModel *user))success
                            failure:(void (^)(NSError *error))failure;
+ (void)callAPIRemoveContactWithUserID:(NSString *)userID
                               success:(void (^)(NSString *message))success
                               failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetUserByUserID:(NSString *)userID
                       success:(void (^)(TAPUserModel *user))success
                       failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetUserByXCUserID:(NSString *)XCUserID
                         success:(void (^)(TAPUserModel *user))success
                         failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetUserByUsername:(NSString *)username
                         success:(void (^)(TAPUserModel *user))success
                         failure:(void (^)(NSError *error))failure;
+ (void)callAPISearchUserByUsernameKeyword:(NSString *)username
                                   success:(void (^)(TAPUserModel *user, NSString *inputKeyword))success
                                   failure:(void (^)(NSError *error, NSString *inputKeyword))failure;
+ (void)callAPIUpdatePushNotificationWithToken:(NSString *)token
                                       isDebug:(BOOL)isDebug
                                       success:(void (^)(void))success
                                       failure:(void (^)(NSError *error))failure;
+ (void)callAPIUpdateMessageDeliverStatusWithArray:(NSArray *)messageArray
                                        success:(void (^)(NSArray *updatedMessageIDsArray))success
                                        failure:(void (^)(NSError *error, NSArray *messageArray))failure;
+ (void)callAPIUpdateMessageReadStatusWithArray:(NSArray *)messageArray
                                        success:(void (^)(NSArray *updatedMessageIDsArray, NSArray *originMessageArray))success
                                        failure:(void (^)(NSError *error, NSArray *messageArray))failure;
+ (NSURLSessionUploadTask *)callAPIUploadFileWithFileData:(NSData *)fileData
                                                   roomID:(NSString *)roomID
                                                 fileName:(NSString *)fileName
                                                 fileType:(NSString *)fileType
                                                 mimeType:(NSString *)mimeType
                                                  caption:(NSString *)caption
                                          completionBlock:(void (^)(NSDictionary *responseObject))successBlock
                                            progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
                                             failureBlock:(void(^)(NSError *error))failureBlock;
+ (NSURLSessionUploadTask *)callAPIUploadUserImageWithImageData:(NSData *)imageData
                                                completionBlock:(void (^)(TAPUserModel *user))successBlock
                                                  progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
                                                   failureBlock:(void(^)(NSError *error))failureBlock;
+ (void)callAPIDownloadFileWithFileID:(NSString *)fileID
                               roomID:(NSString *)roomID
                          isThumbnail:(BOOL)isThumbnail
                      completionBlock:(void (^)(UIImage *downloadedImage))successBlock
                        progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
                         failureBlock:(void(^)(NSError *error))failureBlock;
+ (void)callAPIDownloadFileWithFileID:(NSString *)fileID
                               roomID:(NSString *)roomID
                      completionBlock:(void (^)(NSData *downloadedData))successBlock
                        progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
                         failureBlock:(void(^)(NSError *error))failureBlock;
+ (void)callAPIGetBulkUserByUserID:(NSArray *)userIDArray
                       success:(void (^)(NSArray *userModelArray))success
                           failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetCountryListWithCurrentCountryCode:(NSString *)countryCode
                                            success:(void (^)(NSArray *countryModelArray, NSArray *countryDictionaryArray, NSDictionary *countryListDictionary, TAPCountryModel *defaultLocaleCountry))success
                                            failure:(void (^)(NSError *error))failure;
+ (void)callAPIRequestVerificationCodeWithPhoneNumber:(NSString *)phoneNumber
                                            countryID:(NSString *)countryID
                                               method:(NSString *)method
                                              channel:(NSString *)channel
                                              success:(void (^)(NSString *OTPKey, NSString *OTPID, BOOL isSuccess, NSString *channelString, NSString *whatsAppFailureReason, NSInteger nextRequestSeconds, NSString *successMessage))success
                                              failure:(void (^)(NSError *error))failure;
+ (void)callAPIVerifyOTPWithCode:(NSString *)OTPcode
                           OTPID:(NSString *)OTPID
                          OTPKey:(NSString *)OTPKey
                         success:(void (^)(BOOL isRegistered, NSString *userID, NSString *ticket))success
                         failure:(void (^)(NSError *error))failure;
+ (void)callAPICheckUsername:(NSString *)username
                     success:(void (^)(BOOL isExists, NSString *checkedUsername))success
                     failure:(void (^)(NSError *error))failure;
+ (void)callAPIRegisterWithFullName:(NSString *)fullName
                          countryID:(NSString *)countryID
                              phone:(NSString *)phone
                           username:(NSString *)username
                              email:(NSString *)email
                           password:(NSString *)password
                            success:(void (^)(NSString *userID, NSString *ticket))success
                            failure:(void (^)(NSError *error))failure;
+ (void)callAPIAddContactWithPhones:(NSArray *)phoneNumbers
                            success:(void (^)(NSArray *users))success
                            failure:(void (^)(NSError *error))failure;
+ (void)callAPICreateRoomWithName:(NSString *)roomName
                             type:(NSInteger)roomType
                      userIDArray:(NSArray *)userIDArray
                          success:(void (^)(TAPRoomModel *room))success
                          failure:(void (^)(NSError *error))failure;
+ (NSURLSessionUploadTask *)callAPIUploadRoomImageWithImageData:(NSData *)imageData
                                                         roomID:(NSString *)roomID
                                                completionBlock:(void (^)(TAPRoomModel *room))successBlock
                                                  progressBlock:(void (^)(CGFloat progress, CGFloat total))progressBlock
                                                   failureBlock:(void(^)(NSError *error))failureBlock;
+ (void)callAPIUpdateRoomWithRoomID:(NSString *)roomID
                           roomName:(NSString *)roomName
                            success:(void (^)(TAPRoomModel *room))success
                            failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetRoomWithRoomID:(NSString *)roomID
                         success:(void (^)(TAPRoomModel *room))success
                         failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetRoomWithXCRoomID:(NSString *)xcRoomID
                           success:(void (^)(TAPRoomModel *room))success
                           failure:(void (^)(NSError *error))failure;
+ (void)callAPIAddRoomParticipantsWithRoomID:(NSString *)roomID
                                 userIDArray:(NSArray *)userIDArray
                                     success:(void (^)(TAPRoomModel *room))success
                                     failure:(void (^)(NSError *error))failure;
+ (void)callAPIRemoveRoomParticipantsWithRoomID:(NSString *)roomID
                                    userIDArray:(NSArray *)userIDArray
                                        success:(void (^)(TAPRoomModel *room))success
                                        failure:(void (^)(NSError *error))failure;
+ (void)callAPIPromoteRoomAdminsWithRoomID:(NSString *)roomID
                                    userIDArray:(NSArray *)userIDArray
                                        success:(void (^)(TAPRoomModel *room))success
                                        failure:(void (^)(NSError *error))failure;
+ (void)callAPIDemoteRoomAdminsWithRoomID:(NSString *)roomID
                              userIDArray:(NSArray *)userIDArray
                                  success:(void (^)(TAPRoomModel *room))success
                                  failure:(void (^)(NSError *error))failure;
+ (void)callAPILeaveRoomWithRoomID:(NSString *)roomID
                           success:(void (^)(void))success
                           failure:(void (^)(NSError *error))failure;
+ (void)callAPIDeleteRoomWithRoom:(TAPRoomModel *)room
                          success:(void (^)(void))success
                          failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetProjectConfigsWithSuccess:(void (^)(NSDictionary *projectConfigsDictionary))success
                                    failure:(void (^)(NSError *error))failure;
+ (void)callAPIUpdateBio:(NSString *)bioContent
                            success:(void (^)(TAPUserModel *user))success
                 failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetPhotoList:(NSString *)userID success:(void (^)(NSMutableArray<TAPPhotoListModel *> * photoListArray))success
                      failure:(void (^)(NSError *error))failure;

+ (void)callAPISetProfilePhotoAsMain:(NSInteger)userID
                            success:(void (^)())success
                             failure:(void (^)(NSError *error))failure;
+ (void)callAPIRemovePhotoProfile:(NSInteger)userID createdTime:(long)createdTime
                            success:(void (^)())success
                          failure:(void (^)(NSError *error))failure;
+ (void)callAPIMarkChatRoomAsUnread:(NSArray<NSString *> *)roomIDs
                            success:(void (^)(NSArray<NSString *> *unreadRoomIDs))success
                            failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetMarkedAsUnreadChatRoomList:(void (^)(NSArray<NSString *> *unreadRoomIDs))success
                                     failure:(void (^)(NSError *error))failure;
+ (void)callAPIStarMessage:(NSString *)roomID messageID:(NSArray<NSString *> *)messageID success:(void (^)(NSArray *starredMessageIDs))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIUnStarMessage:(NSString *)roomID messageID:(NSArray<NSString *> *)messageID success:(void (^)(NSArray *messagesArray))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetStarredMessages:(NSString *)roomID pageNumber:(NSInteger)pageNumber numberOfItems:(NSInteger)numberOfItems success:(void (^)(NSArray *starredMessageIDs,BOOL hasMoreData))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetStarredMessageIDs:(NSString *)roomID success:(void (^)(NSMutableArray *starredMessageIDs))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIPinMessage:(NSString *)roomID messageID:(NSArray<NSString *> *)messageIDs success:(void (^)(NSArray *messageIDs))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIUnPinMessage:(NSString *)roomID messageID:(NSArray<NSString *> *)messageIDs success:(void (^)(NSArray *messagesArray))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetPinnedMessages:(NSString *)roomID pageNumber:(NSInteger)pageNumber numberOfItems:(NSInteger)numberOfItems success:(void (^)(NSMutableArray *pinnedMessageIDs,BOOL hasMoreData))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetPinnedMessageIDs:(NSString *)roomID success:(void (^)(NSMutableArray *pinnedMessageIDs))success failure:(void (^)(NSError *error))failure;
+ (void)callAPICheckDeleteAccountState:(void (^)(NSNumber *canDelete))success
                                failure:(void (^)(NSError *error))failure;
+ (void)callAPIRequestVerificationCodeDeleteAccount:(NSString *)channel
                                              success:(void (^)(NSString *OTPKey, NSString *OTPID, BOOL isSuccess, NSString *channelString, NSString *whatsAppFailureReason, NSInteger nextRequestSeconds, NSString *successMessage))success
                                            failure:(void (^)(NSError *error))failure;
+ (void)callAPIVerifyDeleteAccoutOTP:(NSString *)OTPcode
                               OTPID:(NSString *)OTPID
                              OTPKey:(NSString *)OTPKey deletionReason:(NSString *)deletionReason success:(void (^)(NSNumber *isSuccess))success
                             failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetSharedContent:(NSString *)roomID
                     maxCreated:(long)maxCreated
                     minCreated:(long)minCreated success:(void (^)(NSArray <TAPMessageModel *> *mediaMessagesArray, NSArray <TAPMessageModel *> *fileMessagesArray, NSArray <TAPMessageModel *> *linkMessagesArray))success
                        failure:(void (^)(NSError *error))failure;

+ (void)callAPIPinRoom:(NSArray<NSString *> *)roomIDs success:(void (^)(NSArray *roomIDs))success failure:(void (^)(NSError *error))failure;

+ (void)callAPIUnpinRoom:(NSArray<NSString *> *)roomIDs success:(void (^)(NSArray *roomIDs))success failure:(void (^)(NSError *error))failure;

+ (void)callAPIGetPinnedRoomIDs:(void (^)(NSMutableArray *pinnedRoomIDs))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetGroupsInCommon:(NSString *)userID success:(void (^)(NSMutableArray <TAPRoomModel *> *groupsInCommonRoom))success failure:(void (^)(NSError *error))failure;
+ (NSDictionary *)dictionaryFromMessageModel:(TAPMessageModel *)message;
+ (void)callAPIMuteRoom:(NSArray<NSString *> *)roomIDs expiredAt:(NSNumber *)expiredAt success:(void (^)(NSArray *roomIDs))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIUnMuteRoom:(NSArray<NSString *> *)roomIDs success:(void (^)(NSArray *roomIDs))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetMutedRoomList:(void (^)(NSMutableArray<TAPMutedRoomModel *> *mutedRoomListArray))success failure:(void (^)(NSError *error))failure;

+ (void)callAPICreateScheduleMessage:(NSDictionary *)message scheduledTime:(NSNumber *)scheduledTime success:(void (^)(TAPMessageModel *scheduledMessage))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetScheduleMessage:(NSString *)roomID success:(void (^)(NSArray<TAPScheduledMessageModel *> *scheduleMessageArray))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIScheduleMessageSendNow:(NSArray<NSNumber *> *)scheduleIDs roomID:(NSString *)roomID success:(void (^)(NSArray *scheduleIDs))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIEditScheduleMessageTime:(NSNumber *)scheduleID scheduledTime:(NSNumber *)scheduledTime success:(void (^)(BOOL isEditTimeSuccess))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIEditScheduleMessageContent:(NSNumber *)scheduleID updatedMessage:(TAPMessageModel *)updatedMessage success:(void (^)(BOOL isEditContentSuccess))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIDeleteScheduleMessage:(NSArray<NSNumber *> *)scheduleIDs roomID:(NSString *)roomID success:(void (^)(NSArray *deletedIDs))success failure:(void (^)(NSError *error))failure;

+ (void)callAPIDeleteChatroom:(NSArray<NSString *> *)roomIDs success:(void (^)(NSArray *roomIDs))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetMessageDetails:(NSString *)messageID
                     success:(void (^)(TAPMessageModel *message, NSArray <TapMessageRecipientModel *> *deliveredTo, NSArray <TapMessageRecipientModel *> *readBy))success
                         failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetMessageTotalRead:(NSString *)messageID
                     success:(void (^)(NSInteger readCount))success
                           failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetRoomIDsWithState:(void (^)(NSMutableArray<NSString *> *pinnedRoomIDsArray, NSMutableArray<TAPMutedRoomModel *> *mutedRoomModelArray, NSMutableArray<TAPClearedRoomModel *> *clearedRoomModelArray))success failure:(void (^)(NSError *error))failure;

+ (void)callAPIReportUser:(NSString *)userID category:(NSString *)category isOtherCategory:(BOOL)isOtherCategory reason:(NSString *)reason success:(void (^)(BOOL success))isSuccess failure:(void (^)(NSError *error))failure;
+ (void)callAPIReportMessage:(NSString *)messageID roomID:(NSString *)roomID category:(NSString *)category isOtherCategory:(BOOL)isOtherCategory reason:(NSString *)reason success:(void (^)(BOOL success))isSuccess failure:(void (^)(NSError *error))failure;

// Used to prevent inserting message to deleted chat room
+ (void)callAPIBlockUser:(NSString *)userID success:(void (^)(TAPUserModel *blockedUser))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIUnblockUser:(NSString *)userID success:(void (^)(BOOL isSuccess))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetBlockedUserList:(void (^)(NSArray<TAPUserModel *> *blockedUserList))success failure:(void (^)(NSError *error))failure;
+ (void)callAPIGetBlockedUserIDs:(void (^)(NSArray<NSString *> *blockedUserIDs))success failure:(void (^)(NSError *error))failure;
@property (strong, nonatomic) NSMutableArray<NSString *> *deletedRoomIDArray;


@end
