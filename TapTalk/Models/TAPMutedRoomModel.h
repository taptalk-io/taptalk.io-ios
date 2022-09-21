//
//  TAPMutedRoomModel.h
//  TapTalk
//
//  Created by TapTalk.io on 08/09/22.
//

#import "TAPBaseModel.h"



@interface TAPMutedRoomModel : TAPBaseModel
@property (nonatomic, strong) NSNumber *expired;
@property (strong, nonatomic) NSString *roomID;
@end


