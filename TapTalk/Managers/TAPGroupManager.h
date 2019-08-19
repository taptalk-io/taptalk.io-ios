//
//  TAPGroupManager.h
//  TapTalk
//
//  Created by Cundy Sunardy on 09/07/19.  
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPGroupManager : NSObject

+ (TAPGroupManager *)sharedManager;

- (TAPRoomModel *)getRoomWithRoomID:(NSString *)roomID;
- (void)setRoomWithRoomID:(NSString *)roomID room:(TAPRoomModel *)room;
- (void)removeRoomWithRoomID:(NSString *)roomID;
- (void)populateRoomFromPreference;
- (void)saveRoomToPreference;

@end

NS_ASSUME_NONNULL_END
