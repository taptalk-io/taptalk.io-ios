//
//  TAPRecentSearchModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 20/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"
#import "TAPRoomModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPRecentSearchModel : TAPBaseModel

@property (nonatomic, strong) TAPRoomModel *room;
@property (nonatomic, strong) NSNumber *created;

@end

NS_ASSUME_NONNULL_END
