//
//  TAPContactCacheManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 31/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPContactCacheManager.h"

@interface TAPContactCacheManager ()

@property (strong, nonatomic) NSMutableArray *delegatesArray;

- (void)updateContactWithUser:(TAPUserModel *)user;
- (void)insertContactToDatabaseWithUserData:(NSArray *)userDataArray;
- (void)insertToContactDictionaryWithDataArray:(NSArray *)contactArray;

@end

@implementation TAPContactCacheManager

#pragma mark - Lifecycle
+ (TAPContactCacheManager *)sharedManager {
    static TAPContactCacheManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _delegatesArray = [[NSMutableArray alloc] init];
        _contactDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)addDelegate:(id)delegate {
    if ([self.delegatesArray containsObject:delegate]) {
        return;
    }
    
    NSLog(@"[WARNING] ChatManager - Do not forget to remove the delegate object, since an object can't weak retained in an array, also please remove this delegate before dealloc or the delegate will always retained");
    
    [self.delegatesArray addObject:delegate];
}

- (void)removeDelegate:(id)delegate {
    [self.delegatesArray removeObject:delegate];
}

- (void)insertToContactDictionaryWithDataArray:(NSArray *)contactArray {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (TAPUserModel *user in contactArray) {
            [self.contactDictionary setObject:user forKey:user.userID];
        }
    });
}

- (void)getUpdatedContactDataWithUserID:(NSString *)userID {
    userID = [TAPUtil nullToEmptyString:userID];
    [TAPDataManager callAPIGetUserByUserID:userID success:^(TAPUserModel *user) {
        [self shouldUpdateUserWithData:user];
    } failure:^(NSError *error) {
        
    }];
}

- (void)insertContactToDatabaseWithUserData:(NSArray *)userDataArray {
    //Insert To Database
    [TAPDataManager updateOrInsertDatabaseContactWithData:userDataArray success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)shouldUpdateUserWithData:(TAPUserModel *)user {
    NSArray *contactArray = @[user];
    //Add to contact dictionary
    [self insertToContactDictionaryWithDataArray:contactArray];
    //Add to database
    [self insertContactToDatabaseWithUserData:contactArray];
    //Call delegate update contact
    [self updateContactWithUser:user];
}

- (void)clearContactDictionary {
    [self.contactDictionary removeAllObjects];
}

- (void)updateContactWithUser:(TAPUserModel *)user {
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(contactCacheManagerDidUpdateContactWithData:)]) {
            [delegate contactCacheManagerDidUpdateContactWithData:user];
        }
    }
}

@end

