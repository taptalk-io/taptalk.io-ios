//
//  TAPRecentSearchRealmModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 20/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseRealmModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPRecentSearchRealmModel : TAPBaseRealmModel

//Room
@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *roomColor;
@property (nonatomic, strong) NSString *roomImage;
@property (nonatomic) RoomType roomType;
@property (nonatomic, strong) NSNumber<RLMDouble> *created;

@end

NS_ASSUME_NONNULL_END
