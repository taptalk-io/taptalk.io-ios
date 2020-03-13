//
//  TAPDatabaseManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 27/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPDatabaseManager.h"
#import <Realm/Realm.h>
#import "TAPMessageRealmModel.h"

@interface TAPDatabaseManager ()

- (NSArray *)convertRealmResultIntoArray:(RLMResults *)results;
- (id)convertDictionaryIntoRealmObjectWithData:(NSDictionary *)dataDictionary tableName:(NSString *)tableName;
- (NSData *)getKey;
- (RLMRealm *)createRealm;
+ (RLMResults *)filterResultsWithWhereClauseQuery:(NSString *)whereClauseQuery
                                          results:(RLMResults *)results;
+ (RLMResults *)sortResultsWithColumnName:(NSString *)columnName
                              isAscending:(BOOL)isAscending
                                  results:(RLMResults *)results;

@end

@implementation TAPDatabaseManager

#pragma mark - Lifecycle
+ (TAPDatabaseManager *)sharedManager {
    static TAPDatabaseManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Custom Method

+ (void)loadAllDataFromDatabaseWithQuery:(NSString *)query
                               tableName:(NSString *)tableName
                               sortByKey:(NSString *)columnName
                               ascending:(BOOL)isAscending
                                 success:(void (^)(NSArray *resultArray))success
                                 failure:(void (^)(NSError *error))failure {
    RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
    
    RLMResults *results = [NSClassFromString(tableName) allObjectsInRealm:realm];
    
    if (![query isEqualToString:@""]) {
        results = [results objectsWhere:query];
    }
    
    results = [results distinctResultsUsingKeyPaths:@[columnName]];
    results = [results sortedResultsUsingKeyPath:columnName ascending:isAscending];
    
    NSArray *resultArray = [NSArray array];
    resultArray = [[TAPDatabaseManager sharedManager] convertRealmResultIntoArray:results];
    
    [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
        // handle error
        failure(error);
    }];
    
    success(resultArray);
}

/*
 Documentation:
 tableName is RealmModel name and should not be empty.
 fill query with empty string ("") to ignore query
 columnName is Key in RealmModel and fill columnName with empty string ("") to ignore sort
 if sort is ignored, isAscending won't affect anything
 */

+ (void)loadDataFromTableName:(NSString *)tableName
             whereClauseQuery:(NSString *)whereClauseQuery
             sortByColumnName:(NSString *)columnName
                  isAscending:(BOOL)isAscending
                      success:(void (^)(NSArray *resultArray))success
                      failure:(void (^)(NSError *error))failure {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
        
        RLMResults *results = [NSClassFromString(tableName) allObjectsInRealm:realm];
        
        if ([whereClauseQuery isEqualToString:@""]) {
            //NO FILTER REQUIRED
            if (![columnName isEqualToString:@""]) {
                //NO SORTING
                results = [results sortedResultsUsingKeyPath:columnName ascending:isAscending];
            }
        }
        else {
            //FILTER REQUIRED
            results = [TAPDatabaseManager filterResultsWithWhereClauseQuery:whereClauseQuery results:results];
            if (![columnName isEqualToString:@""]) {
                //SORTING
                results = [TAPDatabaseManager sortResultsWithColumnName:columnName isAscending:isAscending results:results];
            }
        }
        
        NSArray *resultArray = [NSArray array];
        resultArray = [[TAPDatabaseManager sharedManager] convertRealmResultIntoArray:results];

        [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
            // handle error
             dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
             });
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(resultArray);
        });
    });
}

+ (void)loadDataFromTableName:(NSString *)tableName
                  whereClauseQuery:(NSString *)whereClauseQuery
                  sortByColumnName:(NSString *)columnName
                       isAscending:(BOOL)isAscending
                        distinctBy:(NSString *)distinctKey
                      success:(void (^)(NSArray *resultArray))success
                      failure:(void (^)(NSError *error))failure {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
        
        RLMResults *results = [NSClassFromString(tableName) allObjectsInRealm:realm];
        
        if ([whereClauseQuery isEqualToString:@""]) {
            //NO FILTER REQUIRED
            if (![columnName isEqualToString:@""]) {
                //NO SORTING
                results = [results sortedResultsUsingKeyPath:columnName ascending:isAscending];
            }
        }
        else {
            //FILTER REQUIRED
            results = [TAPDatabaseManager filterResultsWithWhereClauseQuery:whereClauseQuery results:results];
            if (![columnName isEqualToString:@""]) {
                //SORTING
                results = [TAPDatabaseManager sortResultsWithColumnName:columnName isAscending:isAscending results:results];
            }
        }
        
        results = [results distinctResultsUsingKeyPaths:@[distinctKey]];
        
        NSArray *resultArray = [NSArray array];
        resultArray = [[TAPDatabaseManager sharedManager] convertRealmResultIntoArray:results];

        [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
            // handle error
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(resultArray);
        });
    });
}

+ (void)loadMessageWithRoomID:(NSString *)roomID
              predicateString:(NSString *)predicateString
                numberOfItems:(NSInteger)numberOfItems
                      success:(void (^)(NSArray *resultArray))success
                      failure:(void (^)(NSError *error))failure {
//RN Note - Somehow the performance is better when the load is not thrown to async, if thrown to async, sometimes it caused stuck on tableview scroll, so temporarily disabling async
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
        RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
        
        RLMResults *results = [TAPMessageRealmModel allObjectsInRealm:realm];
        results = [results objectsWhere:[NSString stringWithFormat:@"roomID == '%@'", roomID]];
        results = [results sortedResultsUsingKeyPath:@"created" ascending:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        results = [results objectsWithPredicate:predicate];
        if ([results count] == 0) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                success([NSArray array]);
//            });
        }
        else {
            if (numberOfItems == 0) {
                //No limit
                NSArray *resultArray = [NSArray array];
                resultArray = [[TAPDatabaseManager sharedManager] convertRealmResultIntoArray:results];
                
                [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
                    // handle error
                    //                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                    //                });
                }];
                //            dispatch_async(dispatch_get_main_queue(), ^{
                success(resultArray);
                //            });
            }
            else {
                //with limit
                if ([results count] < numberOfItems) {
                    //Result is less than limit
                    TAPMessageRealmModel *tempMessageModel = [results objectAtIndex:[results count] - 1];
                    NSString *secondLimiterPredicateString = [NSString stringWithFormat:@"created >= %lf", [tempMessageModel.created doubleValue]];
                    //    NSString *combinedPredicateString = [NSString stringWithFormat:@"%@ %@", predicateString, secondLimiterPredicateString];
                    predicate = [NSPredicate predicateWithFormat:secondLimiterPredicateString];
                    results = [results objectsWithPredicate:predicate];
                    
                    NSArray *resultArray = [NSArray array];
                    resultArray = [[TAPDatabaseManager sharedManager] convertRealmResultIntoArray:results];
                    
                    [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
                        // handle error
                        //                dispatch_async(dispatch_get_main_queue(), ^{
                        failure(error);
                        //                });
                    }];
                    
                    //            dispatch_async(dispatch_get_main_queue(), ^{
                    success(resultArray);
                    //            });
                }
                else {
                    //Result is greater or equal to limit
                    TAPMessageRealmModel *tempMessageModel = [results objectAtIndex:numberOfItems - 1];
                    NSString *secondLimiterPredicateString = [NSString stringWithFormat:@"created >= %lf", [tempMessageModel.created doubleValue]];
                    //    NSString *combinedPredicateString = [NSString stringWithFormat:@"%@ %@", predicateString, secondLimiterPredicateString];
                    predicate = [NSPredicate predicateWithFormat:secondLimiterPredicateString];
                    results = [results objectsWithPredicate:predicate];
                    
                    NSArray *resultArray = [NSArray array];
                    resultArray = [[TAPDatabaseManager sharedManager] convertRealmResultIntoArray:results];
                    
                    [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
                        // handle error
                        //                dispatch_async(dispatch_get_main_queue(), ^{
                        failure(error);
                        //                });
                    }];
                    //            dispatch_async(dispatch_get_main_queue(), ^{
                    success(resultArray);
                    //            });
                }
            }
        }
//        else if ([results count] < numberOfItems) {
//            TAPMessageRealmModel *tempMessageModel = [results objectAtIndex:[results count] - 1];
//            NSString *secondLimiterPredicateString = [NSString stringWithFormat:@"created >= %lf", [tempMessageModel.created doubleValue]];
//            //    NSString *combinedPredicateString = [NSString stringWithFormat:@"%@ %@", predicateString, secondLimiterPredicateString];
//            predicate = [NSPredicate predicateWithFormat:secondLimiterPredicateString];
//            results = [results objectsWithPredicate:predicate];
//
//            NSArray *resultArray = [NSArray array];
//            resultArray = [[TAPDatabaseManager sharedManager] convertRealmResultIntoArray:results];
//
//            [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
//                // handle error
////                dispatch_async(dispatch_get_main_queue(), ^{
//                    failure(error);
////                });
//            }];
//
////            dispatch_async(dispatch_get_main_queue(), ^{
//                success(resultArray);
////            });
//        }
//        else {
//            TAPMessageRealmModel *tempMessageModel = [results objectAtIndex:numberOfItems - 1];
//            NSString *secondLimiterPredicateString = [NSString stringWithFormat:@"created >= %lf", [tempMessageModel.created doubleValue]];
//            //    NSString *combinedPredicateString = [NSString stringWithFormat:@"%@ %@", predicateString, secondLimiterPredicateString];
//            predicate = [NSPredicate predicateWithFormat:secondLimiterPredicateString];
//            results = [results objectsWithPredicate:predicate];
//
//            NSArray *resultArray = [NSArray array];
//            resultArray = [[TAPDatabaseManager sharedManager] convertRealmResultIntoArray:results];
//
//            [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
//                // handle error
////                dispatch_async(dispatch_get_main_queue(), ^{
//                    failure(error);
////                });
//            }];
////            dispatch_async(dispatch_get_main_queue(), ^{
//                success(resultArray);
////            });
//        }
//    });
}

+ (void)loadRoomListSuccess:(void (^)(NSArray *resultArray))success
                    failure:(void (^)(NSError *error))failure {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
        
        RLMResults *results = [TAPMessageRealmModel allObjectsInRealm:realm];

        results = [results objectsWhere:@"isHidden == 0"];
        results = [results sortedResultsUsingKeyPath:@"created" ascending:NO];
        results = [results distinctResultsUsingKeyPaths:@[@"roomID"]];
        
        NSArray *resultArray = [NSArray array];
        resultArray = [[TAPDatabaseManager sharedManager] convertRealmResultIntoArray:results];
        
        [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
            // handle error
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(resultArray);
        });
    });
}

+ (void)insertDataToDatabaseWithData:(NSArray *)dataArray
                           tableName:(NSString *)tableName
                             success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure {
    
    if ([dataArray count] <= 0) {
        [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
            // handle error
            failure(error);
        }];
        
        success();
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_async(queue, ^{
         @autoreleasepool {
             NSMutableArray *resultArray = [NSMutableArray array];
             for (NSDictionary *dataDictionary in dataArray) {
                 id resultRealmModel = [[TAPDatabaseManager sharedManager] convertDictionaryIntoRealmObjectWithData:dataDictionary tableName:tableName];
                 [resultArray addObject:resultRealmModel];
             }
             
             RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
             
             [realm beginWriteTransaction];
             [realm addObjects:resultArray];
             [realm commitWriteTransaction];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
                     // handle error
                     failure(error);
                 }];
                 
                 success();
             });
        }
    });
}

+ (void)insertDataToDatabaseInMainThreadWithData:(NSArray *)dataArray
                                       tableName:(NSString *)tableName
                                         success:(void (^)(void))success
                                         failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSDictionary *dataDictionary in dataArray) {
        id resultRealmModel = [[TAPDatabaseManager sharedManager] convertDictionaryIntoRealmObjectWithData:dataDictionary tableName:tableName];
        [resultArray addObject:resultRealmModel];
    }
    
    RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
    
    [realm beginWriteTransaction];
    [realm addObjects:resultArray];
    [realm commitWriteTransaction];

    [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
        // handle error
        failure(error);
    }];

    success();
}

+ (void)updateOrInsertDataToDatabaseWithData:(NSArray *)dataArray
                                   tableName:(NSString *)tableName
                                     success:(void (^)(void))success
                                     failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @autoreleasepool {
            NSMutableArray *resultArray = [NSMutableArray array];
            for (NSDictionary *dataDictionary in dataArray) {
                id resultRealmModel = [[TAPDatabaseManager sharedManager] convertDictionaryIntoRealmObjectWithData:dataDictionary tableName:tableName];
                [resultArray addObject:resultRealmModel];
            }
            
            RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
            
            [realm beginWriteTransaction];
            [realm addOrUpdateObjects:resultArray];
            [realm commitWriteTransaction];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
                // handle error
                failure(error);
            }];
            
            success();
        });
    });
}

+ (void)updateOrInsertDataToDatabaseInMainThreadWithData:(NSArray *)dataArray
                                               tableName:(NSString *)tableName
                                                 success:(void (^)(void))success
                                                 failure:(void (^)(NSError *error))failure {
    if ([dataArray count] <= 0) {
        success();
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSDictionary *dataDictionary in dataArray) {
        id resultRealmModel = [[TAPDatabaseManager sharedManager] convertDictionaryIntoRealmObjectWithData:dataDictionary tableName:tableName];
        [resultArray addObject:resultRealmModel];
    }
    
    RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObjects:resultArray];
    [realm commitWriteTransaction];
    
    [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
        // handle error
        failure(error);
    }];
    
    success();
}

+ (void)deleteAllDataInDatabaseWithSuccess:(void (^)(void))success
                                   failure:(void (^)(NSError *error))failure {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @autoreleasepool {
            RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
            [realm beginWriteTransaction];
            [realm deleteAllObjects];
            [realm commitWriteTransaction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
                    // handle error
                    failure(error);
                }];
                
                success();
            });
        }
    });
}

+ (void)deleteAllDataFromTableName:(NSString *)tableName
                           success:(void (^)(void))success
                           failure:(void (^)(NSError *error))failure {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @autoreleasepool {
            RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
            
            RLMResults *results = [NSClassFromString(tableName) allObjectsInRealm:realm];
            [realm beginWriteTransaction];
            [realm deleteObjects:results];
            [realm commitWriteTransaction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
                    // handle error
                    failure(error);
                }];
                
                success();
            });
        }
    });
}

+ (void)deleteDataInDatabaseWithData:(NSArray *)dataArray
                           tableName:(NSString *)tableName
                             success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @autoreleasepool {
            NSMutableArray *resultArray = [NSMutableArray array];
            for (NSDictionary *dataDictionary in dataArray) {
                id resultRealmModel = [[TAPDatabaseManager sharedManager] convertDictionaryIntoRealmObjectWithData:dataDictionary tableName:tableName];
                [resultArray addObject:resultRealmModel];
            }
            
            RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
            
            NSString *predicateString = @"";
            for (NSInteger counter = 0; counter < [resultArray count]; counter++) {
                TAPMessageRealmModel *messageRealm = [resultArray objectAtIndex:counter];
                predicateString = [NSString stringWithFormat:@"%@localID LIKE '%@'", predicateString, messageRealm.localID];
                if (counter < [resultArray count] - 1) {
                    predicateString = [NSString stringWithFormat:@"%@ OR ", predicateString];
                }
            }
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
            RLMResults *results = [TAPMessageRealmModel allObjectsInRealm:realm];
            results = [results objectsWithPredicate:predicate];
            [realm beginWriteTransaction];
            [realm deleteObjects:results];
            [realm commitWriteTransaction];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
                    // handle error
                    failure(error);
                }];
                
                success();
            });
        }
    });
}

+ (void)deleteDataInDatabaseInMainThreadWithData:(NSArray *)dataArray
                                       tableName:(NSString *)tableName
                                         success:(void (^)(void))success
                                         failure:(void (^)(NSError *error))failure {
    @autoreleasepool {
        NSMutableArray *resultArray = [NSMutableArray array];
        for (NSDictionary *dataDictionary in dataArray) {
            id resultRealmModel = [[TAPDatabaseManager sharedManager] convertDictionaryIntoRealmObjectWithData:dataDictionary tableName:tableName];
            [resultArray addObject:resultRealmModel];
        }
        
        RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
        
        NSString *predicateString = @"";
        for (NSInteger counter = 0; counter < [resultArray count]; counter++) {
            TAPMessageRealmModel *messageRealm = [resultArray objectAtIndex:counter];
            predicateString = [NSString stringWithFormat:@"%@localID LIKE '%@'", predicateString, messageRealm.localID];
            if (counter < [resultArray count] - 1) {
                predicateString = [NSString stringWithFormat:@"%@ OR ", predicateString];
            }
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        RLMResults *results = [TAPMessageRealmModel allObjectsInRealm:realm];
        results = [results objectsWithPredicate:predicate];
        [realm beginWriteTransaction];
        [realm deleteObjects:results];
        [realm commitWriteTransaction];
        
        [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
            // handle error
            failure(error);
        }];
        
        success();
    }
}

+ (void)deleteDataInDatabaseWithPredicateString:(NSString *)predicateString
                                      tableName:(NSString *)tableName
                                        success:(void (^)(void))success
                                        failure:(void (^)(NSError *error))failure {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @autoreleasepool {
            NSMutableArray *resultArray = [NSMutableArray array];
            
            RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
            Class databaseClass = NSClassFromString(tableName);
            RLMResults *results = [[databaseClass class] allObjectsInRealm:realm];
            results = [results objectsWithPredicate:predicate];
            [realm beginWriteTransaction];
            [realm deleteObjects:results];
            [realm commitWriteTransaction];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[RLMSyncManager sharedManager] setErrorHandler:^(NSError *error, RLMSyncSession *session) {
                    // handle error
                    failure(error);
                }];
                
                success();
            });
        }
    });
    
}

- (NSArray *)convertRealmResultIntoArray:(RLMResults *)results {
    NSMutableArray *resultDataArray = [NSMutableArray array];
    
    for (TAPBaseRealmModel *object in results) {
        NSDictionary *resultDictionary = [object toDictionary];
        [resultDataArray addObject:resultDictionary];
    }
    
    return resultDataArray;
}

- (id)convertDictionaryIntoRealmObjectWithData:(NSDictionary *)dataDictionary tableName:(NSString *)tableName {
    Class databaseClass = NSClassFromString(tableName);
    id resultRealmModel = [[databaseClass alloc] initWithDictionary:dataDictionary error:nil];
    return resultRealmModel;
}

- (NSData *)getKey {
    NSString *keyString = @"1234567890123456789012345678901234567890123456789012345678901234"; //DV Note - encryption key to be changed
    NSData *key = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    return key;
}

- (RLMRealm *)createRealm {
    RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
    configuration.encryptionKey = [[TAPDatabaseManager sharedManager] getKey];
    
    // Set the new schema version. This must be greater than the previously used
    // version (if you've never set a schema version before, the version is 0).
    configuration.schemaVersion = 6;
    
    //NOTES - CHANGES
    //SCHEMA VERSION - 1
    //Add phoneWithCode, countryCallingCode, countryID in TAPContactRealmModel
    //SCHEMA VERSION - 2
    //Add replyToXcUserID, replyToFullname, replyToUserID in TAPMessageRealmModel
    //SCHEMA VERSION - 3
    //Add deleted in TAPContactRealmModel
    //Add userDeleted in TAPMessageRealmModel
    //SCHEMA VERSION - 4 - 9 July 2019
    //Add action, groupTargetType, groupTargetID, groupTargetXCID, groupTargetName  in TAPMessageRealmModel
    //SCHEMA VERSION - 5 - 25 July 2019
    //Add roomIsDeleted, roomDeleted  in TAPMessageRealmModel
    //SCHEMA VERSION - 6 - 24 January 2019
    //Add roomIsLocked, xcRoomID in TAPMessageRealmModel

    // Set the block which will be called automatically when opening a Realm with a
    // schema version lower than the one set above
    configuration.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // We haven’t migrated anything yet, so oldSchemaVersion == 6
        if (oldSchemaVersion < 6) {
            // Nothing to do!
            // Realm will automatically detect new properties and removed properties
            // And will update the schema on disk automatically
        }
    };
    
    RLMRealm *realm = [RLMRealm realmWithConfiguration:configuration
                                                 error:nil];
    
    return realm;
}

+ (RLMResults *)filterResultsWithWhereClauseQuery:(NSString *)whereClauseQuery
                                          results:(RLMResults *)results {
    
    results = [results objectsWhere:whereClauseQuery];
    return results;
}

+ (RLMResults *)sortResultsWithColumnName:(NSString *)columnName
                              isAscending:(BOOL)isAscending
                                  results:(RLMResults *)results {
    results = [results sortedResultsUsingKeyPath:columnName ascending:isAscending];
    return results;
}

- (void)updateMessageToFailedWhenClosed {
    RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
    
    RLMResults *results = [TAPMessageRealmModel objectsInRealm:realm where:@"isSending == true"];
    
    if ([results count] != 0) {
        [realm beginWriteTransaction];
        for (TAPMessageRealmModel *messageRealmModel in results) {
            messageRealmModel.isSending = [NSNumber numberWithBool:NO];
            messageRealmModel.isFailedSend = [NSNumber numberWithBool:YES];
        }
        [realm commitWriteTransaction];
    }
}

- (void)updateMessageToFailedWithColumnName:(NSString *)columnName value:(NSString *)value {
    RLMRealm *realm = [[TAPDatabaseManager sharedManager] createRealm];
    
    NSString *whereClause = [NSString stringWithFormat:@"isSending == true AND %@ LIKE '%@'",columnName, value];
    
    RLMResults *results = [TAPMessageRealmModel objectsInRealm:realm where:whereClause];
    
    if ([results count] != 0) {
        [realm beginWriteTransaction];
        for (TAPMessageRealmModel *messageRealmModel in results) {
            messageRealmModel.isSending = [NSNumber numberWithBool:NO];
            messageRealmModel.isFailedSend = [NSNumber numberWithBool:YES];
        }
        [realm commitWriteTransaction];
    }
}

@end
