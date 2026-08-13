//
//  TAPClearedRoomModel.h
//  TapTalk
//
//  Created by TapTalk.io on 26/09/22.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPClearedRoomModel : TAPBaseModel
@property (nonatomic, strong) NSNumber *clearTime;
@property (strong, nonatomic) NSString *roomID;
@end

NS_ASSUME_NONNULL_END
