//
//  TAPGroupManager.m
//  TapTalk
//
//  Created by Cundy Sunardy on 09/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPGroupManager.h"

@interface TAPGroupManager()

@property (strong, nonatomic) NSMutableDictionary *roomModelDictionary;

@end

@implementation TAPGroupManager
#pragma mark - Lifecycle
+ (TAPGroupManager *)sharedManager {
    static TAPGroupManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _roomModelDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Custom Method
- (TAPRoomModel *)getRoomWithRoomID:(NSString *)roomID {
    TAPRoomModel *room = [self.roomModelDictionary objectForKey:roomID];
    return room;
}

- (void)setRoomWithRoomID:(NSString *)roomID room:(TAPRoomModel *)room {
    if (self.roomModelDictionary == nil) {
        _roomModelDictionary = [[NSMutableDictionary alloc] init];
    }
    
    [self.roomModelDictionary setObject:room forKey:roomID];
}

- (void)removeRoomWithRoomID:(NSString *)roomID {
    [self.roomModelDictionary removeObjectForKey:roomID];
}

- (void)saveRoomToPreference {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.roomModelDictionary];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setSecureObject:encodedObject forKey:TAP_PREFS_ROOM_MODEL_DICTIONARY];
    [defaults synchronize];
}

- (void)populateRoomFromPreference {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults secureObjectForKey:TAP_PREFS_ROOM_MODEL_DICTIONARY valid:nil];
    NSMutableDictionary *roomModelDictionary = [[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject] mutableCopy];
    if (roomModelDictionary != nil) {
        [self.roomModelDictionary addEntriesFromDictionary:roomModelDictionary];
    }
    
}
@end
