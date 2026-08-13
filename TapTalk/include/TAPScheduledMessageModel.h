//
//  TAPScheduleMessageModel.h
//  TapTalk
//
//  Created by TapTalk.io on 12/10/22.
//

#import "TAPBaseModel.h"
#import "TAPMessageModel.h"

@interface TAPScheduledMessageModel : TAPBaseModel
@property (strong, nonatomic) NSNumber *scheduleID;
@property (nonatomic, strong) TAPMessageModel *message;
@property (strong, nonatomic) NSNumber *scheduleTime;
@end


