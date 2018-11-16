//
//  TAPConnectionStatusView.h
//  TapTalk
//
//  Created by Welly Kencana on 24/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, TAPConnectionStatusType) {
    TAPConnectionStatusTypeNone = 0,
    TAPConnectionStatusTypeConnecting = 1,
    TAPConnectionStatusTypeNetworkError = 2,
    TAPConnectionStatusTypeConnected = 3,
    TAPConnectionStatusTypeOffline = 4,
};

@interface TAPConnectionStatusView : TAPBaseView
- (void)setConnectionStatusType:(TAPConnectionStatusType)connectionStatusType;
@end

NS_ASSUME_NONNULL_END
