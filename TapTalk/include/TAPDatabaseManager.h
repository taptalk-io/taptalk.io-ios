//
//  TAPDatabaseManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 27/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAPDatabaseManager : NSObject

+ (TAPDatabaseManager *)sharedManager;

+ (void)loadAllDataFromDatabaseWithQuery:(NSString *)query
                               tableName:(NSString *)tableName
                               sortByKey:(NSString *)columnName
                               ascending:(BOOL)isAscending
                                 success:(void (^)(NSArray *resultArray))success
                                 failure:(void (^)(NSError *error))failure;
/*
 Documentation:
 tableName is RealmModel name and should not be empty.
 fill whereClauseQuery with empty string ("") to ignore query
 sortByColumnName is Key in RealmModel and fill sortByColumnName with empty string ("") to ignore sort
 if sort is ignored, isAscending won't affect anything
 */
+ (void)loadDataFromTableName:(NSString *)tableName
             whereClauseQuery:(NSString *)whereClauseQuery
             sortByColumnName:(NSString *)columnName
                  isAscending:(BOOL)isAscending
                      success:(void (^)(NSArray *resultArray))success
                      failure:(void (^)(NSError *error))failure;
+ (void)loadDataFromTableName:(NSString *)tableName
             whereClauseQuery:(NSString *)whereClauseQuery
             sortByColumnName:(NSString *)columnName
                  isAscending:(BOOL)isAscending
                   distinctBy:(NSString *)distinctKey
                      success:(void (^)(NSArray *resultArray))success
                      failure:(void (^)(NSError *error))failure;
+ (void)loadMessageWithRoomID:(NSString *)roomID
              predicateString:(NSString *)predicateString
                numberOfItems:(NSInteger)numberOfItems
                      success:(void (^)(NSArray *resultArray))success
                      failure:(void (^)(NSError *error))failure;
+ (void)loadMessageWithRoomID:(NSString *)roomID
                numberOfItems:(NSInteger)numberOfItems
                    ascending:(BOOL)ascending
                      success:(void (^)(NSArray *resultArray))success
                      failure:(void (^)(NSError *error))failure;
+ (void)loadRoomListSuccess:(void (^)(NSArray *resultArray))success
                    failure:(void (^)(NSError *error))failure;
+ (void)loadForwardRoomListSuccess:(void (^)(NSArray *resultArray))success
                           failure:(void (^)(NSError *error))failure;
+ (void)insertDataToDatabaseWithData:(NSArray *)dataArray
                           tableName:(NSString *)tableName
                             success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure;
+ (void)insertDataToDatabaseInMainThreadWithData:(NSArray *)dataArray
                                       tableName:(NSString *)tableName
                                         success:(void (^)(void))success
                                         failure:(void (^)(NSError *error))failure;
+ (void)updateOrInsertDataToDatabaseWithData:(NSArray *)dataArray
                                   tableName:(NSString *)tableName
                                     success:(void (^)(void))success
                                     failure:(void (^)(NSError *error))failure;
+ (void)updateOrInsertDataToDatabaseInMainThreadWithData:(NSArray *)dataArray
                                               tableName:(NSString *)tableName
                                                 success:(void (^)(void))success
                                                 failure:(void (^)(NSError *error))failure;
+ (void)deleteAllDataInDatabaseWithSuccess:(void (^)(void))success
                                   failure:(void (^)(NSError *error))failure;
+ (void)deleteAllDataFromTableName:(NSString *)tableName
                           success:(void (^)(void))success
                           failure:(void (^)(NSError *error))failure;
+ (void)deleteDataInDatabaseWithData:(NSArray *)dataArray
                           tableName:(NSString *)tableName
                             success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure;
+ (void)deleteMessageInDatabaseWithRoomID:(NSString *)roomID
                                tableName:(NSString *)tableName
                                  success:(void (^)(void))success
                                  failure:(void (^)(NSError *error))failure;
+ (void)deleteDataInDatabaseInMainThreadWithData:(NSArray *)dataArray
                                       tableName:(NSString *)tableName
                                         success:(void (^)(void))success
                                         failure:(void (^)(NSError *error))failure;
+ (void)deleteDataInDatabaseWithPredicateString:(NSString *)predicateString
                                      tableName:(NSString *)tableName
                                        success:(void (^)(void))success
                                        failure:(void (^)(NSError *error))failure;
- (void)updateMessageToFailedWhenClosed;

- (void)updateMessageToFailedWithColumnName:(NSString *)columnName value:(NSString *)value;

@end
