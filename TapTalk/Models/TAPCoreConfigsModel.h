//
//  TAPCoreConfigsModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 09/08/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPCoreConfigsModel : TAPBaseModel

@property (strong, nonatomic) NSNumber *chatMediaMaxFileSize;
@property (strong, nonatomic) NSNumber *roomPhotoMaxFileSize;
@property (strong, nonatomic) NSNumber *userPhotoMaxFileSize;
@property (strong, nonatomic) NSNumber *groupMaxParticipants;
@property (strong, nonatomic) NSNumber *channelMaxParticipants;
@end

NS_ASSUME_NONNULL_END
