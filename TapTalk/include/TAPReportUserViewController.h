//
//  TAPReportUserViewController.h
//  TapTalk
//
//  Created by TapTalk.io on 19/10/22.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPReportType) {
    TAPReportTypeUser = 0,
    TAPReportTypeMessage = 1,
};

@interface TAPReportUserViewController : TAPBaseViewController
@property (nonatomic) TAPReportType reportType;
@property (strong, nonatomic) NSString *messageID;
@property (strong, nonatomic) NSString *roomID;
@property (strong, nonatomic) NSString *userID;
@end

NS_ASSUME_NONNULL_END
